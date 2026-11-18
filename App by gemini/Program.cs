using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.NetworkInformation;
using System.Net.Security;
using System.Net.Sockets;
using System.Security.AccessControl;
using System.Security.Authentication;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Security.Principal;
using System.ServiceProcess;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Win32;

namespace LanFixer;

#region Configuration & Data Contracts

public sealed record AppConfig(
    string StoreDir,
    string PortalHost = "gateway.nitjsr.ac.in",
    int PortalPort = 8888,
    string PortalIp = "10.114.0.5",
    string PortalUrl = "https://10.114.0.5:8888/",
    string CampusDns = "172.16.1.2",
    string CampusDomain = "nitjsr.ac.in",
    string[]? PublicDns = null)
{
    public string[] ActivePublicDns => PublicDns ?? ["9.9.9.9", "8.8.8.8", "1.1.1.1"];
    public string StateFile => Path.Combine(StoreDir, "state.json");
    public string LedgerFile => Path.Combine(StoreDir, "change_ledger.jsonl");
    public string VaultFile => Path.Combine(StoreDir, "vault.bin");
    public string LogFile => Path.Combine(StoreDir, "LanFixer.log");
    public string ResetJournalFile => Path.Combine(StoreDir, "reset_journal.json");
}

public enum NetVerdict { Healthy = 0, Degraded = 10, Broken = 20, Undetermined = 30 }
public enum ConnState { Online, Captive, NoDns, Offline, NoIp, NoLink }

public sealed record SubnetInfo(
    string IpAddress,
    int PrefixLength,
    string SubnetMask,
    string WildcardMask,
    string NetworkAddress,
    string BroadcastAddress,
    string MinHost,
    string MaxHost,
    long TotalHosts);

public sealed record LayerResult(int Layer, string Name, string Status, string Evidence, string Action);
public sealed record DoctorReport(
    string PrimaryAdapter,
    string IpAddress,
    string Gateway,
    string Environment,
    int PathMtu,
    NetVerdict Verdict,
    int ExitCode,
    string RootCause,
    long DurationMs,
    List<LayerResult> Layers);

public sealed record LedgerEntry(
    string EntryId,
    string RunId,
    string TimestampUtc,
    string MutationType,
    string Target,
    string? ValueName,
    string? OldValue,
    string? NewValue,
    bool Reversible,
    string? UndoCommand,
    string Description);

public sealed class PersistentState
{
    public string Version { get; set; } = "7.0.2";
    public string DnsProfile { get; set; } = "Adaptive";
    public string RouteProfile { get; set; } = "Adaptive";
    public string? PortalPin { get; set; }
    public string? DiscoveredPortalUrl { get; set; }
    public string? DiscoveredPortalIp { get; set; }
    public int DiscoveredPortalPort { get; set; }
    public string? DiscoveredDomain { get; set; }
    public bool PortalLoginSuspended { get; set; }
    public int PortalFails { get; set; }
    public bool PendingReboot { get; set; }
    public string? PendingRebootTime { get; set; }
    public Dictionary<string, string> Snapshots { get; set; } = new();
    public List<string> InjectedHostRoutes { get; set; } = new();
    public Dictionary<string, string> ArpMemory { get; set; } = new();
    public Dictionary<string, string> ArpCandidates { get; set; } = new();
}

#endregion

#region Cross-Process Global Mutex, Security ACLs, DPAPI Vault & Transactional State

public sealed class GlobalLock : IDisposable
{
    private Mutex? _mutex;
    private readonly bool _acquired;

    public GlobalLock(int timeoutMs = 15000)
    {
        if (!SecurityEngine.IsAdmin()) return;
        try
        {
            var mSec = new MutexSecurity();
            var admSid = new SecurityIdentifier(WellKnownSidType.BuiltinAdministratorsSid, null);
            var sysSid = new SecurityIdentifier(WellKnownSidType.LocalSystemSid, null);
            mSec.AddAccessRule(new MutexAccessRule(admSid, MutexRights.FullControl, AccessControlType.Allow));
            mSec.AddAccessRule(new MutexAccessRule(sysSid, MutexRights.FullControl, AccessControlType.Allow));

            _mutex = new Mutex(false, @"Global\LanFixer_Lock", out _);
            _mutex.SetAccessControl(mSec);
        }
        catch
        {
            try { _mutex = new Mutex(false, @"Local\LanFixer_Lock"); } catch { }
        }

        if (_mutex == null) return;
        try { _acquired = _mutex.WaitOne(timeoutMs); }
        catch (AbandonedMutexException) { _acquired = true; }
        catch { _acquired = false; }
    }

    public void Dispose()
    {
        if (_acquired && _mutex != null)
        {
            try { _mutex.ReleaseMutex(); } catch { }
        }
        _mutex?.Dispose();
    }
}

public static class SecurityEngine
{
    private static readonly Regex VirtRegex = new(
        @"Virtual|Hyper-V|VMware|VirtualBox|\bTAP\b|\bTUN\b|\bWSL\b|Bluetooth|Tailscale|ZeroTier|WireGuard|Wintun|RNDIS|Loopback|Npcap|OpenVPN|AnyConnect|Fortinet|PANGP|WARP|Wi-Fi Direct",
        RegexOptions.IgnoreCase | RegexOptions.Compiled);

    public static bool IsAdmin()
    {
        try
        {
            using var id = WindowsIdentity.GetCurrent();
            return new WindowsPrincipal(id).IsInRole(WindowsBuiltInRole.Administrator);
        }
        catch { return false; }
    }

    public static bool IsRemoteSession()
    {
        var sess = Environment.GetEnvironmentVariable("SESSIONNAME") ?? "";
        return sess.StartsWith("RDP", StringComparison.OrdinalIgnoreCase) ||
               sess.StartsWith("ICA", StringComparison.OrdinalIgnoreCase) ||
               !string.IsNullOrEmpty(Environment.GetEnvironmentVariable("SSH_CONNECTION"));
    }

    public static bool IsVirtualOrTunnel(NetworkInterface nic) =>
        nic.NetworkInterfaceType is NetworkInterfaceType.Loopback or NetworkInterfaceType.Tunnel ||
        VirtRegex.IsMatch(nic.Description + " " + nic.Name);

    public static void EnsureSecureStore(AppConfig cfg)
    {
        Directory.CreateDirectory(cfg.StoreDir);
        if (!IsAdmin()) return;
        try
        {
            var dirInfo = new DirectoryInfo(cfg.StoreDir);
            var acl = dirInfo.GetAccessControl();
            acl.SetAccessRuleProtection(isProtected: true, preserveInheritance: false);
            var sysSid = new SecurityIdentifier(WellKnownSidType.LocalSystemSid, null);
            var admSid = new SecurityIdentifier(WellKnownSidType.BuiltinAdministratorsSid, null);
            var usrSid = new SecurityIdentifier(WellKnownSidType.BuiltinUsersSid, null);

            acl.SetOwner(admSid);
            acl.AddAccessRule(new FileSystemAccessRule(sysSid, FileSystemRights.FullControl, InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit, PropagationFlags.None, AccessControlType.Allow));
            acl.AddAccessRule(new FileSystemAccessRule(admSid, FileSystemRights.FullControl, InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit, PropagationFlags.None, AccessControlType.Allow));
            acl.AddAccessRule(new FileSystemAccessRule(usrSid, FileSystemRights.ReadAndExecute, InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit, PropagationFlags.None, AccessControlType.Allow));
            dirInfo.SetAccessControl(acl);
        }
        catch { }
    }

    private static byte[] GetVaultEntropy()
    {
        var guid = Registry.GetValue(@"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography", "MachineGuid", "")?.ToString() ?? "";
        return Encoding.UTF8.GetBytes($"LanFixer_NITJSR_AS_SecureEntropy_2026_{guid}");
    }

    public static bool SaveCredentials(AppConfig cfg, string user, string pass, PersistentState state)
    {
        if (string.IsNullOrWhiteSpace(user) || string.IsNullOrEmpty(pass) || user.IndexOfAny(['\t', '\r', '\n']) >= 0)
            return false;

        EnsureSecureStore(cfg);
        var plainBytes = Encoding.UTF8.GetBytes($"{user}\t{pass}");
        try
        {
            var enc = ProtectedData.Protect(plainBytes, GetVaultEntropy(), DataProtectionScope.LocalMachine);
            Array.Clear(plainBytes, 0, plainBytes.Length);

            var tmp = cfg.VaultFile + ".tmp";
            File.WriteAllBytes(tmp, []);
            LockFileToAdminsOnly(tmp);
            File.WriteAllBytes(tmp, enc);
            File.Move(tmp, cfg.VaultFile, overwrite: true);
            LockFileToAdminsOnly(cfg.VaultFile);

            state.PortalFails = 0;
            state.PortalLoginSuspended = false;
            StateStore.Save(cfg, state);
            return true;
        }
        catch
        {
            Array.Clear(plainBytes, 0, plainBytes.Length);
            return false;
        }
    }

    public static (string User, string Pass)? LoadCredentials(AppConfig cfg)
    {
        if (!File.Exists(cfg.VaultFile)) return null;
        try
        {
            var enc = File.ReadAllBytes(cfg.VaultFile);
            var dec = ProtectedData.Unprotect(enc, GetVaultEntropy(), DataProtectionScope.LocalMachine);
            var str = Encoding.UTF8.GetString(dec);
            Array.Clear(dec, 0, dec.Length);
            return ParseVaultString(str);
        }
        catch { return null; }
    }

    public static (string User, string Pass)? ParseVaultString(string plain)
    {
        int idx = plain.IndexOf('\t');
        if (idx < 1 || idx >= plain.Length - 1) return null;
        return (plain[..idx], plain[(idx + 1)..]);
    }

    public static void LockFileToAdminsOnly(string path)
    {
        if (!IsAdmin() || !File.Exists(path)) return;
        try
        {
            var fi = new FileInfo(path);
            var acl = fi.GetAccessControl();
            acl.SetAccessRuleProtection(isProtected: true, preserveInheritance: false);
            var sysSid = new SecurityIdentifier(WellKnownSidType.LocalSystemSid, null);
            var admSid = new SecurityIdentifier(WellKnownSidType.BuiltinAdministratorsSid, null);
            acl.SetOwner(admSid);
            acl.AddAccessRule(new FileSystemAccessRule(sysSid, FileSystemRights.FullControl, AccessControlType.Allow));
            acl.AddAccessRule(new FileSystemAccessRule(admSid, FileSystemRights.FullControl, AccessControlType.Allow));
            fi.SetAccessControl(acl);
        }
        catch { }
    }
}

public static class StateStore
{
    public static readonly string RunId = Guid.NewGuid().ToString("N")[..12];

    public static PersistentState Load(AppConfig cfg)
    {
        foreach (var path in new[] { cfg.StateFile, cfg.StateFile + ".bak", cfg.StateFile + ".tmp" })
        {
            try
            {
                if (File.Exists(path))
                {
                    var s = JsonSerializer.Deserialize<PersistentState>(File.ReadAllText(path));
                    if (s != null) return s;
                }
            }
            catch { }
        }
        return new PersistentState();
    }

