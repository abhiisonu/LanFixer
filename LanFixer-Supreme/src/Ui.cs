using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace LanFixer;

#region Modern Terminal Theme & Aesthetics

public static class Theme
{
    public const string Reset = "\x1b[0m";
    public const string Bold = "\x1b[1m";
    public const string Dim = "\x1b[2m";

    // Palette: Cyberpunk Slate / High-Contrast Precision
    public const string Border = "\x1b[38;2;65;85;110m";       // Refined steel-blue border
    public const string Title = "\x1b[38;2;0;229;255m\x1b[1m";  // Neon Cyan bold
    public const string Text = "\x1b[38;2;225;235;245m";        // Crisp off-white
    public const string Muted = "\x1b[38;2;120;140;165m";       // Slate grey
    public const string Green = "\x1b[38;2;0;230;118m";         // Emerald green
    public const string Cyan = "\x1b[38;2;0;229;255m";          // Vibrant cyan
    public const string Yellow = "\x1b[38;2;255;214;0m";        // Amber gold
    public const string Red = "\x1b[38;2;255;82;82m";           // Crimson alert
    public const string Accent = "\x1b[38;2;130;80;255m";       // Deep violet

    // Keycap badge: dark navy background with bright cyan text
    public const string KeyBg = "\x1b[48;2;20;30;48m\x1b[38;2;0;229;255m\x1b[1m";
    public const string KeyReset = "\x1b[0m";

    public static int VisibleLen(string s) =>
        Regex.Replace(s, @"\x1b\[[0-9;]*[a-zA-Z]", "").Length;

    public static string Fit(string s, int width)
    {
        int vLen = VisibleLen(s);
        if (vLen > width)
        {
            // Truncate plain text part cleanly
            string plain = Regex.Replace(s, @"\x1b\[[0-9;]*[a-zA-Z]", "");
            return plain.Length > width ? plain.Substring(0, width - 1) + "…" : plain;
        }
        return s + new string(' ', width - vLen);
    }

    public static string Badge(string text, string color) =>
        $"{color}[ {Bold}{text}{Reset}{color} ]{Reset}";

    public static string Meter(int ms) => ms switch
    {
        < 0 => $"{Muted}[ ----- ]{Reset}",
        < 30 => $"{Green}[ {Bold}●●●●●{Reset}{Green} ]{Reset}",
        < 75 => $"{Cyan}[ {Bold}●●●●○{Reset}{Cyan} ]{Reset}",
        < 150 => $"{Yellow}[ {Bold}●●●○○{Reset}{Yellow} ]{Reset}",
        < 300 => $"{Yellow}[ {Bold}●●○○○{Reset}{Yellow} ]{Reset}",
        _ => $"{Red}[ {Bold}●○○○○{Reset}{Red} ]{Reset}"
    };
}

#endregion

#region Telemetry & Formatting

public static class Fmt
{
    public static Status? Parse(string? j)
    {
        try { return j != null && j.StartsWith("{") ? JsonSerializer.Deserialize(j, J.Default.Status) : null; }
        catch { return null; }
    }

    public static string Spark(IEnumerable<int> h)
    {
        var l = h.ToList();
        if (l.Count == 0) return $"{Theme.Muted}No history{Theme.Reset}";
        int mx = Math.Max(1, l.Max());
        const string Glyphs = " ▂▃▄▅▆▇█";

        var sb = new StringBuilder();
        foreach (var v in l)
        {
            if (v < 0)
            {
                sb.Append($"{Theme.Red}×{Theme.Reset}");
                continue;
            }
            int idx = Math.Clamp(v * 7 / mx, 0, 7);
            string col = v switch
            {
                < 40 => Theme.Green,
                < 85 => Theme.Cyan,
                < 180 => Theme.Yellow,
                _ => Theme.Red
            };
            sb.Append($"{col}{Glyphs[idx]}{Theme.Reset}");
        }
        return sb.ToString();
    }

    public static string Dur(string iso) =>
        DateTime.TryParse(iso, out var d) ? (DateTime.Now - d).ToString(@"d\.hh\:mm\:ss").TrimStart('0', '.') : "0s";

    public static string Ms(int v) => v < 0 ? "--" : v + "ms";
}

#endregion

#region Interactive Live Dashboard

public static class Dash
{
    private const string Spinner = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏";
    private static int _spinIdx;

