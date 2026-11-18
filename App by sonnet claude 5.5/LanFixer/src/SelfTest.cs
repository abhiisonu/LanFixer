using System.Net;
using System.Text;
using Microsoft.Win32;
namespace LanFixer;

sealed class FakeFx : IFx
{
    public Dictionary<string, string?> D = new(); static string Key(string t, string k, string n) => $"{t}|{k}|{n}";
    public string? Get(string t, string k, string n) => D.GetValueOrDefault(Key(t, k, n));
    public void Set(string t, string k, string n, string? v) { if (v == null) D.Remove(Key(t, k, n)); else D[Key(t, k, n)] = v; }
}
sealed class XorProt : IProt { public byte[]? Do(byte[] d, byte[] e, bool enc) { if (!enc && d.Length < 3) return null; var r = d.Select((b, i) => (byte)(b ^ e[i % e.Length])).ToArray(); return r; } }
sealed class FakeHttp : HttpMessageHandler
{
    public List<(string method, string url, string body)> Req = new(); public Func<HttpRequestMessage, string, HttpResponseMessage> H = (_, _) => new(HttpStatusCode.NotFound);
    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage r, CancellationToken ct)
    { var b = r.Content == null ? "" : await r.Content.ReadAsStringAsync(ct); Req.Add((r.Method.Method, r.RequestUri!.ToString(), b)); return H(r, b); }
}

/// <summary>Built-in verification: pure-logic tests run anywhere; live tests run on Windows (admin adds a real registry round-trip).</summary>
static class SelfTest
{
    static int _ok, _bad, _warn;
    static void T(string n, bool c) { if (c) _ok++; else _bad++; Console.WriteLine($"  [{(c ? "PASS" : "FAIL")}] {n}"); }
    static void W(string n, string d) { _warn++; Console.WriteLine($"  [INFO] {n}: {d}"); }
    static HttpResponseMessage R(HttpStatusCode c, string body = "", string? loc = null) { var m = new HttpResponseMessage(c) { Content = new StringContent(body) }; if (loc != null) m.Headers.Location = new Uri(loc); return m; }
    const string Page = "<html><form action=\"/login\" method=\"post\"><input type=\"hidden\" name=\"zone\" value=\"lan\"><input name=\"auth_user\"><input type=\"password\" name=\"auth_pass\"><input type=\"submit\" name=\"accept\" value=\"Sign In\"></form></html>";

    public static int Run(bool logicOnly)
    {
        Console.WriteLine("== Logic tests =="); Logic().GetAwaiter().GetResult();
        if (!logicOnly && OperatingSystem.IsWindows()) { Console.WriteLine("== Live Windows tests =="); Live().GetAwaiter().GetResult(); }
        else Console.WriteLine("== Live Windows tests skipped ==");
        Console.WriteLine($"\n{_ok} passed, {_bad} failed, {_warn} info"); return _bad == 0 ? 0 : 1;
    }