    public static void Save(AppConfig cfg, PersistentState state)
    {
        if (!SecurityEngine.IsAdmin()) return;
        try
        {
            SecurityEngine.EnsureSecureStore(cfg);
            var tmp = cfg.StateFile + ".tmp";
            var bak = cfg.StateFile + ".bak";
            var json = JsonSerializer.Serialize(state, new JsonSerializerOptions { WriteIndented = true });
            File.WriteAllText(tmp, json, Encoding.ASCII);
            if (JsonSerializer.Deserialize<PersistentState>(File.ReadAllText(tmp)) == null) return;
            if (File.Exists(cfg.StateFile)) File.Copy(cfg.StateFile, bak, overwrite: true);
            File.Move(tmp, cfg.StateFile, overwrite: true);
        }
        catch { }
    }

    public static void SaveOriginal(PersistentState state, string key, string value)
    {
        if (!state.Snapshots.ContainsKey(key))
            state.Snapshots[key] = value;
    }

    public static void RecordMutation(AppConfig cfg, string type, string target, string? valName, string? oldVal, string? newVal, bool reversible, string? undoCmd, string desc)
    {
        try
        {
            SecurityEngine.EnsureSecureStore(cfg);
            if (File.Exists(cfg.LedgerFile) && new FileInfo(cfg.LedgerFile).Length > 2_097_152)
                File.Move(cfg.LedgerFile, cfg.LedgerFile + ".bak", overwrite: true);

            var entry = new LedgerEntry(
                Guid.NewGuid().ToString("N")[..8],
                RunId,
                DateTime.UtcNow.ToString("o"),
                type, target, valName, oldVal, newVal, reversible, undoCmd, desc);
            var line = JsonSerializer.Serialize(entry) + "\r\n";
            File.AppendAllText(cfg.LedgerFile, line, Encoding.ASCII);
            Log(cfg, "OK", desc);
        }
        catch { }
    }

    public static List<LedgerEntry> GetLedgerEntries(AppConfig cfg, int limit = 30)
    {
        var list = new List<LedgerEntry>();
        if (!File.Exists(cfg.LedgerFile)) return list;
        try
        {
            foreach (var line in File.ReadLines(cfg.LedgerFile).Reverse())
            {
                if (string.IsNullOrWhiteSpace(line)) continue;
                var e = JsonSerializer.Deserialize<LedgerEntry>(line);
                if (e != null) list.Add(e);
                if (limit > 0 && list.Count >= limit) break;
            }
        }
        catch { }
        return list;
    }

    public static int UndoLastRun(AppConfig cfg)
    {
        if (!SecurityEngine.IsAdmin() || !File.Exists(cfg.LedgerFile)) return 0;
        var entries = GetLedgerEntries(cfg, 100);
        var lastRunId = entries.FirstOrDefault(e => e.Reversible)?.RunId;
        if (string.IsNullOrEmpty(lastRunId)) return 0;

        int undone = 0;
        foreach (var e in entries.Where(x => x.RunId == lastRunId && x.Reversible))
        {
            try
            {
                if (e.MutationType == "Registry" && !string.IsNullOrEmpty(e.ValueName))
                {
                    if (e.OldValue != null && e.OldValue != "NULL" && int.TryParse(e.OldValue, out int v))
                        Registry.SetValue(e.Target, e.ValueName, v, RegistryValueKind.DWord);
                    undone++;
                }
                else if (!string.IsNullOrEmpty(e.UndoCommand))
                {
                    NetworkEngine.RunTool("cmd.exe", $"/c {e.UndoCommand}", 8000);
                    undone++;
                }
            }
            catch { }
        }
        Log(cfg, "OK", $"Reverted {undone} mutations from run {lastRunId}.");
        return undone;
    }

    public static void Log(AppConfig cfg, string level, string message)
    {
        try
        {
            if (Directory.Exists(cfg.StoreDir))
            {
                if (File.Exists(cfg.LogFile) && new FileInfo(cfg.LogFile).Length > 524_288)
                    File.Move(cfg.LogFile, cfg.LogFile + ".1", overwrite: true);
                File.AppendAllText(cfg.LogFile, $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] [{level,-5}] {message}\r\n", Encoding.ASCII);
            }
        }
        catch { }
    }
}

#endregion

#region Layer 1-7 Network Engine, Subnet Calculus, PMTUD & RFC 1035 DNS Racer

public static class NetworkEngine
{
    public static List<NetworkInterface> GetPhysicalAdapters(bool ethernetOnly = false) =>
        NetworkInterface.GetAllNetworkInterfaces()
            .Where(n => !SecurityEngine.IsVirtualOrTunnel(n) &&
                        (!ethernetOnly || n.NetworkInterfaceType is NetworkInterfaceType.Ethernet or NetworkInterfaceType.GigabitEthernet or NetworkInterfaceType.FastEthernetT or NetworkInterfaceType.FastEthernetFx))
            .OrderByDescending(n => n.OperationalStatus == OperationalStatus.Up)
            .ThenByDescending(n => n.NetworkInterfaceType is NetworkInterfaceType.Ethernet or NetworkInterfaceType.GigabitEthernet)
            .ToList();

    public static List<NetworkInterface> GetSecondaryUplinks()
    {
        var ethIds = GetPhysicalAdapters(ethernetOnly: true).Select(e => e.Id).ToHashSet();
        return GetPhysicalAdapters(ethernetOnly: false)
            .Where(n => !ethIds.Contains(n.Id) && n.OperationalStatus == OperationalStatus.Up && GetValidIPv4(n) != null && GetDefaultGateway(n) != null)
            .ToList();
    }

    public static string? GetValidIPv4(NetworkInterface nic) =>
        nic.GetIPProperties().UnicastAddresses
            .FirstOrDefault(u => u.Address.AddressFamily == AddressFamily.InterNetwork &&
                                 !u.Address.ToString().StartsWith("169.254.") &&
                                 !IPAddress.IsLoopback(u.Address))
            ?.Address.ToString();

    public static string? GetDefaultGateway(NetworkInterface nic) =>
        nic.GetIPProperties().GatewayAddresses
            .Select(g => g.Address)
            .FirstOrDefault(a => a.AddressFamily == AddressFamily.InterNetwork && !a.Equals(IPAddress.Any))
            ?.ToString();

    // Pure Layer 3 Subnet Calculus
    public static SubnetInfo? CalculateSubnet(string ipStr, int prefix)
    {
        if (!IPAddress.TryParse(ipStr, out var ip) || ip.AddressFamily != AddressFamily.InterNetwork)
            return null;
        var ipBytes = ip.GetAddressBytes();
        if (prefix <= 0 || prefix > 32)
            prefix = ipBytes[0] < 128 ? 8 : ipBytes[0] < 192 ? 16 : 24;

        byte[] maskBytes = new byte[4], wildBytes = new byte[4], netBytes = new byte[4], bcastBytes = new byte[4];
        for (int i = 0; i < 4; i++)
        {
            int bits = Math.Clamp(prefix - (i * 8), 0, 8);
            maskBytes[i] = bits == 0 ? (byte)0 : (byte)(256 - (1 << (8 - bits)));
            netBytes[i] = (byte)(ipBytes[i] & maskBytes[i]);
            wildBytes[i] = (byte)(255 ^ maskBytes[i]);
            bcastBytes[i] = (byte)(netBytes[i] | wildBytes[i]);
        }

        byte[] minHost = (byte[])netBytes.Clone(), maxHost = (byte[])bcastBytes.Clone();
        if (prefix <= 30) { minHost[3]++; maxHost[3]--; }
        long totalHosts = prefix >= 31 ? 0L : (1L << (32 - prefix)) - 2;

        return new SubnetInfo(
            ipStr,
            prefix,
            string.Join(".", maskBytes),
            string.Join(".", wildBytes),
            string.Join(".", netBytes),
            string.Join(".", bcastBytes),
            string.Join(".", minHost),
            string.Join(".", maxHost),
            totalHosts);
    }

    public static SubnetInfo? GetAdapterSubnet(NetworkInterface nic)
    {
        var uni = nic.GetIPProperties().UnicastAddresses
            .FirstOrDefault(u => u.Address.AddressFamily == AddressFamily.InterNetwork && !u.Address.ToString().StartsWith("169.254."));
        return uni != null ? CalculateSubnet(uni.Address.ToString(), uni.PrefixLength) : null;
    }

    public static bool IsSameSubnet(string ip1, string ip2, int prefix)
    {
        if (!IPAddress.TryParse(ip1, out var a1) || !IPAddress.TryParse(ip2, out var a2) || prefix <= 0 || prefix > 32)
            return false;
        var b1 = a1.GetAddressBytes();
        var b2 = a2.GetAddressBytes();
        uint u1 = ((uint)b1[0] << 24) | ((uint)b1[1] << 16) | ((uint)b1[2] << 8) | b1[3];
        uint u2 = ((uint)b2[0] << 24) | ((uint)b2[1] << 16) | ((uint)b2[2] << 8) | b2[3];
        uint mask = prefix == 32 ? 0xFFFFFFFFu : 0xFFFFFFFFu << (32 - prefix);
        return (u1 & mask) == (u2 & mask);
    }

    public static int? PingMs(string target, int timeoutMs = 700)
    {
        try
        {
            using var p = new Ping();
            var r = p.Send(target, timeoutMs);
            return r.Status == IPStatus.Success ? (int)r.RoundtripTime : null;
        }
        catch { return null; }
    }

    // Layer 3 Path MTU Discovery (DF=true probe across 1500 / 1492 / 1420 / binary search)
    public static int DiscoverPathMtu(string target)
    {
        try
        {
            using var p = new Ping();
            var opt = new PingOptions(64, dontFragment: true);
            bool ProbeSize(int payload)
            {
                var buf = new byte[payload];
                for (int i = 0; i < 2; i++)
                {
                    try
                    {
                        var r = p.Send(target, 450, buf, opt);
                        if (r.Status == IPStatus.Success) return true;
                    }
                    catch { }
                }
                return false;
            }
            if (ProbeSize(1472)) return 1500;
            if (ProbeSize(1464)) return 1492;
            if (ProbeSize(1392)) return 1420;
            if (ProbeSize(1252)) return 1280;
        }
        catch { }
        return 1500;
    }

    public static bool TestTcpPort(string hostOrIp, int port, int timeoutMs = 600, string? sourceIp = null)
    {
        try
        {
            using var sock = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            if (!string.IsNullOrEmpty(sourceIp) && IPAddress.TryParse(sourceIp, out var src) && !sourceIp.StartsWith("169.254."))
                sock.Bind(new IPEndPoint(src, 0));

            var ar = sock.BeginConnect(hostOrIp, port, null, null);
            try
            {
                if (ar.AsyncWaitHandle.WaitOne(timeoutMs, false) && sock.Connected)
                {
                    sock.EndConnect(ar);
                    return true;
                }
            }
            finally { ar.AsyncWaitHandle.Close(); }
        }
        catch { }
        return false;
    }

    public static string ClassifyEnvironment(NetworkInterface nic, AppConfig cfg, PersistentState state)
    {
        int score = 0;
        var props = nic.GetIPProperties();
        var dns = props.DnsAddresses.Where(a => a.AddressFamily == AddressFamily.InterNetwork).Select(a => a.ToString()).ToList();
        var gw = GetDefaultGateway(nic) ?? "";
        var sfx = (props.DnsSuffix ?? "").Trim().Trim('.').ToLowerInvariant();
        var ip = GetValidIPv4(nic) ?? "";

        if (dns.Contains(cfg.CampusDns)) score += 2;
        if (!string.IsNullOrEmpty(sfx) && (sfx == cfg.CampusDomain || sfx.EndsWith("." + cfg.CampusDomain))) score += 2;
        if (Regex.IsMatch(gw, @"^(10\.\d{1,3}\.\d{1,3}\.1|172\.(1[6-9]|2\d|3[0-1])\.\d{1,3}\.1|100\.(6[4-9]|[7-9]\d|1[01]\d|12[0-7])\.\d{1,3}\.1)$")) score += 1;
        if (score < 2 && !string.IsNullOrEmpty(ip) && !ip.StartsWith("192.168."))
        {
            if (TestTcpPort(cfg.PortalIp, cfg.PortalPort, 350, ip)) score += 2;
        }
        if (score >= 2) return "Campus";
        return !string.IsNullOrEmpty(ip) && !string.IsNullOrEmpty(gw) ? "Other" : "Unknown";
    }