    public static int Run()
    {
        N.EnableVt();
        Console.OutputEncoding = Encoding.UTF8;
        Console.CursorVisible = false;
        Console.Title = "LanFixer Supreme v8.5 - Dual-Core Autonomous Network Guardian";

        string msg = "";
        Task<string>? job = null;
        var last = DateTime.MinValue;
        Status? s = null;

        try
        {
            Console.Write("\x1b[2J");
            while (true)
            {
                _spinIdx = (_spinIdx + 1) % Spinner.Length;

                if (job is { IsCompleted: true })
                {
                    msg = job.Result;
                    job = null;
                    last = DateTime.MinValue;
                }

                if ((DateTime.Now - last).TotalMilliseconds > 1000 && job == null)
                {
                    s = Fmt.Parse(Ipc.AskSync("status", 4000)) ?? Local();
                    last = DateTime.Now;
                    Draw(s, msg, false);
                }
                else if (job != null)
                {
                    Draw(s, msg, true);
                }

                if (!Console.KeyAvailable)
                {
                    Thread.Sleep(100);
                    continue;
                }

                var k = char.ToUpperInvariant(Console.ReadKey(true).KeyChar);
                if (k == 'Q') return 0;
                if (job != null) continue;

                if (k == 'D')
                {
                    Console.Clear();
                    Console.CursorVisible = true;
                    var rep = Doctor.Run();
                    Doctor.PrintConsole(rep);
                    Console.WriteLine("\n  Press any key to return to dashboard...");
                    Console.ReadKey(true);
                    Console.CursorVisible = false;
                    Console.Write("\x1b[2J");
                    last = DateTime.MinValue;
                    continue;
                }

                if (k == 'W')
                {
                    WebServer.Start(49888, openBrowser: true);
                    msg = "Web GUI opened at http://127.0.0.1:" + WebServer.Port + "/";
                    continue;
                }

                if (k == 'S')
                {
                    Console.Clear();
                    Console.CursorVisible = true;
                    Console.WriteLine("\n  Running multi-target Anycast & DNS benchmark...\n");
                    var benchOut = Ipc.AskSync("bench") ?? (P.Admin() ? Engine.BenchmarkAsync().GetAwaiter().GetResult() : "Service not running.");
                    Console.WriteLine(benchOut);
                    Console.WriteLine("\n  Press any key to return to dashboard...");
                    Console.ReadKey(true);
                    Console.CursorVisible = false;
                    Console.Write("\x1b[2J");
                    last = DateTime.MinValue;
                    continue;
                }

                string? cmd = k switch
                {
                    'R' => "repair",
                    'B' => "rollback",
                    'O' => "restore",
                    'L' => "login",
                    'T' => "tune1",
                    'M' => "mtu",
                    'P' => "pnp",
                    'K' => "keepalive",
                    'E' => "bundle",
                    'X' => "reset",
                    _ => null
                };

                if (cmd == null) continue;

                if (cmd == "reset" && (N.Remote() || !Confirm("Rebuild Winsock/TCP-IP stack? Safety backup + restore point are made first; reboot is required. (Y/N)")))
                    continue;
                if (cmd == "restore" && !Confirm("Restore ALL changed settings back to original Windows defaults? (Y/N)"))
                    continue;

                var c = cmd;
                msg = c switch
                {
                    "repair" => "Executing 3-tier repair and asserting Route Shield...",
                    "login" => "Sending credentials to captive portal...",
                    "mtu" => "Running Path MTU sweep and optimal clamping...",
                    "pnp" => "Locking NDIS power management (disabling device sleep)...",
                    "bundle" => "Collecting system forensics and writing diagnostics bundle...",
                    "keepalive" => "Pulsing captive session keep-alive...",
                    _ => $"Executing {c}..."
                };

                job = Task.Run(async () => await Ipc.Ask(c) ?? (P.Admin() ? RunLocal(c) : "Service not running and not elevated. Run 'LanFixer install' or use Admin prompt."));
            }
        }
        finally
        {
            Console.CursorVisible = true;
            Console.Write("\x1b[0m\n");
        }
    }

    private static string RunLocal(string c)
    {
        Engine.Init();
        return Engine.Do(c).GetAwaiter().GetResult();
    }

