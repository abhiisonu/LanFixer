using System.Net.NetworkInformation;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;
using Microsoft.Win32;

namespace LanFixer;

/// <summary>
/// Autonomous decision rules and cadence policy.
/// </summary>
public static class Policy
{
    public static bool ShouldHeal(St s, int streak, DateTime last, int perHour, DateTime now, bool pending) =>
        !pending && s is St.Offline or St.NoDns && streak >= 3 && (now - last).TotalSeconds >= 90 && perHour < 3;

    public static int Interval(St s, bool battery) =>
        s == St.Online ? (battery ? 30 : 15) : 4;
}

public record V(string Id, int Tier, string Key, string Name, uint Val, string Desc);

public static class Engine
{
    public static Store S = null!;
    public static readonly SemaphoreSlim Gate = new(1, 1);
    public static bool Busy => Gate.CurrentCount == 0;
    private static DateTime _lastLogin;
    private static int _fails;
    private static string Pend => Path.Combine(P.Dir, "reboot.pending");
    private static string Dis => Path.Combine(P.Dir, "adapter.disabled");

    public static void Init()
    {
        P.Init();
        S = new Store(P.Db, new WinFx());
        try
        {
            if (File.Exists(Dis))
            {
                Sh.Run("netsh", "interface", "set", "interface", $"name={File.ReadAllText(Dis)}", "admin=enabled");
                File.Delete(Dis);
                Log.W("Re-enabled adapter left disabled by an interrupted repair");
            }
        }
        catch { }
    }

    public static bool Pending
    {
        get
        {
            try
            {
                if (!File.Exists(Pend)) return false;
                if (File.GetLastWriteTime(Pend) < DateTime.Now.AddMilliseconds(-Environment.TickCount64))
                {
                    File.Delete(Pend);
                    return false;
                }
                return true;
            }
            catch { return false; }
        }
    }

    // ---- Network Debloat Vectors ----
    private const string SP = @"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile";
    public static readonly V[] Vs =
    {
        new("DO", 1, @"SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization", "DODownloadMode", 0, "Disable Windows Update P2P uploads over your network"),
        new("NT", 1, SP, "NetworkThrottlingIndex", 0xFFFFFFFF, "Disable multimedia cap on network packet processing"),
        new("SR", 1, SP, "SystemResponsiveness", 0, "Zero CPU reservation away from network packet queues"),
        new("WP", 1, @"SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad", "WpadOverride", 1, "Disable rogue WPAD automatic proxy probing"),
        new("LL", 2, @"SOFTWARE\Policies\Microsoft\Windows NT\DNSClient", "EnableMulticast", 0, "Disable LLMNR multicast name resolution"),
        new("TL", 2, @"SOFTWARE\Policies\Microsoft\Windows\DataCollection", "AllowTelemetry", 0, "Disable background diagnostic network telemetry chatter")
    };

    private static bool Optimal(V v, string? cur) =>
        cur != null && (cur == v.Val.ToString() || (v.Id == "DO" && cur == "1"));

    public static string Audit() =>
        string.Join("\r\n", Vs.Select(v =>
        {
            string? c;
            try { c = S.Cur("reg", v.Key, v.Name); }
            catch { c = "?"; }
            return $"T{v.Tier} {(Optimal(v, c) ? "optimal" : "bloated"),-12} {v.Name,-25} = {c ?? "(not set)",-12} - {v.Desc}";
        }));

    public static string Tune(int tier)
    {
        var run = S.Begin("tune-" + tier);
        int n = 0, skip = 0;
        try
        {
            foreach (var v in Vs.Where(v => v.Tier <= tier))
            {
                try
                {
                    if (!Optimal(v, S.Cur("reg", v.Key, v.Name)) && S.Change(run, "reg", v.Key, v.Name, v.Val.ToString()))
                        n++;
                }
                catch (Exception e)
                {
                    skip++;
                    Log.W($"Tune skipped {v.Name}: {e.Message}");
                }
            }
            if (tier >= 2)
            {
                foreach (var t in new[] { "teredo", "6to4", "isatap" })
                    if (S.Change(run, "tdo", t, "", "disabled")) n++;
            }
        }
        finally { S.End(run); }
        Flush();
        return $"Tune tier {tier}: {n} optimized, {skip} skipped. (Revert anytime with 'rollback')";
    }