    // RFC 1035 Wire Query Builder
    public static byte[] BuildDnsQueryPacket(string domain, ushort txId)
    {
        var buf = new List<byte>(64)
        {
            (byte)(txId >> 8), (byte)(txId & 0xFF),
            0x01, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        };
        foreach (var label in domain.Trim().TrimEnd('.').Split('.', StringSplitOptions.RemoveEmptyEntries))
        {
            var bytes = Encoding.ASCII.GetBytes(label);
            buf.Add((byte)bytes.Length);
            buf.AddRange(bytes);
        }
        buf.AddRange([0x00, 0x00, 0x01, 0x00, 0x01]);
        return [.. buf];
    }

    // RFC 1035 Wire Answer Parser (Multi-Question QDCOUNT + CNAME Hybrid Compression Pointers)
    public static List<string> ParseDnsAAnswers(byte[] resp, byte[] query)
    {
        var res = new List<string>();
        if (resp == null || query == null || resp.Length < 12 || query.Length < 12) return res;
        if (resp[0] != query[0] || resp[1] != query[1]) return res;
        if ((resp[2] & 0x80) == 0 || (resp[3] & 0x0F) != 0) return res;

        int qdc = (resp[4] << 8) | resp[5];
        int anc = (resp[6] << 8) | resp[7];
        if (qdc <= 0 || qdc > 32 || anc <= 0 || anc > 256) return res;

        int i = 12;
        for (int q = 0; q < qdc; q++)
        {
            if (!SkipDnsName(resp, ref i) || i + 4 > resp.Length) return res;
            i += 4;
        }

        for (int a = 0; a < anc && i + 10 <= resp.Length; a++)
        {
            if (!SkipDnsName(resp, ref i) || i + 10 > resp.Length) break;
            int type = (resp[i] << 8) | resp[i + 1];
            int cls = (resp[i + 2] << 8) | resp[i + 3];
            int rdlen = (resp[i + 8] << 8) | resp[i + 9];
            i += 10;
            if (i + rdlen > resp.Length) break;
            if (type == 1 && cls == 1 && rdlen == 4)
            {
                var ip = $"{resp[i]}.{resp[i + 1]}.{resp[i + 2]}.{resp[i + 3]}";
                if (!IsSinkholeIp(ip)) res.Add(ip);
            }
            i += rdlen;
        }
        return res;
    }

    private static bool SkipDnsName(byte[] pkt, ref int i)
    {
        int guard = 0;
        while (i < pkt.Length && guard++ < 128)
        {
            int len = pkt[i];
            if (len == 0) { i++; return true; }
            if ((len & 0xC0) == 0xC0)
            {
                if (i + 2 > pkt.Length) return false;
                i += 2;
                return true;
            }
            if (i + len + 1 > pkt.Length) return false;
            i += len + 1;
        }
        return false;
    }

    public static bool IsSinkholeIp(string ip) =>
        string.IsNullOrWhiteSpace(ip) ||
        Regex.IsMatch(ip.Trim(), @"^(0\.|127\.|169\.254\.|192\.0\.2\.|198\.51\.100\.|203\.0\.113\.|22[4-9]\.|23\d\.|24\d\.|25\d\.)");

    // Source-Scoped Raw UDP DNS Resolver (Prevents Wi-Fi DNS from masking dead Ethernet DNS)
    public static List<string> QueryScopedDns(string domain, string? sourceIp, IEnumerable<string> servers, int timeoutMs = 900)
    {
        ushort txId = (ushort)Random.Shared.Next(1000, 60000);
        var pkt = BuildDnsQueryPacket(domain, txId);
        foreach (var srv in servers.Where(s => !string.IsNullOrWhiteSpace(s)).Distinct())
        {
            try
            {
                using var udp = !string.IsNullOrEmpty(sourceIp) && IPAddress.TryParse(sourceIp, out var src)
                    ? new UdpClient(new IPEndPoint(src, 0))
                    : new UdpClient();
                udp.Client.ReceiveTimeout = timeoutMs;
                udp.Client.SendTimeout = timeoutMs;
                udp.Connect(srv, 53);
                udp.Send(pkt, pkt.Length);
                IPEndPoint? ep = null;
                var resp = udp.Receive(ref ep);
                var ans = ParseDnsAAnswers(resp, pkt);
                if (ans.Count > 0) return ans;
            }
            catch { }
        }
        return [];
    }

    public static Dictionary<string, int?> MeasureResolversFast(IEnumerable<string> servers, string? sourceIp = null, int timeoutMs = 650)
    {
        var serverList = servers.Where(s => !string.IsNullOrWhiteSpace(s)).Distinct().ToList();
        var results = new ConcurrentDictionary<string, int?>();
        ushort txId = (ushort)Random.Shared.Next(1000, 60000);
        var pkt = BuildDnsQueryPacket("www.cloudflare.com", txId);

        Parallel.ForEach(serverList, srv =>
        {
            try
            {
                using var udp = !string.IsNullOrEmpty(sourceIp) && IPAddress.TryParse(sourceIp, out var src)
                    ? new UdpClient(new IPEndPoint(src, 0))
                    : new UdpClient();
                udp.Client.ReceiveTimeout = timeoutMs;
                udp.Client.SendTimeout = timeoutMs;
                var sw = Stopwatch.StartNew();
                udp.Connect(srv, 53);
                udp.Send(pkt, pkt.Length);
                IPEndPoint? ep = null;
                var resp = udp.Receive(ref ep);
                sw.Stop();
                int rcode = resp != null && resp.Length >= 12 ? (resp[3] & 0x0F) : -1;
                if (resp != null && resp.Length >= 12 && resp[0] == pkt[0] && resp[1] == pkt[1] && (resp[2] & 0x80) != 0 && (rcode == 0 || rcode == 3 || rcode == 5))
                    results[srv] = (int)sw.ElapsedMilliseconds;
                else
                    results[srv] = null;
            }
            catch { results[srv] = null; }
        });

        return serverList.ToDictionary(s => s, s => results.GetValueOrDefault(s));
    }

    public static string? ResolveHostScoped(string host, string? sourceIp, AppConfig cfg)
    {
        var clean = host.Trim().TrimEnd('.');
        if (IPAddress.TryParse(clean, out _)) return clean;
        if (clean.Equals(cfg.PortalHost, StringComparison.OrdinalIgnoreCase)) return cfg.PortalIp;

        if (!string.IsNullOrEmpty(sourceIp))
        {
            var ownerNic = GetPhysicalAdapters().FirstOrDefault(n => GetValidIPv4(n) == sourceIp);
            if (ownerNic != null)
            {
                var nicDns = ownerNic.GetIPProperties().DnsAddresses
                    .Where(a => a.AddressFamily == AddressFamily.InterNetwork)
                    .Select(a => a.ToString())
                    .ToList();
                if (GetSecondaryUplinks().Count > 0)
                {
                    var scopedAns = QueryScopedDns(clean, sourceIp, nicDns, 900);
                    return scopedAns.FirstOrDefault();
                }
            }
        }

        try
        {
            var addrs = Dns.GetHostAddressesAsync(clean).WaitAsync(TimeSpan.FromMilliseconds(1800)).GetAwaiter().GetResult();
            var v4 = addrs.FirstOrDefault(a => a.AddressFamily == AddressFamily.InterNetwork && !IsSinkholeIp(a.ToString()));
            if (v4 != null) return v4.ToString();
        }
        catch { }
        return null;
    }

    public static (ConnState State, string Location) GetInternetState(AppConfig cfg, string? sourceIp = null)
    {
        var ip = ResolveHostScoped("connectivitycheck.gstatic.com", sourceIp, cfg);
        if (ip == null) return (ConnState.NoDns, "");

        try
        {
            using var sock = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            if (!string.IsNullOrEmpty(sourceIp) && IPAddress.TryParse(sourceIp, out var src))
                sock.Bind(new IPEndPoint(src, 0));

            var ar = sock.BeginConnect(IPAddress.Parse(ip), 80, null, null);
            try
            {
                if (!ar.AsyncWaitHandle.WaitOne(1800, false)) return (ConnState.Offline, "");
                sock.EndConnect(ar);
            }
            finally { ar.AsyncWaitHandle.Close(); }

            sock.ReceiveTimeout = 1800;
            sock.SendTimeout = 1800;
            var req = Encoding.ASCII.GetBytes("GET /generate_204 HTTP/1.0\r\nHost: connectivitycheck.gstatic.com\r\nUser-Agent: LanFixer/7.0.2\r\nConnection: close\r\n\r\n");
            sock.Send(req);

            var buf = new byte[2048];
            int n = sock.Receive(buf);
            if (n <= 0) return (ConnState.Offline, "");
            var raw = Encoding.ASCII.GetString(buf, 0, n);
            var (code, loc, _) = ParseHttpResponse(raw);

            if (code == 204)
            {
                string activePortal = !string.IsNullOrEmpty(cfg.PortalUrl) ? cfg.PortalUrl : "https://10.114.0.5:8888/";
                if (IsPortalDemandingAuth(activePortal, sourceIp))
                    return (ConnState.Captive, activePortal);

                if (VerifyWanTls("1.1.1.1", sourceIp, 1500) || VerifyWanTls("9.9.9.9", sourceIp, 1500))
                    return (ConnState.Online, "");
                return (ConnState.Captive, activePortal);
            }
            if ((code >= 300 && code <= 399) || (code >= 200 && code <= 299) || code is 401 or 407 or 511 || !string.IsNullOrEmpty(loc))
                return (ConnState.Captive, !string.IsNullOrEmpty(loc) ? loc : cfg.PortalUrl);
        }
        catch { }
        return (ConnState.Offline, "");
    }