    private static Status Local()
    {
        var l = Net.Primary();
        var (st, _, ms) = Net.Probe(l?.Ip, default).GetAwaiter().GetResult();
        return new Status
        {
            State = st.ToString(),
            Ms = ms,
            Adapter = l?.Name ?? "None",
            Ip = l?.Ip ?? "",
            Gw = l?.Gw ?? "",
            Last = "Standalone mode (service inactive)"
        };
    }

    private static bool Confirm(string q)
    {
        Console.Write($"\x1b[2J\x1b[H\x1b[33m{q}\x1b[0m ");
        return char.ToUpperInvariant(Console.ReadKey(true).KeyChar) == 'Y';
    }

    private static void Draw(Status? s, string msg, bool busy)
    {
        if (s == null) return;
        var b = Theme.Border;
        var t = Theme.Text;
        var m = Theme.Muted;
        var r = Theme.Reset;

        string badge = s.State switch
        {
            "Online" => Theme.Badge("🟢 ONLINE", Theme.Green),
            "Captive" => Theme.Badge("🟡 CAPTIVE PORTAL", Theme.Yellow),
            "NoDns" => Theme.Badge("🟠 DNS FAILURE", Theme.Yellow),
            "NoLink" => Theme.Badge("⚪ NO LINK", Theme.Muted),
            _ => Theme.Badge("🔴 OFFLINE", Theme.Red)
        };

        var sb = new StringBuilder("\x1b[H");

        // Helper to output an 88-char padded box line
        void Box(string content)
        {
            sb.Append($"{b}│{r} ").Append(Theme.Fit(content, 84)).Append($" {b}│{r}\r\n");
        }

        // --- 1. HEADER CARD ---
        sb.Append($"{b}╭── {Theme.Title}⚡ LANFIXER SUPREME v8.5{r} {b}").Append(new string('─', 58)).Append($"╮{r}\r\n");
        Box($"State   : {badge}    {m}Uptime:{r} {Fmt.Dur(s.Since)}    {m}Uplink:{r} {s.Adapter}");
        sb.Append($"{b}╰").Append(new string('─', 86)).Append($"╯{r}\r\n");

        // --- 2. DUAL TELEMETRY GRID (Two Side-by-Side Cards, width 42 each) ---
        // Top border
        sb.Append($"{b}╭─ 📡 NETWORK INTERFACE & ROUTING ─────────╮ ╭─ 🌐 REAL-TIME LATENCY & EGRESS ──────────╮{r}\r\n");

        // Row 1
        string l1 = $"{m}Link    :{r} {t}{Theme.Fit(s.Adapter, 28)}{r}";
        string r1 = $"{m}Web RTT :{r} {t}{Fmt.Ms(s.Ms),-6}{r} {Theme.Meter(s.Ms)}";
        sb.Append($"{b}│{r} {Theme.Fit(l1, 39)} {b}│ │{r} {Theme.Fit(r1, 40)} {b}│{r}\r\n");

        // Row 2
        string l2 = $"{m}IPv4    :{r} {t}{Theme.Fit(s.Ip, 28)}{r}";
        string r2 = $"{m}Gateway :{r} {t}{Fmt.Ms(s.GwMs),-6}{r} {Theme.Meter(s.GwMs)}";
        sb.Append($"{b}│{r} {Theme.Fit(l2, 39)} {b}│ │{r} {Theme.Fit(r2, 40)} {b}│{r}\r\n");

        // Row 3
        string l3 = $"{m}Gateway :{r} {t}{Theme.Fit(s.Gw != "" ? s.Gw : "None", 28)}{r}";
        string r3 = $"{m}Net DNS :{r} {t}{Fmt.Ms(s.NetMs),-6}{r} {Theme.Meter(s.NetMs)}";
        sb.Append($"{b}│{r} {Theme.Fit(l3, 39)} {b}│ │{r} {Theme.Fit(r3, 40)} {b}│{r}\r\n");

        // Row 4
        string l4 = $"{m}Shield  :{r} {Theme.Green}Wired Metric 10 Active{r}";
        string lossCol = s.Loss == 0 ? Theme.Green : Theme.Red;
        string r4 = $"{m}Loss    :{r} {lossCol}{s.Loss}%{r}  {m}Heals:{r} {t}{s.Heals}{r}";
        sb.Append($"{b}│{r} {Theme.Fit(l4, 39)} {b}│ │{r} {Theme.Fit(r4, 40)} {b}│{r}\r\n");

        // Bottom border of grid
        sb.Append($"{b}╰──────────────────────────────────────────╯ ╰──────────────────────────────────────────╯{r}\r\n");

        // --- 3. LATENCY TELEMETRY & SPARKLINE CARD ---
        sb.Append($"{b}╭─ 📈 REAL-TIME LATENCY TREND (LAST 40 PROBES) ────────────────────────────────────────╮{r}\r\n");
        var valids = s.Hist.Where(v => v >= 0).ToList();
        int min = valids.Count > 0 ? valids.Min() : -1;
        int max = valids.Count > 0 ? valids.Max() : -1;
        int avg = valids.Count > 0 ? (int)valids.Average() : -1;
        double jit = 0;
        if (valids.Count > 1)
        {
            double mean = avg;
            jit = Math.Sqrt(valids.Sum(v => Math.Pow(v - mean, 2)) / valids.Count);
        }

        string stats = $"{m}Min:{r} {Theme.Green}{Fmt.Ms(min)}{r}  {m}Avg:{r} {Theme.Cyan}{Fmt.Ms(avg)}{r}  {m}Max:{r} {Theme.Yellow}{Fmt.Ms(max)}{r}  {m}Jitter:{r} {Theme.Cyan}{jit:F1}ms{r}";
        Box($"RTT {Fmt.Spark(s.Hist)}  │  {stats}");
        sb.Append($"{b}╰").Append(new string('─', 86)).Append($"╯{r}\r\n");

        // --- 4. SECURITY & EVENTS DUAL GRID ---
        sb.Append($"{b}╭─ 🛡️ SECURITY & AUTONOMOUS ENGINE ─────────╮ ╭─ 📋 RECENT SYSTEM EVENTS ────────────────╮{r}\r\n");

        // Security Row 1
        string sec1 = $"{m}DPAPI Vault :{r} {(s.Vault ? Theme.Badge("✔ ARMED", Theme.Green) : Theme.Badge("✖ EMPTY", Theme.Muted))}";
        string ev1 = s.Events.Count > 0 ? s.Events[0] : "System initialized";
        sb.Append($"{b}│{r} {Theme.Fit(sec1, 39)} {b}│ │{r} {Theme.Fit(m + ev1 + r, 40)} {b}│{r}\r\n");

        // Security Row 2
        string authBadge = s.Susp
            ? Theme.Badge("⚠ PAUSED", Theme.Red)
            : Theme.Badge("✔ ACTIVE", Theme.Green);
        string sec2 = $"{m}Captive Auth:{r} {authBadge} {m}(pfSense:8888){r}";
        string ev2 = s.Events.Count > 1 ? s.Events[1] : "";
        sb.Append($"{b}│{r} {Theme.Fit(sec2, 39)} {b}│ │{r} {Theme.Fit(m + ev2 + r, 40)} {b}│{r}\r\n");

        // Security Row 3
        string sec3 = $"{m}PnP Shield  :{r} {Theme.Badge("✔ SLEEP BLOCKED", Theme.Green)}";
        string ev3 = s.Events.Count > 2 ? s.Events[2] : "";
        sb.Append($"{b}│{r} {Theme.Fit(sec3, 39)} {b}│ │{r} {Theme.Fit(m + ev3 + r, 40)} {b}│{r}\r\n");

        // Security Row 4
        string undoBadge = s.Changes
            ? $"{Theme.Cyan}Yes (Undoable){r}"
            : $"{m}None (Clean){r}";
        string sec4 = $"{m}Undo Ledger :{r} {undoBadge}{(s.Reboot ? $" {Theme.Red}[REBOOT]{r}" : "")}";
        string ev4 = s.Events.Count > 3 ? s.Events[3] : "";
        sb.Append($"{b}│{r} {Theme.Fit(sec4, 39)} {b}│ │{r} {Theme.Fit(m + ev4 + r, 40)} {b}│{r}\r\n");

        sb.Append($"{b}╰──────────────────────────────────────────╯ ╰──────────────────────────────────────────╯{r}\r\n");

        // --- 5. KEYBOARD COMMAND NAVIGATION BAR ---
        sb.Append($"{b}╭─ ⌨️  COMMAND SHORTCUTS ───────────────────────────────────────────────────────────────╮{r}\r\n");
        string rowA = $"  {Theme.KeyBg} [R] {Theme.KeyReset} Repair    {Theme.KeyBg} [L] {Theme.KeyReset} Login      {Theme.KeyBg} [D] {Theme.KeyReset} Doctor      {Theme.KeyBg} [S] {Theme.KeyReset} Speed-Bench    {Theme.KeyBg} [M] {Theme.KeyReset} MTU-Sweep";
        string rowB = $"  {Theme.KeyBg} [W] {Theme.KeyReset} Web-GUI   {Theme.KeyBg} [P] {Theme.KeyReset} PnP-Fix    {Theme.KeyBg} [K] {Theme.KeyReset} KeepAlive   {Theme.KeyBg} [E] {Theme.KeyReset} Bundle         {Theme.KeyBg} [B] {Theme.KeyReset} Rollback   {Theme.KeyBg} [Q] {Theme.KeyReset} Quit";
        Box(rowA);
        Box(rowB);
        sb.Append($"{b}╰").Append(new string('─', 86)).Append($"╯{r}\r\n");

        // --- 6. TOAST / STATUS PROMPT ---
        if (busy)
        {
            char sp = Spinner[_spinIdx];
            sb.Append($"  {Theme.Cyan}{sp}{r} {Theme.Bold}{msg}{r}\x1b[K\r\n");
        }
        else
        {
            string toast = string.IsNullOrEmpty(msg)
                ? $"{Theme.Green}⚡ System Ready.{r} {m}Press any shortcut key to execute an action.{r}"
                : $"{Theme.Yellow}⚡ Notice:{r} {t}{msg}{r}";
            sb.Append($"  {toast}\x1b[K\r\n");
        }

        Console.Write(sb.ToString());
    }
}

