using System.Diagnostics;
using System.Net;
using System.Net.NetworkInformation;
using System.Net.Sockets;
using System.Text;
using Microsoft.Win32;

namespace LanFixer;

public enum St { Online, Captive, NoDns, Offline, NoLink }
public record Pr(int Code, string Body, string Loc, string Err);
public record Link(string Name, string Id, string Ip, string Gw, bool Wifi, int Metric = 0);

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

public static class Net
{
    private static HttpClient? _c;
    private static string _bind = "?";

    /// <summary>
    /// HTTP probe client: no proxy, no redirects, optionally bound to one adapter's IPv4
    /// so a secondary uplink (e.g. Wi-Fi) cannot answer for Ethernet.
    /// </summary>
    public static HttpClient Client(string? bindIp = null, string? pin = null, bool cookies = false)
    {
        if (pin == null && !cookies && _c != null && _bind == (bindIp ?? ""))
            return _c;

        var h = new SocketsHttpHandler
        {
            AllowAutoRedirect = false,
            UseProxy = false,
            UseCookies = cookies,
            ConnectTimeout = TimeSpan.FromSeconds(3)
        };

        if (pin != null)
        {
            h.SslOptions.RemoteCertificateValidationCallback = (_, cert, _, err) =>
                err == System.Net.Security.SslPolicyErrors.None || (cert != null && Pinned(cert.GetRawCertData(), pin));
        }

        if (bindIp != null && IPAddress.TryParse(bindIp, out var ip))
        {
            h.ConnectCallback = async (ctx, ct) =>
            {
                var s = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp) { NoDelay = true };
                try
                {
                    s.Bind(new IPEndPoint(ip, 0));
                    await s.ConnectAsync(ctx.DnsEndPoint, ct);
                    return new NetworkStream(s, true);
                }
                catch
                {
                    s.Dispose();
                    throw;
                }
            };
        }