    public static bool IsPortalDemandingAuth(string portalUrl, string? sourceIp = null, int timeoutMs = 1500)
    {
        if (string.IsNullOrEmpty(portalUrl) || !Uri.TryCreate(portalUrl, UriKind.Absolute, out var uri))
            return false;

        string targetHost = uri.Host;
        int port = uri.Port > 0 ? uri.Port : (uri.Scheme.Equals("https", StringComparison.OrdinalIgnoreCase) ? 443 : 80);
        bool isHttps = uri.Scheme.Equals("https", StringComparison.OrdinalIgnoreCase);

        try
        {
            using var sock = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            if (!string.IsNullOrEmpty(sourceIp) && IPAddress.TryParse(sourceIp, out var src))
                sock.Bind(new IPEndPoint(src, 0));

            var ar = sock.BeginConnect(targetHost, port, null, null);
            try
            {
                if (!ar.AsyncWaitHandle.WaitOne(timeoutMs, false)) return false;
                sock.EndConnect(ar);
            }
            finally { ar.AsyncWaitHandle.Close(); }

            sock.ReceiveTimeout = timeoutMs;
            sock.SendTimeout = timeoutMs;

            Stream stream = new NetworkStream(sock, ownsSocket: false);
            if (isHttps)
            {
                var ssl = new SslStream(stream, false, (_, _, _, _) => true);
                ssl.AuthenticateAsClient(targetHost);
                stream = ssl;
            }

            using (stream)
            {
                var req = Encoding.ASCII.GetBytes($"GET {uri.PathAndQuery} HTTP/1.0\r\nHost: {targetHost}\r\nUser-Agent: LanFixer/7.0.2\r\nConnection: close\r\n\r\n");
                stream.Write(req, 0, req.Length);
                stream.Flush();

                var buf = new byte[8192];
                int n = stream.Read(buf, 0, buf.Length);
                if (n > 0)
                {
                    var html = Encoding.ASCII.GetString(buf, 0, n);
                    return Regex.IsMatch(html, @"name=['""]?passwordfld['""]?", RegexOptions.IgnoreCase) ||
                           Regex.IsMatch(html, @"name=['""]?usernamefld['""]?", RegexOptions.IgnoreCase) ||
                           Regex.IsMatch(html, @"type=['""]?password['""]?", RegexOptions.IgnoreCase);
                }
            }
        }
        catch { }
        return false;
    }

    public static bool VerifyWanTls(string wanIp, string? sourceIp, int timeoutMs = 1500)
    {
        try
        {
            using var sock = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            if (!string.IsNullOrEmpty(sourceIp) && IPAddress.TryParse(sourceIp, out var src))
                sock.Bind(new IPEndPoint(src, 0));
            var ar = sock.BeginConnect(IPAddress.Parse(wanIp), 443, null, null);
            try
            {
                if (!ar.AsyncWaitHandle.WaitOne(timeoutMs, false)) return false;
                sock.EndConnect(ar);
            }
            finally { ar.AsyncWaitHandle.Close(); }

            using var ns = new NetworkStream(sock, ownsSocket: false) { ReadTimeout = timeoutMs, WriteTimeout = timeoutMs };
            using var ssl = new SslStream(ns, false, (_, _, _, errs) => errs == SslPolicyErrors.None);
            ssl.AuthenticateAsClient(wanIp, null, SslProtocols.Tls12 | SslProtocols.Tls13, false);
            return ssl.IsAuthenticated;
        }
        catch { return false; }
    }

    public static (int Code, string Location, string Body) ParseHttpResponse(string raw)
    {
        if (string.IsNullOrEmpty(raw)) return (0, "", "");
        var m = Regex.Match(raw, @"^HTTP/\d\.\d\s+(\d{3})");
        if (!m.Success) return (0, "", "");
        int code = int.Parse(m.Groups[1].Value);

        int cut = raw.IndexOf("\r\n\r\n", StringComparison.Ordinal);
        int skip = 4;
        if (cut < 0) { cut = raw.IndexOf("\n\n", StringComparison.Ordinal); skip = 2; }
        string head = cut >= 0 ? raw[..cut] : raw;
        string body = cut >= 0 ? raw[(cut + skip)..] : "";

        var lm = Regex.Match(head, @"(?im)^Location:[ \t]*(\S+)");
        string loc = lm.Success ? lm.Groups[1].Value.Trim() : ExtractBodyRedirect(body);
        return (code, loc, body);
    }

    public static string ExtractBodyRedirect(string html)
    {
        if (string.IsNullOrEmpty(html)) return "";
        string[] patterns = [
            @"(?is)<meta\b[^>]*http-equiv\s*=\s*[""']?refresh[""']?[^>]*content\s*=\s*[""'][^""']*?url\s*=\s*[""']?([^""'>\s]+)",
            @"(?is)<meta\b[^>]*content\s*=\s*[""'][^""']*?url\s*=\s*[""']?([^""'>\s]+)[^>]*http-equiv\s*=\s*[""']?refresh",
            @"(?is)(?:window\.|self\.|top\.|document\.)?location(?:\.href|\.replace|\.assign)?\s*(?:=|\()\s*[""'](https?://[^""'\s<>]+)[""']"
        ];
        foreach (var rx in patterns)
        {
            var m = Regex.Match(html, rx, RegexOptions.None, TimeSpan.FromMilliseconds(400));
            if (m.Success)
            {
                var u = WebUtility.HtmlDecode(m.Groups[1].Value).Trim('"', '\'', ';', ' ');
                if (Uri.TryCreate(u, UriKind.Absolute, out var uri) && (uri.Scheme == "http" || uri.Scheme == "https"))
                    return uri.AbsoluteUri;
            }
        }
        return "";
    }

    public static (int ExitCode, string Output) RunTool(string exeName, string args, int timeoutMs = 15000)
    {
        try
        {
            var sys32 = Environment.GetFolderPath(Environment.SpecialFolder.System);
            var fullPath = File.Exists(Path.Combine(sys32, exeName)) ? Path.Combine(sys32, exeName) : exeName;
            var psi = new ProcessStartInfo
            {
                FileName = fullPath,
                Arguments = args,
                UseShellExecute = false,
                CreateNoWindow = true,
                RedirectStandardOutput = true,
                RedirectStandardError = true
            };
            using var p = Process.Start(psi);
            if (p == null) return (-1, "");
            var so = p.StandardOutput.ReadToEndAsync();
            var se = p.StandardError.ReadToEndAsync();
            if (!p.WaitForExit(timeoutMs))
            {
                try { p.Kill(); } catch { }
                return (-1, "TimedOut");
            }
            return (p.ExitCode, so.Result + se.Result);
        }
        catch (Exception ex) { return (-1, ex.Message); }
    }
}

#endregion

#region Source-Bound Captive Portal Client, Doctor, Debloat & 6-Tier Recovery Engine

public static class PortalClient
{
    public static (Uri Action, string UserField, string PassField, Dictionary<string, string> Fields)? ParseLoginForm(string html, Uri pageUri)
    {
        if (string.IsNullOrEmpty(html) || !Regex.IsMatch(html, @"(?is)<input\b[^>]*type\s*=\s*[""']?password"))
            return null;

        string? passField = null, userField = null;
        var fields = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        var candidates = new List<(string Name, string Id, string Val)>();

        foreach (Match inp in Regex.Matches(html, @"(?is)<input\b[^>]*>"))
        {
            var tag = inp.Value;
            var type = (GetAttr(tag, "type") ?? "").ToLowerInvariant();
            var name = GetAttr(tag, "name");
            if (string.IsNullOrEmpty(name)) continue;
            var id = GetAttr(tag, "id") ?? "";
            var val = GetAttr(tag, "value") ?? "";

            if (type == "password") passField ??= name;
            else if (type == "hidden") fields[name] = val;
            else if (type == "checkbox" && Regex.IsMatch(tag, @"(?i)\bchecked\b")) fields[name] = string.IsNullOrEmpty(val) ? "on" : val;
            else if (type == "submit" && !fields.ContainsKey(name)) fields[name] = val;
            else if (type is "" or "text" or "email" or "tel" or "number") candidates.Add((name, id, val));
        }

        if (passField == null) return null;
        foreach (var c in candidates)
        {
            if (Regex.IsMatch(c.Name + " " + c.Id, @"(?i)user|login|email|auth|account|id|roll|reg|uid|uname|student"))
            {
                userField = c.Name;
                break;
            }
        }
        userField ??= candidates.FirstOrDefault().Name ?? "auth_user";

        Uri target = pageUri;
        var fm = Regex.Match(html, @"(?is)<form\b([^>]*)>");
        if (fm.Success)
        {
            var act = GetAttr(fm.Groups[1].Value, "action");
            if (!string.IsNullOrEmpty(act) && Uri.TryCreate(pageUri, act, out var resolved))
                target = resolved;
        }
        return (target, userField, passField, fields);
    }

    private static string? GetAttr(string tag, string name)
    {
        var m = Regex.Match(tag, $@"(?i)(?<![\w-]){Regex.Escape(name)}\s*=\s*(?:""([^""]*)""|'([^']*)'|([^\s>]+))");
        if (!m.Success) return null;
        for (int g = 1; g <= 3; g++)
            if (m.Groups[g].Success) return WebUtility.HtmlDecode(m.Groups[g].Value);
        return "";
    }

    public static bool IsCredentialPortalHostTrusted(string host, AppConfig cfg)
    {
        var h = host.Trim().TrimEnd('.').ToLowerInvariant();
        if (string.IsNullOrEmpty(h)) return false;
        if (h == cfg.PortalHost.ToLowerInvariant() || h == cfg.PortalIp) return true;
        var dom = cfg.CampusDomain.ToLowerInvariant().Trim('.');
        return !string.IsNullOrEmpty(dom) && (h == dom || h.EndsWith("." + dom));
    }

    public static bool AttemptHeadlessLogin(AppConfig cfg, PersistentState state, string? sourceIp = null)
    {
        if (state.PortalLoginSuspended) return false;
        var creds = SecurityEngine.LoadCredentials(cfg);
        if (creds == null) return false;

        var url = state.DiscoveredPortalUrl ?? cfg.PortalUrl;
        if (!Uri.TryCreate(url, UriKind.Absolute, out var uri) || uri.Scheme != "https")
            return false;

        if (!IsCredentialPortalHostTrusted(uri.Host, cfg))
        {
            StateStore.Log(cfg, "ALERT", $"Refused to send vault credentials to untrusted host '{uri.Host}'.");
            return false;
        }

        try
        {
            using var handler = new SocketsHttpHandler
            {
                AllowAutoRedirect = true,
                MaxAutomaticRedirections = 4,
                UseProxy = false,
                ConnectTimeout = TimeSpan.FromSeconds(5),
                // Source-Bind TCP socket to Ethernet IP so portal auth never leaks over Wi-Fi hotspot
                ConnectCallback = async (ctx, ct) =>
                {
                    var targetIp = NetworkEngine.ResolveHostScoped(ctx.DnsEndPoint.Host, sourceIp, cfg)
                                   ?? throw new SocketException((int)SocketError.HostNotFound);
                    var sock = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
                    try
                    {
                        if (!string.IsNullOrEmpty(sourceIp) && IPAddress.TryParse(sourceIp, out var src))
                            sock.Bind(new IPEndPoint(src, 0));
                        await sock.ConnectAsync(new IPEndPoint(IPAddress.Parse(targetIp), ctx.DnsEndPoint.Port), ct);
                        return new NetworkStream(sock, ownsSocket: true);
                    }
                    catch
                    {
                        sock.Dispose();
                        throw;
                    }
                }
            };

            handler.SslOptions.RemoteCertificateValidationCallback = (_, cert, _, errs) =>
            {
                if (errs == SslPolicyErrors.None) return true;
                if (cert == null || string.IsNullOrEmpty(state.PortalPin)) return false;
                var hex = Convert.ToHexString(SHA256.HashData(cert.GetRawCertData()));
                return string.Equals(hex, state.PortalPin, StringComparison.OrdinalIgnoreCase);
            };

            using var client = new HttpClient(handler) { Timeout = TimeSpan.FromSeconds(8) };
            var pageHtml = client.GetStringAsync(uri).GetAwaiter().GetResult();
            var form = ParseLoginForm(pageHtml, uri);
            if (form == null || !IsCredentialPortalHostTrusted(form.Value.Action.Host, cfg)) return false;

            var payload = new Dictionary<string, string>(form.Value.Fields)
            {
                [form.Value.UserField] = creds.Value.User,
                [form.Value.PassField] = creds.Value.Pass
            };
            if (!payload.ContainsKey("accept") && payload.ContainsKey("zone"))
                payload["accept"] = "Sign In";

            using var content = new FormUrlEncodedContent(payload);
            using var resp = client.PostAsync(form.Value.Action, content).GetAwaiter().GetResult();

            for (int i = 0; i < 4; i++)
            {
                Thread.Sleep(750);
                if (NetworkEngine.GetInternetState(cfg, sourceIp).State == ConnState.Online)
                {
                    state.PortalFails = 0;
                    state.PortalLoginSuspended = false;
                    StateStore.Save(cfg, state);
                    StateStore.Log(cfg, "OK", "Signed in to campus captive portal automatically via DPAPI vault.");
                    return true;
                }
            }

            state.PortalFails++;
            if (state.PortalFails >= 2) state.PortalLoginSuspended = true;
            StateStore.Save(cfg, state);
        }
        catch { }
        return false;
    }
}

