using System.IO.Pipes;
using System.Net.NetworkInformation;
using System.Runtime.InteropServices;
using System.Security.AccessControl;
using System.Security.Principal;
using System.Text.Json;
using Microsoft.Win32;

namespace LanFixer;

public class Status
{
    public string State { get; set; } = "Starting";
    public string Adapter { get; set; } = "";
    public string Ip { get; set; } = "";
    public string Gw { get; set; } = "";
    public string Since { get; set; } = "";
    public string Last { get; set; } = "";
    public int Ms { get; set; } = -1;
    public int GwMs { get; set; } = -1;
    public int NetMs { get; set; } = -1;
    public int Loss { get; set; }
    public int Heals { get; set; }
    public bool Vault { get; set; }
    public bool Susp { get; set; }
    public bool Busy { get; set; }
    public bool Reboot { get; set; }
    public bool Changes { get; set; }
    public List<int> Hist { get; set; } = new();
    public List<string> Events { get; set; } = new();
}

/// <summary>
/// Silent background monitor: event-driven via NetworkChange + battery-aware adaptive cadence.
/// Serves status and control commands over a secured named pipe.
/// </summary>
public static class Mon
{
    public static Status S = new();
    private static readonly SemaphoreSlim Kick = new(0, 1);
    private static St _prev = St.Offline;
    private static int _streak;
    private static string _fp = "?";
    private static DateTime _lastHeal = DateTime.MinValue, _since = DateTime.Now, _dnsChk = DateTime.Now;
    private static readonly Queue<DateTime> _heals = new();
    private static readonly Queue<bool> _loss = new();

    private static void Poke()
    {
        if (Kick.CurrentCount == 0) Kick.Release();
    }

    public static async Task Run(CancellationToken ct)
    {
        Engine.Init();
        Log.W("Service daemon started");
        Pipe.Start(ct);

        NetworkChange.NetworkAddressChanged += (_, _) => Poke();
        NetworkChange.NetworkAvailabilityChanged += (_, _) => Poke();

        while (!ct.IsCancellationRequested)
        {
            try { await Tick(ct); }
            catch (OperationCanceledException) { break; }
            catch (Exception e) { Log.W("Tick error: " + e.Message); }

            try
            {
                if (await Kick.WaitAsync(TimeSpan.FromSeconds(Policy.Interval(_prev, N.OnBattery())), ct))
                    await Task.Delay(2000, ct); // Debounce to allow DHCP to settle
            }
            catch (OperationCanceledException) { break; }
        }
        Log.W("Service daemon stopped");
    }

    private static async Task Tick(CancellationToken ct)
    {
        var lk = Net.Primary();
        var st = St.NoLink;
        string loc = "";
        int ms = -1, gw = -1, net = -1;
        var fp = Net.Fingerprint(lk);

        if (fp != _fp)
        {
            if (_fp != "?" && Engine.S.D.Runs.Count > 0)
            {
                int n = Engine.S.Revert(c => c.T == "dns");
                if (n > 0) Log.W($"Network roamed: reverted {n} rescue DNS overrides to DHCP");
            }
            _fp = fp;
            _streak = 0;
        }

        if (lk != null)
        {
            var bind = lk.Ip != "" && !lk.Ip.StartsWith("169.254.") ? lk.Ip : null;
            (st, loc, ms) = await Net.Probe(bind, ct);
            if (lk.Gw != "") gw = await Net.Rtt(lk.Gw, 800);
            if (st == St.Online) net = await Net.Rtt("1.1.1.1", 1200);

            // Automatically manage route metrics between Ethernet and Wi-Fi
            Net.ApplyRouteShield(Engine.S, lk, st);
        }

        _loss.Enqueue(st == St.Online && net < 0 && gw < 0);
        if (_loss.Count > 10) _loss.Dequeue();

        lock (S)
        {
            if (st != _prev)
            {
                Ev($"{_prev} -> {st}");
                _since = DateTime.Now;
            }
            S.State = st.ToString();
            S.Ms = ms;
            S.GwMs = gw;
            S.NetMs = net;
            S.Loss = _loss.Count(x => x) * 100 / Math.Max(1, _loss.Count);
            S.Adapter = lk?.Name ?? "";
            S.Ip = lk?.Ip ?? "";
            S.Gw = lk?.Gw ?? "";
            S.Since = _since.ToString("o");
            S.Vault = Vault.Exists;
            S.Susp = File.Exists(P.Susp);
            S.Busy = Engine.Busy;
            S.Reboot = Engine.Pending;
            S.Changes = Engine.S.D.Runs.Count > 0;
            S.Hist.Add(net >= 0 ? net : ms >= 0 ? ms : -1);
            if (S.Hist.Count > 40) S.Hist.RemoveAt(0);
        }

        _prev = st;
        _streak = st is St.Offline or St.NoDns ? _streak + 1 : 0;

        if (st == St.Online)
        {
            if ((DateTime.Now - _dnsChk).TotalMinutes >= 5 && Engine.S.D.Runs.Any(r => r.U.Any(u => u.T == "dns")) && lk != null)
            {
                _dnsChk = DateTime.Now;
                if ((await Dns.Rank(Dns.Dhcp(lk.Id), ct)).Count > 0)
                {
                    Engine.S.Revert(c => c.T == "dns");
                    Ev("DHCP DNS restored: rescue DNS override removed");
                }
            }
        }
        else if (st == St.Captive)
        {
            var m = await Engine.Do("autologin", ct);
            if (m != "throttled" && !m.StartsWith("Busy")) Ev(m);
        }
        else if (Policy.ShouldHeal(st, _streak, _lastHeal, _heals.Count(h => (DateTime.Now - h).TotalHours < 1), DateTime.Now, Engine.Pending))
        {
            _lastHeal = DateTime.Now;
            _heals.Enqueue(_lastHeal);
            while (_heals.Count > 3) _heals.Dequeue();
            Ev("Autonomous auto-repair started");
            var m = await Engine.Do("auto", ct);
            Ev(m);
            lock (S) S.Heals++;
        }
    }

