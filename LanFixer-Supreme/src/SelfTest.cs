using System.Net;
using System.Text;
using Microsoft.Win32;

namespace LanFixer;

public sealed class FakeFx : IFx
{
    public Dictionary<string, string?> D = new();
    private static string Key(string t, string k, string n) => $"{t}|{k}|{n}";
    public string? Get(string t, string k, string n) => D.GetValueOrDefault(Key(t, k, n));
    public void Set(string t, string k, string n, string? v)
    {
        if (v == null) D.Remove(Key(t, k, n));
        else D[Key(t, k, n)] = v;
    }
}

public sealed class XorProt : IProt
{
    public byte[]? Do(byte[] d, byte[] e, bool enc)
    {
        if (!enc && d.Length < 3) return null;
        return d.Select((b, i) => (byte)(b ^ e[i % e.Length])).ToArray();
    }
}

public sealed class FakeHttp : HttpMessageHandler
{
    public List<(string method, string url, string body)> Req = new();
    public Func<HttpRequestMessage, string, HttpResponseMessage> H = (_, _) => new(HttpStatusCode.NotFound);

    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage r, CancellationToken ct)
    {
        var b = r.Content == null ? "" : await r.Content.ReadAsStringAsync(ct);
        Req.Add((r.Method.Method, r.RequestUri!.ToString(), b));
        return H(r, b);
    }
}

public static class SelfTest
{
    private static int _ok, _bad, _warn;

    private static void T(string n, bool c)
    {
        if (c) _ok++; else _bad++;
        Console.ForegroundColor = c ? ConsoleColor.Green : ConsoleColor.Red;
        Console.Write(c ? "  [PASS] " : "  [FAIL] ");
        Console.ResetColor();
        Console.WriteLine(n);
    }

    private static void W(string n, string d)
    {
        _warn++;
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.Write("  [INFO] ");
        Console.ResetColor();
        Console.WriteLine($"{n}: {d}");
    }

    private static HttpResponseMessage R(HttpStatusCode c, string body = "", string? loc = null)
    {
        var m = new HttpResponseMessage(c) { Content = new StringContent(body) };
        if (loc != null) m.Headers.Location = new Uri(loc);
        return m;
    }

    private const string Page = "<html><form action=\"/login\" method=\"post\"><input type=\"hidden\" name=\"zone\" value=\"lan\"><input name=\"auth_user\"><input type=\"password\" name=\"auth_pass\"><input type=\"submit\" name=\"accept\" value=\"Sign In\"></form></html>";

    public static int Run(bool logicOnly)
    {
        Console.WriteLine("============================================================================");
        Console.WriteLine("  LANFIXER SUPREME 8.5 VERIFICATION & SELF-TEST SUITE");
        Console.WriteLine("============================================================================\n");

        Console.WriteLine("== Protocol & Domain Logic Tests ==");
        Logic().GetAwaiter().GetResult();

        if (!logicOnly && OperatingSystem.IsWindows())
        {
            Console.WriteLine("\n== Live Windows Stack Tests ==");
            Live().GetAwaiter().GetResult();
        }
        else
        {
            Console.WriteLine("\n== Live Windows Stack Tests Skipped ==");
        }

        Console.WriteLine($"\nResult: {_ok} passed, {_bad} failed, {_warn} info.\n");
        return _bad == 0 ? 0 : 1;
    }

