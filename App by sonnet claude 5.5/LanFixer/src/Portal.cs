using System.Net;
using System.Net.Security;
using System.Net.Sockets;
using System.Text.RegularExpressions;
namespace LanFixer;

public enum Lr { Ok, Rejected, Ambiguous, Refused, NoForm, Error }

/// <summary>Captive-portal auto-login. Every guard exists because a rogue device on a shared LAN can impersonate a portal.</summary>
static class Portal
{
    public record Form(Uri Action, string UserF, string PassF, Dictionary<string, string> F);
    const RegexOptions O = RegexOptions.IgnoreCase | RegexOptions.Singleline;
    static readonly TimeSpan T = TimeSpan.FromSeconds(2);
    public static int PollMs = 1000;

    public static string? Attr(string tag, string name)
    {
        var m = Regex.Match(tag, @"(?<![\w-])" + name + @"\s*=\s*(?:""([^""]*)""|'([^']*)'|([^\s>]+))", RegexOptions.IgnoreCase, T);
        return m.Success ? WebUtility.HtmlDecode(m.Groups[1].Success ? m.Groups[1].Value : m.Groups[2].Success ? m.Groups[2].Value : m.Groups[3].Value) : null;
    }

    /// <summary>Credentials may only go to https on the trusted host (or a sub-domain of it). No userinfo tricks, no look-alikes.</summary>
    public static bool Trusted(Uri u, string host)
    {
        host = host.Trim().Trim('.').ToLowerInvariant(); if (host == "" || u.Scheme != "https" || u.UserInfo != "") return false;
        var h = u.Host.ToLowerInvariant();
        return h == host || (!IPAddress.TryParse(host, out _) && h.EndsWith("." + host));
    }

    /// <summary>First form holding a password input (with formless HTML5 fallback). Returns hidden/checked/select/submit fields + field names.</summary>
    public static Form? Parse(string html, Uri page)
    {
        var forms = Regex.Matches(html, @"<form\b([^>]*)>(.*?)</form>", O, T).Select(m => (m.Groups[1].Value, m.Groups[2].Value)).ToList();
        if (forms.Count == 0 || !Regex.IsMatch(html, @"<form\b[^>]*>.*?<input\b[^>]*type\s*=\s*[""']?password.*?</form>", O, T)) forms.Add((Regex.Match(html, @"<form\b([^>]*)>", O, T).Groups[1].Value, html));
        foreach (var (fa, body) in forms)
        {
            string? pass = null, user = null; var f = new Dictionary<string, string>(); var cand = new List<(string n, string id, string v)>();
            foreach (Match im in Regex.Matches(body, @"<input\b[^>]*>", O, T))
            {
                var t = im.Value; var type = (Attr(t, "type") ?? "").ToLowerInvariant(); var name = Attr(t, "name"); if (string.IsNullOrEmpty(name)) continue;
                var val = Attr(t, "value") ?? "";
                if (type == "password") pass ??= name;
                else if (type == "hidden") f[name] = val;
                else if (type == "checkbox") { if (Regex.IsMatch(t, @"\bchecked\b", RegexOptions.IgnoreCase, T)) f[name] = val == "" ? "on" : val; }
                else if (type == "submit") f.TryAdd(name, val);
                else if (type is "" or "text" or "email" or "tel" or "number") cand.Add((name, Attr(t, "id") ?? "", val));
            }
            if (pass == null) continue;
            user = cand.FirstOrDefault(c => Regex.IsMatch(c.n + " " + c.id, "user|login|email|auth|account|id|roll|reg|uid|uname|member|netid|student", RegexOptions.IgnoreCase, T)).n ?? cand.FirstOrDefault().n ?? "auth_user";
            foreach (var c in cand) if (c.n != user && c.v != "") f.TryAdd(c.n, c.v);
            foreach (Match s in Regex.Matches(body, @"<select\b([^>]*)>(.*?)</select>", O, T))
            {
                var sn = Attr(s.Groups[1].Value, "name"); if (sn == null) continue;
                var o = Regex.Match(s.Groups[2].Value, @"<option\b[^>]*\bselected\b[^>]*value\s*=\s*[""']?([^""'\s>]+)", O, T);
                if (!o.Success) o = Regex.Match(s.Groups[2].Value, @"<option\b[^>]*value\s*=\s*[""']?([^""'\s>]+)", O, T);
                if (o.Success) f.TryAdd(sn, WebUtility.HtmlDecode(o.Groups[1].Value));
            }
            foreach (Match b in Regex.Matches(body, @"<button\b[^>]*>", O, T))
            {
                var bn = Attr(b.Value, "name"); var bt = (Attr(b.Value, "type") ?? "").ToLowerInvariant();
                if (bn != null && bt is "" or "submit") f.TryAdd(bn, Attr(b.Value, "value") ?? "");
            }
            Uri act = page; var a = Attr(fa, "action");
            if (!string.IsNullOrEmpty(a)) try { act = new Uri(page, a); } catch { continue; }
            return new Form(act, user, pass, f);
        }
        return null;
    }