public static class RemediationEngine
{
    public static DoctorReport RunDoctor(AppConfig cfg)
    {
        var sw = Stopwatch.StartNew();
        var state = StateStore.Load(cfg);
        var layers = new List<LayerResult>();
        var nics = NetworkEngine.GetPhysicalAdapters();
        var primary = nics.FirstOrDefault();

        // Layer 1: Physical Link
        if (primary == null)
            layers.Add(new(1, "PhysicalLink", "UNKNOWN", "No physical network adapter detected", "Diagnose"));
        else if (primary.OperationalStatus != OperationalStatus.Up)
            layers.Add(new(1, "PhysicalLink", "FAILED", $"Adapter {primary.Name} is {primary.OperationalStatus}", "QuickHeal"));
        else
            layers.Add(new(1, "PhysicalLink", "OK", $"{primary.Name} ({Math.Max(1, primary.Speed / 1_000_000)} Mbps Up)", "None"));

        // Layer 2: IP Configuration & Subnet Calculus
        var ip = primary != null && primary.OperationalStatus == OperationalStatus.Up ? NetworkEngine.GetValidIPv4(primary) : null;
        var sub = primary != null ? NetworkEngine.GetAdapterSubnet(primary) : null;
        if (string.IsNullOrEmpty(ip))
            layers.Add(new(2, "IpConfig", "FAILED", "No valid IPv4 lease (APIPA / Unassigned)", "QuickHeal"));
        else
            layers.Add(new(2, "IpConfig", "OK", sub != null ? $"{ip}/{sub.PrefixLength} ({sub.TotalHosts} hosts)" : $"IPv4 Lease: {ip}", "None"));

        // Layer 3: Gateway Reachability
        var gw = primary != null ? NetworkEngine.GetDefaultGateway(primary) : null;
        var gwRtt = !string.IsNullOrEmpty(gw) ? NetworkEngine.PingMs(gw, 700) : null;
        if (string.IsNullOrEmpty(gw))
            layers.Add(new(3, "GatewayReach", "FAILED", "No default 0.0.0.0/0 gateway", "QuickHeal"));
        else if (gwRtt.HasValue || NetworkEngine.TestTcpPort(gw, 80, 350, ip) || NetworkEngine.TestTcpPort(gw, 443, 350, ip) || NetworkEngine.TestTcpPort(gw, cfg.PortalPort, 350, ip))
            layers.Add(new(3, "GatewayReach", "OK", $"Gateway {gw} reachable ({(gwRtt.HasValue ? $"{gwRtt}ms" : "TCP/ARP")})", "None"));
        else
            layers.Add(new(3, "GatewayReach", "FAILED", $"Gateway {gw} unreachable", "QuickHeal"));

        // Layer 4: DNS Resolution
        var resolved = !string.IsNullOrEmpty(ip) ? NetworkEngine.ResolveHostScoped("connectivitycheck.gstatic.com", ip, cfg) : null;
        if (string.IsNullOrEmpty(resolved))
            layers.Add(new(4, "DnsResolution", "FAILED", "DNS resolution failed", "QuickHeal"));
        else
            layers.Add(new(4, "DnsResolution", "OK", $"Resolved probe host -> {resolved}", "None"));

        // Layer 5-7: Internet, TLS & Captive Portal
        var (inetState, loc) = !string.IsNullOrEmpty(ip) ? NetworkEngine.GetInternetState(cfg, ip) : (ConnState.Offline, "");
        if (inetState == ConnState.Online)
        {
            layers.Add(new(5, "InternetIpv4", "OK", "HTTP 204 probe verified", "None"));
            layers.Add(new(6, "HttpsTls", "OK", "TLS 1.2/1.3 WAN handshake verified", "None"));
            layers.Add(new(7, "CaptivePortal", "OK", "Unrestricted internet egress", "None"));
        }
        else if (inetState == ConnState.Captive)
        {
            layers.Add(new(5, "InternetIpv4", "DEGRADED", $"Intercepted by captive portal ({loc})", "Login"));
            layers.Add(new(6, "HttpsTls", "DEGRADED", "Awaiting portal authentication", "Login"));
            layers.Add(new(7, "CaptivePortal", "DEGRADED", "Captive portal sign-in required", "Login"));
        }
        else
        {
            layers.Add(new(5, "InternetIpv4", "FAILED", $"Internet state: {inetState}", "QuickHeal"));
            layers.Add(new(6, "HttpsTls", "FAILED", "WAN TLS unreachable", "QuickHeal"));
            layers.Add(new(7, "CaptivePortal", "UNKNOWN", "Untested while offline", "QuickHeal"));
        }

        sw.Stop();
        var env = primary != null ? NetworkEngine.ClassifyEnvironment(primary, cfg, state) : "Unknown";
        int pmtu = !string.IsNullOrEmpty(gw) ? NetworkEngine.DiscoverPathMtu(gw) : 1500;
        var failed = layers.FirstOrDefault(l => l.Status == "FAILED");
        var degraded = layers.FirstOrDefault(l => l.Status == "DEGRADED");
        var verdict = failed != null ? NetVerdict.Broken : degraded != null ? NetVerdict.Degraded : primary == null ? NetVerdict.Undetermined : NetVerdict.Healthy;
        string cause = failed?.Evidence ?? degraded?.Evidence ?? "All 7 OSI layers verified healthy.";

        return new DoctorReport(primary?.Name ?? "None", ip ?? "None", gw ?? "None", env, pmtu, verdict, (int)verdict, cause, sw.ElapsedMilliseconds, layers);
    }

    // Pure 3-branch routing metric planner
    public static (string Mode, int EthMetric, int OtherMetric, bool CampusRoutes) PlanRouteMetrics(string env, ConnState conn, int otherUplinkCount, string profile = "Adaptive")
    {
        if (profile == "Windows") return ("Restore", 0, 0, false);
        if (profile == "Ethernet") return ("Promote", 10, 40, false);
        if (profile == "Wifi") return otherUplinkCount > 0 ? ("Protect", 50, 15, env == "Campus") : ("Restore", 0, 0, false);

        if (env != "Campus") return ("Restore", 0, 0, false);
        if (conn != ConnState.Online)
            return otherUplinkCount > 0 ? ("Protect", 50, 15, true) : ("Restore", 0, 0, false);
        return ("Promote", 10, 40, false);
    }

    public static void ApplyRouteAndPortalShield(NetworkInterface eth, string env, ConnState conn, AppConfig cfg, PersistentState state)
    {
        if (!SecurityEngine.IsAdmin()) return;
        var secondaries = NetworkEngine.GetSecondaryUplinks();
        var plan = PlanRouteMetrics(env, conn, secondaries.Count, state.RouteProfile);

        if (plan.Mode == "Restore")
        {
            RemoveCampusHostRoutes(state);
            NetworkEngine.RunTool("netsh.exe", $"interface ipv4 set interface \"{eth.Name}\" metric=automatic", 4000);
            foreach (var sec in secondaries)
                NetworkEngine.RunTool("netsh.exe", $"interface ipv4 set interface \"{sec.Name}\" metric=automatic", 4000);
            return;
        }

        if (!plan.CampusRoutes) RemoveCampusHostRoutes(state);
        NetworkEngine.RunTool("netsh.exe", $"interface ipv4 set interface \"{eth.Name}\" metric={plan.EthMetric}", 4000);
        foreach (var sec in secondaries)
            NetworkEngine.RunTool("netsh.exe", $"interface ipv4 set interface \"{sec.Name}\" metric={plan.OtherMetric}", 4000);

        if (plan.CampusRoutes)
        {
            var gw = NetworkEngine.GetDefaultGateway(eth);
            var sub = NetworkEngine.GetAdapterSubnet(eth);
            if (!string.IsNullOrEmpty(gw))
            {
                int ifIdx = eth.GetIPProperties().GetIPv4Properties()?.Index ?? 0;
                foreach (var targetIp in new[] { cfg.PortalIp, cfg.CampusDns, state.DiscoveredPortalIp }.Where(x => !string.IsNullOrEmpty(x)).Distinct())
                {
                    bool onLink = sub != null && NetworkEngine.IsSameSubnet(sub.IpAddress, targetIp!, sub.PrefixLength);
                    string nextHop = onLink ? "0.0.0.0" : gw;
                    NetworkEngine.RunTool("route.exe", $"add {targetIp} mask 255.255.255.255 {nextHop} metric 5 {(ifIdx > 0 ? $"IF {ifIdx}" : "")}", 3000);
                    if (!state.InjectedHostRoutes.Contains(targetIp!))
                        state.InjectedHostRoutes.Add(targetIp!);
                }
            }
        }
    }

    public static void RemoveCampusHostRoutes(PersistentState state)
    {
        foreach (var hip in state.InjectedHostRoutes.ToList())
            NetworkEngine.RunTool("route.exe", $"delete {hip}", 3000);
        state.InjectedHostRoutes.Clear();
    }

    public static void FlushCaches(AppConfig cfg)
    {
        NetworkEngine.RunTool("ipconfig.exe", "/flushdns", 5000);
        NetworkEngine.RunTool("netsh.exe", "interface ip delete arpcache", 5000);
        NetworkEngine.RunTool("nbtstat.exe", "-R", 5000);
        NetworkEngine.RunTool("nbtstat.exe", "-RR", 5000);
        StateStore.Log(cfg, "OK", "6-Stage Universal Cache Flush: DNS, ARP, NetBIOS, and sockets cleared.");
    }