#endregion

#region Zero-Resource System Tray Guard

/// <summary>
/// Lightweight System Tray Guard: pure Win32 P/Invoke with in-memory dynamic bitmap generation.
/// Zero Windows Forms overhead (~4 MB RAM footprint).
/// </summary>
public static unsafe class Tray
{
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    private struct NOTIFYICONDATAW
    {
        public int cbSize;
        public nint hWnd;
        public int uID;
        public int uFlags;
        public int uCallbackMessage;
        public nint hIcon;
        public fixed char szTip[128];
        public int dwState;
        public int dwStateMask;
        public fixed char szInfo[256];
        public int uVersion;
        public fixed char szInfoTitle[64];
        public int dwInfoFlags;
        public Guid guidItem;
        public nint hBalloonIcon;
    }

    [StructLayout(LayoutKind.Sequential)] private struct POINT { public int x, y; }
    [StructLayout(LayoutKind.Sequential)] private struct MSG { public nint hwnd; public uint message; public nint wParam, lParam; public uint time; public POINT pt; }
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    private struct WNDCLASSEXW { public int cbSize, style; public nint lpfnWndProc; public int cbClsExtra, cbWndExtra; public nint hInstance, hIcon, hCursor, hbrBackground, lpszMenuName, lpszClassName, hIconSm; }
    [StructLayout(LayoutKind.Sequential)] private struct ICONINFO { public int fIcon, xHotspot, yHotspot; public nint hbmMask, hbmColor; }