    /// <summary>Redirect target hidden in a 200 page: meta refresh or JS location assignment.</summary>
    public static string? Redirect(string html, Uri b)
    {
        var m = Regex.Match(html, @"<meta[^>]+http-equiv\s*=\s*[""']?refresh[^>]*content\s*=\s*[""'][^""']*url\s*=\s*([^""'>\s;]+)", O, T);
        if (!m.Success) m = Regex.Match(html, @"<meta[^>]+content\s*=\s*[""'][^""']*url\s*=\s*([^""'>\s;]+)[^>]*http-equiv\s*=\s*[""']?refresh", O, T);
        if (!m.Success) m = Regex.Match(html, @"(?:window\.|document\.|top\.)?location(?:\.href\s*=|\.replace\(|\.assign\(|\s*=)\s*\(?\s*[""']([^""']+)[""']", O, T);
        if (!m.Success) return null;
        try { var u = new Uri(b, WebUtility.HtmlDecode(m.Groups[1].Value.Trim('"', '\'', ';'))); return u.Scheme is "http" or "https" ? u.AbsoluteUri : null; } catch { return null; }
    }

    static bool Bad(int code, string body, string loc) =>
        code is 401 or 403 || Regex.IsMatch(body, @"invalid\s+(credential|password|user|login)|incorrect\s+(password|user)|authentication\s+fail|login\s+fail|access\s+denied|wrong\s+(password|user)", RegexOptions.IgnoreCase, T)
        || Regex.IsMatch(loc, "error|fail|invalid|denied", RegexOptions.IgnoreCase, T) || Regex.IsMatch(body, @"<input\b[^>]*type\s*=\s*[""']?password", RegexOptions.IgnoreCase, T);

    /// <param name="c">cookie-enabled client with no auto-redirect. online: re-checks internet after the POST.</param>
    public static async Task<Lr> Login(HttpClient c, Uri start, Cred cr, Func<Task<bool>> online, Action<string> log, CancellationToken ct)
    {
        var cur = start; string body = "";
        if (!Trusted(cur, cr.H)) { log("ALERT redirect target is not the trusted portal host: password NOT sent"); return Lr.Refused; }
        try
        {
            var seen = new HashSet<string> { cur.AbsoluteUri };
            for (int hop = 0; hop < 4; hop++)
            {
                using var r = await c.GetAsync(cur, ct);
                if ((int)r.StatusCode is >= 300 and <= 399 && r.Headers.Location != null)
                {
                    var nx = new Uri(cur, r.Headers.Location);
                    if (!Trusted(nx, cr.H)) { log("ALERT portal redirected to an untrusted host: password NOT sent"); return Lr.Refused; }
                    if (!seen.Add(nx.AbsoluteUri)) break;
                    cur = nx; continue;
                }
                body = await r.Content.ReadAsStringAsync(ct); break;
            }
            var form = Parse(body, cur); if (form == null) { log("no login form found on the portal page"); return Lr.NoForm; }
            if (!Trusted(form.Action, cr.H)) { log("ALERT login form posts to an untrusted host: password NOT sent"); return Lr.Refused; }
            var f = new Dictionary<string, string>(form.F) { [form.UserF] = cr.U, [form.PassF] = cr.P };
            if (!f.ContainsKey("accept") && f.ContainsKey("zone")) f["accept"] = "Sign In";
            using var post = await c.PostAsync(form.Action, new FormUrlEncodedContent(f), ct); f.Clear();
            var pb = await post.Content.ReadAsStringAsync(ct); var loc = post.Headers.Location?.ToString() ?? "";
            for (int i = 0; i < 6; i++) { await Task.Delay(PollMs, ct); if (await online()) return Lr.Ok; }
            return Bad((int)post.StatusCode, pb, loc) ? Lr.Rejected : Lr.Ambiguous;
        }
        catch (OperationCanceledException) { throw; }
        catch (Exception e) { log("login request failed: " + e.GetType().Name); return Lr.Error; }
    }

    /// <summary>SHA-256 of the certificate a host presents (for one-time approval of self-signed portals).</summary>
    public static async Task<string?> Fingerprint(string host)
    {
        try
        {
            using var t = new TcpClient(); await t.ConnectAsync(host, 443); string? fp = null;
            using var s = new SslStream(t.GetStream(), false, (_, cert, _, _) => { fp = cert == null ? null : Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(cert.GetRawCertData())); return true; });
            await s.AuthenticateAsClientAsync(host); return fp;
        }
        catch { return null; }
    }
}