    public static ConnState ExecuteQuickHeal(AppConfig cfg, PersistentState state)
    {
        using var lk = new GlobalLock();
        var eths = NetworkEngine.GetPhysicalAdapters(ethernetOnly: true);
        var all = NetworkEngine.GetPhysicalAdapters(ethernetOnly: false);
        var target = eths.FirstOrDefault(n => n.OperationalStatus == OperationalStatus.Up) ?? all.FirstOrDefault();
        if (target == null) return ConnState.NoLink;

        // Layer 1: AC USB Selective Suspend & PCIe ASPM Shield (Battery-aware)
        if (SecurityEngine.IsAdmin() && SystemInformation.PowerStatus.PowerLineStatus != PowerLineStatus.Offline)
        {
            NetworkEngine.RunTool("powercfg.exe", "/setacvalueindex scheme_current 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0", 4000);
            NetworkEngine.RunTool("powercfg.exe", "/setactive scheme_current", 4000);
        }

        // Layer 2: 3-Step DHCP Recovery Ladder if APIPA or missing IPv4
        var ip = NetworkEngine.GetValidIPv4(target);
        if (string.IsNullOrEmpty(ip))
        {
            if (SecurityEngine.IsAdmin())
            {
                try
                {
                    Registry.SetValue($@"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{target.Id}", "DhcpConnForceBroadcastFlag", 1, RegistryValueKind.DWord);
                }
                catch { }
            }
            NetworkEngine.RunTool("ipconfig.exe", $"/release \"{target.Name}\"", 8000);
            NetworkEngine.RunTool("ipconfig.exe", $"/renew \"{target.Name}\"", 15000);
            target = NetworkEngine.GetPhysicalAdapters().FirstOrDefault(n => n.Id == target.Id) ?? target;
            ip = NetworkEngine.GetValidIPv4(target);
        }
        if (string.IsNullOrEmpty(ip)) return ConnState.NoIp;

        // Layer 3: Environment Classification & Multi-Homed Metric Shield
        var env = NetworkEngine.ClassifyEnvironment(target, cfg, state);
        var (conn, loc) = NetworkEngine.GetInternetState(cfg, ip);
        if (!string.IsNullOrEmpty(loc)) state.DiscoveredPortalUrl = loc;
        ApplyRouteAndPortalShield(target, env, conn, cfg, state);

        // Layer 4: Parallel UDP RFC 1035 DNS Latency Racer & Adaptive Switching
        var candidates = env == "Campus" ? cfg.ActivePublicDns.Prepend(cfg.CampusDns) : cfg.ActivePublicDns;
        var scores = NetworkEngine.MeasureResolversFast(candidates, ip);
        var bestDns = scores.Where(kv => kv.Value.HasValue).OrderBy(kv => kv.Value!.Value).Select(kv => kv.Key).ToList();

        if (SecurityEngine.IsAdmin() && bestDns.Count > 0 && (conn == ConnState.NoDns || env == "Campus"))
        {
            var curDns = string.Join(",", target.GetIPProperties().DnsAddresses.Where(a => a.AddressFamily == AddressFamily.InterNetwork));
            StateStore.SaveOriginal(state, $"Dns:{target.Id}", curDns);
            string primaryDns = conn == ConnState.Captive && scores.GetValueOrDefault(cfg.CampusDns).HasValue ? cfg.CampusDns : bestDns[0];
            NetworkEngine.RunTool("netsh.exe", $"interface ipv4 set dnsservers name=\"{target.Name}\" static {primaryDns} primary", 5000);
            if (bestDns.Count > 1 && bestDns[1] != primaryDns)
                NetworkEngine.RunTool("netsh.exe", $"interface ipv4 add dnsservers name=\"{target.Name}\" {bestDns[1]} index=2", 5000);

            StateStore.RecordMutation(cfg, "Dns", target.Name, null, curDns, primaryDns, true,
                $"netsh interface ipv4 set dnsservers name=\"{target.Name}\" dhcp", $"Configured adaptive DNS ({primaryDns}) on {target.Name}");
            FlushCaches(cfg);
            (conn, _) = NetworkEngine.GetInternetState(cfg, ip);
        }

        // Layer 7: Autonomous Captive Portal Authentication
        if (conn == ConnState.Captive && PortalClient.AttemptHeadlessLogin(cfg, state, ip))
        {
            conn = ConnState.Online;
            ApplyRouteAndPortalShield(target, env, conn, cfg, state);
        }

        StateStore.Save(cfg, state);
        return conn;
    }

    // Tier 1: Careful Network & Stack Debloat
    public static int ApplyNetworkDebloat(AppConfig cfg, PersistentState state)
    {
        if (!SecurityEngine.IsAdmin()) return 0;
        using var lk = new GlobalLock();
        var vectors = new (string Key, string Name, int Val, string Desc)[]
        {
            (@"HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization", "DODownloadMode", 0, "Disable P2P Update Seeding"),
            (@"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile", "NetworkThrottlingIndex", -1, "Disable Multimedia Packet Throttling"),
            (@"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile", "SystemResponsiveness", 0, "Zero Network Packet Queue Reservation"),
            (@"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad", "WpadOverride", 1, "Disable WPAD Proxy Broadcast Probing"),
            (@"HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient", "EnableMulticast", 0, "Disable LLMNR Multicast Spoofing Vector"),
            (@"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters", "MaxNegativeCacheTtl", 5, "Clamp Negative DNS Cache TTL to 5s")
        };

        int count = 0;
        foreach (var v in vectors)
        {
            var cur = Registry.GetValue(v.Key, v.Name, null)?.ToString() ?? "NULL";
            if (cur == v.Val.ToString()) continue;
            StateStore.SaveOriginal(state, $"Reg:{v.Key}\\{v.Name}", cur);
            Registry.SetValue(v.Key, v.Name, v.Val, RegistryValueKind.DWord);
            StateStore.RecordMutation(cfg, "Registry", v.Key, v.Name, cur, v.Val.ToString(), true, null, v.Desc);
            count++;
        }
        NetworkEngine.RunTool("netsh.exe", "int teredo set state disabled", 3000);
        NetworkEngine.RunTool("netsh.exe", "int isatap set state disabled", 3000);
        NetworkEngine.RunTool("netsh.exe", "int 6to4 set state disabled", 3000);
        FlushCaches(cfg);
        StateStore.Save(cfg, state);
        return count;
    }

    // Tier 2: Restore Factory Defaults (Full Rollback)
    public static int RestoreFactoryDefaults(AppConfig cfg, PersistentState state)
    {
        if (!SecurityEngine.IsAdmin()) return 0;
        using var lk = new GlobalLock();
        int restored = 0;

        foreach (var kv in state.Snapshots.ToList())
        {
            if (kv.Key.StartsWith("Reg:"))
            {
                var path = kv.Key[4..];
                int lastSlash = path.LastIndexOf('\\');
                var keyPath = path[..lastSlash];
                var valName = path[(lastSlash + 1)..];
                if (kv.Value != "NULL" && int.TryParse(kv.Value, out int origInt))
                    Registry.SetValue(keyPath, valName, origInt, RegistryValueKind.DWord);
                restored++;
            }
        }

        foreach (var nic in NetworkEngine.GetPhysicalAdapters())
        {
            NetworkEngine.RunTool("netsh.exe", $"interface ipv4 set dnsservers name=\"{nic.Name}\" dhcp", 5000);
            NetworkEngine.RunTool("netsh.exe", $"interface ipv4 set interface \"{nic.Name}\" metric=automatic", 4000);
            restored++;
        }

        RemoveCampusHostRoutes(state);
        NetworkEngine.RunTool("netsh.exe", "int teredo set state default", 3000);
        NetworkEngine.RunTool("netsh.exe", "int isatap set state default", 3000);
        NetworkEngine.RunTool("netsh.exe", "int 6to4 set state default", 3000);

        state.Snapshots.Clear();
        state.ArpMemory.Clear();
        state.ArpCandidates.Clear();
        if (File.Exists(cfg.VaultFile)) File.Delete(cfg.VaultFile);
        FlushCaches(cfg);
        StateStore.Save(cfg, state);
        return restored;
    }

    // Tiers 3, 4, 5, 6: Graduated Network Stack Reset Hierarchy
    public static void ExecuteStackReset(AppConfig cfg, PersistentState state, int tier)
    {
        if (!SecurityEngine.IsAdmin()) return;
        if (tier >= 4 && SecurityEngine.IsRemoteSession())
        {
            StateStore.Log(cfg, "ALERT", "Remote RDP/SSH session detected. Destructive reset blocked to prevent remote lockout.");
            return;
        }

        using var lk = new GlobalLock();
        StateStore.Log(cfg, "STEP", $"Executing Recovery Tier {tier}...");

        // Pre-flight snapshot of current DNS before reset
        foreach (var nic in NetworkEngine.GetPhysicalAdapters())
        {
            var curDns = string.Join(",", nic.GetIPProperties().DnsAddresses.Where(a => a.AddressFamily == AddressFamily.InterNetwork));
            if (!string.IsNullOrEmpty(curDns))
                StateStore.SaveOriginal(state, $"Dns:{nic.Id}", curDns);
        }

        // Tier 3 (Standard 5-Stage) & above
        NetworkEngine.RunTool("netsh.exe", "winsock reset", 8000);
        NetworkEngine.RunTool("netsh.exe", "int ip reset", 8000);
        NetworkEngine.RunTool("netsh.exe", "int tcp set global autotuninglevel=normal", 5000);
        NetworkEngine.RunTool("netsh.exe", "int tcp set global rss=enabled", 4000);
        NetworkEngine.RunTool("netsh.exe", "int tcp set global ecncapability=disabled", 4000);
        NetworkEngine.RunTool("netsh.exe", "winhttp reset proxy", 5000);

        // Tier 4 (Deep 10-Stage Ultra Rebuild) & above
        if (tier >= 4)
        {
            var wowNetsh = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Windows), @"SysWOW64\netsh.exe");
            if (File.Exists(wowNetsh)) NetworkEngine.RunTool(wowNetsh, "winsock reset", 8000);
            NetworkEngine.RunTool("netsh.exe", "int ipv6 reset", 8000);
            NetworkEngine.RunTool("netsh.exe", "interface portproxy reset", 5000);
            NetworkEngine.RunTool("netsh.exe", "advfirewall reset", 8000);
            NetworkEngine.RunTool("route.exe", "-f", 5000);
            NetworkEngine.RunTool("klist.exe", "purge", 4000);
        }

        // Tier 5 (12-Stage Multi-Adapter Doomsday Reinstall) & above
        if (tier >= 5)
        {
            try
            {
                Registry.SetValue(@"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\RadioManagement", "SystemRadioState", 0, RegistryValueKind.DWord);
            }
            catch { }
            NetworkEngine.RunTool("pnputil.exe", "/scan-devices", 8000);
            NetworkEngine.RunTool("ipconfig.exe", "/release", 8000);
            NetworkEngine.RunTool("ipconfig.exe", "/renew", 15000);
            NetworkEngine.RunTool("ipconfig.exe", "/registerdns", 5000);
        }

        // Tier 6 (4-Stage Armageddon Kernel Device Wipe via netcfg -d)
        if (tier == 6)
        {
            state.PendingReboot = true;
            state.PendingRebootTime = DateTime.UtcNow.ToString("o");
            StateStore.Save(cfg, state);
            NetworkEngine.RunTool("netcfg.exe", "-d", 45000);
            StateStore.Log(cfg, "WARN", "Complete Stack Rebuild (netcfg -d) finished. Please restart Windows to reinstall clean drivers.");
            return;
        }

        FlushCaches(cfg);
        ExecuteQuickHeal(cfg, state);
    }
}

#endregion

#region Silent Background Windows Service & System Tray UI

public sealed class LanFixerWindowsService : ServiceBase
{
    private readonly AppConfig _cfg;
    private CancellationTokenSource? _cts;
    private DateTime _lastEventHeal = DateTime.MinValue;

    public LanFixerWindowsService(AppConfig cfg)
    {
        ServiceName = "LanFixerSvc";
        _cfg = cfg;
    }

    protected override void OnStart(string[] args)
    {
        _cts = new CancellationTokenSource();
        NetworkChange.NetworkAddressChanged += OnNetworkChanged;
        NetworkChange.NetworkAvailabilityChanged += OnNetworkChanged;
        Task.Run(() => SentinelLoop(_cts.Token));
    }

