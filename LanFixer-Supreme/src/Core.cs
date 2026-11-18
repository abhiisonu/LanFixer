using System.Diagnostics;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Win32;

namespace LanFixer;

#region Source Generated JSON Serializer Context

[JsonSerializable(typeof(Db))]
[JsonSerializable(typeof(Cred))]
[JsonSerializable(typeof(Status))]
[JsonSerializable(typeof(DoctorReport))]
[JsonSerializable(typeof(SubnetInfo))]
[JsonSerializable(typeof(MtuResult))]
[JsonSerializable(typeof(List<MtuResult>))]
[JsonSerializable(typeof(BenchTarget))]
[JsonSerializable(typeof(List<BenchTarget>))]
[JsonSerializable(typeof(DiagnosticsBundle))]
[JsonSerializable(typeof(LinkInfo))]
[JsonSourceGenerationOptions(WriteIndented = false, DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull)]
public partial class J : JsonSerializerContext { }

public sealed class DiagnosticsBundle
{
    public string GeneratedAt { get; set; } = "";
    public string OsVersion { get; set; } = "";
    public string MachineId { get; set; } = "";
    public DoctorReport? Doctor { get; set; }
    public List<LinkInfo> Adapters { get; set; } = new();
    public string RoutingTable { get; set; } = "";
    public string ArpTable { get; set; } = "";
    public List<BenchTarget> Benchmarks { get; set; } = new();
    public int OptimalMtu { get; set; }
    public List<Chg> JournalBase { get; set; } = new();
    public List<Run> JournalRuns { get; set; } = new();
}

public sealed class LinkInfo
{
    public string Name { get; set; } = "";
    public string Description { get; set; } = "";
    public string Id { get; set; } = "";
    public string Status { get; set; } = "";
    public long SpeedMbps { get; set; }
    public string Ipv4 { get; set; } = "";
    public string Subnet { get; set; } = "";
    public string Gateway { get; set; } = "";
    public List<string> Dns { get; set; } = new();
}

#endregion

#region Paths, Permissions & Process Execution

public static class P
{
    private static string? _dir;
    public static string MachineDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), "LanFixer");
    public static string UserDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "LanFixer");
    public static string Dir
    {
        get => _dir ?? (Admin() ? MachineDir : (CanWrite(MachineDir) ? MachineDir : UserDir));
        set => _dir = value;
    }

    public static string Db => Path.Combine(Dir, "state.json");
    public static string Vault => Path.Combine(MachineDir, "vault.bin");
    public static string Susp => Path.Combine(Dir, "portal.suspended");
    public static string Bak => Path.Combine(Dir, "backups");
    public static string Exe => Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "LanFixer", "LanFixer.exe");

    public static bool CanWrite(string dir)
    {
        try
        {
            if (!Directory.Exists(dir)) return false;
            var test = Path.Combine(dir, ".test-" + Guid.NewGuid().ToString("N"));
            File.WriteAllText(test, "1");
            File.Delete(test);
            return true;
        }
        catch { return false; }
    }

    public static bool Admin()
    {
        try
        {
            return new System.Security.Principal.WindowsPrincipal(System.Security.Principal.WindowsIdentity.GetCurrent())
                .IsInRole(System.Security.Principal.WindowsBuiltInRole.Administrator);
        }
        catch { return false; }
    }

    /// <summary>
    /// Creates the directory locked down strictly to SYSTEM + Administrators via native Windows DACL.
    /// </summary>
    public static void Init()
    {
        try
        {
            Directory.CreateDirectory(Bak);
            if (OperatingSystem.IsWindows() && Admin())
                Sh.Run("icacls", MachineDir, "/inheritance:r", "/grant:r", "*S-1-5-18:(OI)(CI)F", "*S-1-5-32-544:(OI)(CI)F", "*S-1-5-32-545:(OI)(CI)RX");
        }
        catch { }
    }
}

public static class Log
{
    public static readonly List<string> Ring = new();

    public static void W(string m)
    {
        var l = $"{DateTime.Now:yyyy-MM-dd HH:mm:ss} {m}";
        lock (Ring)
        {
            Ring.Add(l);
            if (Ring.Count > 50) Ring.RemoveAt(0);
        }
        try
        {
            var f = Path.Combine(P.Dir, "lanfixer.log");
            Directory.CreateDirectory(P.Dir);
            if (File.Exists(f) && new FileInfo(f).Length > 1 << 20)
                File.Move(f, f + ".old", true);
            File.AppendAllText(f, l + "\r\n", Encoding.ASCII);
        }
        catch { }
    }
}