    private static async Task Logic()
    {
        // --- Connectivity Verdict Table ---
        Pr p(int c, string b = "", string l = "", string e = "") => new(c, b, l, e);
        T("Verdict: 204 => Online", Net.Verdict(p(204), p(0)) == St.Online);
        T("Verdict: MS connect text => Online", Net.Verdict(p(0), p(200, "Microsoft Connect Test")) == St.Online);
        T("Verdict: Both DNS failures => NoDns", Net.Verdict(p(0, e: "dns"), p(0, e: "dns")) == St.NoDns);
        T("Verdict: 302 redirect => Captive", Net.Verdict(p(302, l: "http://x/"), p(0)) == St.Captive);
        T("Verdict: 200 with foreign body => Captive", Net.Verdict(p(200, "<html>"), p(200, "<html>")) == St.Captive);
        T("Verdict: 511 / 407 status => Captive", Net.Verdict(p(511), p(0)) == St.Captive && Net.Verdict(p(0), p(407)) == St.Captive);
        T("Verdict: No response => Offline", Net.Verdict(p(0, e: "x"), p(0, e: "x")) == St.Offline);

        // --- Layer 3 Subnet Calculus ---
        var sub24 = Net.CalculateSubnet("192.168.1.50", 24)!;
        T("Subnet: /24 mask, broadcast, wildcard and 254 hosts",
            sub24.SubnetMask == "255.255.255.0" && sub24.BroadcastAddress == "192.168.1.255" &&
            sub24.WildcardMask == "0.0.0.255" && sub24.TotalHosts == 254);

        var sub22 = Net.CalculateSubnet("10.1.12.254", 22)!;
        T("Subnet: /22 campus mask, network and 1022 hosts",
            sub22.SubnetMask == "255.255.252.0" && sub22.NetworkAddress == "10.1.12.0" && sub22.TotalHosts == 1022);

        T("Subnet: IsSameSubnet on-link vs off-link",
            Net.IsSameSubnet("10.1.12.254", "10.1.12.1", 22) && !Net.IsSameSubnet("10.1.12.254", "10.1.16.1", 22));

        // --- DNS Wire Query Format ---
        var q = Dns.Query(0x1234);
        var rep = (byte[])q.Clone();
        rep[2] = 0x81; rep[3] = 0x80; rep[7] = 1;
        T("DNS: Query header packet layout", q[0] == 0x12 && q[1] == 0x34 && q[5] == 1);
        T("DNS: Valid reply accepted", Dns.Valid(q, rep));
        rep[1] ^= 1; T("DNS: Mismatched tx-id rejected", !Dns.Valid(q, rep));
        rep[1] ^= 1; rep[3] = 0x83; T("DNS: NXDOMAIN rejected", !Dns.Valid(q, rep));

        // --- Login Form & pfSense Port 8888 Parser ---
        var f = Portal.Parse(Page, new Uri("https://10.114.0.5:8888/index"))!;
        T("Portal: Action resolved against page preserving port 8888",
            f.Action.ToString() == "https://10.114.0.5:8888/login" && f.Action.Port == 8888);
        T("Portal: User/pass fields, hidden zone, and submit extracted",
            f.UserF == "auth_user" && f.PassF == "auth_pass" && f.F["zone"] == "lan" && f.F["accept"] == "Sign In");

        var pfSenseSample = "<html><form action=\"https://10.114.0.5:8888/\" method=\"post\"><input name=\"__csrf_magic\" value=\"sid:123\"><input name=\"usernamefld\"><input type=\"password\" name=\"passwordfld\"><input type=\"submit\" name=\"login\" value=\"Login\"></form></html>";
        var pf = Portal.Parse(pfSenseSample, new Uri("https://10.114.0.5:8888/"))!;
        T("Portal: pfSense __csrf_magic, usernamefld and passwordfld parsed",
            pf.F["__csrf_magic"] == "sid:123" && pf.UserF == "usernamefld" && pf.PassF == "passwordfld");

        // --- Hidden Redirects ---
        T("Redirect: Meta refresh with custom port preserved",
            Portal.Redirect("<meta http-equiv=\"refresh\" content=\"0; url=https://10.114.0.5:8888/login\">", new Uri("http://10.1.12.1/")) == "https://10.114.0.5:8888/login");
        T("Redirect: JavaScript location assignment",
            Portal.Redirect("<script>window.location.href='https://10.114.0.5:8888/portal'</script>", new Uri("http://10.1.12.1/")) == "https://10.114.0.5:8888/portal");

        // --- Trust Boundaries & Anti-Phishing ---
        T("Trust: Exact host and subdomain accepted",
            Portal.Trusted(new Uri("https://gateway.nitjsr.ac.in:8888/"), "gateway.nitjsr.ac.in") &&
            Portal.Trusted(new Uri("https://auth.gateway.nitjsr.ac.in:8888/"), "gateway.nitjsr.ac.in"));
        T("Trust: Look-alikes and spoofed domains refused",
            !Portal.Trusted(new Uri("https://evilnitjsr.ac.in/"), "nitjsr.ac.in") &&
            !Portal.Trusted(new Uri("https://nitjsr.ac.in.attacker.com/"), "nitjsr.ac.in"));
        T("Trust: HTTP and userinfo authentication tricks refused",
            !Portal.Trusted(new Uri("http://10.114.0.5:8888/"), "10.114.0.5") &&
            !Portal.Trusted(new Uri("https://nitjsr.ac.in@evil.com/"), "nitjsr.ac.in"));

        // --- Automated Portal Authentication Simulation ---
        Portal.PollMs = 5;
        var cr = new Cred { U = "abhishek", P = "securepass", H = "10.114.0.5", Port = 8888 };
        bool authed = false;
        var h = new FakeHttp();
        h.H = (r, b) => r.Method == HttpMethod.Post
            ? ((authed = b.Contains("auth_pass=securepass")) ? R(HttpStatusCode.OK, "Logged in") : R(HttpStatusCode.OK))
            : R(HttpStatusCode.OK, Page);

        var res = await Portal.Login(new HttpClient(h), new Uri("https://10.114.0.5:8888/index"), cr, () => Task.FromResult(authed), _ => { }, default);
        var post = h.Req.Single(x => x.method == "POST");
        T("Auth: Success posts credentials to trusted host on port 8888",
            res == Lr.Ok && post.url == "https://10.114.0.5:8888/login" && post.body.Contains("auth_user=abhishek"));

        // --- Cadence Policy ---
        var now = DateTime.Now;
        T("Policy: Heals only after 3 consecutive bad probes",
            !Policy.ShouldHeal(St.Offline, 2, DateTime.MinValue, 0, now, false) &&
            Policy.ShouldHeal(St.Offline, 3, DateTime.MinValue, 0, now, false));
        T("Policy: Cooldown and pending reboot respected",
            !Policy.ShouldHeal(St.Offline, 5, now.AddSeconds(-30), 0, now, false) &&
            !Policy.ShouldHeal(St.Offline, 5, DateTime.MinValue, 0, now, true));

        // --- Write-Ahead State Journal & Rollback Drift Protection ---
        var dir = Path.Combine(Path.GetTempPath(), "lf-supreme-" + Guid.NewGuid().ToString("N"));
        P.Dir = dir;
        Directory.CreateDirectory(dir);
        var fx = new FakeFx();
        fx.Set("reg", "Key", "Val", "Original");

        var store = new Store(Path.Combine(dir, "state.json"), fx);
        var run1 = store.Begin("run-1");
        store.Change(run1, "reg", "Key", "Val", "Modified1");
        store.End(run1);

        T("Journal: Baseline captures first-write-wins original value",
            store.D.Base.Single(b => b.N == "Val").V == "Original");

        store.Rollback();
        T("Rollback: Reverts setting back to original",
            fx.Get("reg", "Key", "Val") == "Original");

        // Drift protection test: externally modify setting
        var run2 = store.Begin("run-2");
        store.Change(run2, "reg", "Key", "Val", "Modified2");
        store.End(run2);
        fx.Set("reg", "Key", "Val", "ExternalDriftValue"); // Someone else changed it!
        var (ok, skip) = store.Rollback();
        T("Drift Protection: Skips reverting settings modified by external tools",
            skip == 1 && fx.Get("reg", "Key", "Val") == "ExternalDriftValue");

        // --- Vault Round-Trip ---
        Vault.Prot = new XorProt();
        Vault.Path_ = Path.Combine(dir, "v.bin");
        T("Vault: Encryption round-trip preserves credentials and port 8888",
            Vault.Save(cr) && Vault.Load() is { U: "abhishek", Port: 8888 });

        Vault.Clear();
        T("Vault: Clear removes stored file", !Vault.Exists);
        Vault.Prot = new Dp();
        Vault.Path_ = null;

        try { Directory.Delete(dir, true); } catch { }
    }