    static async Task Logic()
    {
        // --- connectivity verdict (same table as the original script) ---
        Pr p(int c, string b = "", string l = "", string e = "") => new(c, b, l, e);
        T("204 => Online", Net.Verdict(p(204), p(0)) == St.Online);
        T("MS connect text => Online", Net.Verdict(p(0), p(200, "Microsoft Connect Test")) == St.Online);
        T("both DNS failures => NoDns", Net.Verdict(p(0, e: "dns"), p(0, e: "dns")) == St.NoDns);
        T("302 => Captive", Net.Verdict(p(302, l: "http://x/"), p(0)) == St.Captive);
        T("200 with foreign body => Captive", Net.Verdict(p(200, "<html>"), p(200, "<html>")) == St.Captive);
        T("511 / 407 => Captive", Net.Verdict(p(511), p(0)) == St.Captive && Net.Verdict(p(0), p(407)) == St.Captive);
        T("nothing => Offline", Net.Verdict(p(0, e: "x"), p(0, e: "x")) == St.Offline);

        // --- DNS wire format ---
        var q = Dns.Query(0x1234); var rep = (byte[])q.Clone(); rep[2] = 0x81; rep[3] = 0x80; rep[7] = 1;
        T("DNS query header", q[0] == 0x12 && q[1] == 0x34 && q[5] == 1);
        T("DNS valid reply accepted", Dns.Valid(q, rep));
        rep[1] ^= 1; T("DNS wrong id rejected", !Dns.Valid(q, rep)); rep[1] ^= 1; rep[3] = 0x83; T("DNS NXDOMAIN rejected", !Dns.Valid(q, rep));

        // --- login form parser ---
        var f = Portal.Parse(Page, new Uri("https://portal.test/index"))!;
        T("form: action resolved against page", f.Action.ToString() == "https://portal.test/login");
        T("form: user/pass fields + hidden + submit", f.UserF == "auth_user" && f.PassF == "auth_pass" && f.F["zone"] == "lan" && f.F["accept"] == "Sign In");
        var f2 = Portal.Parse("<form action='/a'><input type=checkbox name=remember checked><select name=dom><option value=x><option selected value=y></select><input type=text name=roll_no><input type=text name=junk value=1><input type=password name=pw><button name=go value=1></form>", new Uri("https://p.test/"))!;
        T("form: checkbox/select/user-regex/button", f2.F["remember"] == "on" && f2.F["dom"] == "y" && f2.UserF == "roll_no" && f2.F["go"] == "1" && f2.F["junk"] == "1");
        T("form: formless HTML5 fallback", Portal.Parse("<input name=u><input type=password name=p>", new Uri("https://p.test/x"))?.PassF == "p");
        T("form: none => null", Portal.Parse("<form><input name=q></form>", new Uri("https://p.test/")) == null);

        // --- hidden redirects ---
        T("redirect: meta refresh", Portal.Redirect("<meta http-equiv=\"refresh\" content=\"0; url=/login?a=1\">", new Uri("http://gw/")) == "http://gw/login?a=1");
        T("redirect: JS location", Portal.Redirect("<script>window.location.href='https://p.test/x'</script>", new Uri("http://gw/")) == "https://p.test/x");
        T("redirect: javascript: scheme ignored", Portal.Redirect("<script>location='javascript:alert(1)'</script>", new Uri("http://gw/")) == null);

        // --- trust rules ---
        bool tr(string u, string h) => Portal.Trusted(new Uri(u), h);
        T("trust: exact + sub-domain", tr("https://portal.test/", "portal.test") && tr("https://a.portal.test/x", "portal.test"));
        T("trust: look-alikes refused", !tr("https://evilportal.test/", "portal.test") && !tr("https://portal.test.evil.com/", "portal.test"));
        T("trust: http + userinfo refused", !tr("http://portal.test/", "portal.test") && !tr("https://portal.test@evil.com/", "portal.test") && !tr("https://x:y@portal.test/", "portal.test"));
        T("trust: IP literal exact only", tr("https://10.0.0.1/", "10.0.0.1") && !tr("https://x.10.0.0.1/", "10.0.0.1"));
        T("cert pin compare", Net.Pinned(new byte[] { 1, 2, 3 }, Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(new byte[] { 1, 2, 3 })).ToLower()) && !Net.Pinned(new byte[] { 1 }, "00"));

