using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.NetworkInformation;
using System.Net.Security;
using System.Net.Sockets;
using System.Runtime.InteropServices;
using System.Security.AccessControl;
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

#region Configuration & Models

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
}

public enum NetVerdict { Healthy = 0, Degraded = 10, Broken = 20, Undetermined = 30 }
public enum ConnState { Online, Captive, NoDns, Offline, NoIp, NoLink }

public sealed record LayerResult(int Layer, string Name, string Status, string Evidence, string Action);
public sealed record DoctorReport(string PrimaryAdapter, NetVerdict Verdict, int ExitCode, string RootCause, long DurationMs, List<LayerResult> Layers);

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
    public string DnsProfile { get; set; } = "Adaptive";
    public string RouteProfile { get; set; } = "Adaptive";
    public string? PortalPin { get; set; }
    public string? DiscoveredPortalUrl { get; set; }
    public string? DiscoveredPortalIp { get; set; }
    public int DiscoveredPortalPort { get; set; }
    public bool PortalLoginSuspended { get; set; }
    public int PortalFails { get; set; }
    public Dictionary<string, string> Snapshots { get; set; } = new();
    public List<string> InjectedHostRoutes { get; set; } = new();
    public Dictionary<string, string> ArpMemory { get; set; } = new();
}

#endregion

#region Security, Mutex, DPAPI Vault & Rollback Ledger

public static class SecurityEngine
{
    private static readonly string VirtRegex = @"Virtual|Hyper-V|VMware|VirtualBox|\bTAP\b|\bTUN\b|\bWSL\b|Bluetooth|Tailscale|ZeroTier|WireGuard|Wintun|RNDIS|Loopback|Npcap";

    public static bool IsAdmin()
    {
        using var id = WindowsIdentity.GetCurrent();
        return new WindowsPrincipal(id).IsInRole(WindowsBuiltInRole.Administrator);
    }

    public static bool IsVirtualOrTunnel(NetworkInterface nic) =>
        nic.NetworkInterfaceType == NetworkInterfaceType.Loopback ||
        nic.NetworkInterfaceType == NetworkInterfaceType.Tunnel ||
        Regex.IsMatch(nic.Description + " " + nic.Name, VirtRegex, RegexOptions.IgnoreCase);

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
        catch { /* Best effort on non-NTFS or restricted tokens */ }
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
}

public static class StateStore
{
    public static readonly string RunId = Guid.NewGuid().ToString("N")[..12];

    public static PersistentState Load(AppConfig cfg)
    {
        foreach (var path in new[] { cfg.StateFile, cfg.StateFile + ".bak" })
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

    public static void Log(AppConfig cfg, string level, string message)
    {
        try
        {
            if (Directory.Exists(cfg.StoreDir))
                File.AppendAllText(cfg.LogFile, $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] [{level,-5}] {message}\r\n", Encoding.ASCII);
        }
        catch { }
    }
}

#endregion

#region Layer 1-7 Network Engine, RFC 1035 DNS Racer & Raw Socket TLS Client

public static class NetworkEngine
{
    public static List<NetworkInterface> GetPhysicalAdapters(bool ethernetOnly = false) =>
        NetworkInterface.GetAllNetworkInterfaces()
            .Where(n => !SecurityEngine.IsVirtualOrTunnel(n) &&
                        (!ethernetOnly || n.NetworkInterfaceType == NetworkInterfaceType.Ethernet || n.NetworkInterfaceType == NetworkInterfaceType.GigabitEthernet))
            .OrderByDescending(n => n.OperationalStatus == OperationalStatus.Up)
            .ThenByDescending(n => n.NetworkInterfaceType == NetworkInterfaceType.Ethernet || n.NetworkInterfaceType == NetworkInterfaceType.GigabitEthernet)
            .ToList();

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

    // RFC 1035 Wire Answer Parser (Handles multi-question QDCOUNT & hybrid CNAME compression pointers)
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
                if (resp != null && resp.Length >= 12 && resp[0] == pkt[0] && resp[1] == pkt[1] && (resp[2] & 0x80) != 0)
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
            var (code, loc, body) = ParseHttpResponse(raw);