    private static void Ev(string m)
    {
        Log.W(m);
        lock (S)
        {
            S.Last = m;
            S.Events.Add($"{DateTime.Now:HH:mm:ss} {m}");
            if (S.Events.Count > 8) S.Events.RemoveAt(0);
        }
    }

    public static string Json()
    {
        lock (S) return JsonSerializer.Serialize(S, J.Default.Status);
    }
}

public static class Pipe
{
    private const string Name = "LanFixer";

    internal static NamedPipeServerStream Make()
    {
        var ps = new PipeSecurity();
        ps.AddAccessRule(new(new SecurityIdentifier(WellKnownSidType.NetworkSid, null), PipeAccessRights.FullControl, AccessControlType.Deny)); // Deny network access
        ps.AddAccessRule(new(new SecurityIdentifier(WellKnownSidType.LocalSystemSid, null), PipeAccessRights.FullControl, AccessControlType.Allow));
        ps.AddAccessRule(new(new SecurityIdentifier(WellKnownSidType.BuiltinAdministratorsSid, null), PipeAccessRights.FullControl, AccessControlType.Allow));
        ps.AddAccessRule(new(new SecurityIdentifier(WellKnownSidType.AuthenticatedUserSid, null), PipeAccessRights.ReadWrite, AccessControlType.Allow));
        return NamedPipeServerStreamAcl.Create(Name, PipeDirection.InOut, 4, PipeTransmissionMode.Byte, PipeOptions.Asynchronous, 4096, 4096, ps);
    }

    private static readonly HashSet<string> Allowed = new()
    {
        "status", "repair", "reset", "rollback", "restore", "login", "tune1", "tune2", "audit"
    };

    public static void Start(CancellationToken ct)
    {
        for (int i = 0; i < 3; i++) _ = Loop(ct);
    }

    private static async Task Loop(CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            try
            {
                await using var s = Make();
                await s.WaitForConnectionAsync(ct);
                using var rd = new StreamReader(s);
                var cmd = ((await rd.ReadLineAsync(ct)) ?? "").Trim();
                string resp;
                if (cmd == "status")
                    resp = Mon.Json();
                else if (Allowed.Contains(cmd))
                    resp = await Engine.Do(cmd, ct);
                else
                    resp = "Refused: unknown command";

                await using var wr = new StreamWriter(s) { AutoFlush = true };
                await wr.WriteLineAsync(resp.AsMemory(), ct);
            }
            catch (OperationCanceledException) { break; }
            catch { }
        }
    }
}

public static class Ipc
{
    public static async Task<string?> Ask(string cmd, int timeoutMs = 25000)
    {
        try
        {
            using var c = new CancellationTokenSource(timeoutMs);
            await using var s = new NamedPipeClientStream(".", "LanFixer", PipeDirection.InOut, PipeOptions.Asynchronous);
            await s.ConnectAsync(c.Token);
            await using var wr = new StreamWriter(s) { AutoFlush = true };
            await wr.WriteLineAsync(cmd.AsMemory(), c.Token);
            using var rd = new StreamReader(s);
            return await rd.ReadLineAsync(c.Token);
        }
        catch { return null; }
    }