    // ---- Repair Ladder & Route Metrics ----
    private static string? Bind(Link? l) =>
        l is { Ip.Length: > 0 } && !l.Ip.StartsWith("169.254.") ? l.Ip : null;

    public static void Flush()
    {
        Sh.Run("ipconfig", "/flushdns");
        Sh.Run("netsh", "interface", "ip", "delete", "arpcache");
        Sh.Run("nbtstat", "-R");
        Sh.Run("nbtstat", "-RR");
    }

    private static async Task DnsFix(Link? lk, Run run, CancellationToken ct)
    {
        if (lk == null) return;
        if ((await Dns.Rank(Dns.Current(lk.Id), ct)).Count > 0) return; // Resolvers work fine

        var good = (await Dns.Rank(Dns.Public, ct)).Take(2).Select(x => x.ip).ToList();
        if (good.Count > 0 && S.Change(run, "dns", lk.Id, "", string.Join(",", good)))
            Log.W($"DNS rescue on {lk.Name}: {string.Join(",", good)}");
    }

    private static async Task<bool> WaitIp(int s, CancellationToken ct)
    {
        for (int i = 0; i < s; i++)
        {
            var p = Net.Primary();
            if (Bind(p) != null && p!.Gw != "") return true;
            await Task.Delay(1000, ct);
        }
        return false;
    }

    private static async Task Cycle(Link? lk, CancellationToken ct)
    {
        var name = lk?.Name ?? Net.Primary()?.Name;
        if (name == null) return;
        Sh.Run("ipconfig", "/renew", name);
        if (await WaitIp(5, ct)) return;

        try
        {
            File.WriteAllText(Dis, name);
            Sh.Run("netsh", "interface", "set", "interface", $"name={name}", "admin=disabled");
            await Task.Delay(1500, ct);
        }
        finally
        {
            for (int i = 0; i < 3; i++)
            {
                if (Sh.Run("netsh", "interface", "set", "interface", $"name={name}", "admin=enabled").code == 0)
                {
                    File.Delete(Dis);
                    break;
                }
                await Task.Delay(1000, ct);
            }
        }
        await WaitIp(15, ct);
        Sh.Run("ipconfig", "/renew", name);
        await WaitIp(10, ct);
    }

    private static async Task Level(int l, Run run, CancellationToken ct)
    {
        var lk = Net.Primary();
        if (l == 1)
        {
            Flush();
        }
        else if (l == 2)
        {
            await DnsFix(lk, run, ct);
            Sh.Run("net", "stop", "NlaSvc", "/y");
            Sh.Run("net", "start", "NlaSvc");
        }
        else
        {
            await Cycle(lk, ct);
        }
    }

    /// <summary>
    /// Escalating, self-verifying repair ladder with dynamic route metric arbitration.
    /// </summary>
    public static async Task<string> Heal(int max, bool auto, CancellationToken ct)
    {
        var run = S.Begin(auto ? "auto-heal" : "repair");
        try
        {
            var lk = Net.Primary();
            var p = await Net.Probe(Bind(lk), ct);

            // Apply route shield to prevent unauthenticated Ethernet from blocking working Wi-Fi
            Net.ApplyRouteShield(S, lk, p.s);

            if (p.s == St.Online) return "Already online - connectivity verified.";
            if (p.s == St.Captive)
            {
                var m = await LoginCore(!auto, ct);
                if (m.StartsWith("Signed in"))
                {
                    Net.ApplyRouteShield(S, Net.Primary(), St.Online);
                    return m;
                }
            }

            for (int l = 1; l <= max; l++)
            {
                Log.W($"Executing repair level {l} ({p.s})");
                await Level(l, run, ct);
                await Task.Delay(l == 3 ? 3000 : 1000, ct);

                lk = Net.Primary();
                p = await Net.Probe(Bind(lk), ct);
                Net.ApplyRouteShield(S, lk, p.s);

                if (p.s == St.Online) return $"Repaired successfully at level {l}.";
                if (p.s == St.Captive)
                {
                    var lm = await LoginCore(!auto, ct);
                    if (lm.StartsWith("Signed in"))
                    {
                        Net.ApplyRouteShield(S, Net.Primary(), St.Online);
                        return lm;
                    }
                    return lm;
                }
            }
            return $"Still {p.s} after level {max}. Try 'reset' (stack rebuild) or inspect cable/uplink.";
        }
        finally { S.End(run); }
    }

