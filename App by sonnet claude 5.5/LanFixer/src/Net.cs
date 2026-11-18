using System.Diagnostics;
using System.Net;
using System.Net.NetworkInformation;
using System.Net.Sockets;
using System.Text;
using Microsoft.Win32;
namespace LanFixer;

public enum St { Online, Captive, NoDns, Offline, NoLink }
public record Pr(int Code, string Body, string Loc, string Err);
public record Link(string Name, string Id, string Ip, string Gw, bool Wifi);

static class Net
{
    static HttpClient? _c; static string _bind = "?";
    /// <summary>Probe client: no proxy, no redirects, optionally bound to one adapter's IPv4 (so a second uplink can't answer for it).</summary>
    public static HttpClient Client(string? bindIp = null, string? pin = null, bool cookies = false)
    {
        if (pin == null && !cookies && _c != null && _bind == (bindIp ?? "")) return _c;
        var h = new SocketsHttpHandler { AllowAutoRedirect = false, UseProxy = false, UseCookies = cookies, ConnectTimeout = TimeSpan.FromSeconds(3) };
        if (pin != null) h.SslOptions.RemoteCertificateValidationCallback = (_, cert, _, err) => err == System.Net.Security.SslPolicyErrors.None || (cert != null && Pinned(cert.GetRawCertData(), pin));
        if (bindIp != null && IPAddress.TryParse(bindIp, out var ip))
            h.ConnectCallback = async (ctx, ct) =>
            {
                var s = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp) { NoDelay = true };
                try { s.Bind(new IPEndPoint(ip, 0)); await s.ConnectAsync(ctx.DnsEndPoint, ct); return new NetworkStream(s, true); } catch { s.Dispose(); throw; }
            };
        var c = new HttpClient(h) { Timeout = TimeSpan.FromSeconds(6), MaxResponseContentBufferSize = 1 << 20 };
        if (pin != null || cookies) return c;
        _c?.Dispose(); _bind = bindIp ?? ""; return _c = c;
    }
    public static bool Pinned(byte[] raw, string pin) => Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(raw)).Equals(pin.Replace(":", ""), StringComparison.OrdinalIgnoreCase);

    public static async Task<Pr> Get(HttpClient c, string url, CancellationToken ct)
    {
        try
        {
            using var r = await c.GetAsync(url, HttpCompletionOption.ResponseHeadersRead, ct);
            var body = await r.Content.ReadAsStringAsync(ct); var loc = r.Headers.Location is { } l ? new Uri(new Uri(url), l).ToString() : "";
            if (loc == "" && (int)r.StatusCode == 200) loc = Portal.Redirect(body, new Uri(url)) ?? "";
            return new((int)r.StatusCode, body, loc, "");
        }
        catch (HttpRequestException e) when (e.HttpRequestError == HttpRequestError.NameResolutionError) { return new(0, "", "", "dns"); }
        catch (HttpRequestException e) when (e.HttpRequestError == HttpRequestError.SecureConnectionError) { return new(0, "", "", "tls"); }
        catch { return new(0, "", "", "x"); }
    }

    /// <summary>Same decision table as the original script (generate_204 / connecttest, DNS-only failure, any 2xx/3xx/401/407/511 = captive).</summary>
    public static St Verdict(Pr a, Pr b)
    {
        if (a.Code == 204 || (b.Code == 200 && b.Body.StartsWith("Microsoft Connect Test"))) return St.Online;
        if (a.Err == "dns" && b.Err == "dns") return St.NoDns;
        foreach (var p in new[] { a, b }) if (p.Code is >= 200 and <= 399 or 401 or 407 or 511 || p.Loc != "") return St.Captive;
        return St.Offline;
    }

    /// <summary>Returns state, captive redirect (if any) and HTTP latency of the first probe.</summary>
    public static async Task<(St s, string loc, int ms)> Probe(string? bind, CancellationToken ct)
    {
        var c = Client(bind); var sw = Stopwatch.StartNew();
        var a = await Get(c, "http://connectivitycheck.gstatic.com/generate_204", ct); int ms = (int)sw.ElapsedMilliseconds;
        var b = a.Code == 204 ? new Pr(0, "", "", "") : await Get(c, "http://www.msftconnecttest.com/connecttest.txt", ct);
        var s = Verdict(a, b);
        if (s == St.Online && (await Get(c, "https://connectivitycheck.gstatic.com/generate_204", ct)).Err == "tls") s = St.Captive;   // HTTP spoofed 204 but TLS intercepted
        return (s, a.Loc != "" ? a.Loc : b.Loc, ms);
    }

    public static async Task<int> Rtt(string ip, int ms = 1000)
    {
        try { using var p = new Ping(); var r = await p.SendPingAsync(ip, ms); return r.Status == IPStatus.Success ? (int)r.RoundtripTime : -1; } catch { return -1; }
    }

    static IEnumerable<NetworkInterface> Up() => NetworkInterface.GetAllNetworkInterfaces().Where(n => n.OperationalStatus == OperationalStatus.Up && n.NetworkInterfaceType is NetworkInterfaceType.Ethernet or NetworkInterfaceType.GigabitEthernet or NetworkInterfaceType.Wireless80211
        && !n.Description.Contains("Virtual", StringComparison.OrdinalIgnoreCase) && !n.Description.Contains("VPN", StringComparison.OrdinalIgnoreCase));
    /// <summary>Primary physical uplink: wired preferred, else Wi-Fi. Returns the link even if it has no valid IP yet (APIPA counts as broken, not absent).</summary>
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
    public static string Fingerprint(Link? l) => l == null ? "" : l.Id + "|" + l.Gw;
}