        var c = new HttpClient(h) { Timeout = TimeSpan.FromSeconds(6), MaxResponseContentBufferSize = 1 << 20 };
        if (pin != null || cookies) return c;
        _c?.Dispose();
        _bind = bindIp ?? "";
        return _c = c;
    }

    public static bool Pinned(byte[] raw, string pin) =>
        Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(raw))
            .Equals(pin.Replace(":", ""), StringComparison.OrdinalIgnoreCase);

    public static async Task<Pr> Get(HttpClient c, string url, CancellationToken ct)
    {
        try
        {
            using var r = await c.GetAsync(url, HttpCompletionOption.ResponseHeadersRead, ct);
            var body = await r.Content.ReadAsStringAsync(ct);
            var loc = r.Headers.Location is { } l ? new Uri(new Uri(url), l).ToString() : "";
            if (loc == "" && (int)r.StatusCode == 200)
                loc = Portal.Redirect(body, new Uri(url)) ?? "";
            return new((int)r.StatusCode, body, loc, "");
        }
        catch (HttpRequestException e) when (e.HttpRequestError == HttpRequestError.NameResolutionError)
        {
            return new(0, "", "", "dns");
        }
        catch (HttpRequestException e) when (e.HttpRequestError == HttpRequestError.SecureConnectionError)
        {
            return new(0, "", "", "tls");
        }
        catch (TaskCanceledException)
        {
            return new(0, "", "", "timeout");
        }
        catch
        {
            return new(0, "", "", "x");
        }
    }

    public static St Verdict(Pr a, Pr b)
    {
        if (a.Code == 204 || (b.Code == 200 && b.Body.StartsWith("Microsoft Connect Test")))
            return St.Online;
        if (a.Err == "dns" && b.Err == "dns")
            return St.NoDns;
        foreach (var p in new[] { a, b })
        {
            if (p.Code is >= 200 and <= 399 or 401 or 407 or 511 || p.Loc != "")
                return St.Captive;
        }
        return St.Offline;
    }

    /// <summary>
    /// Dual-verification Probe: checks HTTP 204, HTTPS 204, active portal demand, and genuine WAN TLS.
    /// </summary>
    public static async Task<(St s, string loc, int ms)> Probe(string? bind, CancellationToken ct)
    {
        var c = Client(bind);
        var sw = Stopwatch.StartNew();
        var a = await Get(c, "http://connectivitycheck.gstatic.com/generate_204", ct);
        int ms = (int)sw.ElapsedMilliseconds;
        var b = a.Code == 204 ? new Pr(0, "", "", "") : await Get(c, "http://www.msftconnecttest.com/connecttest.txt", ct);
        var s = Verdict(a, b);

        string activeLoc = a.Loc != "" ? a.Loc : b.Loc;

        // If HTTP 204 passed, cross-verify with HTTPS and active portal demand
        if (s == St.Online)
        {
            var cred = Vault.Load();
            string portalUrl = !string.IsNullOrEmpty(activeLoc)
                ? activeLoc
                : (cred != null && !string.IsNullOrEmpty(cred.H) ? $"https://{cred.H}:{cred.Port}/" : "https://10.114.0.5:8888/");

            // 1. If portal actively serves a login form with password field, we are definitely Captive
            if (Portal.IsDemandingAuth(portalUrl, bind, 1200))
            {
                return (St.Captive, portalUrl, ms);
            }

            // 2. Test HTTPS probe: if TLS is intercepted or connection is dropped by firewall, mark Captive
            var httpsProbe = await Get(c, "https://connectivitycheck.gstatic.com/generate_204", ct);
            if (httpsProbe.Err is "tls" or "x" or "timeout" && httpsProbe.Code != 204)
            {
                // If outbound HTTPS to WAN is dropped/intercepted, verify if public WAN HTTPS works
                if (!VerifyWanTls("1.1.1.1", bind, 1500) && !VerifyWanTls("9.9.9.9", bind, 1500))
                    s = St.Captive;
            }
        }

        return (s, activeLoc, ms);
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
            using var ssl = new System.Net.Security.SslStream(ns, false, (_, _, _, errs) => errs == System.Net.Security.SslPolicyErrors.None);
            ssl.AuthenticateAsClient(wanIp);
            return ssl.IsAuthenticated;
        }
        catch { return false; }
    }

    public static async Task<int> Rtt(string ip, int ms = 1000)
    {
        try
        {
            using var p = new Ping();
            var r = await p.SendPingAsync(ip, ms);
            return r.Status == IPStatus.Success ? (int)r.RoundtripTime : -1;
        }
        catch { return -1; }
    }

    public static IEnumerable<NetworkInterface> Up() =>
        NetworkInterface.GetAllNetworkInterfaces().Where(n =>
            n.OperationalStatus == OperationalStatus.Up &&
            n.NetworkInterfaceType is NetworkInterfaceType.Ethernet or NetworkInterfaceType.GigabitEthernet or NetworkInterfaceType.Wireless80211 &&
            !n.Description.Contains("Virtual", StringComparison.OrdinalIgnoreCase) &&
            !n.Description.Contains("VPN", StringComparison.OrdinalIgnoreCase) &&
            !n.Description.Contains("Bluetooth", StringComparison.OrdinalIgnoreCase) &&
            !n.Description.Contains("Loopback", StringComparison.OrdinalIgnoreCase));

    public static Link? Primary()
    {
        Link? best = null;
        foreach (var n in Up().OrderBy(n => n.NetworkInterfaceType == NetworkInterfaceType.Wireless80211))
        {
            var p = n.GetIPProperties();
            var ip = p.UnicastAddresses.FirstOrDefault(u => u.Address.AddressFamily == AddressFamily.InterNetwork)?.Address.ToString() ?? "";
            var gw = p.GatewayAddresses.FirstOrDefault(g => g.Address.AddressFamily == AddressFamily.InterNetwork && !g.Address.Equals(IPAddress.Any))?.Address.ToString() ?? "";
            var l = new Link(n.Name, n.Id, ip, gw, n.NetworkInterfaceType == NetworkInterfaceType.Wireless80211);
            if (ip != "" && gw != "" && !ip.StartsWith("169.254.")) return l;
            best ??= l;
        }
        return best;
    }

    public static List<Link> AllActiveLinks() =>
        Up().Select(n =>
        {
            var p = n.GetIPProperties();
            var ip = p.UnicastAddresses.FirstOrDefault(u => u.Address.AddressFamily == AddressFamily.InterNetwork)?.Address.ToString() ?? "";
            var gw = p.GatewayAddresses.FirstOrDefault(g => g.Address.AddressFamily == AddressFamily.InterNetwork && !g.Address.Equals(IPAddress.Any))?.Address.ToString() ?? "";
            return new Link(n.Name, n.Id, ip, gw, n.NetworkInterfaceType == NetworkInterfaceType.Wireless80211);
        }).ToList();

    public static bool IsApipa(string? ip) => string.IsNullOrWhiteSpace(ip) || ip.StartsWith("169.254.");

    public static Link? GetEthernetLink() =>
        AllActiveLinks().FirstOrDefault(l => !l.Wifi);

    public static string Fingerprint(Link? l) => l == null ? "" : l.Id + "|" + l.Gw;

    #region Dynamic Route Metric Shield (Ethernet vs Wi-Fi)

    /// <summary>
    /// When Ethernet is Captive, sets its interface metric to 50 and Wi-Fi to 15 so Windows
    /// pushes system traffic out of the working Wi-Fi connection. When Online, promotes Ethernet to 10.
    /// </summary>
    public static void ApplyRouteShield(Store store, Link? primary, St state)
    {
        if (primary == null || !P.Admin()) return;
        var links = AllActiveLinks();
        var eth = links.FirstOrDefault(l => !l.Wifi && l.Ip != "");
        var wifi = links.FirstOrDefault(l => l.Wifi && l.Ip != "");

        if (eth == null || wifi == null) return;

        var run = store.Begin("route-shield");
        try
        {
            if (state == St.Captive)
            {
                // Demote captive Ethernet so system uses working Wi-Fi
                store.Change(run, "metric", eth.Id, "", "50");
                store.Change(run, "metric", wifi.Id, "", "15");
                Log.W($"Route shield active: Demoted {eth.Name} (50), elevated {wifi.Name} (15)");
            }
            else if (state == St.Online)
            {
                // Promote verified Ethernet as primary uplink
                store.Change(run, "metric", eth.Id, "", "10");
                store.Change(run, "metric", wifi.Id, "", "auto");
                Log.W($"Route shield restored: Elevated {eth.Name} (10), set {wifi.Name} (auto)");
            }
        }
        finally
        {
            store.End(run);
        }
    }

    #endregion

    #region Subnet Calculus & Path MTU Discovery

    public static SubnetInfo? CalculateSubnet(string ipStr, int prefixLen)
    {
        if (!IPAddress.TryParse(ipStr, out var ip) || prefixLen < 1 || prefixLen > 32)
            return null;

        var ipBytes = ip.GetAddressBytes();
        uint ipInt = (uint)((ipBytes[0] << 24) | (ipBytes[1] << 16) | (ipBytes[2] << 8) | ipBytes[3]);
        uint maskInt = prefixLen == 0 ? 0 : 0xFFFFFFFF << (32 - prefixLen);
        uint wildInt = ~maskInt;
        uint netInt = ipInt & maskInt;
        uint bcastInt = netInt | wildInt;

        string ToIp(uint val) => $"{val >> 24}.{(val >> 16) & 0xFF}.{(val >> 8) & 0xFF}.{val & 0xFF}";

        long totalHosts = prefixLen >= 31 ? (prefixLen == 31 ? 2 : 1) : (1L << (32 - prefixLen)) - 2;
        string minHost = prefixLen >= 31 ? ToIp(netInt) : ToIp(netInt + 1);
        string maxHost = prefixLen >= 31 ? ToIp(bcastInt) : ToIp(bcastInt - 1);

        return new SubnetInfo(
            ipStr, prefixLen, ToIp(maskInt), ToIp(wildInt),
            ToIp(netInt), ToIp(bcastInt), minHost, maxHost, totalHosts);
    }

    public static bool IsSameSubnet(string ip1, string ip2, int prefixLen)
    {
        if (!IPAddress.TryParse(ip1, out var a) || !IPAddress.TryParse(ip2, out var b)) return false;
        var ab = a.GetAddressBytes(); var bb = b.GetAddressBytes();
        uint ai = (uint)((ab[0] << 24) | (ab[1] << 16) | (ab[2] << 8) | ab[3]);
        uint bi = (uint)((bb[0] << 24) | (bb[1] << 16) | (bb[2] << 8) | bb[3]);
        uint mask = prefixLen == 0 ? 0 : 0xFFFFFFFF << (32 - prefixLen);
        return (ai & mask) == (bi & mask);
    }

    public static int DiscoverPathMtu(string targetIp, int timeoutMs = 1000)
    {
        int[] probes = [1500, 1492, 1420, 1280];
        foreach (var mtu in probes)
        {
            try
            {
                using var ping = new Ping();
                var opt = new PingOptions(64, dontFragment: true);
                var buf = new byte[mtu - 28]; // ICMP payload = MTU - 20 (IP) - 8 (ICMP)
                var reply = ping.Send(targetIp, timeoutMs, buf, opt);
                if (reply.Status == IPStatus.Success) return mtu;
            }
            catch { }
        }
        return 1500; // Standard fallback
    }

    #endregion
}

