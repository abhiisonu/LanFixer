using System.Net;
using System.Net.Security;
using System.Net.Sockets;
using System.Text;
using System.Text.RegularExpressions;

namespace LanFixer;

public enum Lr { Ok, Rejected, Ambiguous, Refused, NoForm, Error }

/// <summary>
/// Autonomous captive-portal engine: supports custom ports (e.g. pfSense port 8888),
/// raw TLS form inspection, source-bound authentication, and anti-impersonation guards.
/// </summary>
public static class Portal
{
    public record Form(Uri Action, string UserF, string PassF, Dictionary<string, string> F);
    private const RegexOptions O = RegexOptions.IgnoreCase | RegexOptions.Singleline;
    private static readonly TimeSpan T = TimeSpan.FromSeconds(2);
    public static int PollMs = 1000;

    public static string? Attr(string tag, string name)
    {
        var m = Regex.Match(tag, @"(?<![\w-])" + name + @"\s*=\s*(?:""([^""]*)""|'([^']*)'|([^\s>]+))", RegexOptions.IgnoreCase, T);
        return m.Success ? WebUtility.HtmlDecode(m.Groups[1].Success ? m.Groups[1].Value : m.Groups[2].Success ? m.Groups[2].Value : m.Groups[3].Value) : null;
    }

    /// <summary>
    /// Credentials may only go to https on the trusted host (or a sub-domain of it).
    /// Preserves custom port integrity and blocks userinfo phishing tricks.
    /// </summary>
    public static bool Trusted(Uri u, string host, int allowedPort = 0)
    {
        host = host.Trim().Trim('.').ToLowerInvariant();
        if (host == "" || u.Scheme != "https" || u.UserInfo != "") return false;
        var h = u.Host.ToLowerInvariant();
        bool hostMatch = h == host || (!IPAddress.TryParse(host, out _) && h.EndsWith("." + host));
        if (!hostMatch) return false;
        if (allowedPort > 0 && u.Port > 0 && u.Port != allowedPort) return false;
        return true;
    }

    /// <summary>
    /// Raw TLS stream probe: checks if the portal at portalUrl is actively demanding authentication
    /// by serving a form with password or user credential inputs.
    /// </summary>
    public static bool IsDemandingAuth(string portalUrl, string? sourceIp = null, int timeoutMs = 1500)
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
                var req = Encoding.ASCII.GetBytes($"GET {uri.PathAndQuery} HTTP/1.0\r\nHost: {targetHost}\r\nUser-Agent: LanFixer/8.5.0\r\nConnection: close\r\n\r\n");
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

    /// <summary>
    /// HTML5 Form Parser: extracts action, user, pass, hidden, select and submit fields.
    /// </summary>
    public static Form? Parse(string html, Uri page)
    {
        var forms = Regex.Matches(html, @"<form\b([^>]*)>(.*?)</form>", O, T).Select(m => (m.Groups[1].Value, m.Groups[2].Value)).ToList();
        if (forms.Count == 0 || !Regex.IsMatch(html, @"<form\b[^>]*>.*?<input\b[^>]*type\s*=\s*[""']?password.*?</form>", O, T))
            forms.Add((Regex.Match(html, @"<form\b([^>]*)>", O, T).Groups[1].Value, html));

        foreach (var (fa, body) in forms)
        {
            string? pass = null, user = null;
            var f = new Dictionary<string, string>();
            var cand = new List<(string n, string id, string v)>();

            foreach (Match im in Regex.Matches(body, @"<input\b[^>]*>", O, T))
            {
                var t = im.Value;
                var type = (Attr(t, "type") ?? "").ToLowerInvariant();
                var name = Attr(t, "name");
                if (string.IsNullOrEmpty(name)) continue;
                var val = Attr(t, "value") ?? "";

                if (type == "password") pass ??= name;
                else if (type == "hidden") f[name] = val;
                else if (type == "checkbox") { if (Regex.IsMatch(t, @"\bchecked\b", RegexOptions.IgnoreCase, T)) f[name] = val == "" ? "on" : val; }
                else if (type == "submit") f.TryAdd(name, val);
                else if (type is "" or "text" or "email" or "tel" or "number") cand.Add((name, Attr(t, "id") ?? "", val));
            }
            if (pass == null) continue;

            user = cand.FirstOrDefault(c => Regex.IsMatch(c.n + " " + c.id, "user|login|email|auth|account|id|roll|reg|uid|uname|member|netid|student", RegexOptions.IgnoreCase, T)).n
                   ?? cand.FirstOrDefault().n ?? "auth_user";

            foreach (var c in cand)
                if (c.n != user && c.v != "") f.TryAdd(c.n, c.v);

            foreach (Match s in Regex.Matches(body, @"<select\b([^>]*)>(.*?)</select>", O, T))
            {
                var sn = Attr(s.Groups[1].Value, "name");
                if (sn == null) continue;
                var o = Regex.Match(s.Groups[2].Value, @"<option\b[^>]*\bselected\b[^>]*value\s*=\s*[""']?([^""'\s>]+)", O, T);
                if (!o.Success) o = Regex.Match(s.Groups[2].Value, @"<option\b[^>]*value\s*=\s*[""']?([^""'\s>]+)", O, T);
                if (o.Success) f.TryAdd(sn, WebUtility.HtmlDecode(o.Groups[1].Value));
            }

            foreach (Match b in Regex.Matches(body, @"<button\b[^>]*>", O, T))
            {
                var bn = Attr(b.Value, "name");
                var bt = (Attr(b.Value, "type") ?? "").ToLowerInvariant();
                if (bn != null && bt is "" or "submit") f.TryAdd(bn, Attr(b.Value, "value") ?? "");
            }

            Uri act = page;
            var a = Attr(fa, "action");
            if (!string.IsNullOrEmpty(a))
            {
                try { act = new Uri(page, a); }
                catch { continue; }
            }
            return new Form(act, user, pass, f);
        }
        return null;
    }