static class Dns
{
    public static readonly string[] Public = { "1.1.1.1", "8.8.8.8", "9.9.9.9", "1.0.0.1", "8.8.4.4", "149.112.112.112" };
    public static byte[] Query(ushort id)
    {
        var l = new List<byte> { (byte)(id >> 8), (byte)id, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0 };
        foreach (var s in "example.com".Split('.')) { l.Add((byte)s.Length); l.AddRange(Encoding.ASCII.GetBytes(s)); }
        l.AddRange(new byte[] { 0, 0, 1, 0, 1 }); return l.ToArray();
    }
    /// <summary>Valid reply = same id, QR set, RCODE 0, at least one answer.</summary>
    public static bool Valid(byte[] q, byte[] r) => r.Length >= 12 && r[0] == q[0] && r[1] == q[1] && (r[2] & 0x80) != 0 && (r[3] & 15) == 0 && ((r[6] << 8) | r[7]) > 0;
    /// <summary>Raw UDP/53 latency in ms, or -1.</summary>
    public static async Task<int> Ms(string server, CancellationToken ct)
    {
        if (!IPAddress.TryParse(server, out var ip)) return -1;
        try
        {
            using var u = new UdpClient(ip.AddressFamily); var q = Query((ushort)Random.Shared.Next(65536)); var sw = Stopwatch.StartNew();
            await u.SendAsync(q, new IPEndPoint(ip, 53), ct);
            using var t = CancellationTokenSource.CreateLinkedTokenSource(ct); t.CancelAfter(1200);
            var r = await u.ReceiveAsync(t.Token); return Valid(q, r.Buffer) ? (int)sw.ElapsedMilliseconds : -1;
        }
        catch { return -1; }
    }
    public static async Task<List<(string ip, int ms)>> Rank(IEnumerable<string> s, CancellationToken ct)
    {
        var l = s.Distinct().ToArray(); var r = await Task.WhenAll(l.Select(x => Ms(x, ct)));
        return l.Zip(r, (a, b) => (a, b)).Where(x => x.b >= 0).OrderBy(x => x.b).ToList();
    }
    static IEnumerable<string> Reg(string id, string v) =>
        (Registry.LocalMachine.OpenSubKey(@"SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\" + id)?.GetValue(v) as string ?? "").Split(new[] { ',', ' ' }, StringSplitOptions.RemoveEmptyEntries);
    public static IEnumerable<string> Dhcp(string id) => Reg(id, "DhcpNameServer");
    public static IEnumerable<string> Current(string id) => NetworkInterface.GetAllNetworkInterfaces().FirstOrDefault(n => n.Id == id)?.GetIPProperties().DnsAddresses.Where(a => a.AddressFamily == AddressFamily.InterNetwork).Select(a => a.ToString()) ?? Enumerable.Empty<string>();
}