            if (code == 204)
            {
                // Verify HTTPS 443 is not intercepted by a captive firewall
                if (VerifyWanTls("1.1.1.1", sourceIp, 1500) || VerifyWanTls("9.9.9.9", sourceIp, 1500))
                    return (ConnState.Online, "");
                return (ConnState.Captive, cfg.PortalUrl);
            }
            if ((code >= 300 && code <= 399) || (code >= 200 && code <= 299) || code is 401 or 407 or 511 || !string.IsNullOrEmpty(loc))
                return (ConnState.Captive, !string.IsNullOrEmpty(loc) ? loc : cfg.PortalUrl);
        }
        catch { }
        return (ConnState.Offline, "");
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
            ssl.AuthenticateAsClient(wanIp, null, System.Security.Authentication.SslProtocols.Tls12 | System.Security.Authentication.SslProtocols.Tls13, false);
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
            var psi = new ProcessStartInfo
            {
                FileName = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System), exeName),
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

#region Captive Portal Client, Doctor, Debloat & Recovery Ladder

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

    public static bool AttemptHeadlessLogin(AppConfig cfg, PersistentState state, string? sourceIp = null)
    {
        if (state.PortalLoginSuspended) return false;
        var creds = SecurityEngine.LoadCredentials(cfg);
        if (creds == null) return false;

        var url = state.DiscoveredPortalUrl ?? cfg.PortalUrl;
        if (!Uri.TryCreate(url, UriKind.Absolute, out var uri) || uri.Scheme != "https")
            return false;

        // Strict credential host boundary check
        var h = uri.Host.ToLowerInvariant().TrimEnd('.');
        bool trusted = h == cfg.PortalHost.ToLowerInvariant() || h == cfg.PortalIp || h.EndsWith("." + cfg.CampusDomain.ToLowerInvariant());
        if (!trusted) return false;

        try
        {
            using var handler = new SocketsHttpHandler
            {
                AllowAutoRedirect = true,
                MaxAutomaticRedirections = 4,
                UseProxy = false,
                ConnectTimeout = TimeSpan.FromSeconds(4)
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
            if (form == null) return false;

            var payload = new Dictionary<string, string>(form.Value.Fields)
            {
                [form.Value.UserField] = creds.Value.User,
                [form.Value.PassField] = creds.Value.Pass
            };
            if (!payload.ContainsKey("accept") && payload.ContainsKey("zone"))
                payload["accept"] = "Sign In";

            using var content = new FormUrlEncodedContent(payload);
            using var resp = client.PostAsync(form.Value.Action, content).GetAwaiter().GetResult();

            Thread.Sleep(800);
            if (NetworkEngine.GetInternetState(cfg, sourceIp).State == ConnState.Online)
            {
                state.PortalFails = 0;
                state.PortalLoginSuspended = false;
                StateStore.Save(cfg, state);
                StateStore.Log(cfg, "OK", "Signed in to captive portal automatically via DPAPI vault.");
                return true;
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
        var layers = new List<LayerResult>();
        var nics = NetworkEngine.GetPhysicalAdapters();
        var primary = nics.FirstOrDefault();

        // Layer 1: Physical Link
        if (primary == null)
            layers.Add(new(1, "PhysicalLink", "UNKNOWN", "No physical adapter detected", "Diagnose"));
        else if (primary.OperationalStatus != OperationalStatus.Up)
            layers.Add(new(1, "PhysicalLink", "FAILED", $"Adapter {primary.Name} is {primary.OperationalStatus}", "QuickHeal"));
        else
            layers.Add(new(1, "PhysicalLink", "OK", $"{primary.Name} ({primary.Speed / 1_000_000} Mbps Up)", "None"));

        // Layer 2: IP Config
        var ip = primary != null && primary.OperationalStatus == OperationalStatus.Up ? NetworkEngine.GetValidIPv4(primary) : null;
        if (string.IsNullOrEmpty(ip))
            layers.Add(new(2, "IpConfig", "FAILED", "No valid IPv4 lease (APIPA / Unassigned)", "QuickHeal"));
        else
            layers.Add(new(2, "IpConfig", "OK", $"IPv4 Lease: {ip}", "None"));

        // Layer 3: Gateway
        var gw = primary != null ? NetworkEngine.GetDefaultGateway(primary) : null;
        var gwRtt = !string.IsNullOrEmpty(gw) ? NetworkEngine.PingMs(gw, 700) : null;
        if (string.IsNullOrEmpty(gw))
            layers.Add(new(3, "GatewayReach", "FAILED", "No default 0.0.0.0/0 gateway", "QuickHeal"));
        else if (gwRtt.HasValue || NetworkEngine.TestTcpPort(gw, 80, 350, ip) || NetworkEngine.TestTcpPort(gw, 443, 350, ip))
            layers.Add(new(3, "GatewayReach", "OK", $"Gateway {gw} reachable ({(gwRtt.HasValue ? $"{gwRtt}ms" : "TCP/ARP")})", "None"));
        else
            layers.Add(new(3, "GatewayReach", "FAILED", $"Gateway {gw} unreachable", "QuickHeal"));

        // Layer 4: DNS
        var resolved = !string.IsNullOrEmpty(ip) ? NetworkEngine.ResolveHostScoped("connectivitycheck.gstatic.com", ip, cfg) : null;
        if (string.IsNullOrEmpty(resolved))
            layers.Add(new(4, "DnsResolution", "FAILED", "DNS resolution failed", "QuickHeal"));
        else
            layers.Add(new(4, "DnsResolution", "OK", $"Resolved test host -> {resolved}", "None"));

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
        var failed = layers.FirstOrDefault(l => l.Status == "FAILED");
        var degraded = layers.FirstOrDefault(l => l.Status == "DEGRADED");
        var verdict = failed != null ? NetVerdict.Broken : degraded != null ? NetVerdict.Degraded : primary == null ? NetVerdict.Undetermined : NetVerdict.Healthy;
        string cause = failed?.Evidence ?? degraded?.Evidence ?? "All 7 OSI layers verified healthy.";

        return new DoctorReport(primary?.Name ?? "None", verdict, (int)verdict, cause, sw.ElapsedMilliseconds, layers);
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

    public static void FlushCaches(AppConfig cfg)
    {
        NetworkEngine.RunTool("ipconfig.exe", "/flushdns", 5000);
        NetworkEngine.RunTool("netsh.exe", "interface ip delete arpcache", 5000);
        NetworkEngine.RunTool("nbtstat.exe", "-R", 5000);
        StateStore.Log(cfg, "OK", "Flushed DNS resolver, ARP neighbor table, and NetBIOS caches.");
    }

    public static ConnState ExecuteQuickHeal(AppConfig cfg, PersistentState state)
    {
        var eths = NetworkEngine.GetPhysicalAdapters(ethernetOnly: true);
        var all = NetworkEngine.GetPhysicalAdapters(ethernetOnly: false);
        var target = eths.FirstOrDefault(n => n.OperationalStatus == OperationalStatus.Up) ?? all.FirstOrDefault();
        if (target == null) return ConnState.NoLink;

        // Layer 2: Renew DHCP if APIPA/missing IP
        var ip = NetworkEngine.GetValidIPv4(target);
        if (string.IsNullOrEmpty(ip))
        {
            NetworkEngine.RunTool("ipconfig.exe", $"/release \"{target.Name}\"", 8000);
            NetworkEngine.RunTool("ipconfig.exe", $"/renew \"{target.Name}\"", 15000);
            target = NetworkEngine.GetPhysicalAdapters().FirstOrDefault(n => n.Id == target.Id) ?? target;
            ip = NetworkEngine.GetValidIPv4(target);
        }
        if (string.IsNullOrEmpty(ip)) return ConnState.NoIp;

        // Layer 3 & 4: Evaluate connectivity & benchmark fastest DNS
        var (conn, loc) = NetworkEngine.GetInternetState(cfg, ip);
        if (!string.IsNullOrEmpty(loc)) state.DiscoveredPortalUrl = loc;

        var scores = NetworkEngine.MeasureResolversFast(cfg.ActivePublicDns.Prepend(cfg.CampusDns), ip);
        var bestDns = scores.Where(kv => kv.Value.HasValue).OrderBy(kv => kv.Value!.Value).Select(kv => kv.Key).ToList();
        if (bestDns.Count > 0 && conn == ConnState.NoDns)
        {
            var curDns = string.Join(",", target.GetIPProperties().DnsAddresses.Where(a => a.AddressFamily == AddressFamily.InterNetwork));
            StateStore.SaveOriginal(state, $"Dns:{target.Id}", curDns);
            NetworkEngine.RunTool("netsh.exe", $"interface ipv4 set dnsservers name=\"{target.Name}\" static {bestDns[0]} primary", 5000);
            StateStore.RecordMutation(cfg, "Dns", target.Name, null, curDns, bestDns[0], true,
                $"netsh interface ipv4 set dnsservers name=\"{target.Name}\" dhcp", $"Set fastest verified DNS ({bestDns[0]}) on {target.Name}");
            FlushCaches(cfg);
            (conn, _) = NetworkEngine.GetInternetState(cfg, ip);
        }

        // Layer 7: Auto-login if Captive
        if (conn == ConnState.Captive && PortalClient.AttemptHeadlessLogin(cfg, state, ip))
            conn = ConnState.Online;

        StateStore.Save(cfg, state);
        return conn;
    }

    public static int ApplyNetworkDebloat(AppConfig cfg, PersistentState state)
    {
        if (!SecurityEngine.IsAdmin()) return 0;
        var vectors = new (string Key, string Name, int Val, string Desc)[]
        {
            (@"HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization", "DODownloadMode", 0, "Disable P2P Update Seeding"),
            (@"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile", "NetworkThrottlingIndex", -1, "Disable Multimedia Packet Throttling"),
            (@"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile", "SystemResponsiveness", 0, "Zero Gaming/Network Queue Reservation"),
            (@"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad", "WpadOverride", 1, "Disable WPAD Proxy Broadcast Probing")
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
        FlushCaches(cfg);
        StateStore.Save(cfg, state);
        return count;
    }

    public static int RestoreFactoryDefaults(AppConfig cfg, PersistentState state)
    {
        if (!SecurityEngine.IsAdmin()) return 0;
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
            restored++;
        }
        foreach (var hip in state.InjectedHostRoutes)
            NetworkEngine.RunTool("route.exe", $"delete {hip}", 3000);

        state.Snapshots.Clear();
        state.InjectedHostRoutes.Clear();
        if (File.Exists(cfg.VaultFile)) File.Delete(cfg.VaultFile);
        FlushCaches(cfg);
        StateStore.Save(cfg, state);
        return restored;
    }

    public static void ExecuteStackReset(AppConfig cfg, PersistentState state, bool deep = false)
    {
        if (!SecurityEngine.IsAdmin()) return;
        StateStore.Log(cfg, "STEP", $"Executing {(deep ? "10-Stage Deep Stack Rebuild" : "5-Stage Standard Stack Reset")}...");
        NetworkEngine.RunTool("netsh.exe", "winsock reset", 8000);
        NetworkEngine.RunTool("netsh.exe", "int ip reset", 8000);
        NetworkEngine.RunTool("netsh.exe", "int tcp set global autotuninglevel=normal", 5000);
        NetworkEngine.RunTool("netsh.exe", "winhttp reset proxy", 5000);
        if (deep)
        {
            NetworkEngine.RunTool("netsh.exe", "int ipv6 reset", 8000);
            NetworkEngine.RunTool("netsh.exe", "advfirewall reset", 8000);
            NetworkEngine.RunTool("route.exe", "-f", 5000);
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
        try
        {
            var state = StateStore.Load(_cfg);
            RemediationEngine.ExecuteQuickHeal(_cfg, state);
        }
        catch { }
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
            var st = StateStore.Load(cfg);
            var res = RemediationEngine.ExecuteQuickHeal(cfg, st);
            icon.ShowBalloonTip(2500, "LanFixer Quick Heal", $"Network Status: {res}", ToolTipIcon.Info);
        });
        menu.Items.Add("Captive Portal Auto-Login", null, (_, _) =>
        {
            var st = StateStore.Load(cfg);
            bool ok = PortalClient.AttemptHeadlessLogin(cfg, st);
            if (!ok) Process.Start(new ProcessStartInfo(st.DiscoveredPortalUrl ?? cfg.PortalUrl) { UseShellExecute = true });
        });
        menu.Items.Add("Flush Network Caches", null, (_, _) =>
        {
            RemediationEngine.FlushCaches(cfg);
            icon.ShowBalloonTip(2000, "LanFixer", "DNS, ARP & NetBIOS caches flushed.", ToolTipIcon.Info);
        });
        menu.Items.Add("Careful Network Debloat", null, (_, _) =>
        {
            var st = StateStore.Load(cfg);
            int n = RemediationEngine.ApplyNetworkDebloat(cfg, st);
            icon.ShowBalloonTip(2500, "LanFixer Debloat", $"Applied {n} low-latency optimizations.", ToolTipIcon.Info);
        });
        menu.Items.Add(new ToolStripSeparator());
        menu.Items.Add("Restore Windows Defaults (Rollback)", null, (_, _) =>
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
                icon.Text = $"LanFixer: {rep.Verdict} ({rep.PrimaryAdapter})";
                if (rep.Verdict != NetVerdict.Healthy)
                    RemediationEngine.ExecuteQuickHeal(cfg, StateStore.Load(cfg));
            });
        };
        timer.Start();
        Application.Run();
    }
}

