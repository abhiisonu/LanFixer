using System.Text;
namespace LanFixer;

static class Program
{
    const string Help = @"LanFixer 8.0 - silent network guardian
  (no args) / dash   live console dashboard        tray        system-tray icon
  status             one-line state (exit 0 online, 10 captive/no-dns, 20 offline, 30 no link)
  repair             escalating repair (flush > DNS > DHCP/adapter)   reset   Winsock/IP stack rebuild (reboot)
  rollback           undo the last change          restore   back to ORIGINAL Windows settings
  login              sign in to the captive portal now
  tune [1|2]         careful network debloat (default 1; undo with rollback)   audit   show tune vectors (read-only)
  cred set|show|pin|clear   encrypted portal credentials (admin)
  install | uninstall [--keep] [--purge]   service + tray autostart (admin)     selftest [--logic]";

    static int Main(string[] a)
    {
        var c = a.Length > 0 ? a[0].ToLowerInvariant() : "dash";
        try
        {
            switch (c)
            {
                case "service": return Svc.Run();
                case "tray": return Tray.Run();
                case "dash": return Dash.Run();
                case "install": return Setup.Install();
                case "uninstall": return Setup.Uninstall(a.Contains("--purge"), a.Contains("--keep"));
                case "selftest": return SelfTest.Run(a.Contains("--logic"));
                case "cred": return Cred_(a);
                case "status": return Status_();
                case "tune": return Op(a.Length > 1 && a[1] == "2" ? "tune2" : "tune1");
                case "repair" or "reset" or "rollback" or "restore" or "login" or "audit":
                    if (c == "reset" && (N.Remote() || !a.Contains("--yes") && !Ask("Rebuild the network stack (backup + restore point first, reboot required)? [y/N] "))) return 1;
                    if (c == "restore" && !a.Contains("--yes") && !Ask("Restore ALL changed settings to original Windows values? [y/N] ")) return 1;
                    return Op(c);
                default: Console.WriteLine(Help); return c is "help" or "-h" or "--help" or "/?" ? 0 : 2;
            }
        }
        catch (Exception e) { Log.W("fatal: " + e); Console.Error.WriteLine(e.Message); return 1; }
    }
    static bool Ask(string q) { Console.Write(q); return Console.ReadLine()?.Trim().ToLowerInvariant() is "y" or "yes"; }

    /// <summary>Ask the service; if it is not running and we are elevated, run in-process.</summary>
    static int Op(string c)
    {
        var r = Ipc.AskSync(c);
        if (r == null) { if (!P.Admin()) { Console.Error.WriteLine("Service not running and not elevated. Run `LanFixer install`, or use an elevated prompt."); return 40; } Engine.Init(); r = Engine.Do(c).GetAwaiter().GetResult(); }
        Console.WriteLine(r); return r.StartsWith("Error") || r.StartsWith("Aborted") || r.StartsWith("Refused") || r.StartsWith("Still") ? 1 : 0;
    }

    static int Status_()
    {
        var s = Fmt.Parse(Ipc.AskSync("status", 4000));
        if (s == null) { var l = Net.Primary(); var (st, _, ms) = Net.Probe(l?.Ip, default).GetAwaiter().GetResult(); s = new Status { State = l == null ? "NoLink" : st.ToString(), Ms = ms, Adapter = l?.Name ?? "" }; }
        Console.WriteLine($"{s.State}  web={Fmt.Ms(s.Ms)} gw={Fmt.Ms(s.GwMs)} net={Fmt.Ms(s.NetMs)} loss={s.Loss}%  {s.Adapter} {s.Ip}");
        return s.State switch { "Online" => 0, "Captive" or "NoDns" => 10, "NoLink" => 30, _ => 20 };
    }

    static string Secret(string prompt)
    {
        Console.Write(prompt); var sb = new StringBuilder();
        for (ConsoleKeyInfo k; (k = Console.ReadKey(true)).Key != ConsoleKey.Enter;) { if (k.Key == ConsoleKey.Backspace) { if (sb.Length > 0) sb.Length--; } else if (k.KeyChar >= ' ') sb.Append(k.KeyChar); }
        Console.WriteLine(); return sb.ToString();
    }

    static int Cred_(string[] a)
    {
        var sub = a.Length > 1 ? a[1].ToLowerInvariant() : "show";
        if (sub != "show" && !P.Admin()) { Console.Error.WriteLine("Credentials can only be changed from an elevated prompt."); return 40; }
        P.Init();
        switch (sub)
        {
            case "clear": Vault.Clear(); Console.WriteLine("Credentials removed."); return 0;
            case "show": { var c = Vault.Load(); Console.WriteLine(c == null ? (Vault.Exists ? "Vault present but unreadable." : "No credentials saved.") : $"user={c.U}  trusted-host={c.H}  pinned-cert={(c.Pin != null ? "yes" : "no")}  password=********"); return 0; }
            case "set":
                {
                    Console.Write("Portal username: "); var u = Console.ReadLine()?.Trim() ?? ""; var p = Secret("Portal password: ");
                    string host = "";
                    var (st, loc, _) = Net.Probe(Net.Primary()?.Ip, default).GetAwaiter().GetResult();
                    if (st == St.Captive && Uri.TryCreate(loc, UriKind.Absolute, out var lu)) { Console.Write($"Detected portal host '{lu.Host}'. Trust it for sending this password? [Y/n] "); if ((Console.ReadLine() ?? "").Trim().ToLowerInvariant() is "" or "y") host = lu.Host; }
                    if (host == "") { Console.Write("Trusted portal host (e.g. login.campus.edu - password is ONLY ever sent here, over HTTPS): "); host = (Console.ReadLine() ?? "").Trim().ToLowerInvariant(); }
                    if (u == "" || p == "" || host == "") { Console.Error.WriteLine("Username, password and host are all required."); return 1; }
                    var old = Vault.Load(); var ok = Vault.Save(new Cred { U = u, P = p, H = host, Pin = old?.H == host ? old.Pin : null });
                    Console.WriteLine(ok ? "Saved (DPAPI machine-encrypted, admin-only folder). Auto-login re-enabled." : "NOT saved."); return ok ? 0 : 1;
                }
            case "pin":
                {
                    var c = Vault.Load(); if (c == null) { Console.Error.WriteLine("Save credentials first."); return 1; }
                    var fp = Portal.Fingerprint(c.H).GetAwaiter().GetResult(); if (fp == null) { Console.Error.WriteLine("Could not read the portal certificate."); return 1; }
                    Console.Write($"Portal {c.H} certificate SHA-256:\n  {fp}\nApprove this certificate for auto-login (needed only for self-signed portals)? [y/N] ");
                    if (Console.ReadLine()?.Trim().ToLowerInvariant() != "y") return 1; c.Pin = fp; return Vault.Save(c) ? 0 : 1;
                }
            default: Console.WriteLine(Help); return 2;
        }
    }
}
