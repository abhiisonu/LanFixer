using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.Json;
namespace LanFixer;

static class Fmt
{
    public static Status? Parse(string? j) { try { return j != null && j.StartsWith("{") ? JsonSerializer.Deserialize(j, J.Default.Status) : null; } catch { return null; } }
    public static string Spark(IEnumerable<int> h) { var l = h.ToList(); if (l.Count == 0) return ""; int mx = Math.Max(1, l.Max()); return string.Concat(l.Select(v => v < 0 ? '×' : "▁▂▃▄▅▆▇█"[Math.Min(7, v * 7 / mx)])); }
    public static string Dur(string iso) => DateTime.TryParse(iso, out var d) ? (DateTime.Now - d).ToString(@"d\.hh\:mm\:ss").TrimStart('0', '.') : "";
    public static string Ms(int v) => v < 0 ? "--" : v + "ms";
}

/// <summary>Console dashboard: live status, latency, one-key repair / reset / rollback / restore.</summary>
static class Dash
{
    public static int Run()
    {
        N.EnableVt(); Console.OutputEncoding = Encoding.UTF8; Console.CursorVisible = false; string msg = ""; Task<string>? job = null; var last = DateTime.MinValue; Status? s = null;
        try
        {
            Console.Write("\x1b[2J");
            while (true)
            {
                if (job is { IsCompleted: true }) { msg = job.Result; job = null; last = DateTime.MinValue; }
                if ((DateTime.Now - last).TotalMilliseconds > 1000 && job == null) { s = Fmt.Parse(Ipc.AskSync("status", 4000)) ?? Local(); last = DateTime.Now; Draw(s, msg, false); }
                else if (job != null) Draw(s, msg + " (working...)", true);
                if (!Console.KeyAvailable) { Thread.Sleep(120); continue; }
                var k = char.ToUpperInvariant(Console.ReadKey(true).KeyChar);
                if (k == 'Q') return 0;
                if (job != null) continue;
                string? cmd = k switch { 'R' => "repair", 'B' => "rollback", 'O' => "restore", 'L' => "login", 'T' => "tune1", 'X' => "reset", _ => null };
                if (cmd == null) continue;
                if (cmd == "reset" && (N.Remote() || !Confirm("Rebuild Winsock/TCP-IP stack? Backup + restore point are made first; a reboot is required. (Y/N)"))) continue;
                if (cmd == "restore" && !Confirm("Restore ALL changed settings to original Windows values? (Y/N)")) continue;
                var c = cmd; msg = "";
                job = Task.Run(async () => await Ipc.Ask(c) ?? (P.Admin() ? RunLocal(c) : "Service not running and not elevated. Run: LanFixer install"));
            }
        }
        finally { Console.CursorVisible = true; Console.Write("\x1b[0m\n"); }
    }
    static string RunLocal(string c) { Engine.Init(); return Engine.Do(c).GetAwaiter().GetResult(); }
    static Status Local() { var (st, _, ms) = Net.Probe(Net.Primary()?.Ip, default).GetAwaiter().GetResult(); var l = Net.Primary(); return new Status { State = st.ToString(), Ms = ms, Adapter = l?.Name ?? "", Ip = l?.Ip ?? "", Gw = l?.Gw ?? "", Last = "service not running (standalone mode)" }; }
    static bool Confirm(string q) { Console.Write($"\x1b[2J\x1b[H\x1b[33m{q}\x1b[0m "); return char.ToUpperInvariant(Console.ReadKey(true).KeyChar) == 'Y'; }
    static void Draw(Status? s, string msg, bool busy)
    {
        if (s == null) return; var c = s.State switch { "Online" => "32", "Captive" => "33", "NoLink" => "90", _ => "31" };
        var sb = new StringBuilder("\x1b[H");
        void L(string t = "") => sb.Append(t).Append("\x1b[K\n");
        L($" \x1b[1mLanFixer\x1b[0m  \x1b[{c}m● {s.State.ToUpper()}\x1b[0m   {Fmt.Dur(s.Since)}");
        L($" Link     {s.Adapter,-24} {s.Ip,-15} gw {s.Gw}");
        L($" Latency  web {Fmt.Ms(s.Ms),-7} gateway {Fmt.Ms(s.GwMs),-7} internet {Fmt.Ms(s.NetMs),-7} loss {s.Loss}%");
        L($" Trend    {Fmt.Spark(s.Hist)}");
        L($" Guard    auto-repairs {s.Heals}   vault {(s.Vault ? "saved" : "empty")}{(s.Susp ? "  \x1b[31mauto-login PAUSED\x1b[0m" : "")}{(s.Reboot ? "  \x1b[33mREBOOT PENDING\x1b[0m" : "")}   undoable changes: {(s.Changes ? "yes" : "none")}");
        L(); L(" Events"); for (int i = 0; i < 8; i++) L("  " + (i < s.Events.Count ? s.Events[i] : "")); L();
        L(" \x1b[1m[R]\x1b[0mepair  \x1b[1m[B]\x1b[0mrollback  \x1b[1m[O]\x1b[0mriginal-restore  \x1b[1m[L]\x1b[0mogin  \x1b[1m[T]\x1b[0mune  \x1b[1m[X]\x1b[0m stack-reset  \x1b[1m[Q]\x1b[0muit");
        L(" " + (busy ? "\x1b[36m" : "") + msg + "\x1b[0m"); Console.Write(sb.ToString());
    }
}

/// <summary>System-tray icon (pure Win32, no WinForms): colour = state, tooltip = latency, menu = controls, balloons on transitions.</summary>
static unsafe class Tray
{
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    struct NID { public int cb; public nint hwnd; public int id, flags, msg; public nint icon; public fixed char tip[128]; public int st, stm; public fixed char info[256]; public int ver; public fixed char title[64]; public int iflags; public Guid g; public nint bicon; }
    [StructLayout(LayoutKind.Sequential)] struct PT { public int x, y; }
    [StructLayout(LayoutKind.Sequential)] struct MSG { public nint h; public uint m; public nint w, l; public uint t; public PT p; }
    [StructLayout(LayoutKind.Sequential)] struct WC { public int cb, style; public nint proc; public int e1, e2; public nint inst, icon, cur, bg, menu, cls, sm; }
    [StructLayout(LayoutKind.Sequential)] struct II { public int ic, x, y; public nint mask, color; }
    [DllImport("shell32", CharSet = CharSet.Unicode)] static extern bool Shell_NotifyIconW(int m, ref NID d);
    [DllImport("user32", CharSet = CharSet.Unicode)] static extern ushort RegisterClassExW(ref WC c);
    [DllImport("user32", CharSet = CharSet.Unicode)] static extern nint CreateWindowExW(int ex, string c, string n, int s, int x, int y, int w, int h, nint p, nint m, nint i, nint l);
    [DllImport("user32")] static extern nint DefWindowProcW(nint h, uint m, nint w, nint l);
    [DllImport("user32")] static extern int GetMessageW(out MSG m, nint h, uint a, uint b);
    [DllImport("user32")] static extern bool TranslateMessage(ref MSG m);
    [DllImport("user32")] static extern nint DispatchMessageW(ref MSG m);
    [DllImport("user32")] static extern void PostQuitMessage(int c);
    [DllImport("user32")] static extern bool PostMessageW(nint h, uint m, nint w, nint l);
    [DllImport("user32")] static extern nint SetTimer(nint h, nint id, uint ms, nint p);
    [DllImport("user32")] static extern nint CreatePopupMenu();
    [DllImport("user32", CharSet = CharSet.Unicode)] static extern bool AppendMenuW(nint m, uint f, nint id, string? t);
    [DllImport("user32")] static extern int TrackPopupMenu(nint m, uint f, int x, int y, int r, nint h, nint rc);
    [DllImport("user32")] static extern bool DestroyMenu(nint m);
    [DllImport("user32")] static extern bool GetCursorPos(out PT p);
    [DllImport("user32")] static extern bool SetForegroundWindow(nint h);
    [DllImport("user32")] static extern nint CreateIconIndirect(ref II i);
    [DllImport("user32")] static extern uint RegisterWindowMessageW(string s);
    [DllImport("user32", CharSet = CharSet.Unicode)] static extern int MessageBoxW(nint h, string t, string c, uint f);
    [DllImport("gdi32")] static extern nint CreateBitmap(int w, int h, uint p, uint b, void* d);
    [DllImport("kernel32", CharSet = CharSet.Unicode)] static extern nint CreateMutexW(nint a, bool o, string n);
    [DllImport("kernel32")] static extern int GetLastError();

    const uint UM = 0x401, DONE = 0x8001; static nint _w; static uint _tb; static readonly Dictionary<string, nint> Ic = new(); static string _st = "", _msg = "", _tip = ""; static Status? _s; static volatile bool _busy;

    static nint Icon(string state)
    {
        if (Ic.TryGetValue(state, out var h)) return h;
        uint rgb = state switch { "Online" => 0x2ECC40, "Captive" => 0xFFB000, "NoLink" => 0x808080, _ => 0xE03030 };
        var px = new uint[256]; var mask = new byte[32];
        for (int y = 0; y < 16; y++) for (int x = 0; x < 16; x++) { int dx = x * 2 - 15, dy = y * 2 - 15; if (dx * dx + dy * dy <= 196) px[y * 16 + x] = 0xFF000000 | rgb; }
        fixed (uint* p = px) fixed (byte* m = mask) { var ii = new II { ic = 1, mask = CreateBitmap(16, 16, 1, 1, m), color = CreateBitmap(16, 16, 1, 32, p) }; return Ic[state] = CreateIconIndirect(ref ii); }
    }
    static void Nid(int msg, string tip, string? balloon = null)
    {
        var d = new NID { cb = sizeof(NID), hwnd = _w, id = 1, flags = 0x7, msg = (int)UM, icon = Icon(_st == "" ? "NoLink" : _st) };
        for (int i = 0; i < tip.Length && i < 127; i++) d.tip[i] = tip[i];
        if (balloon != null) { d.flags |= 0x10; for (int i = 0; i < balloon.Length && i < 255; i++) d.info[i] = balloon[i]; var t = "LanFixer"; for (int i = 0; i < t.Length; i++) d.title[i] = t[i]; }
        Shell_NotifyIconW(msg, ref d);
    }

    static void Poll()
    {
        if (_busy) return; _busy = true;
        Task.Run(() => { var s = Fmt.Parse(Ipc.AskSync("status", 3000)); _s = s; PostMessageW(_w, DONE, 1, 0); });
    }
    static void Refresh()
    {
        _busy = false; var s = _s; string st = s?.State ?? "NoLink";
        var tip = s == null ? "LanFixer: service not running" : $"LanFixer: {s.State}  {Fmt.Ms(s.NetMs >= 0 ? s.NetMs : s.Ms)}" + (s.Susp ? " (auto-login paused)" : "");
        string? b = null;
        if (st != _st && _st != "") b = st switch { "Online" => "Back online.", "Captive" => "Login page detected" + (s!.Vault ? " - signing in..." : "."), "NoLink" => "Network cable/Wi-Fi disconnected.", _ => "Connection lost - auto-repair is running." };
        if (st != _st || tip != _tip) { _st = st; _tip = tip; Nid(1, tip, b); }
    }
    static void Act(string cmd)
    {
        if (cmd == "reset" && MessageBoxW(_w, "Rebuild the Winsock/TCP-IP stack?\n\nA backup and restore point are made first. A restart is required afterwards.", "LanFixer", 0x31) != 1) return;
        if (cmd == "restore" && MessageBoxW(_w, "Restore ALL settings LanFixer changed to their original Windows values?", "LanFixer", 0x21) != 1) return;
        Nid(1, "LanFixer: working...", "Working on: " + cmd);
        Task.Run(() => { _msg = Ipc.AskSync(cmd) ?? "Service not running. Install it with: LanFixer install"; PostMessageW(_w, DONE, 2, 0); });
    }

    [UnmanagedCallersOnly]
    static nint Proc(nint h, uint m, nint w, nint l) { try { return Proc2(h, m, w, l); } catch { return DefWindowProcW(h, m, w, l); } }
    static nint Proc2(nint h, uint m, nint w, nint l)
    {
        if (m == DONE) { if (w == 1) Refresh(); else { Nid(1, _tip, _msg); } return 0; }
        if (m == 0x113) { Poll(); return 0; }                                                           // WM_TIMER
        if (m == _tb && _tb != 0) { Ic.Clear(); _tip = ""; Poll(); return 0; }                          // explorer restarted
        if (m == UM && (l == 0x205 || l == 0x202))                                                      // right / left click
        {
            if (l == 0x202) { Process.Start(new ProcessStartInfo(Environment.ProcessPath!, "dash") { UseShellExecute = true }); return 0; }
            var mn = CreatePopupMenu(); AppendMenuW(mn, 0x3, 0, _tip); AppendMenuW(mn, 0x800, 0, null);
            string[] it = { "Repair now", "Sign in to portal", "Rollback last change", "Restore original settings", "Reset network stack...", "Open dashboard", "Exit" };
            for (int i = 0; i < it.Length; i++) { AppendMenuW(mn, 0, 10 + i, it[i]); if (i == 3) AppendMenuW(mn, 0x800, 0, null); }
            GetCursorPos(out var p); SetForegroundWindow(h); int r = TrackPopupMenu(mn, 0x100, p.x, p.y, 0, h, 0); DestroyMenu(mn);
            switch (r) { case 10: Act("repair"); break; case 11: Act("login"); break; case 12: Act("rollback"); break; case 13: Act("restore"); break; case 14: Act("reset"); break; case 15: Process.Start(new ProcessStartInfo(Environment.ProcessPath!, "dash") { UseShellExecute = true }); break; case 16: Nid(2, ""); PostQuitMessage(0); break; }
            return 0;
        }
        return DefWindowProcW(h, m, w, l);
    }

    public static int Run()
    {
        N.FreeConsole(); CreateMutexW(0, true, "Local\\LanFixerTray"); if (GetLastError() == 183) return 0;      // single instance
        _tb = RegisterWindowMessageW("TaskbarCreated");
        var wc = new WC { cb = sizeof(WC), proc = (nint)(delegate* unmanaged<nint, uint, nint, nint, nint>)&Proc, cls = Marshal.StringToHGlobalUni("LanFixerTray") }; RegisterClassExW(ref wc);
        _w = CreateWindowExW(0x80, "LanFixerTray", "LanFixer", 0, 0, 0, 0, 0, 0, 0, 0, 0);
        Nid(0, "LanFixer"); SetTimer(_w, 1, 2000, 0); Poll();
        while (GetMessageW(out var m, 0, 0, 0) > 0) { TranslateMessage(ref m); DispatchMessageW(ref m); }
        return 0;
    }
}
