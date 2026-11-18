namespace LanFixer;

/// <summary>Pure decision rules (unit-tested).</summary>
static class Policy
{
    /// <summary>Auto-heal only after 3 consecutive bad probes, 90 s apart, max 3 per hour, never while a reboot is pending.</summary>
    public static bool ShouldHeal(St s, int streak, DateTime last, int perHour, DateTime now, bool pending) =>
        !pending && s is St.Offline or St.NoDns && streak >= 3 && (now - last).TotalSeconds >= 90 && perHour < 3;
    public static int Interval(St s, bool battery) => s == St.Online ? (battery ? 30 : 15) : 4;
}

record V(string Id, int Tier, string Key, string Name, uint Val, string Desc);

static class Engine
{
    public static Store S = null!;
    public static readonly SemaphoreSlim Gate = new(1, 1);
    public static bool Busy => Gate.CurrentCount == 0;
    static DateTime _lastLogin; static int _fails;
    static string Pend => Path.Combine(P.Dir, "reboot.pending");
    static string Dis => Path.Combine(P.Dir, "adapter.disabled");

    public static void Init()
    {
        P.Init(); S = new Store(P.Db, new WinFx());
        try { if (File.Exists(Dis)) { Sh.Run("netsh", "interface", "set", "interface", $"name={File.ReadAllText(Dis)}", "admin=enabled"); File.Delete(Dis); Log.W("re-enabled adapter left disabled by an interrupted repair"); } } catch { }
    }
    public static bool Pending
    {
        get { try { if (!File.Exists(Pend)) return false; if (File.GetLastWriteTime(Pend) < DateTime.Now.AddMilliseconds(-Environment.TickCount64)) { File.Delete(Pend); return false; } return true; } catch { return false; } }
    }

    // ---- the careful network debloat set (same vectors and values as the original script) ----
    const string SP = @"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile";
    public static readonly V[] Vs =
    {
        new("DO", 1, @"SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization", "DODownloadMode", 0, "Windows-update P2P uploads over your link"),
        new("NT", 1, SP, "NetworkThrottlingIndex", 0xFFFFFFFF, "Multimedia cap on network packet rate"),
        new("SR", 1, SP, "SystemResponsiveness", 0, "CPU share reserved away from network processing"),
        new("WP", 1, @"SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad", "WpadOverride", 1, "WPAD automatic proxy probing"),
        new("LL", 2, @"SOFTWARE\Policies\Microsoft\Windows NT\DNSClient", "EnableMulticast", 0, "LLMNR multicast name resolution"),
        new("TL", 2, @"SOFTWARE\Policies\Microsoft\Windows\DataCollection", "AllowTelemetry", 0, "Telemetry network chatter"),
    };
    static bool Optimal(V v, string? cur) => cur != null && (cur == v.Val.ToString() || (v.Id == "DO" && cur == "1"));

    public static string Audit() => string.Join("\n", Vs.Select(v => { string? c; try { c = S.Cur("reg", v.Key, v.Name); } catch { c = "?"; } return $"T{v.Tier} {(Optimal(v, c) ? "optimal" : "default/bloated"),-16} {v.Name} = {c ?? "(not set)"}  - {v.Desc}"; }));

    public static string Tune(int tier)
    {
        var run = S.Begin("tune-" + tier); int n = 0, skip = 0;
        try
        {
            foreach (var v in Vs.Where(v => v.Tier <= tier))
                try { if (!Optimal(v, S.Cur("reg", v.Key, v.Name)) && S.Change(run, "reg", v.Key, v.Name, v.Val.ToString())) n++; }
                catch (Exception e) { skip++; Log.W($"tune skipped {v.Name}: {e.Message}"); }
            if (tier >= 2) foreach (var t in new[] { "teredo", "6to4", "isatap" }) if (S.Change(run, "tdo", t, "", "disabled")) n++;
        }
        finally { S.End(run); }
        Flush(); return $"Tune tier {tier}: {n} changed, {skip} skipped. Undo any time with Rollback.";
    }

