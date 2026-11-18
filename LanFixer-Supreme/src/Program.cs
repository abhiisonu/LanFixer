using System.Text;
using System.Text.Json;

namespace LanFixer;

static class Program
{
    const string Help = @"LanFixer Supreme v8.5 - Dual-Core Autonomous Network Guardian
  (no args) / dash   Interactive live console dashboard
  tray               Pure Win32 zero-resource notification tray icon
  doctor [--json]    Run 7-layer OSI Health Doctor deep diagnostic report
  status [--json]    Query connection health & exit with granular status code
  repair             Escalating 3-tier repair (Flush -> DNS -> Adapter reset + Route Shield)
  reset [--yes]      Winsock/IP stack rebuild (System Restore point + netsh backup)
  rollback           Undo the last network change (with drift protection)
  restore [--yes]    Revert ALL changed parameters to baseline Windows settings
  login              Trigger instant captive portal authentication (pfSense port 8888 safe)
  tune [1|2]         Precision network debloat (Tier 1 safe / Tier 2 advanced; undo with rollback)
  audit              Read-only display of tuning parameters and current values
  cred [set|show|pin|clear]   Manage DPAPI-encrypted portal credentials
  install            Install background Windows Service + auto-start tray
  uninstall [--keep] [--purge] Remove background service & clean up logs/vault
  selftest [--logic] Run full test suite (50+ unit tests + live OS stack probes)";

    static int Main(string[] a)
    {
        Console.OutputEncoding = Encoding.UTF8;
        var c = a.Length > 0 ? a[0].ToLowerInvariant() : "dash";
        try
        {
            switch (c)
            {
                case "service": return Svc.Run();
                case "tray": return Tray.Run();
                case "dash": return Dash.Run();
                case "doctor": return Doctor_(a);
                case "status": return Status_(a);
                case "install": return Setup.Install();
                case "uninstall": return Setup.Uninstall(a.Contains("--purge"), a.Contains("--keep"));
                case "selftest": return SelfTest.Run(a.Contains("--logic"));
                case "cred": return Cred_(a);
                case "tune": return Op(a.Length > 1 && a[1] == "2" ? "tune2" : "tune1");
                case "repair" or "heal": return Op("repair");
                case "reset" or "rollback" or "restore" or "login" or "audit":
                    if (c == "reset" && (N.Remote() || (!a.Contains("--yes") && !Ask("Rebuild the network stack (backup + restore point first, reboot required)? [y/N] ")))) return 1;
                    if (c == "restore" && (!a.Contains("--yes") && !Ask("Restore ALL changed settings to original Windows values? [y/N] "))) return 1;
                    return Op(c);
                default:
                    Console.WriteLine(Help);
                    return c is "help" or "-h" or "--help" or "/?" ? 0 : 2;
            }
        }
        catch (Exception e)
        {
            Log.W("fatal: " + e);
            Console.Error.WriteLine("Error: " + e.Message);
            return 1;
        }
    }

    static bool Ask(string q)
    {
        Console.Write(q);
        return Console.ReadLine()?.Trim().ToLowerInvariant() is "y" or "yes";
    }

    /// <summary>
    /// Ask the background service via IPC pipe. If it is not running and we are elevated, run directly in-process.
    /// </summary>
    static int Op(string c)
    {
        var r = Ipc.AskSync(c);
        if (r == null)
        {
            if (!P.Admin())
            {
                Console.Error.WriteLine("Service not running and not elevated. Run `LanFixer install`, or use an elevated prompt.");
                return 40;
            }
            Engine.Init();
            r = Engine.Do(c).GetAwaiter().GetResult();
        }
        Console.WriteLine(r);
        return r.StartsWith("Error") || r.StartsWith("Aborted") || r.StartsWith("Refused") || r.StartsWith("Still") ? 1 : 0;
    }

    static int Doctor_(string[] a)
    {
        var rep = Doctor.Run();
        if (a.Contains("--json"))
        {
            Console.WriteLine(JsonSerializer.Serialize(rep, J.Default.DoctorReport));
        }
        else
        {
            Doctor.PrintConsole(rep);
        }
        return rep.ExitCode;
    }

    static int Status_(string[] a)
    {
        var jsonMode = a.Contains("--json");
        var s = Fmt.Parse(Ipc.AskSync("status", 4000));
        if (s == null)
        {
            var l = Net.Primary();
            var (st, _, ms) = Net.Probe(l?.Ip, default).GetAwaiter().GetResult();
            s = new Status
            {
                State = l == null ? "NoLink" : st.ToString(),
                Ms = ms,
                Adapter = l?.Name ?? "",
                Ip = l?.Ip ?? ""
            };
        }
        if (jsonMode)
        {
            Console.WriteLine(JsonSerializer.Serialize(s, J.Default.Status));
        }
        else
        {
            Console.WriteLine($"{s.State,-8} web={Fmt.Ms(s.Ms)} gw={Fmt.Ms(s.GwMs)} net={Fmt.Ms(s.NetMs)} loss={s.Loss}%  {s.Adapter} {s.Ip}");
        }
        return s.State switch
        {
            "Online" => 0,
            "Captive" or "NoDns" => 10,
            "NoLink" => 30,
            _ => 20
        };
    }

