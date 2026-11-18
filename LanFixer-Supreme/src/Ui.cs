using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.Json;

namespace LanFixer;

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
        if (l.Count == 0) return "";
        int mx = Math.Max(1, l.Max());
        return string.Concat(l.Select(v => v < 0 ? '×' : "▁▂▃▄▅▆▇█"[Math.Min(7, v * 7 / mx)]));
    }

    public static string Dur(string iso) =>
        DateTime.TryParse(iso, out var d) ? (DateTime.Now - d).ToString(@"d\.hh\:mm\:ss").TrimStart('0', '.') : "";

    public static string Ms(int v) => v < 0 ? "--" : v + "ms";
}

public static class Dash
{
    public static int Run()
    {
        N.EnableVt();
        Console.OutputEncoding = Encoding.UTF8;
        Console.CursorVisible = false;
        string msg = "";
        Task<string>? job = null;
        var last = DateTime.MinValue;
        Status? s = null;

        try
        {
            Console.Write("\x1b[2J");
            while (true)
            {
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
                    Draw(s, msg + " (working...)", true);
                }

                if (!Console.KeyAvailable)
                {
                    Thread.Sleep(120);
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

                string? cmd = k switch
                {
                    'R' => "repair",
                    'B' => "rollback",
                    'O' => "restore",
                    'L' => "login",
                    'T' => "tune1",
                    'X' => "reset",
                    _ => null
                };

                if (cmd == null) continue;

                if (cmd == "reset" && (N.Remote() || !Confirm("Rebuild Winsock/TCP-IP stack? Safety backup + restore point are made first; reboot is required. (Y/N)")))
                    continue;
                if (cmd == "restore" && !Confirm("Restore ALL changed settings back to original Windows defaults? (Y/N)"))
                    continue;

                var c = cmd;
                msg = "";
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
            Last = "Standalone mode (service not active)"
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
        var c = s.State switch { "Online" => "32", "Captive" => "33", "NoLink" => "90", _ => "31" };
        var sb = new StringBuilder("\x1b[H");
        void L(string t = "") => sb.Append(t).Append("\x1b[K\r\n");

        L($" \x1b[1mLanFixer Supreme v8.5\x1b[0m  \x1b[{c}m● {s.State.ToUpper()}\x1b[0m   {Fmt.Dur(s.Since)}");
        L($" Link     {s.Adapter,-24} {s.Ip,-15} gw {s.Gw}");
        L($" Latency  web {Fmt.Ms(s.Ms),-7} gateway {Fmt.Ms(s.GwMs),-7} internet {Fmt.Ms(s.NetMs),-7} loss {s.Loss}%");
        L($" Trend    {Fmt.Spark(s.Hist)}");
        L($" Guard    auto-repairs {s.Heals}   vault {(s.Vault ? "saved" : "empty")}{(s.Susp ? "  \x1b[31mauto-login PAUSED\x1b[0m" : "")}{(s.Reboot ? "  \x1b[33mREBOOT PENDING\x1b[0m" : "")}   undoable changes: {(s.Changes ? "yes" : "none")}");
        L();
        L(" Events");
        for (int i = 0; i < 8; i++)
            L("  " + (i < s.Events.Count ? s.Events[i] : ""));
        L();
        L(" \x1b[1m[R]\x1b[0mepair  \x1b[1m[B]\x1b[0mrollback  \x1b[1m[O]\x1b[0mriginal-restore  \x1b[1m[L]\x1b[0mogin  \x1b[1m[D]\x1b[0moctor  \x1b[1m[T]\x1b[0mune  \x1b[1m[X]\x1b[0m stack-reset  \x1b[1m[Q]\x1b[0muit");
        L(" " + (busy ? "\x1b[36m" : "") + msg + "\x1b[0m");
        Console.Write(sb.ToString());
    }
}

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
    private static readonly Dictionary<string, nint> Ic = new();
    private static string _st = "";
    private static Status? _s;
    private static volatile bool _busy;

    private static nint Icon(string state)
    {
        if (Ic.TryGetValue(state, out var h)) return h;
        uint rgb = state switch { "Online" => 0x2ECC40, "Captive" => 0xFFB000, "NoLink" => 0x808080, _ => 0xE03030 };
        var px = new uint[256];
        var mask = new byte[32];
        for (int y = 0; y < 16; y++)
        {
            for (int x = 0; x < 16; x++)
            {
                int dx = x - 7, dy = y - 7;
                if (dx * dx + dy * dy <= 36)
                {
                    px[y * 16 + x] = rgb;
                }
                else
                {
                    mask[y * 2 + (x >> 3)] |= (byte)(0x80 >> (x & 7));
                }
            }
        }
        fixed (uint* pp = px)
        fixed (byte* pm = mask)
        {
            var c = CreateBitmap(16, 16, 1, 32, pp);
            var m = CreateBitmap(16, 16, 1, 1, pm);
            var ii = new ICONINFO { fIcon = 1, hbmColor = c, hbmMask = m };
            var ic = CreateIconIndirect(ref ii);
            return Ic[state] = ic;
        }
    }

    public static int Run()
    {
        N.FreeConsole();
        var mx = CreateMutexW(0, true, "LanFixer_TrayMutex");
        if (GetLastError() == 183) return 0; // Already running

        var wndProc = Marshal.GetFunctionPointerForDelegate<Func<nint, uint, nint, nint, nint>>(WndProc);
        var cls = "LanFixer_TrayClass\0";
        var wc = new WNDCLASSEXW { cbSize = sizeof(WNDCLASSEXW), lpfnWndProc = wndProc, lpszClassName = (nint)Marshal.StringToHGlobalUni(cls) };
        RegisterClassExW(ref wc);
        _w = CreateWindowExW(0, cls, "LanFixerTray", 0, 0, 0, 0, 0, 0, 0, 0, 0);

        SetTimer(_w, 1, 2000, 0);
        Update(init: true);

        while (GetMessageW(out var m, 0, 0, 0) > 0)
        {
            TranslateMessage(ref m);
            DispatchMessageW(ref m);
        }

        var nid = new NOTIFYICONDATAW { cbSize = sizeof(NOTIFYICONDATAW), hWnd = _w, uID = 1 };
        Shell_NotifyIconW(2, ref nid); // NIM_DELETE
        return 0;
    }

    private static void Update(bool init = false)
    {
        _s = Fmt.Parse(Ipc.AskSync("status", 2500));
        var st = _s?.State ?? "NoLink";
        var tip = $"LanFixer: {st}  {_s?.Adapter}  {Fmt.Ms(_s?.Ms ?? -1)}";

        var nid = new NOTIFYICONDATAW
        {
            cbSize = sizeof(NOTIFYICONDATAW),
            hWnd = _w,
            uID = 1,
            uFlags = 1 | 2 | 4, // NIF_MESSAGE | NIF_ICON | NIF_TIP
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
            AppendMenuW(menu, 0, 1, $"LanFixer ({_st})");
            AppendMenuW(menu, 0x800, 0, null); // Separator
            AppendMenuW(menu, _busy ? 1u : 0u, 2, "Quick Heal & Repair");
            AppendMenuW(menu, _busy ? 1u : 0u, 3, "Sign In to Portal");
            AppendMenuW(menu, _busy ? 1u : 0u, 4, "7-Layer Health Doctor");
            AppendMenuW(menu, _busy ? 1u : 0u, 5, "Rollback Last Change");
            AppendMenuW(menu, _busy ? 1u : 0u, 6, "Restore Original Baseline");
            AppendMenuW(menu, 0x800, 0, null); // Separator
            AppendMenuW(menu, 0, 7, "Open Interactive Dashboard");
            AppendMenuW(menu, 0, 8, "Exit Tray");

            SetForegroundWindow(h);
            int cmd = TrackPopupMenu(menu, 0x100, p.x, p.y, 0, h, 0); // TPM_RETURNCMD
            DestroyMenu(menu);

            if (cmd == 8) { PostQuitMessage(0); return 0; }
            if (cmd == 7) { Process.Start(new ProcessStartInfo(P.Exe) { UseShellExecute = true }); return 0; }
            if (cmd == 4) { Process.Start(new ProcessStartInfo(P.Exe, "doctor") { UseShellExecute = true }); return 0; }

            string? op = cmd switch { 2 => "repair", 3 => "login", 5 => "rollback", 6 => "restore", _ => null };
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
