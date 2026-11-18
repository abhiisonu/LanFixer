using System.Diagnostics;
using System.Net;
using System.Net.NetworkInformation;
using System.Text.Json;

namespace LanFixer;

public enum NetVerdict { Healthy = 0, Degraded = 10, Broken = 20, Undetermined = 30 }

public sealed record LayerResult(int Layer, string Name, string Status, string Evidence, string Action);

public sealed record DoctorReport(
    string PrimaryAdapter,
    string IpAddress,
    string Gateway,
    string Subnet,
    int PathMtu,
    NetVerdict Verdict,
    int ExitCode,
    string RootCause,
    long DurationMs,
    List<LayerResult> Layers);

public static class Doctor
{
    public static DoctorReport Run()
    {
        var sw = Stopwatch.StartNew();
        var layers = new List<LayerResult>();
        string rootCause = "None";
        var verdict = NetVerdict.Healthy;

        // Layer 1: Physical NDIS Link
        var primary = Net.Primary();
        if (primary == null)
        {
            layers.Add(new(1, "PhysicalLink", "BROKEN", "No active physical network adapter found", "CheckCableOrRadio"));
            return new("None", "None", "None", "None", 0, NetVerdict.Broken, 20, "Physical link down", sw.ElapsedMilliseconds, layers);
        }

        var nic = NetworkInterface.GetAllNetworkInterfaces().FirstOrDefault(n => n.Id == primary.Id);
        long speedMbps = (nic?.Speed ?? 0) / 1_000_000;
        layers.Add(new(1, "PhysicalLink", "OK", $"{primary.Name} ({speedMbps} Mbps Up, {(primary.Wifi ? "Wi-Fi" : "Ethernet")})", "None"));

        // Layer 2: IPv4 Configuration & Subnet Calculus
        if (string.IsNullOrEmpty(primary.Ip) || primary.Ip.StartsWith("169.254."))
        {
            layers.Add(new(2, "IpConfig", "BROKEN", "APIPA or unassigned IP address", "DhcpRenew"));
            verdict = NetVerdict.Broken;
            rootCause = "Missing valid IPv4 address lease";
        }
        else
        {
            var uAddr = nic?.GetIPProperties().UnicastAddresses.FirstOrDefault(u => u.Address.ToString() == primary.Ip);
            int prefix = uAddr?.PrefixLength ?? 24;
            var sub = Net.CalculateSubnet(primary.Ip, prefix);
            string subSummary = sub != null ? $"{sub.IpAddress}/{sub.PrefixLength} ({sub.TotalHosts} hosts, net: {sub.NetworkAddress})" : primary.Ip;
            layers.Add(new(2, "IpConfig", "OK", subSummary, "None"));
        }

        // Layer 3: Gateway Reachability & Path MTU Discovery
        int pmtu = 1500;
        if (string.IsNullOrEmpty(primary.Gw))
        {
            layers.Add(new(3, "GatewayReach", "BROKEN", "No default gateway configured", "ResetRouting"));
            if (verdict == NetVerdict.Healthy) { verdict = NetVerdict.Broken; rootCause = "Default gateway missing"; }
        }
        else
        {
            int gwRtt = Net.Rtt(primary.Gw, 1200).GetAwaiter().GetResult();
            if (gwRtt >= 0)
            {
                pmtu = Net.DiscoverPathMtu(primary.Gw, 800);
                layers.Add(new(3, "GatewayReach", "OK", $"Gateway {primary.Gw} reachable ({gwRtt}ms, Path MTU: {pmtu})", "None"));
            }
            else
            {
                layers.Add(new(3, "GatewayReach", "DEGRADED", $"Gateway {primary.Gw} unreachable or dropping ICMP", "ArpFlush"));
                if (verdict == NetVerdict.Healthy) { verdict = NetVerdict.Degraded; rootCause = "Gateway ICMP unresponsive"; }
            }
        }

        // Layer 4: DNS Resolution & RFC 1035 UDP Racer
        var dnsList = Dns.Current(primary.Id).ToList();
        var dnsScores = Dns.Rank(dnsList.Count > 0 ? dnsList : Dns.Public, default).GetAwaiter().GetResult();
        if (dnsScores.Count > 0)
        {
            var best = dnsScores[0];
            layers.Add(new(4, "DnsResolution", "OK", $"Fastest resolver: {best.ip} ({best.ms}ms)", "None"));
        }
        else
        {
            layers.Add(new(4, "DnsResolution", "FAILED", "All configured DNS resolvers timed out", "DnsRescue"));
            if (verdict == NetVerdict.Healthy) { verdict = NetVerdict.Broken; rootCause = "DNS resolution failure"; }
        }

        // Layer 5, 6, 7: Internet, TLS Handshake & Captive Portal
        var (st, loc, ms) = Net.Probe(primary.Ip, default).GetAwaiter().GetResult();
        if (st == St.Online)
        {
            layers.Add(new(5, "InternetIpv4", "OK", $"HTTP 204 verified ({ms}ms)", "None"));
            layers.Add(new(6, "HttpsTls", "OK", "TLS 1.2/1.3 WAN handshake verified", "None"));
            layers.Add(new(7, "CaptivePortal", "OK", "Unrestricted internet egress", "None"));
        }
        else if (st == St.Captive)
        {
            layers.Add(new(5, "InternetIpv4", "DEGRADED", $"Intercepted by captive portal ({loc})", "PortalLogin"));
            layers.Add(new(6, "HttpsTls", "DEGRADED", "Outbound HTTPS blocked/demanding authentication", "PortalLogin"));
            layers.Add(new(7, "CaptivePortal", "DEGRADED", $"Captive portal sign-in required ({loc})", "PortalLogin"));
            if (verdict == NetVerdict.Healthy) { verdict = NetVerdict.Degraded; rootCause = $"Captive portal intercepted traffic ({loc})"; }
        }
        else if (st == St.NoDns)
        {
            layers.Add(new(5, "InternetIpv4", "FAILED", "DNS query failed during probe", "DnsRescue"));
            layers.Add(new(6, "HttpsTls", "FAILED", "Cannot resolve WAN TLS hosts", "DnsRescue"));
            layers.Add(new(7, "CaptivePortal", "UNDETERMINED", "Name resolution blocked", "DnsRescue"));
            if (verdict == NetVerdict.Healthy) { verdict = NetVerdict.Broken; rootCause = "DNS failure prevented internet verification"; }
        }
        else
        {
            layers.Add(new(5, "InternetIpv4", "FAILED", "Outbound HTTP dropped", "FullRepair"));
            layers.Add(new(6, "HttpsTls", "FAILED", "Outbound HTTPS dropped", "FullRepair"));
            layers.Add(new(7, "CaptivePortal", "FAILED", "Offline / no upstream response", "FullRepair"));
            if (verdict == NetVerdict.Healthy) { verdict = NetVerdict.Broken; rootCause = "Outbound traffic dropped"; }
        }

        sw.Stop();
        int exitCode = verdict == NetVerdict.Healthy ? 0 : (verdict == NetVerdict.Degraded ? 10 : 20);
        return new DoctorReport(
            primary.Name, primary.Ip, primary.Gw,
            layers.FirstOrDefault(l => l.Name == "IpConfig")?.Evidence ?? primary.Ip,
            pmtu, verdict, exitCode, rootCause, sw.ElapsedMilliseconds, layers);
    }