public static class Dns
{
    public static readonly string[] Public = { "1.1.1.1", "8.8.8.8", "9.9.9.9", "1.0.0.1", "8.8.4.4", "149.112.112.112" };

    public static byte[] Query(ushort id, string qname = "example.com")
    {
        var l = new List<byte> { (byte)(id >> 8), (byte)id, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0 };
        foreach (var s in qname.Split('.'))
        {
            l.Add((byte)s.Length);
            l.AddRange(Encoding.ASCII.GetBytes(s));
        }
        l.AddRange(new byte[] { 0, 0, 1, 0, 1 }); // QTYPE A (1), QCLASS IN (1)
        return l.ToArray();
    }

    public static bool Valid(byte[] q, byte[] r) =>
        r.Length >= 12 && r[0] == q[0] && r[1] == q[1] && (r[2] & 0x80) != 0 && (r[3] & 15) == 0 && ((r[6] << 8) | r[7]) > 0;

    public static async Task<int> Ms(string server, CancellationToken ct)
    {
        if (!IPAddress.TryParse(server, out var ip)) return -1;
        try
        {
            using var u = new UdpClient(ip.AddressFamily);
            var q = Query((ushort)Random.Shared.Next(65536));
            var sw = Stopwatch.StartNew();
            await u.SendAsync(q, new IPEndPoint(ip, 53), ct);
            using var t = CancellationTokenSource.CreateLinkedTokenSource(ct);
            t.CancelAfter(1200);
            var r = await u.ReceiveAsync(t.Token);
            return Valid(q, r.Buffer) ? (int)sw.ElapsedMilliseconds : -1;
        }
        catch { return -1; }
    }