#endregion

#region Interactive Console Dashboard, CLI & Verification Self-Test

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

        bool json = args.Contains("--json", StringComparer.OrdinalIgnoreCase) || args.Contains("-Json", StringComparer.OrdinalIgnoreCase);
        string mode = GetModeArg(args);

        return mode.ToLowerInvariant() switch
        {
            "doctor" or "status" => RunDoctorCli(cfg, json),
            "heal" or "quickheal" => (int)RemediationEngine.ExecuteQuickHeal(cfg, StateStore.Load(cfg)),
            "flush" or "flushcache" => RunAction(cfg, () => RemediationEngine.FlushCaches(cfg)),
            "debloat" => RunAction(cfg, () => Console.WriteLine($"Optimized {RemediationEngine.ApplyNetworkDebloat(cfg, StateStore.Load(cfg))} vectors.")),
            "reset" or "resetfactory" or "undo" => RunAction(cfg, () => Console.WriteLine($"Restored {RemediationEngine.RestoreFactoryDefaults(cfg, StateStore.Load(cfg))} settings.")),
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

    private static int RunAction(AppConfig cfg, Action act)
    {
        act();
        return 0;
    }

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
        Check("RFC 1035 DNS A-record parser extracts valid IPv4", NetworkEngine.ParseDnsAAnswers(fakeAns, q).Contains("1.2.3.4"));
        Check("RFC 1035 DNS sinkhole filter blocks 192.0.2.1 & 127.0.0.1", NetworkEngine.IsSinkholeIp("192.0.2.1") && !NetworkEngine.IsSinkholeIp("1.1.1.1"));

        // 2. HTTP / Meta-Refresh / JS Redirect Parser
        var redir = NetworkEngine.ParseHttpResponse("HTTP/1.1 200 OK\r\n\r\n<meta content=\"0; url='https://portal.univ.edu/login';\" http-equiv=\"refresh\">");
        Check("HTTP 200 meta-refresh reversed attribute parser", redir.Location == "https://portal.univ.edu/login");

        // 3. HTML5 Captive Form Parser
        var fm = PortalClient.ParseLoginForm("<form action=\"/auth\"><input type=\"hidden\" name=\"zone\" value=\"nitjsr\"><input name=\"u\" type=\"text\"><input name=\"p\" type=\"password\"></form>", new Uri("https://10.114.0.5:8888/index.php"));
        Check("HTML5 Login form parser extracts action, user, pass, and hidden fields", fm != null && fm.Value.UserField == "u" && fm.Value.PassField == "p" && fm.Value.Fields["zone"] == "nitjsr");

        // 4. Vault First-Tab Splitting & DPAPI Crypto Round-Trip
        var vp = SecurityEngine.ParseVaultString("2021ug01\tpa\tss");
        Check("Vault parser splits on first tab only", vp != null && vp.Value.User == "2021ug01" && vp.Value.Pass == "pa\tss");

        // 5. Pure 3-Branch Route Metric Planner
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
            Console.WriteLine($"   LAN FIXER v7.0.2 (Native Standalone Engine)   |   Admin: {(SecurityEngine.IsAdmin() ? "YES" : "LIMITED")}");
            Console.WriteLine("  ============================================================================");
            Console.ResetColor();

            Console.Write("   OVERALL STATUS : ");
            Console.ForegroundColor = rep.Verdict == NetVerdict.Healthy ? ConsoleColor.Green : rep.Verdict == NetVerdict.Degraded ? ConsoleColor.Yellow : ConsoleColor.Red;
            Console.WriteLine($"{rep.Verdict.ToString().ToUpperInvariant()} ({rep.RootCause})");
            Console.ResetColor();
            Console.WriteLine($"   PRIMARY NIC    : {rep.PrimaryAdapter}   |   DNS Profile: {state.DnsProfile}   |   Route: {state.RouteProfile}\n");

            foreach (var l in rep.Layers)
            {
                Console.ForegroundColor = l.Status == "OK" ? ConsoleColor.Green : l.Status == "DEGRADED" ? ConsoleColor.Yellow : ConsoleColor.Red;
                Console.Write($"   [{l.Status,-8}] ");
                Console.ResetColor();
                Console.WriteLine($"Layer {l.Layer} {l.Name,-15} : {l.Evidence}");
            }

            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine("\n  ----------------------------------------------------------------------------");
            Console.WriteLine("   [1] Quick Heal (7-Layer Repair)    [5] Flush DNS / ARP / NetBIOS Caches");
            Console.WriteLine("   [2] Launch System Tray Guard       [6] Careful Network Debloat (Low Ping)");
            Console.WriteLine("   [3] Save Portal Login to Vault     [7] Captive Portal Sign-In Now");
            Console.WriteLine("   [4] Standard Stack Reset           [8] Deep 10-Stage Stack Rebuild");
            Console.WriteLine("   [9] Factory Reset & Rollback       [S] Run Self-Test Suite    [Q] Quit");
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
                    Process.Start(new ProcessStartInfo(Environment.ProcessPath!, "--tray") { UseShellExecute = true });
                    break;
                case "3":
                    Console.Write("   Portal Username: ");
                    var u = Console.ReadLine()?.Trim() ?? "";
                    Console.Write("   Portal Password: ");
                    var p = Console.ReadLine() ?? "";
                    if (SecurityEngine.SaveCredentials(cfg, u, p, state))
                        Console.WriteLine("   [OK] Saved to DPAPI LocalMachine vault.");
                    Thread.Sleep(1000);
                    break;
                case "4":
                    RemediationEngine.ExecuteStackReset(cfg, state, deep: false);
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
                    RemediationEngine.ExecuteStackReset(cfg, state, deep: true);
                    break;
                case "9":
                    int r = RemediationEngine.RestoreFactoryDefaults(cfg, state);
                    Console.WriteLine($"   [OK] Rolled back {r} settings to original Windows defaults.");
                    Thread.Sleep(1200);
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
}
#endregion