    /// <summary>
    /// Level 4: Deep Winsock/TCP-IP stack rebuild. Backs up first (netsh dump + System Restore point).
    /// </summary>
    public static async Task<string> Reset(CancellationToken ct)
    {
        var dump = Store.Dump();
        if (dump == null) return "Aborted: Safety backup failed, nothing was modified.";

        bool rp = N.RestorePoint("LanFixer pre-reset");
        var run = S.Begin("stack-reset");
        Log.W("STACK RESET started");

        Sh.Run("netsh", "winsock", "reset");
        Sh.RunT(60000, "netsh", "int", "ip", "reset");
        Sh.Run("netsh", "int", "ipv6", "reset");
        Sh.Run("netsh", "winhttp", "reset", "proxy");
        Sh.Run("ipconfig", "/flushdns");

        File.WriteAllText(Pend, DateTime.Now.ToString("o"));
        S.End(run);
        await Task.CompletedTask;

        return $"Stack reset complete - REBOOT REQUIRED. Backup: {dump}" +
               (rp ? " (System restore point created)" : " (Windows 24h restore point rate limit in effect)");
    }

    public static string Rollback()
    {
        var (ok, sk) = S.Rollback();
        return ok + sk == 0 ? "Nothing to roll back." :
            $"Rolled back last operation: {ok} restored" + (sk > 0 ? $", {sk} skipped (externally changed)." : ".");
    }

    public static string Restore()
    {
        int n = S.RestoreAll();
        Flush();
        return $"Restored {n} setting(s) to original Windows defaults.";
    }

    // ---- Captive Portal Authentication (Fixed Port 8888 Handling) ----
    public static async Task<string> LoginCore(bool manual, CancellationToken ct)
    {
        var cr = Vault.Load();
        if (cr == null) return "No saved credentials (run: 'LanFixer cred set').";

        if (!manual)
        {
            if (File.Exists(P.Susp))
                return "Auto-login paused: Portal rejected saved password. Re-save credentials to resume.";
            if ((DateTime.UtcNow - _lastLogin).TotalSeconds < 45)
                return "throttled";
        }

        _lastLogin = DateTime.UtcNow;
        var bind = Bind(Net.Primary());
        var p = await Net.Probe(bind, ct);
        if (p.s != St.Captive)
            return p.s == St.Online ? "Already online." : "Not behind a captive portal login page.";

        // FIX: Preserve custom port (8888) instead of stripping it!
        Uri start;
        try
        {
            if (!string.IsNullOrEmpty(p.loc))
            {
                var ub = new UriBuilder(p.loc) { Scheme = "https" };
                if (ub.Port <= 0 || ub.Port == 80) ub.Port = cr.Port > 0 ? cr.Port : 8888;
                start = ub.Uri;
            }
            else
            {
                int pt = cr.Port > 0 ? cr.Port : 8888;
                start = new Uri($"https://{cr.H}:{pt}/");
            }
        }
        catch { return "Invalid redirect URI from captive portal."; }

        using var c = Net.Client(bind, cr.Pin, cookies: true);
        var r = await Portal.Login(c, start, cr, async () => (await Net.Probe(bind, ct)).s == St.Online, Log.W, ct);

        switch (r)
        {
            case Lr.Ok:
                _fails = 0;
                Log.W("Portal sign-in verified: Online");
                Net.ApplyRouteShield(S, Net.Primary(), St.Online);
                return "Signed in to the portal successfully.";

            case Lr.Rejected or Lr.Ambiguous:
                if (++_fails >= 2)
                {
                    File.WriteAllText(P.Susp, "1");
                    return "Portal rejected credentials twice - auto-login paused to prevent account lockout.";
                }
                return "Portal did not accept credentials (1 retry remaining).";

            case Lr.Refused:
                return "Refused: Target login host does not match trusted host. Password NOT sent.";

            default:
                return "Login failed: " + r;
        }
    }

    #region Hardware Power-Save Shield (NDIS PnP Sleep Blocker)