    static string Secret(string prompt)
    {
        Console.Write(prompt);
        var sb = new StringBuilder();
        for (ConsoleKeyInfo k; (k = Console.ReadKey(true)).Key != ConsoleKey.Enter;)
        {
            if (k.Key == ConsoleKey.Backspace)
            {
                if (sb.Length > 0) sb.Length--;
            }
            else if (k.KeyChar >= ' ')
            {
                sb.Append(k.KeyChar);
            }
        }
        Console.WriteLine();
        return sb.ToString();
    }

    static int Cred_(string[] a)
    {
        var sub = a.Length > 1 ? a[1].ToLowerInvariant() : "show";
        if (sub != "show" && !P.Admin())
        {
            Console.Error.WriteLine("Credentials can only be changed from an elevated prompt.");
            return 40;
        }
        P.Init();
        switch (sub)
        {
            case "clear":
                Vault.Clear();
                Console.WriteLine("Credentials removed from secure DPAPI vault.");
                return 0;

            case "show":
            {
                var c = Vault.Load();
                if (c == null)
                {
                    Console.WriteLine(Vault.Exists ? "Vault file present but unreadable on this machine." : "No credentials saved in vault.");
                }
                else
                {
                    Console.WriteLine($"user={c.U}  trusted-host={c.H}  port={c.Port}  pinned-cert={(c.Pin != null ? "yes" : "no")}  password=********");
                }
                return 0;
            }

            case "set":
            {
                Console.Write("Portal username: ");
                var u = Console.ReadLine()?.Trim() ?? "";
                var p = Secret("Portal password: ");
                string host = "";
                int port = 8888;
                var (st, loc, _) = Net.Probe(Net.Primary()?.Ip, default).GetAwaiter().GetResult();
                if (st == St.Captive && Uri.TryCreate(loc, UriKind.Absolute, out var lu))
                {
                    Console.Write($"Detected portal '{lu.Host}:{lu.Port}'. Trust it for sending credentials? [Y/n] ");
                    var ans = (Console.ReadLine() ?? "").Trim().ToLowerInvariant();
                    if (ans is "" or "y")
                    {
                        host = lu.Host;
                        port = lu.Port > 0 ? lu.Port : 8888;
                    }
                }
                if (string.IsNullOrEmpty(host))
                {
                    Console.Write("Trusted portal host [e.g. 10.114.0.5 or login.campus.edu]: ");
                    host = (Console.ReadLine() ?? "").Trim().ToLowerInvariant();
                    Console.Write("Portal port [default 8888]: ");
                    var ps = Console.ReadLine()?.Trim();
                    if (int.TryParse(ps, out var parsedPort) && parsedPort > 0) port = parsedPort;
                }
                if (string.IsNullOrEmpty(u) || string.IsNullOrEmpty(p) || string.IsNullOrEmpty(host))
                {
                    Console.Error.WriteLine("Username, password, and host are all required.");
                    return 1;
                }
                var old = Vault.Load();
                var ok = Vault.Save(new Cred
                {
                    U = u,
                    P = p,
                    H = host,
                    Port = port,
                    Pin = old?.H == host ? old.Pin : null
                });
                Console.WriteLine(ok ? "Saved into machine DPAPI vault (LocalSystem / Admin readable). Auto-login armed." : "Failed to encrypt credentials.");
                return ok ? 0 : 1;
            }

            case "pin":
            {
                var c = Vault.Load();
                if (c == null)
                {
                    Console.Error.WriteLine("Save credentials first with `cred set`.");
                    return 1;
                }
                var fp = Portal.Fingerprint(c.H, c.Port).GetAwaiter().GetResult();
                if (fp == null)
                {
                    Console.Error.WriteLine($"Could not retrieve TLS certificate from {c.H}:{c.Port}.");
                    return 1;
                }
                Console.Write($"Portal {c.H}:{c.Port} certificate SHA-256:\n  {fp}\nApprove this certificate pin for auto-login? [y/N] ");
                if (Console.ReadLine()?.Trim().ToLowerInvariant() != "y") return 1;
                c.Pin = fp;
                return Vault.Save(c) ? 0 : 1;
            }

            default:
                Console.WriteLine(Help);
                return 2;
        }
    }
}
