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
    public string State { get; set; } = "Starting"; public string Adapter { get; set; } = ""; public string Ip { get; set; } = ""; public string Gw { get; set; } = "";
    public string Since { get; set; } = ""; public string Last { get; set; } = "";
    public int Ms { get; set; } = -1; public int GwMs { get; set; } = -1; public int NetMs { get; set; } = -1; public int Loss { get; set; } public int Heals { get; set; }
    public bool Vault { get; set; } public bool Susp { get; set; } public bool Busy { get; set; } public bool Reboot { get; set; } public bool Changes { get; set; }
    public List<int> Hist { get; set; } = new(); public List<string> Events { get; set; } = new();
}

/// <summary>The silent monitor: event-driven (NetworkChange) + adaptive polling. Never shows UI; talks to the tray/dashboard over a pipe.</summary>
static class Mon
{
    public static Status S = new(); static readonly SemaphoreSlim Kick = new(0, 1);
    static St _prev = St.Offline; static int _streak; static string _fp = "?"; static DateTime _lastHeal = DateTime.MinValue, _since = DateTime.Now, _dnsChk = DateTime.Now;
    static readonly Queue<DateTime> _heals = new(); static readonly Queue<bool> _loss = new();
    static void Poke() { if (Kick.CurrentCount == 0) Kick.Release(); }

    public static async Task Run(CancellationToken ct)
    {
        Engine.Init(); Log.W("service started"); Pipe.Start(ct);
        NetworkChange.NetworkAddressChanged += (_, _) => Poke(); NetworkChange.NetworkAvailabilityChanged += (_, _) => Poke();
        while (!ct.IsCancellationRequested)
        {
            try { await Tick(ct); } catch (OperationCanceledException) { break; } catch (Exception e) { Log.W("tick error: " + e.Message); }
            try { if (await Kick.WaitAsync(TimeSpan.FromSeconds(Policy.Interval(_prev, N.OnBattery())), ct)) await Task.Delay(2000, ct); }   // 2 s debounce: let DHCP settle after a change
            catch (OperationCanceledException) { break; }
        }
        Log.W("service stopped");
    }

    static async Task Tick(CancellationToken ct)
    {
        var lk = Net.Primary(); var st = St.NoLink; string loc = ""; int ms = -1, gw = -1, net = -1;
        var fp = Net.Fingerprint(lk);
        if (fp != _fp) { if (_fp != "?" && Engine.S.D.Runs.Count > 0) { int n = Engine.S.Revert(c => c.T == "dns"); if (n > 0) Log.W($"network changed: reverted {n} DNS override(s) to DHCP"); } _fp = fp; _streak = 0; }
        if (lk != null)
        {
            var bind = lk.Ip != "" && !lk.Ip.StartsWith("169.254.") ? lk.Ip : null;
            (st, loc, ms) = await Net.Probe(bind, ct);
            if (lk.Gw != "") gw = await Net.Rtt(lk.Gw, 800);
            if (st == St.Online) net = await Net.Rtt("1.1.1.1", 1200);
        }
        _loss.Enqueue(st == St.Online && net < 0 && gw < 0); if (_loss.Count > 10) _loss.Dequeue();
        lock (S)
        {
            if (st != _prev) { Ev($"{_prev} -> {st}"); _since = DateTime.Now; }
            S.State = st.ToString(); S.Ms = ms; S.GwMs = gw; S.NetMs = net; S.Loss = _loss.Count(x => x) * 100 / Math.Max(1, _loss.Count);
            S.Adapter = lk?.Name ?? ""; S.Ip = lk?.Ip ?? ""; S.Gw = lk?.Gw ?? ""; S.Since = _since.ToString("o");
            S.Vault = Vault.Exists; S.Susp = File.Exists(P.Susp); S.Busy = Engine.Busy; S.Reboot = Engine.Pending; S.Changes = Engine.S.D.Runs.Count > 0;
            S.Hist.Add(net >= 0 ? net : ms >= 0 ? ms : -1); if (S.Hist.Count > 40) S.Hist.RemoveAt(0);
        }
        _prev = st; _streak = st is St.Offline or St.NoDns ? _streak + 1 : 0;
        if (st == St.Online)
        {
            if ((DateTime.Now - _dnsChk).TotalMinutes >= 5 && Engine.S.D.Runs.Any(r => r.U.Any(u => u.T == "dns")) && lk != null)
            {   // a DNS rescue stays only until the DHCP-provided resolvers answer again
                _dnsChk = DateTime.Now; if ((await Dns.Rank(Dns.Dhcp(lk.Id), ct)).Count > 0) { Engine.S.Revert(c => c.T == "dns"); Ev("DHCP DNS healthy again: rescue DNS removed"); }
            }
        }
        else if (st == St.Captive) { var m = await Engine.Do("autologin", ct); if (m != "throttled" && !m.StartsWith("Busy")) Ev(m); }
        else if (Policy.ShouldHeal(st, _streak, _lastHeal, _heals.Count(h => (DateTime.Now - h).TotalHours < 1), DateTime.Now, Engine.Pending))
        {
            _lastHeal = DateTime.Now; _heals.Enqueue(_lastHeal); while (_heals.Count > 3) _heals.Dequeue();
            Ev("auto-repair started"); var m = await Engine.Do("auto", ct); Ev(m); lock (S) S.Heals++;
        }
    }
    static void Ev(string m) { Log.W(m); lock (S) { S.Last = m; S.Events.Add($"{DateTime.Now:HH:mm:ss} {m}"); if (S.Events.Count > 8) S.Events.RemoveAt(0); } }
    public static string Json() { lock (S) return JsonSerializer.Serialize(S, J.Default.Status); }
}