    public static string? AskSync(string cmd, int timeoutMs = 25000) =>
        Ask(cmd, timeoutMs).GetAwaiter().GetResult();
}

public static class Svc
{
    private static nint _h;
    private static N.SERVICE_STATUS _st;
    private static CancellationTokenSource? _cts;

    public static unsafe int Run()
    {
        var name = "LanFixer\0";
        fixed (char* pn = name)
        {
            nint[] tab = { (nint)pn, Marshal.GetFunctionPointerForDelegate<Action<uint, nint>>(SvcMain), 0, 0 };
            fixed (nint* pt = tab)
            {
                if (!N.StartServiceCtrlDispatcherW((nint)pt))
                {
                    Log.W("StartServiceCtrlDispatcher failed: " + Marshal.GetLastWin32Error());
                    return 1;
                }
            }
        }
        return 0;
    }

    private static unsafe void SvcMain(uint argc, nint argv)
    {
        _st = new N.SERVICE_STATUS { dwServiceType = 0x10, dwControlsAccepted = 1 }; // SERVICE_WIN32_OWN_PROCESS, SERVICE_ACCEPT_STOP
        _h = N.RegisterServiceCtrlHandlerExW("LanFixer", Marshal.GetFunctionPointerForDelegate<Func<uint, uint, nint, nint, uint>>(Handler), 0);
        if (_h == 0) return;

        Set(2); // START_PENDING
        _cts = new CancellationTokenSource();
        Set(4); // RUNNING

        try { Mon.Run(_cts.Token).GetAwaiter().GetResult(); }
        finally { Set(1); } // STOPPED
    }

    private static uint Handler(uint ctrl, uint type, nint data, nint ctx)
    {
        if (ctrl is 1 or 2) // STOP or SHUTDOWN
        {
            Set(3); // STOP_PENDING
            _cts?.Cancel();
            return 0;
        }
        return 0x78; // ERROR_CALL_NOT_IMPLEMENTED
    }

    private static void Set(uint state)
    {
        _st.dwCurrentState = state;
        N.SetServiceStatus(_h, ref _st);
    }
}

public static class Setup
{
    public static int Install()
    {
        if (!P.Admin()) { Console.Error.WriteLine("Administrative privileges required."); return 40; }
        P.Init();
        var cur = Environment.ProcessPath ?? "";
        var curDir = Path.GetDirectoryName(cur);
        var targetDir = Path.GetDirectoryName(P.Exe)!;
        Directory.CreateDirectory(targetDir);
        if (!cur.Equals(P.Exe, StringComparison.OrdinalIgnoreCase))
        {
            Sh.Run("taskkill", "/f", "/im", "LanFixer.exe");
            if (!string.IsNullOrEmpty(curDir) && Directory.Exists(curDir))
            {
                foreach (var file in Directory.GetFiles(curDir, "LanFixer.*"))
                {
                    try { File.Copy(file, Path.Combine(targetDir, Path.GetFileName(file)), true); } catch { }
                }
            }
            try { File.Copy(cur, P.Exe, true); } catch { }
        }

        Sh.Run("sc", "create", "LanFixer", $"binPath=\"{P.Exe} service\"", "start=delayed-auto", "displayname=LanFixer Network Guardian");
        Sh.Run("sc", "description", "LanFixer", "Silent network guardian: captive portal automation and self-healing.");
        Sh.Run("sc", "failure", "LanFixer", "reset=86400", "actions=restart/5000/restart/10000/restart/30000");
        Sh.Run("sc", "start", "LanFixer");

        // Autostart Tray for all users
        using var rk = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Run", true);
        rk?.SetValue("LanFixerTray", $"\"{P.Exe}\" tray");

        Console.WriteLine("[OK] LanFixer service installed & started. System tray guard configured for autostart.");
        return 0;
    }

    public static int Uninstall(bool purge, bool keep)
    {
        if (!P.Admin()) { Console.Error.WriteLine("Administrative privileges required."); return 40; }
        if (!keep)
        {
            Console.WriteLine("Restoring all settings to Windows original baseline...");
            Engine.Init();
            Engine.Restore();
        }

        Sh.Run("sc", "stop", "LanFixer");
        Sh.Run("sc", "delete", "LanFixer");
        Sh.Run("taskkill", "/f", "/im", "LanFixer.exe");

        using var rk = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Run", true);
        rk?.DeleteValue("LanFixerTray", false);

        if (purge)
        {
            try { Directory.Delete(P.Dir, true); } catch { }
            Console.WriteLine("[OK] LanFixer uninstalled and data directory purged.");
        }
        else
        {
            Console.WriteLine("[OK] LanFixer uninstalled. Backups preserved in " + P.Bak);
        }
        return 0;
    }
}