    public static string PnpShield()
    {
        if (!P.Admin()) return "Error: Administrative privileges required.";
        var primary = Net.Primary();
        if (primary == null) return "No active primary network adapter found.";

        const string classPath = @"SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}";
        using var classKey = Registry.LocalMachine.OpenSubKey(classPath);
        if (classKey == null) return "Error: Network class registry key not found.";

        int touched = 0;
        var run = S.Begin("pnp");
        try
        {
            var ifaces = NetworkInterface.GetAllNetworkInterfaces();
            foreach (var sub in classKey.GetSubKeyNames())
            {
                using var sk = classKey.OpenSubKey(sub);
                var guid = sk?.GetValue("NetCfgInstanceId") as string;
                if (string.IsNullOrEmpty(guid)) continue;

                var match = ifaces.FirstOrDefault(n => n.Id.Equals(guid, StringComparison.OrdinalIgnoreCase));
                if (match == null) continue;

                var pnp = sk?.GetValue("PnPCapabilities");
                int curPnp = pnp is int i ? i : (pnp is uint u ? (int)u : 0);
                if (curPnp != 24)
                {
                    string targetKey = $@"{classPath}\{sub}";
                    if (S.Change(run, "pnp", targetKey, "PnPCapabilities", "24"))
                        touched++;
                }
            }
        }
        finally { S.End(run); }

        return touched > 0
            ? $"[OK] Hardware Power-Save Shield enforced on {touched} adapter(s). Device sleep disabled."
            : "[OK] Hardware Power-Save Shield already active on all network adapters.";
    }

    #endregion

    #region Path MTU Black-Hole Optimizer

    public static string MtuOptimize()
    {
        if (!P.Admin()) return "Error: Administrative privileges required.";
        var primary = Net.Primary();
        if (primary == null) return "No active primary network adapter found.";

        var (optimal, _) = Mtu.Sweep();
        var currentStr = S.Cur("mtu", primary.Id, "");
        int current = int.TryParse(currentStr, out var cVal) ? cVal : 1500;

        if (optimal == current)
            return $"[OK] Current MTU ({current}) on {primary.Name} is already optimal for this uplink.";

        var run = S.Begin("mtu");
        try
        {
            S.Change(run, "mtu", primary.Id, "", optimal.ToString());
        }
        finally { S.End(run); }

        return $"[OK] Clamped MTU on {primary.Name} from {current} to {optimal} (Path MTU bottleneck resolved).";
    }

    #endregion

    #region Multi-Target Anycast & DNS Benchmark

    public static async Task<string> BenchmarkAsync(CancellationToken ct = default)
    {
        var primary = Net.Primary();
        var results = await Bench.RunAsync(primary?.Gw, ct);
        var sb = new StringBuilder();
        sb.AppendLine("============================================================================");
        sb.AppendLine("  LANFIXER ANYCAST & DNS BENCHMARK SUITE");
        sb.AppendLine("============================================================================");
        sb.AppendLine($"  Primary Uplink: {primary?.Name ?? "None"} ({primary?.Ip ?? "No IP"}) | Gateway: {primary?.Gw ?? "None"}\n");
        sb.AppendLine($"  {"Target",-12} {"Endpoint",-16} {"Min",-6} {"Avg",-6} {"Max",-6} {"Jitter",-8} {"Loss",-6} {"DNS",-6}");
        sb.AppendLine("  " + new string('-', 72));

        foreach (var r in results)
        {
            string min = r.PingMin >= 0 ? r.PingMin + "ms" : "--";
            string avg = r.PingAvg >= 0 ? r.PingAvg + "ms" : "--";
            string max = r.PingMax >= 0 ? r.PingMax + "ms" : "--";
            string jit = r.PingAvg >= 0 ? r.JitterMs + "ms" : "--";
            string loss = r.LossPct + "%";
            string dns = r.DnsMs >= 0 ? r.DnsMs + "ms" : "--";
            sb.AppendLine($"  {r.Name,-12} {r.Ip,-16} {min,-6} {avg,-6} {max,-6} {jit,-8} {loss,-6} {dns,-6}");
        }
        return sb.ToString();
    }

    #endregion

    #region Diagnostic Bundle Generator

    public static string CreateBundle() => Task.Run(() => CreateBundleAsync()).GetAwaiter().GetResult();