    [DllImport("shell32", CharSet = CharSet.Unicode)] private static extern bool Shell_NotifyIconW(int dwMessage, ref NOTIFYICONDATAW lpData);
    [DllImport("user32", CharSet = CharSet.Unicode)] private static extern ushort RegisterClassExW(ref WNDCLASSEXW lpwcx);
    [DllImport("user32", CharSet = CharSet.Unicode)] private static extern nint CreateWindowExW(int dwExStyle, string lpClassName, string lpWindowName, int dwStyle, int X, int Y, int nWidth, int nHeight, nint hWndParent, nint hMenu, nint hInstance, nint lpParam);
    [DllImport("user32")] private static extern nint DefWindowProcW(nint hWnd, uint Msg, nint wParam, nint lParam);
    [DllImport("user32")] private static extern int GetMessageW(out MSG lpMsg, nint hWnd, uint wMsgFilterMin, uint wMsgFilterMax);
    [DllImport("user32")] private static extern bool TranslateMessage(ref MSG lpMsg);
    [DllImport("user32")] private static extern nint DispatchMessageW(ref MSG lpMsg);
    [DllImport("user32")] private static extern void PostQuitMessage(int nExitCode);
    [DllImport("user32")] private static extern bool PostMessageW(nint hWnd, uint Msg, nint wParam, nint lParam);
    [DllImport("user32")] private static extern nint SetTimer(nint hWnd, nint nIDEvent, uint uElapse, nint lpTimerFunc);
    [DllImport("user32")] private static extern nint CreatePopupMenu();
    [DllImport("user32", CharSet = CharSet.Unicode)] private static extern bool AppendMenuW(nint hMenu, uint uFlags, nint uIDNewItem, string? lpNewItem);
    [DllImport("user32")] private static extern int TrackPopupMenu(nint hMenu, uint uFlags, int x, int y, int nReserved, nint hWnd, nint prcRect);
    [DllImport("user32")] private static extern bool DestroyMenu(nint hMenu);
    [DllImport("user32")] private static extern bool GetCursorPos(out POINT lpPoint);
    [DllImport("user32")] private static extern bool SetForegroundWindow(nint hWnd);
    [DllImport("user32")] private static extern nint CreateIconIndirect(ref ICONINFO piconinfo);
    [DllImport("gdi32")] private static extern nint CreateBitmap(int nWidth, int nHeight, uint cPlanes, uint cBitsPerPel, void* lpvBits);
    [DllImport("kernel32", CharSet = CharSet.Unicode)] private static extern nint CreateMutexW(nint lpMutexAttributes, bool bInitialOwner, string lpName);
    [DllImport("kernel32")] private static extern int GetLastError();

