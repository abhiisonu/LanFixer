using System.Runtime.InteropServices;

namespace LanFixer;

/// <summary>
/// Native Win32 interop primitives: DPAPI, Service Control Manager, Power status,
/// System Restore Point, Console VT100 control. Zero external dependencies.
/// </summary>
public static unsafe class N
{
    // ---- DPAPI (Machine scope + Application Entropy) ----
    [StructLayout(LayoutKind.Sequential)]
    private struct BLOB { public int n; public byte* p; }

    [DllImport("crypt32", SetLastError = true)]
    private static extern bool CryptProtectData(BLOB* i, nint d, BLOB* e, nint r, nint ps, int f, BLOB* o);

    [DllImport("crypt32", SetLastError = true)]
    private static extern bool CryptUnprotectData(BLOB* i, nint d, BLOB* e, nint r, nint ps, int f, BLOB* o);

    [DllImport("kernel32")]
    private static extern nint LocalFree(nint h);

    public static byte[]? Dpapi(byte[] data, byte[] ent, bool enc)
    {
        fixed (byte* pd = data, pe = ent)
        {
            BLOB i = new() { n = data.Length, p = pd };
            BLOB e = new() { n = ent.Length, p = pe };
            BLOB o = default;
            // flag 5 = CRYPTPROTECT_LOCAL_MACHINE (4) | CRYPTPROTECT_UI_FORBIDDEN (1)
            if (!(enc ? CryptProtectData(&i, 0, &e, 0, 0, 5, &o) : CryptUnprotectData(&i, 0, &e, 0, 0, 5, &o)))
                return null;
            var r = new Span<byte>(o.p, o.n).ToArray();
            new Span<byte>(o.p, o.n).Clear();
            LocalFree((nint)o.p);
            return r;
        }
    }

    // ---- Windows Service Control Manager (SCM) ----
    [StructLayout(LayoutKind.Sequential)]
    public struct SERVICE_STATUS
    {
        public uint dwServiceType;
        public uint dwCurrentState;
        public uint dwControlsAccepted;
        public uint dwWin32ExitCode;
        public uint dwServiceSpecificExitCode;
        public uint dwCheckPoint;
        public uint dwWaitHint;
    }

    [DllImport("advapi32", SetLastError = true)]
    public static extern bool StartServiceCtrlDispatcherW(nint lpServiceTable);

    [DllImport("advapi32", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern nint RegisterServiceCtrlHandlerExW(string lpServiceName, nint lpHandlerProc, nint lpContext);

    [DllImport("advapi32", SetLastError = true)]
    public static extern bool SetServiceStatus(nint hServiceStatus, ref SERVICE_STATUS lpServiceStatus);

    // ---- Console, Terminal & Session Metrics ----
    [DllImport("kernel32")]
    private static extern nint GetStdHandle(int nStdHandle);

    [DllImport("kernel32")]
    private static extern bool GetConsoleMode(nint hConsoleHandle, out uint lpMode);

    [DllImport("kernel32")]
    private static extern bool SetConsoleMode(nint hConsoleHandle, uint dwMode);

    [DllImport("kernel32")]
    public static extern bool FreeConsole();

    [DllImport("user32")]
    public static extern int GetSystemMetrics(int nIndex);

    public static void EnableVt()
    {
        var h = GetStdHandle(-11); // STD_OUTPUT_HANDLE
        if (GetConsoleMode(h, out var m))
            SetConsoleMode(h, m | 4); // ENABLE_VIRTUAL_TERMINAL_PROCESSING
    }

    public static bool Remote() => GetSystemMetrics(0x1000) != 0; // SM_REMOTESESSION

    [StructLayout(LayoutKind.Sequential)]
    private struct SYSTEM_POWER_STATUS
    {
        public byte ACLineStatus;
        public byte BatteryFlag;
        public byte BatteryLifePercent;
        public byte SystemStatusFlag;
        public int BatteryLifeTime;
        public int BatteryFullLifeTime;
    }

    [DllImport("kernel32")]
    private static extern bool GetSystemPowerStatus(out SYSTEM_POWER_STATUS lpSystemPowerStatus);

    public static bool OnBattery() => GetSystemPowerStatus(out var p) && p.ACLineStatus == 0;

    // ---- Native System Restore Point (srclient.dll) ----
    [StructLayout(LayoutKind.Sequential, Pack = 1, CharSet = CharSet.Unicode)]
    private struct RESTOREPOINTINFO
    {
        public int dwEventType;
        public int dwRestorePtType;
        public long llSequenceNumber;
        public fixed char szDescription[256];
    }

    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    private struct STATUSTYPE
    {
        public int nStatus;
        public long llSequenceNumber;
    }

    [DllImport("srclient", CharSet = CharSet.Unicode)]
    private static extern bool SRSetRestorePointW(ref RESTOREPOINTINFO pRestorePointInit, out STATUSTYPE pStatus);

    public static bool RestorePoint(string desc)
    {
        try
        {
            var i = new RESTOREPOINTINFO { dwEventType = 100, dwRestorePtType = 12 }; // BEGIN_SYSTEM_CHANGE, APPLICATION_INSTALL
            for (int k = 0; k < desc.Length && k < 255; k++) i.szDescription[k] = desc[k];
            if (!SRSetRestorePointW(ref i, out var s) || s.nStatus != 0) return false;
            i.dwEventType = 101; // END_SYSTEM_CHANGE
            i.llSequenceNumber = s.llSequenceNumber;
            SRSetRestorePointW(ref i, out _);
            return true;
        }
        catch { return false; }
    }
}