    public static async Task<string> CreateBundleAsync(CancellationToken ct = default)
    {
        try
        {
            if (S == null) Init();
            Directory.CreateDirectory(P.Dir);
            var outFile = Path.Combine(P.Dir, $"diagnostics-bundle-{DateTime.Now:yyyyMMdd-HHmmss}.json");

            var doc = Doctor.Run();
            var primary = Net.Primary();
            var (optimalMtu, _) = Mtu.Sweep();

            var ifaces = NetworkInterface.GetAllNetworkInterfaces().Select(n =>
            {
                var ipProps = n.GetIPProperties();
                var ipv4 = ipProps.UnicastAddresses.FirstOrDefault(a => a.Address.AddressFamily == AddressFamily.InterNetwork);
                var gw = ipProps.GatewayAddresses.FirstOrDefault(a => a.Address.AddressFamily == AddressFamily.InterNetwork)?.Address.ToString() ?? "";
                var dns = ipProps.DnsAddresses.Where(a => a.AddressFamily == AddressFamily.InterNetwork).Select(a => a.ToString()).ToList();

                return new LinkInfo
                {
                    Name = n.Name,
                    Description = n.Description,
                    Id = n.Id,
                    Status = n.OperationalStatus.ToString(),
                    SpeedMbps = n.Speed / 1_000_000,
                    Ipv4 = ipv4?.Address.ToString() ?? "",
                    Subnet = ipv4?.IPv4Mask?.ToString() ?? "",
                    Gateway = gw,
                    Dns = dns
                };
            }).ToList();

            var (_, routeTxt) = Sh.Run("route", "print", "-4");
            var (_, arpTxt) = Sh.Run("arp", "-a");

            var bench = await Bench.RunAsync(primary?.Gw, ct);

            var bundle = new DiagnosticsBundle
            {
                GeneratedAt = DateTime.UtcNow.ToString("o"),
                OsVersion = Environment.OSVersion.ToString(),
                MachineId = Vault.Exists ? "Configured" : "None",
                Doctor = doc,
                Adapters = ifaces,
                RoutingTable = routeTxt,
                ArpTable = arpTxt,
                Benchmarks = bench,
                OptimalMtu = optimalMtu,
                JournalBase = S?.D.Base ?? new(),
                JournalRuns = S?.D.Runs ?? new()
            };

            var json = JsonSerializer.Serialize(bundle, J.Default.DiagnosticsBundle);
            await File.WriteAllTextAsync(outFile, json, ct);

            return $"[OK] Diagnostics bundle generated successfully:\n     {outFile} ({new FileInfo(outFile).Length / 1024} KB)";
        }
        catch (Exception ex)
        {
            return "Error generating bundle: " + ex.Message;
        }
    }

    #endregion

    #region Keep-Alive Heartbeat

    public static async Task<string> KeepAliveAsync(CancellationToken ct = default)
    {
        var primary = Net.Primary();
        if (primary == null) return "No active network link.";

        var (st, _, ms) = await Net.Probe(primary.Ip, ct);
        if (st == St.Captive)
        {
            Log.W("Keep-alive pulse detected captive session. Initiating re-authentication...");
            return await LoginCore(false, ct);
        }

        return $"[OK] Network session active (egress probe: {ms}ms, state: {st}).";
    }

    #endregion

    public static async Task<string> Do(string cmd, CancellationToken ct = default)
    {
        if (!await Gate.WaitAsync(0, ct)) return "Busy: another operation is in progress.";
        try
        {
            return cmd switch
            {
                "repair" => await Heal(3, false, ct),
                "auto" => await Heal(3, true, ct),
                "reset" => await Reset(ct),
                "rollback" => Rollback(),
                "restore" => Restore(),
                "login" => await LoginCore(true, ct),
                "autologin" => await LoginCore(false, ct),
                "tune1" => Tune(1),
                "tune2" => Tune(2),
                "audit" => Audit(),
                "pnp" => PnpShield(),
                "mtu" => MtuOptimize(),
                "bench" => await BenchmarkAsync(ct),
                "bundle" => await CreateBundleAsync(ct),
                "keepalive" => await KeepAliveAsync(ct),
                _ => "Unknown command."
            };
        }
        catch (OperationCanceledException) { return "Cancelled."; }
        catch (Exception e)
        {
            Log.W("ERROR: " + e.Message);
            return "Error: " + e.Message;
        }
        finally { Gate.Release(); }
    }
}