    private const uint WM_TRAY = 0x401;
    private const uint WM_DONE = 0x8001;
    private static nint _w;
    private static string _st = "";
    private static bool _busy;
    private static Status? _s;

    public static int Run()
    {
        var m = CreateMutexW(0, false, @"Local\LanFixerTrayGuard");
        if (m == 0 || GetLastError() == 183) return 0; // Already running

        var cls = "LanFixerTrayClass\0";
        fixed (char* pc = cls)
        {
            var wc = new WNDCLASSEXW
            {
                cbSize = sizeof(WNDCLASSEXW),
                lpfnWndProc = Marshal.GetFunctionPointerForDelegate<Func<nint, uint, nint, nint, nint>>(WndProc),
                lpszClassName = (nint)pc
            };
            RegisterClassExW(ref wc);
            _w = CreateWindowExW(0, cls, "", 0, 0, 0, 0, 0, 0, 0, 0, 0);
        }

        Update(init: true);
        SetTimer(_w, 1, 2000, 0);

        MSG msg;
        while (GetMessageW(out msg, 0, 0, 0) > 0)
        {
            TranslateMessage(ref msg);
            DispatchMessageW(ref msg);
        }

        var nid = new NOTIFYICONDATAW { cbSize = sizeof(NOTIFYICONDATAW), hWnd = _w, uID = 1 };
        Shell_NotifyIconW(2, ref nid); // NIM_DELETE
        return 0;
    }

    private static nint Icon(string st)
    {
        uint col = st switch
        {
            "Online" => 0x00E676,   // Emerald
            "Captive" => 0xFFD600,  // Amber
            "NoDns" => 0xFF9100,    // Orange
            "NoLink" => 0x78909C,   // Slate
            _ => 0xFF5252           // Crimson
        };

        var bits = new uint[16 * 16];
        for (int y = 0; y < 16; y++)
            for (int x = 0; x < 16; x++)
            {
                int dx = x - 8, dy = y - 8;
                bits[y * 16 + x] = dx * dx + dy * dy <= 36 ? col : 0;
            }

        var mask = new byte[16 * 16 / 8];
        fixed (uint* pb = bits)
        fixed (byte* pm = mask)
        {
            var cb = CreateBitmap(16, 16, 1, 32, pb);
            var cm = CreateBitmap(16, 16, 1, 1, pm);
            var ii = new ICONINFO { fIcon = 1, hbmColor = cb, hbmMask = cm };
            return CreateIconIndirect(ref ii);
        }
    }