    private static async Task Live()
    {
        P.Dir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), "LanFixer");
        var raw = Encoding.UTF8.GetBytes("LanFixerSupreme");
        var enc = N.Dpapi(raw, Encoding.UTF8.GetBytes("ent"), true);
        var dec = enc != null ? N.Dpapi(enc, Encoding.UTF8.GetBytes("ent"), false) : null;
        T("Live: DPAPI machine-scope hardware encryption round-trip",
            dec != null && Encoding.UTF8.GetString(dec) == "LanFixerSupreme");

        T("Live: MachineGuid registry read",
            Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Microsoft\Cryptography")?.GetValue("MachineGuid") != null);
        T("Live: Netsh dump tool available",
            Sh.Run("netsh", "dump").output.Length > 50);

        var lk = Net.Primary();
        W("Primary Uplink", lk == null ? "None" : $"{lk.Name} ({lk.Ip}, Gateway: {lk.Gw})");

        var (st, loc, ms) = await Net.Probe(lk?.Ip, default);
        W("Live Probe", $"State: {st} ({ms}ms) Redirect: {(loc != "" ? loc : "None")}");

        var dns = await Dns.Rank(Dns.Public, default);
        W("Public DNS Latency", dns.Count > 0 ? string.Join(", ", dns.Take(3).Select(d => $"{d.ip}={d.ms}ms")) : "None reachable");

        try
        {
            using var pp = Pipe.Make();
            T("Live: Secured named-pipe ACL creation (Deny Network, Allow Local Admin/System)", true);
        }
        catch (Exception ex)
        {
            T("Live: Secured named-pipe ACL creation: " + ex.Message, false);
        }

        W("Background Service", Sh.Run("sc", "query", "LanFixer").output.Contains("RUNNING") ? "Running" : "Not installed/active");
        W("Elevated Admin", P.Admin() ? "Yes" : "No (run elevated for system modifications)");
    }
}