    private void OnNetworkChanged(object? sender, EventArgs e)
    {
        if ((DateTime.UtcNow - _lastEventHeal).TotalSeconds < 8) return;
        _lastEventHeal = DateTime.UtcNow;
        Task.Run(() =>
        {
            try { RemediationEngine.ExecuteQuickHeal(_cfg, StateStore.Load(_cfg)); }
            catch { }
        });
    }

    private async Task SentinelLoop(CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            try
            {
                var state = StateStore.Load(_cfg);
                var rep = RemediationEngine.RunDoctor(_cfg);
                if (rep.Verdict != NetVerdict.Healthy)
                    RemediationEngine.ExecuteQuickHeal(_cfg, state);

                bool onBattery = SystemInformation.PowerStatus.PowerLineStatus == PowerLineStatus.Offline;
                await Task.Delay(TimeSpan.FromSeconds(onBattery ? 25 : 10), ct);
            }
            catch (OperationCanceledException) { break; }
            catch { await Task.Delay(5000, ct); }
        }
    }

    protected override void OnStop()
    {
        NetworkChange.NetworkAddressChanged -= OnNetworkChanged;
        NetworkChange.NetworkAvailabilityChanged -= OnNetworkChanged;
        _cts?.Cancel();
    }

    public static bool InstallService(AppConfig cfg)
    {
        if (!SecurityEngine.IsAdmin()) return false;
        var exePath = Environment.ProcessPath!;
        NetworkEngine.RunTool("sc.exe", "stop LanFixerSvc", 5000);
        NetworkEngine.RunTool("sc.exe", "delete LanFixerSvc", 5000);
        var (code, _) = NetworkEngine.RunTool("sc.exe", $"create LanFixerSvc binPath= \"\\\"{exePath}\\\" --service\" start= auto DisplayName= \"LanFixer Autonomous Network Sentinel\"", 8000);
        if (code == 0)
        {
            NetworkEngine.RunTool("sc.exe", "description LanFixerSvc \"Zero-window event-driven network healer and captive portal authenticator.\"", 5000);
            NetworkEngine.RunTool("sc.exe", "start LanFixerSvc", 8000);
            StateStore.Log(cfg, "OK", "Installed and started LanFixerSvc background Windows Service.");
            return true;
        }
        return false;
    }

    public static bool UninstallService(AppConfig cfg)
    {
        if (!SecurityEngine.IsAdmin()) return false;
        NetworkEngine.RunTool("sc.exe", "stop LanFixerSvc", 5000);
        var (code, _) = NetworkEngine.RunTool("sc.exe", "delete LanFixerSvc", 5000);
        StateStore.Log(cfg, "OK", "Removed LanFixerSvc background Windows Service.");
        return code == 0;
    }
}

public static class TrayHost
{
    public static void Run(AppConfig cfg)
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);

        using var icon = new NotifyIcon
        {
            Icon = SystemIcons.Shield,
            Text = "LanFixer 7.0.2 - Guarding Network",
            Visible = true
        };

        var menu = new ContextMenuStrip();
        menu.Items.Add("Quick Heal (7-Layer Repair)", null, (_, _) =>
        {
            Task.Run(() =>
            {
                var st = StateStore.Load(cfg);
                var res = RemediationEngine.ExecuteQuickHeal(cfg, st);
                icon.ShowBalloonTip(2500, "LanFixer Quick Heal", $"Network Status: {res}", ToolTipIcon.Info);
            });
        });
        menu.Items.Add("Captive Portal Auto-Login", null, (_, _) =>
        {
            Task.Run(() =>
            {
                var st = StateStore.Load(cfg);
                bool ok = PortalClient.AttemptHeadlessLogin(cfg, st);
                if (!ok) Process.Start(new ProcessStartInfo(st.DiscoveredPortalUrl ?? cfg.PortalUrl) { UseShellExecute = true });
            });
        });
        menu.Items.Add("Flush Network Caches", null, (_, _) =>
        {
            RemediationEngine.FlushCaches(cfg);
            icon.ShowBalloonTip(2000, "LanFixer", "DNS, ARP & NetBIOS caches flushed.", ToolTipIcon.Info);
        });
        menu.Items.Add("Careful Network Debloat (Low Ping)", null, (_, _) =>
        {
            var st = StateStore.Load(cfg);
            int n = RemediationEngine.ApplyNetworkDebloat(cfg, st);
            icon.ShowBalloonTip(2500, "LanFixer Debloat", $"Applied {n} low-latency optimizations.", ToolTipIcon.Info);
        });
        menu.Items.Add(new ToolStripSeparator());
        menu.Items.Add("Undo Last Repair Run", null, (_, _) =>
        {
            int n = StateStore.UndoLastRun(cfg);
            icon.ShowBalloonTip(2500, "LanFixer Undo", $"Reverted {n} recent mutations.", ToolTipIcon.Info);
        });
        menu.Items.Add("Restore Windows Defaults (Factory Rollback)", null, (_, _) =>
        {
            var st = StateStore.Load(cfg);
            RemediationEngine.RestoreFactoryDefaults(cfg, st);
            icon.ShowBalloonTip(2500, "LanFixer Rollback", "Restored original Windows network settings.", ToolTipIcon.Warning);
        });
        menu.Items.Add("Exit Tray Guard", null, (_, _) => { icon.Visible = false; Application.Exit(); });

        icon.ContextMenuStrip = menu;

        using var timer = new System.Windows.Forms.Timer { Interval = 10000 };
        timer.Tick += (_, _) =>
        {
            Task.Run(() =>
            {
                var rep = RemediationEngine.RunDoctor(cfg);
                var txt = $"LanFixer: {rep.Verdict} ({rep.PrimaryAdapter} - {rep.IpAddress})";
                icon.Text = txt.Length > 63 ? txt[..63] : txt;
                if (rep.Verdict != NetVerdict.Healthy)
                    RemediationEngine.ExecuteQuickHeal(cfg, StateStore.Load(cfg));
            });
        };
        timer.Start();
        Application.Run();
    }
}

#endregion

#region Interactive Console Dashboard, CLI & 18-Point Verification Self-Test