static class Pipe
{
    const string Name = "LanFixer";
    internal static NamedPipeServerStream Make()
    {
        var ps = new PipeSecurity();
        ps.AddAccessRule(new(new SecurityIdentifier(WellKnownSidType.NetworkSid, null), PipeAccessRights.FullControl, AccessControlType.Deny));   // local only
        ps.AddAccessRule(new(new SecurityIdentifier(WellKnownSidType.LocalSystemSid, null), PipeAccessRights.FullControl, AccessControlType.Allow));
        ps.AddAccessRule(new(new SecurityIdentifier(WellKnownSidType.BuiltinAdministratorsSid, null), PipeAccessRights.FullControl, AccessControlType.Allow));
        ps.AddAccessRule(new(new SecurityIdentifier(WellKnownSidType.AuthenticatedUserSid, null), PipeAccessRights.ReadWrite, AccessControlType.Allow));
        return NamedPipeServerStreamAcl.Create(Name, PipeDirection.InOut, 4, PipeTransmissionMode.Byte, PipeOptions.Asynchronous, 4096, 4096, ps);
    }
    static readonly HashSet<string> Allowed = new() { "status", "repair", "reset", "rollback", "restore", "login", "tune1", "tune2", "audit" };
    public static void Start(CancellationToken ct) { for (int i = 0; i < 3; i++) _ = Loop(ct); }
    static async Task Loop(CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
            try
            {
                await using var s = Make(); await s.WaitForConnectionAsync(ct);
                using var rd = new StreamReader(s); var cmd = ((await rd.ReadLineAsync(ct)) ?? "").Trim();
                var reply = !Allowed.Contains(cmd) ? "Unknown command." : cmd == "status" ? Mon.Json() : (await Engine.Do(cmd, ct)).Replace('\n', ' ');
                await new StreamWriter(s) { AutoFlush = true }.WriteLineAsync(reply);
            }
            catch (OperationCanceledException) { }
            catch (Exception e) { Log.W("pipe: " + e.Message); try { await Task.Delay(500, ct); } catch { } }
    }
}

/// <summary>Client side: ask the service; null when it is not running.</summary>
static class Ipc
{
    public static async Task<string?> Ask(string cmd, int ms = 90000)
    {
        try
        {
            await using var c = new NamedPipeClientStream(".", "LanFixer", PipeDirection.InOut, PipeOptions.Asynchronous);
            using var t = new CancellationTokenSource(ms); await c.ConnectAsync(600, t.Token);
            await new StreamWriter(c) { AutoFlush = true }.WriteLineAsync(cmd);
            return await new StreamReader(c).ReadLineAsync(t.Token);
        }
        catch { return null; }
    }
    public static string? AskSync(string cmd, int ms = 90000) => Ask(cmd, ms).GetAwaiter().GetResult();
}