    // ---- repair ladder ----
    static string? Bind(Link? l) => l is { Ip.Length: > 0 } && !l.Ip.StartsWith("169.254.") ? l.Ip : null;
    static void Flush() { Sh.Run("ipconfig", "/flushdns"); Sh.Run("netsh", "interface", "ip", "delete", "arpcache"); Sh.Run("nbtstat", "-R"); Sh.Run("nbtstat", "-RR"); }

    static async Task DnsFix(Link? lk, Run run, CancellationToken ct)
    {
        if (lk == null) return;
        if ((await Dns.Rank(Dns.Current(lk.Id), ct)).Count > 0) return;                 // current resolvers answer: DNS is not the problem
        var good = (await Dns.Rank(Dns.Public, ct)).Take(2).Select(x => x.ip).ToList();
        if (good.Count > 0 && S.Change(run, "dns", lk.Id, "", string.Join(",", good))) Log.W("DNS rescue on " + lk.Name + ": " + string.Join(",", good));
    }
    static async Task<bool> WaitIp(int s, CancellationToken ct)
    {
        for (int i = 0; i < s; i++) { if (Bind(Net.Primary()) != null && Net.Primary()!.Gw != "") return true; await Task.Delay(1000, ct); }
        return false;
    }
    static async Task Cycle(Link? lk, CancellationToken ct)
    {
        var name = lk?.Name ?? Net.Primary()?.Name; if (name == null) return;
        Sh.Run("ipconfig", "/renew", name); if (await WaitIp(5, ct)) return;
        try { File.WriteAllText(Dis, name); Sh.Run("netsh", "interface", "set", "interface", $"name={name}", "admin=disabled"); await Task.Delay(1500, ct); }
        finally { for (int i = 0; i < 3; i++) { if (Sh.Run("netsh", "interface", "set", "interface", $"name={name}", "admin=enabled").code == 0) { File.Delete(Dis); break; } await Task.Delay(1000); } }
        await WaitIp(15, ct); Sh.Run("ipconfig", "/renew", name); await WaitIp(10, ct);
    }
    static async Task Level(int l, Run run, CancellationToken ct)
    {
        var lk = Net.Primary();
        if (l == 1) Flush();
        else if (l == 2) { await DnsFix(lk, run, ct); Sh.Run("net", "stop", "NlaSvc", "/y"); Sh.Run("net", "start", "NlaSvc"); }
        else await Cycle(lk, ct);
    }

    /// <summary>Escalating, self-verifying repair: flush -> DNS rescue + NLA refresh -> DHCP renew / adapter cycle. Stops at the first level that restores internet.</summary>
    static async Task<string> Heal(int max, bool auto, CancellationToken ct)
    {
        var run = S.Begin(auto ? "auto-heal" : "repair");
        try
        {
            var p = await Net.Probe(Bind(Net.Primary()), ct);
            if (p.s == St.Online) return "Already online - nothing to repair.";
            if (p.s == St.Captive) { var m = await LoginCore(!auto, ct); if (m.StartsWith("Signed in")) return m; }
            for (int l = 1; l <= max; l++)
            {
                Log.W($"repair level {l} ({p.s})"); await Level(l, run, ct); await Task.Delay(l == 3 ? 3000 : 1000, ct);
                p = await Net.Probe(Bind(Net.Primary()), ct);
                if (p.s == St.Online) return $"Repaired at level {l}.";
                if (p.s == St.Captive) return await LoginCore(!auto, ct);
            }
            return $"Still {p.s} after level {max}. Try Reset (stack rebuild) or check the cable/router.";
        }
        finally { S.End(run); }
    }