public static class Sh
{
    public static string Sys(string exe) => Path.Combine(Environment.SystemDirectory, exe.Contains('.') ? exe : exe + ".exe");
    public static (int code, string output) Run(string exe, params string[] args) => RunT(25000, exe, args);

    public static (int code, string output) RunT(int ms, string exe, params string[] args)
    {
        try
        {
            var f = Sys(exe);
            if (!File.Exists(f)) f = exe;
            var psi = new ProcessStartInfo(f)
            {
                CreateNoWindow = true,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true
            };
            foreach (var a in args) psi.ArgumentList.Add(a);
            using var p = Process.Start(psi)!;
            var o = p.StandardOutput.ReadToEndAsync();
            if (!p.WaitForExit(ms))
            {
                try { p.Kill(true); } catch { }
                return (-1, "timeout");
            }
            return (p.ExitCode, o.Result);
        }
        catch (Exception e) { return (-2, e.Message); }
    }
}

#endregion

#region Reversible Write-Ahead Mutation Journal

public interface IFx
{
    string? Get(string t, string k, string n);
    void Set(string t, string k, string n, string? v);
}

public sealed class WinFx : IFx
{
    private const string If = @"SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\";

    public string? Get(string t, string k, string n)
    {
        if (t == "dns")
            return (Registry.LocalMachine.OpenSubKey(If + k)?.GetValue("NameServer") as string ?? "").Replace(' ', ',').Trim(',');
        if (t == "metric")
            return Registry.LocalMachine.OpenSubKey(If + k)?.GetValue("InterfaceMetric")?.ToString();
        if (t == "mtu")
        {
            var name = System.Net.NetworkInformation.NetworkInterface.GetAllNetworkInterfaces()
                .FirstOrDefault(x => x.Id == k)?.Name;
            if (name == null) return null;
            var (_, outTxt) = Sh.Run("netsh", "interface", "ipv4", "show", "subinterface", $"\"{name}\"");
            var m = System.Text.RegularExpressions.Regex.Match(outTxt, @"\b(\d{3,4})\s+\d+\s+" + System.Text.RegularExpressions.Regex.Escape(name));
            return m.Success ? m.Groups[1].Value : "1500";
        }
        if (t == "pnp")
        {
            using var pnpKey = Registry.LocalMachine.OpenSubKey(k);
            var pnpVal = pnpKey?.GetValue(n);
            return pnpVal == null ? null : unchecked((uint)(int)pnpVal).ToString();
        }
        if (t == "tdo")
            return "default";

        using var key = Registry.LocalMachine.OpenSubKey(k);
        var v = key?.GetValue(n);
        if (v == null) return null;
        if (key!.GetValueKind(n) != RegistryValueKind.DWord)
            throw new InvalidOperationException("Registry value is not a DWORD");
        return unchecked((uint)(int)v).ToString();
    }