/// <summary>Raw Windows-service host (no ServiceBase package needed, AOT-safe).</summary>
static unsafe class Svc
{
    static nint _h; static readonly CancellationTokenSource Cts = new();
    public static int Run()
    {
        var t = (nint*)NativeMemory.AllocZeroed(4 * (nuint)sizeof(nint));
        t[0] = Marshal.StringToHGlobalUni("LanFixer"); t[1] = (nint)(delegate* unmanaged<int, nint, void>)&ServiceMain;
        return N.StartServiceCtrlDispatcherW((nint)t) ? 0 : 1;
    }
    static void Set(uint s) { var x = new N.SS { type = 0x10, state = s, accepted = s == 4 ? 5u : 0, check = s is 2 or 3 ? 1u : 0, wait = s is 2 or 3 ? 5000u : 0 }; N.SetServiceStatus(_h, ref x); }
    [UnmanagedCallersOnly] static void ServiceMain(int c, nint v)
    {
        _h = N.RegisterServiceCtrlHandlerExW("LanFixer", (nint)(delegate* unmanaged<uint, uint, nint, nint, uint>)&Ctl, 0);
        Set(2); Set(4);
        try { Mon.Run(Cts.Token).GetAwaiter().GetResult(); } catch (Exception e) { Log.W("fatal: " + e); }
        Set(1);
    }
    [UnmanagedCallersOnly] static uint Ctl(uint c, uint e, nint d, nint x) { if (c is 1 or 5) { Set(3); Cts.Cancel(); } return 0; }
}

/// <summary>Install / uninstall. The exe is copied to Program Files so a SYSTEM service never runs from a user-writable folder.</summary>
static class Setup
{
    public static int Install()
    {
        if (!P.Admin()) { Console.Error.WriteLine("Run from an elevated prompt."); return 40; }
        P.Init(); Sh.Run("sc", "stop", "LanFixer");
        var self = Environment.ProcessPath!; Directory.CreateDirectory(Path.GetDirectoryName(P.Exe)!);
        if (!string.Equals(self, P.Exe, StringComparison.OrdinalIgnoreCase)) { for (int i = 0; i < 10; i++) try { File.Copy(self, P.Exe, true); break; } catch { Thread.Sleep(500); } }
        Sh.Run("icacls", Path.GetDirectoryName(P.Exe)!, "/inheritance:r", "/grant:r", "*S-1-5-18:(OI)(CI)F", "*S-1-5-32-544:(OI)(CI)F", "*S-1-5-32-545:(OI)(CI)RX");
        Sh.Run("sc", "delete", "LanFixer");
        var r = Sh.Run("sc", "create", "LanFixer", "binPath=", $"\"{P.Exe}\" service", "start=", "delayed-auto", "obj=", "LocalSystem", "DisplayName=", "LanFixer Network Guardian");
        if (r.code != 0) { Console.Error.WriteLine("sc create failed: " + r.output); return 1; }
        Sh.Run("sc", "description", "LanFixer", "Silent network watchdog: detects drops and captive portals, repairs safely, signs in automatically.");
        Sh.Run("sc", "failure", "LanFixer", "reset=", "86400", "actions=", "restart/5000/restart/5000/restart/30000");
        Registry.LocalMachine.CreateSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Run").SetValue("LanFixerTray", $"\"{P.Exe}\" tray");
        r = Sh.Run("sc", "start", "LanFixer");
        Console.WriteLine(r.code == 0 ? $"Installed to {P.Exe}. Service running. Tray starts at next sign-in (or run: LanFixer tray)." : "Installed, but the service did not start: " + r.output); return r.code == 0 ? 0 : 1;
    }
    public static int Uninstall(bool purge, bool keep)
    {
        if (!P.Admin()) { Console.Error.WriteLine("Run from an elevated prompt."); return 40; }
        Sh.Run("sc", "stop", "LanFixer"); Thread.Sleep(2500);
        if (!keep) { Engine.Init(); Console.WriteLine(Engine.Restore()); }                    // leave Windows exactly as found
        Vault.Clear(); Sh.Run("sc", "delete", "LanFixer");
        try { Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Run", true)?.DeleteValue("LanFixerTray", false); } catch { }
        if (purge) try { Directory.Delete(P.Dir, true); } catch { }
        var dir = Path.GetDirectoryName(P.Exe)!;
        Sh.Run("cmd", "/c", $"start \"\" /b cmd /c \"ping -n 3 127.0.0.1 >nul & rmdir /s /q \"{dir}\"\"");
        Console.WriteLine("Uninstalled." + (purge ? "" : $" Backups kept in {P.Dir} (use --purge to delete).")); return 0;
    }
}