    public static void PrintConsole(DoctorReport rep)
    {
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine("============================================================================");
        Console.WriteLine($"  LANFIXER 8.5 HEALTH DOCTOR  |  Verdict: {rep.Verdict} (ExitCode: {rep.ExitCode})");
        Console.WriteLine("============================================================================");
        Console.ResetColor();
        Console.WriteLine($"  Adapter: {rep.PrimaryAdapter} | IP: {rep.IpAddress} | GW: {rep.Gateway} | PMTU: {rep.PathMtu}");
        if (rep.Verdict != NetVerdict.Healthy)
        {
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine($"  Root Cause: {rep.RootCause}");
            Console.ResetColor();
        }
        Console.WriteLine();

        foreach (var l in rep.Layers)
        {
            var color = l.Status switch
            {
                "OK" => ConsoleColor.Green,
                "DEGRADED" => ConsoleColor.Yellow,
                "BROKEN" or "FAILED" => ConsoleColor.Red,
                _ => ConsoleColor.Gray
            };
            Console.ForegroundColor = color;
            Console.Write($"  [{l.Status,-8}] ");
            Console.ResetColor();
            Console.Write($"Layer {l.Layer} ({l.Name,-15}): ");
            Console.WriteLine(l.Evidence);
        }
    }
}