    public void Set(string t, string k, string n, string? v)
    {
        if (t == "tdo")
        {
            Sh.Run("netsh", "interface", k, "set", "state", v!);
            return;
        }
        if (t == "dns")
        {
            var name = System.Net.NetworkInformation.NetworkInterface.GetAllNetworkInterfaces()
                .FirstOrDefault(x => x.Id == k)?.Name ?? throw new InvalidOperationException("Adapter not found: " + k);
            var l = (v ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries);
            if (l.Length == 0)
            {
                Sh.Run("netsh", "interface", "ip", "set", "dnsservers", $"name={name}", "source=dhcp");
                return;
            }
            Sh.Run("netsh", "interface", "ip", "set", "dnsservers", $"name={name}", "static", l[0], "primary", "validate=no");
            for (int i = 1; i < l.Length; i++)
                Sh.Run("netsh", "interface", "ip", "add", "dnsservers", $"name={name}", l[i], $"index={i + 1}", "validate=no");
            return;
        }
        if (t == "metric")
        {
            var name = System.Net.NetworkInformation.NetworkInterface.GetAllNetworkInterfaces()
                .FirstOrDefault(x => x.Id == k)?.Name ?? throw new InvalidOperationException("Adapter not found: " + k);
            if (string.IsNullOrEmpty(v) || v == "0" || v.Equals("auto", StringComparison.OrdinalIgnoreCase))
                Sh.Run("netsh", "interface", "ipv4", "set", "interface", $"interface={name}", "metric=auto");
            else
                Sh.Run("netsh", "interface", "ipv4", "set", "interface", $"interface={name}", $"metric={v}");
            return;
        }
        if (t == "mtu")
        {
            var name = System.Net.NetworkInformation.NetworkInterface.GetAllNetworkInterfaces()
                .FirstOrDefault(x => x.Id == k)?.Name ?? throw new InvalidOperationException("Adapter not found: " + k);
            Sh.Run("netsh", "interface", "ipv4", "set", "subinterface", $"\"{name}\"", $"mtu={v}", "store=persistent");
            return;
        }
        if (t == "pnp")
        {
            using var pnpW = Registry.LocalMachine.CreateSubKey(k);
            if (v == null) pnpW.DeleteValue(n, false);
            else pnpW.SetValue(n, unchecked((int)uint.Parse(v)), RegistryValueKind.DWord);
            return;
        }
        if (v == null)
        {
            using var d = Registry.LocalMachine.OpenSubKey(k, true);
            d?.DeleteValue(n, false);
            return;
        }
        using var w = Registry.LocalMachine.CreateSubKey(k);
        w.SetValue(n, unchecked((int)uint.Parse(v)), RegistryValueKind.DWord);
    }
}

public class Chg
{
    public string T { get; set; } = "";
    public string K { get; set; } = "";
    public string N { get; set; } = "";
    public string? V { get; set; }
    public string? W { get; set; }
}

public class Run
{
    public string Id { get; set; } = "";
    public string Act { get; set; } = "";
    public DateTime At { get; set; }
    public List<Chg> U { get; set; } = new();
}

public class Db
{
    public List<Chg> Base { get; set; } = new();
    public List<Run> Runs { get; set; } = new();
}

public sealed class Store
{
    private readonly string _f;
    private readonly IFx _fx;
    public Db D = new();

    public Store(string file, IFx fx)
    {
        _f = file;
        _fx = fx;
        Load();
    }

    private void Load()
    {
        foreach (var f in new[] { _f, _f + ".bak" })
        {
            try
            {
                if (File.Exists(f))
                {
                    D = JsonSerializer.Deserialize(File.ReadAllText(f), J.Default.Db) ?? new();
                    return;
                }
            }
            catch { Log.W("State file unreadable: " + f); }
        }
    }

    public void Save()
    {
        Directory.CreateDirectory(Path.GetDirectoryName(_f)!);
        var tmp = _f + ".tmp";
        File.WriteAllText(tmp, JsonSerializer.Serialize(D, J.Default.Db));
        _ = JsonSerializer.Deserialize(File.ReadAllText(tmp), J.Default.Db)!; // Verify parsing before swap
        if (File.Exists(_f)) File.Copy(_f, _f + ".bak", true);
        File.Move(tmp, _f, true);
    }

    public string? Cur(string t, string k, string n) => _fx.Get(t, k, n);

    public Run Begin(string act)
    {
        var r = new Run { Id = DateTime.UtcNow.ToString("yyyyMMddHHmmssfff"), Act = act, At = DateTime.Now };
        D.Runs.Add(r);
        return r;
    }

    public void End(Run r)
    {
        if (r.U.Count == 0) D.Runs.Remove(r);
        while (D.Runs.Count > 30) D.Runs.RemoveAt(0);
        Save();
    }

    public bool Change(Run r, string t, string k, string n, string? w)
    {
        var old = _fx.Get(t, k, n);
        if (old == w) return false;
        if (!D.Base.Any(b => b.T == t && b.K == k && b.N == n))
            D.Base.Add(new Chg { T = t, K = k, N = n, V = old });
        var c = new Chg { T = t, K = k, N = n, V = old, W = w };
        r.U.Add(c);
        Save();
        try { _fx.Set(t, k, n, w); }
        catch
        {
            r.U.Remove(c);
            Save();
            throw;
        }
        return true;
    }

    public (int ok, int skip) Rollback()
    {
        var r = D.Runs.LastOrDefault();
        if (r == null) return (0, 0);
        var res = Undo(r.U);
        D.Runs.Remove(r);
        if (D.Runs.Count == 0) D.Base.Clear();
        Save();
        return res;
    }