    /// <summary>
    /// Preserves exact custom port and path during HTTP 200 meta-refresh or JS redirects.
    /// </summary>
    public static string? Redirect(string html, Uri b)
    {
        var m = Regex.Match(html, @"<meta[^>]+http-equiv\s*=\s*[""']?refresh[^>]*content\s*=\s*[""'][^""']*url\s*=\s*([^""'>\s;]+)", O, T);
        if (!m.Success) m = Regex.Match(html, @"<meta[^>]+content\s*=\s*[""'][^""']*url\s*=\s*([^""'>\s;]+)[^>]*http-equiv\s*=\s*[""']?refresh", O, T);
        if (!m.Success) m = Regex.Match(html, @"(?:window\.|document\.|top\.)?location(?:\.href\s*=|\.replace\(|\.assign\(|\s*=)\s*\(?\s*[""']([^""']+)[""']", O, T);
        if (!m.Success) return null;
        try
        {
            var u = new Uri(b, WebUtility.HtmlDecode(m.Groups[1].Value.Trim('"', '\'', ';')));
            return u.Scheme is "http" or "https" ? u.AbsoluteUri : null;
        }
        catch { return null; }
    }

    private static bool Bad(int code, string body, string loc) =>
        code is 401 or 403 ||
        Regex.IsMatch(body, @"invalid\s+(credential|password|user|login)|incorrect\s+(password|user)|authentication\s+fail|login\s+fail|access\s+denied|wrong\s+(password|user)", RegexOptions.IgnoreCase, T) ||
        Regex.IsMatch(loc, "error|fail|invalid|denied", RegexOptions.IgnoreCase, T) ||
        Regex.IsMatch(body, @"<input\b[^>]*type\s*=\s*[""']?password", RegexOptions.IgnoreCase, T);

    /// <summary>
    /// Performs automated authentication, preserving non-standard HTTPS ports (like port 8888).
    /// </summary>
    public static async Task<Lr> Login(HttpClient c, Uri start, Cred cr, Func<Task<bool>> online, Action<string> log, CancellationToken ct)
    {
        var cur = start;
        string body = "";

        if (!Trusted(cur, cr.H))
        {
            log($"ALERT redirect target '{cur.Host}' is not the trusted portal host '{cr.H}': password NOT sent");
            return Lr.Refused;
        }

        try
        {
            var seen = new HashSet<string> { cur.AbsoluteUri };
            for (int hop = 0; hop < 4; hop++)
            {
                using var r = await c.GetAsync(cur, ct);
                if ((int)r.StatusCode is >= 300 and <= 399 && r.Headers.Location != null)
                {
                    var nx = new Uri(cur, r.Headers.Location);
                    if (!Trusted(nx, cr.H))
                    {
                        log($"ALERT portal redirected to untrusted host '{nx.Host}': password NOT sent");
                        return Lr.Refused;
                    }
                    if (!seen.Add(nx.AbsoluteUri)) break;
                    cur = nx;
                    continue;
                }
                body = await r.Content.ReadAsStringAsync(ct);
                break;
            }

            var form = Parse(body, cur);
            if (form == null)
            {
                log("No login form found on the portal page");
                return Lr.NoForm;
            }

            if (!Trusted(form.Action, cr.H))
            {
                log($"ALERT login form posts to untrusted host '{form.Action.Host}': password NOT sent");
                return Lr.Refused;
            }

            var f = new Dictionary<string, string>(form.F)
            {
                [form.UserF] = cr.U,
                [form.PassF] = cr.P
            };

            // pfSense specific compatibility
            if (!f.ContainsKey("accept") && f.ContainsKey("zone")) f["accept"] = "Sign In";
            if (!f.ContainsKey("login") && f.ContainsKey("passwordfld")) f["login"] = "Login";

            using var post = await c.PostAsync(form.Action, new FormUrlEncodedContent(f), ct);
            f.Clear();

            var pb = await post.Content.ReadAsStringAsync(ct);
            var loc = post.Headers.Location?.ToString() ?? "";

            for (int i = 0; i < 6; i++)
            {
                await Task.Delay(PollMs, ct);
                if (await online()) return Lr.Ok;
            }

            return Bad((int)post.StatusCode, pb, loc) ? Lr.Rejected : Lr.Ambiguous;
        }
        catch (OperationCanceledException) { throw; }
        catch (Exception e)
        {
            log("Login request failed: " + e.GetType().Name);
            return Lr.Error;
        }
    }

    /// <summary>
    /// Reads the SHA-256 fingerprint of the certificate presented by the host:port.
    /// </summary>
    public static async Task<string?> Fingerprint(string host, int port = 443)
    {
        try
        {
            using var t = new TcpClient();
            await t.ConnectAsync(host, port);
            string? fp = null;
            using var s = new SslStream(t.GetStream(), false, (_, cert, _, _) =>
            {
                fp = cert == null ? null : Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(cert.GetRawCertData()));
                return true;
            });
            await s.AuthenticateAsClientAsync(host);
            return fp;
        }
        catch { return null; }
    }
}