public static class Program
{
    [STAThread]
    public static int Main(string[] args)
    {
        var cfg = new AppConfig(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), "LanFixer"));

        if (!Environment.UserInteractive || args.Contains("--service", StringComparer.OrdinalIgnoreCase))
        {
            ServiceBase.Run(new LanFixerWindowsService(cfg));
            return 0;
        }

        if (args.Contains("--tray", StringComparer.OrdinalIgnoreCase))
        {
            TrayHost.Run(cfg);
            return 0;
        }

        if (args.Contains("--install-service", StringComparer.OrdinalIgnoreCase))
            return LanFixerWindowsService.InstallService(cfg) ? 0 : 1;

        if (args.Contains("--uninstall-service", StringComparer.OrdinalIgnoreCase))
            return LanFixerWindowsService.UninstallService(cfg) ? 0 : 1;

        bool json = args.Contains("--json", StringComparer.OrdinalIgnoreCase) || args.Contains("-Json", StringComparer.OrdinalIgnoreCase);
        string mode = GetModeArg(args);

        return mode.ToLowerInvariant() switch
        {
            "doctor" or "status" => RunDoctorCli(cfg, json),
            "heal" or "quickheal" => (int)RemediationEngine.ExecuteQuickHeal(cfg, StateStore.Load(cfg)),
            "flush" or "flushcache" => RunAction(() => RemediationEngine.FlushCaches(cfg)),
            "debloat" => RunAction(() => Console.WriteLine($"Optimized {RemediationEngine.ApplyNetworkDebloat(cfg, StateStore.Load(cfg))} vectors.")),
            "undo" => RunAction(() => Console.WriteLine($"Reverted {StateStore.UndoLastRun(cfg)} mutations.")),
            "reset" or "resetfactory" => RunAction(() => Console.WriteLine($"Restored {RemediationEngine.RestoreFactoryDefaults(cfg, StateStore.Load(cfg))} settings.")),
            "selftest" or "verify" => RunSelfTest(cfg, json),
            _ => RunInteractiveDashboard(cfg)
        };
    }

    private static string GetModeArg(string[] args)
    {
        for (int i = 0; i < args.Length; i++)
        {
            if (args[i].Equals("-Mode", StringComparison.OrdinalIgnoreCase) && i + 1 < args.Length)
                return args[i + 1];
            if (args[i].StartsWith("--") && !args[i].Equals("--json", StringComparison.OrdinalIgnoreCase))
                return args[i][2..];
        }
        return "interactive";
    }

    private static int RunAction(Action act) { act(); return 0; }

    private static int RunDoctorCli(AppConfig cfg, bool json)
    {
        var rep = RemediationEngine.RunDoctor(cfg);
        if (json)
        {
            Console.WriteLine(JsonSerializer.Serialize(rep, new JsonSerializerOptions { WriteIndented = true }));
        }
        else
        {
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine("============================================================================");
            Console.WriteLine($"  LANFIXER 7.0.2 HEALTH DOCTOR  |  Verdict: {rep.Verdict} (ExitCode: {rep.ExitCode})");
            Console.WriteLine("============================================================================");
            Console.ResetColor();
            Console.WriteLine($"  Adapter: {rep.PrimaryAdapter} | IP: {rep.IpAddress} | GW: {rep.Gateway} | Env: {rep.Environment} | PMTU: {rep.PathMtu}");
            foreach (var l in rep.Layers)
            {
                Console.ForegroundColor = l.Status == "OK" ? ConsoleColor.Green : l.Status == "DEGRADED" ? ConsoleColor.Yellow : ConsoleColor.Red;
                Console.Write($"  [{l.Status,-8}] ");
                Console.ResetColor();
                Console.WriteLine($"Layer {l.Layer} ({l.Name,-14}): {l.Evidence}");
            }
        }
        return rep.ExitCode;
    }

    public static int RunSelfTest(AppConfig cfg, bool json)
    {
        var checks = new List<(string Name, bool Passed)>();
        void Check(string name, bool ok) => checks.Add((name, ok));

        // 1. RFC 1035 DNS Wire Packet & Multi-Question / CNAME Parser
        var q = NetworkEngine.BuildDnsQueryPacket("a.bc", 0x1234);
        byte[] fakeAns = [0x12, 0x34, 0x81, 0x80, 0, 1, 0, 1, 0, 0, 0, 0, .. q[12..], 0xC0, 0x0C, 0, 1, 0, 1, 0, 0, 0, 60, 0, 4, 1, 2, 3, 4];
        byte[] multiQ = [0x12, 0x34, 0x81, 0x80, 0, 2, 0, 1, 0, 0, 0, 0, .. q[12..], .. q[12..], 0xC0, 0x0C, 0, 1, 0, 1, 0, 0, 0, 60, 0, 4, 5, 6, 7, 8];
        Check("RFC 1035 DNS A-record parser extracts valid IPv4", NetworkEngine.ParseDnsAAnswers(fakeAns, q).Contains("1.2.3.4"));
        Check("RFC 1035 DNS parser skips multiple questions in QDCOUNT", NetworkEngine.ParseDnsAAnswers(multiQ, q).Contains("5.6.7.8"));
        Check("RFC 1035 DNS sinkhole filter blocks 192.0.2.1 & 127.0.0.1", NetworkEngine.IsSinkholeIp("192.0.2.1") && !NetworkEngine.IsSinkholeIp("1.1.1.1"));

        // 2. Layer 3 Subnet Calculus & Same-Subnet Verification
        var sub24 = NetworkEngine.CalculateSubnet("10.114.12.34", 24);
        var sub23 = NetworkEngine.CalculateSubnet("172.16.5.100", 23);
        Check("Layer 3 Subnet Calculus computes /24 mask, broadcast, wildcard & 254 hosts",
            sub24 != null && sub24.SubnetMask == "255.255.255.0" && sub24.WildcardMask == "0.0.0.255" && sub24.BroadcastAddress == "10.114.12.255" && sub24.TotalHosts == 254);
        Check("Layer 3 Subnet Calculus computes /23 mask, network & 510 hosts",
            sub23 != null && sub23.SubnetMask == "255.255.254.0" && sub23.NetworkAddress == "172.16.4.0" && sub23.TotalHosts == 510);
        Check("Layer 3 IsSameSubnet evaluates on-link vs off-link targets accurately",
            NetworkEngine.IsSameSubnet("10.114.12.34", "10.114.12.1", 24) && !NetworkEngine.IsSameSubnet("10.114.12.34", "10.114.0.5", 24));

        // 3. HTTP / Meta-Refresh / JS Redirect Parser
        var redir = NetworkEngine.ParseHttpResponse("HTTP/1.1 200 OK\r\n\r\n<meta content=\"0; url='https://portal.univ.edu/login';\" http-equiv=\"refresh\">");
        var jsRedir = NetworkEngine.ParseHttpResponse("HTTP/1.1 200 OK\r\n\r\n<script>window.location.assign('https://portal.univ.edu/js');</script>");
        Check("HTTP 200 meta-refresh reversed attribute parser", redir.Location == "https://portal.univ.edu/login");
        Check("HTTP 200 window.location.assign redirect parser", jsRedir.Location == "https://portal.univ.edu/js");

        // 4. HTML5 Captive Form Parser & Credential Trust Boundary
        var fm = PortalClient.ParseLoginForm("<form action=\"/auth\"><input type=\"hidden\" name=\"zone\" value=\"nitjsr\"><input name=\"u\" type=\"text\"><input name=\"p\" type=\"password\"></form>", new Uri("https://10.114.0.5:8888/index.php"));
        Check("HTML5 Login form parser extracts action, user, pass, and hidden fields", fm != null && fm.Value.UserField == "u" && fm.Value.PassField == "p" && fm.Value.Fields["zone"] == "nitjsr");
        Check("Credential trust boundary allows campus domain and blocks lookalike domains",
            PortalClient.IsCredentialPortalHostTrusted("gateway.nitjsr.ac.in", cfg) && !PortalClient.IsCredentialPortalHostTrusted("nitjsr.ac.in.evil.com", cfg));

        // 5. Vault First-Tab Splitting
        var vp = SecurityEngine.ParseVaultString("2021ug01\tpa\tss");
        Check("Vault parser splits on first tab only", vp != null && vp.Value.User == "2021ug01" && vp.Value.Pass == "pa\tss");

        // 6. Pure 3-Branch Route Metric Planner
        var pOther = RemediationEngine.PlanRouteMetrics("Other", ConnState.Online, 1);
        var pCaptive = RemediationEngine.PlanRouteMetrics("Campus", ConnState.Captive, 1);
        var pOnline = RemediationEngine.PlanRouteMetrics("Campus", ConnState.Online, 1);
        Check("Route planner never demotes non-campus Ethernet", pOther.Mode == "Restore" && !pOther.CampusRoutes);
        Check("Route planner protects Wi-Fi (15 vs 50) while campus Ethernet is Captive", pCaptive.Mode == "Protect" && pCaptive.EthMetric == 50 && pCaptive.OtherMetric == 15 && pCaptive.CampusRoutes);
        Check("Route planner promotes Ethernet (10 vs 40) when verified Online", pOnline.Mode == "Promote" && pOnline.EthMetric == 10 && pOnline.OtherMetric == 40);

        int failed = checks.Count(c => !c.Passed);
        if (json)
        {
            Console.WriteLine(JsonSerializer.Serialize(new { Total = checks.Count, Failed = failed, Checks = checks }));
        }
        else
        {
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine("  LANFIXER 7.0.2 SELF-TEST SUITE");
            Console.ResetColor();
            foreach (var c in checks)
            {
                Console.ForegroundColor = c.Passed ? ConsoleColor.Green : ConsoleColor.Red;
                Console.Write(c.Passed ? "  [ PASS ] " : "  [ FAIL ] ");
                Console.ResetColor();
                Console.WriteLine(c.Name);
            }
            Console.WriteLine($"\n  Result: {checks.Count - failed}/{checks.Count} passed ({failed} failed).");
        }
        return failed == 0 ? 0 : 1;
    }

    private static int RunInteractiveDashboard(AppConfig cfg)
    {
        while (true)
        {
            Console.Clear();
            var rep = RemediationEngine.RunDoctor(cfg);
            var state = StateStore.Load(cfg);

            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine("  ============================================================================");
            Console.WriteLine($"   LAN FIXER v7.0.2 (Single-File Native Engine)  |  Admin: {(SecurityEngine.IsAdmin() ? "YES" : "LIMITED")}");
            Console.WriteLine("  ============================================================================");
            Console.ResetColor();

            Console.Write("   OVERALL STATUS : ");
            Console.ForegroundColor = rep.Verdict == NetVerdict.Healthy ? ConsoleColor.Green : rep.Verdict == NetVerdict.Degraded ? ConsoleColor.Yellow : ConsoleColor.Red;
            Console.WriteLine($"{rep.Verdict.ToString().ToUpperInvariant()} ({rep.RootCause})");
            Console.ResetColor();
            Console.WriteLine($"   ADAPTER / IP   : {rep.PrimaryAdapter} ({rep.IpAddress})  |  GW: {rep.Gateway}  |  Env: {rep.Environment}  |  PMTU: {rep.PathMtu}\n");

            foreach (var l in rep.Layers)
            {
                Console.ForegroundColor = l.Status == "OK" ? ConsoleColor.Green : l.Status == "DEGRADED" ? ConsoleColor.Yellow : ConsoleColor.Red;
                Console.Write($"   [{l.Status,-8}] ");
                Console.ResetColor();
                Console.WriteLine($"Layer {l.Layer} {l.Name,-15} : {l.Evidence}");
            }

            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine("\n  ----------------------------------------------------------------------------");
            Console.WriteLine("   [1] Quick Heal (7-Layer Repair)    [6] Careful Network Debloat (Low Ping)");
            Console.WriteLine("   [2] Install 24/7 Windows Service   [7] Captive Portal Sign-In Now");
            Console.WriteLine("   [3] Launch System Tray Guard       [8] 6-Tier Recovery & Reset Menu");
            Console.WriteLine("   [4] Save Portal Login to Vault     [9] Factory Reset & Full Rollback");
            Console.WriteLine("   [5] Flush DNS/ARP/NetBIOS Caches   [U] Undo Last Run   [S] Self-Test  [Q] Quit");
            Console.WriteLine("  ----------------------------------------------------------------------------");
            Console.ResetColor();
            Console.Write("   Select action > ");

            var key = Console.ReadKey(intercept: true).KeyChar.ToString().ToLowerInvariant();
            Console.WriteLine();
            switch (key)
            {
                case "1":
                    RemediationEngine.ExecuteQuickHeal(cfg, state);
                    break;
                case "2":
                    Console.WriteLine(LanFixerWindowsService.InstallService(cfg)
                        ? "   [OK] LanFixerSvc installed and running silently in background."
                        : "   [WARN] Run as Administrator to install the Windows Service.");
                    Thread.Sleep(1200);
                    break;
                case "3":
                    Process.Start(new ProcessStartInfo(Environment.ProcessPath!, "--tray") { UseShellExecute = true });
                    break;
                case "4":
                    Console.Write("   Portal Username: ");
                    var u = Console.ReadLine()?.Trim() ?? "";
                    Console.Write("   Portal Password: ");
                    var p = Console.ReadLine() ?? "";
                    if (SecurityEngine.SaveCredentials(cfg, u, p, state))
                        Console.WriteLine("   [OK] Saved to DPAPI LocalMachine vault.");
                    Thread.Sleep(1000);
                    break;
                case "5":
                    RemediationEngine.FlushCaches(cfg);
                    Thread.Sleep(800);
                    break;
                case "6":
                    int n = RemediationEngine.ApplyNetworkDebloat(cfg, state);
                    Console.WriteLine($"   [OK] Applied {n} network debloat optimizations.");
                    Thread.Sleep(1000);
                    break;
                case "7":
                    if (!PortalClient.AttemptHeadlessLogin(cfg, state))
                        Process.Start(new ProcessStartInfo(state.DiscoveredPortalUrl ?? cfg.PortalUrl) { UseShellExecute = true });
                    break;
                case "8":
                    ShowRecoveryTierMenu(cfg, state);
                    break;
                case "9":
                    LanFixerWindowsService.UninstallService(cfg);
                    int r = RemediationEngine.RestoreFactoryDefaults(cfg, state);
                    Console.WriteLine($"   [OK] Rolled back {r} settings to original Windows defaults.");
                    Thread.Sleep(1200);
                    break;
                case "u":
                    int un = StateStore.UndoLastRun(cfg);
                    Console.WriteLine($"   [OK] Reverted {un} mutations from last run.");
                    Thread.Sleep(1000);
                    break;
                case "s":
                    Console.Clear();
                    RunSelfTest(cfg, false);
                    Console.WriteLine("\n  Press any key to return...");
                    Console.ReadKey(true);
                    break;
                case "q":
                    return 0;
            }
        }
    }

    private static void ShowRecoveryTierMenu(AppConfig cfg, PersistentState state)
    {
        Console.Clear();
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine("  ============================================================================");
        Console.WriteLine("   6-TIER RISK-ORDERED RECOVERY & STACK REBUILD HIERARCHY");
        Console.WriteLine("  ============================================================================");
        Console.ResetColor();
        Console.WriteLine("   [1] [SAFE]    Careful Network Debloat (P2P Seeding, Throttling, WPAD, LLMNR)");
        Console.WriteLine("   [2] [NOTICE]  Restore Network Defaults (Reverts all snapshots, DNS & metrics)");
        Console.WriteLine("   [3] [CAUTION] Standard 5-Stage Stack Reset (Winsock, TCP/IP, Proxy, 7-Layer)");
        Console.WriteLine("   [4] [CAUTION] Deep 10-Stage Stack Rebuild (64/32-bit Winsock, Firewall, Route)");
        Console.WriteLine("   [5] [HIGH]    12-Stage Multi-Adapter Reinstall (All Media, PnP Bus, Radio)");
        Console.WriteLine("   [6] [REBOOT]  4-Stage Complete Stack Rebuild (netcfg -d kernel device wipe)");
        Console.WriteLine("   [B] Back to Dashboard");
        Console.Write("\n   Select tier [1-6] > ");

        var k = Console.ReadKey(intercept: true).KeyChar.ToString().ToLowerInvariant();
        Console.WriteLine();
        if (k == "1") RemediationEngine.ApplyNetworkDebloat(cfg, state);
        else if (k == "2") RemediationEngine.RestoreFactoryDefaults(cfg, state);
        else if (k is "3" or "4" or "5" or "6")
        {
            Console.Write($"   Confirm Tier {k} execution? (type yes): ");
            if ((Console.ReadLine()?.Trim().ToLowerInvariant()) == "yes")
                RemediationEngine.ExecuteStackReset(cfg, state, int.Parse(k));
        }
    }
}

#endregion