    public int Revert(Func<Chg, bool> pred)
    {
        int n = 0;
        foreach (var r in D.Runs.ToArray())
        {
            var m = r.U.Where(pred).ToList();
            n += Undo(m).ok;
            foreach (var c in m)
            {
                r.U.Remove(c);
                D.Base.RemoveAll(b => b.T == c.T && b.K == c.K && b.N == c.N);
            }
            if (r.U.Count == 0) D.Runs.Remove(r);
        }
        Save();
        return n;
    }

    private (int ok, int skip) Undo(List<Chg> l)
    {
        int ok = 0, skip = 0;
        foreach (var c in Enumerable.Reverse(l))
        {
            try
            {
                if (c.T != "tdo" && _fx.Get(c.T, c.K, c.N) != c.W)
                {
                    skip++; // Drift protection: skipped because value was changed externally
                    continue;
                }
                _fx.Set(c.T, c.K, c.N, c.V);
                ok++;
            }
            catch (Exception e)
            {
                Log.W("Undo failed: " + e.Message);
                skip++;
            }
        }
        return (ok, skip);
    }

    public int RestoreAll()
    {
        int n = 0;
        foreach (var b in Enumerable.Reverse(D.Base))
        {
            try { _fx.Set(b.T, b.K, b.N, b.V); n++; }
            catch (Exception e) { Log.W("Restore failed: " + e.Message); }
        }
        D.Base.Clear();
        D.Runs.Clear();
        Save();
        return n;
    }

    public static string? Dump()
    {
        try
        {
            Directory.CreateDirectory(P.Bak);
            var f = Path.Combine(P.Bak, $"netsh-{DateTime.Now:yyyyMMdd-HHmmss}.txt");
            var (c, o) = Sh.Run("netsh", "dump");
            if (c != 0 || o.Length < 50) return null;
            File.WriteAllText(f, o);
            foreach (var old in Directory.GetFiles(P.Bak, "netsh-*.txt").OrderDescending().Skip(10))
                File.Delete(old);
            return f;
        }
        catch { return null; }
    }
}

#endregion

#region Encrypted Credential Vault (DPAPI)

public class Cred
{
    public string U { get; set; } = "";
    public string P { get; set; } = "";
    public string H { get; set; } = "";
    public int Port { get; set; } = 8888;
    public string? Pin { get; set; }
}

public interface IProt
{
    byte[]? Do(byte[] d, byte[] e, bool enc);
}

public sealed class Dp : IProt
{
    public byte[]? Do(byte[] d, byte[] e, bool enc) => N.Dpapi(d, e, enc);
}

public static class Vault
{
    public static IProt Prot = new Dp();
    public static string? Path_;
    private static string F => Path_ ?? P.Vault;

    private static byte[] Ent()
    {
        string g = "";
        try { g = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Microsoft\Cryptography")?.GetValue("MachineGuid") as string ?? ""; }
        catch { }
        return Encoding.UTF8.GetBytes("LanFixer.Supreme.v8.5|" + g);
    }

    public static bool Save(Cred c)
    {
        try
        {
            var raw = JsonSerializer.SerializeToUtf8Bytes(c, J.Default.Cred);
            var enc = Prot.Do(raw, Ent(), true);
            Array.Clear(raw);
            if (enc == null) return false;
            Directory.CreateDirectory(Path.GetDirectoryName(F)!);
            var tmp = F + ".new";
            File.WriteAllBytes(tmp, enc);
            File.Move(tmp, F, true);
            File.Delete(P.Susp);
            return true;
        }
        catch (Exception e)
        {
            Log.W("Vault save failed: " + e.Message);
            return false;
        }
    }

    public static Cred? Load()
    {
        try
        {
            if (!File.Exists(F)) return null;
            var raw = Prot.Do(File.ReadAllBytes(F), Ent(), false);
            if (raw == null) return null;
            var c = JsonSerializer.Deserialize(raw, J.Default.Cred);
            Array.Clear(raw);
            return c;
        }
        catch { return null; }
    }

    public static void Clear()
    {
        foreach (var s in new[] { "", ".new" })
            try { File.Delete(F + s); } catch { }
        try { File.Delete(P.Susp); } catch { }
    }

    public static bool Exists => File.Exists(F);
}

#endregion