        // --- auto-login behaviour against a fake portal (no network) ---
        Portal.PollMs = 5; var cr = new Cred { U = "alice", P = "s3cret", H = "portal.test" }; bool authed = false;
        var h = new FakeHttp(); h.H = (r, b) => r.Method == HttpMethod.Post ? (authed = b.Contains("auth_pass=s3cret")) ? R(HttpStatusCode.OK, "ok") : R(HttpStatusCode.OK) : R(HttpStatusCode.OK, Page);
        var res = await Portal.Login(new HttpClient(h), new Uri("https://portal.test/index"), cr, () => Task.FromResult(authed), _ => { }, default);
        var post = h.Req.Single(x => x.method == "POST");
        T("login: success posts user+password+hidden fields to trusted host", res == Lr.Ok && post.url == "https://portal.test/login" && post.body.Contains("auth_user=alice") && post.body.Contains("zone=lan"));
        h = new FakeHttp(); h.H = (r, b) => R(HttpStatusCode.OK, Page.Replace("/login", "https://evil.test/steal"));
        res = await Portal.Login(new HttpClient(h), new Uri("https://portal.test/"), cr, () => Task.FromResult(false), _ => { }, default);
        T("login: form posting to foreign host => Refused, password never sent", res == Lr.Refused && h.Req.All(x => x.method == "GET" && !x.body.Contains("s3cret")));
        h = new FakeHttp(); h.H = (r, b) => R(HttpStatusCode.Found, "", "https://evil.test/");
        res = await Portal.Login(new HttpClient(h), new Uri("https://portal.test/"), cr, () => Task.FromResult(false), _ => { }, default);
        T("login: redirect to foreign host => Refused, evil host never contacted", res == Lr.Refused && h.Req.All(x => !x.url.Contains("evil.test")));
        h = new FakeHttp();
        res = await Portal.Login(new HttpClient(h), new Uri("http://portal.test/"), cr, () => Task.FromResult(false), _ => { }, default);
        T("login: plain-http start => Refused, zero requests", res == Lr.Refused && h.Req.Count == 0);
        h = new FakeHttp(); h.H = (r, b) => R(HttpStatusCode.OK, Page);
        res = await Portal.Login(new HttpClient(h), new Uri("https://portal.test/"), cr, () => Task.FromResult(false), _ => { }, default);
        T("login: login form returned again => Rejected", res == Lr.Rejected);

        // --- policy ---
        var now = DateTime.Now;
        T("policy: heals only after 3 bad probes", !Policy.ShouldHeal(St.Offline, 2, DateTime.MinValue, 0, now, false) && Policy.ShouldHeal(St.Offline, 3, DateTime.MinValue, 0, now, false));
        T("policy: cooldown / hourly cap / pending reboot / link-down block", !Policy.ShouldHeal(St.Offline, 5, now.AddSeconds(-30), 0, now, false) && !Policy.ShouldHeal(St.NoDns, 5, DateTime.MinValue, 3, now, false) && !Policy.ShouldHeal(St.Offline, 5, DateTime.MinValue, 0, now, true) && !Policy.ShouldHeal(St.NoLink, 9, DateTime.MinValue, 0, now, false) && !Policy.ShouldHeal(St.Captive, 9, DateTime.MinValue, 0, now, false));
        T("policy: adaptive interval (battery slower, unhealthy fast)", Policy.Interval(St.Online, false) == 15 && Policy.Interval(St.Online, true) == 30 && Policy.Interval(St.Offline, true) == 4);

        // --- change journal: backup / rollback / restore ---
        var dir = Path.Combine(Path.GetTempPath(), "lf-" + Guid.NewGuid().ToString("N")); P.Dir = dir; Directory.CreateDirectory(dir);
        var fx = new FakeFx(); fx.Set("reg", "K", "A", "5"); var s = new Store(Path.Combine(dir, "s.json"), fx);
        var r1 = s.Begin("one"); s.Change(r1, "reg", "K", "A", "0"); s.Change(r1, "reg", "K", "B", "1"); s.End(r1);
        var r2 = s.Begin("two"); s.Change(r2, "reg", "K", "A", "9"); s.End(r2);
        T("journal: first-write-wins baseline keeps ORIGINAL value", s.D.Base.Single(b => b.N == "A").V == "5" && s.D.Base.Single(b => b.N == "B").V == null);
        s.Rollback(); T("rollback: undoes only the last run", fx.Get("reg", "K", "A") == "0" && fx.Get("reg", "K", "B") == "1");
        var s2 = new Store(Path.Combine(dir, "s.json"), fx); T("journal survives restart (persisted)", s2.D.Runs.Count == 1 && s2.D.Base.Count == 2);
        fx.Set("reg", "K", "A", "77"); var (ok, sk) = s2.Rollback(); T("rollback: drift protection skips values changed by others", ok == 1 && sk == 1 && fx.Get("reg", "K", "A") == "77");
        var s3 = new Store(Path.Combine(dir, "s.json"), fx); var r3 = s3.Begin("t"); s3.Change(r3, "reg", "K", "A", "0"); s3.Change(r3, "reg", "K", "C", "1"); s3.End(r3);
        s3.RestoreAll(); T("restore: everything back to original, created values removed", fx.Get("reg", "K", "A") == "77" && fx.Get("reg", "K", "C") == null && s3.D.Base.Count == 0 && s3.D.Runs.Count == 0);
        File.WriteAllText(Path.Combine(dir, "s.json"), "{corrupt"); var s4 = new Store(Path.Combine(dir, "s.json"), fx); T("corrupt state file falls back to .bak", s4.D != null);
        var s5 = new Store(Path.Combine(dir, "d.json"), fx); var r5 = s5.Begin("dns"); s5.Change(r5, "dns", "G", "", "1.1.1.1"); s5.End(r5); T("revert(dns) removes only DNS entries", s5.Revert(c => c.T == "dns") == 1 && fx.Get("dns", "G", "") == null);