    /// <summary>Level 4: Winsock/IP stack rebuild. Needs a reboot. Backs up first (netsh dump + restore point) and refuses if the backup fails.</summary>
    static async Task<string> Reset(CancellationToken ct)
    {
        var dump = Store.Dump(); if (dump == null) return "Aborted: could not write the safety backup, nothing was changed.";
        bool rp = N.RestorePoint("LanFixer pre-reset");
        var run = S.Begin("stack-reset"); Log.W("STACK RESET started");
        Sh.Run("netsh", "winsock", "reset"); Sh.RunT(60000, "netsh", "int", "ip", "reset"); Sh.Run("netsh", "int", "ipv6", "reset"); Sh.Run("netsh", "winhttp", "reset", "proxy"); Sh.Run("ipconfig", "/flushdns");
        File.WriteAllText(Pend, DateTime.Now.ToString("o")); S.End(run); await Task.CompletedTask;
        return $"Stack reset complete - RESTART REQUIRED. Backup: {dump}" + (rp ? " + system restore point." : " (no restore point: Windows allows one per 24 h).");
    }

    public static string Rollback() { var (ok, sk) = S.Rollback(); return ok + sk == 0 ? "Nothing to roll back." : $"Rolled back last change: {ok} restored" + (sk > 0 ? $", {sk} skipped (changed by something else since)." : "."); }
    public static string Restore() { int n = S.RestoreAll(); Flush(); return $"Restored {n} setting(s) to their original Windows values."; }

    // ---- captive portal ----
    public static async Task<string> LoginCore(bool manual, CancellationToken ct)
    {
        var cr = Vault.Load(); if (cr == null) return "No saved credentials (run: LanFixer cred set).";
        if (!manual)
        {
            if (File.Exists(P.Susp)) return "Auto-login paused: the portal rejected the saved password. Re-save credentials to resume.";
            if ((DateTime.UtcNow - _lastLogin).TotalSeconds < 45) return "throttled";
        }
        _lastLogin = DateTime.UtcNow; var bind = Bind(Net.Primary());
        var p = await Net.Probe(bind, ct); if (p.s != St.Captive) return p.s == St.Online ? "Already online." : "Not behind a login page right now.";
        Uri start; try { start = p.loc != "" ? new UriBuilder(p.loc) { Scheme = "https", Port = -1 }.Uri : new Uri("https://" + cr.H + "/"); } catch { return "Bad redirect from network."; }
        using var c = Net.Client(bind, cr.Pin, true);
        var r = await Portal.Login(c, start, cr, async () => (await Net.Probe(bind, ct)).s == St.Online, Log.W, ct);
        switch (r)
        {
            case Lr.Ok: _fails = 0; Log.W("portal sign-in OK"); return "Signed in to the portal.";
            case Lr.Rejected or Lr.Ambiguous:
                if (++_fails >= 2) { File.WriteAllText(P.Susp, "1"); return "Portal did not accept the login twice - auto-login paused to avoid locking your account."; }
                return "Portal did not accept the login (one more automatic try allowed).";
            case Lr.Refused: return "Refused: this network's login page is not your trusted portal. Password NOT sent.";
            default: return "Login failed: " + r;
        }
    }

    /// <summary>Single entry point for every command (service pipe, CLI, tray, dashboard). One operation at a time.</summary>
    public static async Task<string> Do(string cmd, CancellationToken ct = default)
    {
        if (!await Gate.WaitAsync(0, ct)) return "Busy: another operation is running.";
        try
        {
            return cmd switch
            {
                "repair" => await Heal(3, false, ct), "auto" => await Heal(3, true, ct), "reset" => await Reset(ct), "rollback" => Rollback(), "restore" => Restore(),
                "login" => await LoginCore(true, ct), "autologin" => await LoginCore(false, ct), "tune1" => Tune(1), "tune2" => Tune(2), "audit" => Audit(), _ => "Unknown command."
            };
        }
        catch (OperationCanceledException) { return "Cancelled."; }
        catch (Exception e) { Log.W("ERROR " + e.Message); return "Error: " + e.Message; }
        finally { Gate.Release(); }
    }
}