    public static async Task<List<(string ip, int ms)>> Rank(IEnumerable<string> s, CancellationToken ct)
    {
        var l = s.Distinct().ToArray();
        var r = await Task.WhenAll(l.Select(x => Ms(x, ct)));
        return l.Zip(r, (a, b) => (a, b)).Where(x => x.b >= 0).OrderBy(x => x.b).ToList();
    }

    private static IEnumerable<string> Reg(string id, string v) =>
        (Registry.LocalMachine.OpenSubKey(@"SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\" + id)?.GetValue(v) as string ?? "")
        .Split(new[] { ',', ' ' }, StringSplitOptions.RemoveEmptyEntries);

    public static IEnumerable<string> Dhcp(string id) => Reg(id, "DhcpNameServer");

    public static IEnumerable<string> Current(string id) =>
        NetworkInterface.GetAllNetworkInterfaces().FirstOrDefault(n => n.Id == id)?.GetIPProperties().DnsAddresses
            .Where(a => a.AddressFamily == AddressFamily.InterNetwork)
            .Select(a => a.ToString()) ?? Enumerable.Empty<string>();
}

#region Path MTU Black-Hole Discovery

public sealed record MtuResult(int TestedMtu, bool Success, int RttMs);

public static class Mtu
{
    private static readonly int[] CandidatePayloads = { 1472, 1464, 1452, 1432, 1392, 1372, 1252 };

    public static (int OptimalMtu, List<MtuResult> Results) Sweep(string targetHost = "8.8.8.8", int timeoutMs = 800)
    {
        var results = new List<MtuResult>();
        int optimal = 1500;
        using var ping = new Ping();
        var opts = new PingOptions(64, true);

        foreach (var payload in CandidatePayloads)
        {
            int totalMtu = payload + 28;
            byte[] buf = new byte[payload];
            bool ok = false;
            int rtt = -1;
            try
            {
                var reply = ping.Send(targetHost, timeoutMs, buf, opts);
                if (reply.Status == IPStatus.Success)
                {
                    ok = true;
                    rtt = (int)reply.RoundtripTime;
                }
            }
            catch { }
            results.Add(new MtuResult(totalMtu, ok, rtt));
        }

        var maxOk = results.Where(r => r.Success).OrderByDescending(r => r.TestedMtu).FirstOrDefault();
        optimal = maxOk?.TestedMtu ?? 1500;
        return (optimal, results);
    }
}

#endregion

#region Multi-Target Anycast Benchmark & Jitter Gauge

public sealed record BenchTarget(string Name, string Ip, int PingMin, int PingAvg, int PingMax, double JitterMs, int DnsMs, int LossPct);

public static class Bench
{
    public static readonly (string Name, string Ip)[] Targets =
    {
        ("Gateway", ""),
        ("Cloudflare", "1.1.1.1"),
        ("Google", "8.8.8.8"),
        ("Quad9", "9.9.9.9"),
        ("OpenDNS", "208.67.222.222"),
        ("Level3", "4.2.2.1")
    };

    public static async Task<List<BenchTarget>> RunAsync(string? gatewayIp = null, CancellationToken ct = default)
    {
        var res = new List<BenchTarget>();
        using var ping = new Ping();
        var buf = new byte[32];

        foreach (var (name, ip) in Targets)
        {
            if (ct.IsCancellationRequested) break;
            string targetIp = string.IsNullOrEmpty(ip) ? (gatewayIp ?? Net.Primary()?.Gw ?? "") : ip;
            if (string.IsNullOrEmpty(targetIp)) continue;

            var rtts = new List<int>();
            int lost = 0;
            const int count = 4;

            for (int i = 0; i < count; i++)
            {
                try
                {
                    var rep = await ping.SendPingAsync(targetIp, 600, buf);
                    if (rep.Status == IPStatus.Success)
                        rtts.Add((int)rep.RoundtripTime);
                    else
                        lost++;
                }
                catch { lost++; }
            }

            int pMin = rtts.Count > 0 ? rtts.Min() : -1;
            int pMax = rtts.Count > 0 ? rtts.Max() : -1;
            int pAvg = rtts.Count > 0 ? (int)rtts.Average() : -1;
            double jitter = 0;
            if (rtts.Count > 1)
            {
                double mean = rtts.Average();
                jitter = Math.Sqrt(rtts.Sum(v => Math.Pow(v - mean, 2)) / rtts.Count);
            }
            int lossPct = (lost * 100) / count;

            int dnsMs = -1;
            if (targetIp != gatewayIp && !string.IsNullOrEmpty(ip))
            {
                dnsMs = await Dns.Ms(targetIp, ct);
            }

            res.Add(new BenchTarget(name, targetIp, pMin, pAvg, pMax, Math.Round(jitter, 1), dnsMs, lossPct));
        }
        return res;
    }
}

#endregion