    private static void Update(bool init = false)
    {
        _s = Fmt.Parse(Ipc.AskSync("status", 1000));
        var st = _s?.State ?? "Offline";
        var tip = $"LanFixer Supreme: {st} (Web: {Fmt.Ms(_s?.Ms ?? -1)}, Loss: {_s?.Loss ?? 0}%)";

        var nid = new NOTIFYICONDATAW
        {
            cbSize = sizeof(NOTIFYICONDATAW),
            hWnd = _w,
            uID = 1,
            uFlags = 7, // NIF_MESSAGE | NIF_ICON | NIF_TIP
            uCallbackMessage = (int)WM_TRAY,
            hIcon = Icon(st)
        };

        for (int i = 0; i < tip.Length && i < 127; i++) nid.szTip[i] = tip[i];

        if (init)
        {
            Shell_NotifyIconW(0, ref nid); // NIM_ADD
        }
        else if (st != _st)
        {
            nid.uFlags |= 0x10; // NIF_INFO (Balloon tip)
            nid.dwInfoFlags = st == "Online" ? 1 : (st == "Captive" ? 2 : 3);
            var title = "LanFixer: " + st;
            var text = _s?.Last ?? st;
            for (int i = 0; i < title.Length && i < 63; i++) nid.szInfoTitle[i] = title[i];
            for (int i = 0; i < text.Length && i < 255; i++) nid.szInfo[i] = text[i];
            Shell_NotifyIconW(1, ref nid); // NIM_MODIFY
        }
        else
        {
            Shell_NotifyIconW(1, ref nid); // NIM_MODIFY
        }
        _st = st;
    }

    private static nint WndProc(nint h, uint m, nint w, nint l)
    {
        if (m == WM_TRAY && (int)l == 0x205) // WM_RBUTTONUP
        {
            GetCursorPos(out var p);
            var menu = CreatePopupMenu();
            string statusIcon = _st == "Online" ? "🟢" : (_st == "Captive" ? "🟡" : "🔴");
            AppendMenuW(menu, 0, 1, $"{statusIcon} LanFixer Supreme ({_st})");
            AppendMenuW(menu, 0x800, 0, null); // Separator
            AppendMenuW(menu, _busy ? 1u : 0u, 2, "⚡ Quick Heal & Repair");
            AppendMenuW(menu, _busy ? 1u : 0u, 3, "🔑 Sign In to Portal");
            AppendMenuW(menu, _busy ? 1u : 0u, 4, "🩺 7-Layer Health Doctor");
            AppendMenuW(menu, _busy ? 1u : 0u, 5, "📊 Anycast & DNS Benchmark");
            AppendMenuW(menu, _busy ? 1u : 0u, 6, "🛡️ Enforce PnP Hardware Shield");
            AppendMenuW(menu, 0x800, 0, null); // Separator
            AppendMenuW(menu, _busy ? 1u : 0u, 7, "🔄 Rollback Last Change");
            AppendMenuW(menu, _busy ? 1u : 0u, 8, "⏮️ Restore Original Baseline");
            AppendMenuW(menu, 0x800, 0, null); // Separator
            AppendMenuW(menu, 0, 9, "🌐 Open Modern Web Dashboard");
            AppendMenuW(menu, 0, 10, "🖥️ Open Console TUI Dashboard");
            AppendMenuW(menu, 0, 11, "❌ Exit Tray");

            SetForegroundWindow(h);
            int cmd = TrackPopupMenu(menu, 0x100, p.x, p.y, 0, h, 0); // TPM_RETURNCMD
            DestroyMenu(menu);

            var targetExe = File.Exists(P.Exe) ? P.Exe : Environment.ProcessPath ?? P.Exe;
            if (cmd == 11) { PostQuitMessage(0); return 0; }
            if (cmd == 10) { Process.Start(new ProcessStartInfo(targetExe, "dash") { UseShellExecute = true }); return 0; }
            if (cmd == 9) { Process.Start(new ProcessStartInfo(targetExe, "gui") { UseShellExecute = true }); return 0; }
            if (cmd == 4) { Process.Start(new ProcessStartInfo(targetExe, "doctor") { UseShellExecute = true }); return 0; }
            if (cmd == 5) { Process.Start(new ProcessStartInfo(targetExe, "bench") { UseShellExecute = true }); return 0; }

            string? op = cmd switch
            {
                2 => "repair",
                3 => "login",
                6 => "pnp",
                7 => "rollback",
                8 => "restore",
                _ => null
            };

            if (op != null && !_busy)
            {
                _busy = true;
                Task.Run(() =>
                {
                    Ipc.AskSync(op);
                    PostMessageW(_w, WM_DONE, 0, 0);
                });
            }
            return 0;
        }

        if (m == WM_DONE)
        {
            _busy = false;
            Update();
            return 0;
        }

        if (m == 0x0113) // WM_TIMER
        {
            Update();
            return 0;
        }

        return DefWindowProcW(h, m, w, l);
    }
}

#endregion