        // --- vault ---
        Vault.Prot = new XorProt(); Vault.Path_ = Path.Combine(dir, "v.bin"); var c0 = new Cred { U = "bob", P = "pw", H = "h.test", Pin = "AB" };
        T("vault: save + load round-trip", Vault.Save(c0) && Vault.Load() is { U: "bob", P: "pw", H: "h.test", Pin: "AB" });
        T("vault: file does not contain the password in clear", !Encoding.UTF8.GetString(File.ReadAllBytes(Vault.Path_)).Contains("pw\""));
        File.WriteAllBytes(Vault.Path_, new byte[] { 1 }); T("vault: tampered file => fails closed (null)", Vault.Load() == null);
        Vault.Clear(); T("vault: clear removes file", !Vault.Exists); Vault.Prot = new Dp(); Vault.Path_ = null;
        try { Directory.Delete(dir, true); } catch { }
    }

    static async Task Live()
    {
        P.Dir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), "LanFixer");
        var raw = Encoding.UTF8.GetBytes("hello"); var e = N.Dpapi(raw, Encoding.UTF8.GetBytes("ent"), true); var d = e == null ? null : N.Dpapi(e, Encoding.UTF8.GetBytes("ent"), false);
        T("DPAPI machine-scope round-trip", d != null && Encoding.UTF8.GetString(d) == "hello" && N.Dpapi(e!, Encoding.UTF8.GetBytes("other"), false) == null);
        T("registry readable (MachineGuid)", Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Microsoft\Cryptography")?.GetValue("MachineGuid") != null);
        T("netsh dump (backup source) works", Sh.Run("netsh", "dump").output.Length > 100);
        T("icacls available (folder lock-down)", Sh.Run("icacls", "/?").code == 0 || Sh.Run("icacls").code != -2);
        var lk = Net.Primary(); W("primary link", lk == null ? "none" : $"{lk.Name} {lk.Ip} gw {lk.Gw}");
        var (st, loc, ms) = await Net.Probe(lk?.Ip, default); W("probe", $"{st} {ms}ms {loc}");
        var rk = await Dns.Rank(Dns.Public, default); W("public DNS reachable", rk.Count == 0 ? "none" : string.Join(", ", rk.Select(x => $"{x.ip}={x.ms}ms")));
        try { using var pp = Pipe.Make(); T("service pipe ACL (admins/system full, users rw, network denied) builds", true); } catch (Exception ex) { T("service pipe ACL builds: " + ex.Message, false); }
        W("service", Sh.Run("sc", "query", "LanFixer").output.Contains("RUNNING") ? "installed and running" : "not installed/running");
        W("admin", P.Admin() ? "yes" : "no (registry round-trip skipped; run elevated for the full test)");
        if (!P.Admin()) return;
        const string K = @"SOFTWARE\LanFixerSelfTest"; Registry.LocalMachine.DeleteSubKeyTree(K, false); var fx = new WinFx(); var tmp = Path.Combine(Path.GetTempPath(), "lf-live.json"); File.Delete(tmp);
        var s = new Store(tmp, fx); var r = s.Begin("selftest");
        T("live: change writes a DWORD", s.Change(r, "reg", K, "V", "4294967295") && fx.Get("reg", K, "V") == "4294967295"); s.End(r);
        T("live: rollback removes it again", s.Rollback() == (1, 0) && fx.Get("reg", K, "V") == null);
        Registry.LocalMachine.DeleteSubKeyTree(K, false); File.Delete(tmp);
    }
}
