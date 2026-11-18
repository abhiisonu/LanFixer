using System.Runtime.InteropServices;
namespace LanFixer;

/// <summary>All Win32 interop in one place (no NuGet packages, AOT-safe).</summary>
static unsafe class N
{
    // ---- DPAPI (machine scope + app entropy) ----
    struct BLOB { public int n; public byte* p; }
    [DllImport("crypt32", SetLastError = true)] static extern bool CryptProtectData(BLOB* i, nint d, BLOB* e, nint r, nint ps, int f, BLOB* o);
    [DllImport("crypt32", SetLastError = true)] static extern bool CryptUnprotectData(BLOB* i, nint d, BLOB* e, nint r, nint ps, int f, BLOB* o);
    [DllImport("kernel32")] static extern nint LocalFree(nint h);
    public static byte[]? Dpapi(byte[] data, byte[] ent, bool enc)
    {
        fixed (byte* pd = data, pe = ent)
        {
            BLOB i = new() { n = data.Length, p = pd }, e = new() { n = ent.Length, p = pe }, o = default;
            if (!(enc ? CryptProtectData(&i, 0, &e, 0, 0, 5, &o) : CryptUnprotectData(&i, 0, &e, 0, 0, 5, &o))) return null;
            var r = new Span<byte>(o.p, o.n).ToArray(); new Span<byte>(o.p, o.n).Clear(); LocalFree((nint)o.p); return r;
        }
    }

    // ---- Service control manager ----
    [StructLayout(LayoutKind.Sequential)] public struct SS { public uint type, state, accepted, win32, svc, check, wait; }
    [DllImport("advapi32", SetLastError = true)] public static extern bool StartServiceCtrlDispatcherW(nint table);
    [DllImport("advapi32", CharSet = CharSet.Unicode)] public static extern nint RegisterServiceCtrlHandlerExW(string n, nint h, nint c);
    [DllImport("advapi32")] public static extern bool SetServiceStatus(nint h, ref SS s);

    // ---- Console / session / power ----
    [DllImport("kernel32")] static extern nint GetStdHandle(int n);
    [DllImport("kernel32")] static extern bool GetConsoleMode(nint h, out uint m);
    [DllImport("kernel32")] static extern bool SetConsoleMode(nint h, uint m);
    [DllImport("kernel32")] public static extern bool FreeConsole();
    [DllImport("user32")] public static extern int GetSystemMetrics(int i);
    public static void EnableVt() { var h = GetStdHandle(-11); if (GetConsoleMode(h, out var m)) SetConsoleMode(h, m | 4); }
    public static bool Remote() => GetSystemMetrics(0x1000) != 0;
    [StructLayout(LayoutKind.Sequential)] struct PWR { public byte ac, flag, pct, sav; public int life, full; }
    [DllImport("kernel32")] static extern bool GetSystemPowerStatus(out PWR p);
    public static bool OnBattery() => GetSystemPowerStatus(out var p) && p.ac == 0;

    // ---- System Restore point ----
    [StructLayout(LayoutKind.Sequential, Pack = 1, CharSet = CharSet.Unicode)]
    struct RPI { public int ev, ty; public long seq; public fixed char d[256]; }
    [StructLayout(LayoutKind.Sequential, Pack = 1)] struct RPS { public int st; public long seq; }
    [DllImport("srclient")] static extern bool SRSetRestorePointW(ref RPI i, out RPS s);
    public static bool RestorePoint(string desc)
    {
        try
        {
            var i = new RPI { ev = 100, ty = 12 }; for (int k = 0; k < desc.Length && k < 255; k++) i.d[k] = desc[k];
            if (!SRSetRestorePointW(ref i, out var s) || s.st != 0) return false;
            i.ev = 101; i.seq = s.seq; SRSetRestorePointW(ref i, out _); return true;
        }
        catch { return false; }
    }
}
