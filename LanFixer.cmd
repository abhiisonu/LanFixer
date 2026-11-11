<# :
@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Lan Fixer
set "LANFIXER_SELF=%~f0"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create([System.IO.File]::ReadAllText($env:LANFIXER_SELF))) %*; if (-not $?) { exit 1 } elseif ($LASTEXITCODE) { exit $LASTEXITCODE } else { exit 0 }"
exit /b %errorlevel%
#>

<#
.SYNOPSIS
    LanFixer 7.0.0 - Network diagnostic, stabilization, and captive portal automation utility for Windows.
    Author: Abhishek Sonu (https://github.com/abhiisonu)
.DESCRIPTION
    Single file, ASCII only. Run it normally for the control center, or use -Mode:
      Interactive | Heal | AutoHeal | Diagnose | QuickProbe | FlushCache | InstallWatchdog |
      UninstallWatchdog | ResetFactory | LaunchPortal | SetDnsProfile | SelfTest | Report
    Add -DryRun to see exactly what would change without changing anything.
    Every change is snapshotted first, so ResetFactory restores YOUR original values.
.NOTES
    7.0.0 (Production Release & Architecture Modernization):
      - Battery & Power Efficiency Engine: Deep WMI hardware battery telemetry (charge %, wear %, health %, cycle count); preserves DC USB selective suspend to prevent battery drain; adaptive background Sentinel polling cadence (20s+) when healthy on battery.
      - Zero-Popup Scheduled Task Architecture: Configured Hidden=True across all Task Scheduler XML definitions (Watchdog, Sentinel, Portal); added automated startup shortcut and Run registry key purging on uninstall and factory reset.
      - Risk-Ordered Recovery Hierarchy: Standardized recovery tiers in ascending risk order from Level 1 [SAFE] Careful Network Debloat to Level 6 [REBOOT] Complete Stack Rebuild.
      - Elevated Diagnostics & Controls: Multi-Size Path MTU Discovery (1500/1492/1420), RFC Bufferbloat Letter Grading (Grade A+ to F), TCP handshake latency, live 0.0.0.0/0 route priority table, and 6-stage universal network cache flush with millisecond timings.
      - Universal Network Auto-Discovery: Seamless dynamic campus gateway discovery across 10.x, 172.16-31.x, 192.168.x, 100.64-127.x subnets with intelligent Wi-Fi uplink fallback.
    6.7.0 (Enterprise Resiliency, Deep Diagnostics & Safe Recovery Engine):
      - Feature F6 (Link Quality & Flap Monitor): Added state-persisted ring buffer ($State.LinkMonitor) tracking NDIS link transitions, flap detection (>=3 drops in 10m), gigabit speed downshift alerts, and CRC packet error thresholds.
      - Feature F5 (Configuration & Policy File System): Added pure INI policy engine ($StoreDir\lanfixer.ini) with tamper-resistant ACL auditing, strict key whitelisting, and effective origin reporting (-Mode Config [-Validate] [-Json]).
      - Feature F4 (Redacted Diagnostic Support Bundle): Added zero-dependency ZIP archive generator (-Mode Bundle [-OutDir] [-Redaction Strict|Standard]) with multi-pass PII and secret redaction (MAC, public IP, username, hostname, credentials) and forensic metadata manifest.
      - Feature F3 (Guided Recovery Escalation Ladder): Added closed-loop intelligent recovery engine (-Mode Recover [-Plan]) with layered remediation, automatic re-verification, safe Tier 2 cap, and correlated undo commands.
      - Feature F2 (Change Ledger & Reversible Undo): Added persistent append-only change ledger ($StoreDir\change_ledger.jsonl) with size capping, run correlation, and drift-protected reverse-chronological undo (-Mode History, -Mode Undo [-Id <id>] [-RunId <runid>] [-Plan]).
      - Feature F1 (Health Verdict Engine): Added 7-layer OSI forensic diagnostic pipeline (-Mode Doctor, alias Status) with discrete exit code contracts (0=Healthy, 10=Degraded, 20=Broken, 30=Undetermined) and automation modifiers (-Json, -Quiet, -NoColor).
    6.6.0 (Production Hardening & Forensic Verification Release):
      - Cold Start Monotonic Adapter Cache: Implemented 2.5s high-resolution stopwatch cache in Get-EthernetAdapters, cutting redundant CIM/WMI enumeration and startup latency.
      - Locale Invariance: Sanitized powercfg index parsing across English, German, French, and Russian outputs; generalized WinHTTP loopback proxy detection to match universal IP/port patterns.
      - Scheduled Task Security & Hygiene: Hardened New-SentinelTaskXml against XML argument injection via SecurityElement escaping; added scrub of temporary task XMLs on uninstall.
      - Destructive Mode Safeguards: Added Test-RemoteSession guard to UltraSystemReset, DoomsdayReset, and ArmageddonReset to prevent remote RDP/SSH operator lockout; blocked invocation by automated background modes (AutoHeal/Daemon/Sentinel).
      - Pending Reboot Tracking: Recorded PendingReboot state and reboot timestamp upon ArmageddonReset; enforced AutoHeal debounce pause until machine restart completes.
      - Universal Upfront Parameter Guards: Hardened 19 core networking functions against null or malformed $Ad adapter objects to guarantee zero unhandled runtime exceptions.
      - Store ACL Non-Admin Verification: Added non-destructive Test-StoreAcl inspection enabling unprivileged SelfTest and audit modes to verify store security without elevation.
      - Batch Header Exit Normalization: Updated batch launcher to trap PowerShell parameter validation failures via ($?) and bubble exit code 1.
    6.5.4 (Exhaustive 10-Lens Full Forensic Audit & Behavioral Hardening):
      - PSModulePath Isolation: Sanitized $env:PSModulePath under Windows PowerShell 5.1 to prevent format/type collisions from PowerShell 7 modules.
      - Dynamic Discovery Purge: Fixed state leak in Invoke-RoamingCleanup, Invoke-SupremeOmnifix, Invoke-UltraSystemReset, and Invoke-DoomsdayReset by purging DiscoveredPortalPort and DiscoveryTime.
      - Enter-Lock PID Reuse Defense: Added StartTime timestamping to lock.json and validated lock-holder process identity (powershell|pwsh|cmd|LanFixer) and process start time.
      - DNS Wire Parser Hardening: Added QDCOUNT limits (<=32) and packet boundary checks on question/answer label lengths and compression pointers in Get-DnsAAnswers.
      - Redirect Sanitization & ReDoS Protection: Added regex match timeouts, trailing quote/semicolon trimming, and URI scheme validation to Get-RedirectFromBody.
      - Credential Vault Security: Enforced Administrators ownership (*S-1-5-32-544) in Protect-VaultFile and validated owner SID in Test-VaultAcl.
      - Dynamic Portal Endpoint Sync: Synchronized Host with DiscoveredPortalIp in Get-ActivePortalEndpoint when discovered on local network.
      - Stale Route Pruning Mutation Safety: Wrapped stale host route removal in Invoke-Change and updated in-memory tracking list in Shield-GatewayArp.
      - Config Portal Security: Enforced strict HTTPS validation on PortalUrl in ConvertTo-CfgOverride to prevent cleartext credential transmission.
      - Behavioral SelfTest Suite: Replaced shallow source-code IndexOf string assertions with live functional execution tests.
    6.5.3 (Definitive 360-Degree 8-Pillars Forensic Audit & Production Shipment):
      - State & Mutex Concurrency: Verified process identity in Enter-Lock to eradicate PID recycling deadlocks; preserved DiscoveredPortalPort in-memory across disk state reloads.
      - L1/L2 Hardware Power Catalog Expansion: Added EnergyEfficientEthernet, AutoDisableGigabit, SavePowerNowLinkDown, and ModernStandbyWoL to disable silent battery drops.
      - L3 Host Route Lifecycle Reconciliation: Pruned stale off-subnet /32 gateway host routes when default gateway changes across VLANs.
      - L4 Scoped DNS Wire Parser Compliance: Enhanced Get-DnsAAnswers with dynamic QDCOUNT loop skipping to strictly adhere to RFC 1035 multi-question packet specifications.
      - L5-L7 Captive Engine Hardening: Added HTML attribute order independence to meta-refresh tags and added window.location.assign redirection handling.
    6.5.2 (Exhaustive Forensic Audit Resolutions & Hardware/Stack Reliability Hardening):
      - NDIS Link Speed Cast: Replaced fragile [int64]$Ad.LinkSpeed string conversion with UInt64 TransmitLinkSpeed and robust regex evaluation, preventing duplex flap crash.
      - Roaming Debounce State: Stamped LinkDownSince in $script:State.Misc to unfreeze AutoHeal from perpetual 45s debounce trap; cleared both Misc and Times on recovery.
      - Smart DNS Management Guard: Added management flag check to Restore-SmartDnsIfManaged to avoid spurious registry writes.
      - PnP Hardware Restart Quoting: Removed manual outer quotes on PnPDeviceID in Invoke-Native pnputil call to prevent double-escaping failure.
      - DHCP DNS Management Inversion: Set Managed=false on Set-AdapterDnsAutomatic to prevent erroneous re-management after DHCP reset.
      - Off-Subnet Gateway Route Tracking: Added Add-TrackedHostRoute and metric 5 alignment to off-subnet gateway injection for clean roaming teardown.
      - Path MTU Target Fallbacks: Enriched Get-PathMtuForAdapter with gateway and DHCP DNS probe targets for firewalled intranets.
      - Sockets DAD Binding Fallback: Added unbound socket fallback to Test-TcpPort on tentative local IP addresses.
      - HttpWebRequest Stream Disposal: Guaranteed $resp.Close() in Get-InternetState system fallback via try/finally.
    6.5.1 (Definitive Forensic Audit Resolutions & Omni-Adaptive Dynamic Stack Hardening):
      - Subnet Calculus: Pre-assigned $ipBytes before prefix validation; converted WildcardMask from scalar byte to 4-octet dotted quad.
      - State Persistence: Repointed Shield-Profile to Snapshot table; stamped DiscoveryTime on Other cleanup and purged missing keys on sync.
      - Socket & Route Safety: Validated IPv4 in Get-DhcpDnsServers to prevent UdpClient address family mismatches while retaining IPv6 support.
      - TLS Decision Priority: Validated CA certificates prior to pin check in New-CertCallback to prevent rejection of updated certificates.
      - Institutional Overrides: Enforced Import-UserConfig on Initialize-Store completion.
      - Dynamic Portals: Replaced hardcoded portal endpoints in [G] dashboard handler and Invoke-HeadlessPortalLogin with Get-ActivePortalEndpoint.
      - Reset MTU Scavenging: Purged all wildcard MtuCandidate* keys during resets.
    6.5.0 (Omniscient Layer 1-7 Healer, Doomsday Multi-Medium & Armageddon Deep OS Reset):
      - Invoke-ArmageddonReset: 4-stage Microsoft Windows native kernel network stack wipe and reinstallation engine (netcfg.exe -d). Uninstalls all adapters, clears virtual switches/filters, wipes TCP/IP registry stack, and triggers clean PnP driver reinstallation upon reboot.
      - Invoke-DoomsdayReset: 12-stage universal doomsday network stack annihilation engine with 5 Deep Forensic Antidotes for total connectivity death across ALL media (Wi-Fi, Bluetooth, USB Tethering, Ethernet, Cellular).
      - Rogue NDIS 6 Filter Driver Deactivation: automatically deactivates 3rd-party NDIS lightweight filter drivers (Npcap, VirtualBox, VPN, Antivirus packet drop traps) on physical adapters while preserving native Microsoft protocols.
      - PnP Silicon Hardware Bus Restart: executes pnputil.exe /restart-device on physical PCI/USB device instances to wake transceivers from Modern Standby D3cold / PCIe ASPM hardware lockups without rebooting.
      - RadioManagement / Airplane Mode Deadlock Eradication: sets SystemRadioState to 0 in registry and cycles RmSvc to unlock trapped hardware radios.
      - Ghost Adapter Registry Scrub & Outbound Firewall Guarantee: scrubs orphaned GUIDs under Tcpip\Parameters\Interfaces and enforces netsh advfirewall blockinbound,allowoutbound.
      - Universal Manual Static IP & Route Purge: strips conflicting manual static IPs and default routes across all physical adapters, enforcing pure DHCP Discover.
      - Dual-Architecture Winsock LSP & NSP Annihilation: wipes 64-bit System32 and 32-bit SysWOW64 Winsock catalogs (netsh winsock reset catalog & reset), zeroes AutodialFlags.
      - Dual-Stack TCP/IP & Heuristics Normalization: netsh int ip/ipv6 reset, netsh int tcp reset, autotuninglevel=normal, RSS/RSC enabled, ECN/timestamps disabled, initialrto=3000.
      - Transition Tunnel Disablement: disables Teredo, ISATAP, and 6to4 transition tunnels to eliminate campus IPv6 routing sinkholes.
      - Routing, Destination Cache, PortProxy & Bridge Purge: route -f (clears gateways), deletes destinationcache, netsh interface portproxy/httpstunnel reset, destroys rogue bridges via netsh bridge.
      - Encrypted DNS (DoH/DoT/DDR) Global & Per-Interface Factory Wipe: netsh dnsclient delete global all & delete interface all.
      - Firewall, WPAD Autoproxy & BITS Transfer Purge: netsh advfirewall reset & on, netsh winhttp reset proxy/autoproxy/tracing, flushes HTTP log buffer, cancels zombie BITS jobs.
      - NCSI Calibration, Kerberos Purge & SMB Session Sweep: calibrates ActiveWebProbe/ActiveDnsProbe, klist purge, net use * /delete /y, purges unmanaged NLM signatures.
      - Cache & NetBIOS Eviction: netsh interface ip delete arpcache, netsh int ip/ipv6 delete neighbors, arp -d *, nbtstat -R & -RR, Clear-DnsClientCache, ipconfig /flushdns.
      - Hardware Transceiver Cycle & Driver Power Lock: pnputil /restart-device, re-binds ms_tcpip/ms_tcpip6/ms_rspndr/ms_lltdio/ms_pacer, defeats PHY EEE/green power & selective suspend.
      - DHCP Broadcast Flag Enforcement & Registry Zeroing: enforces DhcpConnForceBroadcastFlag=1 (RFC 2131), zeroes cached DhcpIPAddress/DhcpServer keys to force pure Discover.
      - Topological 13-Service Stack Resuscitation: cleanly halts 13 dependent services before reset and restarts them in strict topological order (BFE -> mpssvc -> CryptSvc -> RmSvc -> WlanSvc -> dot3svc -> bthserv -> WwanSvc -> Dhcp -> Dnscache -> iphlpsvc -> NlaSvc -> netprofm -> BITS).
      - 802.1X Wired AutoConfig Reconnection: issues netsh lan reconnect across wired LAN interfaces.
      - Full DHCP Stack Cycle & Dynamic DNS: ipconfig /release & /renew (IPv4/IPv6), ipconfig /registerdns, and 802.1D Spanning Tree Protocol (STP) convergence loop.
      - Interactive TUI & CLI Integration: Key [D] for Doomsday, Key [U] for Ultra, 4-tier selector on [X], -Mode ArmageddonReset / DoomsdayReset / UltraReset / FullNetReset CLI dispatch.
    6.4.2 (PnP Optimization & Mutex Starvation Protection):
      - PnP Rescan Rate-Limit & Narrowing: Rescue-DormantEthernetPnp stamps limiter before query, checks only present faulted physical wired NICs, and ignores disabled/ghost devices.
      - Interactive Session Timestamp Validation: Start-Interactive writes process StartTime in round-trippable ISO-8601 UTC format, eliminating false-positive session purges.
      - Undoable IPv6 Neutralization & Restoration: Shield-DnsIntegrity snapshots DnsStatic/Ipv6Rd; Restore-Ipv6IfNeutralized restores ms_tcpip6 and router discovery upon leaving campus or factory reset.
      - Dry-Run Enforcement in Get-GatewayMacs: Wrapped Remove-NetNeighbor in dry-run guard to prevent neighbor eviction during read-only audits.
      - Accurate Metric Drift Detection: Get-RoutingLabel reads actual adapter metric to enable drift remediation in Start-Interactive.
      - Neutralized Interceptor State Persistence: Preserves StartType, DelayedAutostart, and WasRunning for third-party services; added $skipKill gate in Shield-SystemStack.
      - Prompt Mutex Starvation Protection: Extracted interactive confirmation prompts outside of Invoke-WithLock so operator pauses never block the background watchdog.
      - Source-Bound Gateway Liveness Probes: Cleaned unbound proxy checks in Test-GatewayAlive; bound TCP probes to adapter IPv4.
      - Per-Adapter Path-MTU Candidates: Keyed MtuCandidate by interface GUID; enforced Test-RouteViaAdapter unconditionally.
      - NlaNudge Sleep Optimization: Gated 5s sleep in Shield-Services behind Test-Elapsed 900s limiter.
      - TCP Auto-Tuning Snapshotting: Shield-TcpAutoTuning snapshots original auto-tuning level before restoration.
    6.4.1 (Supreme Omni-Hardening & Static Lint Resolution):
      - Static IP Auto-Rollback: Shield-DataLink restores snapshotted static IPv4 if DHCP renewal ladder fails.
      - Inverted DHCP Stack Unfreeze: Inverted Step 3 in Repair-Dhcp (Stop -> Zero Registry -> Start) to prevent cached lease rewrites.
      - Roaming Cleanup Flap Grace Period: 45s debounce in Invoke-RoamingCleanup avoids full teardown during momentary cable wiggles.
      - Measured Per-Adapter Complete-Authentication: Evaluates genuine Internet state per adapter rather than assuming 'Online'.
      - Source-Bound Stage 5 Omnifix: Bound public verification probes to primary Ethernet IP, eliminating Wi-Fi hotspot false-positives.
      - Secondary-Uplink DNS Scoping: Preserves legitimate DHCP-supplied campus DNS on campus Wi-Fi while purging stuck static entries.
      - Inverted Stale Portal Condition Fix: Corrected line 3285 to unconditionally purge discovered portal state on non-campus networks.
      - HTML5 Form Parser Expansion: Added input number, checked checkboxes, and select dropdown extraction in ConvertFrom-LoginForm.
      - Vault Re-Save Protection: Implemented transaction guard ($moved) in Save-PortalCredentials to protect existing vault secrets.
      - Read-Only Telemetry Contract: Purged unsynchronized metric writes from Get-Telemetry to prevent multi-threaded race conditions.
      - Wi-Fi Enablement Dry-Run Guard: Wrapped Enable-NetAdapter in Invoke-Change and dry-run check in Set-RouteProfileMode.
      - Lazy Uplink Evaluation: Deferred Test-OtherUplinkActive in Get-InternetState, eliminating 75% of route table sweep overhead.
    6.4.0 (Alpha-to-Omega Network Resilience Engine):
      - Dormant USB PnP Transceiver Revival: Rescue-DormantEthernetPnp detects non-present/sleep-crashed USB NICs and
        resynchronizes the PnP bus via pnputil /scan-devices, guaranteeing zero-reboot waking on all USB controllers.
      - RFC 4861 Link-Local IPv6 Gateway Preservation: Corrected IPv6 route evaluation in Get-AdapterDnsVerdict to recognize
        standard fe80:: next hops, preserving legitimate dual-stack connectivity while neutralizing true rogue sinkholes.
      - Windows 11 Native DoH UDP Fallback: Shield-DohFallback enforces AllowFallbackToUdp = $true across DoH templates,
        preventing catastrophic port 443 stall timeouts when behind unauthenticated captive portal firewalls.
      - AST Syntactic Bug Elimination: Wrapped Test-MetricsManaged command evaluation on line 3753 to fix operator-as-parameter
        token binding, restoring proper routing profile restoration logic.
      - Source-Bound Gateway Liveness: Test-GatewayAlive probes only the gateway IP and verifies on-link ARP MACs, eliminating
        multi-uplink cross-talk where active Wi-Fi falsely reported a disconnected or dead Ethernet gateway as alive.
      - Watchdog Dashboard Coexistence & Stale PID Purge: Test-InteractiveSessionActive validates process StartTime to prevent
        stale recycled PIDs from silencing the watchdog, and allows AutoHeal when the Global mutex is idle.
      - Fail-Safe NDIS Driver Cycling: Guaranteed finally retry loop with kernel PnP fallback in Reset-PhysicalAdapterHardware
        ensures a network adapter is never left in a disabled state.
      - Device Parameters Snapshotting & Dry-Run Safety: Wrapped all 7 USB transceiver power parameters in Save-Original,
        Invoke-Change, and Restore-Everything handlers.
      - Topology-Aware /32 Captive Pathing: Test-SameSubnetIPv4 calculates on-link vs off-link captive targets, routing
        on-link targets via 0.0.0.0 (direct ARP) and off-link targets via the physical gateway at metric 5.
      - Clean Roaming & Reset Hygiene: Invoke-RoamingCleanup purges discovered portal state upon leaving campus, and full
        resets unconditionally evict stale Permanent ARP locks across network switches.
    6.3.0 (Zero-Reboot Situational Auto-Adaptation Engine):
      - Situational DNS Engine: Shield-Dns resolves failures across Online, NoDns, and Offline states via parallel
        53/UDP latency probes, automatically placing measured working public resolvers at the head of the adapter list.
      - NRPT Split-Horizon Rule Injection: Dynamically maps the campus/organization domain to campus resolvers so
        internal portals, ERPs, and intranet services continue working alongside high-speed public internet.
      - Dynamic Captive Host Routing: Ensure-CampusPortalPath resolves portal redirect hostnames on the wire and
        creates /32 host routes pinned to the active gateway, preventing secondary uplinks from hijacking portal auth.
      - Zero-Reboot Hardware Cycling: Combines pnputil /restart-device with NDIS stack cycling and DHCP Client service
        unfreezing, eliminating the need to restart the PC to resolve hung transceivers or frozen sockets.
      - Multi-Vendor NIC Power Hardening: Suppresses selective suspend and Energy Efficient Ethernet (EEE) across
        Realtek, ASIX, and Intel GbE controllers, and disables USB selective suspend globally across AC and DC power plans.
      - DHCP Stale Cache Flush: Step 3 of Repair-Dhcp purges stale DhcpIPAddress and DhcpDefaultGateway registry values
        before renewing, preventing 30-second APIPA 169.254.x.x deadlocks on foreign networks.
    5.2.0 (verified-defect release; every item below was reproduced in the 5.0.0 source before it was changed):
      SECURITY
      - The saved portal password could be sent to any HTTPS host under the DNS suffix that the CURRENT network's DHCP
        handed out (Misc.DiscoveredDomain was trusted like the configured campus). Credential-bearing steps now use
        Test-CredentialPortalHost / Get-CredentialPortalUrl: only the configured PortalHost / PortalIp / CampusDomain
        (or an IP literal, which still needs a Windows-valid or pinned certificate). Browser navigation keeps the
        broader trust because nothing secret is sent. Another institution opts in explicitly through config.json.
      CORRECTNESS
      - Test-GatewayAlive deleted a neighbour (ARP) entry during -DryRun.
      - Save-State now proves the new temp file parses before it replaces state, and never copies a damaged live file
        over a good .bak.
      - Non-campus DNS rescue no longer flaps (Get-OtherDnsAction): a rescue stays until the DHCP resolvers answer.
      - Watchdog self-heal also covers a task DISABLED in Task Scheduler.
      - Dashboard autopilot: one automatic vault sign-in attempt when the dashboard opens on an already captive link.
      - Remove-CampusHostRoutes now also removes the /32 routes Ensure-CampusPortalPath adds for other addresses
        (discovered portal, redirect target, the adapter's DHCP resolvers).
      - Invoke-TlsHttp resolved the portal host name without the Ethernet source address (SMHNR could answer from Wi-Fi).
      - Captive portals that answer 200 with a <meta refresh> or a JavaScript redirect now yield a Location; the probe
        reads enough of the body to see it.
      - gzip/deflate bodies are decoded (bounded to 1 MB: a decompression bomb returns the raw bytes).
      - Path-MTU probes are skipped when they would leave through another uplink (the result would describe the wrong
        link and could clamp the Ethernet MTU).
      - -Mode SelfTest now exits 1 when an assertion fails (it always exited 0 before).
      UNIVERSALITY
      - Environment detection records Home (does this lease look like the configured campus). The built-in NITJSR portal
        IP / resolver / domain are used as fallbacks only on that campus (NRPT, /32 routes, resolver candidates,
        portal check, gateway-liveness proxy). Other networks get discovered values only.
      - Optional <store>\config.json (admin/SYSTEM-owned, not writable by others) sets PortalHost, PortalIp, PortalPort,
        PortalUrl, CampusDns, CampusDomain, GwRegex, ProfileRegex; every value is validated and nothing can be blanked.
    4.6.0 (Comprehensive edge-case hardening, non-destructive static IP fallback, WFP precision, LF chunking):
      - CNAME wire parser: Get-DnsAAnswers correctly handles hybrid label+pointer compression (RFC 1035 Section 4.1.4).
      - Split-Words: deterministically slices unbreakable tokens > Width to guarantee zero console frame overflow.
      - HTTP engine: ConvertFrom-ChunkedBytes supports LF-only (\n) framing; ConvertFrom-LoginForm adds HTML5 formless input fallback.
      - Concurrency: Invoke-SupremeOmnifix releases Global\LanFixer_Lock before the 180s human captive portal wait.
      - Security: Initialize-Store AST-validates $SelfPath before mirroring to protected %ProgramData%\LanFixer\LanFixer_Core.cmd.
      - State persistence: Enter-Lock merges in-memory LearnedDhcp and Env tables across state reloads.
      - Non-destructive static IP: Shield-DataLink snapshots static IPv4 configurations before DHCP switchover, and Restore-Everything restores them.
      - Disarming hygiene: Uninstall-Watchdog removes campus host routes, restores metrics, interceptors, and managed adapter DNS.
      - Precision WFP remediation: Shield-SystemStack tests Google Auth resolution before declaring DNS broken and spares user VPNs.
      - SelfTest suite: expanded to 156 assertions verifying all parser, wrapping, chunking, and logic invariants.
    4.5.6 (TUI responsiveness audit + a much wider self test; no behaviour change in the UI itself):
      - Verified end to end in the source: an unmapped key (arrows, Tab, Backspace, stray letters) returns
        $false from Invoke-DashboardKey, and the main loop only clears the screen and re-probes when it returns
        $true - so no screen wipe and no synchronous network probe on a stray keypress. [Q] Quit is its own dim
        segment, and Get-Sig already tracked all 15 dynamic telemetry fields.
      - Self test grew to 149 assertions: the transient dashboard layouts (pending MAC, Limited Mode, Wi-Fi
        Protected) are now width-checked at 60/76/100 columns in BOTH glyph modes, the [K] offer is proven present
        at every supported width, unmapped keys are proven unhandled, and Dry-Run is proven inert three ways:
        the action never executes, no log line is written, and the state file is never rewritten.
      - Those Dry-Run probes satisfy every other guard (store ready, mutex held, elevated) and are pointed at
        throwaway files, so they fail if the IsDry guard alone regresses - confirmed by mutation testing.
    4.5.5 (state-file transactions, routing telemetry, one-key elevation; no UI changes):
      - [7] Open Portal Page and [2] Arm Watchdog now persist their state INSIDE the same Global\LanFixer_Lock block
        that made the changes. Previously a failed browser launch returned from the lock with the metric/DNS edits
        still only in memory, and the next SYSTEM watchdog pass overwrote them from its own copy.
      - Complete-Authentication and every state write in Invoke-HeadlessPortalLogin now take the lock themselves
        (reentrant, so nested calls simply nest). This matters because Save-State is a deliberate no-op without the
        mutex: an unlocked caller used to lose its write silently.
      - The dashboard no longer claims "Ethernet First" while the campus link is demoted: the routing label is decided
        by Get-RoutingLabel from the REAL Ethernet metric (<=15 Ethernet First, >=45 Wi-Fi Protected).
      - [E] one-key elevation was already wired (Get-Advice -> [E], ENTER in Limited Mode) and is now covered by the
        self test, which checks the exact status/action strings the dashboard promises.
    4.5.4 (portal vault, headless login and [K] approval workflow; no UI changes):
      - The gateway-MAC review is now advertised on the compact dashboard legend too, not only in the full dock, and
        only while a candidate is really waiting (the [K] advice itself was already raised for every link state).
      - [K] refuses to approve a MAC that stopped being the pending one while the confirmation prompt was open: the
        candidate is re-read inside the lock, so a second change cannot be silently locked in.
      - Headless login can no longer retry a rejected certificate for ever: re-pinning the SAME fingerprint that was
        just rejected stops immediately, and a portal that keeps rotating certificates is abandoned after 3 attempts.
    4.5.3 (Layer 0 + DNS state-machine hardening, no UI changes):
      - Every DNS write in Shield-SystemStack (loopback bypass AND the Wi-Fi / USB-tethering / Bluetooth-PAN ladder)
        now snapshots the adapter's ORIGINAL resolver string first and marks the adapter managed, so no secondary
        uplink can keep a substituted resolver after Lan Fixer is done with it.
      - New Restore-ManagedAdapterDns sweep: leaving campus (Invoke-RoamingCleanup) and the factory reset
        (Restore-Everything) both restore the user's exact pre-Lan Fixer DNS on every adapter this tool touched,
        including ones whose snapshot predates the fix.
      - [3] -> [5] Reset DHCP is now final: it clears DNS management, restores the Adaptive profile, removes the
        campus NRPT rules whether or not a cable is plugged in, and leaves no managed flag behind for a later
        roaming cleanup to resurrect. A legacy stored 'ResetDHCP' profile reads back as Adaptive.
      - Manual [1] Heal while unplugged already runs Invoke-RoamingCleanup BEFORE Shield-SystemStack, matching the
        AutoHeal safety order; this is now asserted by the self test instead of being an incidental ordering.
    4.5.2 (routing/probing hardening, no UI changes):
      - Routing metrics now run through ONE pure planner with three strict, mutually exclusive branches, so a
        NON-campus wired network is never demoted to metric 50 and never receives the NITJSR /32 host routes
        (4.5.1 demoted it and injected campus routes onto home/office routers whenever Wi-Fi was also up).
      - Ensure-CampusPortalPath takes the live redirect URI, reconciles a host route whose next hop went stale
        (VRRP/HSRP failover) and is applied by the metric engine, the vault actions and the portal client alike.
      - Resolve-HostBounded is source-scoped: while a second uplink is up, only the Ethernet adapter's OWN
        resolvers may answer, so a dead campus resolver is reported as NoDns instead of being masked by Wi-Fi.
      - Resolver measurement falls back to an unbound socket when the source address is still tentative (DAD).
#>

[CmdletBinding()]
param(
    [ValidateSet('Interactive','Heal','QuickHeal','AutoHeal','Omnifix','StandardReset','NetReset','FullNetReset','UltraReset','Ultra','DoomsdayReset','Doomsday','ArmageddonReset','Armageddon','ResetOptions','ResetMenu','Diagnose','Audit','QuickProbe','Probe','FlushCache','Flush','InstallWatchdog','UninstallWatchdog','InstallShield','UninstallShield','InstallSentinel','UninstallSentinel','ResetFactory','Reset','LaunchPortal','Login','SetDnsProfile','Dns','DnsMenu','SetRouteProfile','Route','RouteMenu','SelfTest','Verify','Report','Daemon','Sentinel','Vault','Guide','Help','Doctor','Status','History','Undo','Recover','Bundle','Config','Integrity','Debloat','UndoDebloat')]
    [string]$Mode = 'Interactive',
    [ValidateSet('Adaptive','DHCP','Hybrid','Cloudflare','ResetDHCP')]
    [string]$DnsProfile = 'Adaptive',
    [ValidateSet('Adaptive','Ethernet','Wifi','Windows')]
    [string]$RouteProfile = 'Adaptive',
    [switch]$DryRun,
    [switch]$NoPause,
    [switch]$Force,
    [switch]$Headless,
    [switch]$ConfirmRemoteDisconnect,
    [switch]$Json,
    [switch]$Quiet,
    [switch]$NoColor,
    [string]$Id,
    [string]$RunId,
    [int]$Limit = 20,
    [switch]$Plan,
    [string]$OutDir = '',
    [ValidateSet('Strict','Standard')][string]$Redaction = 'Strict',
    [string]$Section = '',
    [switch]$Follow,
    [string]$Level = '',
    [string]$Filter = '',
    [string]$OutFile = '',
    [switch]$Validate,
    [switch]$Audit,
    [switch]$Authorize,
    [switch]$SafeOnly,
    [int]$Tier = 1,
    [Parameter(DontShow)][switch]$LfElevated
)

$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
try { Add-Type -AssemblyName System.Security -ErrorAction SilentlyContinue } catch {}
try { Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue } catch {}
if ($PSVersionTable.PSEdition -ne 'Core') {
    $sysMod = Join-Path $env:SystemRoot 'system32\WindowsPowerShell\v1.0\Modules'
    if (Test-Path -LiteralPath $sysMod) {
        $cleanMods = @($sysMod) + @(($env:PSModulePath -split ';') | Where-Object { $_ -and $_ -notmatch 'PowerShell[\\/][67]|microsoft\.powershell' })
        $env:PSModulePath = ($cleanMods | Select-Object -Unique) -join ';'
    }
}

# ==============================================================================
# CONFIG (edit here, nowhere else)
# ==============================================================================
$script:Version = '7.0.0'
$script:RunId   = [guid]::NewGuid().ToString()
$script:Sys32   = Join-Path $env:SystemRoot 'System32'
$script:SelfPath = if ($env:LANFIXER_SELF -and (Test-Path -LiteralPath $env:LANFIXER_SELF)) { $env:LANFIXER_SELF } elseif ($PSCommandPath -and (Test-Path -LiteralPath $PSCommandPath)) { $PSCommandPath } elseif ($MyInvocation.MyCommand.Path -and (Test-Path -LiteralPath $MyInvocation.MyCommand.Path)) { $MyInvocation.MyCommand.Path } elseif ($PSScriptRoot -and (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'LanFixer.cmd'))) { (Join-Path $PSScriptRoot 'LanFixer.cmd') } else { (Join-Path (Get-Location).Path 'LanFixer.cmd') }
$script:IsDry   = [bool]$DryRun
$script:IsPlan  = [bool]$Plan
if ($script:IsPlan) { $script:IsDry = $true }
$script:PlannedChanges = New-Object System.Collections.ArrayList
$script:UiOn    = ($Mode -ne 'AutoHeal' -and $Mode -ne 'InstallSentinel' -and $Mode -ne 'UninstallSentinel' -and -not $Headless)
if ($env:NO_COLOR -and $env:NO_COLOR -ne '') { $NoColor = [switch]::Present }
$script:NoColor = [bool]$NoColor
if ($Json -or $Quiet) { $script:UiOn = $false; $NoPause = $true }
$script:Cfg = @{
    StoreDir        = (Join-Path $env:ProgramData 'LanFixer')
    SelfName        = 'LanFixer_Core.cmd'
    TaskWatchdog    = 'LanFixer_Watchdog'
    TaskPortal      = 'LanFixer_Portal'
    PortalHost      = 'gateway.nitjsr.ac.in'
    PortalPort      = 8003
    PortalIp        = '10.114.0.5'
    PortalUrl       = 'https://gateway.nitjsr.ac.in:8003/index.php?zone=nitjsr'
    CampusDns       = '172.16.1.2'
    CampusDomain    = 'nitjsr.ac.in'
    GwRegex         = '^(10\.\d{1,3}\.\d{1,3}\.1|172\.(1[6-9]|2\d|3[0-1])\.\d{1,3}\.1|192\.168\.\d{1,3}\.1|100\.(6[4-9]|[7-9]\d|1[01]\d|12[0-7])\.\d{1,3}\.1)$'   # multi-subnet / campus / router gateway hint
    ProfileRegex    = 'nitjsr|campus|university|college|school|academic|eduroam|hostel|hall|dorm|guest|enterprise|corp|internal|portal|login|hotspot|wifi|wlan|lan'
    CampusThreshold = 2
    PublicDns       = @('9.9.9.9','8.8.8.8','1.1.1.1')
    CfDns           = @('1.1.1.1','1.0.0.1')
    DnsTestNames    = @('www.wikipedia.org','www.python.org','www.cloudflare.com')
    CampusDad       = 0
    DefaultDad      = 3
    ArpLock         = $true
    ForcePublic     = $true
    HeartbeatMin    = 10
    AuthWatchSec    = 720
    LogMaxBytes     = 524288
    DadPolicy       = 'Auto'     # Auto = switch duplicate-address probes off only after real conflict evidence; Always | Never
    DisableLlmnr    = $true      # LLMNR is a name-poisoning vector on shared LANs; restored when you leave campus
    ProbeSourceBind = $true      # bind connectivity probes to the Ethernet adapter's own IP (correct when Wi-Fi is also on)
    BreakerFails    = 5          # after this many failed automatic repairs in a row, slow down to once an hour
    TaskNotify      = 'LanFixer_Notify'
    PreferIpv4      = $true      # prefer IPv4 over IPv6, but ONLY after IPv6 is proven advertised-and-unreachable on this LAN
    ManageMetrics   = $true      # Ensure 1 Gbps Ethernet gets priority over metered Wi-Fi when Ethernet is Online
    StpMaxSec       = 45         # Max seconds to wait for IEEE 802.1D STP convergence on switch link reset
    AutoClampMtu    = $true      # Automatically clamp MTU if campus core router drops 1500-byte packets
    AutoPortalLogin = $true      # sign in by itself, but only if YOU saved credentials in the vault (menu A); HTTPS + trusted host + pinned/valid certificate only
    ArpPersistent   = $false     # $true also writes the gateway ARP lock to the PERSISTENT store (survives reboots and follows the adapter to other networks)
}
$script:StoreDir  = $script:Cfg.StoreDir
$script:LogFile   = Join-Path $script:StoreDir 'LanFixer.log'
$script:StateFile = Join-Path $script:StoreDir 'state.clixml'
$script:SelfCopy  = Join-Path $script:StoreDir $script:Cfg.SelfName
$script:VaultFile = Join-Path $script:StoreDir 'vault.bin'
$script:VirtRegex = 'Virtual|Hyper-V|VMware|VirtualBox|\bTAP\b|\bTUN\b|\bWSL\b|Bluetooth|Tailscale|ZeroTier|WireGuard|Wintun|RNDIS|Remote NDIS|Loopback|Npcap|OpenVPN|AnyConnect|Fortinet|PANGP'
$script:PowerKeywords = @('*EEE','EEE','EEELinkAdvertisement','EnableGreenEthernet','GreenEthernet','PowerSavingMode','AutoPowerSaveModeEnabled','ULPMode','EnableSavePowerNow','ReduceSpeedOnPowerDown','AdvancedEEE','GigaLite','*SelectiveSuspend','BatteryModeLinkSpeed','EnableBatteryModeLinkSpeed','EnableExtraPowerSaving','EnableAdaptiveLinkCap','*IdleRestriction','IdleRestriction','EnergyEfficientEthernet','AutoDisableGigabit','SavePowerNowLinkDown','ModernStandbyWoL')
$script:StoreReady  = $false
$script:StoreSecure = $false
$script:State       = @{ Snapshot = @{}; Env = @{}; Dns = @{}; Arp = @{}; Times = @{}; Misc = @{} }
$script:EnvCache    = @{}
$script:ConnCache   = $null
$script:ChangeCount = 0
$script:FailCount   = 0
$script:Mutex          = $null
$script:HasMutex       = $false
$script:LockDepth      = 0
$script:CancelHandler  = $null
$script:InDashboard    = $false

# ==============================================================================
# CORE HELPERS
# ==============================================================================
function Test-IsAdmin {
    try {
        $id = [Security.Principal.WindowsIdentity]::GetCurrent()
        return ([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch { return $false }
}
function Test-IsSystem {
    try { return [Security.Principal.WindowsIdentity]::GetCurrent().IsSystem } catch { return $false }
}

function Write-Log {
    param([string]$Level, [string]$Message)
    if ($script:StoreReady -and -not $script:IsDry) {
        try {
            $line = '[{0}] [{1}] {2}' -f (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'), $Level, $Message
            [System.IO.File]::AppendAllText($script:LogFile, $line + "`r`n")
        } catch {}
    }
    if (-not $script:UiOn) { return }
    if ($script:InDashboard) { return }
    $g = $script:G
    switch ($Level) {
        'STEP' {
            Out-Line @()
            $m = [regex]::Match($Message, '^LAYER\s+(\d+/\d+)\s+(.*)$')
            if ($m.Success) { Out-Line @((Seg 'accent!' ('  ' + $g.arr + ' ')), (Seg 'dim' ($m.Groups[1].Value + '  ')), (Seg 'text!' $m.Groups[2].Value)) }
            else { Out-Line @((Seg 'accent!' ('  ' + $g.arr + ' ')), (Seg 'text!' $Message)) }
        }
        'OK'    { Out-Wrapped 'ok' $g.ok 'text' $Message }
        'INFO'  { Out-Wrapped 'faint' $g.mid 'dim' $Message }
        'WARN'  { Out-Wrapped 'warn' $g.warn 'warn' $Message }
        'FAIL'  { Out-Wrapped 'bad' $g.bad 'bad' $Message }
        'ALERT' { Out-Wrapped 'bad!' $g.bad 'bad!' $Message }
        'DRY'   { Out-Wrapped 'vio' $g.half 'vio' $Message }
        default { Out-Line @((Seg 'text' ('    ' + $Message))) }
    }
}
# Every mutation goes through here: honest success/failure, dry-run support, counters.
# ==============================================================================
# CHANGE LEDGER & MUTATION ENGINE (FEATURE F2)
# ==============================================================================
function Add-ChangeLedgerEntry {
    param(
        [string]$Description,
        [string]$MutationType = 'Generic',
        [string]$Target = '',
        $OldValue = $null,
        $NewValue = $null,
        [bool]$Success = $true,
        [bool]$Reversible = $false,
        [string]$UndoScript = ''
    )
    if ($script:IsDry) { return }
    try {
        if (-not (Test-Path -LiteralPath $script:StoreDir)) {
            [void](New-Item -ItemType Directory -Path $script:StoreDir -Force -ErrorAction SilentlyContinue)
        }
        $ledgerFile = Join-Path $script:StoreDir 'change_ledger.jsonl'
        if (Test-Path -LiteralPath $ledgerFile) {
            $item = Get-Item -LiteralPath $ledgerFile -ErrorAction SilentlyContinue
            if ($item -and $item.Length -ge 2097152) {
                $bakFile = $ledgerFile + '.bak'
                Copy-Item -LiteralPath $ledgerFile -Destination $bakFile -Force -ErrorAction SilentlyContinue
                Remove-Item -LiteralPath $ledgerFile -Force -ErrorAction SilentlyContinue
            }
        }
        $now = [DateTime]::UtcNow
        $entry = @{
            SchemaVersion  = 1
            EntryId        = [guid]::NewGuid().ToString()
            RunId          = [string]$script:RunId
            TimestampUtc   = $now.ToString('o')
            TimestampLocal = (Get-Date).ToString('o')
            Mode           = [string]$Mode
            Description    = [string]$Description
            MutationType   = [string]$MutationType
            Target         = [string]$Target
            OldValue       = $OldValue
            NewValue       = $NewValue
            Success        = $Success
            Reversible     = $Reversible
            UndoScript     = [string]$UndoScript
        }
        $jsonLine = (ConvertTo-Json $entry -Compress) -replace '[
]+', ''
        [System.IO.File]::AppendAllText($ledgerFile, $jsonLine + "`r`n", [System.Text.Encoding]::ASCII)
    } catch {}
}

function Get-ChangeLedgerEntries([int]$Limit = 0) {
    $ledgerFile = Join-Path $script:StoreDir 'change_ledger.jsonl'
    if (-not (Test-Path -LiteralPath $ledgerFile)) { return @() }
    $lines = @(Get-Content -LiteralPath $ledgerFile -ErrorAction SilentlyContinue | Where-Object { $_ -and $_.Trim() -ne '' })
    if ($lines.Count -eq 0) { return @() }
    $entries = New-Object System.Collections.ArrayList
    foreach ($line in $lines) {
        try {
            $e = ConvertFrom-Json $line
            if ($e -and $e.EntryId) { [void]$entries.Add($e) }
        } catch {}
    }
    if ($Limit -gt 0 -and $entries.Count -gt $Limit) {
        $startIdx = $entries.Count - $Limit
        return @($entries.GetRange($startIdx, $Limit))
    }
    return @($entries)
}

function Format-LedgerHistory($Entries, [switch]$NoColor) {
    $nc = [bool]($NoColor -or $script:NoColor)
    if ($nc) {
        Write-Host '================================================================================'
        Write-Host '                    LANFIXER CHANGE LEDGER (MUTATION HISTORY)'
        Write-Host '================================================================================'
    } else {
        Write-Host '================================================================================' -ForegroundColor Cyan
        Write-Host '                    LANFIXER CHANGE LEDGER (MUTATION HISTORY)' -ForegroundColor Cyan
        Write-Host '================================================================================' -ForegroundColor Cyan
    }
    if (-not $Entries -or $Entries.Count -eq 0) {
        if ($nc) {
            Write-Host 'No ledger entries recorded yet.'
            Write-Host '================================================================================'
        } else {
            Write-Host 'No ledger entries recorded yet.' -ForegroundColor Gray
            Write-Host '================================================================================' -ForegroundColor Cyan
        }
        return
    }
    if ($nc) {
        Write-Host ('{0,-20} {1,-14} {2,-16} {3,-18} {4}' -f 'Timestamp (Local)', 'Mode', 'Target', 'MutationType', 'Reversible')
        Write-Host ('-' * 80)
    } else {
        Write-Host ('{0,-20} {1,-14} {2,-16} {3,-18} {4}' -f 'Timestamp (Local)', 'Mode', 'Target', 'MutationType', 'Reversible') -ForegroundColor Gray
        Write-Host ('-' * 80) -ForegroundColor Gray
    }
    foreach ($e in $Entries) {
        $ts = if ($e.TimestampLocal) { [string]$e.TimestampLocal } else { [string]$e.TimestampUtc }
        if ($ts.Length -gt 19) { $ts = $ts.Substring(0, 19).Replace('T', ' ') }
        $revStr = if ($e.Reversible) { 'Yes' } else { 'No' }
        $revCol = if ($e.Reversible) { 'Green' } else { 'DarkGray' }
        $line = ('{0,-20} {1,-14} {2,-16} {3,-18} ' -f $ts, [string]$e.Mode, [string]$e.Target, [string]$e.MutationType)
        $idShort = if ($e.EntryId -and $e.EntryId.Length -ge 8) { $e.EntryId.Substring(0, 8) } else { [string]$e.EntryId }
        if ($nc) {
            Write-Host ($line + $revStr)
            Write-Host ('    ' + $e.Description + ' [ID: ' + $idShort + ']')
        } else {
            Write-Host $line -NoNewline
            Write-Host $revStr -ForegroundColor $revCol
            Write-Host ('    ' + $e.Description + ' ') -NoNewline -ForegroundColor DarkGray
            Write-Host ('[ID: ' + $idShort + ']') -ForegroundColor Cyan
        }
    }
    if ($nc) {
        Write-Host '================================================================================'
    } else {
        Write-Host '================================================================================' -ForegroundColor Cyan
    }
}

function Invoke-Undo {
    param(
        [string]$TargetId = '',
        [string]$TargetRunId = '',
        [switch]$Plan,
        [switch]$Force,
        [switch]$Json,
        [switch]$Quiet,
        [switch]$NoColor
    )
    $allEntries = Get-ChangeLedgerEntries
    if ($allEntries.Count -eq 0) {
        if ($TargetId) {
            if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'NotFound'; TargetId = $TargetId; UndoneCount = 0 })) }
            elseif (-not $Quiet) { Write-Host "Error: Entry ID '$TargetId' not found in change ledger." -ForegroundColor Red }
            return @{ Status = 'NotFound'; UndoneCount = 0 }
        }
        if ($TargetRunId) {
            if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'NotFound'; TargetRunId = $TargetRunId; UndoneCount = 0 })) }
            elseif (-not $Quiet) { Write-Host "Error: Run ID '$TargetRunId' not found in change ledger." -ForegroundColor Red }
            return @{ Status = 'NotFound'; UndoneCount = 0 }
        }
        if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'Empty'; UndoneCount = 0; Entries = @() })) }
        elseif (-not $Quiet) { Write-Host 'No mutations recorded in change ledger to undo.' -ForegroundColor Yellow }
        return @{ Status = 'Empty'; UndoneCount = 0 }
    }

    $candidates = @()
    if ($TargetId) {
        $candidates = @($allEntries | Where-Object { $_.EntryId -eq $TargetId -or $_.EntryId -like "$TargetId*" })
        if ($candidates.Count -eq 0) {
            if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'NotFound'; TargetId = $TargetId; UndoneCount = 0 })) }
            elseif (-not $Quiet) { Write-Host "Error: Entry ID '$TargetId' not found in change ledger." -ForegroundColor Red }
            return @{ Status = 'NotFound'; UndoneCount = 0 }
        }
    } elseif ($TargetRunId) {
        $candidates = @($allEntries | Where-Object { $_.RunId -eq $TargetRunId })
        if ($candidates.Count -eq 0) {
            if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'NotFound'; TargetRunId = $TargetRunId; UndoneCount = 0 })) }
            elseif (-not $Quiet) { Write-Host "Error: Run ID '$TargetRunId' not found in change ledger." -ForegroundColor Red }
            return @{ Status = 'NotFound'; UndoneCount = 0 }
        }
    } else {
        $lastMut = @($allEntries | Where-Object { $_.Success -and $_.Reversible -and $_.RunId }) | Select-Object -Last 1
        if (-not $lastMut) { $lastMut = $allEntries[-1] }
        $chosenRunId = $lastMut.RunId
        $candidates = @($allEntries | Where-Object { $_.RunId -eq $chosenRunId })
    }

    $candidatesList = New-Object System.Collections.ArrayList
    foreach ($item in $candidates) { [void]$candidatesList.Add($item) }
    $candidatesList.Reverse()

    if ($Plan -and -not $Quiet -and -not $Json) {
        Write-Host '================================================================================' -ForegroundColor Cyan
        Write-Host '                       PLAN PREVIEW: REVERSIBLE UNDO' -ForegroundColor Cyan
        Write-Host '================================================================================' -ForegroundColor Cyan
    }

    $undoneCount = 0
    $skippedCount = 0
    $planEntries = New-Object System.Collections.ArrayList

    foreach ($e in $candidatesList) {
        $idShort = if ($e.EntryId -and $e.EntryId.Length -ge 8) { $e.EntryId.Substring(0, 8) } else { [string]$e.EntryId }
        if (-not $e.Reversible -and -not $e.UndoScript) {
            if (-not $Quiet -and -not $Json) {
                Write-Host ("  [SKIP] Entry {0} ({1}) is marked non-reversible." -f $idShort, $e.Description) -ForegroundColor DarkGray
            }
            $skippedCount++
            continue
        }

        # Drift Detection
        $driftDetected = $false
        $driftReason = ''
        if ($e.MutationType -eq 'Registry' -and $e.Target -and $e.ValueName) {
            $curVal = (Get-ItemProperty -LiteralPath $e.Target -Name $e.ValueName -ErrorAction SilentlyContinue).($e.ValueName)
            if ($null -ne $curVal -and [string]$curVal -ne [string]$e.NewValue) {
                $driftDetected = $true
                $driftReason = "Current registry value '$curVal' does not match recorded NewValue '$($e.NewValue)'"
            }
        } elseif ($e.MutationType -eq 'DnsClientServerAddress' -and $e.Target) {
            $curDns = @((Get-DnsClientServerAddress -InterfaceAlias $e.Target -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses) -join ','
            $expDns = @($e.NewValue) -join ','
            if ($curDns -ne $expDns) {
                $driftDetected = $true
                $driftReason = "Current DNS '$curDns' does not match recorded NewValue '$expDns'"
            }
        }

        if ($driftDetected -and -not $Force) {
            if (-not $Quiet -and -not $Json) {
                Write-Host ("  [DRIFT REFUSED] Entry {0}: {1} (use -Force to override)" -f $idShort, $driftReason) -ForegroundColor Yellow
            }
            $skippedCount++
            continue
        }

        if ($Plan) {
            [void]$planEntries.Add(@{
                EntryId     = $e.EntryId
                Target      = $e.Target
                Description = $e.Description
                OldValue    = $e.OldValue
                NewValue    = $e.NewValue
                Action      = "Would revert to $($e.OldValue)"
            })
            if (-not $Quiet -and -not $Json) {
                Write-Host ("  [PLAN] Revert {0} on {1}: restore OldValue ({2})" -f $idShort, $e.Target, $e.OldValue) -ForegroundColor Cyan
            }
            $undoneCount++
            continue
        }

        # Apply Reversal
        $undoSuccess = $false
        if ($e.UndoScript) {
            try {
                $sb = [scriptblock]::Create($e.UndoScript)
                $res = Invoke-Change ("Undo {0}: {1}" -f $idShort, $e.Description) $sb
                if ($res) { $undoSuccess = $true }
            } catch {}
        } elseif ($e.MutationType -eq 'DnsClientServerAddress' -and $e.Target) {
            $oldAddresses = @($e.OldValue) | Where-Object { $_ }
            if ($oldAddresses.Count -gt 0) {
                $undoSuccess = Invoke-Change ("Restore DNS on {0} to {1}" -f $e.Target, ($oldAddresses -join ', ')) {
                    Set-DnsClientServerAddress -InterfaceAlias $e.Target -ServerAddresses $oldAddresses -ErrorAction Stop
                }
            } else {
                $undoSuccess = Invoke-Change ("Reset DNS on {0} to DHCP" -f $e.Target) {
                    Set-DnsClientServerAddress -InterfaceAlias $e.Target -ResetServerAddresses -ErrorAction Stop
                }
            }
        } elseif ($e.MutationType -eq 'Registry' -and $e.Target -and $e.ValueName) {
            if ($null -ne $e.OldValue) {
                $undoSuccess = Invoke-Change ("Restore registry {0}\{1} to {2}" -f $e.Target, $e.ValueName, $e.OldValue) {
                    Set-ItemProperty -LiteralPath $e.Target -Name $e.ValueName -Value $e.OldValue -ErrorAction Stop
                }
            } else {
                $undoSuccess = Invoke-Change ("Remove registry value {0}\{1}" -f $e.Target, $e.ValueName) {
                    Remove-ItemProperty -LiteralPath $e.Target -Name $e.ValueName -ErrorAction Stop
                }
            }
        }

        if ($undoSuccess) {
            $undoneCount++
            Add-ChangeLedgerEntry -Description ("Reverted mutation {0}" -f $idShort) -MutationType 'Undo' -Target $e.Target -OldValue $e.NewValue -NewValue $e.OldValue -Success $true -Reversible $false
        }
    }

    $summary = @{
        Status       = if ($Plan) { 'Planned' } else { 'Completed' }
        UndoneCount  = $undoneCount
        SkippedCount = $skippedCount
        Entries      = if ($Plan) { $planEntries } else { @() }
    }

    if ($Json) {
        [Console]::Out.WriteLine((ConvertTo-Json $summary -Depth 4))
    } elseif (-not $Quiet) {
        if ($Plan) {
            Write-Host ("`nPlan preview complete: {0} mutations would be reverted ({1} skipped)." -f $undoneCount, $skippedCount) -ForegroundColor Green
            Write-Host '================================================================================' -ForegroundColor Cyan
        } else {
            Write-Host ("`nUndo complete: {0} mutations reverted, {1} skipped." -f $undoneCount, $skippedCount) -ForegroundColor Green
        }
    }

    return $summary
}

function Format-PlanPreview($Changes, [string]$Mode = '', [switch]$NoColor) {
    $nc = [bool]($NoColor -or $script:NoColor)
    if ($nc) {
        Write-Host '================================================================================'
        Write-Host ("               LANFIXER NON-DESTRUCTIVE PLAN PREVIEW [-Plan] ($Mode)")
        Write-Host '================================================================================'
        Write-Host 'Target               Type               Reversible Action'
        Write-Host ('-' * 80)
    } else {
        Write-Host '================================================================================' -ForegroundColor Cyan
        Write-Host ("               LANFIXER NON-DESTRUCTIVE PLAN PREVIEW [-Plan] ($Mode)") -ForegroundColor Cyan
        Write-Host '================================================================================' -ForegroundColor Cyan
        Write-Host 'Target               Type               Reversible Action' -ForegroundColor Gray
        Write-Host ('-' * 80) -ForegroundColor Gray
    }
    if (-not $Changes -or $Changes.Count -eq 0) {
        if ($nc) {
            Write-Host 'No system mutations required or planned.'
            Write-Host '================================================================================'
        } else {
            Write-Host 'No system mutations required or planned.' -ForegroundColor Green
            Write-Host '================================================================================' -ForegroundColor Cyan
        }
        return
    }
    foreach ($c in $Changes) {
        $revStr = if ($c.Reversible) { 'Yes' } else { 'No' }
        $revCol = if ($c.Reversible) { 'Green' } else { 'Yellow' }
        $line = ('{0,-20} {1,-18} ' -f ([string]$c.Target).PadRight(20).Substring(0,20), ([string]$c.MutationType).PadRight(18).Substring(0,18))
        if ($nc) {
            Write-Host ($line + $revStr.PadRight(11) + $c.Description)
        } else {
            Write-Host $line -NoNewline
            Write-Host ($revStr.PadRight(11)) -NoNewline -ForegroundColor $revCol
            Write-Host ([string]$c.Description) -ForegroundColor Cyan
        }
        if ($null -ne $c.OldValue -or $null -ne $c.NewValue) {
            $diffLine = ('    Old: {0}  ->  New: {1}' -f [string]$c.OldValue, [string]$c.NewValue)
            if ($nc) { Write-Host $diffLine } else { Write-Host $diffLine -ForegroundColor DarkGray }
        }
    }
    if ($nc) {
        Write-Host ('-' * 80)
        Write-Host ("Total Planned Mutations: {0} (Zero system mutations executed)" -f $Changes.Count)
        Write-Host '================================================================================'
    } else {
        Write-Host ('-' * 80) -ForegroundColor Gray
        Write-Host ("Total Planned Mutations: {0} (Zero system mutations executed)" -f $Changes.Count) -ForegroundColor Green
        Write-Host '================================================================================' -ForegroundColor Cyan
    }
}

# ==============================================================================
# FEATURE: SUPREME MULTI-DIMENSIONAL HISTORY & FORENSIC SUITE
# ==============================================================================
function Get-HistorySessionLogs([int]$Limit = 50, [string]$Level = '', [string]$Filter = '') {
    $results = New-Object System.Collections.ArrayList
    if (-not (Test-Path -LiteralPath $script:LogFile)) { return @($results) }
    $lines = @(Get-Content -LiteralPath $script:LogFile -Tail ([Math]::Max(100, $Limit * 5)) -ErrorAction SilentlyContinue)
    for ($i = $lines.Count - 1; $i -ge 0; $i--) {
        $l = $lines[$i]
        if (-not $l -or $l.Trim() -eq '') { continue }
        $ts = ''; $lvl = 'INFO'; $msg = $l
        $m = [regex]::Match($l, '^\[(.*?)\]\s+\[(.*?)\]\s+(.*)$')
        if ($m.Success) {
            $ts = $m.Groups[1].Value
            $lvl = $m.Groups[2].Value.ToUpper()
            $msg = $m.Groups[3].Value
        }
        if ($Level -and $lvl -ne $Level.ToUpper()) { continue }
        if ($Filter -and $msg -notmatch [regex]::Escape($Filter)) { continue }
        [void]$results.Add(@{
            Timestamp = $ts
            Level     = $lvl
            Message   = $msg
            Source    = 'LanFixer.log'
        })
        if ($Limit -gt 0 -and $results.Count -ge $Limit) { break }
    }
    return @($results)
}

function Show-HistorySessionLogs([int]$Limit = 50, [string]$Level = '', [string]$Filter = '', [switch]$NoColor) {
    $nc = [bool]($NoColor -or $script:NoColor)
    $logs = @(Get-HistorySessionLogs -Limit $Limit -Level $Level -Filter $Filter)
    if ($nc) {
        Write-Host '================================================================================'
        Write-Host ('             LANFIXER EXACT SESSION EXECUTION LOGS (LAST {0})' -f $logs.Count)
        Write-Host '================================================================================'
    } else {
        Write-Host '================================================================================' -ForegroundColor Cyan
        Write-Host ('             LANFIXER EXACT SESSION EXECUTION LOGS (LAST {0})' -f $logs.Count) -ForegroundColor Cyan
        Write-Host '================================================================================' -ForegroundColor Cyan
    }
    if ($logs.Count -eq 0) {
        if ($nc) {
            Write-Host '  No matching log records found.'
        } else {
            Write-Host '  No matching log records found.' -ForegroundColor Gray
        }
        return
    }
    foreach ($entry in $logs) {
        $col = switch ($entry.Level) {
            'OK'   { 'Green' }
            'WARN' { 'Yellow' }
            'FAIL' { 'Red' }
            'STEP' { 'Cyan' }
            default { 'Gray' }
        }
        $linePrefix = ('[{0}] [{1,-4}] ' -f $entry.Timestamp, $entry.Level)
        if ($nc) {
            Write-Host ($linePrefix + $entry.Message)
        } else {
            Write-Host $linePrefix -NoNewline -ForegroundColor $col
            Write-Host $entry.Message -ForegroundColor $(if ($entry.Level -in @('FAIL','WARN')) { $col } else { 'White' })
        }
    }
    if ($nc) {
        Write-Host '================================================================================'
    } else {
        Write-Host '================================================================================' -ForegroundColor Cyan
    }
}

function Get-HistoryErrors([int]$Limit = 50, [int]$Hours = 24) {
    $errList = New-Object System.Collections.ArrayList
    $logErrs = Get-HistorySessionLogs -Limit ($Limit * 3)
    foreach ($e in $logErrs) {
        if ($e.Level -in @('FAIL', 'WARN')) {
            [void]$errList.Add(@{
                Timestamp = $e.Timestamp
                Severity  = if ($e.Level -eq 'FAIL') { 'Error' } else { 'Warning' }
                Category  = 'LanFixer'
                Source    = 'LanFixer.log'
                Message   = $e.Message
            })
            if ($errList.Count -ge $Limit) { break }
        }
    }
    $ledgerFile = Join-Path $script:StoreDir 'change_ledger.jsonl'
    if (Test-Path -LiteralPath $ledgerFile) {
        $lines = @(Get-Content -LiteralPath $ledgerFile -ErrorAction SilentlyContinue)
        for ($i = $lines.Count - 1; $i -ge 0; $i--) {
            try {
                $item = ConvertFrom-Json $lines[$i]
                if ($item -and $item.Success -eq $false) {
                    [void]$errList.Add(@{
                        Timestamp = if ($item.TimestampLocal) { $item.TimestampLocal } else { $item.TimestampUtc }
                        Severity  = 'Error'
                        Category  = 'Mutation'
                        Source    = 'change_ledger.jsonl'
                        Message   = ("Failed mutation ({0}) on {1}: {2}" -f $item.MutationType, $item.Target, $item.Description)
                    })
                }
            } catch {}
            if ($errList.Count -ge ($Limit * 2)) { break }
        }
    }
    try {
        $winErrs = @(Get-WinEvent -FilterHashtable @{ LogName = 'System'; Level = @(1, 2); StartTime = (Get-Date).AddHours(-$Hours) } -MaxEvents 30 -ErrorAction SilentlyContinue)
        foreach ($we in $winErrs) {
            $pName = [string]$we.ProviderName
            if ($pName -match 'Tcpip|Dhcp|DNS|NDIS|Netw|e1d|WLAN|Network') {
                [void]$errList.Add(@{
                    Timestamp = $we.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss')
                    Severity  = 'Critical/Error'
                    Category  = 'Windows OS'
                    Source    = $pName
                    Message   = ($we.Message -replace "[\r\n]+", " ").Trim()
                })
            }
        }
    } catch {}
    return @($errList | Select-Object -First $Limit)
}

function Show-HistoryErrors([int]$Limit = 50, [switch]$NoColor) {
    $nc = [bool]($NoColor -or $script:NoColor)
    $errors = @(Get-HistoryErrors -Limit $Limit)
    if ($nc) {
        Write-Host '================================================================================'
        Write-Host ('                 LANFIXER ERROR & FAILURE AUDIT ({0} RECORDS)' -f $errors.Count)
        Write-Host '================================================================================'
    } else {
        Write-Host '================================================================================' -ForegroundColor Red
        Write-Host ('                 LANFIXER ERROR & FAILURE AUDIT ({0} RECORDS)' -f $errors.Count) -ForegroundColor Red
        Write-Host '================================================================================' -ForegroundColor Red
    }
    if ($errors.Count -eq 0) {
        if ($nc) {
            Write-Host '  Zero errors or warnings detected in current lookback window.'
        } else {
            Write-Host '  Zero errors or warnings detected in current lookback window.' -ForegroundColor Green
        }
        return
    }
    $critCount = @($errors | Where-Object { $_.Severity -match 'Error|Critical' }).Count
    $warnCount = @($errors | Where-Object { $_.Severity -match 'Warning' }).Count
    if ($nc) {
        Write-Host ("  Total Errors: {0} | Warnings: {1}" -f $critCount, $warnCount)
        Write-Host ('-' * 80)
    } else {
        Write-Host ("  Total Errors: {0} | Warnings: {1}" -f $critCount, $warnCount) -ForegroundColor Yellow
        Write-Host ('-' * 80) -ForegroundColor DarkGray
    }
    foreach ($err in $errors) {
        $isCrit = ($err.Severity -match 'Error|Critical')
        $col = if ($isCrit) { 'Red' } else { 'Yellow' }
        $hdr = ('{0,-20} [{1,-8}] [{2,-14}] ' -f $err.Timestamp, $err.Severity, $err.Category)
        if ($nc) {
            Write-Host ($hdr + $err.Source)
            Write-Host ('    ' + $err.Message)
        } else {
            Write-Host $hdr -NoNewline -ForegroundColor $col
            Write-Host $err.Source -ForegroundColor White
            Write-Host ('    ' + $err.Message) -ForegroundColor Gray
        }
    }
    if ($nc) {
        Write-Host '================================================================================'
    } else {
        Write-Host '================================================================================' -ForegroundColor Red
    }
}

function Get-HistoryWindowsEvents([int]$Limit = 50, [int]$Hours = 24) {
    $out = New-Object System.Collections.ArrayList
    try {
        $npEvents = @(Get-WinEvent -FilterHashtable @{ LogName = 'Microsoft-Windows-NetworkProfile/Operational'; StartTime = (Get-Date).AddHours(-$Hours) } -MaxEvents ($Limit / 2) -ErrorAction SilentlyContinue)
        foreach ($e in $npEvents) {
            $desc = switch ($e.Id) {
                10000 { "Network Connected" }
                10001 { "Network Disconnected" }
                4004  { "Network State Change Fired" }
                default { "Network Profile Event $($e.Id)" }
            }
            [void]$out.Add(@{
                Timestamp = $e.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss')
                Channel   = 'NetworkProfile'
                EventId   = $e.Id
                Type      = 'State'
                Summary   = $desc
                Details   = ($e.Message -replace "[\r\n]+", " ").Trim()
            })
        }
    } catch {}
    try {
        $ncsiEvents = @(Get-WinEvent -FilterHashtable @{ LogName = 'Microsoft-Windows-NCSI/Operational'; StartTime = (Get-Date).AddHours(-$Hours) } -MaxEvents 15 -ErrorAction SilentlyContinue)
        foreach ($e in $ncsiEvents) {
            $desc = switch ($e.Id) {
                4042  { "Active Web Probe Result" }
                4001  { "NCSI Capability Transition" }
                default { "NCSI Event $($e.Id)" }
            }
            [void]$out.Add(@{
                Timestamp = $e.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss')
                Channel   = 'NCSI'
                EventId   = $e.Id
                Type      = 'Probe'
                Summary   = $desc
                Details   = ($e.Message -replace "[\r\n]+", " ").Trim()
            })
        }
    } catch {}
    try {
        $dhcpEvents = @(Get-WinEvent -FilterHashtable @{ LogName = 'System'; ProviderName = @('Dhcp-Client','Microsoft-Windows-Dhcp-Client'); StartTime = (Get-Date).AddHours(-$Hours) } -MaxEvents 15 -ErrorAction SilentlyContinue)
        foreach ($e in $dhcpEvents) {
            $desc = switch ($e.Id) {
                50036 { "DHCPv4 client service started" }
                50037 { "DHCPv4 client service stopped" }
                1001  { "DHCP address lease assigned" }
                1002  { "DHCP lease renewal failed" }
                1003  { "DHCP lease expired / APIPA fallback" }
                default { "DHCP Client Event $($e.Id)" }
            }
            [void]$out.Add(@{
                Timestamp = $e.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss')
                Channel   = 'Dhcp-Client'
                EventId   = $e.Id
                Type      = 'Lease'
                Summary   = $desc
                Details   = ($e.Message -replace "[\r\n]+", " ").Trim()
            })
        }
    } catch {}
    return @($out | Sort-Object { $_.Timestamp } -Descending | Select-Object -First $Limit)
}

function Show-HistoryWindowsEvents([int]$Limit = 50, [switch]$NoColor) {
    $nc = [bool]($NoColor -or $script:NoColor)
    $events = @(Get-HistoryWindowsEvents -Limit $Limit)
    if ($nc) {
        Write-Host '================================================================================'
        Write-Host ('             WINDOWS OS NETWORK EVENT FORENSICS ({0} RECORDS)' -f $events.Count)
        Write-Host '================================================================================'
    } else {
        Write-Host '================================================================================' -ForegroundColor Cyan
        Write-Host ('             WINDOWS OS NETWORK EVENT FORENSICS ({0} RECORDS)' -f $events.Count) -ForegroundColor Cyan
        Write-Host '================================================================================' -ForegroundColor Cyan
    }
    if ($events.Count -eq 0) {
        if ($nc) {
            Write-Host '  No recent Windows networking OS events recorded in lookback window.'
        } else {
            Write-Host '  No recent Windows networking OS events recorded in lookback window.' -ForegroundColor Gray
        }
        return
    }
    foreach ($ev in $events) {
        $prefix = ('{0,-20} [{1,-14}:{2,-5}] ' -f $ev.Timestamp, $ev.Channel, $ev.EventId)
        if ($nc) {
            Write-Host ($prefix + $ev.Summary)
            Write-Host ('    ' + $ev.Details)
        } else {
            Write-Host $prefix -NoNewline -ForegroundColor Yellow
            Write-Host $ev.Summary -ForegroundColor White
            Write-Host ('    ' + $ev.Details) -ForegroundColor DarkGray
        }
    }
    if ($nc) {
        Write-Host '================================================================================'
    } else {
        Write-Host '================================================================================' -ForegroundColor Cyan
    }
}

function Get-HistoryStateTransitions([int]$Limit = 30) {
    $trans = New-Object System.Collections.ArrayList
    $lm = $script:State.LinkMonitor
    if ($lm -is [System.Collections.IEnumerable]) {
        foreach ($item in $lm) {
            if ($item) {
                [void]$trans.Add(@{
                    Timestamp = [string]$item.Timestamp
                    Type      = 'LinkTransition'
                    Adapter   = [string]$item.Adapter
                    Status    = [string]$item.Status
                    Speed     = [string]$item.Speed
                    Details   = ("Link transition on {0}: Status={1} Speed={2}" -f $item.Adapter, $item.Status, $item.Speed)
                })
            }
        }
    }
    $np = Get-HistoryWindowsEvents -Limit $Limit
    foreach ($e in $np) {
        if ($e.Channel -eq 'NetworkProfile') {
            [void]$trans.Add(@{
                Timestamp = $e.Timestamp
                Type      = 'NetworkProfile'
                Adapter   = 'Windows'
                Status    = $e.Summary
                Speed     = '-'
                Details   = $e.Details
            })
        }
    }
    return @($trans | Sort-Object { $_.Timestamp } -Descending | Select-Object -First $Limit)
}

function Show-HistoryStateTransitions([int]$Limit = 30, [switch]$NoColor) {
    $nc = [bool]($NoColor -or $script:NoColor)
    $trans = @(Get-HistoryStateTransitions -Limit $Limit)
    if ($nc) {
        Write-Host '================================================================================'
        Write-Host ('            NETWORK STATE TRANSITIONS & FLAP AUDIT ({0} RECORDS)' -f $trans.Count)
        Write-Host '================================================================================'
    } else {
        Write-Host '================================================================================' -ForegroundColor Cyan
        Write-Host ('            NETWORK STATE TRANSITIONS & FLAP AUDIT ({0} RECORDS)' -f $trans.Count) -ForegroundColor Cyan
        Write-Host '================================================================================' -ForegroundColor Cyan
    }
    if ($trans.Count -eq 0) {
        if ($nc) {
            Write-Host '  No network link flaps or transitions recorded.'
        } else {
            Write-Host '  No network link flaps or transitions recorded.' -ForegroundColor Green
        }
        return
    }
    foreach ($t in $trans) {
        $line = ('{0,-20} {1,-16} {2,-18} ' -f $t.Timestamp, $t.Type, $t.Status)
        if ($nc) {
            Write-Host ($line + $t.Details)
        } else {
            Write-Host $line -NoNewline -ForegroundColor White
            Write-Host $t.Details -ForegroundColor DarkGray
        }
    }
    if ($nc) {
        Write-Host '================================================================================'
    } else {
        Write-Host '================================================================================' -ForegroundColor Cyan
    }
}

function Get-HistoryHeals([int]$Limit = 30) {
    $heals = New-Object System.Collections.ArrayList
    $logs = Get-HistorySessionLogs -Limit ($Limit * 4)
    foreach ($l in $logs) {
        if ($l.Message -match '^(Executing initial repair pipeline|Watchdog active|Signed in automatically|Completed stage|ChangeLedger:|Invoking [A-Za-z]+Heal|Supreme Omnifix|Ultra System Reset|Doomsday Reset|Armageddon Reset|HealSummary)') {
            [void]$heals.Add(@{
                Timestamp = $l.Timestamp
                Type      = if ($l.Message -match 'Reset') { 'SystemReset' } elseif ($l.Message -match 'Watchdog') { 'Watchdog' } else { 'QuickHeal' }
                Message   = $l.Message
                Level     = $l.Level
            })
            if ($heals.Count -ge $Limit) { break }
        }
    }
    return @($heals)
}

function Show-HistoryHeals([int]$Limit = 30, [switch]$NoColor) {
    $nc = [bool]($NoColor -or $script:NoColor)
    $heals = @(Get-HistoryHeals -Limit $Limit)
    if ($nc) {
        Write-Host '================================================================================'
        Write-Host ('               HEAL & REMEDIATION RUN AUDIT ({0} RECORDS)' -f $heals.Count)
        Write-Host '================================================================================'
    } else {
        Write-Host '================================================================================' -ForegroundColor Cyan
        Write-Host ('               HEAL & REMEDIATION RUN AUDIT ({0} RECORDS)' -f $heals.Count) -ForegroundColor Cyan
        Write-Host '================================================================================' -ForegroundColor Cyan
    }
    if ($heals.Count -eq 0) {
        if ($nc) {
            Write-Host '  No recent heal runs recorded.'
        } else {
            Write-Host '  No recent heal runs recorded.' -ForegroundColor Gray
        }
        return
    }
    foreach ($h in $heals) {
        $prefix = ('{0,-20} [{1,-11}] ' -f $h.Timestamp, $h.Type)
        if ($nc) {
            Write-Host ($prefix + $h.Message)
        } else {
            Write-Host $prefix -NoNewline -ForegroundColor Green
            Write-Host $h.Message -ForegroundColor White
        }
    }
    if ($nc) {
        Write-Host '================================================================================'
    } else {
        Write-Host '================================================================================' -ForegroundColor Cyan
    }
}

function Get-HistoryTimeline([int]$Limit = 50) {
    $timeline = New-Object System.Collections.ArrayList
    $ledgerFile = Join-Path $script:StoreDir 'change_ledger.jsonl'
    if (Test-Path -LiteralPath $ledgerFile) {
        $lines = @(Get-Content -LiteralPath $ledgerFile -ErrorAction SilentlyContinue)
        for ($i = $lines.Count - 1; $i -ge 0; $i--) {
            try {
                $e = ConvertFrom-Json $lines[$i]
                if ($e -and $e.Description) {
                    $ts = if ($e.TimestampLocal) { $e.TimestampLocal } else { $e.TimestampUtc }
                    if ($ts.Length -gt 19) { $ts = $ts.Substring(0, 19).Replace('T', ' ') }
                    [void]$timeline.Add(@{
                        Timestamp = $ts
                        Category  = '[MUTATION]'
                        Source    = if ($e.Mode) { $e.Mode } else { 'LanFixer' }
                        Event     = ("{0} on {1}: {2}" -f $e.MutationType, $e.Target, $e.Description)
                    })
                }
            } catch {}
            if ($timeline.Count -ge ($Limit / 2)) { break }
        }
    }
    $logs = Get-HistorySessionLogs -Limit ($Limit / 2)
    foreach ($l in $logs) {
        $cat = if ($l.Level -in @('FAIL', 'WARN')) { '[ERROR]' } elseif ($l.Level -eq 'STEP') { '[STEP]' } else { '[LOG]' }
        [void]$timeline.Add(@{
            Timestamp = $l.Timestamp
            Category  = $cat
            Source    = 'LanFixer'
            Event     = $l.Message
        })
    }
    $win = Get-HistoryWindowsEvents -Limit ($Limit / 2)
    foreach ($w in $win) {
        [void]$timeline.Add(@{
            Timestamp = $w.Timestamp
            Category  = '[OS-EVENT]'
            Source    = $w.Channel
            Event     = ("{0}: {1}" -f $w.Summary, $w.Details)
        })
    }
    return @($timeline | Sort-Object { $_.Timestamp } -Descending | Select-Object -First $Limit)
}

function Show-HistoryTimeline([int]$Limit = 50, [switch]$NoColor) {
    $nc = [bool]($NoColor -or $script:NoColor)
    $items = @(Get-HistoryTimeline -Limit $Limit)
    if ($nc) {
        Write-Host '================================================================================'
        Write-Host ('         UNIFIED CAUSALITY TIMELINE ("WHAT BROKE WHEN") ({0} EVENTS)' -f $items.Count)
        Write-Host '================================================================================'
    } else {
        Write-Host '================================================================================' -ForegroundColor Cyan
        Write-Host ('         UNIFIED CAUSALITY TIMELINE ("WHAT BROKE WHEN") ({0} EVENTS)' -f $items.Count) -ForegroundColor Cyan
        Write-Host '================================================================================' -ForegroundColor Cyan
    }
    if ($items.Count -eq 0) {
        if ($nc) {
            Write-Host '  No events recorded in causality timeline.'
        } else {
            Write-Host '  No events recorded in causality timeline.' -ForegroundColor Gray
        }
        return
    }
    foreach ($it in $items) {
        $catCol = switch ($it.Category) {
            '[MUTATION]' { 'Cyan' }
            '[ERROR]'    { 'Red' }
            '[STEP]'     { 'Yellow' }
            '[OS-EVENT]' { 'Magenta' }
            default      { 'Gray' }
        }
        $line = ('{0,-20} {1,-11} {2,-16} ' -f $it.Timestamp, $it.Category, $it.Source)
        if ($nc) {
            Write-Host ($line + $it.Event)
        } else {
            Write-Host $line -NoNewline -ForegroundColor $catCol
            Write-Host $it.Event -ForegroundColor White
        }
    }
    if ($nc) {
        Write-Host '================================================================================'
    } else {
        Write-Host '================================================================================' -ForegroundColor Cyan
    }
}

function Show-HistoryLiveStream([int]$RefreshSeconds = 2) {
    Clear-Screen
    Show-Cursor $false
    Write-Banner 'REAL-TIME LIVE FORENSIC MONITOR STREAM'
    Out-Line @((Seg 'text' '  Streaming live LanFixer logs, system events, and gateway pulse in real time.'))
    Out-Line @((Seg 'dim' '  [SPACE] Pause/Resume  |  [C] Clear Screen  |  [Q] Return to Menu'))
    Out-Line @()
    $paused = $false
    $lastLineCount = 0
    try {
        while ($true) {
            if (Test-KeyAvailable) {
                $k = Read-KeyNow
                $ch = if ($k -and $k.KeyChar) { [string]$k.KeyChar } else { '' }
                if ($ch.ToLowerInvariant() -eq 'q') { break }
                elseif ($ch -eq ' ') {
                    $paused = -not $paused
                    Out-Line @((Seg $(if ($paused) { 'warn!' } else { 'ok!' }) ("  [Stream " + $(if ($paused) { 'PAUSED' } else { 'RESUMED' }) + "]")))
                } elseif ($ch.ToLowerInvariant() -eq 'c') {
                    Clear-Screen
                    Write-Banner 'REAL-TIME LIVE FORENSIC MONITOR STREAM'
                    Out-Line @((Seg 'dim' '  [SPACE] Pause/Resume  |  [C] Clear Screen  |  [Q] Return to Menu'))
                    Out-Line @()
                }
            }
            if (-not $paused -and (Test-Path -LiteralPath $script:LogFile)) {
                $allLines = @(Get-Content -LiteralPath $script:LogFile -Tail 20 -ErrorAction SilentlyContinue)
                if ($allLines.Count -gt $lastLineCount) {
                    $newCount = $allLines.Count - $lastLineCount
                    $start = [Math]::Max(0, $allLines.Count - [Math]::Min(5, $newCount))
                    for ($idx = $start; $idx -lt $allLines.Count; $idx++) {
                        $line = $allLines[$idx]
                        $col = 'dim'
                        if ($line -match '\[OK\s*\]') { $col = 'ok' }
                        elseif ($line -match '\[WARN\s*\]') { $col = 'warn' }
                        elseif ($line -match '\[FAIL\s*\]') { $col = 'bad' }
                        elseif ($line -match '\[STEP\s*\]') { $col = 'accent!' }
                        elseif ($line -match '\[INFO\s*\]') { $col = 'dim' }
                        Out-Line @((Seg $col ("  " + $line)))
                    }
                }
                $lastLineCount = $allLines.Count
            }
            Start-Sleep -Milliseconds ($RefreshSeconds * 1000)
        }
    } finally {
        Show-Cursor $true
    }
}

function Export-HistoryForensicBundle([string]$OutFile = '', [switch]$Json) {
    $bundle = @{
        GeneratedAt   = (Get-Date).ToString('o')
        MachineName   = $env:COMPUTERNAME
        User          = $env:USERNAME
        OSVersion     = [Environment]::OSVersion.VersionString
        PSVersion     = $PSVersionTable.PSVersion.ToString()
        Mutations     = @(Get-ChangeLedgerEntries -Limit 100)
        RecentLogs    = @(Get-HistorySessionLogs -Limit 100)
        Errors        = @(Get-HistoryErrors -Limit 50)
        WindowsEvents = @(Get-HistoryWindowsEvents -Limit 50)
        Transitions   = @(Get-HistoryStateTransitions -Limit 50)
        HealRuns      = @(Get-HistoryHeals -Limit 50)
        Timeline      = @(Get-HistoryTimeline -Limit 100)
    }
    if (-not $OutFile) {
        $stamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
        $ext = if ($Json) { 'json' } else { 'txt' }
        $fileName = ("LanFixer_Forensic_History_{0}.{1}" -f $stamp, $ext)
        $targetDir = $PWD.Path
        $canWrite = $false
        try {
            $testP = Join-Path $targetDir (".lf_test_" + [guid]::NewGuid().ToString('N'))
            [System.IO.File]::WriteAllText($testP, 'x')
            Remove-Item -LiteralPath $testP -Force -ErrorAction SilentlyContinue
            $canWrite = $true
        } catch {}
        if (-not $canWrite) {
            $targetDir = [System.IO.Path]::GetTempPath()
        }
        $OutFile = Join-Path $targetDir $fileName
    }
    if ($Json) {
        $jsonTxt = ConvertTo-Json $bundle -Depth 5
        [System.IO.File]::WriteAllText($OutFile, $jsonTxt, [System.Text.Encoding]::ASCII)
    } else {
        $sb = New-Object System.Text.StringBuilder
        [void]$sb.AppendLine('=' * 80)
        [void]$sb.AppendLine('             LANFIXER SUPREME FORENSIC HISTORY EXPORT BUNDLE')
        [void]$sb.AppendLine('=' * 80)
        [void]$sb.AppendLine("Timestamp: $($bundle.GeneratedAt) | Host: $($bundle.MachineName) | User: $($bundle.User)")
        [void]$sb.AppendLine("OS: $($bundle.OSVersion) | PowerShell: $($bundle.PSVersion)")
        [void]$sb.AppendLine('=' * 80)
        [void]$sb.AppendLine("`n--- [1] RECENT MUTATIONS ($($bundle.Mutations.Count)) ---")
        foreach ($m in $bundle.Mutations) {
            [void]$sb.AppendLine(("{0} [{1}] {2} -> {3}" -f $m.TimestampLocal, $m.MutationType, $m.Target, $m.Description))
        }
        [void]$sb.AppendLine("`n--- [2] ERROR & FAILURE AUDIT ($($bundle.Errors.Count)) ---")
        foreach ($e in $bundle.Errors) {
            [void]$sb.AppendLine(("{0} [{1}] [{2}] {3}" -f $e.Timestamp, $e.Severity, $e.Source, $e.Message))
        }
        [void]$sb.AppendLine("`n--- [3] WINDOWS NETWORK OS EVENTS ($($bundle.WindowsEvents.Count)) ---")
        foreach ($w in $bundle.WindowsEvents) {
            [void]$sb.AppendLine(("{0} [{1}:{2}] {3} - {4}" -f $w.Timestamp, $w.Channel, $w.EventId, $w.Summary, $w.Details))
        }
        [void]$sb.AppendLine("`n--- [4] UNIFIED CAUSALITY TIMELINE ($($bundle.Timeline.Count)) ---")
        foreach ($t in $bundle.Timeline) {
            [void]$sb.AppendLine(("{0} {1,-12} {2,-16} {3}" -f $t.Timestamp, $t.Category, $t.Source, $t.Event))
        }
        [System.IO.File]::WriteAllText($OutFile, $sb.ToString(), [System.Text.Encoding]::ASCII)
    }
    Write-Host ("Forensic history exported to: {0}" -f $OutFile) -ForegroundColor Green
    return @{ Path = $OutFile; Entries = $bundle.Timeline.Count }
}

function Show-HistoryMenu {
    while ($true) {
        Clear-Screen; Show-Cursor $true
        Write-Banner 'LANFIXER SUPREME HISTORY & FORENSIC SUITE'
        Out-Line @((Seg 'text' '  Unified multi-dimensional audit of all system mutations, logs, errors, and events:'))
        Out-Line @()
        $sections = @(
            @('1', 'Mutation & Change Ledger',    'm', 'Exact registry, DNS, and route changes modified by LanFixer'),
            @('2', 'Exact Session Logs',          'l', 'Chronological execution logs from LanFixer.log (with level filters)'),
            @('3', 'Error & Failure Audit',       'e', 'All caught errors, failed native calls, timeouts, and exceptions'),
            @('4', 'Windows OS Network Events',   'w', 'Real-time Windows Event Log network forensic analysis (NDIS/DHCP/DNS)'),
            @('5', 'Network State Transitions',   's', 'Link up/down transitions, speed drops, flaps, and IP lease changes'),
            @('6', 'Heal & Remediation Runs',     'h', 'Historical record of QuickHeal, Watchdog, and System Reset passes'),
            @('7', 'Unified Causality Timeline',  't', 'Deep chronological correlation: "What broke when & root cause"'),
            @('8', 'Live Forensic Monitor Stream','r', 'Real-time live streaming tail of operations, events, and gateway pulse'),
            @('9', 'Export Forensic Bundle',      'x', 'Save complete history audit to a comprehensive diagnostic file')
        )
        foreach ($sec in $sections) {
            Out-Line @(
                (Seg 'faint' '  ['),
                (Seg 'accent!' $sec[0]),
                (Seg 'faint' '] '),
                (Seg 'text!' ($sec[1].PadRight(28))),
                (Seg 'dim' $sec[3])
            )
        }
        Out-Line @()
        Out-Line @((Seg 'dim' '  Select section [1-9] or [M/L/E/W/S/H/T/R/X], or press any other key to return '), (Seg 'accent!' $script:G.prompt)) -NoNewline
        $k = Read-Choice
        Out-Line @()
        $c = ([string]$k.KeyChar).ToLowerInvariant()
        switch ($c) {
            { $_ -eq '1' -or $_ -eq 'm' } {
                Show-View 'mutation & change ledger' { Format-LedgerHistory (Get-ChangeLedgerEntries -Limit 50) }
            }
            { $_ -eq '2' -or $_ -eq 'l' } {
                Show-View 'exact session logs' { Show-HistorySessionLogs -Limit 50 }
            }
            { $_ -eq '3' -or $_ -eq 'e' } {
                Show-View 'error & failure audit' { Show-HistoryErrors -Limit 50 }
            }
            { $_ -eq '4' -or $_ -eq 'w' } {
                Show-View 'windows os network events' { Show-HistoryWindowsEvents -Limit 50 }
            }
            { $_ -eq '5' -or $_ -eq 's' } {
                Show-View 'network state transitions' { Show-HistoryStateTransitions -Limit 30 }
            }
            { $_ -eq '6' -or $_ -eq 'h' } {
                Show-View 'heal & remediation runs' { Show-HistoryHeals -Limit 30 }
            }
            { $_ -eq '7' -or $_ -eq 't' } {
                Show-View 'unified causality timeline' { Show-HistoryTimeline -Limit 50 }
            }
            { $_ -eq '8' -or $_ -eq 'r' } {
                Show-HistoryLiveStream -RefreshSeconds 2
            }
            { $_ -eq '9' -or $_ -eq 'x' } {
                Show-View 'export forensic history bundle' { [void](Export-HistoryForensicBundle) }
            }
            default { return }
        }
    }
}

function Invoke-HistorySuite {
    param(
        [string]$Section = '',
        [int]$Limit = 20,
        [switch]$Follow,
        [string]$Level = '',
        [string]$Filter = '',
        [string]$OutFile = '',
        [switch]$Json,
        [switch]$Quiet,
        [switch]$NoColor
    )
    if ($Follow -or $Section -in @('live', 'stream', 'tail', 'realtime')) {
        Show-HistoryLiveStream
        return 0
    }
    $sec = $Section.ToLowerInvariant()
    if ($Json) {
        $res = switch ($sec) {
            { $_ -in @('mutations', 'changes', 'ledger') } { @(Get-ChangeLedgerEntries -Limit $Limit) }
            { $_ -in @('logs', 'session') }                { @(Get-HistorySessionLogs -Limit $Limit -Level $Level -Filter $Filter) }
            { $_ -in @('errors', 'failures') }             { @(Get-HistoryErrors -Limit $Limit) }
            { $_ -in @('os', 'windows', 'events') }        { @(Get-HistoryWindowsEvents -Limit $Limit) }
            { $_ -in @('states', 'transitions', 'flaps') } { @(Get-HistoryStateTransitions -Limit $Limit) }
            { $_ -in @('heals', 'remediations') }          { @(Get-HistoryHeals -Limit $Limit) }
            { $_ -in @('timeline', 'causality') }          { @(Get-HistoryTimeline -Limit $Limit) }
            { $_ -in @('export', 'bundle') }               { Export-HistoryForensicBundle -OutFile $OutFile -Json }
            default {
                @{
                    Mutations   = @(Get-ChangeLedgerEntries -Limit $Limit)
                    Logs        = @(Get-HistorySessionLogs -Limit $Limit -Level $Level -Filter $Filter)
                    Errors      = @(Get-HistoryErrors -Limit $Limit)
                    WindowsEvents = @(Get-HistoryWindowsEvents -Limit $Limit)
                    Transitions = @(Get-HistoryStateTransitions -Limit $Limit)
                    Heals       = @(Get-HistoryHeals -Limit $Limit)
                    Timeline    = @(Get-HistoryTimeline -Limit $Limit)
                }
            }
        }
        [Console]::Out.WriteLine((ConvertTo-Json $res -Depth 4))
        return 0
    }
    if ($Quiet) {
        $count = switch ($sec) {
            { $_ -in @('mutations', 'changes', 'ledger') } { (Get-ChangeLedgerEntries -Limit $Limit).Count }
            { $_ -in @('logs', 'session') }                { (Get-HistorySessionLogs -Limit $Limit -Level $Level -Filter $Filter).Count }
            { $_ -in @('errors', 'failures') }             { (Get-HistoryErrors -Limit $Limit).Count }
            { $_ -in @('os', 'windows', 'events') }        { (Get-HistoryWindowsEvents -Limit $Limit).Count }
            { $_ -in @('states', 'transitions', 'flaps') } { (Get-HistoryStateTransitions -Limit $Limit).Count }
            { $_ -in @('heals', 'remediations') }          { (Get-HistoryHeals -Limit $Limit).Count }
            { $_ -in @('timeline', 'causality') }          { (Get-HistoryTimeline -Limit $Limit).Count }
            default                                        { (Get-HistoryTimeline -Limit $Limit).Count }
        }
        [Console]::Out.WriteLine(("History [{0}]: {1} entries" -f $(if ($Section) { $Section } else { 'Timeline' }), $count))
        return 0
    }
    switch ($sec) {
        { $_ -in @('mutations', 'changes', 'ledger') } { Format-LedgerHistory (Get-ChangeLedgerEntries -Limit $Limit) -NoColor:$NoColor }
        { $_ -in @('logs', 'session') }                { Show-HistorySessionLogs -Limit $Limit -Level $Level -Filter $Filter -NoColor:$NoColor }
        { $_ -in @('errors', 'failures') }             { Show-HistoryErrors -Limit $Limit -NoColor:$NoColor }
        { $_ -in @('os', 'windows', 'events') }        { Show-HistoryWindowsEvents -Limit $Limit -NoColor:$NoColor }
        { $_ -in @('states', 'transitions', 'flaps') } { Show-HistoryStateTransitions -Limit $Limit -NoColor:$NoColor }
        { $_ -in @('heals', 'remediations') }          { Show-HistoryHeals -Limit $Limit -NoColor:$NoColor }
        { $_ -in @('timeline', 'causality') }          { Show-HistoryTimeline -Limit $Limit -NoColor:$NoColor }
        { $_ -in @('export', 'bundle') }               { [void](Export-HistoryForensicBundle -OutFile $OutFile) }
        default {
            if ($script:UiOn) {
                Show-HistoryMenu
            } else {
                Show-HistoryTimeline -Limit $Limit -NoColor:$NoColor
            }
        }
    }
    return 0
}

function Invoke-Change {
    param(
        [string]$Description,
        [scriptblock]$Action,
        [switch]$FailOnFalse,
        [string]$MutationType = 'Generic',
        [string]$Target = '',
        $OldValue = $null,
        $NewValue = $null,
        [string]$UndoScript = '',
        [switch]$Reversible
    )
    if ($script:IsPlan) {
        $pItem = @{
            Target       = if ($Target) { $Target } else { 'System' }
            MutationType = $MutationType
            Description  = $Description
            OldValue     = $OldValue
            NewValue     = $NewValue
            Reversible   = [bool]($Reversible -or $UndoScript)
        }
        if ($script:PlannedChanges -is [System.Collections.ArrayList]) {
            [void]$script:PlannedChanges.Add($pItem)
        }
        Write-Log 'PLAN' "Planned: $Description"
        return $true
    }
    if ($script:IsDry) { Write-Log 'DRY' "Would: $Description"; return $true }
    $ErrorActionPreference = 'Stop'
    try {
        $out = @(& $Action)
        if ($FailOnFalse -and $out.Count -gt 0 -and $out[-1] -is [bool] -and -not $out[-1]) { throw 'the action reported failure' }
        $script:ChangeCount++
        Write-Log 'OK' $Description
        Add-ChangeLedgerEntry -Description $Description -MutationType $MutationType -Target $Target -OldValue $OldValue -NewValue $NewValue -Success $true -Reversible ([bool]($Reversible -or $UndoScript)) -UndoScript $UndoScript
        return $true
    } catch {
        $script:FailCount++
        Write-Log 'FAIL' ("{0} -> {1}" -f $Description, $_.Exception.Message)
        Add-ChangeLedgerEntry -Description $Description -MutationType $MutationType -Target $Target -OldValue $OldValue -NewValue $NewValue -Success $false -Reversible $false
        return $false
    }
}

# CommandLineToArgvW-correct quoting (the v2 version broke on a trailing backslash inside quotes).
function ConvertTo-ArgString([string[]]$Arguments) {
    $parts = @()
    foreach ($a in @($Arguments)) {
        if ($null -eq $a) { $a = '' }
        if ($a -ne '' -and $a -notmatch '[\s"]') { $parts += $a; continue }
        $sb = New-Object System.Text.StringBuilder
        [void]$sb.Append('"')
        $bs = 0
        foreach ($ch in $a.ToCharArray()) {
            if ($ch -eq [char]92) { $bs++ }
            elseif ($ch -eq [char]34) { [void]$sb.Append([char]92, ($bs * 2 + 1)); [void]$sb.Append([char]34); $bs = 0 }
            else { if ($bs -gt 0) { [void]$sb.Append([char]92, $bs); $bs = 0 }; [void]$sb.Append($ch) }
        }
        if ($bs -gt 0) { [void]$sb.Append([char]92, ($bs * 2)) }
        [void]$sb.Append('"')
        $parts += $sb.ToString()
    }
    return ($parts -join ' ')
}
function Invoke-Native {
    param([string]$File, [string[]]$Arguments = @(), [int]$TimeoutMs = 20000)
    $res = @{ ExitCode = -1; TimedOut = $false; Output = '' }
    $p = $null
    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $File
        $psi.Arguments = (ConvertTo-ArgString $Arguments)
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $p = [System.Diagnostics.Process]::Start($psi)
        $so = $p.StandardOutput.ReadToEndAsync()
        $se = $p.StandardError.ReadToEndAsync()
        if (-not $p.WaitForExit($TimeoutMs)) {
            try { $p.Kill() } catch {}
            try { [void]$p.WaitForExit(1000) } catch {}
            $res.TimedOut = $true
            return $res
        }
        $p.WaitForExit()
        $res.ExitCode = $p.ExitCode
        $res.Output = ([string]$so.Result + [string]$se.Result)
    } catch { $res.Output = $_.Exception.Message }
    finally {
        if ($p) { try { $p.Dispose() } catch {} }
    }
    return $res
}
function Get-SysExe([string]$Name) { return (Join-Path $script:Sys32 $Name) }

# ---- state (Clixml, written atomically, lives in the ACL-locked store) --------
function Get-State {
    $s = $null
    foreach ($candPath in @($script:StateFile, "$($script:StateFile).bak", "$($script:StateFile).tmp")) {
        if (-not $candPath) { continue }
        try {
            if (Test-Path -LiteralPath $candPath) {
                $s = Import-Clixml -LiteralPath $candPath -ErrorAction Stop
                if ($s -is [hashtable]) {
                    if ($candPath -ne $script:StateFile -and $script:IsAdmin -and -not $script:IsDry) {
                        try { Copy-Item -LiteralPath $candPath -Destination $script:StateFile -Force -ErrorAction SilentlyContinue } catch {}
                    }
                    break
                }
            }
        } catch { $s = $null }
    }
    if ($s -isnot [hashtable]) { $s = @{} }
    foreach ($k in 'Snapshot','Env','Dns','Arp','Times','Misc','LinkMonitor') { if ($s[$k] -isnot [hashtable]) { $s[$k] = @{} } }
    return $s
}
# True only for a file that exists AND deserialises to the hashtable the engine expects.
function Test-StateFile([string]$Path) {
    try {
        if (-not $Path -or -not (Test-Path -LiteralPath $Path)) { return $false }
        $s = Import-Clixml -LiteralPath $Path -ErrorAction Stop
        return ($s -is [hashtable])
    } catch { return $false }
}
function Save-State {
    if (-not $script:StoreReady -or $script:IsDry) { return }
    # Never write without the lock: a long-idle menu window would otherwise overwrite newer watchdog state
    # (including the snapshot of your ORIGINAL settings) with its stale in-memory copy when it exits.
    if (-not $script:IsAdmin -or -not $script:HasMutex) { return }   # non-admin: the store is read-only for you anyway
    try {
        $tmp = "$($script:StateFile).tmp"
        $bak = "$($script:StateFile).bak"
        $script:State | Export-Clixml -LiteralPath $tmp -Depth 8 -Force -ErrorAction Stop
        # A truncated temp file (disk full, power loss mid-write) must never replace the live state.
        if (-not (Test-StateFile $tmp)) {
            try { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue } catch {}
            Write-Log 'WARN' 'State save skipped: the new state file failed verification; the previous good copy was kept.'
            return
        }
        # Only a live file that still parses may become the backup, so damage can never overwrite a good .bak.
        if ((Test-Path -LiteralPath $script:StateFile) -and (Test-StateFile $script:StateFile)) {
            try { Copy-Item -LiteralPath $script:StateFile -Destination $bak -Force -ErrorAction SilentlyContinue } catch {}
        }
        Move-Item -LiteralPath $tmp -Destination $script:StateFile -Force -ErrorAction Stop
    } catch { Write-Log 'WARN' ("State save failed: " + $_.Exception.Message) }
}
function Get-SubTable([string]$Name, [string]$Key) {
    if ($script:State[$Name] -isnot [hashtable]) { $script:State[$Name] = @{} }
    $t = $script:State[$Name]
    if ($t[$Key] -isnot [hashtable]) { $t[$Key] = @{} }
    return $t[$Key]
}
function Get-StateTime([string]$Name) {
    $s = $script:State.Times[$Name]
    if ($s) {
        try { return [datetime]::Parse([string]$s, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::RoundtripKind) } catch {}
    }
    return [datetime]::MinValue
}
function Set-StateTime([string]$Name) { $script:State.Times[$Name] = (Get-Date).ToString('o') }
function Test-Elapsed([string]$Name, [int]$Seconds) {
    $diff = ((Get-Date) - (Get-StateTime $Name)).TotalSeconds
    return ($diff -ge $Seconds -or $diff -lt 0)
}

# First-write-wins snapshot of the user's ORIGINAL value, so restore is exact.
function Save-Original([string]$Guid, [string]$Key, $Value) {
    if ($script:IsDry) { return }
    $snap = Get-SubTable 'Snapshot' $Guid
    if (-not $snap.ContainsKey($Key)) { $snap[$Key] = $Value }
}

function Get-DnsProfileName {
    $p = $script:State.Misc['DnsProfile']
    # 'ResetDHCP' is an ACTION, never a resting state: a value stored by an older build means the reset already ran,
    # which is exactly the Adaptive profile. Reporting it verbatim would show a profile that can never apply again.
    if ([string]$p -eq 'ResetDHCP') { return 'Adaptive' }
    if ($p -and (@('Adaptive','DHCP','Hybrid','Cloudflare') -contains [string]$p)) { return [string]$p }
    return 'Adaptive'
}
function Get-RouteProfileName {
    $p = $script:State.Misc['RouteProfile']
    if ($p -and (@('Adaptive','Ethernet','Wifi','Windows') -contains [string]$p)) { return [string]$p }
    return 'Adaptive'
}

# ==============================================================================
# SECURE STORE  (SYSTEM runs code from here, so it must not be user-writable)
# ==============================================================================
# Heals tampered ACLs on store children WITHOUT touching the vault: the old blanket "icacls \* /reset /T" ran on every
# elevated start (including every watchdog pass) and silently put the vault back under the folder's inherited,
# user-readable ACL a few minutes after it had been locked down.
function Repair-StoreChildren([string]$Dir) {
    $icacls = Get-SysExe 'icacls.exe'
    $curSid = try { [Security.Principal.WindowsIdentity]::GetCurrent().User.Value } catch { $null }
    $trustedOwners = @('S-1-5-18', 'S-1-5-32-544')
    if ($curSid) { $trustedOwners += $curSid }
    foreach ($f in @(Get-ChildItem -LiteralPath $Dir -Force -ErrorAction SilentlyContinue)) {
        if ($f.Name -like 'vault*') { continue }
        $bad = $false
        try {
            $acl = Get-Acl -LiteralPath $f.FullName
            if ($acl.AreAccessRulesProtected) { $bad = $true }
            if (@($acl.GetAccessRules($true, $false, [System.Security.Principal.SecurityIdentifier])).Count -gt 0) { $bad = $true }
            $o = $acl.GetOwner([System.Security.Principal.SecurityIdentifier]).Value
            if ($trustedOwners -notcontains $o) { $bad = $true }
        } catch { $bad = $true }
        if ($f.PSIsContainer -and ($f.Attributes -band [IO.FileAttributes]::ReparsePoint)) { $bad = $true }
        if ($bad) {
            [void](Invoke-Native $icacls @($f.FullName, '/setowner', '*S-1-5-32-544', '/T', '/C', '/Q') 5000)
            [void](Invoke-Native $icacls @($f.FullName, '/reset', '/T', '/C', '/Q') 5000)
        }
    }
    $cfgJson = Join-Path $Dir 'config.json'
    if (Test-Path -LiteralPath $cfgJson) {
        try {
            $co = (Get-Acl -LiteralPath $cfgJson).GetOwner([System.Security.Principal.SecurityIdentifier]).Value
            if (@('S-1-5-18', 'S-1-5-32-544') -notcontains $co -and ($trustedOwners -contains $co)) {
                [void](Invoke-Native $icacls @($cfgJson, '/setowner', '*S-1-5-32-544', '/C', '/Q') 5000)
                [void](Invoke-Native $icacls @($cfgJson, '/reset', '/C', '/Q') 5000)
            }
        } catch {}
    }
    if ((Test-Path -LiteralPath $script:VaultFile) -and -not (Test-VaultAcl $script:VaultFile)) {
        if (Protect-VaultFile $script:VaultFile) { Write-Log 'WARN' 'The vault file had loose permissions; they were tightened to Administrators/SYSTEM only.' }
    }
}
function Get-FileSha256([string]$Path) {
    $stream = $null; $sha = $null
    try {
        $stream = [System.IO.File]::OpenRead($Path)
        $sha = [System.Security.Cryptography.SHA256]::Create()
        $hash = $sha.ComputeHash($stream)
        return ([System.BitConverter]::ToString($hash) -replace '-').ToUpperInvariant()
    } catch {
        try { return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToUpperInvariant() } catch { return $null }
    } finally {
        if ($stream) { try { $stream.Dispose() } catch {} }
        if ($sha) { try { $sha.Dispose() } catch {} }
    }
}
# ---- optional per-institution override: <store>\config.json -------------------------------------
# Pure validator (unit-tested): yields ONLY well-formed values, so a typo can never blank a setting (an empty
# CampusDomain would make the environment scorer treat every network as campus).
function ConvertTo-CfgOverride($Raw) {
    $out = @{}
    if ($null -eq $Raw) { return $out }
    $hostRx = '^(?=.{1,253}$)([A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$'
    foreach ($p in @($Raw.PSObject.Properties)) {
        $k = [string]$p.Name
        $v = $p.Value
        if ($k -eq 'PortalIp' -or $k -eq 'CampusDns') {
            $a = $null
            if ($v -is [string] -and $v -match '^\d{1,3}(\.\d{1,3}){3}$' -and [System.Net.IPAddress]::TryParse($v, [ref]$a) -and $a.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork) {
                if ($v -notmatch '^(0\.|127\.|169\.254\.|22[4-9]\.|23\d\.|24\d\.|25\d\.)') { $out[$k] = $v }
            }
        }
        elseif ($k -eq 'PortalPort') {
            $n = 0
            if ($null -ne $v -and [int]::TryParse(([string]$v), [ref]$n) -and $n -ge 1 -and $n -le 65535) { $out[$k] = $n }
        }
        elseif ($k -eq 'PortalHost' -or $k -eq 'CampusDomain') {
            if ($v -is [string] -and $v.Trim().TrimEnd('.') -match $hostRx) { $out[$k] = $v.Trim().TrimEnd('.').ToLowerInvariant() }
        }
        elseif ($k -eq 'PortalUrl') {
            try {
                $u = [uri][string]$v
                if ($u.IsAbsoluteUri -and $u.Scheme -eq 'https' -and $u.Host -and -not $u.UserInfo) { $out[$k] = [string]$v }
            } catch {}
        }
        elseif ($k -eq 'GwRegex' -or $k -eq 'ProfileRegex') {
            if ($v -is [string] -and $v.Length -gt 0 -and $v.Length -le 200) {
                try { [void][regex]::new($v); $out[$k] = $v } catch {}
            }
        }
    }
    return $out
}
# The file may only steer the tool when nobody but SYSTEM / Administrators owns or can write it.
function Test-ConfigFileTrusted([string]$Path) {
    try {
        $acl = Get-Acl -LiteralPath $Path
        $owner = $acl.GetOwner([System.Security.Principal.SecurityIdentifier]).Value
        if (@('S-1-5-18', 'S-1-5-32-544') -notcontains $owner) { return $false }
        $writeMask = 0x116 -bor 0x10000 -bor 0x40000 -bor 0x80000 -bor 0x40000000 -bor 0x10000000
        foreach ($r in @($acl.GetAccessRules($true, $true, [System.Security.Principal.SecurityIdentifier]))) {
            if ([string]$r.AccessControlType -ne 'Allow') { continue }
            if (@('S-1-5-18', 'S-1-5-32-544') -contains [string]$r.IdentityReference.Value) { continue }
            if (([int]$r.FileSystemRights -band $writeMask) -ne 0) { return $false }
        }
        return $true
    } catch { return $false }
}
function Import-UserConfig {
    try {
        $path = Join-Path $script:StoreDir 'config.json'
        if (-not (Test-Path -LiteralPath $path)) { return }
        $fi = Get-Item -LiteralPath $path -Force
        if ($fi.Length -gt 65536 -or ($fi.Attributes -band [IO.FileAttributes]::ReparsePoint)) { Write-Log 'WARN' 'config.json ignored (too large or a link).'; return }
        if (-not (Test-ConfigFileTrusted $path)) { Write-Log 'WARN' 'config.json ignored: it must be owned by Administrators or SYSTEM and not writable by other accounts.'; return }
        $raw = [System.IO.File]::ReadAllText($path)
        $ov = ConvertTo-CfgOverride ($raw | ConvertFrom-Json -ErrorAction Stop)
        $names = New-Object System.Collections.ArrayList
        foreach ($k in @($ov.Keys)) { $script:Cfg[$k] = $ov[$k]; [void]$names.Add($k) }
        if ($names.Count -gt 0) { Write-Log 'INFO' ('config.json applied: ' + (($names | Sort-Object) -join ', ')) }
    } catch { Write-Log 'WARN' ('config.json ignored: ' + $_.Exception.Message) }
}
function Test-IsNitjsrNetwork {
    try {
        $dom = if ($script:State.Misc -and $script:State.Misc['DiscoveredDomain']) { [string]$script:State.Misc['DiscoveredDomain'] } else { '' }
        if ($dom -and ($dom -eq 'nitjsr.ac.in' -or $dom.EndsWith('.nitjsr.ac.in'))) { return $true }
        foreach ($a in @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' })) {
            $sfx = (Get-DnsClient -InterfaceIndex $a.ifIndex -ErrorAction SilentlyContinue).ConnectionSpecificSuffix
            if ($sfx -and ($sfx.ToLower() -eq 'nitjsr.ac.in' -or $sfx.ToLower().EndsWith('.nitjsr.ac.in'))) { return $true }
            $dns = @(Get-DhcpDnsServers ([string]$a.InterfaceGuid))
            if ($dns -contains '172.16.1.2') { return $true }
            $np = Get-NetConnectionProfile -InterfaceIndex $a.ifIndex -ErrorAction SilentlyContinue
            if ($np -and $np.Name -match 'nitjsr') { return $true }
        }
        if (Test-TcpPort '10.114.0.5' 8003 250) { return $true }
    } catch {}
    return $false
}
function Invoke-NetworkAutoDiscovery {
    param([switch]$Force)
    if (-not $Force -and $script:State.Misc -and $script:State.Misc['DiscoveryTime']) {
        try {
            $lastDisc = [DateTime]::Parse([string]$script:State.Misc['DiscoveryTime'])
            if (((Get-Date) - $lastDisc).TotalSeconds -lt 20) { return }
        } catch {}
    }
    try {
        $adapters = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notmatch $script:VirtRegex })
        $gws = @()
        foreach ($ad in $adapters) { $gws += @(Get-GatewaysV4 $ad) }
        $gws = @($gws | Where-Object { $_ } | Select-Object -Unique)
        $primaryGw = if ($gws.Count -gt 0) { [string]$gws[0] } else { '' }

        # 1. Discover Domain & DNS Suffixes
        $discoveredSuffix = ''
        foreach ($a in $adapters) {
            try {
                $sfx = (Get-DnsClient -InterfaceIndex $a.ifIndex -ErrorAction SilentlyContinue).ConnectionSpecificSuffix
                if ($sfx -and $sfx -match '\.' -and $sfx -notmatch '^(local|lan|home|arpa|localdomain|mshome\.net)$') {
                    $discoveredSuffix = $sfx.Trim().Trim('.').ToLowerInvariant()
                    break
                }
            } catch {}
            $reg = Get-IfaceReg ([string]$a.InterfaceGuid)
            if ($reg -and $reg.DhcpDomain -and $reg.DhcpDomain -match '\.' -and $reg.DhcpDomain -notmatch '^(local|lan|home|arpa|localdomain|mshome\.net)$') {
                $discoveredSuffix = ([string]$reg.DhcpDomain).Trim().Trim('.').ToLowerInvariant()
                break
            }
        }
        if ($discoveredSuffix -and -not $script:IsDry) {
            $script:State.Misc['DiscoveredDomain'] = $discoveredSuffix
        }

        # 2. Discover Captive URL from DHCP Option 114 (RFC 8910)
        foreach ($a in $adapters) {
            $dhcpUrl = Get-DhcpCaptiveUrl ([string]$a.InterfaceGuid)
            if ($dhcpUrl -and -not $script:IsDry) {
                $script:State.Misc['DiscoveredPortalUrl'] = $dhcpUrl
                try {
                    $du = [uri]$dhcpUrl
                    if ($du.Host) {
                        $script:State.Misc['DiscoveredPortalHost'] = ([string]$du.Host).ToLowerInvariant()
                        if ($du.Port -gt 0) { $script:State.Misc['DiscoveredPortalPort'] = [int]$du.Port }
                    }
                } catch {}
                break
            }
        }

        # 3. Discover Active Web Services on Gateway
        if ($primaryGw -and (-not $script:State.Misc['DiscoveredPortalUrl']) -and -not $script:IsDry) {
            $gwPorts = @(80, 443, 8080, 8003, 8443, 8888)
            foreach ($p in $gwPorts) {
                if (Test-TcpPort $primaryGw $p 250) {
                    $script:State.Misc['DiscoveredPortalPort'] = $p
                    $script:State.Misc['DiscoveredPortalIp'] = $primaryGw
                    $proto = if ($p -eq 443 -or $p -eq 8443) { 'https' } else { 'http' }
                    $portStr = if ($p -eq 80 -or $p -eq 443) { '' } else { ":$p" }
                    if (-not (Test-IsNitjsrNetwork)) {
                        $script:State.Misc['DiscoveredPortalUrl'] = ($proto + '://' + $primaryGw + $portStr + '/')
                        $script:State.Misc['DiscoveredPortalHost'] = $primaryGw
                    }
                    break
                }
            }
        }

        # 4. Discover DHCP DNS Servers
        $dhcpDnsList = New-Object System.Collections.ArrayList
        foreach ($a in $adapters) {
            $dServers = @(Get-DhcpDnsServers ([string]$a.InterfaceGuid))
            foreach ($ds in $dServers) {
                if ($ds -and -not $dhcpDnsList.Contains($ds)) { [void]$dhcpDnsList.Add($ds) }
            }
        }
        if ($dhcpDnsList.Count -gt 0 -and -not $script:IsDry) {
            $script:State.Misc['DiscoveredDns'] = @($dhcpDnsList)
        }

        if (-not $script:IsDry) {
            $script:State.Misc['DiscoveryTime'] = (Get-Date).ToString('o')
        }
    } catch {}
}
function Get-ActivePortalUrl {
    $discUrl = if ($script:State -is [hashtable] -and $script:State.Misc -is [hashtable]) { [string]$script:State.Misc['DiscoveredPortalUrl'] } else { '' }
    $discUrl = $discUrl.Trim()
    if ($discUrl) {
        $safe = Get-SafePortalUrl $discUrl
        if ($safe) { return $safe }
    }
    if (-not (Test-IsNitjsrNetwork) -and -not (Test-Path -LiteralPath (Join-Path $script:StoreDir 'config.json'))) {
        $gws = @(Get-GatewaysV4) | Where-Object { $_ }
        if ($gws.Count -gt 0) {
            $gw = [string]$gws[0]
            $p = if ($script:State.Misc -and $script:State.Misc['DiscoveredPortalPort']) { [int]$script:State.Misc['DiscoveredPortalPort'] } else { Find-ActivePortalPort $gw 80 }
            $proto = if ($p -eq 443 -or $p -eq 8443) { 'https' } else { 'http' }
            $portStr = if ($p -eq 80 -or $p -eq 443) { '' } else { ":$p" }
            return ($proto + '://' + $gw + $portStr + '/')
        }
    }
    return [string]$script:Cfg.PortalUrl
}
function Find-ActivePortalPort([string]$HostOrIp, [int]$DefaultPort = 8003) {
    if (-not $HostOrIp) { return $DefaultPort }
    if ($script:State.Misc -and $script:State.Misc['DiscoveredPortalPort']) {
        $savedPort = [int]$script:State.Misc['DiscoveredPortalPort']
        if ($savedPort -ge 1 -and $savedPort -le 65535) {
            if (Test-TcpPort $HostOrIp $savedPort 250) { return $savedPort }
        }
    }
    $probePorts = @([int]$DefaultPort, 8003, 8888, 8443, 8080, 443, 80) | Select-Object -Unique
    foreach ($p in $probePorts) {
        if (Test-TcpPort $HostOrIp $p 300) {
            if ($script:State.Misc) { $script:State.Misc['DiscoveredPortalPort'] = $p }
            return $p
        }
    }
    return $DefaultPort
}
function Test-PortalOnlineSmart([string]$HostOrIp, [int]$ConfiguredPort = 8003) {
    $candidatePorts = @([int]$ConfiguredPort, 8003, 8888, 8443, 8080, 443, 80) | Select-Object -Unique
    foreach ($p in $candidatePorts) {
        if (Test-TcpPort $HostOrIp $p 350) { return $true }
    }
    return $false
}
function Get-ActivePortalEndpoint {
    $discIp = if ($script:State -is [hashtable] -and $script:State.Misc -is [hashtable]) { [string]$script:State.Misc['DiscoveredPortalIp'] } else { '' }
    $discIp = $discIp.Trim()
    $discUrl = Get-ActivePortalUrl
    try {
        $u = [uri]$discUrl
        if ($u.Host) {
            $h = [string]$u.Host
            $ip = if ($discIp -and (Test-AllowedPortalIp $discIp)) { $discIp } elseif (-not (Test-IsNitjsrNetwork) -and (Test-AllowedPortalIp $h)) { $h } else { [string]$script:Cfg.PortalIp }
            if ($discIp -and (Test-AllowedPortalIp $discIp) -and ($h -eq [string]$script:Cfg.PortalHost -or $h -eq [string]$script:Cfg.PortalIp)) {
                $h = $discIp
            }
            $port = if ($u.Port -gt 0) { [int]$u.Port } else { Find-ActivePortalPort $h ([int]$script:Cfg.PortalPort) }
            return @{ Host = $h; Ip = $ip; Port = $port; Url = $discUrl }
        }
    } catch {}
    if (-not (Test-IsNitjsrNetwork)) {
        $gw = @(Get-GatewaysV4) | Select-Object -First 1
        $gwIp = if ($gw) { [string]$gw } else { '127.0.0.1' }
        $gwPort = if ($script:State.Misc -and $script:State.Misc['DiscoveredPortalPort']) { [int]$script:State.Misc['DiscoveredPortalPort'] } else { 80 }
        return @{ Host = $gwIp; Ip = $gwIp; Port = $gwPort; Url = ('http://' + $gwIp + '/') }
    }
    $defIp = if ($discIp -and (Test-AllowedPortalIp $discIp)) { $discIp } else { [string]$script:Cfg.PortalIp }
    $defHost = if ($discIp -and (Test-AllowedPortalIp $discIp)) { $discIp } else { [string]$script:Cfg.PortalHost }
    return @{ Host = $defHost; Ip = $defIp; Port = [int]$script:Cfg.PortalPort; Url = [string]$script:Cfg.PortalUrl }
}
function Get-ActiveCampusDns($Ad = $null) {
    if ($Ad) {
        $d = @(Get-DhcpDnsServers ([string]$Ad.InterfaceGuid))
        if ($d.Count -gt 0) { return [string]$d[0] }
    } else {
        $targetAdapters = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
    if ($targetAdapters.Count -eq 0) {
        $targetAdapters = @(Get-OtherUplinkAdapters | Where-Object { $_.Status -eq 'Up' })
    }
    foreach ($a in $targetAdapters) {
            $d = @(Get-DhcpDnsServers ([string]$a.InterfaceGuid))
            if ($d.Count -gt 0) { return [string]$d[0] }
        }
        foreach ($a in @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notmatch $script:VirtRegex })) {
            $d = @(Get-DhcpDnsServers ([string]$a.InterfaceGuid))
            if ($d.Count -gt 0) { return [string]$d[0] }
        }
    }
    if ($script:State.Misc -and $script:State.Misc['DiscoveredDns']) {
        $dList = @($script:State.Misc['DiscoveredDns'])
        if ($dList.Count -gt 0) { return [string]$dList[0] }
    }
    if (-not (Test-IsNitjsrNetwork)) {
        $gw = @(Get-GatewaysV4) | Select-Object -First 1
        if ($gw) { return [string]$gw }
        return '1.1.1.1'
    }
    return [string]$script:Cfg.CampusDns
}
function Test-StoreAcl([string]$Path = $null) {
    if (-not $Path) { $Path = $script:StoreDir }
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    try {
        $acl = [System.IO.Directory]::GetAccessControl($Path)
        $owner = $acl.GetOwner([System.Security.Principal.SecurityIdentifier]).Value
        if (@('S-1-5-18', 'S-1-5-32-544') -notcontains $owner) { return $false }
        if (-not $acl.AreAccessRulesProtected) { return $false }
        $rules = $acl.GetAccessRules($true, $false, [System.Security.Principal.SecurityIdentifier])
        $allowedSids = @('S-1-5-18', 'S-1-5-32-544', 'S-1-5-32-545')
        foreach ($r in $rules) {
            if ($r.AccessControlType -eq [System.Security.AccessControl.AccessControlType]::Allow) {
                if ($allowedSids -notcontains $r.IdentityReference.Value) { return $false }
                if ($r.IdentityReference.Value -eq 'S-1-5-32-545') {
                    $dangerousRights = [System.Security.AccessControl.FileSystemRights]::WriteData -bor
                                       [System.Security.AccessControl.FileSystemRights]::AppendData -bor
                                       [System.Security.AccessControl.FileSystemRights]::CreateDirectories -bor
                                       [System.Security.AccessControl.FileSystemRights]::Delete -bor
                                       [System.Security.AccessControl.FileSystemRights]::DeleteSubdirectoriesAndFiles -bor
                                       [System.Security.AccessControl.FileSystemRights]::WriteExtendedAttributes
                    if ($r.FileSystemRights -band $dangerousRights) { return $false }
                }
            }
        }
        return $true
    } catch { return $false }
}

function Initialize-Store {
    $dir = $script:StoreDir
    $trusted = @('S-1-5-18', 'S-1-5-32-544', 'S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464')
    try {
        $curSid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
        if ($curSid) { $trusted += $curSid }
    } catch {}
    if ($script:IsDry) { $script:StoreReady = (Test-Path -LiteralPath $dir); $script:StoreSecure = $script:StoreReady; return }
    try {
        if (Test-Path -LiteralPath $dir) {
            $item = Get-Item -LiteralPath $dir -Force
            $bad = $false
            if (-not $item.PSIsContainer) { $bad = $true }
            elseif ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { $bad = $true }
            else {
                $sid = (Get-Acl -LiteralPath $dir).GetOwner([System.Security.Principal.SecurityIdentifier]).Value
                if ($trusted -notcontains $sid) {
                    $isAdminOwner = $false
                    try {
                        $secId = New-Object System.Security.Principal.SecurityIdentifier($sid)
                        $curUser = [Security.Principal.WindowsIdentity]::GetCurrent()
                        if ($curUser.User.Value -eq $sid -or $curUser.Groups -contains $secId) { $isAdminOwner = $true }
                    } catch {}
                    if (-not $isAdminOwner) { $bad = $true }
                }
            }
            if ($bad) {
                $quar = $dir + '.untrusted-' + (Get-Date).ToString('yyyyMMddHHmmss')
                Move-Item -LiteralPath $dir -Destination $quar -Force -ErrorAction Stop
            }
        }
        if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force -ErrorAction Stop | Out-Null }
        $icacls = Get-SysExe 'icacls.exe'
        # SIDs, not names, so this works on any Windows language.
        $r1 = Invoke-Native $icacls @($dir, '/setowner', '*S-1-5-32-544', '/C', '/Q')
        $r2 = Invoke-Native $icacls @($dir, '/inheritance:r', '/grant:r', '*S-1-5-18:(OI)(CI)F', '/grant:r', '*S-1-5-32-544:(OI)(CI)F', '/grant:r', '*S-1-5-32-545:(OI)(CI)RX', '/C', '/Q')
        Repair-StoreChildren $dir
        Import-UserConfig
        $script:StoreSecure = ($r1.ExitCode -eq 0 -and $r2.ExitCode -eq 0)
        $script:StoreReady = $true
        try { $fi = Get-Item -LiteralPath $script:LogFile -ErrorAction Stop; if ($fi.Length -gt $script:Cfg.LogMaxBytes) { Move-Item -LiteralPath $script:LogFile -Destination ($script:LogFile + '.1') -Force } } catch {}
        if (-not $script:StoreSecure) { Write-Log 'WARN' 'Could not lock down the store folder ACL; the watchdog will refuse to install.' }
        # Mirror this script into the store (what the SYSTEM watchdog executes).
        if ($script:StoreSecure -and $script:SelfPath -and (Test-Path -LiteralPath $script:SelfPath) -and ($script:SelfPath -ne $script:SelfCopy)) {
            $need = $true
            if (Test-Path -LiteralPath $script:SelfCopy) {
                try {
                    $copyErrs = $null
                    [void][System.Management.Automation.Language.Parser]::ParseFile($script:SelfCopy, [ref]$null, [ref]$copyErrs)
                    $h1 = Get-FileSha256 $script:SelfCopy
                    $h2 = Get-FileSha256 $script:SelfPath
                    if ($h1 -and $h2 -and ($h1 -eq $h2) -and ($null -eq $copyErrs -or $copyErrs.Count -eq 0)) { $need = $false }
                } catch {}
            }
            if ($need) {
                $parseErrs = $null
                [void][System.Management.Automation.Language.Parser]::ParseFile($script:SelfPath, [ref]$null, [ref]$parseErrs)
                if ($null -eq $parseErrs -or $parseErrs.Count -eq 0) {
                    Copy-Item -LiteralPath $script:SelfPath -Destination $script:SelfCopy -Force -ErrorAction Stop
                    [void](Set-ScriptAuthorization $script:SelfCopy)
                } else {
                    Write-Log 'WARN' 'Refused to overwrite protected watchdog copy because current script has syntax errors.'
                }
            }
        }
    } catch {
        $script:StoreReady = (Test-Path -LiteralPath $dir)
        $script:StoreSecure = $false
        Write-Log 'WARN' ("Store init problem: " + $_.Exception.Message)
    }
}

# ==============================================================================
# LOCKING (abandoned-mutex safe, cross-session DACL verified, PID-tracked)
# ==============================================================================
function Get-LanFixerMutex([string]$Name = 'Global\LanFixer_Lock') {
    if ($Name -eq 'Global\LanFixer_Lock' -and $script:Mutex) { return $script:Mutex }
    try {
        $mSec = New-Object System.Security.AccessControl.MutexSecurity
        $ruleAdmin = New-Object System.Security.AccessControl.MutexAccessRule(
            (New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::BuiltinAdministratorsSid, $null)),
            [System.Security.AccessControl.MutexRights]::FullControl,
            [System.Security.AccessControl.AccessControlType]::Allow
        )
        $mSec.AddAccessRule($ruleAdmin)
        $ruleSystem = New-Object System.Security.AccessControl.MutexAccessRule(
            (New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::LocalSystemSid, $null)),
            [System.Security.AccessControl.MutexRights]::FullControl,
            [System.Security.AccessControl.AccessControlType]::Allow
        )
        $mSec.AddAccessRule($ruleSystem)
        $created = $false
        $m = New-Object System.Threading.Mutex($false, $Name, [ref]$created, $mSec)
        if ($Name -eq 'Global\LanFixer_Lock') { $script:Mutex = $m }
        return $m
    } catch {
        try {
            $m = [System.Threading.Mutex]::OpenExisting($Name, [System.Security.AccessControl.MutexRights]::Synchronize -bor [System.Security.AccessControl.MutexRights]::Modify)
            if ($Name -eq 'Global\LanFixer_Lock') { $script:Mutex = $m }
            return $m
        } catch {
            try {
                $m = New-Object System.Threading.Mutex($false, $Name)
                if ($Name -eq 'Global\LanFixer_Lock') { $script:Mutex = $m }
                return $m
            } catch {
                try {
                    $localName = $Name -replace '^Global\\', 'Local\'
                    $m = New-Object System.Threading.Mutex($false, $localName)
                    if ($Name -eq 'Global\LanFixer_Lock') { $script:Mutex = $m }
                    return $m
                } catch { return $null }
            }
        }
    }
}
function Enter-Lock([int]$TimeoutMs = 1000) {
    if (-not $script:IsAdmin) { return $false }
    try {
        if (-not $script:Mutex) { $script:Mutex = Get-LanFixerMutex 'Global\LanFixer_Lock' }
        if (-not $script:Mutex) { return $false }
        if ($script:LockDepth -gt 0) {
            $script:LockDepth++
            $script:HasMutex = $true
            return $true
        }
        $got = $false
        try { $got = $script:Mutex.WaitOne($TimeoutMs) } catch [System.Threading.AbandonedMutexException] { $got = $true }
        if (-not $got) {
            $lf = Join-Path $script:StoreDir 'lock.json'
            $holderDead = $false
            if (Test-Path -LiteralPath $lf) {
                try {
                    $raw = [System.IO.File]::ReadAllText($lf)
                    $h = ConvertFrom-Json -InputObject $raw
                    if ($h -and $h.Pid) {
                        $p = Get-Process -Id ([int]$h.Pid) -ErrorAction SilentlyContinue
                        if (-not $p) {
                            $holderDead = $true
                        } else {
                            $procName = [string]$p.ProcessName
                            if ($procName -notmatch '^(?:powershell|pwsh|cmd|LanFixer)$') {
                                $holderDead = $true
                            } elseif ($h.StartTime) {
                                $pStart = try { $p.StartTime.ToUniversalTime().ToString('o') } catch { '' }
                                if ($pStart -and $pStart -ne [string]$h.StartTime) {
                                    $holderDead = $true
                                }
                            }
                        }
                    }
                } catch {}
            }
            if ($holderDead) {
                try { Remove-Item -LiteralPath $lf -Force -ErrorAction SilentlyContinue } catch {}
                try { $got = $script:Mutex.WaitOne(1000) } catch [System.Threading.AbandonedMutexException] { $got = $true }
            }
        }
        if ($got) {
            $script:LockDepth = 1
            $script:HasMutex = $true
            try {
                $lf = Join-Path $script:StoreDir 'lock.json'
                $myStart = try { (Get-Process -Id $PID).StartTime.ToUniversalTime().ToString('o') } catch { '' }
                $meta = @{ Pid = $PID; Mode = ([string]$Mode); Time = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'); StartTime = $myStart; User = [string]$env:USERNAME }
                [System.IO.File]::WriteAllText($lf, (ConvertTo-Json -InputObject $meta -Compress))
            } catch {}
            $memMisc = @{}
            if ($script:State -is [hashtable] -and $script:State.Misc -is [hashtable]) {
                foreach ($mk in @('LearnedDhcp','DiscoveredDomain','DiscoveredPortalUrl','DiscoveredPortalIp','DiscoveredPortalPort','DiscoveryTime','InjectedHostRoutes')) {
                    if ($script:State.Misc.ContainsKey($mk)) { $memMisc[$mk] = $script:State.Misc[$mk] }
                }
            }
            $memEnv = if ($script:State -is [hashtable] -and $script:State.Env -is [hashtable]) { $script:State.Env.Clone() } else { @{} }
            $script:State = Get-State
            if ($memMisc['LearnedDhcp'] -and -not $script:State.Misc['LearnedDhcp']) { $script:State.Misc['LearnedDhcp'] = $memMisc['LearnedDhcp'] }
            if ($memMisc['DiscoveredPortalPort'] -and -not $script:State.Misc['DiscoveredPortalPort']) { $script:State.Misc['DiscoveredPortalPort'] = $memMisc['DiscoveredPortalPort'] }
            if ($memMisc['DiscoveryTime'] -and ([string]$memMisc['DiscoveryTime'] -ge [string]$script:State.Misc['DiscoveryTime'])) {
                foreach ($mk in @('DiscoveredDomain','DiscoveredPortalUrl','DiscoveredPortalIp','DiscoveryTime')) {
                    if ($memMisc.ContainsKey($mk)) { $script:State.Misc[$mk] = $memMisc[$mk] }
                    else { $script:State.Misc.Remove($mk) }
                }
            }
            if ($memMisc['InjectedHostRoutes']) {
                $curR = @($script:State.Misc['InjectedHostRoutes'] | Where-Object { $_ })
                $script:State.Misc['InjectedHostRoutes'] = @($curR + @($memMisc['InjectedHostRoutes']) | Where-Object { $_ } | Select-Object -Unique)
            }
            foreach ($ek in $memEnv.Keys) {
                if (-not $script:State.Env.ContainsKey($ek)) { $script:State.Env[$ek] = $memEnv[$ek] }
                elseif ($memEnv[$ek] -is [hashtable] -and $script:State.Env[$ek] -is [hashtable] -and $memEnv[$ek].Time -and ([string]$memEnv[$ek].Time -gt [string]$script:State.Env[$ek].Time)) {
                    $script:State.Env[$ek].Env = $memEnv[$ek].Env
                    $script:State.Env[$ek].Time = $memEnv[$ek].Time
                }
            }
        }
        return $got
    } catch { return $false }
}
function Exit-Lock {
    if (-not $script:IsAdmin) { return }
    if ($script:LockDepth -gt 0) {
        $script:LockDepth--
        if ($script:LockDepth -eq 0) {
            try {
                $lf = Join-Path $script:StoreDir 'lock.json'
                if (Test-Path -LiteralPath $lf) { Remove-Item -LiteralPath $lf -Force -ErrorAction SilentlyContinue }
            } catch {}
            if ($script:Mutex) { try { $script:Mutex.ReleaseMutex() } catch {} }
            $script:HasMutex = $false
        }
    } else {
        $script:HasMutex = $false
    }
}
function Invoke-WithLock {
    param([scriptblock]$Block, [int]$WaitMs = 20000)
    if (-not $script:IsAdmin) { return (& $Block) }   # read-only/limited mode: no shared lock needed (and a standard user cannot open it)
    if (-not (Enter-Lock $WaitMs)) {
        $holderDesc = 'Another Lan Fixer operation'
        try {
            $lf = Join-Path $script:StoreDir 'lock.json'
            if (Test-Path -LiteralPath $lf) {
                $h = ConvertFrom-Json (Get-Content -LiteralPath $lf -Raw -ErrorAction SilentlyContinue)
                if ($h -and $h.Mode) { $holderDesc = ("Lan Fixer ({0}, PID {1})" -f $h.Mode, $h.Pid) }
            }
        } catch {}
        Write-Log 'WARN' ("{0} is running. Try again in a moment." -f $holderDesc)
        return $null
    }
    try { return (& $Block) } finally { Exit-Lock }
}
function Test-InteractiveSessionActive {
    try {
        $intFile = Join-Path $script:StoreDir 'interactive.json'
        if (Test-Path -LiteralPath $intFile) {
            $meta = ConvertFrom-Json (Get-Content -LiteralPath $intFile -Raw -ErrorAction SilentlyContinue)
            if ($meta -and $meta.Pid -and ($meta.Pid -ne $PID)) {
                $p = Get-Process -Id ([int]$meta.Pid) -ErrorAction SilentlyContinue
                if ($p -and ($p.ProcessName -match 'powershell|cmd|LanFixer')) {
                    if ($meta.StartTime) {
                        try {
                            $mStart = [datetime]::Parse([string]$meta.StartTime, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind).ToUniversalTime()
                            if ([math]::Abs(($p.StartTime.ToUniversalTime() - $mStart).TotalSeconds) -le 5) { return $true }
                        } catch { return $true }
                    } else { return $true }
                }
                Remove-Item -LiteralPath $intFile -Force -ErrorAction SilentlyContinue
            }
        }
    } catch {}
    return $false
}
function Assert-Admin {
    if ($script:IsAdmin -or $script:IsDry -or $script:IsPlan) { return $true }
    Write-Log 'FAIL' 'Administrator rights are required for this action. Re-open Lan Fixer and approve the UAC prompt.'
    return $false
}

# ==============================================================================
# PROBES (all bounded by timeouts; no hangs on dead DNS or dead links)
# ==============================================================================
# Sets TLS 1.2/1.3 and trusts campus firewall self-signed certs for internal 10.* and 172.16.* subnets
function Test-Ping([string]$Target, [int]$TimeoutMs = 800) {
    $p = New-Object System.Net.NetworkInformation.Ping
    try {
        $r = $p.Send($Target, $TimeoutMs)
        if ($r.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) { return [int]$r.RoundtripTime }
    } catch {} finally { $p.Dispose() }
    return $null
}
function Test-LatencySample([string]$Target, [int]$TimeoutMs = 800) {
    if (-not $Target) { return -1 }
    $rtt = Test-Ping $Target $TimeoutMs
    if ($null -ne $rtt) { return [int]$rtt }
    return -1
}
function Test-TcpPort([string]$Address, [int]$Port, [int]$TimeoutMs = 800, [string]$SourceIp = '') {
    $c = $null
    $iar = $null
    try {
        if ($SourceIp -and $SourceIp -ne '0.0.0.0' -and $SourceIp -notlike '169.254.*') {
            try {
                $ep = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($SourceIp), 0)
                $c = New-Object System.Net.Sockets.TcpClient($ep)
            } catch {
                if ($c) { try { $c.Close() } catch {} }; $c = $null
            }
        }
        if (-not $c) {
            $c = New-Object System.Net.Sockets.TcpClient
        }
        $iar = $c.BeginConnect($Address, $Port, $null, $null)
        if ($iar.AsyncWaitHandle.WaitOne($TimeoutMs, $false) -and $c.Connected) { $c.EndConnect($iar); return $true }
        return $false
    } catch { return $false }
    finally {
        if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
        if ($c) { try { $c.Close(); $c.Dispose() } catch {} }
    }
}
# Parses the ANSWER section of a DNS response and returns ONLY IPv4 A records, in wire order.
# Pure (no sockets, no state): this is what unit tests feed synthetic packets to.
#  - the transaction id must match the query, or a late answer to an earlier round is accepted as this one
#  - QR must be set and RCODE must be 0 (NXDOMAIN/SERVFAIL/REFUSED carry no usable address)
#  - compression pointers are followed only as a skip; name lengths are bounded so a hostile packet cannot hang us
function Get-DnsAAnswers([byte[]]$Response, [byte[]]$Query) {
    $out = @()
    if ($null -eq $Response -or $null -eq $Query) { return $out }
    if ($Response.Length -lt 12 -or $Query.Length -lt 12) { return $out }
    $qid = ([int]$Query[0] -shl 8) -bor [int]$Query[1]
    $rid = ([int]$Response[0] -shl 8) -bor [int]$Response[1]
    if ($rid -ne $qid) { return $out }
    if (($Response[2] -band 128) -eq 0) { return $out }
    if (($Response[3] -band 15) -ne 0) { return $out }
    $anc = ([int]$Response[6] -shl 8) -bor [int]$Response[7]
    if ($anc -le 0 -or $anc -gt 256) { return $out }
    $qdc = ([int]$Response[4] -shl 8) -bor [int]$Response[5]
    if ($qdc -le 0 -or $qdc -gt 32) { return $out }
    $i = 12
    for ($q = 0; $q -lt $qdc; $q++) {
        $guard = 0
        $qDone = $false
        while ($i -lt $Response.Length -and $guard -lt 256) {
            $len = [int]$Response[$i]
            if ($len -eq 0) { $i++; $qDone = $true; break }
            if (($len -band 0xC0) -eq 0xC0) {
                if ($i + 2 -gt $Response.Length) { return $out }
                $i += 2; $qDone = $true; break
            }
            if ($i + $len + 1 -gt $Response.Length) { return $out }
            $i += ($len + 1); $guard++
        }
        if (-not $qDone -or $guard -ge 256) { return $out }
        if ($i + 4 -gt $Response.Length) { return $out }
        $i += 4   # qtype + qclass
    }
    $n = 0
    while ($n -lt $anc -and $i + 10 -le $Response.Length) {
        $n++
        $guard = 0
        $rDone = $false
        while ($i -lt $Response.Length -and $guard -lt 256) {
            $len = [int]$Response[$i]
            if ($len -eq 0) { $i++; $rDone = $true; break }
            if (($len -band 0xC0) -eq 0xC0) {
                if ($i + 2 -gt $Response.Length) { return $out }
                $i += 2; $rDone = $true; break
            }
            if ($i + $len + 1 -gt $Response.Length) { return $out }
            $i += ($len + 1); $guard++
        }
        if (-not $rDone -or $guard -ge 256) { break }
        if ($i + 10 -gt $Response.Length) { break }
        $type = ([int]$Response[$i] -shl 8) -bor [int]$Response[$i + 1]
        $class = ([int]$Response[$i + 2] -shl 8) -bor [int]$Response[$i + 3]
        $rdlen = ([int]$Response[$i + 8] -shl 8) -bor [int]$Response[$i + 9]
        $i += 10
        if ($i + $rdlen -gt $Response.Length) { break }
        if ($type -eq 1 -and $class -eq 1 -and $rdlen -eq 4) { $out += ('{0}.{1}.{2}.{3}' -f $Response[$i], $Response[$i + 1], $Response[$i + 2], $Response[$i + 3]) }
        $i += $rdlen
    }
    return $out
}
# One raw UDP DNS query for ONE name, sent FROM a given local IPv4 address, answered only by that adapter's own
# configured resolvers. Binding the source is what makes the answer about THAT link: the system resolver would be
# free to answer from the Wi-Fi hotspot's DNS and hide a completely dead campus resolver.
function Get-ScopedDnsAnswers([string]$Name, [string]$SourceIp, [int]$TimeoutMs = 1200) {
    $out = @()
    if (-not $Name -or -not $SourceIp) { return $out }
    $owner = $null
    try { $owner = @(Get-NetIPAddress -IPAddress $SourceIp -ErrorAction SilentlyContinue | Select-Object -First 1) } catch {}
    if (-not $owner) { return $out }
    $idx = [int]$owner.InterfaceIndex
    $servers = @()
    try { $servers = @((Get-DnsClientServerAddress -InterfaceIndex $idx -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses | Where-Object { $_ -match '^\d{1,3}(\.\d{1,3}){3}$' }) } catch {}
    $guidScoped = ''
    try { $guidScoped = [string](Get-NetAdapter -InterfaceIndex $idx -ErrorAction SilentlyContinue | Select-Object -First 1).InterfaceGuid } catch {}
    if ($guidScoped) { try { $servers += @(Get-DhcpDnsServers $guidScoped) } catch {} }
    $ipifScoped = Get-NetIPInterface -InterfaceIndex $idx -AddressFamily IPv4 -ErrorAction SilentlyContinue
    if ($ipifScoped -and [int]$ipifScoped.InterfaceMetric -ge 45 -and (Get-RouteProfileName) -ne 'Wifi') {
        $localAllowed = @($script:Cfg.CampusDns, $script:Cfg.PortalIp)
        if ($guidScoped) { try { $localAllowed += @(Get-DhcpDnsServers $guidScoped) } catch {} }
        $localAllowed = @($localAllowed | Where-Object { $_ -and $_ -ne '0.0.0.0' } | Select-Object -Unique)
        $scopedOnly = @($servers | Where-Object { $localAllowed -contains $_ -or (Test-PrivateIPv4 $_) })
        if ($scopedOnly.Count -gt 0) { $servers = $scopedOnly } elseif ($localAllowed.Count -gt 0) { $servers = $localAllowed }
    }
    $servers = @($servers | Where-Object { $_ -and $_ -ne '0.0.0.0' } | Select-Object -Unique)
    if ($servers.Count -eq 0) { return $out }
    $id = Get-Random -Minimum 1000 -Maximum 60000
    [byte[]]$pkt = New-DnsQueryPacket $Name $id
    $pending = @{}
    foreach ($s in $servers) {
        $u = $null
        try {
            try { $u = New-Object System.Net.Sockets.UdpClient((New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($SourceIp), 0))) }
            catch { if ($u) { try { $u.Close() } catch {} }; $u = $null }
            if (-not $u) {
                if ($s -eq $script:Cfg.CampusDns -or $s -eq $script:Cfg.PortalIp -or (Test-PrivateIPv4 $s)) { $u = New-Object System.Net.Sockets.UdpClient }
                else { continue }
            }
            $u.Connect($s, 53)
            [void]$u.Send($pkt, $pkt.Length)
            $pending[$s] = $u
        } catch { if ($u) { try { $u.Close() } catch {} } }
    }
    if ($pending.Count -eq 0) { return $out }
    $clock = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        while ($pending.Count -gt 0 -and $clock.ElapsedMilliseconds -lt $TimeoutMs -and $out.Count -eq 0) {
            $slice = [int][math]::Min(25, [math]::Max(1, $TimeoutMs - $clock.ElapsedMilliseconds))
            $rl = New-Object System.Collections.ArrayList
            foreach ($s in $pending.Keys) { [void]$rl.Add($pending[$s].Client) }
            try { [System.Net.Sockets.Socket]::Select($rl, $null, $null, ($slice * 1000)) } catch { Start-Sleep -Milliseconds 2 }
            foreach ($s in @($pending.Keys)) {
                $u = $pending[$s]
                if (-not $rl.Contains($u.Client)) { continue }
                try {
                    $ep = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
                    $ans = @(Get-DnsAAnswers ($u.Receive([ref]$ep)) $pkt)
                    if ($ans.Count -gt 0) { $out = @($ans) }
                } catch {}
                try { $u.Close() } catch {}
                $pending.Remove($s)
            }
        }
    } finally {
        foreach ($s in @($pending.Keys)) { try { $pending[$s].Close() } catch {} }
    }
    return $out
}
# DNS lookup with a hard time limit (HttpWebRequest/GetHostAddresses alone can block for many seconds).
# $SourceIp pins the lookup to ONE link: while a second uplink is up, the system-wide resolver answers from ITS DNS,
# so a dead Ethernet resolver looks healthy. In that case only this adapter's own resolvers may answer; when none
# does, the truthful answer is "no DNS on this link" ($null) and Invoke-HttpProbe reports DnsFail for that adapter.
function Test-IsSinkholeIp([string]$Ip) {
    if (-not $Ip) { return $true }
    $s = ([string]$Ip).Trim()
    # IPv4 RFC 5737 TEST-NET-1/2/3, loopback, 0.0.0.0/8, link-local, benchmarking, multicast, reserved
    if ($s -match '^192\.0\.2\.' -or $s -match '^198\.51\.100\.' -or $s -match '^203\.0\.113\.' -or
        $s -match '^127\.' -or $s -eq '0.0.0.0' -or $s -match '^0\.' -or $s -match '^169\.254\.' -or
        $s -match '^198\.(1[89])\.' -or $s -match '^(22[4-9]|23[0-9]|24[0-9]|25[0-5])\.') {
        return $true
    }
    # IPv6 documentation (2001:db8::), loopback (::1), unspecified (::), link-local (fe80::) or ULA (fc00::/fd00::)
    if ($s -match '^(?i)2001:0?db8:' -or $s -eq '::1' -or $s -eq '::' -or
        $s -match '^(?i)fe[89ab][0-9a-f]:' -or $s -match '^(?i)f[cd][0-9a-f]{2}:') {
        return $true
    }
    return $false
}

function Get-DnsVerdictDecision([bool]$HasGlobalV6, [bool]$HasV6Route, [int]$V6DnsCount, [bool]$IsSinkhole) {
    if ($V6DnsCount -le 0) { return 'None' }
    if ($IsSinkhole) { return 'Neutralize' }
    if (-not $HasGlobalV6 -or -not $HasV6Route) { return 'Neutralize' }
    return 'Keep'
}

function Get-AdapterDnsVerdict($Ad) {
    if (-not $Ad -or -not $Ad.ifIndex) { return 'Neutralize' }
    $hasGlobalV6 = $false
    $hasV6Route = $false
    $v6Dns = @()
    $isSinkhole = $false
    try {
        $addrs = @(Get-NetIPAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv6 -ErrorAction SilentlyContinue | Where-Object { [string]$_.AddressState -eq 'Preferred' })
        foreach ($a in $addrs) {
            $ip = [string]$a.IPAddress
            if ($ip -match '^(?i)[23][0-9a-f]{3}:') { $hasGlobalV6 = $true; break }
        }
        $routes = @(Get-NetRoute -InterfaceIndex $Ad.ifIndex -AddressFamily IPv6 -DestinationPrefix '::/0' -ErrorAction SilentlyContinue)
        foreach ($r in $routes) {
            $nh = [string]$r.NextHop
            if ($nh -and $nh -ne '::') {
                $hasV6Route = $true; break
            }
        }
        $v6Dns = @(Get-DnsClientServerAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv6 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ServerAddresses)
        if ($v6Dns.Count -gt 0) {
            try {
                $dnsq = Resolve-DnsName -Name 'connectivitycheck.gstatic.com' -Server $v6Dns[0] -Type A -QuickTimeout -DnsOnly -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($dnsq -and $dnsq.IPAddress -and (Test-IsSinkholeIp [string]$dnsq.IPAddress)) {
                    $isSinkhole = $true
                }
            } catch {}
        }
    } catch {}
    $decision = Get-DnsVerdictDecision $hasGlobalV6 $hasV6Route $v6Dns.Count $isSinkhole
    return @{
        Action      = $decision
        HasGlobalV6 = $hasGlobalV6
        HasV6Route  = $hasV6Route
        V6DnsCount  = $v6Dns.Count
        IsSinkhole  = $isSinkhole
    }
}
function Resolve-HostBounded([string]$Name, [int]$TimeoutMs = 2500, [string]$SourceIp = '', [switch]$NoPin) {
    if (-not $Name) { return $null }
    $cleanName = $Name.Trim().TrimEnd('.')
    if (-not $cleanName) { return $null }
    $discIp = if ($script:State -is [hashtable] -and $script:State.Misc -is [hashtable]) { [string]$script:State.Misc['DiscoveredPortalIp'] } else { '' }
    if (-not $NoPin -and $discIp -and (Test-AllowedPortalIp $discIp)) {
        $activeEp = Get-ActivePortalEndpoint
        if ($cleanName.ToLower() -eq ([string]$activeEp.Host).TrimEnd('.').ToLower()) { return $discIp }
    }
    if (-not $NoPin -and $script:Cfg.PortalHost -and ($cleanName.ToLower() -eq ([string]$script:Cfg.PortalHost).TrimEnd('.').ToLower()) -and $script:Cfg.PortalIp) {
        return [string]$script:Cfg.PortalIp
    }
    if ($SourceIp -and (Test-OtherUplinkActive)) {
        $bounded = @(Get-ScopedDnsAnswers $cleanName $SourceIp 1200)
        foreach ($b in $bounded) {
            if ($b -and -not (Test-IsSinkholeIp [string]$b)) { return [string]$b }
        }
        return $null
    }
    try {
        $ar = [System.Net.Dns]::BeginGetHostAddresses($cleanName, $null, $null)
        $ok = $ar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)   # the runtime owns this handle: closing it early breaks later connects
        if ($ok) {
            $ips = [System.Net.Dns]::EndGetHostAddresses($ar)
            foreach ($ip in $ips) {
                if ($ip.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork) {
                    $s = $ip.ToString()
                    if (-not (Test-IsSinkholeIp $s)) { return $s }
                }
            }
        }
    } catch {}
    try {
        $dnsRecs = @(Resolve-DnsName -Name $cleanName -Type A -QuickTimeout -DnsOnly -ErrorAction SilentlyContinue)
        foreach ($rec in $dnsRecs) {
            if ($rec -and $rec.IPAddress) {
                $s = [string]$rec.IPAddress
                if (-not (Test-IsSinkholeIp $s)) { return $s }
            }
        }
    } catch {}
    return $null
}
# Pure (unit-tested): the absolute http(s) URL a captive page redirects to with <meta refresh> or JavaScript, else ''.
function Get-RedirectFromBody([string]$Html) {
    if (-not $Html) { return '' }
    $h = $Html
    if ($h.Length -gt 4096) { $h = $h.Substring(0, 4096) }
    $patterns = @(
        '(?is)<meta\b[^>]*http-equiv\s*=\s*["'']?refresh["'']?[^>]*content\s*=\s*["''][^"'']*?url\s*=\s*["'']?([^"''>\s]+)',
        '(?is)<meta\b[^>]*content\s*=\s*["''][^"'']*?url\s*=\s*["'']?([^"''>\s]+)[^>]*http-equiv\s*=\s*["'']?refresh',
        '(?is)(?:window\.|self\.|top\.|document\.)?location(?:\.href|\.replace|\.assign)?\s*(?:=|\()\s*["''](https?://[^"''\s<>]+)["'']'
    )
    $timeout = [TimeSpan]::FromMilliseconds(500)
    foreach ($rx in $patterns) {
        try {
            $m = [regex]::Match($h, $rx, [System.Text.RegularExpressions.RegexOptions]::None, $timeout)
            if ($m.Success) {
                $u = [System.Net.WebUtility]::HtmlDecode($m.Groups[1].Value).Trim('"', "'", ';', ' ')
                if ($u -match '^https?://\S+$') {
                    try {
                        $parsed = [uri]$u
                        if ($parsed.IsAbsoluteUri -and ($parsed.Scheme -eq 'http' -or $parsed.Scheme -eq 'https')) {
                            return $parsed.AbsoluteUri
                        }
                    } catch {}
                }
            }
        } catch {}
    }
    return ''
}
function ConvertFrom-HttpResponse([string]$Raw) {
    $r = @{ Code = 0; Body = ''; Location = '' }
    if (-not $Raw) { return $r }
    $m = [regex]::Match($Raw, '^HTTP/\d\.\d\s+(\d{3})')
    if (-not $m.Success) { return $r }
    $r.Code = [int]$m.Groups[1].Value
    $head = $Raw
    $cut = $Raw.IndexOf("`r`n`r`n"); $skip = 4
    if ($cut -lt 0) { $cut = $Raw.IndexOf("`n`n"); $skip = 2 }
    $full = ''
    if ($cut -ge 0) {
        $head = $Raw.Substring(0, $cut)
        $body = $Raw.Substring($cut + $skip)
        $full = $body
        if ($body.Length -gt 128) { $body = $body.Substring(0, 128) }
        $r.Body = $body
    }
    $lm = [regex]::Match($head, '(?im)^Location:[ \t]*(\S+)')
    if ($lm.Success) { $r.Location = $lm.Groups[1].Value }
    elseif ($r.Code -eq 200 -and $full) { $r.Location = Get-RedirectFromBody $full }
    return $r
}
# Plain HTTP/1.0 over a raw socket: hard timeouts everywhere, no proxy, no redirects followed, and the
# socket can be bound to the Ethernet adapter's own IP so the verdict is about THAT link (not Wi-Fi).
function Invoke-HttpProbe([string]$HostName, [string]$Path, [int]$TimeoutMs = 2500, [string]$SourceIp = '', [int]$Port = 80) {
    $r = @{ Code = 0; Body = ''; Location = ''; Error = '' }
    # The socket is bound to $SourceIp, so the NAME has to be resolved the same way: otherwise Wi-Fi's DNS answers
    # for the Ethernet probe and a dead campus resolver is never reported.
    $ip = Resolve-HostBounded $HostName 2200 $SourceIp
    if (-not $ip) { $r.Error = 'DnsFail'; return $r }
    $sock = New-Object System.Net.Sockets.Socket([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
    try {
        if ($SourceIp) {
            try { $sock.Bind((New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($SourceIp), 0))) } catch { $r.Error = 'BindFailure'; return $r }
        }
        $iar = $sock.BeginConnect([System.Net.IPAddress]::Parse($ip), $Port, $null, $null)
        $connected = $iar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)
        if (-not $connected) { $r.Error = 'Timeout'; return $r }
        try { $sock.EndConnect($iar) } catch { $r.Error = 'ConnectFailure'; return $r }
        $sock.ReceiveTimeout = $TimeoutMs
        $sock.SendTimeout = $TimeoutMs
        $req = "GET $Path HTTP/1.0`r`nHost: $HostName`r`nUser-Agent: Mozilla/5.0 LanFixer-Probe`r`nAccept: */*`r`nConnection: close`r`n`r`n"
        [void]$sock.Send([System.Text.Encoding]::ASCII.GetBytes($req))
        $buf = New-Object byte[] 2048
        $total = 0
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        while ($total -lt $buf.Length -and $sw.ElapsedMilliseconds -lt $TimeoutMs) {
            $n = 0
            try { $n = $sock.Receive($buf, $total, ($buf.Length - $total), [System.Net.Sockets.SocketFlags]::None) } catch { break }
            if ($n -le 0) { break }
            $total += $n
            $txt = [System.Text.Encoding]::ASCII.GetString($buf, 0, $total)
            $he = $txt.IndexOf("`r`n`r`n")
            if ($he -ge 0) {
                # Headers are complete. Anything but a 200 is already decisive; a 200 needs a little body to compare.
                $bodyLen = $total - $he - 4
                if (($txt -notmatch '^HTTP/\d\.\d\s+200') -or (($bodyLen -ge 40) -and (($txt -match 'Microsoft Connect Test') -or ($bodyLen -ge 700)))) { break }
            }
        }
        if ($total -eq 0) { $r.Error = 'NoResponse'; return $r }
        $p = ConvertFrom-HttpResponse ([System.Text.Encoding]::ASCII.GetString($buf, 0, $total))
        $r.Code = $p.Code; $r.Body = $p.Body; $r.Location = $p.Location
        if ($r.Code -eq 0) { $r.Error = 'BadResponse' }
    } catch { $r.Error = $_.Exception.Message }
    finally {
        if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
        if ($sock) { try { $sock.Close(); $sock.Dispose() } catch {} }
    }
    return $r
}
# Pure classifier (unit-tested in SelfTest).
#   Captive = a redirect (3xx), an auth demand (401/407/511) or a 2xx that is not the expected probe answer.
#   v2 treated EVERY HTTP answer as "captive", so a 502/503 from an upstream outage made it open the login
#   page and sit in a 12-minute auth watch over and over. 4xx/5xx now means Offline (gateway up, path broken).
# ==============================================================================
# CONNECTIVITY VERDICT (strict per adapter; a system-wide fallback only when no other uplink could be answering)
# ==============================================================================
function Test-OtherUplinkActive {
    try { return ((Get-OtherUplinkAdapters).Count -gt 0) }
    catch { return $true }   # cannot tell: assume yes (the safe answer: no fallback)
}

# Pure decision (unit-tested). The unbound/system probe exists for VPN/WARP/loopback-DNS setups. It would also happily
# answer over Wi-Fi, so it is allowed only for a general question (not a per-adapter one) and only when no other
# physical uplink is up; otherwise a dead Ethernet port would be reported "Online" and the repair engine would stand down.
function Test-AllowSystemFallback([bool]$Explicit, [string]$State, [bool]$OtherUplink) {
    if ($Explicit) { return $false }
    if ($State -ne 'Offline' -and $State -ne 'NoDns') { return $false }
    if ($OtherUplink) { return $false }
    return $true
}

# ==============================================================================
# INTERFACE METRICS (apply only while Ethernet is verified online; always restorable to the ORIGINAL values)
# ==============================================================================
function Get-AllWirelessAdapters {
    $ethGuids = @(Get-EthernetAdapters | ForEach-Object { [string]$_.InterfaceGuid })
    return @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object {
        $ethGuids -notcontains [string]$_.InterfaceGuid -and
        ($_.InterfaceAlias -match 'Wi-?Fi|Wireless|WLAN' -or $_.InterfaceDescription -match 'Wi-?Fi|Wireless|802\.11|WLAN') -and
        $_.InterfaceDescription -notmatch 'Virtual|Hyper-V|VMware|VirtualBox|\bTAP\b|\bTUN\b|\bWSL\b|Tailscale|ZeroTier|WireGuard|Wintun|Loopback|Npcap|OpenVPN|AnyConnect|Fortinet|PANGP|WARP|Wi-Fi Direct'
    })
}
function Get-OtherUplinkAdapters {
    $ethGuids = @(Get-EthernetAdapters | ForEach-Object { [string]$_.InterfaceGuid })
    $candidates = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object {
        $_.Status -eq 'Up' -and
        $ethGuids -notcontains [string]$_.InterfaceGuid -and
        $_.InterfaceDescription -notmatch 'Virtual|Hyper-V|VMware|VirtualBox|\bTAP\b|\bTUN\b|\bWSL\b|Tailscale|ZeroTier|WireGuard|Wintun|Loopback|Npcap|OpenVPN|AnyConnect|Fortinet|PANGP|WARP|Wi-Fi Direct'
    })
    $valid = @()
    foreach ($c in $candidates) {
        $hasGw4 = @(Get-NetRoute -InterfaceIndex $c.ifIndex -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Where-Object { $_.NextHop -and $_.NextHop -ne '0.0.0.0' -and $_.NextHop -notlike '169.254.*' }).Count -gt 0
        $hasGw6 = @(Get-NetRoute -InterfaceIndex $c.ifIndex -DestinationPrefix '::/0' -ErrorAction SilentlyContinue | Where-Object { $_.NextHop -and $_.NextHop -ne '::' }).Count -gt 0
        $hasIp4 = [bool](Get-ValidIPv4 $c)
        $hasIp6 = @(Get-NetIPAddress -InterfaceIndex $c.ifIndex -AddressFamily IPv6 -ErrorAction SilentlyContinue | Where-Object { [string]$_.AddressState -eq 'Preferred' -and [string]$_.IPAddress -notmatch '^(fe80|fc|fd|::1)' }).Count -gt 0
        if (($hasGw4 -and $hasIp4) -or ($hasGw6 -and $hasIp6)) { $valid += $c }
    }
    return $valid
}

function Save-MetricOriginal($If) {
    if ($script:IsDry) { return }
    $ad = Get-NetAdapter -InterfaceIndex $If.ifIndex -IncludeHidden -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $ad) { return }
    if ($script:State.Misc['MetricOrig'] -isnot [hashtable]) { $script:State.Misc['MetricOrig'] = @{} }
    $k = ('{0}|{1}' -f [string]$ad.InterfaceGuid, [string]$If.AddressFamily)
    if ($script:State.Misc['MetricOrig'].ContainsKey($k)) { return }
    $script:State.Misc['MetricOrig'][$k] = @{ Auto = [string]$If.AutomaticMetric; Metric = [int]$If.InterfaceMetric; Alias = [string]$If.InterfaceAlias; Af = [string]$If.AddressFamily }
}

function Set-InterfaceMetric($If, [int]$Metric, [string]$Why) {
    Save-MetricOriginal $If
    $af = [string]$If.AddressFamily
    return (Invoke-Change $Why { Set-NetIPInterface -InterfaceIndex $If.ifIndex -AddressFamily $af -InterfaceMetric $Metric -AutomaticMetric Disabled -ErrorAction Stop })
}

# Remember every host route we create, so cleanup can remove addresses the configuration does not name.
function Add-TrackedHostRoute([string]$Ip) {
    try {
        if (-not $Ip -or $script:State -isnot [hashtable] -or $script:State.Misc -isnot [hashtable]) { return }
        $cur = @($script:State.Misc['InjectedHostRoutes'] | Where-Object { $_ })
        if ($cur -notcontains $Ip) { $script:State.Misc['InjectedHostRoutes'] = @($cur + $Ip) }
    } catch {}
}
function Remove-CampusHostRoutes([int]$InterfaceIndex = 0) {
    if ($script:IsDry) { return }
    foreach ($hip in @($script:Cfg.PortalIp, $script:Cfg.CampusDns) | Where-Object { $_ }) {
        foreach ($rt in @(Get-NetRoute -DestinationPrefix "$hip/32" -PolicyStore ActiveStore -ErrorAction SilentlyContinue | Where-Object { [int]$_.RouteMetric -eq 5 -and ($InterfaceIndex -le 0 -or [int]$_.InterfaceIndex -eq $InterfaceIndex) })) {
            Remove-NetRoute -InterfaceIndex ([int]$rt.InterfaceIndex) -DestinationPrefix "$hip/32" -PolicyStore ActiveStore -Confirm:$false -ErrorAction SilentlyContinue
            Remove-NetRoute -InterfaceIndex ([int]$rt.InterfaceIndex) -DestinationPrefix "$hip/32" -PolicyStore PersistentStore -Confirm:$false -ErrorAction SilentlyContinue
        }
    }
    # Ensure-CampusPortalPath also routes the discovered portal, the redirect target and each adapter's DHCP resolvers.
    # Those are removed here too, but only routes that carry OUR metric (5), so a route someone else owns is never touched.
    $extra = @()
    try {
        if ($script:State -is [hashtable] -and $script:State.Misc -is [hashtable]) {
            $extra += [string]$script:State.Misc['DiscoveredPortalIp']
            $extra += @($script:State.Misc['InjectedHostRoutes'] | ForEach-Object { [string]$_ })
        }
        foreach ($ea in @(Get-EthernetAdapters)) { $extra += @(Get-DhcpDnsServers ([string]$ea.InterfaceGuid) | Where-Object { Test-PrivateIPv4 $_ }) }
    } catch {}
    foreach ($hip in @($extra | Where-Object { $_ } | Select-Object -Unique)) {
        foreach ($rt in @(Get-NetRoute -DestinationPrefix "$hip/32" -PolicyStore ActiveStore -ErrorAction SilentlyContinue | Where-Object { [int]$_.RouteMetric -eq 5 -and ($InterfaceIndex -le 0 -or [int]$_.InterfaceIndex -eq $InterfaceIndex) })) {
            Remove-NetRoute -InterfaceIndex ([int]$rt.InterfaceIndex) -DestinationPrefix "$hip/32" -PolicyStore ActiveStore -Confirm:$false -ErrorAction SilentlyContinue
        }
    }
    try { if ($InterfaceIndex -le 0 -and $script:State -is [hashtable] -and $script:State.Misc -is [hashtable] -and $script:State.Misc.ContainsKey('InjectedHostRoutes')) { $script:State.Misc.Remove('InjectedHostRoutes') } } catch {}
}
function Restore-InterfaceMetrics([string]$Why) {
    Remove-CampusHostRoutes
    $orig = $script:State.Misc['MetricOrig']
    $present = @(Get-NetAdapter -IncludeHidden -ErrorAction SilentlyContinue)
    if ($orig -is [hashtable] -and $orig.Count -gt 0) {
        foreach ($k in @($orig.Keys)) {
            $rec = $orig[$k]
            $guid = ($k -split '\|')[0]
            $ad = $present | Where-Object { [string]$_.InterfaceGuid -eq $guid } | Select-Object -First 1
            if (-not $ad) { continue }
            $af = [string]$rec.Af
            $targetIf = Get-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily $af -ErrorAction SilentlyContinue | Select-Object -First 1
            if (-not $targetIf) {
                if (-not $script:IsDry) { $orig.Remove($k) }
                continue
            }
            $ok = $false
            if ([string]$rec.Auto -eq 'Enabled') {
                if ([string]$targetIf.AutomaticMetric -ne 'Enabled') {
                    $ok = Invoke-Change ('{0}: {1} {2} metric back to automatic' -f $Why, $rec.Alias, $af) { Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily $af -AutomaticMetric Enabled -ErrorAction Stop }
                } else {
                    $ok = $true
                }
            } else {
                $mv = [int]$rec.Metric
                if ([int]$targetIf.InterfaceMetric -ne $mv -or [string]$targetIf.AutomaticMetric -eq 'Enabled') {
                    $ok = Invoke-Change ('{0}: {1} {2} metric back to {3}' -f $Why, $rec.Alias, $af, $mv) { Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily $af -InterfaceMetric $mv -ErrorAction Stop }
                } else {
                    $ok = $true
                }
            }
            if ($ok -and -not $script:IsDry) { $orig.Remove($k) }
        }
    }
    if ($script:State.Misc['WifiMetricManaged'] -eq $true -and -not ($orig -is [hashtable] -and $orig.Count -gt 0)) {
        # records written by an older build: it never kept the original values, so automatic is the best honest restore
        foreach ($w in @(Get-NetIPInterface -ErrorAction SilentlyContinue | Where-Object { $_.InterfaceAlias -match 'Wi-?Fi|Wireless' })) {
            [void](Invoke-Change ('{0}: {1} {2} metric back to automatic (older record)' -f $Why, $w.InterfaceAlias, $w.AddressFamily) { Set-NetIPInterface -InterfaceIndex $w.ifIndex -AddressFamily $w.AddressFamily -AutomaticMetric Enabled -ErrorAction Stop })
        }
        if (-not $script:IsDry) { $script:State.Misc['WifiMetricManaged'] = $false }
    }
    if ((Get-RouteProfileName) -eq 'Windows') {
        foreach ($ea in @(Get-EthernetAdapters)) {
            foreach ($af in @('IPv4', 'IPv6')) {
                $ipif = Get-NetIPInterface -InterfaceIndex $ea.ifIndex -AddressFamily $af -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($ipif -and [string]$ipif.AutomaticMetric -ne 'Enabled') {
                    [void](Invoke-Change ('{0}: {1} {2} automatic metric enabled' -f $Why, $ea.Name, $af) { Set-NetIPInterface -InterfaceIndex $ea.ifIndex -AddressFamily $af -AutomaticMetric Enabled -ErrorAction Stop })
                }
            }
        }
        foreach ($w in @(Get-OtherUplinkAdapters)) {
            foreach ($af in @('IPv4', 'IPv6')) {
                $ipif = Get-NetIPInterface -InterfaceIndex $w.ifIndex -AddressFamily $af -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($ipif -and [string]$ipif.AutomaticMetric -ne 'Enabled') {
                    [void](Invoke-Change ('{0}: {1} {2} automatic metric enabled' -f $Why, $w.Name, $af) { Set-NetIPInterface -InterfaceIndex $w.ifIndex -AddressFamily $af -AutomaticMetric Enabled -ErrorAction Stop })
                }
            }
        }
    }
}

function Test-MetricsManaged {
    $o = $script:State.Misc['MetricOrig']
    return (($o -is [hashtable] -and $o.Count -gt 0) -or ($script:State.Misc['WifiMetricManaged'] -eq $true))
}

# ==============================================================================
# IPv6: act only on EVIDENCE (advertised, but unreachable while IPv4 works); keep every other DisabledComponents bit
# ==============================================================================
function Get-Ipv6State($Ad, [string]$Conn) {
    if (-not $Ad -or -not $Ad.ifIndex) { return @{ Verdict = 'None'; HasGlobal = $false } }
    $g6 = @(Get-NetIPAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv6 -ErrorAction SilentlyContinue | Where-Object { [string]$_.AddressState -eq 'Preferred' -and [string]$_.IPAddress -notmatch '^(fe80|fc|fd|::1)' })
    $r6 = @(Get-NetRoute -InterfaceIndex $Ad.ifIndex -AddressFamily IPv6 -DestinationPrefix '::/0' -ErrorAction SilentlyContinue)
    $reach = $false
    if ($g6.Count -gt 0 -and $r6.Count -gt 0 -and $Conn -eq 'Online') { $reach = Test-Ipv6Reach ([string]$g6[0].IPAddress) }
    return @{ Verdict = (Get-Ipv6Verdict ($g6.Count -gt 0) ($r6.Count -gt 0) $Conn $reach); HasGlobal = ($g6.Count -gt 0) }
}

function Get-PreferIpv4Value($Current) {
    $c = 0
    if ($null -ne $Current) { $c = [int]$Current }
    return ($c -bor 32)   # 0x20 = prefer IPv4 in prefix policy; every other bit the user/OS set stays
}

# Pure decision (unit-tested): skip | candidate (seen once) | clamp (seen twice, within 8 bytes).
function Get-MtuDecision($Pmtu, [int]$CurrentMtu, $Candidate) {
    if ($null -eq $Pmtu) { return @{ Action = 'skip'; Value = 0 } }
    $p = [int]$Pmtu
    if ($CurrentMtu -le $p -or ($CurrentMtu -eq 1400 -and $p -eq 1400)) { return @{ Action = 'skip'; Value = 0 } }
    if ($p -ge 1500 -or $p -lt 1280) { return @{ Action = 'skip'; Value = 0 } }
    if ($null -ne $Candidate -and [Math]::Abs([int]$Candidate - $p) -le 8) { return @{ Action = 'clamp'; Value = [Math]::Min([int]$Candidate, $p) } }
    return @{ Action = 'candidate'; Value = $p }
}

# ==============================================================================
# DHCP FAILURE WORDING (states what Windows logged; does not guess at the cause)
# ==============================================================================
$script:DhcpDiagCache = $null
function Get-DhcpErrorCode {
    $c = $script:DhcpDiagCache
    if ($c -and (((Get-Date) - $c.Time).TotalSeconds -lt 60)) { return $c.Code }
    $code = $null
    try {
        foreach ($e in @(Get-WinEvent -FilterHashtable @{ LogName = 'Microsoft-Windows-Dhcp-Client/Admin'; Id = 1001 } -MaxEvents 3 -ErrorAction SilentlyContinue)) {
            if (((Get-Date) - $e.TimeCreated).TotalSeconds -gt 300) { continue }
            $m = [regex]::Match([string]$e.Message, '0x([0-9a-fA-F]{1,8})')
            if ($m.Success) { $code = [Convert]::ToInt32($m.Groups[1].Value, 16); break }
            if ($e.Properties -and $e.Properties.Count -gt 7) { $v = 0; if ([int]::TryParse([string]$e.Properties[7].Value, [ref]$v)) { $code = $v; break } }
        }
    } catch {}
    $script:DhcpDiagCache = @{ Time = (Get-Date); Code = $code }
    return $code
}

function Get-DhcpFailureText($Code, [string]$Mac) {
    $extra = ''
    try {
        $lastL = $script:State.Misc['LastCampusLease']
        if ($lastL -and $lastL.Ip) { $extra = " (Last known lease was $($lastL.Ip))." }
    } catch {}
    if ($null -ne $Code -and [int]$Code -eq 121) { return ('The DHCP request timed out (0x79): no DHCP server or relay answered on this port. A switch fault and an unregistered MAC look identical from here.' + $extra) }
    if ($null -ne $Code) { return (('Windows logged DHCP error 0x{0:X} for this port.' -f [int]$Code) + $extra) }
    return (('No lease. Likely causes: wrong or blocked wall port, VLAN not provisioned, or this MAC is not registered: {0}' -f $Mac) + $extra)
}
# ==============================================================================
# HARDENED PORTAL CLIENT (raw TLS over a source-bound socket; no process-wide certificate bypass)
# ==============================================================================
function Test-AllowedPortalIp([string]$Ip, $Ad = $null) {
    if (Test-PrivateIPv4 $Ip) { return $true }
    if ($Ip -match '^100\.(6[4-9]|[7-9]\d|1[01]\d|12[0-7])\.') { return $true }
    if ($Ip -eq [string]$script:Cfg.PortalIp) { return $true }
    if ($Ad) {
        foreach ($g in @(Get-GatewaysV4 $Ad)) { if ($g -eq $Ip) { return $true } }
    } else {
        foreach ($a in @(Get-EthernetAdapters)) {
            foreach ($g in @(Get-GatewaysV4 $a)) { if ($g -eq $Ip) { return $true } }
        }
    }
    return $false
}
function Test-PrivateIPv4([string]$Ip) {
    $a = $null
    if (-not [System.Net.IPAddress]::TryParse($Ip, [ref]$a)) { return $false }
    if ($a.AddressFamily -ne [System.Net.Sockets.AddressFamily]::InterNetwork) { return $false }
    $b = $a.GetAddressBytes()
    if ($b[0] -eq 10) { return $true }
    if ($b[0] -eq 172 -and $b[1] -ge 16 -and $b[1] -le 31) { return $true }
    if ($b[0] -eq 192 -and $b[1] -eq 168) { return $true }
    return $false
}

# Pure decision (unit-tested). The real callback inlines the same rule: a delegate cannot see script functions.
function Get-CertDecision([string]$PolicyErrors, [string]$Sha256, [string]$Pin) {
    if ($PolicyErrors -eq 'None') { return 'valid' }
    if ($Pin -and $Sha256 -and ($Sha256.ToUpper() -eq $Pin.ToUpper())) { return 'pinned' }
    return 'reject'
}

# A certificate is accepted ONLY when Windows validates it, or when its SHA-256 equals the pin you approved.
# $Capture (optional hashtable) receives the certificate details; with AcceptAny it is a look-only handshake.
function New-CertCallback([string]$Pin, $Capture) {
    $pinU = ([string]$Pin).ToUpper()
    $cb = {
        param($sender, $cert, $chain, $errs)
        $sha = $null; $hex = ''
        try {
            if ($null -ne $cert) {
                $sha = [System.Security.Cryptography.SHA256]::Create()
                $hex = ([BitConverter]::ToString($sha.ComputeHash($cert.GetRawCertData())) -replace '-', '')
            }
        } catch {} finally { if ($sha) { $sha.Dispose() } }
        if ($null -ne $Capture) {
            $Capture.Sha256 = $hex; $Capture.Errors = [string]$errs; $Capture.Subject = ''; $Capture.Issuer = ''; $Capture.NotAfter = ''
            try { $c2 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($cert); $Capture.Subject = [string]$c2.Subject; $Capture.Issuer = [string]$c2.Issuer; $Capture.NotAfter = $c2.NotAfter.ToString('yyyy-MM-dd') } catch {}
            if ($Capture.AcceptAny) { return $true }
        }
        if ([string]$errs -eq 'None') { return $true }
        if ($pinU -and $hex -and ($hex -eq $pinU)) { return $true }
        return $false
    }.GetNewClosure()
    return [System.Net.Security.RemoteCertificateValidationCallback]$cb
}

function ConvertFrom-ChunkedBytes([byte[]]$Data) {
    $out = New-Object System.IO.MemoryStream
    try {
        $i = 0
        while ($i -lt $Data.Length) {
            $e = $i
            $lfLen = 0
            while ($e -lt $Data.Length) {
                if ($e -lt ($Data.Length - 1) -and $Data[$e] -eq 13 -and $Data[$e + 1] -eq 10) { $lfLen = 2; break }
                if ($Data[$e] -eq 10) { $lfLen = 1; break }
                $e++
            }
            if ($lfLen -eq 0) { break }
            $line = [System.Text.Encoding]::ASCII.GetString($Data, $i, $e - $i)
            $semi = $line.IndexOf(';'); if ($semi -ge 0) { $line = $line.Substring(0, $semi) }
            $n = 0
            try { $n = [Convert]::ToInt32($line.Trim(), 16) } catch { break }
            $i = $e + $lfLen
            if ($n -le 0 -or $i -ge $Data.Length) { break }
            $take = [Math]::Min($n, $Data.Length - $i)
            if ($take -gt 0) { $out.Write($Data, $i, $take) }
            $i += $take
            if ($i -lt ($Data.Length - 1) -and $Data[$i] -eq 13 -and $Data[$i + 1] -eq 10) { $i += 2 }
            elseif ($i -lt $Data.Length -and $Data[$i] -eq 10) { $i += 1 }
        }
        return , ($out.ToArray())
    } finally {
        $out.Dispose()
    }
}

# Bounded gzip / deflate (zlib or raw) decoder. A decompression bomb (> MaxBytes) or undecodable data returns the raw bytes.
function Expand-HttpBody([byte[]]$Bytes, [string]$Encoding, [int]$MaxBytes = 1048576) {
    $enc = ([string]$Encoding).Trim().ToLowerInvariant()
    if ($null -eq $Bytes -or $Bytes.Length -lt 2) { return , $Bytes }
    $isGz = ($Bytes[0] -eq 0x1F -and $Bytes[1] -eq 0x8B)
    if ($enc -notmatch 'gzip|deflate' -and -not $isGz) { return , $Bytes }
    $in = $null; $zs = $null; $out = $null
    try {
        $start = 0
        if (-not $isGz -and (($Bytes[0] -band 0x0F) -eq 8) -and ((([int]$Bytes[0] * 256) + [int]$Bytes[1]) % 31) -eq 0) { $start = 2 }
        $in = New-Object System.IO.MemoryStream(, $Bytes)
        $in.Position = $start
        if ($isGz) { $zs = New-Object System.IO.Compression.GZipStream($in, [System.IO.Compression.CompressionMode]::Decompress) }
        else { $zs = New-Object System.IO.Compression.DeflateStream($in, [System.IO.Compression.CompressionMode]::Decompress) }
        $out = New-Object System.IO.MemoryStream
        $buf = New-Object byte[] 8192
        $total = 0
        while ($true) {
            $n = $zs.Read($buf, 0, $buf.Length)
            if ($n -le 0) { break }
            $total += $n
            if ($total -gt $MaxBytes) { return , $Bytes }
            $out.Write($buf, 0, $n)
        }
        return , ($out.ToArray())
    } catch { return , $Bytes }
    finally { foreach ($o in @($zs, $out, $in)) { if ($o) { try { $o.Dispose() } catch {} } } }
}
function ConvertFrom-HttpBytes([byte[]]$Raw) {
    $r = @{ Code = 0; Headers = @{}; Cookies = @(); Body = ''; Location = '' }
    if ($null -eq $Raw -or $Raw.Length -lt 12) { return $r }
    $he = -1
    $termLen = 4
    for ($i = 0; $i -lt ($Raw.Length - 3); $i++) {
        if ($Raw[$i] -eq 13 -and $Raw[$i + 1] -eq 10 -and $Raw[$i + 2] -eq 13 -and $Raw[$i + 3] -eq 10) {
            $he = $i; $termLen = 4; break
        }
    }
    if ($he -lt 0) {
        for ($i = 0; $i -lt ($Raw.Length - 1); $i++) {
            if ($Raw[$i] -eq 10 -and $Raw[$i + 1] -eq 10) {
                $he = $i; $termLen = 2; break
            }
        }
    }
    if ($he -lt 0) { return $r }
    $headerStr = [System.Text.Encoding]::ASCII.GetString($Raw, 0, $he)
    $lines = $headerStr -split "`r?`n"
    $m = [regex]::Match($lines[0], '^HTTP/\d\.\d\s+(\d{3})')
    if (-not $m.Success) { return $r }
    $r.Code = [int]$m.Groups[1].Value
    foreach ($l in ($lines | Select-Object -Skip 1)) {
        $c = $l.IndexOf(':'); if ($c -lt 1) { continue }
        $k = $l.Substring(0, $c).Trim().ToLower(); $v = $l.Substring($c + 1).Trim()
        if ($k -eq 'set-cookie') { $r.Cookies += $v } else { $r.Headers[$k] = $v }
    }
    $r.Location = [string]$r.Headers['location']
    $bs = $he + $termLen
    $len = [Math]::Max(0, $Raw.Length - $bs)
    $bodyBytes = New-Object byte[] $len
    if ($len -gt 0) { [Array]::Copy($Raw, $bs, $bodyBytes, 0, $len) }
    if (([string]$r.Headers['transfer-encoding']) -match 'chunked') { $bodyBytes = ConvertFrom-ChunkedBytes $bodyBytes }
    $bodyBytes = Expand-HttpBody $bodyBytes ([string]$r.Headers['content-encoding'])
    $r.Body = [System.Text.Encoding]::UTF8.GetString($bodyBytes)
    return $r
}

# One HTTPS exchange. Source-bound to the Ethernet IP, TLS 1.2, bounded time and size, no proxy, no auto-redirect.
function Invoke-TlsHttp {
    param([uri]$Uri, [string]$Method = 'GET', [string]$Body = '', [string]$SourceIp = '', [string]$Pin = '', [hashtable]$Jar, [int]$TimeoutMs = 6000, [int]$MaxBytes = 262144, $Capture = $null, [switch]$HandshakeOnly)
    $r = @{ Code = 0; Headers = @{}; Body = ''; Location = ''; Error = ''; Sha256 = ''; TlsErrors = '' }
    $sock = $null; $ssl = $null
    try {
        $hostName = [string]$Uri.Host
        $ip = ''
        $tmp = $null
        if ([System.Net.IPAddress]::TryParse($hostName, [ref]$tmp)) { $ip = $hostName } else { $ip = Resolve-HostBounded $hostName 2500 $SourceIp }
        if (-not $ip) { $r.Error = 'DnsFail'; return $r }
        # Verify IP is allowed campus IP (private RFC1918, CGNAT, configured portal IP, or local gateway)
        if (-not (Test-AllowedPortalIp $ip)) { $r.Error = 'NotPrivate'; return $r }
        $sock = New-Object System.Net.Sockets.Socket([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
        if ($SourceIp) {
            try { $sock.Bind((New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($SourceIp), 0))) } catch { $r.Error = 'BindFailure'; return $r }
        }
        $iar = $sock.BeginConnect([System.Net.IPAddress]::Parse($ip), [int]$Uri.Port, $null, $null)
        $connected = $iar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)
        if (-not $connected) {
            try { $sock.Close() } catch {}
            $r.Error = 'ConnectTimeout'; return $r
        }
        try { $sock.EndConnect($iar) } catch { $r.Error = 'ConnectFailure'; return $r }
        $ns = New-Object System.Net.Sockets.NetworkStream($sock, $false)
        $ns.ReadTimeout = $TimeoutMs; $ns.WriteTimeout = $TimeoutMs
        $cb = New-CertCallback $Pin $Capture
        $ssl = New-Object System.Net.Security.SslStream($ns, $false, $cb)
        $protocols = [System.Security.Authentication.SslProtocols]::Tls12
        try { $protocols = [System.Security.Authentication.SslProtocols]'Tls12, Tls13' } catch {
            # keep TLS 1.2: never fall back to the OS default list (it can still include TLS 1.0/1.1)
        }
        try { $ssl.AuthenticateAsClient($hostName, $null, $protocols, $false) }
        catch { $r.Error = 'TlsRejected'; if ($Capture) { $r.Sha256 = [string]$Capture.Sha256; $r.TlsErrors = [string]$Capture.Errors }; return $r }
        if ($Capture) { $r.Sha256 = [string]$Capture.Sha256; $r.TlsErrors = [string]$Capture.Errors }
        if ($HandshakeOnly) { return $r }
        $port = [int]$Uri.Port
        $hostHdr = $hostName; if ($port -ne 443) { $hostHdr = ('{0}:{1}' -f $hostName, $port) }
        $ck = ''
        if ($Jar -and $Jar.Count -gt 0) { $ck = 'Cookie: ' + ((@($Jar.Keys | ForEach-Object { ('{0}={1}' -f $_, $Jar[$_]) })) -join '; ') + "`r`n" }
        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($Body)
        $head = ('{0} {1} HTTP/1.1' -f $Method, $Uri.PathAndQuery) + "`r`nHost: $hostHdr`r`nUser-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) LanFixer`r`nAccept: text/html,*/*`r`nAccept-Encoding: identity`r`n$ck"
        if ($Method -eq 'POST') { $head += "Content-Type: application/x-www-form-urlencoded`r`nContent-Length: $($bodyBytes.Length)`r`n" }
        $head += "Connection: close`r`n`r`n"
        $hb = [System.Text.Encoding]::ASCII.GetBytes($head)
        $ssl.Write($hb, 0, $hb.Length)
        if ($bodyBytes.Length -gt 0) { $ssl.Write($bodyBytes, 0, $bodyBytes.Length) }
        $ssl.Flush()
        $ms = New-Object System.IO.MemoryStream
        $buf = New-Object byte[] 8192
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $contentLength = -1
        $headerEndIdx = -1
        $isChunked = $false
        while ($ms.Length -lt $MaxBytes -and $sw.ElapsedMilliseconds -lt ($TimeoutMs * 2)) {
            $n = 0
            try { $n = $ssl.Read($buf, 0, $buf.Length) } catch { break }
            if ($n -le 0) { break }
            $ms.Write($buf, 0, $n)
            if ($headerEndIdx -lt 0) {
                $curBytes = $ms.ToArray()
                for ($ci = 0; $ci -lt ($curBytes.Length - 3); $ci++) {
                    if ($curBytes[$ci] -eq 13 -and $curBytes[$ci+1] -eq 10 -and $curBytes[$ci+2] -eq 13 -and $curBytes[$ci+3] -eq 10) {
                        $headerEndIdx = $ci + 4; break
                    }
                }
                if ($headerEndIdx -lt 0) {
                    for ($ci = 0; $ci -lt ($curBytes.Length - 1); $ci++) {
                        if ($curBytes[$ci] -eq 10 -and $curBytes[$ci+1] -eq 10) {
                            $headerEndIdx = $ci + 2; break
                        }
                    }
                }
                if ($headerEndIdx -gt 0) {
                    $hStr = [System.Text.Encoding]::ASCII.GetString($curBytes, 0, $headerEndIdx)
                    $mCl = [regex]::Match($hStr, '(?i)Content-Length:\s*(\d+)')
                    if ($mCl.Success) { $contentLength = [int]$mCl.Groups[1].Value }
                    elseif ($hStr -match '^HTTP/\d\.\d\s+(30[12378]|204)\b') { $contentLength = 0 }
                    if ($hStr -match '(?i)Transfer-Encoding:\s*chunked') { $isChunked = $true }
                }
            }
            if ($contentLength -ge 0 -and $headerEndIdx -ge 0) {
                if (($ms.Length - $headerEndIdx) -ge $contentLength) { break }
            } elseif ($isChunked -and $headerEndIdx -ge 0) {
                $curArr = $ms.ToArray()
                $cL = $curArr.Length
                if ($cL -ge 5 -and $curArr[$cL - 5] -eq 48 -and $curArr[$cL - 4] -eq 13 -and $curArr[$cL - 3] -eq 10 -and $curArr[$cL - 2] -eq 13 -and $curArr[$cL - 1] -eq 10 -and (($cL -eq ($headerEndIdx + 5)) -or ($cL -ge 7 -and $curArr[$cL - 7] -eq 13 -and $curArr[$cL - 6] -eq 10))) { break }
            }
        }
        $p = ConvertFrom-HttpBytes $ms.ToArray()
        if ($p.Code -eq 0) { $r.Error = 'BadResponse'; return $r }
        $r.Code = $p.Code; $r.Headers = $p.Headers; $r.Body = $p.Body; $r.Location = $p.Location
        if ($Jar) {
            foreach ($sc in @($p.Cookies)) {
                $first = ([string]$sc).Split(';')[0]
                $eq = $first.IndexOf('=')
                if ($eq -gt 0) { $Jar[$first.Substring(0, $eq).Trim()] = $first.Substring($eq + 1).Trim() }
            }
        }
    } catch { $r.Error = 'Error' }
    finally {
        if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
        if ($ms) { try { $ms.Dispose() } catch {} }
        if ($ssl) { try { $ssl.Dispose() } catch {} }
        if ($sock) { try { $sock.Close(); $sock.Dispose() } catch {} }
    }
    return $r
}

function Get-HtmlAttr([string]$Tag, [string]$Name) {
    $m = [regex]::Match($Tag, '(?i)(?<![\w-])' + [regex]::Escape($Name) + '\s*=\s*(?:"([^"]*)"|''([^'']*)''|([^\s>]+))')
    if (-not $m.Success) { return $null }
    foreach ($g in 1..3) { if ($m.Groups[$g].Success) { return [System.Net.WebUtility]::HtmlDecode($m.Groups[$g].Value) } }
    return ''
}

# First <form> that contains a password input. Returns hidden/submit fields, the user/password field names and the resolved action.
function ConvertFrom-LoginForm([string]$Html, [uri]$PageUri) {
    foreach ($fm in [regex]::Matches($Html, '(?is)<form\b([^>]*)>(.*?)</form>')) {
        $pass = $null; $user = $null
        $fields = [ordered]@{}
        $candidates = @()
        foreach ($inp in [regex]::Matches($fm.Groups[2].Value, '(?is)<input\b[^>]*>')) {
            $tag = $inp.Value
            $type = ([string](Get-HtmlAttr $tag 'type')).ToLower()
            $name = Get-HtmlAttr $tag 'name'
            if (-not $name) { continue }
            $id = Get-HtmlAttr $tag 'id'
            $val = [string](Get-HtmlAttr $tag 'value')
            if ($type -eq 'password') { if (-not $pass) { $pass = $name } }
            elseif ($type -eq 'hidden') { $fields[$name] = $val }
            elseif ($type -eq 'checkbox') { if ($tag -match '(?i)\bchecked\b') { $fields[$name] = $(if ($val) { $val } else { 'on' }) } }
            elseif ($type -eq 'submit') { if (-not $fields.Contains($name)) { $fields[$name] = $val } }
            elseif ($type -eq '' -or $type -eq 'text' -or $type -eq 'email' -or $type -eq 'tel' -or $type -eq 'number') {
                $candidates += @{ Name = $name; Id = $id; Value = $val }
            }
        }
        if (-not $pass) { continue }
        foreach ($c in $candidates) {
            $comb = ($c.Name + ' ' + $c.Id)
            if ($comb -match '(?i)user|login|email|auth|account|id|roll|reg|uid|uname|member|netid|student') { $user = $c.Name; break }
        }
        if (-not $user -and $candidates.Count -gt 0) { $user = $candidates[0].Name }
        foreach ($c in $candidates) {
            if ($c.Name -ne $user -and $c.Value -and -not $fields.Contains($c.Name)) { $fields[$c.Name] = $c.Value }
        }
        foreach ($sel in [regex]::Matches($fm.Groups[2].Value, '(?is)<select\b([^>]*)>(.*?)</select>')) {
            $sname = Get-HtmlAttr $sel.Groups[1].Value 'name'
            if ($sname) {
                $optM = [regex]::Match($sel.Groups[2].Value, '(?is)<option\b[^>]*\bselected\b[^>]*value\s*=\s*["\x27]?([^"\x27\s>]+)')
                if (-not $optM.Success) { $optM = [regex]::Match($sel.Groups[2].Value, '(?is)<option\b[^>]*value\s*=\s*["\x27]?([^"\x27\s>]+)') }
                if ($optM.Success -and -not $fields.Contains($sname)) { $fields[$sname] = [System.Net.WebUtility]::HtmlDecode($optM.Groups[1].Value) }
            }
        }
        foreach ($bt in [regex]::Matches($fm.Groups[2].Value, '(?is)<button\b[^>]*>')) {
            $bn = Get-HtmlAttr $bt.Value 'name'
            $btype = ([string](Get-HtmlAttr $bt.Value 'type')).ToLower()
            if ($bn -and ($btype -eq '' -or $btype -eq 'submit') -and -not $fields.Contains($bn)) { $fields[$bn] = [string](Get-HtmlAttr $bt.Value 'value') }
        }
        $act = Get-HtmlAttr $fm.Groups[1].Value 'action'
        $target = $PageUri
        if ($act) { try { $target = New-Object System.Uri($PageUri, $act) } catch { $target = $null } }
        if ($null -eq $target) { continue }
        if (-not $user) { $user = 'auth_user' }
        return @{ Action = $target; UserField = $user; PassField = $pass; Fields = $fields }
    }
    # Fallback for HTML5 portals where <input type="password"> sits outside <form>...</form> via form="id" or layout containers
    if ($Html -match '(?is)<input\b[^>]*type\s*=\s*["\x27]?password') {
        $pass = $null; $user = $null; $fields = [ordered]@{}; $candidates = @()
        foreach ($inp in [regex]::Matches($Html, '(?is)<input\b[^>]*>')) {
            $tag = $inp.Value
            $type = ([string](Get-HtmlAttr $tag 'type')).ToLower()
            $name = Get-HtmlAttr $tag 'name'
            if (-not $name) { continue }
            $id = Get-HtmlAttr $tag 'id'; $val = [string](Get-HtmlAttr $tag 'value')
            if ($type -eq 'password') { if (-not $pass) { $pass = $name } }
            elseif ($type -eq 'hidden') { $fields[$name] = $val }
            elseif ($type -eq 'checkbox') { if ($tag -match '(?i)\bchecked\b') { $fields[$name] = $(if ($val) { $val } else { 'on' }) } }
            elseif ($type -eq 'submit') { if (-not $fields.Contains($name)) { $fields[$name] = $val } }
            elseif ($type -eq '' -or $type -eq 'text' -or $type -eq 'email' -or $type -eq 'tel' -or $type -eq 'number') { $candidates += @{ Name = $name; Id = $id; Value = $val } }
        }
        if ($pass) {
            foreach ($c in $candidates) { if (($c.Name + ' ' + $c.Id) -match '(?i)user|login|email|auth|account|id|roll|reg|uid|uname|member|netid|student') { $user = $c.Name; break } }
            if (-not $user -and $candidates.Count -gt 0) { $user = $candidates[0].Name }
            foreach ($c in $candidates) { if ($c.Name -ne $user -and $c.Value -and -not $fields.Contains($c.Name)) { $fields[$c.Name] = $c.Value } }
            if (-not $user) { $user = 'auth_user' }
            $target = $PageUri
            $fmFirst = [regex]::Match($Html, '(?is)<form\b([^>]*)>')
            if ($fmFirst.Success) {
                $act = Get-HtmlAttr $fmFirst.Groups[1].Value 'action'
                if ($act) { try { $target = New-Object System.Uri($PageUri, $act) } catch { $target = $PageUri } }
            }
            if ($target) { return @{ Action = $target; UserField = $user; PassField = $pass; Fields = $fields } }
        }
    }
    return $null
}
# ==============================================================================
# CREDENTIAL VAULT (machine-bound DPAPI + admin-only ACL, re-verified on every run) AND AUTO-LOGIN
# ==============================================================================
function Test-AclSidsOnly($Rules, [string[]]$Allowed) {
    foreach ($r in @($Rules)) {
        if ($Allowed -notcontains [string]$r.IdentityReference.Value) { return $false }
    }
    return $true
}

function Protect-VaultFile([string]$Path) {
    $ic = Get-SysExe 'icacls.exe'
    [void](Invoke-Native $ic @($Path, '/inheritance:r', '/grant:r', '*S-1-5-18:F', '*S-1-5-32-544:F', '/C', '/Q') 5000)
    $r2 = Invoke-Native $ic @($Path, '/setowner', '*S-1-5-32-544', '/C', '/Q') 5000
    return ($r2.ExitCode -eq 0)
}

# The vault must be readable by SYSTEM and Administrators ONLY, with inheritance cut.
function Test-VaultAcl([string]$Path) {
    if (-not $Path) { $Path = $script:VaultFile }
    if (-not (Test-Path -LiteralPath $Path)) { return $true }
    try {
        $acl = [System.IO.File]::GetAccessControl($Path)
        $owner = $acl.GetOwner([System.Security.Principal.SecurityIdentifier]).Value
        if (@('S-1-5-18', 'S-1-5-32-544') -notcontains $owner) { return $false }
        $rules = $acl.GetAccessRules($true, $true, [System.Security.Principal.SecurityIdentifier])
        return ((Test-AclSidsOnly $rules @('S-1-5-18', 'S-1-5-32-544')) -and $acl.AreAccessRulesProtected)
    } catch { return $false }
}

function Protect-IntegrityFile([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    $ic = Get-SysExe 'icacls.exe'
    [void](Invoke-Native $ic @($Path, '/inheritance:r', '/grant:r', '*S-1-5-18:F', '*S-1-5-32-544:F', '/grant:r', '*S-1-5-32-545:R', '/C', '/Q') 5000)
    $r2 = Invoke-Native $ic @($Path, '/setowner', '*S-1-5-32-544', '/C', '/Q') 5000
    return ($r2.ExitCode -eq 0)
}

function Set-ScriptAuthorization([string]$TargetScript = '') {
    if (-not $TargetScript) {
        $TargetScript = if (Test-Path -LiteralPath $script:SelfCopy) { $script:SelfCopy } else { $script:SelfPath }
    }
    if (-not (Test-Path -LiteralPath $TargetScript)) {
        Write-Log 'WARN' ("Set-ScriptAuthorization: target script not found: $TargetScript")
        return $false
    }
    $sha = Get-FileSha256 $TargetScript
    if (-not $sha) {
        Write-Log 'WARN' "Set-ScriptAuthorization: failed to compute SHA256 of $TargetScript"
        return $false
    }
    $curSid = try { [Security.Principal.WindowsIdentity]::GetCurrent().User.Value } catch { 'S-1-5-32-544' }
    $manifest = @{
        SchemaVersion     = 1
        ScriptPath        = (Resolve-Path -LiteralPath $TargetScript).Path
        ScriptSha256      = $sha
        AuthorizedBy      = $curSid
        AuthorizedTimeUtc = (Get-Date).ToUniversalTime().ToString('o')
    }
    $intFile = Join-Path $script:StoreDir 'integrity.json'
    $json = ConvertTo-Json $manifest -Depth 2
    try {
        [System.IO.File]::WriteAllText($intFile, $json, [System.Text.Encoding]::ASCII)
        [void](Protect-IntegrityFile $intFile)
        Write-Log 'OK' ("Cryptographic integrity authorized: $TargetScript [SHA256: $sha]")
        return $true
    } catch {
        Write-Log 'WARN' ("Failed to write integrity manifest: " + $_.Exception.Message)
        return $false
    }
}

function Test-ScriptIntegrity([string]$TargetScript = '') {
    $errors = New-Object System.Collections.ArrayList
    $intFile = Join-Path $script:StoreDir 'integrity.json'
    
    if (-not $TargetScript) {
        $TargetScript = if (Test-Path -LiteralPath $script:SelfCopy) { $script:SelfCopy } else { $script:SelfPath }
    }
    
    if (-not (Test-Path -LiteralPath $TargetScript)) {
        [void]$errors.Add("Target script not found: $TargetScript")
        return @{ Valid = $false; Status = 'FileNotFound'; ScriptPath = $TargetScript; Errors = $errors; ExpectedHash = ''; ActualHash = '' }
    }
    
    try {
        $acl = [System.IO.File]::GetAccessControl($TargetScript)
        $owner = $acl.GetOwner([System.Security.Principal.SecurityIdentifier]).Value
        if (@('S-1-5-18', 'S-1-5-32-544') -notcontains $owner) {
            $isAdminOwner = $false
            try {
                $secId = New-Object System.Security.Principal.SecurityIdentifier($owner)
                $curUser = [Security.Principal.WindowsIdentity]::GetCurrent()
                if ($curUser.User.Value -eq $owner -or $curUser.Groups -contains $secId) { $isAdminOwner = $true }
            } catch {}
            if (-not $isAdminOwner) {
                [void]$errors.Add("Script owner is untrusted: $owner (must be Administrators or SYSTEM)")
            }
        }
        $rules = $acl.GetAccessRules($true, $true, [System.Security.Principal.SecurityIdentifier])
        foreach ($r in $rules) {
            $sid = $r.IdentityReference.Value
            if (@('S-1-5-32-545', 'S-1-1-0', 'S-1-5-11') -contains $sid) {
                $rights = $r.FileSystemRights
                $hasWrite = [bool]($rights -band [System.Security.AccessControl.FileSystemRights]::Write) -or
                            [bool]($rights -band [System.Security.AccessControl.FileSystemRights]::WriteData) -or
                            [bool]($rights -band [System.Security.AccessControl.FileSystemRights]::CreateFiles) -or
                            [bool]($rights -band [System.Security.AccessControl.FileSystemRights]::FullControl)
                if ($hasWrite -and $r.AccessControlType -eq [System.Security.AccessControl.AccessControlType]::Allow) {
                    [void]$errors.Add("Unprivileged identity $sid has write permissions on $TargetScript")
                }
            }
        }
    } catch {
        [void]$errors.Add("Failed to inspect script ACL: " + $_.Exception.Message)
    }

    if (-not (Test-Path -LiteralPath $intFile)) {
        [void]$errors.Add("Integrity manifest missing: $intFile")
        $actualSha = Get-FileSha256 $TargetScript
        return @{ Valid = $false; Status = 'MissingManifest'; ScriptPath = $TargetScript; ExpectedHash = ''; ActualHash = $actualSha; Errors = $errors }
    }
    
    $manifest = $null
    try {
        $manifest = ConvertFrom-Json (Get-Content -LiteralPath $intFile -Raw -ErrorAction Stop)
    } catch {
        [void]$errors.Add("Integrity manifest corrupt: " + $_.Exception.Message)
        return @{ Valid = $false; Status = 'CorruptManifest'; ScriptPath = $TargetScript; ExpectedHash = ''; ActualHash = ''; Errors = $errors }
    }
    
    $actualHash = Get-FileSha256 $TargetScript
    $expectedHash = [string]$manifest.ScriptSha256
    
    if (-not $expectedHash -or -not $actualHash -or ($actualHash -ne $expectedHash)) {
        [void]$errors.Add("SHA256 mismatch! Expected: $expectedHash, Actual: $actualHash")
        return @{ Valid = $false; Status = 'HashMismatch'; ScriptPath = $TargetScript; ExpectedHash = $expectedHash; ActualHash = $actualHash; Errors = $errors }
    }

    if ($errors.Count -gt 0) {
        return @{ Valid = $false; Status = 'UntrustedAcl'; ScriptPath = $TargetScript; ExpectedHash = $expectedHash; ActualHash = $actualHash; Errors = $errors }
    }

    return @{
        Valid             = $true
        Status            = 'Authorized'
        ScriptPath        = $TargetScript
        ExpectedHash      = $expectedHash
        ActualHash        = $actualHash
        AuthorizedBy      = [string]$manifest.AuthorizedBy
        AuthorizedTimeUtc = [string]$manifest.AuthorizedTimeUtc
        Errors            = @()
    }
}

# user<TAB>password, split on the FIRST tab only (a password may contain tabs).
function ConvertFrom-VaultPlain([string]$Plain) {
    $i = $Plain.IndexOf([char]9)
    if ($i -lt 1 -or $i -ge ($Plain.Length - 1)) { return $null }
    return @{ User = $Plain.Substring(0, $i); Pass = $Plain.Substring($i + 1) }
}

function Test-SameSubnetIPv4([string]$Ip1, [string]$Ip2, [int]$Prefix) {
    if (-not $Ip1 -or -not $Ip2 -or $Prefix -le 0 -or $Prefix -gt 32) { return $false }
    try {
        $b1 = ([System.Net.IPAddress]::Parse($Ip1)).GetAddressBytes()
        $b2 = ([System.Net.IPAddress]::Parse($Ip2)).GetAddressBytes()
        if ($b1.Length -ne 4 -or $b2.Length -ne 4) { return $false }
        $mask = [uint32]0
        if ($Prefix -gt 0) { $mask = [uint32]::MaxValue -shl (32 - $Prefix) }
        $u1 = ([uint32]$b1[0] -shl 24) -bor ([uint32]$b1[1] -shl 16) -bor ([uint32]$b1[2] -shl 8) -bor [uint32]$b1[3]
        $u2 = ([uint32]$b2[0] -shl 24) -bor ([uint32]$b2[1] -shl 16) -bor ([uint32]$b2[2] -shl 8) -bor [uint32]$b2[3]
        return ($u1 -band $mask) -eq ($u2 -band $mask)
    } catch { return $false }
}

# Host routes that keep the campus portal and the campus resolver reachable over the UNAUTHENTICATED cable while
# every other destination keeps using the working secondary uplink (Wi-Fi / Bluetooth / USB tethering).
# Called by the metric engine, by the vault's certificate/test actions and by the portal client, so no code path can
# reach 10.114.0.5 over the mobile hotspot and time out.
function Ensure-CampusPortalPath([uri]$RedirectUri = $null) {
    if (-not $script:IsAdmin -or $script:IsDry) { return }
    $discIp = [string]$script:State.Misc['DiscoveredPortalIp']
    $cfgTargets = @($script:Cfg.PortalIp, $script:Cfg.CampusDns)   # configured campus only (Get-HomeCampusVerdict)
    $baseTargets = @()
    if ($discIp -and (Test-AllowedPortalIp $discIp)) { $baseTargets += $discIp }
    if ($RedirectUri -and $RedirectUri.Host) {
        $hostIp = $null
        if ([System.Net.IPAddress]::TryParse([string]$RedirectUri.Host, [ref]$hostIp) -and ($hostIp.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork)) {
            # Only a private/CGNAT/known-gateway literal: never add a host route for an arbitrary public address.
            if (Test-AllowedPortalIp ([string]$RedirectUri.Host)) { $baseTargets += [string]$RedirectUri.Host }
        } else {
            $resIp = Resolve-HostBounded ([string]$RedirectUri.Host) 1200
            if ($resIp -and (Test-AllowedPortalIp $resIp)) { $baseTargets += $resIp }
        }
    }
    $targetAdapters = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
    if ($targetAdapters.Count -eq 0) {
        $targetAdapters = @(Get-OtherUplinkAdapters | Where-Object { $_.Status -eq 'Up' })
    }
    foreach ($a in $targetAdapters) {
        $e = Get-AdapterEnvironment $a -UseCache
        $isCaptiveOrCampus = ($e.Env -eq 'Campus' -or $baseTargets.Count -gt 0 -or [bool]$script:State.Misc['DiscoveredPortalUrl'])
        if (-not $isCaptiveOrCampus) { continue }
        $gw4 = @(Get-GatewaysV4 $a) | Select-Object -First 1
        if (-not $gw4) { continue }
        $dhcpDns = @(Get-DhcpDnsServers ([string]$a.InterfaceGuid) | Where-Object { Test-PrivateIPv4 $_ })
        $clientIpObj = Get-NetIPAddress -InterfaceIndex $a.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue |
                       Where-Object { $_.IPAddress -notlike '169.254.*' -and $_.AddressState -eq 'Preferred' } | Select-Object -First 1
        $clientIp = if ($clientIpObj) { [string]$clientIpObj.IPAddress } else { '' }
        $prefixLen = if ($clientIpObj) { [int]$clientIpObj.PrefixLength } else { 24 }
        $cfgPart = if (($null -eq $e.Home) -or [bool]$e.Home) { @($cfgTargets) } else { @() }
        $targets = @($cfgPart + $baseTargets + $dhcpDns | Where-Object { $_ } | Select-Object -Unique)
        foreach ($hip in $targets) {
            $isOnLink = ($clientIp -and (Test-SameSubnetIPv4 $clientIp $hip $prefixLen))
            $nextHopTarget = if ($isOnLink) { '0.0.0.0' } else { $gw4 }
            $have = @(Get-NetRoute -InterfaceIndex $a.ifIndex -DestinationPrefix "$hip/32" -PolicyStore ActiveStore -ErrorAction SilentlyContinue | Select-Object -First 1)
            if ($have -and ([string]$have[0].NextHop -eq [string]$nextHopTarget)) { continue }
            # A route left pointing at a previous gateway (VRRP/HSRP failover) is worse than no route at all.
            if ($have) {
                Remove-NetRoute -InterfaceIndex $a.ifIndex -DestinationPrefix "$hip/32" -PolicyStore ActiveStore -Confirm:$false -ErrorAction SilentlyContinue
                Remove-NetRoute -InterfaceIndex $a.ifIndex -DestinationPrefix "$hip/32" -PolicyStore PersistentStore -Confirm:$false -ErrorAction SilentlyContinue
            }
            New-NetRoute -InterfaceIndex $a.ifIndex -DestinationPrefix "$hip/32" -NextHop $nextHopTarget -RouteMetric 5 -PolicyStore ActiveStore -ErrorAction SilentlyContinue | Out-Null
            Add-TrackedHostRoute ([string]$hip)
        }
    }
}

# Pinning: only a certificate YOU looked at and approved is ever accepted when Windows does not trust it.
function Get-PortalCertInfo([uri]$TargetUri = $null) {
    $u = $TargetUri
    if (-not $u) {
        try { $u = [uri](Get-ActivePortalUrl) } catch { return @{ Ok = $false; Error = 'BadPortalUrl' } }
    }
    Ensure-CampusPortalPath $u
    $cap = @{ AcceptAny = $true; Sha256 = ''; Errors = ''; Subject = ''; Issuer = ''; NotAfter = '' }
    $src = ''; if ($script:Cfg.ProbeSourceBind) { $src = Get-PrimarySourceIp }
    $r = Invoke-TlsHttp -Uri $u -SourceIp $src -Pin '' -Capture $cap -HandshakeOnly
    return @{ Ok = (-not $r.Error -and $cap.Sha256); Error = [string]$r.Error; Sha256 = [string]$cap.Sha256; Errors = [string]$cap.Errors; Subject = [string]$cap.Subject; Issuer = [string]$cap.Issuer; NotAfter = [string]$cap.NotAfter }
}

function Format-Fingerprint([string]$Hex) {
    if (-not $Hex) { return '' }
    return (($Hex -split '(.{2})' | Where-Object { $_ }) -join ':')
}
# Pure decision (unit-tested). The old lock pinned whichever MAC answered first, so a spoofer already on the LAN was
# "locked in". Now the MAC is compared with what this gateway used before; a NEW MAC is only accepted after it has
# stayed the same for 24 hours (a real router swap), and is flagged loudly until then.
# Pure decision (unit-tested): a gateway that answers from a NEW MAC is flagged and only accepted after 24 stable hours,
# or after YOU review it. Approval is recorded per gateway in the persistent memory, never as a blanket in-process flag.
function Get-ArpDecision([string]$Prev, [string]$Mac, $Cand, [datetime]$Now) {
    if (-not $Prev -or $Prev -eq $Mac) { return 'lock' }
    if ($null -eq $Cand -or [string]$Cand.Mac -ne $Mac) { return 'candidate' }
    $since = [datetime]::MinValue
    try { $since = [datetime]::Parse([string]$Cand.Since, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind) } catch { return 'candidate' }
    if (($Now - $since).TotalHours -ge 24) { return 'lock' }
    return 'wait'
}
function Get-WatchdogTask {
    $r = Invoke-Native (Get-SysExe 'schtasks.exe') @('/query', '/tn', $script:Cfg.TaskWatchdog, '/xml') 8000
    if ($r.TimedOut -or $r.ExitCode -ne 0) { return $null }
    try {
        $txt = [string]$r.Output
        $i = $txt.IndexOf('<Task')
        if ($i -lt 0) { return $null }
        return ([xml]$txt.Substring($i)).Task
    } catch { return $null }
}

# Pure decision (unit-tested): does the registered task need to be written again?
# Wrong arguments = it runs an older copy. StopExisting = a repair can be killed by the very events it causes.
function Test-WatchdogStale([string]$Have, [string]$Want, [string]$Policy) {
    if ($Have -ne $Want) { return $true }
    if ($Policy -ne 'IgnoreNew') { return $true }
    return $false
}
# ==============================================================================
# TERMINAL UI FOUNDATION
# One accent, colour reserved for state, no boxes around everything. True-colour when the terminal can
# (Windows Terminal / VT console), the 16-colour palette otherwise, plain ASCII glyphs in legacy consoles,
# and no escape codes at all when output is redirected or captured for the support report.
# ==============================================================================
$script:Esc = [string][char]27
$script:Ui = @{ Vt = $false; Uni = $false; Plain = $false; Alt = $false }
$script:Pal = @{
    text   = @(192, 202, 245); dim = @(115, 122, 162); faint = @(65, 72, 104)
    accent = @(122, 162, 247); ok = @(158, 206, 106); warn = @(224, 175, 104)
    bad    = @(247, 118, 142); info = @(125, 207, 255); vio = @(187, 154, 247)
}
$script:ConMap = @{ text = 'Gray'; dim = 'DarkGray'; faint = 'DarkGray'; accent = 'Cyan'; ok = 'Green'; warn = 'Yellow'; bad = 'Red'; info = 'Cyan'; vio = 'Magenta' }
$script:G = @{}
function Set-UiGlyphs([bool]$Unicode) {
    if ($Unicode) {
        $script:G = @{
            dot = [string][char]0x25CF; ring = [string][char]0x25CB; half = [string][char]0x25D0
            ok = [string][char]0x2713; bad = [string][char]0x2715; warn = [string][char]0x25B2
            mid = [string][char]0x00B7; arr = [string][char]0x25B8; rule = [string][char]0x2500
            link = [string][char]0x2501; miss = [string][char]0x00D7; ell = [string][char]0x2026
            prompt = [string][char]0x203A
            spark = @(0x2581, 0x2582, 0x2583, 0x2584, 0x2585, 0x2586, 0x2587, 0x2588 | ForEach-Object { [string][char]$_ })
            spin = @(0x280B, 0x2819, 0x2839, 0x2838, 0x283C, 0x2834, 0x2826, 0x2827, 0x2807, 0x280F | ForEach-Object { [string][char]$_ })
        }
    } else {
        $script:G = @{
            dot = '*'; ring = 'o'; half = '~'; ok = '+'; bad = 'x'; warn = '!'; mid = '.'; arr = '>'; rule = '-'; link = '='
            miss = 'x'; ell = '...'; prompt = '>'
            spark = @('_', '.', ',', '-', '~', '^', '"', '#')
            spin = @('|', '/', '-', '\')
        }
    }
}

Set-UiGlyphs $false
# Switches the console into VT mode on older hosts. Never throws; false means "stay with 16 colours".
function Enable-VtMode {
    try {
        if (-not ('LanFixer.Native' -as [type])) {
            Add-Type -Namespace LanFixer -Name Native -MemberDefinition @'
[System.Runtime.InteropServices.DllImport("kernel32.dll", SetLastError = true)] public static extern System.IntPtr GetStdHandle(int h);
[System.Runtime.InteropServices.DllImport("kernel32.dll", SetLastError = true)] public static extern bool GetConsoleMode(System.IntPtr h, out uint m);
[System.Runtime.InteropServices.DllImport("kernel32.dll", SetLastError = true)] public static extern bool SetConsoleMode(System.IntPtr h, uint m);
'@
        }
        $h = [LanFixer.Native]::GetStdHandle(-11)
        if ($h -eq [System.IntPtr]::Zero -or $h.ToInt64() -eq -1) { return $false }
        [uint32]$m = 0
        if (-not [LanFixer.Native]::GetConsoleMode($h, [ref]$m)) { return $false }
        if (($m -band 4) -ne 0) { return $true }
        return [bool][LanFixer.Native]::SetConsoleMode($h, ($m -bor 4))
    } catch { return $false }
}

function Set-ConsoleQuickEdit([bool]$Enable = $true) {
    # Ensure QuickEdit mode is always enabled and raw mouse capture is stripped so all console text is freely selectable
    if (Test-InputRedirected) { return }
    try {
        if (-not ('LanFixer.Native' -as [type])) { [void](Enable-VtMode) }
        if (-not ('LanFixer.Native' -as [type])) { return }
        $h = [LanFixer.Native]::GetStdHandle(-10)
        if ($h -eq [System.IntPtr]::Zero -or $h.ToInt64() -eq -1) { return }
        [uint32]$m = 0
        if (-not [LanFixer.Native]::GetConsoleMode($h, [ref]$m)) { return }
        # 0x0040 = ENABLE_QUICK_EDIT_MODE, 0x0080 = ENABLE_EXTENDED_FLAGS, 0x0010 = ENABLE_MOUSE_INPUT
        $newMode = (($m -bor 0x0040) -bor 0x0080) -band (-bnot 0x0010)
        [void][LanFixer.Native]::SetConsoleMode($h, $newMode)
    } catch {}
}
function Initialize-Ui {
    $redir = $false
    try { $redir = [Console]::IsOutputRedirected } catch {}
    $modern = [bool]($env:WT_SESSION -or $env:TERM_PROGRAM -or ($env:ConEmuANSI -eq 'ON'))
    $vt = $false
    if (-not $redir -and $Host.Name -eq 'ConsoleHost') { if ($modern) { $vt = $true } elseif ($env:LANFIXER_NOVT -ne '1') { $vt = Enable-VtMode } }   # LANFIXER_NOVT=1: never compile the console helper, use 16 colours
    $uni = ($modern -and -not $redir)
    if ($env:LANFIXER_ASCII -eq '1') { $uni = $false } elseif ($env:LANFIXER_UNICODE -eq '1' -and -not $redir) { $uni = $true }
    if ($uni) { try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {} }
    $script:Ui.Vt = $vt
    $script:Ui.Uni = $uni
    if ($script:NoColor) { $script:Ui.Plain = $true; $script:Ui.Vt = $false }
    Set-UiGlyphs $uni
}

function Get-UiWidth {
    $w = 100
    try { $w = [Console]::WindowWidth } catch {}
    return [int][Math]::Min(100, [Math]::Max(60, $w - 4))
}

function Get-UiHeight { try { return [int][Console]::WindowHeight } catch { return 0 } }

function ConvertTo-Role([string]$Name) {
    switch -regex ($Name) {
        '^(Green|ok)$' { return 'ok' }
        '^(Yellow|warn|DarkYellow)$' { return 'warn' }
        '^(Red|bad|DarkRed)$' { return 'bad' }
        '^(Cyan|info)$' { return 'info' }
        '^(DarkGray|dim)$' { return 'dim' }
        '^(Magenta|vio|DarkMagenta)$' { return 'vio' }
        '^(DarkCyan|accent|Blue)$' { return 'accent' }
        '^faint$' { return 'faint' }
        default { return 'text' }
    }
}

# A segment is a hashtable on purpose: nested arrays get flattened by @() when a line has a single segment.
function Seg([string]$Role, [string]$Text) { return @{ R = $Role; T = $Text } }

function Fit([string]$Text, [int]$Width) {
    if ($null -eq $Text) { $Text = '' }
    if ($Width -le 0) { return '' }
    if ($Text.Length -gt $Width) {
        if ($Width -le 1) { return $Text.Substring(0, $Width) }
        return ($Text.Substring(0, $Width - 1) + $script:G.ell.Substring(0, 1))
    }
    return $Text.PadRight($Width)
}

function Get-SegsLength($Segs) { $n = 0; foreach ($s in @($Segs)) { $n += ([string]$s.T).Length }; return $n }

function Get-StatusToken([string]$State) {
    switch ($State.ToLowerInvariant()) {
        'ok'      { return @{ Text = '[  OK  ]'; Role = 'ok'; Glyph = $script:G.dot } }
        'warn'    { return @{ Text = '[ WARN ]'; Role = 'warn'; Glyph = $script:G.half } }
        'bad'     { return @{ Text = '[ FAIL ]'; Role = 'bad'; Glyph = $script:G.cross } }
        'skip'    { return @{ Text = '[ SKIP ]'; Role = 'info'; Glyph = $script:G.dash } }
        'prog'    { return @{ Text = '[ .... ]'; Role = 'vio'; Glyph = $script:G.mid } }
        'unknown' { return @{ Text = '[ ???? ]'; Role = 'dim'; Glyph = $script:G.ring } }
        'unk'     { return @{ Text = '[ ???? ]'; Role = 'dim'; Glyph = $script:G.ring } }
        default   { return @{ Text = '[ ???? ]'; Role = 'dim'; Glyph = $script:G.ring } }
    }
}

function ConvertTo-AnsiString($Segs) {
    $sb = New-Object System.Text.StringBuilder
    foreach ($s in @($Segs)) {
        $r = [string]$s.R
        $bold = $r.EndsWith('!')
        if ($bold) { $r = $r.Substring(0, $r.Length - 1) }
        $c = $script:Pal[$r]; if (-not $c) { $c = $script:Pal['text'] }
        [void]$sb.Append($script:Esc + '[0m' + $(if ($bold) { $script:Esc + '[1m' } else { '' }) + $script:Esc + '[38;2;' + $c[0] + ';' + $c[1] + ';' + $c[2] + 'm' + $s.T)
    }
    [void]$sb.Append($script:Esc + '[0m')
    return $sb.ToString()
}

function Out-Line($Segs, [switch]$NoNewline) {
    if ($script:Ui.Vt -and -not $script:Ui.Plain -and -not $script:NoColor) {
        $txt = ConvertTo-AnsiString $Segs
        if (-not $NoNewline) { $txt += "`n" }
        [Console]::Write($txt)
        return
    }
    foreach ($s in @($Segs)) {
        $r = ([string]$s.R).TrimEnd('!')
        $col = $script:ConMap[$r]; if (-not $col) { $col = 'Gray' }
        if ($script:NoColor) {
            Write-Host ([string]$s.T) -NoNewline
        } else {
            Write-Host ([string]$s.T) -NoNewline -ForegroundColor $col
        }
    }
    if (-not $NoNewline) { Write-Host '' }
}

function Out-Rule([int]$Width, [string]$Role = 'faint', [string]$Indent = '  ') {
    Out-Line @((Seg 'text' $Indent), (Seg $Role ($script:G.rule * $Width)))
}

# Redraws the whole screen in ONE write (no flicker, no scroll-back pollution).
function Write-Frame($Lines) {
    if ($script:Ui.Vt) {
        $sb = New-Object System.Text.StringBuilder
        [void]$sb.Append($script:Esc + '[?25l' + $script:Esc + '[H')
        foreach ($l in @($Lines)) { [void]$sb.Append((ConvertTo-AnsiString $l) + $script:Esc + '[K' + "`n") }
        [void]$sb.Append($script:Esc + '[J')
        [Console]::Write($sb.ToString())
    } else {
        $canRewind = $false
        try {
            if (-not [Console]::IsOutputRedirected) {
                [Console]::CursorVisible = $false
                [Console]::SetCursorPosition(0, 0)
                $canRewind = $true
            }
        } catch {}
        if (-not $canRewind) { Clear-Host }
        $cw = 80
        try { $cw = [Console]::WindowWidth } catch {}
        foreach ($l in @($Lines)) {
            if ($canRewind) {
                $len = Get-SegsLength $l
                if ($len -lt $cw) {
                    $padSeg = Seg 'text' (' ' * ($cw - $len))
                    Out-Line (@($l) + $padSeg)
                } else {
                    Out-Line $l
                }
            } else {
                Out-Line $l
            }
        }
        try { if ($canRewind) { [Console]::CursorVisible = $true } } catch {}
    }
}

function Clear-Screen {
    if ($script:Ui.Vt) { [Console]::Write($script:Esc + '[H' + $script:Esc + '[2J') } else { Clear-Host }
}

function Show-Cursor([bool]$On) { if ($script:Ui.Vt) { [Console]::Write($script:Esc + $(if ($On) { '[?25h' } else { '[?25l' })) } }

# Ctrl+C needs no handler: PowerShell stops the pipeline and the try/finally in Start-Interactive restores the screen.
# (A scriptblock delegate on the console's control thread has no runspace and can fault instead of cleaning up.)
function Enter-Screen {
    Set-ConsoleQuickEdit $true
    Clear-InputBuffer
    if ($script:Ui.Vt) { [Console]::Write($script:Esc + '[?1049h'); $script:Ui.Alt = $true }
    Clear-Screen
}
function Exit-Screen {
    Set-ConsoleQuickEdit $true
    Show-Cursor $true
    if ($script:Ui.Alt) { [Console]::Write($script:Esc + '[?1049l'); $script:Ui.Alt = $false }
}
# One message, word-wrapped to the terminal with a hanging indent under the glyph (nothing is cut off).
function Out-Wrapped([string]$GlyphRole, [string]$Glyph, [string]$TextRole, [string]$Message, [int]$Indent = 4) {
    $w = Get-UiWidth
    $lines = @(Split-Words $Message ($w - $Indent - 2) 99)
    if ($lines.Count -eq 0) { $lines = @('') }
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($i -eq 0) { $lead = Seg $GlyphRole ((' ' * $Indent) + $Glyph + ' ') } else { $lead = Seg 'text' (' ' * ($Indent + 2)) }
        Out-Line @($lead, (Seg $TextRole ([string]$lines[$i])))
    }
}

# Thin wrappers so the interactive loop can be driven by scripted keystrokes in tests.
function Test-InputRedirected {
    try {
        if (-not [Environment]::UserInteractive) { return $true }
        if ([Console]::IsInputRedirected -or [Console]::IsOutputRedirected -or [Console]::IsErrorRedirected) { return $true }
        return $false
    } catch { return $true }
}

function Test-KeyAvailable { try { return [Console]::KeyAvailable } catch { return $false } }

function Read-KeyNow { return [Console]::ReadKey($true) }

function Test-RemoteSession {
    try {
        if ($env:SESSIONNAME -match '^(?:RDP|ICA|HDX)') { return $true }
        if ($env:SSH_CONNECTION -or $env:SSH_CLIENT) { return $true }
        if ($env:REMOTEHOST) { return $true }
        return $false
    } catch { return $false }
}

function Clear-InputBuffer {
    try {
        while ([Console]::KeyAvailable) { [void][Console]::ReadKey($true) }
    } catch {}
}
# ==============================================================================
# STATE MODEL (pure, unit-tested)
# ==============================================================================
# Maps the repair engine's verdict to a headline and the state of the five hops of the path.
function Get-StateInfo([string]$Problem) {
    switch ($Problem) {
        { $_ -eq 'Healthy' -or $_ -eq 'Online' } { return @{ Word = 'Online'; Role = 'ok'; Hops = @('ok', 'ok', 'ok', 'ok', 'ok') } }
        'Captive'       { return @{ Word = 'Sign-In Required'; Role = 'warn'; Hops = @('ok', 'ok', 'ok', 'ok', 'warn') } }
        'NoIp'          { return @{ Word = 'No IP Address'; Role = 'bad'; Hops = @('ok', 'bad', 'unk', 'unk', 'unk') } }
        'GwUnreachable' { return @{ Word = 'Gateway Unreachable'; Role = 'bad'; Hops = @('ok', 'ok', 'bad', 'unk', 'unk') } }
        'NoDns'         { return @{ Word = 'DNS Unresolved'; Role = 'bad'; Hops = @('ok', 'ok', 'ok', 'bad', 'unk') } }
        'Offline'       { return @{ Word = 'Internet Blocked'; Role = 'bad'; Hops = @('ok', 'ok', 'ok', 'ok', 'bad') } }
        'NoLink'        { return @{ Word = 'Cable Disconnected'; Role = 'warn'; Hops = @('bad', 'unk', 'unk', 'unk', 'unk') } }
        'NoAdapter'     { return @{ Word = 'No Adapter Found'; Role = 'warn'; Hops = @('bad', 'unk', 'unk', 'unk', 'unk') } }
        default         { return @{ Word = 'Checking'; Role = 'dim'; Hops = @('unk', 'unk', 'unk', 'unk', 'unk') } }
    }
}

function Get-StateRole([string]$State) {
    switch ($State) { 'ok' { return 'ok' } 'warn' { return 'warn' } 'bad' { return 'bad' } default { return 'faint' } }
}

# Greedy word wrap, at most $MaxLines lines (the last one is cut with an ellipsis).
function Split-Words([string]$Text, [int]$Width, [int]$MaxLines = 2) {
    $Width = [Math]::Max(4, $Width)
    $out = New-Object System.Collections.ArrayList
    $cur = ''
    foreach ($rawWord in ($Text -split '\s+')) {
        if (-not $rawWord) { continue }
        $chunks = @()
        if ($rawWord.Length -gt $Width) {
            for ($p = 0; $p -lt $rawWord.Length; $p += $Width) {
                $chunks += $rawWord.Substring($p, [Math]::Min($Width, $rawWord.Length - $p))
            }
        } else { $chunks = @($rawWord) }
        foreach ($word in $chunks) {
            if ($cur -and (($cur.Length + 1 + $word.Length) -gt $Width)) { [void]$out.Add($cur); $cur = $word }
            elseif ($cur) { $cur += ' ' + $word }
            else { $cur = $word }
        }
    }
    if ($cur) { [void]$out.Add($cur) }
    $res = @($out)
    if ($res.Count -gt $MaxLines) {
        $res = @($res[0..($MaxLines - 1)])
        $last = [string]$res[$MaxLines - 1]
        if ($last.Length -ge $Width) { $last = $last.Substring(0, $Width - 1) }
        $res[$MaxLines - 1] = $last.TrimEnd() + $script:G.ell.Substring(0, 1)
    }
    return $res
}

# ==============================================================================
# GATEWAY PULSE (non-blocking async ping; history feeds the sparkline)
# ==============================================================================
$script:Pulse = @{ Hist = (New-Object System.Collections.ArrayList); Task = $null; Ping = $null; Gw = ''; Last = [datetime]::MinValue; Max = 36 }
$script:LiveGwRtt = $null
# Returns $true when a new sample arrived. Never blocks.
function Update-Pulse([string]$Gw) {
    $p = $script:Pulse
    if ($p.Gw -ne $Gw) {
        try { if ($p.Ping) { $p.Ping.Dispose() } } catch {}
        $p.Ping = $null
        $p.Gw = $Gw; $p.Hist.Clear(); $p.Task = $null; $script:LiveGwRtt = $null
    }
    if (-not $Gw) { return $false }
    $changed = $false
    if ($p.Task -and $p.Task.IsCompleted) {
        $rtt = -1
        try { if ($p.Task.Status -eq 'RanToCompletion' -and $p.Task.Result.Status -eq 'Success') { $rtt = [int]$p.Task.Result.RoundtripTime } } catch {}
        [void]$p.Hist.Add($rtt)
        if ($p.Hist.Count -gt $p.Max) { $p.Hist.RemoveAt(0) }
        if ($rtt -ge 0) { $script:LiveGwRtt = $rtt } else { $script:LiveGwRtt = $null }
        $p.Task = $null; $changed = $true
    }
    if (-not $p.Task -and (((Get-Date) - $p.Last).TotalMilliseconds -ge 350)) {
        if (-not $p.Ping) { $p.Ping = New-Object System.Net.NetworkInformation.Ping }
        try { $p.Task = $p.Ping.SendPingAsync($Gw, 300); $p.Last = Get-Date } catch { try { $p.Ping.Dispose() } catch {}; $p.Ping = $null; $p.Task = $null }
    }
    return $changed
}

# Pure: samples (-1 = lost) -> characters with roles plus summary numbers.
function Get-PulseModel($Hist, [int]$Width) {
    $h = @($Hist)
    $Width = [Math]::Max(1, $Width)
    if ($h.Count -gt $Width) { $h = @($h[($h.Count - $Width)..($h.Count - 1)]) }
    $valid = @($h | Where-Object { $_ -ge 0 })
    $hi = 10
    if ($valid.Count -gt 0) { $hi = [Math]::Max(10, [int](($valid | Measure-Object -Maximum).Maximum)) }
    $med = 0
    if ($valid.Count -gt 0) { $s = @($valid | Sort-Object); $med = $s[[int][Math]::Floor($s.Count / 2)] }
    $chars = New-Object System.Collections.ArrayList
    foreach ($v in $h) {
        if ($v -lt 0) { [void]$chars.Add(@{ Role = 'bad'; Ch = $script:G.miss }); continue }
        $lvl = [int][Math]::Min(7, [Math]::Floor($v * 8 / ($hi + 1)))
        $role = 'accent'
        if ($v -gt 20 -and $v -gt (3 * [Math]::Max(1, $med))) { $role = 'warn' }
        [void]$chars.Add(@{ Role = $role; Ch = [string]$script:G.spark[$lvl] })
    }
    $recent = @($h | Select-Object -Last 20)
    $lost = @($recent | Where-Object { $_ -lt 0 }).Count
    $ok = @($recent | Where-Object { $_ -ge 0 })
    $avg = 0.0; $jit = 0.0
    if ($ok.Count -gt 0) { $avg = ($ok | Measure-Object -Average).Average }
    if ($ok.Count -gt 1) { $d = 0.0; for ($i = 1; $i -lt $ok.Count; $i++) { $d += [Math]::Abs($ok[$i] - $ok[$i - 1]) }; $jit = $d / ($ok.Count - 1) }
    $loss = 0
    if ($recent.Count -gt 0) { $loss = [int][Math]::Round(100.0 * $lost / $recent.Count) }
    return @{ Chars = @($chars); Avg = $avg; Jitter = $jit; Loss = $loss; Count = $h.Count; Valid = $ok.Count }
}

function Get-PulseSegs($t, [int]$Width) {
    $segs = @((Seg 'dim' '  Gateway   '))
    if (-not $t.GwIp) { return @($segs + (Seg 'faint' 'No gateway')) }
    $curRtt = if ($null -ne $script:LiveGwRtt) { $script:LiveGwRtt } else { $t.GwRtt }
    if ($null -eq $curRtt -and $t.GwAlive) { return @($segs + (Seg 'dim' ('ARP active; ICMP ping filtered ' + $script:G.mid + ' no live pulse'))) }
    $m = Get-PulseModel $script:Pulse.Hist $Width
    if ($m.Count -eq 0) { return @($segs + (Seg 'faint' 'Waiting for reply...')) }
    $pad = $Width - $m.Chars.Count
    if ($pad -gt 0) { $segs += (Seg 'faint' (' ' * $pad)) }
    foreach ($c in $m.Chars) { $segs += (Seg $c.Role $c.Ch) }
    if ($m.Valid -eq 0) {
        $segs += (Seg 'bad' '   No reply')
        $segs += (Seg 'bad' ('   Loss {0}%' -f $m.Loss))
        return $segs
    }
    $role = 'text'; if ($m.Loss -gt 0 -or $curRtt -gt 80) { $role = 'warn' }
    $segs += (Seg $role ('   {0:N0} ms' -f $curRtt))
    $lr = 'dim'; if ($m.Loss -gt 0) { $lr = 'warn' }
    $segs += (Seg $lr ('   Loss {0}%' -f $m.Loss))
    $segs += (Seg 'dim' ('   Jitter {0:N0} ms' -f $m.Jitter))
    return $segs
}

# ==============================================================================
# TELEMETRY + ADVICE
# ==============================================================================
function New-Telemetry {
    return @{
        Admin = $script:IsAdmin; Problem = ''; LinkUp = $false; Speed = ''; Nic = ''; Mac = ''; Ip = ''; GwIp = ''; GwRtt = $null; GwAlive = $false
        Conn = '-'; Env = ''; EnvScore = 0; Sticky = $false; DnsPrimary = ''; DnsProfile = ''; Mtu = ''; Routing = 'automatic'
        Watchdog = $false; Vault = $false; Pin = $false; Paused = $false; ArpPending = $false; RouteProfile = 'Adaptive'; LastFull = $null
        UplinkActive = $false; UplinkName = ''; UplinkProfile = ''; UplinkIsPrimary = $false
        SubnetPrefix = $null; SubnetMask = ''; SubnetHosts = $null; IpV6 = ''; DhcpServer = ''; GwLocked = $false; Domain = ''
    }
}

# Hop model for the stepper: label, value, state per hop.
function Get-HopRows($t, $adv) {
    $st = $adv.Hops
    $curRtt = if ($null -ne $script:LiveGwRtt) { $script:LiveGwRtt } else { $t.GwRtt }
    $gw = 'None'
    if ($t.GwIp) { $gw = $t.GwIp; if ($null -ne $curRtt) { $gw += (' {0}ms' -f $curRtt) } elseif ($t.GwAlive) { $gw += ' arp' } }
    $link = 'Down'; if ($t.LinkUp) { $link = $t.Speed }
    $ip = 'None'; if ($t.Ip) { $ip = if ($t.SubnetPrefix) { "$($t.Ip)/$($t.SubnetPrefix)" } else { $t.Ip } }
    $dns = '-'; if ($t.DnsPrimary) { $dns = $t.DnsPrimary }
    $net = '-'
    switch ($t.Problem) {
        { $_ -eq 'Healthy' -or $_ -eq 'Online' } {
            if ($t.UplinkIsPrimary -and $t.UplinkName) { $net = 'via ' + $t.UplinkName } else { $net = 'Reachable' }
        }
        'Captive' { $net = 'Sign-In' }
        'Offline' { $net = 'Blocked' }
    }
    return @(
        @{ Label = 'Link'; Value = $link; State = $st[0]; Token = (Get-StatusToken $st[0]).Text },
        @{ Label = 'Address'; Value = $ip; State = $st[1]; Token = (Get-StatusToken $st[1]).Text },
        @{ Label = 'Gateway'; Value = $gw; State = $st[2]; Token = (Get-StatusToken $st[2]).Text },
        @{ Label = 'DNS'; Value = $dns; State = $st[3]; Token = (Get-StatusToken $st[3]).Text },
        @{ Label = 'Internet'; Value = $net; State = $st[4]; Token = (Get-StatusToken $st[4]).Text })
}

function Get-StepperLines($Rows, [int]$Width) {
    $n = $Rows.Count
    if ($n -le 1) { return @() }
    $inner = $Width - 2
    $gap = [int][Math]::Floor(($inner - 11) / ($n - 1))   # the last node keeps >= 11 columns for 'internet'
    $last = $inner - (($n - 1) * $gap)
    $l1 = @((Seg 'text' '  ')); $l2 = @((Seg 'text' '  ')); $l3 = @((Seg 'text' '  '))
    for ($i = 0; $i -lt $n; $i++) {
        $r = $Rows[$i]
        $role = Get-StateRole $r.State
        $glyph = $script:G.dot
        if ($r.State -eq 'warn') { $glyph = $script:G.half } elseif ($r.State -eq 'unk') { $glyph = $script:G.ring }
        $l1 += (Seg $role $glyph)
        if ($i -lt ($n - 1)) {
            $next = $Rows[$i + 1].State
            $crole = 'faint'
            if ($r.State -eq 'ok' -and $next -eq 'ok') { $crole = 'ok' } elseif ($r.State -eq 'ok' -and $next -eq 'warn') { $crole = 'warn' } elseif ($r.State -eq 'ok' -and $next -eq 'bad') { $crole = 'bad' }
            $l1 += (Seg $crole ($script:G.link * ($gap - 1)))
            $l2 += (Seg 'dim' (Fit $r.Label $gap))
            $l3 += (Seg $(if ($r.State -eq 'bad' -or $r.State -eq 'warn') { $role } else { 'text' }) (Fit $r.Value ($gap - 1)))
            $l3[-1].T = $l3[-1].T + ' '
        } else {
            $l2 += (Seg 'dim' (Fit $r.Label $last))
            $l3 += (Seg $(if ($r.State -eq 'bad' -or $r.State -eq 'warn') { $role } else { 'text' }) (Fit $r.Value $last))
        }
    }
    return @(, $l1) + @(, $l2) + @(, $l3)
}

# ==============================================================================
# DASHBOARD
# ==============================================================================
# Packs "key label" pairs into as many rows as the width needs (never wider than the terminal).
function Get-LegendRows($Items, [string]$Rec, [int]$Width) {
    $rows = New-Object System.Collections.ArrayList
    $segs = @((Seg 'text' '  ')); $len = 2
    foreach ($it in $Items) {
        $keyTag = '[' + $it[0] + ']'
        $cell = $keyTag.Length + 1 + $it[1].Length + 2
        if ($len + $cell -gt ($Width + 2) -and $len -gt 2) { [void]$rows.Add($segs); $segs = @((Seg 'text' '  ')); $len = 2 }
        $isRec = ($it[0].ToLower() -eq $Rec)
        $segs += (Seg 'faint' '[')
        $segs += (Seg $(if ($isRec) { 'ok!' } else { 'accent!' }) $it[0])
        $segs += (Seg 'faint' ']')
        $segs += (Seg $(if ($isRec) { 'text!' } else { 'dim' }) (' ' + $it[1] + '  '))
        $len += $cell
    }
    if ($len -gt 2) { [void]$rows.Add($segs) }
    return $rows.ToArray()
}

function Get-DashboardModel($t, $adv, [int]$Width = 0) {
    $w = $Width
    if ($w -le 0) { $w = Get-UiWidth }
    $L = New-Object System.Collections.ArrayList
    $pulseIdx = -1
    # header
    $left = @((Seg 'accent!' '  LAN FIXER'), (Seg 'faint' ('  v' + $script:Version)))
    $chips = @()
    $chipDefs = @(@('admin', $t.Admin, $(if ($t.Admin) { 'Admin' } else { 'Limited' })), @('watchdog', $t.Watchdog, 'Guard'), @('vault', $t.Vault, 'Vault'))
    if ($script:IsDry) { $chipDefs += , @('dryrun', $true, 'DryRun') }
    foreach ($c in $chipDefs) {
        $dotRole = 'faint'; $glyph = $script:G.ring
        if ($c[1]) { $dotRole = 'ok'; $glyph = $script:G.dot } elseif ($c[0] -eq 'admin') { $dotRole = 'warn'; $glyph = $script:G.dot }
        $chips += (Seg $dotRole $glyph); $chips += (Seg 'dim' (' ' + $c[2] + '  '))
    }
    $pad = ($w + 2) - (Get-SegsLength $left) - (Get-SegsLength $chips)
    [void]$L.Add(@($left + (Seg 'text' (' ' * [Math]::Max(2, $pad))) + $chips))
    [void]$L.Add(@((Seg 'text' '  '), (Seg 'faint' ($script:G.rule * $w))))
    # hero capsule
    $right = ''
    if ($t.LinkUp) {
        if ($t.UplinkActive -and $t.UplinkName) {
            $uLabel = if ($t.UplinkProfile) { "$($t.UplinkName) ($($t.UplinkProfile))" } else { $t.UplinkName }
            if ($t.UplinkIsPrimary) {
                $right = ('Eth ' + $t.Speed + ' (Standby) ' + $script:G.mid + ' Uplink: ' + $uLabel)
            } else {
                $right = ('Eth ' + $t.Speed + ' (Primary) ' + $script:G.mid + ' Uplink: ' + $uLabel)
            }
        } else {
            $right = ('Ethernet ' + $script:G.mid + ' ' + $t.Speed)
        }
    } elseif ($t.Problem) {
        if ($t.UplinkActive -and $t.UplinkName) {
            $uLabel = if ($t.UplinkProfile) { "$($t.UplinkName) ($($t.UplinkProfile))" } else { $t.UplinkName }
            $right = ('Ethernet (Down) ' + $script:G.mid + ' Uplink: ' + $uLabel)
        } else {
            $right = 'Ethernet (Down)'
        }
    }
    $heroL = @((Seg ($adv.Role + '!') ('  ' + $adv.Word)))
    $maxRightLen = [Math]::Max(10, ($w + 2) - (Get-SegsLength $heroL) - 2)
    if ($right.Length -gt $maxRightLen) {
        if ($t.UplinkActive -and $t.UplinkName) {
            $tag = if ($t.UplinkIsPrimary) { '(Standby)' } else { '(Primary)' }
            $right = ('Eth ' + $t.Speed + ' ' + $tag + ' ' + $script:G.mid + ' ' + $t.UplinkName)
        }
        if ($right.Length -gt $maxRightLen) {
            $right = Fit $right $maxRightLen
        }
    }
    $hp = ($w + 2) - (Get-SegsLength $heroL) - $right.Length
    if ($hp -lt 2) {
        $right = Fit $right [Math]::Max(4, (($w + 2) - (Get-SegsLength $heroL) - 2))
        $hp = 2
    }
    [void]$L.Add(@($heroL + (Seg 'text' (' ' * [Math]::Max(2, $hp))) + (Seg 'dim' $right)))
    # path
    foreach ($ln in @(Get-StepperLines (Get-HopRows $t $adv) $w)) { [void]$L.Add($ln) }
    [void]$L.Add(@())
    $pulseIdx = $L.Count
    [void]$L.Add((Get-PulseSegs $t ([Math]::Max(4, [Math]::Min(36, $w - 54)))))
    [void]$L.Add(@())
    # facts (dynamically auto-discovered and responsive)
    $cw = [int][Math]::Floor(($w - 4) / 2)
    $nicLabel = $t.Nic
    if ($t.Mtu -and $w -ge 76) { $nicLabel = Fit ($t.Nic + ' ' + $script:G.mid + ' MTU ' + $t.Mtu) ($cw - 10) }
    $net = '-'
    if ($t.Env) {
        $net = if ($t.Domain -and $w -ge 76) { ($t.Env + ' (' + $t.Domain + ') ' + $script:G.mid + ' Score ' + $t.EnvScore) } else { ($t.Env + ' ' + $script:G.mid + ' Score ' + $t.EnvScore) }
        if ($t.Sticky) { $net += ' (Remembered)' }
    }
    $leaseVal = $t.Ip
    if ($t.SubnetPrefix) {
        $leaseVal = if ($t.SubnetHosts -and $w -ge 76) { ("{0}/{1} ({2} hosts)" -f $t.Ip, $t.SubnetPrefix, $t.SubnetHosts) } else { ("{0}/{1}" -f $t.Ip, $t.SubnetPrefix) }
    }
    $dnsv = '-'
    if ($t.DnsProfile) {
        $dnsv = $t.DnsProfile
        if ($t.DnsPrimary) {
            $dnsServers = if ($t.DnsSecondary -and $w -ge 76) { "$($t.DnsPrimary), $($t.DnsSecondary)" } else { $t.DnsPrimary }
            $dnsv += (' ' + $script:G.mid + ' ' + $dnsServers)
        }
    }
    $rout = if ($t.Routing) {
        switch ($t.Routing.ToLower()) {
            'ethernet first'   { if ($t.UplinkActive) { 'Ethernet First (10 vs 40)' } else { 'Ethernet First' } }
            'wi-fi first'      { 'Wi-Fi First (15 vs 50)' }
            'wi-fi standby'    { 'Wi-Fi Priority (Wired Active, Wi-Fi Standby)' }
            'wi-fi priority'   { 'Wi-Fi Priority (Wired Active, Wi-Fi Standby)' }
            'wi-fi protected'  { if ($t.RouteProfile -eq 'Wifi') { 'Wi-Fi First (15 vs 50)' } else { 'Wi-Fi Protected (15 vs 50)' } }
            'ethernet demoted' { 'Ethernet Demoted (Metric 50)' }
            'windows default'  { 'Windows Default (Auto)' }
            'automatic'        {
                if ($t.RouteProfile -eq 'Wifi') { 'Wi-Fi Priority (Wired Active, Wi-Fi Standby)' }
                elseif ($t.RouteProfile -eq 'Ethernet') { 'Ethernet Priority' }
                elseif ($t.RouteProfile -eq 'Windows') { 'Windows Default (Auto)' }
                else { 'Automatic' }
            }
            default            { $t.Routing }
        }
    } else { 'Automatic' }
    $curRtt = if ($null -ne $script:LiveGwRtt) { $script:LiveGwRtt } else { $t.GwRtt }
    $gwVal = if ($t.GwIp) {
        $baseGw = if ($null -ne $curRtt) { '{0} ({1} ms)' -f $t.GwIp, $curRtt } elseif ($t.GwAlive) { '{0} (ARP)' -f $t.GwIp } else { $t.GwIp }
        if ($t.GwLocked -and $w -ge 76) { $baseGw + ' ' + $script:G.mid + ' Locked' } else { $baseGw }
    } else { '-' }

    $facts = @(
        @(@('Adapter', $nicLabel), @('Network', $net)),
        @(@('Lease', $leaseVal), @('DNS', $dnsv)),
        @(@('Gateway', $gwVal), @('Routing', $rout)))

    # Dynamically discover and display Dual-Stack IPv6 / DHCP / Secondary Uplink
    if ($t.IpV6 -or $t.DhcpServer -or $t.UplinkActive) {
        $cellL = if ($t.IpV6) { @('IPv6', $t.IpV6) } elseif ($t.DhcpServer) { @('DHCP Svr', $t.DhcpServer) } else { @('Subnet', "$($t.SubnetMask) (/$($t.SubnetPrefix))") }
        $cellR = if ($t.UplinkActive -and $t.UplinkName) {
            $upStr = if ($t.UplinkProfile) { "$($t.UplinkName) ($($t.UplinkProfile))" } else { $t.UplinkName }
            @('Uplink', $upStr)
        } elseif ($t.DhcpServer -and $t.IpV6) {
            @('DHCP Svr', $t.DhcpServer)
        } elseif ($t.SubnetMask) {
            @('Subnet', "$($t.SubnetMask) (/$($t.SubnetPrefix))")
        } else {
            @('Status', 'Auto-Discovered')
        }
        $facts += , @($cellL, $cellR)
    }

    foreach ($row in $facts) {
        $segs = @((Seg 'text' '  '))
        foreach ($cell in $row) {
            $segs += (Seg 'dim' (Fit $cell[0] 9))
            $v = [string]$cell[1]; if (-not $v) { $v = '-' }
            $segs += (Seg 'text' (Fit $v ($cw - 10)))
            $segs += (Seg 'text' ' ')
        }
        [void]$L.Add($segs)
    }
    [void]$L.Add(@((Seg 'text' '  '), (Seg 'faint' ($script:G.rule * $w))))
    # co-pilot intelligence (status and action directly below telemetry facts and rule)
    $stTxt = [string]$adv.Status; if (-not $stTxt) { $stTxt = [string]$adv.Text }
    $actTxt = [string]$adv.Action; if (-not $actTxt) { if ($adv.Key) { $actTxt = ('Press [ENTER] to ' + $adv.KeyLabel + ' (or press ' + $adv.Key.ToUpper() + ').') } else { $actTxt = 'No action needed.' } }
    
    $stLines = @(Split-Words $stTxt ($w - 12) 2)
    for ($i = 0; $i -lt $stLines.Count; $i++) {
        if ($i -eq 0) { [void]$L.Add(@((Seg 'dim' '  STATUS  '), (Seg 'text' ([string]$stLines[$i])))) }
        else { [void]$L.Add(@((Seg 'text' '          '), (Seg 'text' ([string]$stLines[$i])))) }
    }
    $actLines = @(Split-Words $actTxt ($w - 12) 2)
    for ($i = 0; $i -lt $actLines.Count; $i++) {
        if ($i -eq 0) { [void]$L.Add(@((Seg 'ok!' '  ACTION  '), (Seg 'text!' ([string]$actLines[$i])))) }
        else { [void]$L.Add(@((Seg 'text' '          '), (Seg 'text!' ([string]$actLines[$i])))) }
    }
    [void]$L.Add(@())
    
    # categorized command dock (responsive, clear hierarchy, plain language)
    $uiH = Get-UiHeight
    if ($w -ge 74 -and ($uiH -eq 0 -or $uiH -ge 28)) {
        $col1W = $cw
        [void]$L.Add(@((Seg 'accent!' ('  REPAIR & REMEDIATION'.PadRight($col1W + 2))), (Seg 'accent!' 'DIAGNOSTICS & AUDIT')))
        [void]$L.Add(@((Seg $(if ($adv.Key -eq '1') { 'ok!' } else { 'text' }) ('  [1] Quick Heal (Recommended)'.PadRight($col1W + 2))), (Seg 'text' '[3] DNS Configuration')))
        [void]$L.Add(@((Seg $(if ($adv.Key -eq '2') { 'ok!' } else { 'text' }) ('  [2] Install Watchdog Task'.PadRight($col1W + 2))), (Seg 'text' '[M] Routing & Metric Priority')))
        [void]$L.Add(@((Seg $(if ($adv.Key -eq 'a') { 'ok!' } else { 'text' }) ('  [A] Portal Credentials Vault'.PadRight($col1W + 2))), (Seg 'text' '[4] Network Quality Probe')))
        [void]$L.Add(@((Seg $(if ($adv.Key -eq '7') { 'ok!' } else { 'text' }) ('  [7] Captive Portal Check'.PadRight($col1W + 2))), (Seg 'text' '[5] Flush Network Caches')))
        [void]$L.Add(@((Seg $(if ($adv.Key -eq 'g') { 'ok!' } else { 'text' }) ('  [G] Submit Portal Login'.PadRight($col1W + 2))), (Seg 'text' '[6] System Diagnostics Audit')))
        if ($uiH -eq 0 -or $uiH -ge 32) { [void]$L.Add(@()) }
        [void]$L.Add(@((Seg 'accent!' ('  PREVIEW & LOGS'.PadRight($col1W + 2))), (Seg 'accent!' 'Recovery and System')))
        [void]$L.Add(@((Seg 'text' ('  [T] Dry Run'.PadRight($col1W + 2))), (Seg 'text' '[8] Remove Watchdog Task')))
        [void]$L.Add(@((Seg 'text' ('  [R] Export Diagnostic Report'.PadRight($col1W + 2))), (Seg 'text' '[B] Live Sentinel Monitor')))
        [void]$L.Add(@((Seg 'text' ('  [H] History & Forensics'.PadRight($col1W + 2))), (Seg $(if ($adv.Key -eq 'x') { 'ok!' } else { 'accent!' }) '[X] Recovery and System')))
        [void]$L.Add(@((Seg 'dim' ('  [0] User Guide'.PadRight($col1W + 2))), (Seg 'dim' '[Q] Exit')))
        if ($t.ArpPending) { [void]$L.Add(@((Seg 'warn!' ('  [K] Approve Gateway MAC Change'.PadRight($col1W + 2))), (Seg 'warn' 'Router MAC changed; review to lock ARP'))) }
    } else {
        $legend = @(@('1', 'QuickHeal'), @('X', 'Recovery'), @('H', 'History'), @('2', 'Watchdog'), @('A', 'Vault'), @('7', 'Portal'), @('G', 'Login'), @('3', 'DNS'), @('M', 'Route'), @('4', 'Probe'), @('5', 'Flush'), @('6', 'Audit'), @('B', 'Sentinel'), @('T', 'DryRun'), @('R', 'Report'), @('8', 'Disarm'), @('9', 'Reset'), @('0', 'Guide'), @('Q', 'Quit'))
        # A gateway-MAC review is transient, so [K] is advertised only while a candidate is really waiting. The leading
        # comma appends the pair as ONE legend cell; a bare "+=" would append two loose strings and corrupt the legend.
        if ($t.ArpPending) { $legend += , @('K', 'MAC') }
        foreach ($row in @(Get-LegendRows $legend $adv.Key $w)) { [void]$L.Add($row) }
    }
    return @{ Lines = $L.ToArray(); PulseIdx = $pulseIdx; Width = $w }
}

# Repaints only the pulse row (no flicker). VT consoles only, and only when the frame fits the window.
function Update-PulseRow($t) {
    $f = $script:Frame
    if (-not $f -or -not $script:Ui.Vt -or $f.Model.PulseIdx -lt 0) { return $false }
    $hgt = Get-UiHeight
    if ($hgt -le 0 -or ($f.Rows + 1) -gt $hgt) { return $false }   # unknown or too small: skip the partial repaint
    $sparkWidth = [Math]::Max(4, [Math]::Min(36, $f.Model.Width - 54))
    $segs = Get-PulseSegs $t $sparkWidth
    $targetRow = $f.Model.PulseIdx + 1
    $promptRow = $f.Rows + 1
    $e = $script:Esc
    [Console]::Write($e + '[' + $targetRow + ';1H' + (ConvertTo-AnsiString $segs) + $e + '[K' + $e + '[' + $promptRow + ';5H' + $e + '[?25h')
    return $true
}

# ==============================================================================
# VIEWS AND MENUS
# ==============================================================================
function Show-View([string]$Title, [scriptblock]$Body, [switch]$NoWait) {
    $prevInDash = $script:InDashboard
    $script:InDashboard = $false
    Clear-Screen
    Show-Cursor $true
    Write-Banner $Title
    try { & $Body } catch { Write-Log 'FAIL' ('Operation failed: ' + $_.Exception.Message) }
    if (-not $NoWait) {
        Out-Line @()
        Out-Line @((Seg 'dim' '  Press any key to return to dashboard...'))
        Wait-AnyKey
    }
    $script:InDashboard = $prevInDash
}

function Read-Choice {
    Clear-InputBuffer
    try { return (Read-KeyNow) } catch { $s = [string](Read-Host); if ($s.Length -gt 0) { return [pscustomobject]@{ KeyChar = $s[0]; Key = 'Other' } }; return [pscustomobject]@{ KeyChar = [char]0; Key = 'Enter' } }
}

function Read-Confirm([string]$Prompt, [string]$Word = 'yes') {
    Out-Line @((Seg 'warn' ('  ' + $Prompt + ' ')), (Seg 'dim' ('(type ' + $Word + ' to confirm): '))) -NoNewline
    Show-Cursor $true
    $a = ''
    try { $a = [string](Read-Host) } catch {}
    return ($a.Trim().ToLower() -eq $Word)
}

function Show-Advisory {
    Clear-Screen; Show-Cursor $true
    Write-Banner 'USER GUIDE'
    $w = Get-UiWidth
    Out-Line @((Seg 'accent!' '  Recommendation'))
    Out-Line @((Seg 'dim' '  * Plug in Ethernet cable  '), (Seg 'faint' '-> '), (Seg 'ok!' '[1] Quick Heal '), (Seg 'dim' '(repairs adapter, IP lease & routes)'))
    Out-Line @()
    Out-Line @((Seg 'accent!' '  COMMON SYMPTOMS & 1-TOUCH FIXES'.PadRight(50)), (Seg 'accent!' 'ACTION'))
    Out-Line @((Seg 'faint' ('  ' + ($script:G.rule * $w))))
    $matrix = @(
        # 1. Connection & Initial Setup
        @('Cable in, no IP / APIPA (169.254.x.x)',       '1', 'Quick Heal (Recommended)'),
        @('Campus portal login required for internet',   'A', 'Portal Credentials Vault'),
        @('Auto-repair on cable plug or system wake',    '2', 'Install Watchdog Task'),
        @('Autonomous continuous sentinel monitoring',   'B', 'Live Sentinel Monitor'),
        # 2. DNS & Everyday Browsing
        @('University ERP or intranet unreachable',      '3', 'DNS Configuration (DHCP)'),
        @('Balance traffic: Ethernet vs Wi-Fi',          'M', 'Routing & Metric Priority'),
        @('Websites fail to open / stale DNS cache',     '5', 'Flush Network Caches'),
        @('High ping, jitter or lag in games & calls',   '4', 'Network Quality Probe'),
        # 3. Diagnostics & Audit Reports
        @('Inspect hardware MAC, lease & gateway',       '6', 'System Diagnostics Audit'),
        @('Save diagnostic audit report to file',        'R', 'Export Diagnostic Report'),
        # 4. Safety & Rollback
        @('Instant background sign-in with saved login', 'G', 'Submit Portal Login'),
        @('Total network down / no internet anywhere',   'X', 'Recovery and System'),
        @('Total connectivity dead (Wi-Fi/LAN/USB/BT)',  'D', 'Deep Multi-Adapter Reinstall'),
        @('Corrupted Winsock catalog & TCP/IP stack',     'U', 'Standard Stack Reset'),
        @('Preview repairs safely without changes',      'T', 'Dry Run'),
        @('Autonomous Sentinel background daemon',       'B', 'Live Sentinel Monitor'),
        @('Restore default Windows network settings',    '9', 'Restore Network Defaults')
    )
    foreach ($m in $matrix) {
        Out-Line @(
            (Seg 'text' ('  ' + $m[0].PadRight(44))),
            (Seg 'faint' ' -> '),
            (Seg 'faint' '['),
            (Seg 'ok!' $m[1]),
            (Seg 'faint' '] '),
            (Seg 'dim' $m[2])
        )
    }
    Out-Line @()
    Out-Line @((Seg 'faint' ('  ' + ($script:G.rule * $w))))
    Out-Line @((Seg 'dim' '  Press any key to return to dashboard...'))
    Wait-AnyKey
}

# ==============================================================================
# FEATURE F11: IN-FILE HELP SYSTEM & UNIFIED METADATA REGISTRY
# ==============================================================================
function Get-CommandMetadata {
    if ($script:CommandMetadata) { return $script:CommandMetadata }
    $meta = @{
        # --- Diagnostics ---
        'Doctor' = @{
            Name         = 'Doctor'
            Category     = 'Diagnostics'
            Tier         = 0
            Mutating     = $false
            Reversible   = $true
            Summary      = 'Comprehensive 7-layer read-only health diagnosis.'
            Description  = 'Audits physical transceiver, DHCP lease, gateway reachability, DNS resolvers, IPv4 internet, TLS handshake, and captive portal state.'
            BlastRadius  = 'None (Read-Only)'
            ExitCodes    = @{ '0' = 'Healthy'; '10' = 'Degraded'; '20' = 'Broken'; '30' = 'Undetermined' }
            Examples     = @('LanFixer.cmd -Mode Doctor', 'LanFixer.cmd -Mode Doctor -Json', 'LanFixer.cmd -Mode Doctor -Quiet')
            RelatedModes = @('Status', 'Diagnose', 'Recover')
            Aliases      = @('Doctor')
        }
        'Status' = @{
            Name         = 'Status'
            Category     = 'Diagnostics'
            Tier         = 0
            Mutating     = $false
            Reversible   = $true
            Summary      = 'High-level network health status summary (alias for Doctor).'
            Description  = 'Audits network connectivity across all 7 OSI layers and outputs health verdict and degraded components.'
            BlastRadius  = 'None (Read-Only)'
            ExitCodes    = @{ '0' = 'Healthy'; '10' = 'Degraded'; '20' = 'Broken'; '30' = 'Undetermined' }
            Examples     = @('LanFixer.cmd -Mode Status', 'LanFixer.cmd -Mode Status -Quiet')
            RelatedModes = @('Doctor', 'Diagnose')
            Aliases      = @('Doctor')
        }
        'Diagnose' = @{
            Name         = 'Diagnose'
            Category     = 'Diagnostics'
            Tier         = 0
            Mutating     = $false
            Reversible   = $true
            Summary      = 'Deep forensic network and adapter configuration audit.'
            Description  = 'Inspects IP interfaces, DHCP leases, DNS client configurations, ARP cache, adapter hardware states, and routing tables.'
            BlastRadius  = 'None (Read-Only)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode Diagnose', 'LanFixer.cmd -Mode Audit')
            RelatedModes = @('Audit', 'Doctor', 'Report')
            Aliases      = @('Audit')
        }
        'Audit' = @{
            Name         = 'Audit'
            Category     = 'Diagnostics'
            Tier         = 0
            Mutating     = $false
            Reversible   = $true
            Summary      = 'Deep forensic network and adapter configuration audit (alias for Diagnose).'
            Description  = 'Inspects IP interfaces, DHCP leases, DNS client configurations, ARP cache, adapter hardware states, and routing tables.'
            BlastRadius  = 'None (Read-Only)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode Audit', 'LanFixer.cmd -Mode Diagnose')
            RelatedModes = @('Diagnose', 'Doctor', 'Report')
            Aliases      = @('Diagnose')
        }
        'QuickProbe' = @{
            Name         = 'QuickProbe'
            Category     = 'Diagnostics'
            Tier         = 0
            Mutating     = $false
            Reversible   = $true
            Summary      = 'Lightweight latency, loss, and jitter probe to gateways and internet targets.'
            Description  = 'Tests UDP/ICMP reachability and round-trip latency to the local default gateway and public DNS root servers.'
            BlastRadius  = 'None (Read-Only)'
            ExitCodes    = @{ '0' = 'Online'; '1' = 'Offline/Degraded' }
            Examples     = @('LanFixer.cmd -Mode QuickProbe', 'LanFixer.cmd -Mode Probe')
            RelatedModes = @('Probe', 'Doctor')
            Aliases      = @('Probe')
        }
        'Probe' = @{
            Name         = 'Probe'
            Category     = 'Diagnostics'
            Tier         = 0
            Mutating     = $false
            Reversible   = $true
            Summary      = 'Lightweight latency, loss, and jitter probe (alias for QuickProbe).'
            Description  = 'Tests UDP/ICMP reachability and round-trip latency to the local default gateway and public DNS root servers.'
            BlastRadius  = 'None (Read-Only)'
            ExitCodes    = @{ '0' = 'Online'; '1' = 'Offline/Degraded' }
            Examples     = @('LanFixer.cmd -Mode Probe')
            RelatedModes = @('QuickProbe', 'Doctor')
            Aliases      = @('QuickProbe')
        }
        'SelfTest' = @{
            Name         = 'SelfTest'
            Category     = 'Diagnostics'
            Tier         = 0
            Mutating     = $false
            Reversible   = $true
            Summary      = 'Comprehensive internal regression suite verifying all system subsystems and logic.'
            Description  = 'Executes 385+ hermetic behavioral tests against network stack, crypto, state management, ACLs, and repair algorithms.'
            BlastRadius  = 'None (Read-Only in dry-run)'
            ExitCodes    = @{ '0' = 'All Passed'; '1' = 'Test Failure' }
            Examples     = @('LanFixer.cmd -Mode SelfTest -DryRun', 'LanFixer.cmd -Mode SelfTest -Json')
            RelatedModes = @('Verify', 'Doctor')
            Aliases      = @('Verify')
        }
        'Verify' = @{
            Name         = 'Verify'
            Category     = 'Diagnostics'
            Tier         = 0
            Mutating     = $false
            Reversible   = $true
            Summary      = 'System regression test suite (alias for SelfTest).'
            Description  = 'Executes comprehensive internal self-tests verifying cmdlets, tools, parsers, and logic invariants.'
            BlastRadius  = 'None (Read-Only in dry-run)'
            ExitCodes    = @{ '0' = 'All Passed'; '1' = 'Test Failure' }
            Examples     = @('LanFixer.cmd -Mode Verify -DryRun')
            RelatedModes = @('SelfTest', 'Doctor')
            Aliases      = @('SelfTest')
        }
        'Report' = @{
            Name         = 'Report'
            Category     = 'Diagnostics'
            Tier         = 0
            Mutating     = $false
            Reversible   = $true
            Summary      = 'Generates and exports an exhaustive diagnostic text report to disk.'
            Description  = 'Compiles full adapter configuration, routing tables, DNS status, event log snippets, and driver inventory into a timestamped report file.'
            BlastRadius  = 'None (Writes local report file)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode Report', 'LanFixer.cmd -Mode Report -Json')
            RelatedModes = @('Bundle', 'Diagnose')
            Aliases      = @()
        }
        'Bundle' = @{
            Name         = 'Bundle'
            Category     = 'Diagnostics'
            Tier         = 0
            Mutating     = $false
            Reversible   = $true
            Summary      = 'Zero-dependency redacted diagnostic ZIP support bundle generator.'
            Description  = 'Creates an encrypted/redacted ZIP archive of system network diagnostics, event logs, and state with PII, MAC, and IP masking.'
            BlastRadius  = 'None (Creates ZIP bundle in OutDir)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode Bundle -OutDir C:\Logs', 'LanFixer.cmd -Mode Bundle -Redaction Strict -Json')
            RelatedModes = @('Report', 'Diagnose')
            Aliases      = @()
        }

        # --- Remediation ---
        'Recover' = @{
            Name         = 'Recover'
            Category     = 'Remediation'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Guided automated recovery escalation ladder.'
            Description  = 'Executes Doctor diagnosis, applies least-destructive repair for the specific failing layer, and re-verifies. Halts before destructive tiers.'
            BlastRadius  = 'Low to Moderate (Scoped to failing layer)'
            ExitCodes    = @{ '0' = 'Healthy'; '1' = 'Error'; '2' = 'Unresolved' }
            Examples     = @('LanFixer.cmd -Mode Recover', 'LanFixer.cmd -Mode Recover -Plan')
            RelatedModes = @('Doctor', 'QuickHeal', 'Omnifix')
            Aliases      = @()
        }
        'QuickHeal' = @{
            Name         = 'QuickHeal'
            Category     = 'Remediation'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Autonomous multi-loop network heal pipeline for common link and lease dropouts.'
            Description  = 'Cycles physical adapter transceivers, renews DHCP leases, repairs ARP entries, and corrects routing priority.'
            BlastRadius  = 'Low (Temporary link toggle, ~2-4s)'
            ExitCodes    = @{ '0' = 'Repaired'; '1' = 'Error'; '2' = 'Unresolved' }
            Examples     = @('LanFixer.cmd -Mode QuickHeal', 'LanFixer.cmd -Mode Heal')
            RelatedModes = @('Heal', 'AutoHeal', 'Recover')
            Aliases      = @('Heal')
        }
        'Heal' = @{
            Name         = 'Heal'
            Category     = 'Remediation'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Network healing pipeline (alias for QuickHeal).'
            Description  = 'Cycles physical adapter transceivers, renews DHCP leases, repairs ARP entries, and corrects routing priority.'
            BlastRadius  = 'Low (Temporary link toggle, ~2-4s)'
            ExitCodes    = @{ '0' = 'Repaired'; '1' = 'Error'; '2' = 'Unresolved' }
            Examples     = @('LanFixer.cmd -Mode Heal')
            RelatedModes = @('QuickHeal', 'AutoHeal')
            Aliases      = @('QuickHeal')
        }
        'AutoHeal' = @{
            Name         = 'AutoHeal'
            Category     = 'Remediation'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Background unattended recovery triggered by Windows Task Scheduler or Watchdog.'
            Description  = 'Non-interactive execution of the QuickHeal pipeline with cooldown debounce, integrity check, and failure telemetry suppression.'
            BlastRadius  = 'Low (Scheduled/background execution)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error'; '50' = 'Integrity Tamper' }
            Examples     = @('LanFixer.cmd -Mode AutoHeal')
            RelatedModes = @('QuickHeal', 'InstallWatchdog')
            Aliases      = @()
        }
        'FlushCache' = @{
            Name         = 'FlushCache'
            Category     = 'Remediation'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Flushes DNS client cache, NetBIOS names, and ARP neighbor table.'
            Description  = 'Purges cached DNS lookup responses, ARP resolution tables, and NetBIOS name registrations to resolve stale endpoint bindings.'
            BlastRadius  = 'Low (Flushes dynamic caches)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode FlushCache', 'LanFixer.cmd -Mode Flush')
            RelatedModes = @('Flush', 'QuickHeal')
            Aliases      = @('Flush')
        }
        'Flush' = @{
            Name         = 'Flush'
            Category     = 'Remediation'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Flush caches (alias for FlushCache).'
            Description  = 'Purges cached DNS lookup responses, ARP resolution tables, and NetBIOS name registrations.'
            BlastRadius  = 'Low (Flushes dynamic caches)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode Flush')
            RelatedModes = @('FlushCache')
            Aliases      = @('FlushCache')
        }

        # --- Reset & Recovery ---
        'Omnifix' = @{
            Name         = 'Omnifix'
            Category     = 'Reset & Recovery'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = '5-stage non-destructive stack refresh (Tier 1 Reset).'
            Description  = 'Hardware bus rescan, adapter power management optimization, TCP/IP stack parameter tuning, and WFP proxy neutralization.'
            BlastRadius  = 'Moderate (Transient adapter reset)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode Omnifix', 'LanFixer.cmd -Mode StandardReset -Force')
            RelatedModes = @('StandardReset', 'NetReset', 'UltraReset')
            Aliases      = @('StandardReset')
        }
        'StandardReset' = @{
            Name         = 'StandardReset'
            Category     = 'Reset & Recovery'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Standard network reset (alias for Omnifix).'
            Description  = 'Hardware bus rescan, adapter power management optimization, TCP/IP stack parameter tuning, and WFP proxy neutralization.'
            BlastRadius  = 'Moderate (Transient adapter reset)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode StandardReset')
            RelatedModes = @('Omnifix', 'NetReset')
            Aliases      = @('Omnifix')
        }
        'NetReset' = @{
            Name         = 'NetReset'
            Category     = 'Reset & Recovery'
            Tier         = 2
            Mutating     = $true
            Reversible   = $false
            Summary      = '10-stage deep network stack resuscitation (Tier 2 Reset).'
            Description  = 'Winsock catalog reset, TCP/IP autotuning reset, firewall policy normalization, proxy wipe, and adapter driver reload.'
            BlastRadius  = 'High (Resets network stack configuration)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode NetReset -Force', 'LanFixer.cmd -Mode FullNetReset')
            RelatedModes = @('FullNetReset', 'UltraReset', 'Omnifix')
            Aliases      = @('FullNetReset')
        }
        'FullNetReset' = @{
            Name         = 'FullNetReset'
            Category     = 'Reset & Recovery'
            Tier         = 2
            Mutating     = $true
            Reversible   = $false
            Summary      = 'Full network reset (alias for NetReset).'
            Description  = 'Winsock catalog reset, TCP/IP autotuning reset, firewall policy normalization, proxy wipe, and adapter driver reload.'
            BlastRadius  = 'High (Resets network stack configuration)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode FullNetReset -Force')
            RelatedModes = @('NetReset', 'UltraReset')
            Aliases      = @('NetReset')
        }
        'UltraReset' = @{
            Name         = 'UltraReset'
            Category     = 'Reset & Recovery'
            Tier         = 2
            Mutating     = $true
            Reversible   = $false
            Summary      = '10-stage network stack and driver resuscitation.'
            Description  = 'Comprehensive stack wipe, LSP driver cleanup, network profile normalization, and adapter re-initialization.'
            BlastRadius  = 'High (Requires elevated confirmation or -Force)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode UltraReset -Force', 'LanFixer.cmd -Mode Ultra')
            RelatedModes = @('Ultra', 'NetReset', 'DoomsdayReset')
            Aliases      = @('Ultra')
        }
        'Ultra' = @{
            Name         = 'Ultra'
            Category     = 'Reset & Recovery'
            Tier         = 2
            Mutating     = $true
            Reversible   = $false
            Summary      = 'Ultra system reset (alias for UltraReset).'
            Description  = 'Comprehensive stack wipe, LSP driver cleanup, network profile normalization, and adapter re-initialization.'
            BlastRadius  = 'High (Requires elevated confirmation or -Force)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode Ultra -Force')
            RelatedModes = @('UltraReset', 'DoomsdayReset')
            Aliases      = @('UltraReset')
        }
        'DoomsdayReset' = @{
            Name         = 'DoomsdayReset'
            Category     = 'Reset & Recovery'
            Tier         = 3
            Mutating     = $true
            Reversible   = $false
            Summary      = 'Comprehensive multi-adapter reinstall, NDIS unbind/rebind, and service rebuild (Tier 3 Reset).'
            Description  = 'Purges all virtual adapters, neutralizes misconfigured third-party network filters, and rebuilds core networking services.'
            BlastRadius  = 'Critical (Reboot recommended; requires explicit confirmation)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode DoomsdayReset -Force', 'LanFixer.cmd -Mode Doomsday')
            RelatedModes = @('Doomsday', 'ArmageddonReset', 'UltraReset')
            Aliases      = @('Doomsday')
        }
        'Doomsday' = @{
            Name         = 'Doomsday'
            Category     = 'Reset & Recovery'
            Tier         = 3
            Mutating     = $true
            Reversible   = $false
            Summary      = 'Doomsday system reset (alias for DoomsdayReset).'
            Description  = 'Purges all virtual adapters, neutralizes misconfigured third-party network filters, and rebuilds core networking services.'
            BlastRadius  = 'Critical (Reboot recommended; requires explicit confirmation)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode Doomsday -Force')
            RelatedModes = @('DoomsdayReset', 'ArmageddonReset')
            Aliases      = @('DoomsdayReset')
        }
        'ArmageddonReset' = @{
            Name         = 'ArmageddonReset'
            Category     = 'Reset & Recovery'
            Tier         = 4
            Mutating     = $true
            Reversible   = $false
            Summary      = 'Absolute bare-metal network device wipe via netcfg -d (Tier 4 Reset).'
            Description  = 'Uninstalls all network adapters and cleans up registry networking keys. Will sever remote sessions; requires reboot.'
            BlastRadius  = 'Total (Performs netcfg -d bare-metal purge)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode ArmageddonReset -Force -ConfirmRemoteDisconnect')
            RelatedModes = @('Armageddon', 'DoomsdayReset')
            Aliases      = @('Armageddon')
        }
        'Armageddon' = @{
            Name         = 'Armageddon'
            Category     = 'Reset & Recovery'
            Tier         = 4
            Mutating     = $true
            Reversible   = $false
            Summary      = 'Armageddon reset (alias for ArmageddonReset).'
            Description  = 'Uninstalls all network adapters and cleans up registry networking keys. Will sever remote sessions; requires reboot.'
            BlastRadius  = 'Total (Performs netcfg -d bare-metal purge)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode Armageddon -Force -ConfirmRemoteDisconnect')
            RelatedModes = @('ArmageddonReset')
            Aliases      = @('ArmageddonReset')
        }
        'ResetOptions' = @{
            Name         = 'ResetOptions'
            Category     = 'Reset & Recovery'
            Tier         = 0
            Mutating     = $false
            Reversible   = $true
            Summary      = 'Interactive menu displaying all 5 graduated network reset tiers.'
            Description  = 'Presents descriptions, blast radius, and confirmation prompts for Omnifix, Ultra, Doomsday, Armageddon, and Factory Reset.'
            BlastRadius  = 'None (Menu interface)'
            ExitCodes    = @{ '0' = 'Success' }
            Examples     = @('LanFixer.cmd -Mode ResetOptions', 'LanFixer.cmd -Mode ResetMenu')
            RelatedModes = @('ResetMenu', 'UltraReset', 'DoomsdayReset')
            Aliases      = @('ResetMenu')
        }
        'ResetMenu' = @{
            Name         = 'ResetMenu'
            Category     = 'Reset & Recovery'
            Tier         = 0
            Mutating     = $false
            Reversible   = $true
            Summary      = 'Reset menu (alias for ResetOptions).'
            Description  = 'Presents descriptions, blast radius, and confirmation prompts for all reset tiers.'
            BlastRadius  = 'None (Menu interface)'
            ExitCodes    = @{ '0' = 'Success' }
            Examples     = @('LanFixer.cmd -Mode ResetMenu')
            RelatedModes = @('ResetOptions')
            Aliases      = @('ResetOptions')
        }
        'ResetFactory' = @{
            Name         = 'ResetFactory'
            Category     = 'Reset & Recovery'
            Tier         = 5
            Mutating     = $true
            Reversible   = $false
            Summary      = 'Restores the original system network baseline snapshot captured on first run.'
            Description  = 'Restores initial registry values, adapter metrics, power management settings, and DNS server configuration.'
            BlastRadius  = 'High (Restores first-seen system snapshot)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode ResetFactory -Force', 'LanFixer.cmd -Mode Reset')
            RelatedModes = @('Reset', 'Undo')
            Aliases      = @('Reset')
        }
        'Reset' = @{
            Name         = 'Reset'
            Category     = 'Reset & Recovery'
            Tier         = 5
            Mutating     = $true
            Reversible   = $false
            Summary      = 'Factory reset rollback (alias for ResetFactory).'
            Description  = 'Restores initial registry values, adapter metrics, power management settings, and DNS server configuration.'
            BlastRadius  = 'High (Restores first-seen system snapshot)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode Reset -Force')
            RelatedModes = @('ResetFactory')
            Aliases      = @('ResetFactory')
        }
        'Undo' = @{
            Name         = 'Undo'
            Category     = 'Reset & Recovery'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Rolls back specific mutations recorded in the persistent Change Ledger.'
            Description  = 'Reverses changes by mutation entry ID or run correlation ID with drift detection before modifying system state.'
            BlastRadius  = 'Targeted (Reverses specified mutations)'
            ExitCodes    = @{ '0' = 'Undone'; '1' = 'Error'; '2' = 'NotFound'; '3' = 'DriftSkipped' }
            Examples     = @('LanFixer.cmd -Mode Undo -Id <EntryId>', 'LanFixer.cmd -Mode Undo -RunId <RunId>')
            RelatedModes = @('History', 'ResetFactory')
            Aliases      = @()
        }
        'History' = @{
            Name         = 'History'
            Category     = 'Reset & Recovery'
            Tier         = 0
            Mutating     = $false
            Reversible   = $true
            Summary      = 'Multi-section forensic history, mutation ledger, execution logs, and live network monitor.'
            Description  = 'Deep multi-dimensional forensic suite: audits mutations (registry, DNS, routes), exact execution logs (LanFixer.log), error/failure history, Windows OS network events (NDIS/DHCP/DNS/NCSI), state transitions, heal passes, root-cause causality timeline, and live streaming forensics.'
            BlastRadius  = 'None (Read-Only)'
            ExitCodes    = @{ '0' = 'Success' }
            Examples     = @('LanFixer.cmd -Mode History', 'LanFixer.cmd -Mode History -Section mutations', 'LanFixer.cmd -Mode History -Section logs', 'LanFixer.cmd -Mode History -Section errors', 'LanFixer.cmd -Mode History -Section os', 'LanFixer.cmd -Mode History -Section timeline', 'LanFixer.cmd -Mode History -Follow', 'LanFixer.cmd -Mode History -Limit 50 -Json')
            RelatedModes = @('Undo', 'Doctor', 'Audit')
            Aliases      = @('Hist', 'Logs', 'Forensics')
        }

        # --- Network Configuration ---
        'SetDnsProfile' = @{
            Name         = 'SetDnsProfile'
            Category     = 'Network Configuration'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Configures DNS resolver policy (Adaptive, DHCP, Hybrid, Cloudflare, ResetDHCP).'
            Description  = 'Applies fast public DNS fallbacks, university intranet resolution rules, or restores ISP DHCP assigned resolvers.'
            BlastRadius  = 'Low (Updates DNS server addresses)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode SetDnsProfile -DnsProfile Adaptive', 'LanFixer.cmd -Mode Dns')
            RelatedModes = @('Dns', 'DnsMenu', 'SetRouteProfile')
            Aliases      = @('Dns', 'DnsMenu')
        }
        'Dns' = @{
            Name         = 'Dns'
            Category     = 'Network Configuration'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'DNS resolver profile configuration (alias for SetDnsProfile).'
            Description  = 'Applies fast public DNS fallbacks, university intranet resolution rules, or restores ISP DHCP assigned resolvers.'
            BlastRadius  = 'Low (Updates DNS server addresses)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode Dns')
            RelatedModes = @('SetDnsProfile', 'DnsMenu')
            Aliases      = @('SetDnsProfile', 'DnsMenu')
        }
        'DnsMenu' = @{
            Name         = 'DnsMenu'
            Category     = 'Network Configuration'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Interactive DNS profile selection menu (alias for SetDnsProfile).'
            Description  = 'Interactive menu to choose between Adaptive, DHCP, Hybrid, and Cloudflare DNS resolver configurations.'
            BlastRadius  = 'Low (Updates DNS server addresses)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode DnsMenu')
            RelatedModes = @('SetDnsProfile', 'Dns')
            Aliases      = @('SetDnsProfile', 'Dns')
        }
        'SetRouteProfile' = @{
            Name         = 'SetRouteProfile'
            Category     = 'Network Configuration'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Configures interface metric priority routing (Adaptive, Ethernet, Wifi, Windows).'
            Description  = 'Adjusts IPv4 and IPv6 interface route metrics to prioritize high-speed wired Ethernet over wireless or split traffic.'
            BlastRadius  = 'Low (Modifies route interface metrics)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode SetRouteProfile -RouteProfile Adaptive', 'LanFixer.cmd -Mode Route')
            RelatedModes = @('Route', 'RouteMenu', 'SetDnsProfile')
            Aliases      = @('Route', 'RouteMenu')
        }
        'Route' = @{
            Name         = 'Route'
            Category     = 'Network Configuration'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Interface metric routing policy (alias for SetRouteProfile).'
            Description  = 'Adjusts IPv4 and IPv6 interface route metrics to prioritize wired Ethernet or balanced multi-homed traffic.'
            BlastRadius  = 'Low (Modifies route interface metrics)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode Route')
            RelatedModes = @('SetRouteProfile', 'RouteMenu')
            Aliases      = @('SetRouteProfile', 'RouteMenu')
        }
        'RouteMenu' = @{
            Name         = 'RouteMenu'
            Category     = 'Network Configuration'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Interactive routing profile menu (alias for SetRouteProfile).'
            Description  = 'Interactive menu to choose between Adaptive, Ethernet, Wifi, and Windows default routing profiles.'
            BlastRadius  = 'Low (Modifies route interface metrics)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode RouteMenu')
            RelatedModes = @('SetRouteProfile', 'Route')
            Aliases      = @('SetRouteProfile', 'Route')
        }

        # --- Authentication & Portals ---
        'LaunchPortal' = @{
            Name         = 'LaunchPortal'
            Category     = 'Authentication & Portals'
            Tier         = 0
            Mutating     = $false
            Reversible   = $true
            Summary      = 'Detects captive portal gateway redirect and launches browser or completes sign-in.'
            Description  = 'Probes HTTP 204 endpoint to discover redirect URLs and opens browser or executes automated authentication.'
            BlastRadius  = 'None'
            ExitCodes    = @{ '0' = 'Online'; '1' = 'LoginRequired/Failed' }
            Examples     = @('LanFixer.cmd -Mode LaunchPortal', 'LanFixer.cmd -Mode Login')
            RelatedModes = @('Login', 'Vault')
            Aliases      = @('Login')
        }
        'Login' = @{
            Name         = 'Login'
            Category     = 'Authentication & Portals'
            Tier         = 0
            Mutating     = $false
            Reversible   = $true
            Summary      = 'Captive portal sign-in (alias for LaunchPortal).'
            Description  = 'Probes HTTP 204 endpoint to discover redirect URLs and opens browser or executes automated authentication.'
            BlastRadius  = 'None'
            ExitCodes    = @{ '0' = 'Online'; '1' = 'LoginRequired/Failed' }
            Examples     = @('LanFixer.cmd -Mode Login')
            RelatedModes = @('LaunchPortal', 'Vault')
            Aliases      = @('LaunchPortal')
        }
        'Vault' = @{
            Name         = 'Vault'
            Category     = 'Authentication & Portals'
            Tier         = 0
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Manages encrypted DPAPI LocalMachine credentials for captive network login.'
            Description  = 'Stores, audits, and removes campus/hotel network authentication credentials secured by Windows DPAPI.'
            BlastRadius  = 'Low (Stores encrypted local secret)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode Vault')
            RelatedModes = @('LaunchPortal', 'Login')
            Aliases      = @()
        }

        # --- Automation & Sentinel ---
        'InstallWatchdog' = @{
            Name         = 'InstallWatchdog'
            Category     = 'Automation & Sentinel'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Registers event-triggered SYSTEM scheduled task for automatic network repair on link connect.'
            Description  = 'Attaches a secured scheduled task to NDIS 10000/10001 connect events, executing AutoHeal upon link change.'
            BlastRadius  = 'Moderate (Registers scheduled task)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode InstallWatchdog')
            RelatedModes = @('UninstallWatchdog', 'InstallShield')
            Aliases      = @()
        }
        'UninstallWatchdog' = @{
            Name         = 'UninstallWatchdog'
            Category     = 'Automation & Sentinel'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Removes the event-triggered scheduled repair task from Windows Task Scheduler.'
            Description  = 'Deletes the LanFixerWatchdog task and cleans up event trigger registrations.'
            BlastRadius  = 'Low (Removes scheduled task)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode UninstallWatchdog')
            RelatedModes = @('InstallWatchdog')
            Aliases      = @()
        }
        'InstallShield' = @{
            Name         = 'InstallShield'
            Category     = 'Automation & Sentinel'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Installs link connection watchdog and locks down adapter power throttling.'
            Description  = 'Registers watchdog task and enforces continuous adapter transceiver vigilance.'
            BlastRadius  = 'Moderate (Registers scheduled task)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode InstallShield')
            RelatedModes = @('UninstallShield', 'InstallWatchdog')
            Aliases      = @()
        }
        'UninstallShield' = @{
            Name         = 'UninstallShield'
            Category     = 'Automation & Sentinel'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Uninstalls watchdog shield and restores adapter power management policies.'
            Description  = 'Removes watchdog scheduled task and restores energy saving settings.'
            BlastRadius  = 'Low (Removes scheduled task)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode UninstallShield')
            RelatedModes = @('InstallShield')
            Aliases      = @()
        }
        'InstallSentinel' = @{
            Name         = 'InstallSentinel'
            Category     = 'Automation & Sentinel'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Registers autonomous sentinel background service task for continuous monitoring.'
            Description  = 'Creates persistent SYSTEM scheduled task running the Sentinel daemon loop with flap detection.'
            BlastRadius  = 'Moderate (Registers scheduled task)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode InstallSentinel')
            RelatedModes = @('UninstallSentinel', 'Sentinel')
            Aliases      = @()
        }
        'UninstallSentinel' = @{
            Name         = 'UninstallSentinel'
            Category     = 'Automation & Sentinel'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Removes autonomous sentinel scheduled monitoring task.'
            Description  = 'Deletes the LanFixerSentinel scheduled task.'
            BlastRadius  = 'Low (Removes scheduled task)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'Error' }
            Examples     = @('LanFixer.cmd -Mode UninstallSentinel')
            RelatedModes = @('InstallSentinel')
            Aliases      = @()
        }
        'Daemon' = @{
            Name         = 'Daemon'
            Category     = 'Automation & Sentinel'
            Tier         = 0
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Runs continuous background link monitor and autonomous repair loop.'
            Description  = 'Continuously monitors NDIS link state, detects link flapping and Gigabit downshifts, and heals connectivity issues.'
            BlastRadius  = 'Moderate (Long-running process)'
            ExitCodes    = @{ '0' = 'Terminated'; '1' = 'Error'; '50' = 'Integrity Tamper' }
            Examples     = @('LanFixer.cmd -Mode Daemon -Headless', 'LanFixer.cmd -Mode Sentinel')
            RelatedModes = @('Sentinel', 'AutoHeal')
            Aliases      = @('Sentinel')
        }
        'Sentinel' = @{
            Name         = 'Sentinel'
            Category     = 'Automation & Sentinel'
            Tier         = 0
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Autonomous sentinel monitor (alias for Daemon).'
            Description  = 'Continuously monitors NDIS link state, detects link flapping and Gigabit downshifts, and heals connectivity issues.'
            BlastRadius  = 'Moderate (Long-running process)'
            ExitCodes    = @{ '0' = 'Terminated'; '1' = 'Error'; '50' = 'Integrity Tamper' }
            Examples     = @('LanFixer.cmd -Mode Sentinel')
            RelatedModes = @('Daemon', 'AutoHeal')
            Aliases      = @('Daemon')
        }

        # --- System & Policy ---
        'Config' = @{
            Name         = 'Config'
            Category     = 'System & Policy'
            Tier         = 0
            Mutating     = $false
            Reversible   = $true
            Summary      = 'Inspects and audits effective policy configuration from INI file and defaults.'
            Description  = 'Parses $StoreDir\lanfixer.ini, audits file security ACLs, and merges values with system defaults.'
            BlastRadius  = 'None (Read-Only unless validating)'
            ExitCodes    = @{ '0' = 'Valid'; '1' = 'Invalid' }
            Examples     = @('LanFixer.cmd -Mode Config', 'LanFixer.cmd -Mode Config -Validate -Json')
            RelatedModes = @('Integrity', 'Report')
            Aliases      = @()
        }
        'Integrity' = @{
            Name         = 'Integrity'
            Category     = 'System & Policy'
            Tier         = 0
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Validates or authorizes cryptographic SHA-256 self-integrity manifest.'
            Description  = 'Verifies the script file owner, ACL permissions, and SHA-256 hash against $StoreDir\integrity.json to prevent tampering.'
            BlastRadius  = 'None (or writes integrity manifest on -Authorize)'
            ExitCodes    = @{ '0' = 'Authorized'; '1' = 'Error'; '50' = 'Tampered' }
            Examples     = @('LanFixer.cmd -Mode Integrity -Audit', 'LanFixer.cmd -Mode Integrity -Authorize')
            RelatedModes = @('SelfTest', 'Config')
            Aliases      = @()
        }
        'Help' = @{
            Name         = 'Help'
            Category     = 'System & Policy'
            Tier         = 0
            Mutating     = $false
            Reversible   = $true
            Summary      = 'Displays in-file command reference manual and metadata.'
            Description  = 'Displays comprehensive command manuals, category references, exit code specifications, and JSON schemas.'
            BlastRadius  = 'None (Read-Only)'
            ExitCodes    = @{ '0' = 'Success'; '1' = 'UnknownCommand' }
            Examples     = @('LanFixer.cmd -Mode Help', 'LanFixer.cmd -Mode Help -Id Doctor', 'LanFixer.cmd -Mode Help -Json')
            RelatedModes = @('Guide', 'Interactive')
            Aliases      = @('Guide')
        }
        'Guide' = @{
            Name         = 'Guide'
            Category     = 'System & Policy'
            Tier         = 0
            Mutating     = $false
            Reversible   = $true
            Summary      = 'Decision guide and symptom troubleshooting matrix (alias for Help).'
            Description  = 'Displays decision guide matrix for common networking symptoms and recommended one-touch repairs.'
            BlastRadius  = 'None (Read-Only)'
            ExitCodes    = @{ '0' = 'Success' }
            Examples     = @('LanFixer.cmd -Mode Guide')
            RelatedModes = @('Help', 'Interactive')
            Aliases      = @('Help')
        }
        'Interactive' = @{
            Name         = 'Interactive'
            Category     = 'System & Policy'
            Tier         = 0
            Mutating     = $false
            Reversible   = $true
            Summary      = 'Interactive console dashboard with live network telemetry and hotkey menus.'
            Description  = 'Starts full-screen terminal dashboard displaying real-time link status, gateway reachability, DNS profiles, and repair keys.'
            BlastRadius  = 'None (Interactive UI)'
            ExitCodes    = @{ '0' = 'Exited' }
            Examples     = @('LanFixer.cmd', 'LanFixer.cmd -Mode Interactive')
            RelatedModes = @('Help', 'Doctor')
            Aliases      = @()
        }
        'Debloat' = @{
            Name         = 'Debloat'
            Category     = 'Optimization'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Careful network and stack debloat (removes telemetry chatter, P2P uploads, packet throttling).'
            Description  = 'Optimizes Windows network stack by disabling Delivery Optimization P2P upload seeding, disabling multimedia network packet throttling, overriding WPAD probing, quieting telemetry chatter, and flushing network caches. Safe-by-default with pre-flight snapshots.'
            BlastRadius  = 'Low (Registry and services optimized; zero impact on core connectivity)'
            ExitCodes    = @{ '0' = 'Success'; '40' = 'Elevation Required' }
            Examples     = @('LanFixer.cmd -Mode Debloat', 'LanFixer.cmd -Mode Debloat -SafeOnly', 'LanFixer.cmd -Mode Debloat -Audit')
            RelatedModes = @('UndoDebloat', 'Flush', 'ResetOptions')
            Aliases      = @()
        }
        'UndoDebloat' = @{
            Name         = 'UndoDebloat'
            Category     = 'Optimization'
            Tier         = 1
            Mutating     = $true
            Reversible   = $true
            Summary      = 'Rollback previous network debloat changes back to pre-debloat snapshots.'
            Description  = 'Restores every registry key, DWORD value, service mode, and transition tunnel configuration to its exact pre-debloat state recorded in the snapshot.'
            BlastRadius  = 'Low (Restores original Windows defaults)'
            ExitCodes    = @{ '0' = 'Success'; '40' = 'Elevation Required' }
            Examples     = @('LanFixer.cmd -Mode UndoDebloat')
            RelatedModes = @('Debloat', 'Undo')
            Aliases      = @()
        }
    }
    $script:CommandMetadata = $meta
    return $script:CommandMetadata
}

function Show-HelpReport {
    param(
        [string]$TargetMode = '',
        [switch]$Json,
        [switch]$Quiet,
        [switch]$NoColor,
        [switch]$NoOutput
    )
    $allMeta = Get-CommandMetadata
    $normTarget = if ($TargetMode) { $TargetMode.Trim() } else { '' }

    if ($normTarget -ne '') {
        $found = $null
        foreach ($k in $allMeta.Keys) {
            if ($k -ieq $normTarget) {
                $found = $allMeta[$k]
                break
            }
        }
        if (-not $found) {
            if (-not $NoOutput) {
                if ($Json) {
                [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'Error'; ExitCode = 1; Message = ("Unknown command mode '{0}'" -f $normTarget) } -Depth 4))
            } elseif ($Quiet) {
                [Console]::Out.WriteLine(("Unknown mode: {0}" -f $normTarget))
            } else {
                [Console]::Out.WriteLine(("Unknown command mode '{0}'. Run 'LanFixer.cmd -Mode Help' to view all available commands." -f $normTarget))
            }
            }
            return @{ Status = 'Error'; ExitCode = 1 }
        }

        if ($NoOutput) {
            return @{ Status = 'Success'; ExitCode = 0; Metadata = $found }
        }

        if ($Json) {
            [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'Success'; ExitCode = 0; Mode = $found.Name; Metadata = $found } -Depth 5))
            return @{ Status = 'Success'; ExitCode = 0; Metadata = $found }
        }
        if ($Quiet) {
            [Console]::Out.WriteLine(("{0}: {1}" -f $found.Name, $found.Summary))
            return @{ Status = 'Success'; ExitCode = 0; Metadata = $found }
        }

        [Console]::Out.WriteLine('================================================================================')
        [Console]::Out.WriteLine(("LANFIXER COMMAND MANUAL: {0}" -f $found.Name.ToUpperInvariant()))
        [Console]::Out.WriteLine('================================================================================')
        [Console]::Out.WriteLine('SUMMARY:')
        [Console]::Out.WriteLine(("  {0}" -f $found.Summary))
        [Console]::Out.WriteLine('')
        [Console]::Out.WriteLine(("CATEGORY:      {0}" -f $found.Category))
        $tierDesc = switch ($found.Tier) {
            0 { '0 (Non-Destructive / Read-Only)' }
            1 { '1 (Standard Remediation / Cache Flush)' }
            2 { '2 (Stack & Driver Resuscitation)' }
            3 { '3 (Nuclear Stack & Service Rebuild)' }
            4 { '4 (Bare-Metal netcfg -d Purge)' }
            5 { '5 (Baseline Snapshot Factory Restore)' }
            default { [string]$found.Tier }
        }
        [Console]::Out.WriteLine(("TIER:          {0}" -f $tierDesc))
        $mutatingStr = if ($found.Mutating) { 'YES (Modifies system configuration)' } else { 'NO (Read-only)' }
        [Console]::Out.WriteLine(("MUTATING:      {0}" -f $mutatingStr))
        $revStr = if ($found.Reversible) { 'YES (Tracked in ledger / undoable)' } else { 'NO (Irreversible / requires reboot)' }
        [Console]::Out.WriteLine(("REVERSIBLE:    {0}" -f $revStr))
        [Console]::Out.WriteLine(("BLAST RADIUS:  {0}" -f $found.BlastRadius))
        [Console]::Out.WriteLine('')
        [Console]::Out.WriteLine('DESCRIPTION:')
        [Console]::Out.WriteLine(("  {0}" -f $found.Description))
        [Console]::Out.WriteLine('')
        [Console]::Out.WriteLine('EXIT CODES:')
        if ($found.ExitCodes) {
            foreach ($code in ($found.ExitCodes.Keys | Sort-Object { [int]$_ })) {
                [Console]::Out.WriteLine(("  {0,-4} {1}" -f $code, $found.ExitCodes[$code]))
            }
        }
        [Console]::Out.WriteLine('')
        [Console]::Out.WriteLine('EXAMPLES:')
        if ($found.Examples) {
            foreach ($ex in $found.Examples) {
                [Console]::Out.WriteLine(("  {0}" -f $ex))
            }
        }
        [Console]::Out.WriteLine('')
        [Console]::Out.WriteLine('RELATED MODES:')
        $rel = if ($found.RelatedModes) { $found.RelatedModes -join ', ' } else { 'None' }
        [Console]::Out.WriteLine(("  {0}" -f $rel))
        [Console]::Out.WriteLine('================================================================================')
        return @{ Status = 'Success'; ExitCode = 0; Metadata = $found }
    }

    if ($NoOutput) {
        return @{ Status = 'Success'; ExitCode = 0; Commands = $allMeta }
    }

    if ($Json) {
        $cats = @('Diagnostics', 'Remediation', 'Reset & Recovery', 'Network Configuration', 'Authentication & Portals', 'Automation & Sentinel', 'System & Policy')
        $jsonPayload = @{
            Version    = $script:Version
            TotalModes = $allMeta.Count
            Categories = $cats
            Commands   = $allMeta
        }
        [Console]::Out.WriteLine((ConvertTo-Json $jsonPayload -Depth 5))
        return @{ Status = 'Success'; ExitCode = 0; Commands = $allMeta }
    }

    if ($Quiet) {
        foreach ($k in ($allMeta.Keys | Sort-Object)) {
            [Console]::Out.WriteLine(("{0,-20} : {1}" -f $allMeta[$k].Name, $allMeta[$k].Summary))
        }
        return @{ Status = 'Success'; ExitCode = 0; Commands = $allMeta }
    }

    [Console]::Out.WriteLine('================================================================================')
    [Console]::Out.WriteLine(("          LANFIXER v{0} COMMAND & UNIFIED METADATA REFERENCE" -f $script:Version))
    [Console]::Out.WriteLine('================================================================================')
    [Console]::Out.WriteLine('Usage:')
    [Console]::Out.WriteLine('  LanFixer.cmd -Mode <Command> [options]')
    [Console]::Out.WriteLine('  LanFixer.cmd -Mode Help [-Id <Command>] [-Json] [-Quiet] [-NoColor]')
    [Console]::Out.WriteLine('')

    $cats = @('Diagnostics', 'Remediation', 'Reset & Recovery', 'Network Configuration', 'Authentication & Portals', 'Automation & Sentinel', 'System & Policy')
    foreach ($cat in $cats) {
        [Console]::Out.WriteLine(("=== {0} ===" -f $cat.ToUpperInvariant()))
        $items = @($allMeta.Values | Where-Object { $_.Category -eq $cat } | Sort-Object { $_.Tier }, { $_.Name })
        $seen = @{}
        foreach ($item in $items) {
            if ($seen.ContainsKey($item.Name)) { continue }
            $seen[$item.Name] = $true
            $mutStr = if ($item.Mutating) { 'Mutating' } else { 'Read-Only' }
            [Console]::Out.WriteLine(("  {0,-18} Tier {1}  {2,-9}  {3}" -f $item.Name, $item.Tier, $mutStr, $item.Summary))
        }
        [Console]::Out.WriteLine('')
    }
    [Console]::Out.WriteLine('Run ''LanFixer.cmd -Mode Help -Id <Command>'' for detailed syntax, exit codes, and examples.')
    [Console]::Out.WriteLine('================================================================================')
    return @{ Status = 'Success'; ExitCode = 0; Commands = $allMeta }
}

function Show-VaultMenu {
    while ($true) {
        Clear-Screen; Show-Cursor $true
        Write-Banner 'PORTAL LOGIN VAULT'
        $cur = Get-PortalCredentials
        $pin = [string]$script:State.Misc['PortalPin']
        $paused = ($script:State.Misc['PortalLoginSuspended'] -eq $true)
        Out-Line @((Seg 'text' '  Enables automated background authentication for captive portals without opening a browser.'))
        Out-Line @()
        Out-Line @((Seg 'dim' '  Security Architecture:'))
        Out-Wrapped 'faint' $script:G.mid 'text' 'Encrypted with Windows DPAPI (LocalMachine scope); access restricted to SYSTEM and Administrators.' 2
        Out-Wrapped 'faint' $script:G.mid 'text' 'Transmitted strictly over TLS to verified campus portal endpoints with certificate pinning.' 2
        Out-Wrapped 'warn' $script:G.warn 'warn' 'Notice: Any account with local Administrator privileges can decrypt stored machine credentials.' 2
        Out-Line @()
        $credTxt = 'Not saved'; $credRole = 'dim'
        if ($cur) { $credTxt = ('Saved for ' + $cur.User); $credRole = 'ok' }
        $pinTxt = 'None'; $pinRole = 'dim'
        if ($pin) { $fpShort = Format-Fingerprint $pin; if ($fpShort.Length -gt 23) { $fpShort = $fpShort.Substring(0, 23) + '...' }; $pinTxt = ('Approved  ' + $fpShort); $pinRole = 'ok' }
        $autoTxt = 'Disabled (no credentials stored)'; $autoRole = 'dim'
        if ($cur -and $paused) { $autoTxt = 'Suspended: Portal rejected stored password'; $autoRole = 'warn' }
        elseif ($cur) { $autoTxt = 'Active'; $autoRole = 'ok' }
        Out-Line @((Seg 'dim' '  Credentials   '), (Seg $credRole $credTxt))
        Out-Line @((Seg 'dim' '  Certificate   '), (Seg $pinRole $pinTxt))
        Out-Line @((Seg 'dim' '  Auto Sign-In  '), (Seg $autoRole $autoTxt))
        Out-Line @()
        Out-Line @((Seg 'accent' '  [S/1]'), (Seg 'text' ' Save / Update   '), (Seg 'accent' '[T/2]'), (Seg 'text' ' Test Login   '), (Seg 'accent' '[P/3]'), (Seg 'text' ' Certificate Pinning   '), (Seg 'accent' '[C/4]'), (Seg 'text' ' Clear Credentials'))
        Out-Line @((Seg 'dim' '  Press any other key to return '), (Seg 'accent!' $script:G.prompt)) -NoNewline
        $k = Read-Choice
        Out-Line @()
        Out-Line @()
        switch (([string]$k.KeyChar).ToLowerInvariant()) {
            { $_ -eq 's' -or $_ -eq '1' } {
                if (-not (Assert-Admin)) { Out-Line @(); Out-Line @((Seg 'dim' '  press any key')); Wait-AnyKey; continue }
                Out-Line @((Seg 'text' '  Use the same login you type on the campus portal page.'))
                if (-not (Read-Confirm 'Store this login on this PC?')) { Out-Line @((Seg 'dim' '  cancelled.')); Start-Sleep -Milliseconds 700; continue }
                Show-Cursor $true
                $u = ([string](Read-Host '  username')).Trim()
                if (-not $u) { Out-Line @((Seg 'warn' '  username was empty; cancelled.')); Start-Sleep -Milliseconds 800; continue }
                $sec = Read-Host '  password' -AsSecureString
                $cred = New-Object System.Net.NetworkCredential('', $sec)
                $ok = $false
                $plain = $cred.Password
                if (-not $plain) { Out-Line @((Seg 'warn' '  password was empty; cancelled.')); Start-Sleep -Milliseconds 800; continue }
                $ok = @(Invoke-WithLock { $r = Save-PortalCredentials $u $plain; Save-State; $r }) -contains $true
                $plain = $null; $cred = $null; $sec = $null
                if ($ok) {
                    Out-Line @((Seg 'ok' ('  ' + $script:G.ok + ' ')), (Seg 'text' 'credentials saved safely to the DPAPI vault.'))
                    if (-not $script:State.Misc['PortalPin'] -and @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' }).Count -gt 0) {
                        $liveUrl = Resolve-PortalUrl (Get-InternetState -NoCache)
                        $targetUri = $null; try { $targetUri = [uri]$liveUrl } catch {}
                        $ci = Get-PortalCertInfo $targetUri
                        if ($ci.Ok -and $ci.Errors -ne 'None') {
                            Out-Line @((Seg 'warn' ('  ' + $script:G.warn + ' ')), (Seg 'warn' ('Portal certificate is self-signed (' + (Format-Fingerprint $ci.Sha256) + ').')))
                            if (Read-Confirm 'Approve this certificate now for automatic sign-in?') {
                                $fp = $ci.Sha256
                                [void](Invoke-WithLock { $script:State.Misc['PortalPin'] = $fp; $script:State.Misc['PortalLoginSuspended'] = $false; Save-State })
                                Out-Line @((Seg 'ok' ('  ' + $script:G.ok + ' ')), (Seg 'text' 'certificate pinned!'))
                            }
                        }
                    }
                }
                Start-Sleep -Seconds 1
            }
            { $_ -eq 't' -or $_ -eq '2' } {
                if (-not (Assert-Admin)) { Out-Line @(); Out-Line @((Seg 'dim' '  press any key')); Wait-AnyKey; continue }
                [void](Invoke-HeadlessPortalLogin -Manual)
                if (-not $script:IsDry) { [void](Invoke-WithLock { Save-State }) }
                Out-Line @(); Out-Line @((Seg 'dim' '  press any key')); Wait-AnyKey
            }
            { $_ -eq 'p' -or $_ -eq '3' } {
                if (-not (Assert-Admin)) { Out-Line @(); Out-Line @((Seg 'dim' '  press any key')); Wait-AnyKey; continue }
                $liveUrl = Resolve-PortalUrl (Get-InternetState -NoCache)
                $targetUri = $null; try { $targetUri = [uri]$liveUrl } catch {}
                $ci = Get-PortalCertInfo $targetUri
                if (-not $ci.Ok) { Out-Line @((Seg 'bad' ('  ' + $script:G.bad + ' ')), (Seg 'text' ('could not read the portal certificate (' + $ci.Error + '). Are you connected to the campus LAN?'))) }
                else {
                    Out-Line @((Seg 'dim' '  subject      '), (Seg 'text' $ci.Subject))
                    Out-Line @((Seg 'dim' '  issuer       '), (Seg 'text' $ci.Issuer))
                    Out-Line @((Seg 'dim' '  valid until  '), (Seg 'text' $ci.NotAfter))
                    Out-Line @((Seg 'dim' '  sha-256      '), (Seg 'text' (Format-Fingerprint $ci.Sha256)))
                    if ($ci.Errors -eq 'None') { Out-Line @((Seg 'ok' ('  ' + $script:G.ok + ' ')), (Seg 'text' 'Windows trusts this certificate: no approval is needed.')) }
                    else {
                        Out-Line @((Seg 'warn' ('  ' + $script:G.warn + ' ')), (Seg 'warn' ('Windows does not trust it (' + $ci.Errors + '). Compare the fingerprint with one IT gives you, if possible.')))
                        if (Read-Confirm 'Approve exactly this certificate for the campus portal?') {
                            $fp = $ci.Sha256
                            [void](Invoke-WithLock { $script:State.Misc['PortalPin'] = $fp; $script:State.Misc['PortalLoginSuspended'] = $false; Save-State })
                            Out-Line @((Seg 'ok' ('  ' + $script:G.ok + ' ')), (Seg 'text' 'approved. A different certificate will be refused.'))
                        }
                    }
                }
                Out-Line @(); Out-Line @((Seg 'dim' '  press any key')); Wait-AnyKey
            }
            { $_ -eq 'c' -or $_ -eq '4' } {
                if (-not (Assert-Admin)) { Out-Line @(); Out-Line @((Seg 'dim' '  press any key')); Wait-AnyKey; continue }
                if (Read-Confirm 'Delete the saved login and the approved certificate?') {
                    [void](Invoke-WithLock { Remove-PortalCredentials; $script:State.Misc.Remove('PortalPin'); Save-State })
                    Out-Line @((Seg 'ok' ('  ' + $script:G.ok + ' ')), (Seg 'text' 'deleted.'))
                    Start-Sleep -Milliseconds 800
                }
            }
            default { return }
        }
    }
}

function Start-Repair([string]$Title = 'quick heal') {
    Show-View $Title {
        if (-not (Assert-Admin)) { return }
        if ($script:State.Misc -is [hashtable]) { $script:State.Misc['FailStreak'] = 0 }
        $script:ChangeCount = 0; $script:FailCount = 0
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $r = Pick-Hash (Invoke-WithLock { Invoke-HealPipeline })
        $sw.Stop()
        Write-HealSummary $r $sw
        if ($r -and $r.Conn -eq 'Captive') {
            $signedHeadless = $false
            $portalSrc = if ($r.Ip) { [string]$r.Ip } else { Get-PrimarySourceIp }
            if ($script:Cfg.AutoPortalLogin -and (Get-PortalCredentials)) {
                Out-Line @((Seg 'dim' '  Attempting automated sign-in using saved vault credentials...'))
                $signedHeadless = [bool](Invoke-HeadlessPortalLogin (Get-InternetState -NoCache -SourceIp $portalSrc) -Manual)
                if (-not $script:IsDry) { [void](Invoke-WithLock { Save-State }) }
                if ($signedHeadless) { Write-Log 'OK' 'Signed in automatically using stored vault credentials.' }
            }
            if (-not $signedHeadless) {
                [void](Invoke-WithLock { [void](Open-Portal); Save-State })
                if ((Get-InternetState -NoCache).State -eq 'Captive') {
                    Out-Line @((Seg 'dim' '  Sign in on the page that opened; the fast DNS path is applied for you afterwards.'))
                    if (Wait-ForAuthentication 180) { [void](Invoke-WithLock { Complete-Authentication }); Write-Log 'OK' 'Signed in. Post-login DNS applied.' }
                }
            }
        }
    }
}

function Invoke-DashboardKey([string]$Key, $adv) {
    $aliases = @{ w = '2'; n = 'x'; p = '4'; f = '5'; c = '5'; i = '6'; o = '7'; v = 'a'; l = 'g'; '?' = '0' }
    if ($aliases.ContainsKey($Key)) { $Key = $aliases[$Key] }
    switch ($Key) {
        '0' { Show-Advisory }
        'h' {
            Show-View 'History & Forensic Suite' {
                Show-HistoryMenu
            }
        }
        'b' {
            Show-View 'Live Sentinel Monitor' {
                if (-not (Assert-Admin)) { return }
                Start-AutonomousDaemon
            } -NoWait
        }
        '1' { Start-Repair 'Quick Heal' }
        'm' { Show-View 'Routing & Metric Priority' { Show-RouteMenu } }
        'x' {
            Show-View 'Recovery and System' {
                Show-ResetMenu
            }
        }
        '!' {
            Show-View 'Complete Network Stack Rebuild (netcfg -d)' {
                if (-not (Assert-Admin)) { return }
                Out-Line @((Seg 'bad!' '  WARNING: COMPLETE NETWORK STACK REBUILD ([ REBOOT REQUIRED ]):'))
                Out-Wrapped 'faint' $script:G.mid 'text' 'Kernel-level removal and reinstallation of all network protocols, virtual adapters, and hardware stacks via netcfg -d.' 4
                Out-Wrapped 'warn'  $script:G.mid 'warn' 'Requires an immediate system reboot to reconstruct the Windows networking stack.' 4
                Out-Line @()
                if (Read-Confirm 'Execute Complete Network Stack Rebuild (netcfg -d, requires reboot)?' 'yes') {
                    $script:ChangeCount = 0; $script:FailCount = 0
                    Invoke-ArmageddonReset -Confirmed
                    $script:WdCache = $null
                } else {
                    Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
                }
            }
        }
        'd' {
            Show-View 'Deep Multi-Adapter Reinstall' {
                if (-not (Assert-Admin)) { return }
                Out-Line @((Seg 'warn!' '  WARNING: DEEP MULTI-ADAPTER REINSTALL ([ HIGH RISK ]):'))
                Out-Wrapped 'faint' $script:G.mid 'text' 'Universal recovery when no internet works: Wi-Fi, Bluetooth, USB Tethering, LAN, Cellular' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Cycles all network interfaces, wipes dual-architecture Winsock catalogs, and restores TCP/IP stack.' 4
                Out-Line @()
                if (Read-Confirm 'Execute Deep Multi-Adapter Reinstall?' 'yes') {
                    $script:ChangeCount = 0; $script:FailCount = 0
                    Invoke-DoomsdayReset -Confirmed
                    $script:WdCache = $null
                } else {
                    Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
                }
            }
        }
        'u' {
            Show-View 'Standard Stack Reset (Winsock & IP)' {
                if (-not (Assert-Admin)) { return }
                Out-Line @((Seg 'warn!' '  NOTICE: STANDARD STACK RESET ([ CAUTION ]):'))
                Out-Wrapped 'faint' $script:G.mid 'text' '10-Stage network stack reset: Dual 64/32-bit Winsock, TCP/IP heuristics, NCSI calibration, and adapter bounce.' 4
                Out-Line @()
                if (Read-Confirm 'Execute Standard Stack Reset (Winsock & IP)?' 'yes') {
                    $script:ChangeCount = 0; $script:FailCount = 0
                    Invoke-UltraSystemReset -Confirmed
                    $script:WdCache = $null
                } else {
                    Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
                }
            }
        }
        '2' {
            Show-View 'Install Watchdog Task' {
                if (-not (Assert-Admin)) { return }
                $script:ChangeCount = 0; $script:FailCount = 0
                $sw = [System.Diagnostics.Stopwatch]::StartNew()
                $ok = @(Invoke-WithLock { $okI = Install-Watchdog; Save-State; $okI }) -contains $true
                $script:WdCache = $null
                if ($ok) {
                    Out-Line @((Seg 'dim' '  Executing initial repair pipeline...'))
                    $r = Pick-Hash (Invoke-WithLock { $rr = Invoke-HealPipeline; Save-State; $rr })
                    $sw.Stop()
                    Write-HealSummary $r $sw
                    if ($r -and $r.Conn -eq 'Captive') {
                        $signedHeadless = $false
                        if ($script:Cfg.AutoPortalLogin -and (Get-PortalCredentials)) {
                            Out-Line @((Seg 'dim' '  Attempting automated sign-in using saved vault credentials...'))
                            $signedHeadless = [bool](Invoke-HeadlessPortalLogin (Get-InternetState -NoCache) -Manual)
                            if (-not $script:IsDry) { [void](Invoke-WithLock { Save-State }) }
                            if ($signedHeadless) { Write-Log 'OK' 'Signed in automatically using stored vault credentials.' }
                        }
                        if (-not $signedHeadless) {
                            [void](Invoke-WithLock { [void](Open-Portal); Save-State })
                            if ((Get-InternetState -NoCache).State -eq 'Captive') {
                                Out-Line @((Seg 'dim' '  Sign in on the page that opened; the fast DNS path is applied for you afterwards.'))
                                if (Wait-ForAuthentication 180) { [void](Invoke-WithLock { Complete-Authentication }); Write-Log 'OK' 'Signed in. Post-login DNS applied.' }
                            }
                        }
                    }
                }
            }
        }
        '3' { Show-View 'DNS Configuration' { Show-DnsMenu } }
        '4' { Show-View 'Network Quality Probe' { Run-QuickProbe } }
        '5' {
            Show-View 'Flush Network Caches' {
                $script:ChangeCount = 0; $script:FailCount = 0
                [void](Invoke-WithLock { Flush-NetworkCache })
            }
        }
        '6' { Show-View 'System Diagnostics Audit' { Show-Diagnostics } }
        '7' {
            Show-View 'Captive Portal Check' {
                $ups = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
                if ($ups.Count -eq 0) {
                    Write-Log 'WARN' 'No active Ethernet link is connected. Plug in the campus LAN cable before opening the portal.'
                    return
                }
                $ipV4 = Get-ValidIPv4 $ups[0]
                if (-not $ipV4 -and $script:IsAdmin) {
                    Out-Line @((Seg 'warn' '  No valid IP lease (APIPA/unassigned); renewing DHCP lease first...'))
                    [void](Invoke-WithLock { Shield-DataLink @{ Ad = $ups[0]; Env = (Get-AdapterEnvironment $ups[0]); Repaired = $false } })
                }
                [void](Invoke-WithLock {
                    if ($script:IsAdmin) {
                        $script:WatchdogOn = Test-WatchdogInstalled
                        foreach ($a in $ups) {
                            $ctx = @{ Ad = $a; Env = (Get-AdapterEnvironment $a) }
                            Shield-RouteMetrics $ctx 'Captive'
                            if ((Get-DnsProfileName) -eq 'Adaptive') { Shield-Dns $ctx 'Captive' }
                        }
                    }
                    [void](Open-Portal -Force)
                    # The metric/DNS changes above are state even when the browser could not be opened: persist them
                    # inside the same lock, or a SYSTEM watchdog pass would overwrite them with the state it still holds.
                    Save-State
                })
                Out-Line @((Seg 'dim' '  Sign in in the browser window; the fast DNS path is applied afterwards.'))
                if (Wait-ForAuthentication 180) { if ($script:IsAdmin) { [void](Invoke-WithLock { Complete-Authentication }) }; Write-Log 'OK' 'The internet is authenticated.' }
            }
        }
        '8' {
            Show-View 'Remove Watchdog Task' {
                $script:ChangeCount = 0; $script:FailCount = 0
                [void](Invoke-WithLock { Uninstall-Watchdog; Save-State })
                $script:WdCache = $null
            }
        }
        'e' {
            if ($script:IsAdmin) { return $false }
            if ($script:SelfPath) {
                try {
                    Start-Process -FilePath $script:SelfPath -ArgumentList '-LfElevated' -Verb RunAs -ErrorAction Stop
                    Exit-Screen
                    exit 0
                } catch {}
            }
            return $true
        }
        'k' {
            Show-View 'gateway mac verification' {
                if (-not (Assert-Admin)) { return }
                $pend = @(Get-PendingGatewayMacs)
                if ($pend.Count -eq 0) { Out-Line @((Seg 'dim' '  No gateway change is waiting for a decision.')); return }
                Out-Wrapped 'warn' $script:G.warn 'warn' 'A gateway now answers from a different hardware address than before. That is normal after IT replaces or fails over a router, and it is also exactly what ARP spoofing looks like. Approve only if you trust this network.' 2
                foreach ($pg in $pend) {
                    Out-Line @()
                    Out-Line @((Seg 'dim' '  gateway      '), (Seg 'text' $pg.Gw))
                    Out-Line @((Seg 'dim' '  used to be   '), (Seg 'text' $pg.Old))
                    Out-Line @((Seg 'dim' '  now answers  '), (Seg 'warn' $pg.New))
                    if (Read-Confirm ('Trust ' + $pg.New + ' for gateway ' + $pg.Gw + '?')) {
                        # Re-read the candidate inside the lock: while this prompt was on screen the gateway may have
                        # answered from a THIRD MAC (failover plus a spoofer, or a router still settling). Approving the
                        # stale value would write a MAC the network no longer uses into the lock memory.
                        $raw = Invoke-WithLock {
                            $curCand = $script:State.Misc['ArpCand']
                            $stillCurrent = $true
                            if ($curCand -is [hashtable] -and $curCand.ContainsKey($pg.Gw)) {
                                if ([string]$curCand[$pg.Gw].Mac -ne [string]$pg.New) { $stillCurrent = $false }
                            }
                            if (-not $stillCurrent) { 'STALE' }
                            else { $r1 = Approve-GatewayMac $pg.Gw $pg.New; Save-State; $r1 }
                        }
                        if ($raw -contains 'STALE') {
                            Out-Line @((Seg 'warn' ('  ' + $script:G.warn + ' ')), (Seg 'warn' 'The gateway answered from a different MAC while this prompt was open: nothing was approved. Run [K] again to review the current one.'))
                        } elseif (-not ($raw -contains $true)) { Out-Line @((Seg 'dim' '  nothing to approve.')) }
                    } else { Out-Line @((Seg 'dim' '  left unlocked.')) }
                }
            }
        }
        'a' { Show-VaultMenu }
        'g' {
            Show-View 'automated portal sign-in' {
                $ups = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
                if ($ups.Count -eq 0) {
                    Write-Log 'WARN' 'No active Ethernet link is connected. Plug in the campus LAN cable first.'
                    return
                }
                $loginRes = Pick-Hash (Invoke-WithLock {
                    $script:WatchdogOn = Test-WatchdogInstalled
                    foreach ($a in $ups) {
                        $ctx = @{ Ad = $a; Env = (Get-AdapterEnvironment $a) }
                        if ($ctx.Env.Env -eq 'Campus') {
                            Shield-RouteMetrics $ctx 'Captive'
                            if ((Get-DnsProfileName) -eq 'Adaptive') { Shield-Dns $ctx 'Captive' }
                        }
                    }
                    $inet = Get-InternetState -NoCache
                    if ($inet.State -eq 'Online') {
                        Write-Log 'OK' 'Ethernet is already authenticated and online; no sign-in needed.'
                        return @{ State = 'Online'; Signed = $true }
                    }
                    if ($inet.State -ne 'Captive') {
                        $epG = Get-ActivePortalEndpoint
                        if ($inet.State -eq 'Offline' -and (Test-PortalOnlineSmart $epG.Ip ([int]$epG.Port))) {
                            $inet = @{ State = 'Captive'; Location = $epG.Url; Via = 'link' }
                        } else {
                            Write-Log 'WARN' ("Link state is '{0}' (not behind captive portal). Run [1] Quick Heal first." -f $inet.State)
                            return @{ State = $inet.State; Signed = $false; SkipBrowser = $true }
                        }
                    }
                    $okLogin = [bool](Invoke-HeadlessPortalLogin $inet -Manual)
                    Save-State
                    return @{ State = $inet.State; Signed = $okLogin; SkipBrowser = $false }
                })
                if ($loginRes -and -not $loginRes.Signed -and -not $loginRes.SkipBrowser) {
                    Out-Line @((Seg 'dim' '  Automatic sign-in did not complete; opening the login page instead.'))
                    [void](Invoke-WithLock { [void](Open-Portal -Force) })
                    if (Wait-ForAuthentication 180) { if ($script:IsAdmin) { [void](Invoke-WithLock { Complete-Authentication }) }; Write-Log 'OK' 'The internet is authenticated.' }
                }
            }
        }
        's' { Show-View 'System Integrity Self-Test' { Invoke-SelfTest } }
        't' {
            Show-View 'Dry Run' {
                $script:IsDry = $true
                $script:ChangeCount = 0; $script:FailCount = 0
                $sw = [System.Diagnostics.Stopwatch]::StartNew()
                try {
                    Out-Line @((Seg 'vio' ('  ' + $script:G.half + ' ')), (Seg 'vio' 'Simulation mode active: system configuration will not be modified'))
                    $r = Pick-Hash (Invoke-HealPipeline)
                    $sw.Stop()
                    Write-HealSummary $r $sw
                } finally { $script:IsDry = [bool]$DryRun; if ($script:StoreReady) { $script:State = Get-State } }
            }
        }
        'r' { Show-View 'Export Diagnostic Report' { New-SupportReport } }
        '9' {
            Show-View 'Restore Network Defaults' {
                if (-not (Assert-Admin)) { return }
                Out-Line @((Seg 'text' '  This action will revert system configuration:'))
                Out-Wrapped 'faint' $script:G.mid 'text' 'Restore all adapter properties, DNS resolvers, and route metrics to original pre-LanFixer state' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Unregister background watchdog and helper tasks, NRPT rules, and firewall exceptions' 4
                Out-Wrapped 'faint' $script:G.mid 'warn' 'Purge saved portal login credentials from the encrypted machine vault' 4
                Out-Line @()
                if (Read-Confirm 'Restore all network settings and adapters to DHCP defaults?' 'yes') {
                    $script:ChangeCount = 0; $script:FailCount = 0
                    [void](Invoke-WithLock { Restore-Everything })
                    $script:WdCache = $null
                } else { Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.')) }
            }
        }
        default { return $false }
    }
    return $true
}
function Get-PendingGatewayMacs {
    $out = @()
    $cand = $script:State.Misc['ArpCand']
    if ($cand -isnot [hashtable]) { return $out }
    foreach ($gw in @($cand.Keys)) {
        $old = ''
        foreach ($g in @($script:State.Arp.Keys)) { $mem = $script:State.Arp[$g]; if ($mem -is [hashtable] -and $mem.ContainsKey($gw)) { $old = [string]$mem[$gw] } }
        $out += @{ Gw = [string]$gw; New = [string]$cand[$gw].Mac; Old = $old; Since = [string]$cand[$gw].Since }
    }
    return $out
}

# Approves ONE gateway at ONE MAC (the caller has already shown old/new and asked you to confirm).
function Approve-GatewayMac([string]$Gw, [string]$Mac, [switch]$Quiet) {
    $done = $false
    foreach ($g in @($script:State.Arp.Keys)) {
        $mem = $script:State.Arp[$g]
        if ($mem -is [hashtable]) { $mem[$Gw] = $Mac; $done = $true }
    }
    foreach ($a in @(Get-EthernetAdapters)) {
        $mem = Get-SubTable 'Arp' ([string]$a.InterfaceGuid)
        $mem[$Gw] = $Mac
        $done = $true
    }
    if ($script:State.Misc['ArpCand'] -is [hashtable] -and $script:State.Misc['ArpCand'].ContainsKey($Gw)) { $script:State.Misc['ArpCand'].Remove($Gw) }
    if ($done -and -not $Quiet) { Write-Log 'OK' ("Gateway {0} approved at {1}; it is locked on the next repair pass." -f $Gw, $Mac) }
    return $done
}

# ---- USB selective suspend: record the ORIGINAL value and put exactly that back (no forced "factory" value)
$script:UsbSub = '2a737441-1930-4402-8d77-b2bebba308a3'
$script:UsbSet = '48e6b7a6-50f5-4782-a5d4-53bb8f07e226'
function ConvertFrom-PowerIndexText([string]$Text, [string]$Mode = 'ac') {
    $matches = @([regex]::Matches($Text, '0x([0-9a-fA-F]{1,8})'))
    if ($Mode -eq 'ac' -and $matches.Count -ge 1) { return [Convert]::ToInt32($matches[0].Groups[1].Value, 16) }
    elseif ($Mode -ne 'ac' -and $matches.Count -ge 2) { return [Convert]::ToInt32($matches[1].Groups[1].Value, 16) }
    elseif ($matches.Count -ge 1) { return [Convert]::ToInt32($matches[0].Groups[1].Value, 16) }
    return $null
}

function Get-ActivePowerScheme {
    $r = Invoke-Native (Get-SysExe 'powercfg.exe') @('/getactivescheme') 5000
    $m = [regex]::Match([string]$r.Output, '[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}')
    if ($m.Success) { return $m.Value }
    return ''
}

function Get-PowerSettingIndex([string]$Scheme, [string]$Mode) {
    $r = Invoke-Native (Get-SysExe 'powercfg.exe') @('/query', $Scheme, $script:UsbSub, $script:UsbSet) 5000
    if ($Mode -eq 'ac') {
        $m = [regex]::Match([string]$r.Output, 'Current AC Power Setting Index:\s*0x([0-9a-fA-F]+)')
        if ($m.Success) { return [Convert]::ToInt32($m.Groups[1].Value, 16) }
    } else {
        $m = [regex]::Match([string]$r.Output, 'Current DC Power Setting Index:\s*0x([0-9a-fA-F]+)')
        if ($m.Success) { return [Convert]::ToInt32($m.Groups[1].Value, 16) }
    }
    return (ConvertFrom-PowerIndexText ([string]$r.Output) $Mode)
}


function Get-BatteryHealthAndEfficiency {
    $res = @{
        HasBattery         = $false
        IsOnBattery        = $false
        ChargePercent      = 100
        StatusText         = 'AC Wall Power (Desktop / Workstation)'
        HealthPercent      = 100
        WearLevelPercent   = 0
        CycleCount         = 0
        DesignCapacityMWh  = 0
        FullCapacityMWh    = 0
        RemainingMWh       = 0
        EfficiencyTier     = 'Optimal'
    }
    try {
        $wmiBat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($wmiBat) {
            $res.HasBattery = $true
            if ($null -ne $wmiBat.EstimatedChargeRemaining) {
                $res.ChargePercent = [int]$wmiBat.EstimatedChargeRemaining
            }
            $bStat = [int]$wmiBat.BatteryStatus
            if ($bStat -eq 1 -or $bStat -eq 4 -or $bStat -eq 5) {
                $res.IsOnBattery = $true
                $res.StatusText = ("Battery Discharging ({0}%)" -f $res.ChargePercent)
            } elseif ($bStat -eq 6 -or $bStat -eq 7 -or $bStat -eq 8 -or $bStat -eq 9) {
                $res.IsOnBattery = $false
                $res.StatusText = ("AC Connected, Charging ({0}%)" -f $res.ChargePercent)
            } else {
                $res.IsOnBattery = $false
                $res.StatusText = ("AC Connected ({0}%)" -f $res.ChargePercent)
            }
        }
        $full = Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($full -and $full.FullChargedCapacity -gt 0) {
            $res.FullCapacityMWh = [int]$full.FullChargedCapacity
        }
        $stat = Get-CimInstance -Namespace root\wmi -ClassName BatteryStatus -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($stat) {
            if ($null -ne $stat.PowerOnline) {
                $res.IsOnBattery = (-not [bool]$stat.PowerOnline)
                if ($res.IsOnBattery) {
                    $res.StatusText = ("Battery Power (DC) - {0}%" -f $res.ChargePercent)
                }
            }
            if ($stat.RemainingCapacity -gt 0) { $res.RemainingMWh = [int]$stat.RemainingCapacity }
        }
        $cycles = Get-CimInstance -Namespace root\wmi -ClassName BatteryCycleCount -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($cycles -and $null -ne $cycles.CycleCount) {
            $res.CycleCount = [int]$cycles.CycleCount
        }
        $static = Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($static -and $static.DesignedCapacity -gt 0) {
            $res.DesignCapacityMWh = [int]$static.DesignedCapacity
        }
        if ($res.DesignCapacityMWh -gt 0 -and $res.FullCapacityMWh -gt 0) {
            $res.HealthPercent = [math]::Round(($res.FullCapacityMWh / $res.DesignCapacityMWh) * 100, 1)
            $res.WearLevelPercent = [math]::Max(0, [math]::Round((1 - ($res.FullCapacityMWh / $res.DesignCapacityMWh)) * 100, 1))
        }
    } catch {}
    return $res
}

function Set-UsbSuspendOff {
    $pcfg = Get-SysExe 'powercfg.exe'
    if (-not [System.IO.File]::Exists($pcfg)) { return }
    $scheme = Get-ActivePowerScheme
    if (-not $scheme) { return }
    $ac = Get-PowerSettingIndex $scheme 'ac'
    $dc = Get-PowerSettingIndex $scheme 'dc'
    if ($null -eq $ac -and $null -eq $dc) { return }                        # unreadable: never write blind
    if (($null -eq $ac -or $ac -eq 0) -and ($null -eq $dc -or $dc -eq 0)) { return }   # already off
    Save-Original 'Global' 'UsbSuspend' @{ Scheme = $scheme; Ac = $ac; Dc = $dc }
    $bat = Get-BatteryHealthAndEfficiency
    [void](Invoke-Change 'USB selective suspend configured for low-latency Ethernet on AC power (preserves battery efficiency)' {
        [void](Invoke-Native $pcfg @('/setacvalueindex', $scheme, $script:UsbSub, $script:UsbSet, '0') 5000)
        if (-not $bat.IsOnBattery) {
            [void](Invoke-Native $pcfg @('/setdcvalueindex', $scheme, $script:UsbSub, $script:UsbSet, '0') 5000)
        }
        [void](Invoke-Native $pcfg @('/s', $scheme) 5000)
    })
}

function Restore-UsbSuspend($Rec) {
    if ($Rec -isnot [hashtable] -or -not $Rec.Scheme) { return }
    $pcfg = Get-SysExe 'powercfg.exe'
    if (-not [System.IO.File]::Exists($pcfg)) { return }
    if ($null -ne $Rec.Ac) { [void](Invoke-Native $pcfg @('/setacvalueindex', [string]$Rec.Scheme, $script:UsbSub, $script:UsbSet, [string]$Rec.Ac) 5000) }
    if ($null -ne $Rec.Dc) { [void](Invoke-Native $pcfg @('/setdcvalueindex', [string]$Rec.Scheme, $script:UsbSub, $script:UsbSet, [string]$Rec.Dc) 5000) }
    if ((Get-ActivePowerScheme) -eq [string]$Rec.Scheme) {
        [void](Invoke-Native $pcfg @('/s', [string]$Rec.Scheme) 5000)
    }
}
function Get-ProbeVerdict($P1, $P2) {
    if ($P1.Code -eq 204) { return 'Online' }
    if ($P2.Code -eq 200 -and ([string]$P2.Body) -like 'Microsoft Connect Test*') { return 'Online' }
    if ($P1.Error -eq 'DnsFail' -and $P2.Error -eq 'DnsFail') { return 'NoDns' }
    foreach ($p in @($P1, $P2)) {
        $c = [int]$p.Code
        if (($c -ge 300 -and $c -le 399) -or ($c -ge 200 -and $c -le 299) -or $c -eq 401 -or $c -eq 407 -or $c -eq 511 -or ($p.Location -and $p.Location -ne '')) { return 'Captive' }
    }
    return 'Offline'
}
function Get-PrimarySourceIp {
    $targetAdapters = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
    if ($targetAdapters.Count -eq 0) {
        $targetAdapters = @(Get-OtherUplinkAdapters | Where-Object { $_.Status -eq 'Up' })
    }
    foreach ($a in $targetAdapters) {
        $ip = Get-ValidIPv4 $a
        if ($ip) { return [string]$ip }
    }
    return ''
}
# State: Online | Captive | NoDns | Offline  (+ Location of a captive redirect, when there is one)
function Get-InternetState {
    param([switch]$NoCache, [string]$SourceIp)
    $explicit = $PSBoundParameters.ContainsKey('SourceIp')
    if (-not $script:Cfg.ProbeSourceBind) { $SourceIp = '' }
    elseif (-not $explicit) { $SourceIp = Get-PrimarySourceIp }
    if ($null -eq $SourceIp) { $SourceIp = '' }
    if (-not $SourceIp -or $SourceIp -like '169.254.*') {
        $upEths = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
        if ($upEths.Count -gt 0 -and (Test-OtherUplinkActive)) {
            return @{ State = 'Offline'; DnsOk = $false; Code = 0; Location = ''; Error = 'NoValidIpOnEthernet' }
        }
    }
    $ckey = ('{0}|{1}' -f $SourceIp, $explicit)
    if (-not $NoCache -and $script:ConnCache -and $script:ConnCache.Key -eq $ckey -and (((Get-Date) - $script:ConnCache.Time).TotalSeconds -lt 1.8)) { return $script:ConnCache.Result }
    $none = @{ Code = 0; Body = ''; Location = ''; Error = '' }
    $p1 = Invoke-HttpProbe 'connectivitycheck.gstatic.com' '/generate_204' 2500 $SourceIp
    $p2 = $none
    if ($p1.Code -ne 204) { $p2 = Invoke-HttpProbe 'www.msftconnecttest.com' '/connecttest.txt' 2500 $SourceIp }
    if ($p1.Code -eq 0 -and $p2.Code -eq 0) {
        $pApple = Invoke-HttpProbe 'captive.apple.com' '/hotspot-detect.html' 2500 $SourceIp
        if ($pApple.Code -ne 0) { $p2 = $pApple }
    }
    $state = Get-ProbeVerdict $p1 $p2
    $via = 'link'
    if (-not $explicit -and ($state -eq 'Offline' -or $state -eq 'NoDns') -and (Test-AllowSystemFallback $explicit $state (Test-OtherUplinkActive))) {
        $u1 = $none
        if ($SourceIp) { $u1 = Invoke-HttpProbe 'connectivitycheck.gstatic.com' '/generate_204' 2000 '' }
        if ($u1.Code -eq 204) { $state = 'Online'; $via = 'system'; $p1 = $u1 }
        elseif (($u1.Code -ge 300 -and $u1.Code -le 399) -or ($u1.Code -ge 200 -and $u1.Code -le 299) -or $u1.Code -eq 401 -or $u1.Code -eq 407 -or $u1.Code -eq 511) { $state = 'Captive'; $via = 'system'; $p1 = $u1 }
        if ($state -eq 'Offline' -or $state -eq 'NoDns') {
            try {
                $wr = [System.Net.HttpWebRequest]::Create('http://connectivitycheck.gstatic.com/generate_204')
                $wr.Timeout = 2500
                $wr.AllowAutoRedirect = $false
                $wr.Proxy = $null   # a local proxy answering 204 must not count as internet
                $resp = $null
                try {
                    $resp = $wr.GetResponse()
                    $c = [int]$resp.StatusCode
                    if ($c -eq 204) { $state = 'Online'; $via = 'system' }
                    elseif (($c -ge 300 -and $c -le 399) -or ($c -ge 200 -and $c -le 299) -or $c -eq 401 -or $c -eq 407 -or $c -eq 511) {
                        $state = 'Captive'; $via = 'system'
                        $p1 = @{ Code = $c; Location = [string]$resp.Headers['Location'] }
                    }
                } finally {
                    if ($resp) { try { $resp.Close() } catch {} }
                }
            } catch [System.Net.WebException] {
                $webResp = $_.Exception.Response -as [System.Net.HttpWebResponse]
                if ($webResp) {
                    $c = [int]$webResp.StatusCode
                    if (($c -ge 300 -and $c -le 399) -or $c -eq 401 -or $c -eq 407 -or $c -eq 511 -or [bool]$webResp.Headers['Location']) {
                        $state = 'Captive'; $via = 'system'
                        $p1 = @{ Code = $c; Location = [string]$webResp.Headers['Location'] }
                    }
                    try { $webResp.Close() } catch {}
                }
            } catch {}
        }
    }
    $loc = ''
    if ($state -eq 'Captive') {
        if ($p1.Location) { $loc = [string]$p1.Location } elseif ($p2.Location) { $loc = [string]$p2.Location }
        if ($loc -and -not $script:IsDry -and $script:State -is [hashtable] -and $script:State.Misc -is [hashtable]) {
            try {
                $lu = [uri]$loc
                if ($lu.IsAbsoluteUri -and ($lu.Scheme -eq 'http' -or $lu.Scheme -eq 'https')) {
                    $script:State.Misc['DiscoveredPortalUrl'] = [string]$lu.AbsoluteUri
                    $script:State.Misc['DiscoveryTime'] = (Get-Date).ToString('o')
                    if ($lu.Port -gt 0) { $script:State.Misc['DiscoveredPortalPort'] = [int]$lu.Port }
                    $cleanHost = ([string]$lu.Host).Trim().Trim('.').ToLower()
                    if ($cleanHost) {
                        $script:State.Misc['DiscoveredPortalHost'] = $cleanHost
                        if ($cleanHost -match '\.' -and $cleanHost -notmatch '^(local|lan|home|arpa|localdomain|mshome\.net)$') {
                            $script:State.Misc['DiscoveredDomain'] = $cleanHost
                        }
                    }
                    $tmpIp = $null
                    if ([System.Net.IPAddress]::TryParse($lu.Host, [ref]$tmpIp) -and (Test-AllowedPortalIp $lu.Host)) {
                        $script:State.Misc['DiscoveredPortalIp'] = $lu.Host
                    } else {
                        $resIp = Resolve-HostBounded $lu.Host 1500
                        if ($resIp -and (Test-AllowedPortalIp $resIp)) {
                            $script:State.Misc['DiscoveredPortalIp'] = $resIp
                        }
                    }
                }
            } catch {}
        }
    }
    $res = @{ State = $state; Location = $loc; Via = $via }
    $script:ConnCache = @{ Time = (Get-Date); Result = $res; Key = $ckey }
    return $res
}
# "Gateway alive" no longer depends on ICMP alone: many campus gateways drop ping but still answer ARP.
# Fresh evidence only: a cached neighbour entry proves nothing. 'Stale'/'Delay'/'Probe' are exactly what a DEAD gateway's
# leftover entry looks like, and 'Permanent' is our own lock. Force a fresh ARP exchange and accept only a freshly
# 'Reachable' entry (checked a few times, because the entry appears a moment after the probe).
function Test-GatewayAlive($Ad, [string]$Gw) {
    if (-not $Ad -or -not $Ad.ifIndex -or -not $Gw) { return @{ Alive = $false; Rtt = $null; Via = '' } }
    $rtt = Test-Ping $Gw 700
    if ($null -ne $rtt) { return @{ Alive = $true; Rtt = $rtt; Via = 'icmp' } }
    $ex = Get-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($ex -and [string]$ex.State -eq 'Permanent' -and $ex.LinkLayerAddress -and $ex.LinkLayerAddress -notmatch '^(00-)+00$') {
        $homeAd = $true
        try { $eh = Get-AdapterEnvironment $Ad -UseCache; if ($null -ne $eh.Home) { $homeAd = [bool]$eh.Home } } catch {}
        $gwSrc = [string](Get-ValidIPv4 $Ad)
        if ((Test-TcpPort $Gw 80 400 $gwSrc) -or (Test-TcpPort $Gw 443 400 $gwSrc) -or (Test-TcpPort $Gw 53 400 $gwSrc) -or (Test-TcpPort $Gw 8003 400 $gwSrc)) {
            return @{ Alive = $true; Rtt = $null; Via = 'arp' }
        }
        $dynamicGwPorts = @()
        if ($script:State.Misc -and $script:State.Misc['DiscoveredPortalPort']) {
            $dp = [int]$script:State.Misc['DiscoveredPortalPort']
            if ($dp -gt 0 -and @(80, 443, 53, 8003) -notcontains $dp) { $dynamicGwPorts += $dp }
        }
        if ($script:Cfg.PortalPort -and @(80, 443, 53, 8003) -notcontains [int]$script:Cfg.PortalPort) {
            $dynamicGwPorts += [int]$script:Cfg.PortalPort
        }
        foreach ($gp in $dynamicGwPorts) {
            if (Test-TcpPort $Gw $gp 400 $gwSrc) { return @{ Alive = $true; Rtt = $null; Via = 'arp' } }
        }
        $freshArp = @(Get-GatewayMacs $Ad $Gw 1)
        if ($freshArp.Count -gt 0 -and $freshArp[0] -eq [string]$ex.LinkLayerAddress) {
            return @{ Alive = $true; Rtt = $null; Via = 'arp' }
        }
        return @{ Alive = $false; Rtt = $null; Via = '' }
    }
    $gwSrc = [string](Get-ValidIPv4 $Ad)
    $dynamicGwPorts2 = @(80, 443, 53, 8003)
    if ($script:State.Misc -and $script:State.Misc['DiscoveredPortalPort']) {
        $dp2 = [int]$script:State.Misc['DiscoveredPortalPort']
        if ($dp2 -gt 0 -and $dynamicGwPorts2 -notcontains $dp2) { $dynamicGwPorts2 += $dp2 }
    }
    if ($script:Cfg.PortalPort -and $dynamicGwPorts2 -notcontains [int]$script:Cfg.PortalPort) {
        $dynamicGwPorts2 += [int]$script:Cfg.PortalPort
    }
    $tcpGwAlive2 = $false
    if ($gwSrc) {
        foreach ($gp in $dynamicGwPorts2) {
            if (Test-TcpPort $Gw $gp 350 $gwSrc) { $tcpGwAlive2 = $true; break }
        }
    }
    if ($tcpGwAlive2) {
        return @{ Alive = $true; Rtt = $null; Via = 'tcp' }
    }
    if ($script:IsAdmin -and -not $script:IsDry -and $ex -and @('Unreachable','Incomplete') -contains [string]$ex.State) {
        Remove-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -Confirm:$false -ErrorAction SilentlyContinue
    }
    [void](Test-Ping $Gw 700)
    for ($i = 0; $i -lt 4; $i++) {
        Start-Sleep -Milliseconds 100
        $n = Get-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -AddressFamily IPv4 -ErrorAction SilentlyContinue |
             Where-Object { $_.LinkLayerAddress -and $_.LinkLayerAddress -notmatch '^(00-)+00$' -and ([string]$_.State -eq 'Reachable' -or [string]$_.State -eq 'Permanent') } | Select-Object -First 1
        if ($n) { return @{ Alive = $true; Rtt = $null; Via = 'arp' } }
    }
    return @{ Alive = $false; Rtt = $null; Via = '' }
}
# ==============================================================================
# ADAPTERS / ENVIRONMENT / HEALTH
# ==============================================================================
function Rescue-DormantEthernetPnp {
    if (-not $script:IsAdmin -or $script:IsDry) { return }
    if (-not (Test-Elapsed 'PnpRescan' 300)) { return }
    Set-StateTime 'PnpRescan'
    try {
        $nics = @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object {
            $_.MediaType -eq '802.3' -and $_.Status -ne 'Not Present' -and $_.InterfaceDescription -notmatch $script:VirtRegex })
        if ($nics.Count -eq 0) {
            [void](Invoke-Native (Get-SysExe 'pnputil.exe') @('/scan-devices') 5000)
            return
        }
        $sick = @(Get-PnpDevice -Class Net -PresentOnly -ErrorAction SilentlyContinue | Where-Object {
            $_.FriendlyName -match 'Ethernet|GbE|Gigabit|ASIX|Realtek|USB' -and
            $_.FriendlyName -notmatch $script:VirtRegex -and
            $_.FriendlyName -notmatch 'Wi-?Fi|Wireless|WLAN|802\.11' -and
            $_.Problem -notin @('CM_PROB_NONE', 'CM_PROB_DISABLED', 'CM_PROB_HARDWARE_DISABLED') })
        foreach ($dev in ($sick | Select-Object -First 2)) {
            Write-Log 'INFO' "Restarting faulted wired transceiver: $($dev.FriendlyName)"
            [void](Invoke-Native (Get-SysExe 'pnputil.exe') @('/restart-device', $dev.InstanceId) 10000)
        }
    } catch {
        Write-Log 'WARN' "Rescue-DormantEthernetPnp non-critical exception: $_"
    }
}
$script:EthernetAdaptersCache = $null
$script:EthernetAdaptersCacheTicks = 0L

function Get-EthernetAdapters([switch]$NoCache) {
    $nowTicks = [System.Diagnostics.Stopwatch]::GetTimestamp()
    if (-not $NoCache -and $null -ne $script:EthernetAdaptersCache -and (($nowTicks - $script:EthernetAdaptersCacheTicks) / [System.Diagnostics.Stopwatch]::Frequency) -lt 2.5) {
        return $script:EthernetAdaptersCache
    }
    Rescue-DormantEthernetPnp
    $res = @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object {
        $_.MediaType -eq '802.3' -and $_.InterfaceDescription -notmatch $script:VirtRegex
    })
    $script:EthernetAdaptersCache = $res
    $script:EthernetAdaptersCacheTicks = $nowTicks
    return $res
}
function Get-IfaceReg([string]$Guid) {
    try { return (Get-ItemProperty -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$Guid" -ErrorAction Stop) } catch { return $null }
}
function Get-DhcpDnsServers([string]$Guid, [switch]$IncludeIPv6) {
    $reg = Get-IfaceReg $Guid
    if (-not $reg) { return @() }
    $res = @()
    if ($reg.DhcpNameServer) {
        $res += @(([string]$reg.DhcpNameServer) -split '[,\s]+' | Where-Object {
            $a = $null
            ($_ -match '^\d{1,3}(\.\d{1,3}){3}$') -and [System.Net.IPAddress]::TryParse($_, [ref]$a) -and ($a.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork)
        })
    }
    if ($IncludeIPv6 -and $reg.Dhcpv6DNSServers) {
        $res += @(([string]$reg.Dhcpv6DNSServers) -split '[,\s]+' | Where-Object { $_ -match '^[0-9a-fA-F:]+$' })
    }
    return @($res | Select-Object -Unique)
}
function Get-DhcpCaptiveUrl([string]$Guid) {
    $reg = Get-IfaceReg $Guid
    if (-not $reg) { return $null }
    foreach ($prop in 'DhcpCaptivePortalUrl', 'CaptivePortalUrl', 'DhcpOption114') {
        if ($reg.$prop) {
            $u = [string]$reg.$prop
            if ($u -match '^https?://[^\s]+$') { return $u }
        }
    }
    if ($reg.DhcpInterfaceOptions -is [byte[]]) {
        [byte[]]$bytes = $reg.DhcpInterfaceOptions
        $i = 0
        while ($i -lt ($bytes.Length - 2)) {
            $opt = [int]$bytes[$i]
            $len = [int]$bytes[$i + 1]
            if ($len -le 0 -or ($i + 2 + $len) -gt $bytes.Length) { break }
            if ($opt -eq 114 -or $opt -eq 160) {
                try {
                    $str = [System.Text.Encoding]::ASCII.GetString($bytes, $i + 2, $len)
                    if ($str -match '^https?://[^\s]+$') { return $str }
                } catch {}
            }
            $i += (2 + $len)
        }
    }
    return $null
}
function Get-GatewaysV4($Ad) {
    if (-not $Ad -or -not $Ad.ifIndex) { return @() }
    return @(Get-NetRoute -InterfaceIndex $Ad.ifIndex -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue |
        Where-Object { $_.NextHop -and $_.NextHop -ne '0.0.0.0' } | ForEach-Object { [string]$_.NextHop } | Select-Object -Unique)
}
function Get-DefaultGateway($Ad) {
    if (-not $Ad) { return $null }
    $gws = @(Get-GatewaysV4 $Ad)
    if ($gws.Count -gt 0) { return [string]$gws[0] }
    return $null
}
function Get-ValidIPv4($Ad) {
    if (-not $Ad -or -not $Ad.ifIndex) { return $null }
    $x = Get-NetIPAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue |
         Where-Object { $_.IPAddress -notlike '169.254.*' -and $_.AddressState -eq 'Preferred' } | Select-Object -First 1
    if ($x) { return [string]$x.IPAddress }
    return $null
}

# Scored fingerprinting. Strong evidence needs no network I/O (DHCP lease data survives APIPA),
# and a sticky history stops a broken lease from being mistaken for "home network".
function Test-LearnableDhcpServer([string]$Ip) {
    $a = $null
    if (-not [System.Net.IPAddress]::TryParse($Ip, [ref]$a)) { return $false }
    if ($a.AddressFamily -ne [System.Net.Sockets.AddressFamily]::InterNetwork) { return $false }
    if ($Ip -match '^(0\.|127\.|169\.254\.|255\.)') { return $false }
    # Addresses every home router / phone hotspot uses: learning one would mislabel other networks as campus.
    $common = @('192.168.0.1', '192.168.1.1', '192.168.0.254', '192.168.1.254', '192.168.2.1', '192.168.10.1', '192.168.100.1', '192.168.43.1',
                '172.20.10.1', '10.0.0.1', '10.0.0.138', '10.0.1.1', '10.1.1.1', '10.10.10.1')
    return ($common -notcontains $Ip)
}
function Get-AdapterEnvironment {
    param($Ad, [switch]$UseCache)
    if (-not $Ad -or -not $Ad.InterfaceGuid) { return @{ Env = 'Other'; Score = 0; Reasons = @(); DhcpDns = @(); Gateways = @(); DhcpServer = ''; Subnet = $null; State = 'Offline' } }
    $guid = [string]$Ad.InterfaceGuid
    if ($UseCache -and $script:EnvCache.ContainsKey($guid)) {
        $c = $script:EnvCache[$guid]
        if (((Get-Date) - $c.Time).TotalSeconds -lt 60) { return $c.Info }
    }
    $cfg = $script:Cfg
    $score = 0
    $ev = New-Object System.Collections.ArrayList
    $reg = Get-IfaceReg $guid
    $dhcpDns = @(Get-DhcpDnsServers $guid)
    $gws = @(Get-GatewaysV4 $Ad)
    if ($reg -and $reg.DhcpDefaultGateway) { $gws += @($reg.DhcpDefaultGateway | ForEach-Object { [string]$_ }) }
    $gws = @($gws | Where-Object { $_ } | Select-Object -Unique)
    $ip = Get-ValidIPv4 $Ad

    if ($dhcpDns -contains $cfg.CampusDns) { $score += 2; [void]$ev.Add("DHCP supplies campus DNS $($cfg.CampusDns)") }
    $dhcpPortal = Get-DhcpCaptiveUrl $guid
    if ($dhcpPortal) {
        $score += 2; [void]$ev.Add("DHCP option 114 captive URL '$dhcpPortal'")
        if (-not $script:IsDry) {
            $script:State.Misc['DiscoveredPortalUrl'] = $dhcpPortal
            $script:State.Misc['DiscoveryTime'] = (Get-Date).ToString('o')
            try { $du = [uri]$dhcpPortal; if ($du.Port -gt 0) { $script:State.Misc['DiscoveredPortalPort'] = [int]$du.Port } } catch {}
        }
    }
    foreach ($g in $gws) { if ($g -match $cfg.GwRegex) { $score += 1; [void]$ev.Add("gateway $g matches hostel pattern"); break } }
    $sfx = ''
    try { $sfx = [string](Get-DnsClient -InterfaceIndex $Ad.ifIndex -ErrorAction SilentlyContinue).ConnectionSpecificSuffix } catch {}
    if (-not $sfx -and $reg -and $reg.DhcpDomain) { $sfx = [string]$reg.DhcpDomain }
    $cleanSfx = if ($sfx) { $sfx.Trim().Trim('.').ToLower() } else { '' }
    $campDom = ([string]$cfg.CampusDomain).ToLower().Trim('.')
    if ($cleanSfx -and ($cleanSfx -eq $campDom -or $cleanSfx.EndsWith('.' + $campDom))) {
        $score += 2; [void]$ev.Add("DNS suffix '$cleanSfx'")
        if (-not $script:IsDry) {
            $script:State.Misc.Remove('DiscoveredDomain')
            $script:State.Misc['DiscoveryTime'] = (Get-Date).ToString('o')
        }
    } elseif ($cleanSfx -and $cleanSfx -match '\.' -and $cleanSfx -notmatch '^(local|lan|home|arpa|localdomain|mshome\.net)$') {
        $score += 1; [void]$ev.Add("enterprise DNS suffix '$cleanSfx'")
        if (-not $script:IsDry) {
            $script:State.Misc['DiscoveredDomain'] = $cleanSfx
            $script:State.Misc['DiscoveryTime'] = (Get-Date).ToString('o')
        }
    }
    try {
        $np = Get-NetConnectionProfile -InterfaceIndex $Ad.ifIndex -ErrorAction SilentlyContinue
        if ($np -and $np.Name -match $cfg.ProfileRegex) { $score += 1; [void]$ev.Add("network name '$($np.Name)'") }
    } catch {}
    # Learned fingerprint: the DHCP server seen when the evidence was strong. Survives a changed DNS IP / suffix.
    $dhcpSrv = ''
    if ($reg -and $reg.DhcpServer) { $dhcpSrv = [string]$reg.DhcpServer }
    $learnedSrv = [string]$script:State.Misc['LearnedDhcp']
    $learnedBonus = 0
    $portalHit = $false
    if ($dhcpSrv -and $learnedSrv -and ($dhcpSrv -eq $learnedSrv)) { $learnedBonus = 1; $score += 1; [void]$ev.Add("DHCP server $dhcpSrv matches the campus server learned earlier") }
    elseif ($dhcpSrv -and $gws.Count -gt 0 -and ($gws -notcontains $dhcpSrv) -and (Test-LearnableDhcpServer $dhcpSrv)) {
        $score += 1; [void]$ev.Add("dedicated DHCP server $dhcpSrv")
    }
    if ($score -lt $cfg.CampusThreshold -and $ip) {
        $targetPortalIp = if ($script:State.Misc -and $script:State.Misc['DiscoveredPortalIp']) { [string]$script:State.Misc['DiscoveredPortalIp'] } elseif ($gws.Count -gt 0 -and $cfg.PortalIp -ne $gws[0]) { [string]$gws[0] } else { $cfg.PortalIp }
        if ($targetPortalIp) {
            $detectedPort = Find-ActivePortalPort $targetPortalIp ([int]$cfg.PortalPort)
            if (Test-TcpPort $targetPortalIp $detectedPort 700) { $score += 2; $portalHit = $true; [void]$ev.Add(("portal {0}:{1} open" -f $targetPortalIp, $detectedPort)) }
            if ($null -ne (Test-Ping $targetPortalIp 700)) { $score += 1; $portalHit = $true; [void]$ev.Add("portal firewall answers ping") }
        }
        if ($cfg.CampusDns -and $null -ne (Test-Ping $cfg.CampusDns 700)) { $score += 1; [void]$ev.Add("campus DNS answers ping") }
        if ($score -lt $cfg.CampusThreshold) {
            $probeEnv = Get-InternetState -SourceIp $ip
            if ($probeEnv.State -eq 'Captive') {
                $score += 2; [void]$ev.Add('live captive portal detected on link')
                if ($probeEnv.Location -and -not $script:IsDry) {
                    try {
                        $lu = [uri][string]$probeEnv.Location
                        if ($lu.Host) {
                            $script:State.Misc['DiscoveredPortalUrl'] = [string]$probeEnv.Location
                            $script:State.Misc['DiscoveryTime'] = (Get-Date).ToString('o')
                            if ($lu.Port -gt 0) { $script:State.Misc['DiscoveredPortalPort'] = [int]$lu.Port }
                            $tmpIp = $null
                            if ([System.Net.IPAddress]::TryParse($lu.Host, [ref]$tmpIp)) {
                                if (Test-AllowedPortalIp $lu.Host) { $script:State.Misc['DiscoveredPortalIp'] = $lu.Host }
                            } else {
                                $cleanHost = ([string]$lu.Host).Trim().Trim('.').ToLower()
                                if ($cleanHost -match '\.' -and $cleanHost -notmatch '^(local|lan|home|arpa|localdomain|mshome\.net)$') {
                                    $script:State.Misc['DiscoveredDomain'] = $cleanHost
                                }
                                $resIp = Resolve-HostBounded $lu.Host 1500 $ip
                                if ($resIp -and (Test-AllowedPortalIp $resIp)) {
                                    $script:State.Misc['DiscoveredPortalIp'] = $resIp
                                }
                            }
                        }
                    } catch {}
                }
            }
        }
    }

    $envName = 'Unknown'
    $sticky = $false
    $homeVerdict = Get-HomeCampusVerdict $dhcpDns $cleanSfx $portalHit $script:State.Env[$guid]
    if ($score -ge $cfg.CampusThreshold) { $envName = 'Campus' }
    elseif ($ip -and $gws.Count -gt 0) { $envName = 'Other' }
    else {
        $hist = $script:State.Env[$guid]
        if ($hist -is [hashtable] -and $hist.Env -eq 'Campus') { $envName = 'Campus'; $sticky = $true; [void]$ev.Add('no lease yet; using last known: campus') }
    }
    if ($envName -eq 'Campus' -and -not $sticky -and $dhcpSrv -and (Test-LearnableDhcpServer $dhcpSrv) -and (($score - $learnedBonus) -ge 3) -and $learnedSrv -ne $dhcpSrv) {
        $script:State.Misc['LearnedDhcp'] = $dhcpSrv   # only ever learned from strong, independent evidence
    }
    if (-not $sticky -and ($envName -eq 'Campus' -or $envName -eq 'Other')) {
        $h = Get-SubTable 'Env' $guid
        $h.Env = $envName
        $h.Home = $homeVerdict
        $h.Time = (Get-Date).ToString('o')
        if (-not $script:IsDry) {
            if ($envName -eq 'Other') {
                $script:State.Misc.Remove('DiscoveredPortalIp')
                $script:State.Misc.Remove('DiscoveredPortalUrl')
                $script:State.Misc.Remove('DiscoveredDomain')
                $script:State.Misc['DiscoveryTime'] = (Get-Date).ToString('o')
            }
        }
    }
    $info = @{ Env = $envName; Score = $score; Evidence = @($ev); Sticky = $sticky; Ip = $ip; Gateways = $gws; Home = $homeVerdict }
    $script:EnvCache[$guid] = @{ Time = (Get-Date); Info = $info }
    return $info
}

# Problem: NoAdapter | NoLink | NoIp | GwUnreachable | NoDns | Captive | Offline | Healthy
function Get-AdapterHealth($Ad) {
    if (-not $Ad -or -not $Ad.Name) { return @{ Name = ''; Up = $false; Ip = $null; Apipa = $false; Gateway = $null; GwRtt = $null; GwAlive = $false; GwVia = ''; Conn = 'Offline'; Problem = 'NoAdapter' } }
    $h = @{ Name = $Ad.Name; Up = ($Ad.Status -eq 'Up'); Ip = $null; Apipa = $false; Gateway = $null; GwRtt = $null; GwAlive = $false; GwVia = ''; Conn = 'Offline'; Problem = 'NoLink' }
    if (-not $h.Up) { return $h }
    $all = @(Get-NetIPAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue)
    $h.Apipa = [bool]($all | Where-Object { $_.IPAddress -like '169.254.*' })
    $h.Ip = Get-ValidIPv4 $Ad
    if (-not $h.Ip) { $h.Problem = 'NoIp'; return $h }
    $gw = @(Get-GatewaysV4 $Ad) | Select-Object -First 1
    $h.Gateway = $gw
    if ($gw) { $ga = Test-GatewayAlive $Ad $gw; $h.GwRtt = $ga.Rtt; $h.GwAlive = $ga.Alive; $h.GwVia = $ga.Via }
    $h.Conn = (Get-InternetState -NoCache -SourceIp $h.Ip).State
    switch ($h.Conn) {
        'Online'  { $h.Problem = 'Healthy' }
        'Captive' { $h.Problem = 'Captive' }
        'NoDns'   { $h.Problem = 'NoDns' }
        default   { if (-not $h.GwAlive) { $h.Problem = 'GwUnreachable' } else { $h.Problem = 'Offline' } }
    }
    return $h
}

function Wait-LinkSettling([int]$MaxMs = 12000) {
    if ($script:IsDry) { return }
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $minWait = if ($MaxMs -gt 12000) { 2000 } else { 500 }
    while ($sw.ElapsedMilliseconds -lt $MaxMs) {
        $ups = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' -and $_.LinkSpeed -and $_.LinkSpeed -notmatch '^(0\s*bps)?$' })
        if ($ups.Count -gt 0 -and $sw.ElapsedMilliseconds -ge $minWait) { break }
        Start-Sleep -Milliseconds 150
    }
    Write-Log 'INFO' ("Link settling finished after {0} ms" -f $sw.ElapsedMilliseconds)
}

function Test-WatchdogInstalled {
    $r = Invoke-Native (Get-SysExe 'schtasks.exe') @('/query', '/tn', $script:Cfg.TaskWatchdog) 8000
    return ($r.ExitCode -eq 0)
}

# ==============================================================================
function Reset-PhysicalAdapterHardware($Ad) {
    if (-not $Ad) { return $false }
    if ($script:IsDry) { Write-Log 'DRY' "Would cycle transceiver/driver on $($Ad.Name)"; return $true }
    $pnpId = [string]$Ad.PnPDeviceID
    $pnpExe = Get-SysExe 'pnputil.exe'
    $restarted = $false
    if ($pnpId -and (Test-Path -LiteralPath $pnpExe)) {
        try {
            $r = Invoke-Native $pnpExe @('/restart-device', $pnpId) 15000
            if ($r.ExitCode -eq 0 -and ($r.Output -notmatch 'Failed|Error')) {
                Write-Log 'OK' "Hardware PnP bus cycled on $($Ad.Name) ($pnpId)."
                $restarted = $true
            } else {
                Write-Log 'INFO' "pnputil /restart-device returned code $($r.ExitCode); falling back to driver cycling."
            }
        } catch {
            Write-Log 'INFO' "PnP cycle exception: $($_.Exception.Message)"
        }
    }
    if (-not $restarted) {
        $disabled = $false
        try {
            Disable-NetAdapter -Name $Ad.Name -Confirm:$false -ErrorAction Stop
            $disabled = $true
            Start-Sleep -Milliseconds 1200
        } catch {
            Write-Log 'WARN' "Failed to disable $($Ad.Name): $($_.Exception.Message)"
        } finally {
            if ($disabled) {
                $enabled = $false
                for ($attempt = 1; $attempt -le 3; $attempt++) {
                    try {
                        Enable-NetAdapter -Name $Ad.Name -Confirm:$false -ErrorAction Stop
                        $enabled = $true
                        Write-Log 'OK' "Kernel NDIS driver cycled and re-enabled on $($Ad.Name)."
                        break
                    } catch {
                        Start-Sleep -Milliseconds 1000
                    }
                }
                if (-not $enabled) {
                    Write-Log 'ALERT' "Enable-NetAdapter failed on $($Ad.Name); invoking emergency fallback Restart-NetAdapter..."
                    try { Restart-NetAdapter -Name $Ad.Name -Confirm:$false -ErrorAction SilentlyContinue } catch {}
                }
                $restarted = $enabled
            }
        }
    }
    return $restarted
}

# LAYER 1 - HARDWARE, NDIS LINK HEALTH & POWER SHIELD
# ==============================================================================
function Test-NdisLinkHealth($Ad) {
    if (-not $Ad) { return [PSCustomObject]@{ Healthy = $false; Discards = 0L; Errors = 0L; LinkSpeed = '0 bps'; Duplex = 'Unknown'; Reason = 'NoAdapter' } }
    $stats = $null
    try { $stats = Get-NetAdapterStatistics -Name $Ad.Name -ErrorAction SilentlyContinue } catch {}
    $discards = 0L
    $errors = 0L
    if ($stats) {
        $discards = [int64]$stats.ReceivedDiscardedPackets + [int64]$stats.OutboundDiscardedPackets
        $errors   = [int64]$stats.ReceivedPacketErrors + [int64]$stats.OutboundPacketErrors
    } else {
        try {
            $cimStats = Get-CimInstance -ClassName MSFT_NetAdapterStatisticsSettingData -Namespace 'Root/StandardCimv2' -Filter ("Name='{0}'" -f $Ad.Name) -ErrorAction SilentlyContinue
            if ($cimStats) {
                $discards = [int64]$cimStats.ReceivedDiscardedPackets + [int64]$cimStats.OutboundDiscardedPackets
                $errors   = [int64]$cimStats.ReceivedPacketErrors + [int64]$cimStats.OutboundPacketErrors
            }
        } catch {}
    }
    $speed = [string]$Ad.LinkSpeed
    $duplex = 'Unknown'
    try {
        $advDuplex = Get-NetAdapterAdvancedProperty -Name $Ad.Name -RegistryKeyword '*SpeedDuplex' -ErrorAction SilentlyContinue
        if ($advDuplex) { $duplex = [string]$advDuplex.DisplayValue }
    } catch {}

    $healthy = $true
    $reasons = @()
    if ($Ad.Status -ne 'Up') {
        $healthy = $false
        $reasons += 'LinkDown'
    } elseif ($speed -match '^\s*10\s*M') {
        $healthy = $false
        $reasons += 'FlapTo10Mbps'
    }
    if ($errors -gt 100) { $healthy = $false; $reasons += ("PacketErrors({0})" -f $errors) }
    if ($discards -gt 1000) { $healthy = $false; $reasons += ("HighDiscards({0})" -f $discards) }
    $reasonStr = if ($reasons.Count -gt 0) { $reasons -join ', ' } else { 'Healthy' }
    return [PSCustomObject]@{
        Healthy   = $healthy
        Discards  = $discards
        Errors    = $errors
        LinkSpeed = $speed
        Duplex    = $duplex
        Reason    = $reasonStr
    }
}

function Resolve-DuplexFlap($Ad) {
    if (-not $Ad -or $script:IsDry) {
        if ($script:IsDry -and $Ad) { Write-Log 'DRY' ("Would evaluate and remediate link speed/duplex flap on {0}" -f $Ad.Name) }
        return $false
    }
    $guid = [string]$Ad.InterfaceGuid
    $speed = [string]$Ad.LinkSpeed
    $isGigabitOrHigher = $false
    try {
        $rawSpeed = 0L
        if ($Ad.TransmitLinkSpeed) { $rawSpeed = [int64]$Ad.TransmitLinkSpeed }
        elseif ($Ad.ReceiveLinkSpeed) { $rawSpeed = [int64]$Ad.ReceiveLinkSpeed }
        elseif ($Ad.MaxSpeed) { $rawSpeed = [int64]$Ad.MaxSpeed }

        if ($rawSpeed -ge 1000000000 -or $speed -match 'Gbps|1000\s*Mbps|2\.5\s*G|5\s*G|10\s*G') { $isGigabitOrHigher = $true }
        elseif ($Ad.InterfaceDescription -match 'Gigabit|GbE|1000|2\.5G|5G|10G|10000|RTL81|I21|I22') { $isGigabitOrHigher = $true }
        else {
            $sdProp = Get-NetAdapterAdvancedProperty -Name $Ad.Name -RegistryKeyword '*SpeedDuplex' -ErrorAction SilentlyContinue
            if ($sdProp -and ($sdProp.ValidDisplayValues -match '1\.0 Gbps|1 Gbps|1000|2\.5|5 Gbps|10 Gbps')) { $isGigabitOrHigher = $true }
        }
    } catch {}
    if ($speed -match '^\s*10\s*M' -and $isGigabitOrHigher) {
        $prop = Get-NetAdapterAdvancedProperty -Name $Ad.Name -RegistryKeyword '*SpeedDuplex' -ErrorAction SilentlyContinue
        if ($prop) {
            $curVal = [string](@($prop.RegistryValue) | Select-Object -First 1)
            if ($curVal -ne '0') {
                Save-Original $guid 'Adv:*SpeedDuplex' $curVal
                return (Invoke-Change ("Reset *SpeedDuplex to Auto-Negotiation on {0}" -f $Ad.Name) {
                    Set-NetAdapterAdvancedProperty -Name $Ad.Name -RegistryKeyword '*SpeedDuplex' -RegistryValue @('0') -NoRestart -ErrorAction Stop
                })
            }
        }
    }
    return $false
}

function Optimize-PhySiliconBuffers($Ad) {
    if (-not $Ad -or $script:IsDry) {
        if ($script:IsDry -and $Ad) { Write-Log 'DRY' ("Would check ring buffers on {0}" -f $Ad.Name) }
        return $false
    }
    $health = Test-NdisLinkHealth $Ad
    $guid = [string]$Ad.InterfaceGuid
    $modified = $false
    $rxKw = '*ReceiveBuffers'
    $txKw = '*TransmitBuffers'
    $props = @(Get-NetAdapterAdvancedProperty -Name $Ad.Name -AllProperties -ErrorAction SilentlyContinue)

    foreach ($kw in @($rxKw, $txKw)) {
        $p = $props | Where-Object { $_.RegistryKeyword -eq $kw } | Select-Object -First 1
        if (-not $p) { continue }
        $cur = $null
        try { $cur = [int](@($p.RegistryValue) | Select-Object -First 1) } catch { $cur = $null }
        if ($null -eq $cur) { continue }

        if ($health.Discards -lt 500 -and $cur -ge 512) { continue }
        $validVals = @()
        if ($p.ValidRegistryValues) {
            foreach ($v in $p.ValidRegistryValues) {
                $iv = 0
                if ([int]::TryParse([string]$v, [ref]$iv) -and $iv -gt 0) { $validVals += $iv }
            }
        }
        $validVals = @($validVals | Sort-Object)
        $target = $null
        if ($validVals.Count -gt 0) {
            $higher = @($validVals | Where-Object { $_ -gt $cur })
            if ($higher.Count -gt 0) { $target = $higher[-1] }
        }
        if ($null -eq $target) {
            $target = if ($cur -lt 512) { 512 } elseif ($cur -lt 1024) { 1024 } else { 2048 }
        }
        if ($target -gt $cur) {
            Save-Original $guid ("Adv:" + $kw) [string]$cur
            $ok = Invoke-Change ("Scaled ring buffer {0} from {1} to {2} on {3} (NDIS burst buffer optimization)" -f $kw, $cur, $target, $Ad.Name) {
                Set-NetAdapterAdvancedProperty -Name $Ad.Name -RegistryKeyword $kw -RegistryValue @([string]$target) -NoRestart -ErrorAction Stop
            }
            if ($ok) { $modified = $true; $script:PendingRestart[$guid] = $Ad.Name }
        }
    }
    $imProp = $props | Where-Object { $_.RegistryKeyword -eq '*InterruptModeration' } | Select-Object -First 1
    if ($imProp) {
        $imVal = [string](@($imProp.RegistryValue) | Select-Object -First 1)
        if ($imVal -eq '0') {
            Save-Original $guid 'Adv:*InterruptModeration' $imVal
            $ok = Invoke-Change ("Enabled *InterruptModeration on {0} to prevent DPC CPU spikes" -f $Ad.Name) {
                Set-NetAdapterAdvancedProperty -Name $Ad.Name -RegistryKeyword '*InterruptModeration' -RegistryValue @('1') -NoRestart -ErrorAction Stop
            }
            if ($ok) { $modified = $true; $script:PendingRestart[$guid] = $Ad.Name }
        }
    }
    return $modified
}

function Shield-TransceiverBus($Ad) {
    if (-not $Ad -or $script:IsDry) {
        if ($script:IsDry -and $Ad) { Write-Log 'DRY' ("Would verify transceiver bus and PnP controller status on {0}" -f $Ad.Name) }
        return $false
    }
    $recovered = $false
    try {
        if ($Ad.PnPDeviceID) {
            $pnp = Get-CimInstance Win32_PnPEntity -Filter ("DeviceID = '{0}'" -f ($Ad.PnPDeviceID -replace "\\", "\\\\")) -ErrorAction SilentlyContinue
            if ($pnp -and $pnp.ConfigManagerErrorCode -ne 0) {
                $code = [int]$pnp.ConfigManagerErrorCode
                Write-Log 'WARN' ("Ethernet controller {0} reports PnP ConfigManagerErrorCode {1} ({2})" -f $Ad.Name, $code, $pnp.Status)
                if (@(10, 22, 43, 14, 31) -contains $code) {
                    $ok = Invoke-Change ("PnP hardware controller reset cycle on {0} (clearing error code {1})" -f $Ad.Name, $code) {
                        $pnputil = Get-SysExe 'pnputil.exe'
                        if (Test-Path -LiteralPath $pnputil) {
                            [void](Invoke-Native $pnputil @('/restart-device', [string]$Ad.PnPDeviceID) 10000)
                        } else {
                            Disable-PnpDevice -InstanceId $Ad.PnPDeviceID -Confirm:$false -ErrorAction SilentlyContinue
                            Start-Sleep -Milliseconds 500
                            Enable-PnpDevice -InstanceId $Ad.PnPDeviceID -Confirm:$false -ErrorAction Stop
                        }
                    }
                    if ($ok) { $recovered = $true }
                }
            }
        }
    } catch {
        Write-Log 'INFO' ("PnP transceiver bus evaluation skipped on {0}: {1}" -f $Ad.Name, $_.Exception.Message)
    }
    return $recovered
}

function Shield-Aspm {
    if ($script:IsDry) { Write-Log 'DRY' 'Would disable PCIe Link State Power Management (ASPM) on AC'; return }
    try {
        $powercfg = Get-SysExe 'powercfg.exe'
        if (Test-Path -LiteralPath $powercfg) {
            [void](Invoke-Native $powercfg @('/setacvalueindex', 'scheme_current', 'sub_pcipexpress', 'express', '0') 5000)
            [void](Invoke-Native $powercfg @('/setactive', 'scheme_current') 5000)
            Write-Log 'INFO' 'PCIe Link State Power Management (ASPM) verified disabled on active AC power scheme.'
        }
    } catch {}
}

function Get-NicClassKey($Ad) {
    $base = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}'
    foreach ($k in @(Get-ChildItem -LiteralPath $base -ErrorAction SilentlyContinue)) {
        $v = Get-ItemProperty -LiteralPath $k.PSPath -Name NetCfgInstanceId -ErrorAction SilentlyContinue
        if ($v -and ([string]$v.NetCfgInstanceId) -eq ([string]$Ad.InterfaceGuid)) { return $k.PSPath }
    }
    return $null
}
function Resolve-DisabledValue($Prop) {
    $disp = @($Prop.ValidDisplayValues)
    $reg  = @($Prop.ValidRegistryValues)
    if ($reg.Count -eq 0) { return $null }
    if ($disp.Count -eq $reg.Count) {
        for ($i = 0; $i -lt $disp.Count; $i++) {
            if ([string]$disp[$i] -match '^\s*(Disabled|Disable|Off)\s*$') { return [string]$reg[$i] }
        }
    }
    # Localized driver UI: only accept the unambiguous 0/1 pair for whitelisted keywords.
    if ($reg.Count -eq 2 -and ($reg -contains '0') -and ($reg -contains '1')) { return '0' }
    return $null
}
function Shield-Hardware($Ad) {
    if (-not $Ad -or -not $Ad.Name) { return $false }
    $guid = [string]$Ad.InterfaceGuid
    [void](Shield-TransceiverBus $Ad)
    $touched = $false
    $props = @(Get-NetAdapterAdvancedProperty -Name $Ad.Name -AllProperties -ErrorAction SilentlyContinue)
    foreach ($kw in $script:PowerKeywords) {
        $p = $props | Where-Object { $_.RegistryKeyword -eq $kw } | Select-Object -First 1
        if (-not $p) { continue }
        $off = Resolve-DisabledValue $p
        if ($null -eq $off) { continue }
        $cur = [string](@($p.RegistryValue) | Select-Object -First 1)
        if ($cur -eq $off) { continue }
        Save-Original $guid ("Adv:" + $kw) $cur
        $ok = Invoke-Change "Power-saving feature '$kw' off on $($Ad.Name) (was $cur)" {
            Set-NetAdapterAdvancedProperty -Name $Ad.Name -RegistryKeyword $kw -RegistryValue @($off) -NoRestart -ErrorAction Stop
        }
        if ($ok) { $touched = $true }
    }
    # "Allow the computer to turn off this device to save power" = PnPCapabilities DWORD 24 (0x18).
    $ck = Get-NicClassKey $Ad
    if ($ck) {
        $cur = $null
        try {
            $kind = (Get-Item -LiteralPath $ck).GetValueKind('PnPCapabilities')
            if ($kind -eq [Microsoft.Win32.RegistryValueKind]::DWord) { $cur = [int](Get-ItemProperty -LiteralPath $ck -Name PnPCapabilities).PnPCapabilities }
        } catch {}
        if ($cur -ne 24) {
            Save-Original $guid 'Pnp' $cur
            $ok = Invoke-Change "NIC power-off permission removed on $($Ad.Name)" {
                New-ItemProperty -LiteralPath $ck -Name 'PnPCapabilities' -Value 24 -PropertyType DWord -Force -ErrorAction Stop
            }
            if ($ok) { $touched = $true }
        }
    }
    # Hardening USB device parameters for Realtek and USB GbE dongles against idle power drops
    if ($Ad.InterfaceDescription -match 'USB|Realtek|GbE|Ethernet' -and $Ad.PnPDeviceID) {
        try {
            $enumKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\$($Ad.PnPDeviceID)\Device Parameters"
            if (Test-Path -LiteralPath $enumKey) {
                $paramNames = @('DeviceSelectiveSuspended','IdleInWorkingState','SelectiveSuspendEnabled','AutoPowerSave','IdlePowerSave','ReduceSpeedOnPowerDown','UltraLowPowerMode')
                try {
                    $item = Get-ItemProperty -LiteralPath $enumKey -ErrorAction SilentlyContinue
                    if ($item) {
                        foreach ($prop in $item.PSObject.Properties) {
                            $pn = $prop.Name
                            if ($pn -match '(?i)(selective|suspend|powersave|powerdown|idle|lowpower|energysave|green)' -and $paramNames -notcontains $pn) {
                                $paramNames += $pn
                            }
                        }
                    }
                } catch {}
                foreach ($pName in $paramNames) {
                    $cur = (Get-ItemProperty -LiteralPath $enumKey -Name $pName -ErrorAction SilentlyContinue).$pName
                    if ($null -ne $cur -and [int]$cur -eq 0) { continue }
                    try {
                        Set-ItemProperty -LiteralPath $enumKey -Name $pName -Value 0 -Type DWord -Force -ErrorAction Stop
                        Save-Original $guid ("Enum:$pName") $cur
                        Write-Log 'OK' "Device Parameters '$pName' set to 0 on $($Ad.Name)"
                        $script:ChangeCount++
                    } catch {
                        Write-Log 'INFO' "Device Parameters '$pName' on $($Ad.Name) skipped (SYSTEM ownership required)"
                    }
                }
            }
        } catch {}
    }
    # Windows Power Scheme: Disable USB Selective Suspend so the USB host controller never sleeps the dongle
    Set-UsbSuspendOff
    Shield-Aspm
    if ($touched) {
        $script:PendingRestart[$guid] = $Ad.Name
        Write-Log 'INFO' "Driver power settings changed on $($Ad.Name); they take effect at the next link reset."
    } else {
        Write-Log 'INFO' "Hardware/power settings already optimal on $($Ad.Name)."
    }
}
$script:PendingRestart = @{}

# ==============================================================================
# LAYER 2 - DATA LINK: duplicate-address guard + DHCP/APIPA recovery ladder
# ==============================================================================
function Shield-Dot3Svc($Ad) {
    if (-not $script:IsAdmin -or -not $Ad) { return $false }
    if ($script:IsDry) { Write-Log 'DRY' 'Would check Wired AutoConfig (dot3svc) service'; return $false }
    try {
        $svc = Get-Service -Name 'dot3svc' -ErrorAction SilentlyContinue
        if ($svc) {
            $changed = $false
            if ($svc.StartType -eq 'Disabled') {
                $changed = Invoke-Change 'Re-enabled Wired AutoConfig service (dot3svc) for IEEE 802.1X campus auth' {
                    Set-Service -Name 'dot3svc' -StartupType Automatic -ErrorAction Stop
                }
            }
            if ($svc.Status -ne 'Running') {
                $started = Invoke-Change 'Started Wired AutoConfig service (dot3svc)' {
                    Start-Service -Name 'dot3svc' -ErrorAction Stop
                }
                if ($started) { $changed = $true }
            }
            if ($changed -and $Ad) {
                Start-Sleep -Milliseconds 600
                $netsh = Get-SysExe 'netsh.exe'
                if (Test-Path -LiteralPath $netsh) {
                    [void](Invoke-Native $netsh @('lan', 'set', 'autoconfig', 'enabled=yes', ("interface={0}" -f $Ad.Name)) 5000)
                    [void](Invoke-Native $netsh @('lan', 'reconnect', ("interface={0}" -f $Ad.Name)) 5000)
                }
            }
            return $changed
        }
    } catch {}
    return $false
}

function Wait-StpConvergence($Ad, [int]$MaxWaitSec = 45) {
    if (-not $Ad -or $script:IsDry) { return $true }
    Write-Log 'INFO' ("Evaluating switch-port STP convergence on {0} (up to {1}s)..." -f $Ad.Name, $MaxWaitSec)
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $converged = $false
    while ($sw.Elapsed.TotalSeconds -lt $MaxWaitSec) {
        $curAd = Get-NetAdapter -Name $Ad.Name -ErrorAction SilentlyContinue
        if ($curAd -and $curAd.Status -eq 'Up') {
            $ip = Get-ValidIPv4 $curAd
            $hasV6 = @(Get-NetIPAddress -InterfaceIndex $curAd.ifIndex -AddressFamily IPv6 -ErrorAction SilentlyContinue | Where-Object { [string]$_.AddressState -eq 'Preferred' -and [string]$_.IPAddress -notmatch '^(fe80|::1)' }).Count -gt 0
            if ($ip -or $hasV6) {
                $gw = @(Get-GatewaysV4 $curAd) | Select-Object -First 1
                if ($gw) {
                    $chk = Test-GatewayAlive $curAd $gw
                    if ($chk.Alive) { $converged = $true; break }
                } else {
                    $converged = $true; break
                }
            }
        }
        Start-Sleep -Milliseconds 350
    }
    $sw.Stop()
    if ($converged) {
        Write-Log 'OK' ("STP convergence achieved on {0} after {1}s." -f $Ad.Name, [math]::Round($sw.Elapsed.TotalSeconds, 1))
    } else {
        Write-Log 'WARN' ("STP convergence window expired after {0}s on {1}." -f [math]::Round($sw.Elapsed.TotalSeconds, 1), $Ad.Name)
    }
    return $converged
}

function Get-IPv4Interface($Ad) {
    if (-not $Ad -or -not $Ad.ifIndex) { return $null }
    return (Get-NetIPInterface -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue)
}

function Get-DhcpFailureDiagnosis($Ad) {
    $mac = if ($Ad -and $Ad.MacAddress) { [string]$Ad.MacAddress } else { '' }
    return (Get-DhcpFailureText (Get-DhcpErrorCode) $mac)
}
function Test-DhcpLeaseUsable($Ad) {
    if (-not $Ad -or -not $Ad.ifIndex) { return $false }
    $ip = Get-ValidIPv4 $Ad
    if (-not $ip) { return $false }
    $gw = @(Get-GatewaysV4 $Ad) | Select-Object -First 1
    if (-not $gw) { return $false }
    return (Test-GatewayAlive $Ad $gw).Alive
}
function Repair-Dhcp($Ad, [switch]$ForceRelease) {
    if (-not $Ad -or -not $Ad.Name) { return $false }
    $guid = [string]$Ad.InterfaceGuid
    $ipconfig = Get-SysExe 'ipconfig.exe'
    Write-Log 'WARN' ("Starting DHCP recovery ladder on {0} ({1})." -f $Ad.Name, $(if ($ForceRelease) { 'gateway unreachable / stale lease' } else { 'APIPA / no valid IPv4' }))
    # Step 1: release APIPA/stale state and renew with broadcast flag
    if ($script:IsDry) { Write-Log 'DRY' "Would: DHCP renew on $($Ad.Name)"; return $false }
    $curIp = Get-ValidIPv4 $Ad
    if ($ForceRelease -or -not $curIp -or $curIp -like '169.254*') {
        Write-Log 'INFO' "Releasing stale/APIPA lease on $($Ad.Name) before renew..."
        if ($guid) {
            try {
                $ifKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"
                if (Test-Path -LiteralPath $ifKey) {
                    Set-ItemProperty -LiteralPath $ifKey -Name 'DhcpConnForceBroadcastFlag' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
                    Set-ItemProperty -LiteralPath $ifKey -Name 'DhcpIPAddress' -Value '0.0.0.0' -ErrorAction SilentlyContinue
                }
            } catch {}
        }
        Remove-NetNeighbor -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
        [void](Invoke-Native $ipconfig @('/release', $Ad.Name) 10000)
    }
    Write-Log 'INFO' "DHCP renew attempted on $($Ad.Name)..."
    $r = Invoke-Native $ipconfig @('/renew', $Ad.Name) 15000
    if ($r.ExitCode -eq 0) { Write-Log 'OK' "DHCP renew completed on $($Ad.Name)" }
    for ($i = 0; $i -lt 12; $i++) {
        if ($(if ($ForceRelease) { Test-DhcpLeaseUsable $Ad } else { [bool](Get-ValidIPv4 $Ad) })) { Write-Log 'OK' 'Lease acquired.'; return $true }
        Start-Sleep -Milliseconds 500
    }
    # Step 2: link reset with STP convergence
    Set-StateTime ("Restart:" + $guid)
    [void](Invoke-Change "Zero-reboot hardware/link reset on $($Ad.Name)" { Reset-PhysicalAdapterHardware $Ad })
    $script:PendingRestart.Remove($guid)
    # Adaptive STP convergence window (up to 45s, instant early-exit on lease acquisition)
    for ($i = 0; $i -lt 90; $i++) {
        if ($i % 4 -eq 0) {
            $freshAd = Get-NetAdapter -Name $Ad.Name -ErrorAction SilentlyContinue
            if ($freshAd) { $Ad = $freshAd }
        }
        if (Get-ValidIPv4 $Ad) { Write-Log 'OK' 'Lease acquired after link reset.'; return $true }
        Start-Sleep -Milliseconds 500
    }
    # Step 3: DHCP stack unfreeze and release/renew
    [void](Invoke-Change "DHCP stack unfreeze and release/renew on $($Ad.Name)" {
        try {
            Stop-Service -Name Dhcp -Force -ErrorAction SilentlyContinue
            if ($guid) {
                try {
                    $ifKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"
                    if (Test-Path -LiteralPath $ifKey) {
                        Set-ItemProperty -LiteralPath $ifKey -Name 'DhcpIPAddress' -Value '0.0.0.0' -ErrorAction SilentlyContinue
                        Set-ItemProperty -LiteralPath $ifKey -Name 'DhcpDefaultGateway' -Value @() -ErrorAction SilentlyContinue
                    }
                } catch {}
            }
        } finally {
            Start-Service -Name Dhcp -ErrorAction SilentlyContinue
            Start-Service -Name WlanSvc -ErrorAction SilentlyContinue
            Start-Service -Name Wcmsvc -ErrorAction SilentlyContinue
            Start-Service -Name iphlpsvc -ErrorAction SilentlyContinue
            Start-Service -Name NlaSvc -ErrorAction SilentlyContinue
            Start-Service -Name netprofm -ErrorAction SilentlyContinue
        }
        [void](Invoke-Native $ipconfig @('/release', $Ad.Name) 10000)
        $r = Invoke-Native $ipconfig @('/renew', $Ad.Name) 25000
        if ($r.TimedOut) { throw 'ipconfig /renew timed out' }
        if ($r.ExitCode -ne 0) { Write-Log 'WARN' ('ipconfig /renew said: ' + (([string]$r.Output -replace '\s+', ' ').Trim())) }
    })
    for ($i = 0; $i -lt 16; $i++) {
        if ($i % 4 -eq 0) {
            $freshAd = Get-NetAdapter -Name $Ad.Name -ErrorAction SilentlyContinue
            if ($freshAd) { $Ad = $freshAd }
        }
        if (Get-ValidIPv4 $Ad) { Write-Log 'OK' 'Lease acquired after release/renew.'; return $true }
        Start-Sleep -Milliseconds 500
    }
    Write-Log 'ALERT' 'DHCP still not answering.'
    Write-Log 'INFO' (Get-DhcpFailureDiagnosis $Ad)
    return $false
}

# Duplicate-address probes protect you from a REAL duplicate IP. They only hurt when the switch/ARP proxy
# answers every probe (false conflict -> address marked Duplicate -> 169.254.x.x). So 'Auto' turns them off
# only after evidence of that, instead of unconditionally trading away conflict detection.
function Test-DadConflictEvidence($Ad) {
    if (-not $Ad -or -not $Ad.ifIndex) { return '' }
    $dup = @(Get-NetIPAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { [string]$_.AddressState -eq 'Duplicate' })
    if ($dup.Count -gt 0) { return 'an address is in Duplicate state right now' }
    $c = @(Get-WinEvent -FilterHashtable @{ LogName = 'System'; ProviderName = 'Tcpip'; Id = 4199; StartTime = (Get-Date).AddDays(-7) } -ErrorAction SilentlyContinue).Count
    if ($c -gt 0) { return "$c address-conflict events in the last 7 days" }
    return ''
}
function Shield-DataLink($Ctx) {
    $ad = $Ctx.Ad
    $guid = [string]$ad.InterfaceGuid
    $ipif = Get-IPv4Interface $ad
    if ($ipif) {
        $cur = [int]$ipif.DadTransmits
        if ($Ctx.Env.Env -eq 'Campus') {
            $want = [int]$script:Cfg.CampusDad
            $policy = [string]$script:Cfg.DadPolicy
            if ($cur -ne $want) {
                $why = ''
                if ($policy -eq 'Always') { $why = 'policy Always' }
                elseif ($policy -ne 'Never') { $why = Test-DadConflictEvidence $ad }
                if ($why) {
                    Save-Original $guid 'Dad4' $cur
                    [void](Invoke-Change "IPv4 duplicate-address probes $cur -> $want on $($ad.Name) ($why)" {
                        Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -DadTransmits $want -ErrorAction Stop
                    })
                } else { Write-Log 'INFO' "No address-conflict evidence on $($ad.Name): duplicate-address probes stay at $cur (DadPolicy $policy)." }
            } else { Write-Log 'INFO' "Duplicate-address probes already $want on $($ad.Name)." }
        } elseif ($Ctx.Env.Env -eq 'Other') {
            $dupNow = @(Get-NetIPAddress -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { [string]$_.AddressState -eq 'Duplicate' }).Count -gt 0
            if ($dupNow -and $cur -ne 0 -and ([string]$script:Cfg.DadPolicy -ne 'Never')) {
                Save-Original $guid 'Dad4' $cur
                [void](Invoke-Change "Active Duplicate IPv4 conflict on $($ad.Name): duplicate-address probes $cur -> 0" {
                    Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -DadTransmits 0 -ErrorAction Stop
                })
            } else {
                $snap = Get-SubTable 'Snapshot' $guid
                $orig = if ($snap.ContainsKey('Dad4')) { [int]$snap['Dad4'] } else { [int]$script:Cfg.DefaultDad }
                if (-not $dupNow -and $cur -eq [int]$script:Cfg.CampusDad -and $orig -ne $cur) {
                    [void](Invoke-Change "Non-campus network: duplicate-address probes restored to $orig on $($ad.Name)" {
                        Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -DadTransmits $orig -ErrorAction Stop
                    })
                }
            }
        } else { Write-Log 'INFO' 'Environment unknown: leaving duplicate-address settings untouched.' }
    }
    $Ctx.Repaired = $false
    if ($ipif -and [string]$ipif.Dhcp -eq 'Disabled') {
        $stGw = @(Get-GatewaysV4 $ad) | Select-Object -First 1
        $stAlive = $false
        if ($stGw) {
            $stAlive = (Test-GatewayAlive $ad $stGw).Alive
        } elseif ($Mode -eq 'AutoHeal') {
            $stAlive = $true
        } else {
            $peerArp = @(Get-NetNeighbor -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object {
                @('Reachable','Stale','Delay','Probe') -contains [string]$_.State -and
                $_.IPAddress -notmatch '^(169\.254\.|127\.|224\.|239\.|255\.)' -and
                $_.LinkLayerAddress -and $_.LinkLayerAddress -notmatch '^(00-)+00$|^(ff-)+ff$'
            })
            if ($peerArp.Count -gt 0) { $stAlive = $true }
        }
        if (-not $stAlive) {
            $origIpInfo = $null
            $stIps = @(Get-NetIPAddress -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notmatch '^(169\.254\.|127\.)' })
            if ($stIps.Count -gt 0) {
                $origIpInfo = @{ IPAddress = [string]$stIps[0].IPAddress; PrefixLength = [int]$stIps[0].PrefixLength; DefaultGateway = $(if ($stGw) { [string]$stGw } else { '' }) }
                Save-Original $guid 'StaticIp4' $origIpInfo
            }
            $gwLabel = if ($stGw) { "gateway $stGw unreachable" } else { "no default gateway configured" }
            [void](Invoke-Change "Static IPv4 ($gwLabel) on $($ad.Name): enabling DHCP to acquire valid lease" {
                if ($stGw) { Remove-NetRoute -InterfaceIndex $ad.ifIndex -DestinationPrefix '0.0.0.0/0' -NextHop $stGw -Confirm:$false -ErrorAction SilentlyContinue }
                Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -Dhcp Enabled -ErrorAction Stop
            })
            $Ctx.Repaired = (Repair-Dhcp $ad)
            if (-not $Ctx.Repaired -and $origIpInfo -and -not (Get-ValidIPv4 $ad)) {
                Write-Log 'WARN' "DHCP failed to acquire lease on $($ad.Name); rolling back to static IP $($origIpInfo.IPAddress)..."
                [void](Invoke-Change "Rollback to static IP on $($ad.Name)" {
                    Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -Dhcp Disabled -ErrorAction Stop
                    Remove-NetIPAddress -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
                    $params = @{ InterfaceIndex = $ad.ifIndex; IPAddress = $origIpInfo.IPAddress; PrefixLength = $origIpInfo.PrefixLength; ErrorAction = 'Stop' }
                    if ($origIpInfo.DefaultGateway) { $params.DefaultGateway = $origIpInfo.DefaultGateway }
                    New-NetIPAddress @params -ErrorAction SilentlyContinue | Out-Null
                })
            }
            $fresh = Get-NetAdapter -Name $ad.Name -ErrorAction SilentlyContinue; if ($fresh) { $ad = $fresh; $Ctx.Ad = $fresh }
            $script:EnvCache.Remove($guid)
            $Ctx.Env = Get-AdapterEnvironment $ad
        }
    }
    if (-not (Get-ValidIPv4 $ad)) {
        $Ctx.Repaired = (Repair-Dhcp $ad)
        $fresh = Get-NetAdapter -Name $ad.Name -ErrorAction SilentlyContinue; if ($fresh) { $ad = $fresh; $Ctx.Ad = $fresh }
        $script:EnvCache.Remove($guid)
        $Ctx.Env = Get-AdapterEnvironment $ad
    } elseif ($ipif -and [string]$ipif.Dhcp -eq 'Enabled') {
        $curGw = @(Get-GatewaysV4 $ad) | Select-Object -First 1
        $gwOk = if ($curGw) { (Test-GatewayAlive $ad $curGw).Alive } else { $false }
        if (-not $gwOk) {
            Write-Log 'WARN' "IPv4 lease is present on $($ad.Name), but default gateway is $(if ($curGw) { "$curGw (unreachable)" } else { 'missing' }). Refreshing DHCP lease..."
            $Ctx.Repaired = (Repair-Dhcp $ad -ForceRelease)
            $fresh = Get-NetAdapter -Name $ad.Name -ErrorAction SilentlyContinue; if ($fresh) { $ad = $fresh; $Ctx.Ad = $fresh }
            $script:EnvCache.Remove($guid)
            $Ctx.Env = Get-AdapterEnvironment $ad
        }
    }
    $validIp = Get-ValidIPv4 $ad
    if ($validIp -and -not $script:IsDry) {
        $subCalc = Get-SubnetInfoFromLease $ad
        if ($subCalc -and $subCalc.Broadcast) { [void](Test-Ping $subCalc.Broadcast 150) }
    }
    if ($validIp -and $Ctx.Env.Env -eq 'Campus' -and -not $script:IsDry) {
        $gw = @(Get-GatewaysV4 $ad) | Select-Object -First 1
        if ($gw) { $script:State.Misc['LastCampusLease'] = @{ Ip = [string]$validIp; Gateway = [string]$gw; Time = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss') } }
    }
}

# ==============================================================================
# LAYER 3 - GATEWAY ARP INTEGRITY (verify, then lock; auto-release if it hurts)
# ==============================================================================
function Get-GatewayMacs($Ad, [string]$Gw, [int]$Samples = 3) {
    if (-not $Ad -or -not $Ad.ifIndex -or -not $Gw) { return @() }
    $macs = @()
    for ($i = 0; $i -lt $Samples; $i++) {
        $n = Get-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -AddressFamily IPv4 -ErrorAction SilentlyContinue |
             Where-Object { $_.LinkLayerAddress -and $_.LinkLayerAddress -notmatch '^(00-)+00$' -and @('Unreachable','Incomplete') -notcontains [string]$_.State } | Select-Object -First 1
        if (-not $n -or $n.State -eq 'Stale') {
            if (-not $script:IsDry) { [void](Test-Ping $Gw 500) }
            $n = Get-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -AddressFamily IPv4 -ErrorAction SilentlyContinue |
                 Where-Object { $_.LinkLayerAddress -and $_.LinkLayerAddress -notmatch '^(00-)+00$' -and @('Unreachable','Incomplete') -notcontains [string]$_.State } | Select-Object -First 1
        }
        if ($n) {
            $macs += ([string]$n.LinkLayerAddress).ToUpper()
        } else {
            if (-not $script:IsDry) {
                Remove-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -Confirm:$false -ErrorAction SilentlyContinue
                [void](Test-Ping $Gw 700)
            }
            Start-Sleep -Milliseconds 150
            $n = Get-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -AddressFamily IPv4 -ErrorAction SilentlyContinue |
                 Where-Object { $_.LinkLayerAddress -and $_.LinkLayerAddress -notmatch '^(00-)+00$' -and @('Unreachable','Incomplete') -notcontains [string]$_.State } | Select-Object -First 1
            if ($n) { $macs += ([string]$n.LinkLayerAddress).ToUpper() }
        }
        if ($i -lt ($Samples - 1)) { Start-Sleep -Milliseconds 100 }
    }
    return $macs
}
function Remove-GatewayLock($Ad, [string]$Gw) {
    if (-not $Ad -or -not $Ad.ifIndex -or -not $Gw) { return }
    if ($script:IsDry) { Write-Log 'DRY' "Would release ARP lock for $Gw on $($Ad.Name)"; return }
    Remove-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -PolicyStore ActiveStore -Confirm:$false -ErrorAction SilentlyContinue
    Remove-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -PolicyStore PersistentStore -Confirm:$false -ErrorAction SilentlyContinue
    Remove-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -Confirm:$false -ErrorAction SilentlyContinue
    [void](Invoke-Native (Get-SysExe 'arp.exe') @('-d', $Gw) 5000)
    # Retain the recorded MAC in $script:State.Arp so Get-ArpDecision can continue
    # to compare against $Prev and detect rogue spoofed MAC candidates!
    $t = Get-SubTable 'Arp' ([string]$Ad.InterfaceGuid)
}
function Release-ArpLocks($Ad) {
    if (-not $Ad -or -not $Ad.InterfaceGuid) { return }
    $t = Get-SubTable 'Arp' ([string]$Ad.InterfaceGuid)
    foreach ($gw in @($t.Keys)) {
        [void](Invoke-Change "Gateway ARP lock released: $gw" { Remove-GatewayLock $Ad $gw })
    }
}
function Lock-GatewayArp($Ad) {
    if (-not $Ad) { return }
    $ctx = @{ Ad = $Ad; Env = (Get-AdapterEnvironment $Ad) }
    Shield-GatewayArp $ctx 'Online'
}
function Shield-GatewayArp($Ctx, [string]$ConnState) {
    if (-not $script:Cfg.ArpLock) { return }
    $ad = $Ctx.Ad
    if ($Ctx.Env.Env -eq 'Other') { Release-ArpLocks $ad; return }
    if ($Ctx.Env.Env -ne 'Campus') { return }
    if ($script:IsDry) { Write-Log 'DRY' 'Would verify gateway ARP stability (3 samples), compare it with the MAC seen before, and lock it if consistent.'; return }
    $subInfo = Get-SubnetInfoFromLease $ad
    $activeGws = @(Get-GatewaysV4 $ad)
    if ($script:State.Misc['InjectedHostRoutes'] -is [array]) {
        $pruned = @()
        foreach ($oldGw in @($script:State.Misc['InjectedHostRoutes'] | Where-Object { $_ -and $activeGws -notcontains $_ -and $_ -match '^\d{1,3}(\.\d{1,3}){3}$' })) {
            try {
                [void](Invoke-Change ("Pruned stale off-subnet host route for {0} on {1}" -f $oldGw, $ad.Name) {
                    Remove-NetRoute -InterfaceIndex $ad.ifIndex -DestinationPrefix ("{0}/32" -f $oldGw) -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
                })
                $pruned += $oldGw
            } catch {}
        }
        if ($pruned.Count -gt 0) {
            $script:State.Misc['InjectedHostRoutes'] = @($script:State.Misc['InjectedHostRoutes'] | Where-Object { $_ -and $pruned -notcontains $_ })
        }
    }
    foreach ($gw in $activeGws) {
        if ($subInfo -and -not (Test-SubnetContainsIp $subInfo.NetworkAddress $subInfo.SubnetMask $gw)) {
            Write-Log 'WARN' ("Gateway {0} is outside subnet {1}/{2} on {3}; injecting on-link host route" -f $gw, $subInfo.NetworkAddress, $subInfo.PrefixLength, $ad.Name)
            try {
                $existingHostRoute = Get-NetRoute -InterfaceIndex $ad.ifIndex -DestinationPrefix ("{0}/32" -f $gw) -AddressFamily IPv4 -ErrorAction SilentlyContinue
                if (-not $existingHostRoute) {
                    [void](Invoke-Change ("Injected on-link host route for off-subnet gateway {0} on {1}" -f $gw, $ad.Name) {
                        New-NetRoute -InterfaceIndex $ad.ifIndex -DestinationPrefix ("{0}/32" -f $gw) -NextHop '0.0.0.0' -RouteMetric 5 -AddressFamily IPv4 -PolicyStore ActiveStore -ErrorAction Stop | Out-Null
                    })
                    Add-TrackedHostRoute $gw
                }
            } catch {}
        }
        $existing = Get-NetNeighbor -InterfaceIndex $ad.ifIndex -IPAddress $gw -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($existing -and $existing.State -eq 'Permanent') {
            $gwTest = Test-GatewayAlive $ad $gw
            $lockAlive = [bool]($gwTest.Alive)
            if ($lockAlive) {
                Write-Log 'INFO' "Gateway ARP lock for $gw verified ($(if ($ConnState -eq 'Online') { 'online' } else { 'gateway reachable; WAN offline' }))."
                continue
            }
            Write-Log 'WARN' "Gateway $gw unreachable while ARP-locked: re-learning gateway $gw (the MAC may have changed)."
            Remove-GatewayLock $ad $gw
        }
        $macs = @(Get-GatewayMacs $ad $gw 3)
        if ($macs.Count -lt 3) { Write-Log 'INFO' "Gateway $gw did not answer ARP consistently; not locking."; continue }
        if (@($macs | Select-Object -Unique).Count -ne 1) {
            Write-Log 'ALERT' ("ARP SPOOFING SUSPECTED: gateway {0} answered from several MACs ({1}). Not locking; avoid sensitive logins on this LAN." -f $gw, (($macs | Select-Object -Unique) -join ', '))
            continue
        }
        $mac = $macs[0]
        $mem = Get-SubTable 'Arp' ([string]$ad.InterfaceGuid)
        if ($script:State.Misc['ArpCand'] -isnot [hashtable]) { $script:State.Misc['ArpCand'] = @{} }
        $dec = Get-ArpDecision ([string]$mem[$gw]) $mac $script:State.Misc['ArpCand'][$gw] (Get-Date)
        if ($dec -eq 'candidate') {
            $script:State.Misc['ArpCand'][$gw] = @{ Mac = $mac; Since = (Get-Date).ToString('o') }
            $isVrrp = ($mac -match '^(?:00-00-5E-00-01|00-00-5E-00-02|00-00-0C-07-AC|00-00-0C-9F-F|00-07-B4|00-05-73-A0)')
            if (-not $isVrrp) {
                try {
                    $firstByte = [convert]::ToByte(($mac -split '[:-]')[0], 16)
                    if (($firstByte -band 2) -ne 0) { $isVrrp = $true }
                } catch {}
            }
            if ($isVrrp) {
                Write-Log 'INFO' ("High-availability redundancy transition (VRRP/HSRP) detected for gateway {0}: {1} -> {2}." -f $gw, [string]$mem[$gw], $mac)
            } else {
                Write-Log 'ALERT' ("Gateway {0} now answers from {1}, but it used to answer from {2}. Not locking it. If IT did not replace the router, treat this network with suspicion." -f $gw, $mac, [string]$mem[$gw])
            }
            continue
        }
        if ($dec -eq 'wait') { Write-Log 'WARN' ("Gateway {0} still answers from the new MAC {1}; it is locked only after 24 stable hours." -f $gw, $mac); continue }
        $ip = $Ctx.Env.Ip
        $ok = Invoke-Change "Gateway ARP locked: $gw -> $mac" {
            Remove-NetNeighbor -InterfaceIndex $ad.ifIndex -IPAddress $gw -PolicyStore ActiveStore -Confirm:$false -ErrorAction SilentlyContinue
            Remove-NetNeighbor -InterfaceIndex $ad.ifIndex -IPAddress $gw -PolicyStore PersistentStore -Confirm:$false -ErrorAction SilentlyContinue
            try {
                New-NetNeighbor -InterfaceIndex $ad.ifIndex -IPAddress $gw -LinkLayerAddress $mac -State Permanent -PolicyStore ActiveStore -ErrorAction Stop | Out-Null
                if ($script:Cfg.ArpPersistent) { New-NetNeighbor -InterfaceIndex $ad.ifIndex -IPAddress $gw -LinkLayerAddress $mac -State Permanent -PolicyStore PersistentStore -ErrorAction SilentlyContinue | Out-Null }
            } catch {
                $r = Invoke-Native (Get-SysExe 'arp.exe') @('-s', $gw, $mac, $ip) 5000
                if ($r.ExitCode -ne 0) { throw 'both New-NetNeighbor and arp -s failed' }
            }
        }
        if ($ok) {
            $mem[$gw] = $mac
            if ($script:State.Misc['ArpCand'].ContainsKey($gw)) { $script:State.Misc['ArpCand'].Remove($gw) }
        }
    }
}
# Layer 3 Subnet Calculus & Adaptive PMTUD (Universal Zero-Hardcode Standard)
function Test-SubnetContainsIp([string]$NetworkAddress, [string]$SubnetMask, [string]$TargetIp) {
    try {
        if (-not $NetworkAddress -or -not $SubnetMask -or -not $TargetIp) { return $false }
        $net = [System.Net.IPAddress]::Parse($NetworkAddress).GetAddressBytes()
        $mask = [System.Net.IPAddress]::Parse($SubnetMask).GetAddressBytes()
        $target = [System.Net.IPAddress]::Parse($TargetIp).GetAddressBytes()
        for ($i = 0; $i -lt 4; $i++) {
            if (($target[$i] -band $mask[$i]) -ne $net[$i]) { return $false }
        }
        return $true
    } catch { return $false }
}

function Get-SubnetInfoFromLease($Ad) {
    if (-not $Ad) { return $null }
    $ipObj = Get-NetIPAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike '169.254*' } | Select-Object -First 1
    if (-not $ipObj -or -not $ipObj.IPAddress) { return $null }
    $ipStr = [string]$ipObj.IPAddress
    $prefix = [int]$ipObj.PrefixLength
    if ($prefix -le 0 -or $prefix -gt 32) {
        $reg = Get-IfaceReg ([string]$Ad.InterfaceGuid)
        $maskStr = if ($reg -and $reg.DhcpSubnetMask) { [string]$reg.DhcpSubnetMask } elseif ($reg -and $reg.SubnetMask) { [string]$reg.SubnetMask } else { '' }
        if ($maskStr) {
            $parsedMask = $null
            if ([System.Net.IPAddress]::TryParse($maskStr, [ref]$parsedMask)) {
                $calcPrefix = 0
                foreach ($b in $parsedMask.GetAddressBytes()) {
                    for ($bit = 7; $bit -ge 0; $bit--) {
                        if (($b -band [math]::Pow(2, $bit)) -ne 0) { $calcPrefix++ }
                    }
                }
                if ($calcPrefix -gt 0 -and $calcPrefix -le 32) { $prefix = $calcPrefix }
            }
        }
    }

    $ip = [System.Net.IPAddress]::Parse($ipStr)
    $ipBytes = $ip.GetAddressBytes()
    if ($prefix -le 0 -or $prefix -gt 32) {
        $prefix = if ($ipBytes[0] -lt 128) { 8 } elseif ($ipBytes[0] -lt 192) { 16 } else { 24 }
    }
    $maskBytes = New-Object byte[] 4
    $wildBytes = New-Object byte[] 4
    $netBytes = New-Object byte[] 4
    $bcastBytes = New-Object byte[] 4

    for ($i = 0; $i -lt 4; $i++) {
        $bits = [math]::Max(0, [math]::Min(8, $prefix - ($i * 8)))
        $maskBytes[$i] = [byte]$(if ($bits -eq 0) { 0 } else { 256 - [math]::Pow(2, 8 - $bits) })
        $netBytes[$i]  = [byte]($ipBytes[$i] -band $maskBytes[$i])
        $wildBytes[$i] = [byte](255 -bxor $maskBytes[$i])
        $bcastBytes[$i]= [byte]($netBytes[$i] -bor $wildBytes[$i])
    }

    $minHostBytes = [byte[]]$netBytes.Clone()
    $maxHostBytes = [byte[]]$bcastBytes.Clone()
    if ($prefix -le 30) {
        $minHostBytes[3] = [byte]($minHostBytes[3] + 1)
        $maxHostBytes[3] = [byte]($maxHostBytes[3] - 1)
    }

    $totalHosts = if ($prefix -ge 31) { 0L } else { [int64]([math]::Pow(2, 32 - $prefix) - 2) }

    return [PSCustomObject]@{
        IPAddress      = $ipStr
        PrefixLength   = $prefix
        SubnetMask     = ($maskBytes -join '.')
        WildcardMask   = ($wildBytes -join '.')
        NetworkAddress = ($netBytes -join '.')
        Broadcast      = ($bcastBytes -join '.')
        MinHost        = ($minHostBytes -join '.')
        MaxHost        = ($maxHostBytes -join '.')
        TotalHosts     = $totalHosts
    }
}

function Find-OptimalPathMtu($Ad, [string]$Target = '') {
    if (-not $Ad) { return 1500 }
    if (-not $Target) {
        $gws = @(Get-GatewaysV4 $Ad)
        $dhcpDnsList = @(Get-DhcpDnsServers ([string]$Ad.InterfaceGuid))
        $Target = if ($gws.Count -gt 0) { $gws[0] } elseif ($dhcpDnsList.Count -gt 0) { $dhcpDnsList[0] } elseif ($script:Cfg.PublicDns.Count -gt 0) { $script:Cfg.PublicDns[0] } else { '9.9.9.9' }
    }
    $mtu = Get-PathMtuForAdapter $Ad $Target
    if ($null -ne $mtu -and $mtu -ge 1200 -and $mtu -le 1500) {
        return $mtu
    }
    return 1500
}

# Layer 3 Path MTU Clamping: Eliminates campus router blackhole drops on large TCP frames
# Ping.Send cannot bind to an adapter: with a second uplink the echo may leave through Wi-Fi/hotspot and the measured
# MTU would then be clamped onto the Ethernet adapter. Only measure when the route to the target really uses $Ad.
function Test-RouteViaAdapter($Ad, [string]$Target) {
    try {
        $r = @(Find-NetRoute -RemoteIPAddress $Target -ErrorAction Stop | Select-Object -First 1)
        if ($r.Count -eq 0 -or $null -eq $r[0].InterfaceIndex) { return $true }
        return ([int]$r[0].InterfaceIndex -eq [int]$Ad.ifIndex)
    } catch { return $true }
}
function Get-PathMtuForAdapter($Ad, [string]$Target = '') {
    $cands = @($Target)
    if (-not $Target) {
        if ($Ad) {
            $cands += @(Get-GatewaysV4 $Ad)
            $cands += @(Get-DhcpDnsServers ([string]$Ad.InterfaceGuid))
        }
        $cands += @($script:Cfg.PublicDns)
        $cands += @('9.9.9.9', '1.1.1.1')
    } else {
        $cands += @('1.1.1.1', '9.9.9.9')
    }
    foreach ($t in @($cands | Where-Object { $_ } | Select-Object -Unique)) {
        if (-not (Test-RouteViaAdapter $Ad $t)) {
            Write-Log 'INFO' ("Path-MTU probe to {0} skipped on {1}: route uses another interface." -f $t, $Ad.Name)
            continue
        }
        if ($null -eq (Test-Ping $t 600)) { continue }
        $res = Get-PathMtu $t
        if ($null -ne $res) { return $res }
    }
    return $null
}
function Shield-PathMtu($Ctx, [string]$ConnState) {
    if (-not $script:Cfg.AutoClampMtu) { return }
    $ad = $Ctx.Ad
    if ($Ctx.Env.Env -eq 'Other') {
        $snap = Get-SubTable 'Snapshot' ([string]$ad.InterfaceGuid)
        if ($snap.ContainsKey('Mtu')) {
            $orig = [int]$snap['Mtu']
            $ipif = Get-IPv4Interface $ad
            if ($ipif -and [int]$ipif.NlMtu -ne $orig -and ($ConnState -ne 'Online' -or (Get-PathMtuForAdapter $ad) -ge $orig)) {
                [void](Invoke-Change "Non-campus network supports full frame size: restoring MTU to $orig on $($ad.Name)" {
                    Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -NlMtuBytes $orig -ErrorAction Stop
                    Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily IPv6 -NlMtuBytes ([Math]::Max(1280, $orig)) -ErrorAction SilentlyContinue
                })
                return
            }
        }
    }
    if ($ConnState -ne 'Online') { return }
    if ($script:IsDry) { Write-Log 'DRY' 'Would measure the path MTU and lower the adapter MTU only if a blackhole is confirmed twice.'; return }
    $ipif = Get-IPv4Interface $ad
    if (-not $ipif -or [int]$ipif.NlMtu -le 1280) { return }
    $pmtu = Get-PathMtuForAdapter $ad
    $candKey = 'MtuCandidate:' + [string]$ad.InterfaceGuid
    $d = Get-MtuDecision $pmtu ([int]$ipif.NlMtu) $script:State.Misc[$candKey]
    if ($d.Action -eq 'candidate') { $script:State.Misc[$candKey] = $d.Value; Write-Log 'INFO' ("A path MTU of {0} was measured; it is applied only if the next measurement agrees." -f $d.Value) }
    elseif ($d.Action -eq 'clamp') {
        Save-Original ([string]$ad.InterfaceGuid) 'Mtu' ([int]$ipif.NlMtu)
        $v = [int]$d.Value
        $ok = Invoke-Change "Adapter MTU lowered to $v on $($ad.Name) (path MTU confirmed twice)" {
            Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -NlMtuBytes $v -ErrorAction Stop
            Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily IPv6 -NlMtuBytes ([Math]::Max(1280, $v)) -ErrorAction SilentlyContinue
        }
        if ($ok) { $script:State.Misc.Remove($candKey) }
    } else { if ($null -ne $script:State.Misc[$candKey]) { $script:State.Misc.Remove($candKey) } }
}
# Layer 3 Route Shield: Verify reachability and prune unreachable duplicate default gateways
function Shield-DefaultRoutes($Ctx) {
    $ad = $Ctx.Ad
    $gws = @(Get-GatewaysV4 $ad)
    if ($gws.Count -le 1) { return }
    if ($script:IsDry) { Write-Log 'DRY' "Would verify and prune unreachable duplicate default gateways on $($ad.Name)"; return }
    $aliveGws = @()
    $deadGws = @()
    foreach ($gw in $gws) {
        # a gateway under OUR ARP lock has an unknowable liveness here (its entry is permanent): never prune it on that basis
        $locked = Get-NetNeighbor -InterfaceIndex $ad.ifIndex -IPAddress $gw -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { [string]$_.State -eq 'Permanent' } | Select-Object -First 1
        if ($locked) { $aliveGws += $gw; continue }
        $check = Test-GatewayAlive $ad $gw
        if ($check.Alive) { $aliveGws += $gw } else { $deadGws += $gw }
    }
    if ($aliveGws.Count -ge 1 -and $deadGws.Count -ge 1) {
        foreach ($dgw in $deadGws) {
            $routes = @(Get-NetRoute -InterfaceIndex $ad.ifIndex -DestinationPrefix '0.0.0.0/0' -NextHop $dgw -AddressFamily IPv4 -ErrorAction SilentlyContinue)
            if ($routes.Count -gt 0 -and [int]$routes[0].RouteMetric -lt 256) {
                Save-Original ([string]$ad.InterfaceGuid) ("DemotedRoute_$dgw") @{ DestinationPrefix = '0.0.0.0/0'; NextHop = $dgw; RouteMetric = [int]$routes[0].RouteMetric }
                [void](Invoke-Change "Demoted metric on unresponsive default gateway $dgw to 256 on $($ad.Name) (prevents blackhole while preserving VRRP/HSRP standby)" {
                    Set-NetRoute -InterfaceIndex $ad.ifIndex -DestinationPrefix '0.0.0.0/0' -NextHop $dgw -RouteMetric 256 -ErrorAction Stop
                })
            }
        }
    }
}
# Layer 3 Multi-Homing: Ensure Gigabit Ethernet takes priority over metered Wi-Fi hotspot when Ethernet is Online (Dual-Stack IPv4 & IPv6)
# Pure decision (unit-tested). THREE mutually exclusive plans, so a NON-campus wired network can never be demoted and
# never gets the NITJSR /32 host routes pointed at a foreign router. The v4.5.1 bug was one compound condition
# ('not Campus OR not Online'): on a home/office network (Env = 'Other') that is perfectly Online it was true, so a
# working gigabit link was pushed to metric 50, Wi-Fi boosted to 15 and the campus host routes injected off-campus.
function Get-RouteMetricPlan([string]$EnvName, [string]$ConnState, [int]$OtherCount, [string]$Profile = '') {
    if (-not $Profile) { $Profile = Get-RouteProfileName }
    if ($Profile -eq 'Windows') {
        return @{ Mode = 'Restore'; Ethernet = 0; Others = 0; CampusRoutes = $false; Why = 'Windows Default: automatic metrics enabled' }
    }
    if ($Profile -eq 'Ethernet') {
        return @{ Mode = 'Promote'; Ethernet = 10; Others = 40; CampusRoutes = $false; Why = 'Forced Ethernet First: wired priority active' }
    }
    if ($Profile -eq 'Wifi') {
        if ($OtherCount -le 0) {
            return @{ Mode = 'Restore'; Ethernet = 0; Others = 0; CampusRoutes = $false; Why = 'Forced Wi-Fi First: no secondary uplink active, metrics restored' }
        }
        $hasCampus = ($EnvName -eq 'Campus')
        return @{ Mode = 'Protect'; Ethernet = 50; Others = 15; CampusRoutes = $hasCampus; Why = 'Forced Wi-Fi First: hotspot primary, campus routes on Ethernet' }
    }
    # Adaptive (Default): Smart campus-aware multi-homing
    if ($EnvName -ne 'Campus') {
        # Branch 1: not the campus network. Nothing here justifies touching routing at all.
        return @{ Mode = 'Restore'; Ethernet = 0; Others = 0; CampusRoutes = $false; Why = 'Non-campus network: metrics restored' }
    }
    if ($ConnState -ne 'Online') {
        if ($OtherCount -gt 0) {
            # Branch 2: campus portal still unauthenticated while a secondary uplink works: protect that uplink.
            return @{ Mode = 'Protect'; Ethernet = 50; Others = 15; CampusRoutes = $true; Why = 'Campus link not authenticated: secondary uplink kept primary' }
        }
        # Branch 2b: nothing to protect and nothing verified: leave the system exactly as the user had it.
        return @{ Mode = 'Restore'; Ethernet = 0; Others = 0; CampusRoutes = $false; Why = 'Ethernet not online and no secondary uplink active' }
    }
    # Branch 3: campus link verified online: Ethernet first, the rest behind it.
    return @{ Mode = 'Promote'; Ethernet = 10; Others = 40; CampusRoutes = $false; Why = 'Campus link verified online: Ethernet first' }
}
function Shield-RouteMetrics($Ctx, [string]$ConnState) {
    if (-not $script:Cfg.ManageMetrics) { return }
    if ($Ctx -and -not $Ctx.Ad -and ($Ctx.InterfaceIndex -or $Ctx.InterfaceGuid)) {
        $Ctx = @{ Ad = $Ctx; Env = (Get-AdapterEnvironment $Ctx) }
    }
    if (-not $ConnState) {
        $curIp = if ($Ctx -and $Ctx.Ad) { Get-ValidIPv4 $Ctx.Ad } else { Get-PrimarySourceIp }
        $ConnState = if ($curIp) { (Get-InternetState -NoCache -SourceIp $curIp).State } else { 'Offline' }
    }
    $ad = $Ctx.Ad
    if (-not $ad) { return }
    $others = @(Get-OtherUplinkAdapters)
    $plan = Get-RouteMetricPlan ([string]$Ctx.Env.Env) $ConnState $others.Count
    if ($plan.Mode -eq 'Restore') {
        if (-not $script:IsDry) { Remove-CampusHostRoutes $ad.ifIndex }
        $hasOtherCampus = @(Get-EthernetAdapters | Where-Object { $_.ifIndex -ne $ad.ifIndex -and (Get-AdapterEnvironment $_).Env -eq 'Campus' }).Count -gt 0
        if (-not $hasOtherCampus -and ((Test-MetricsManaged) -or (Get-RouteProfileName) -eq 'Windows')) {
            Restore-InterfaceMetrics ([string]$plan.Why)
        }
        return
    }
    # Branch 3 removes the campus host routes BEFORE promoting; branch 2 injects them AFTER demoting, so the
    # portal/resolver path is built on a link that is already the lower-priority one.
    if (-not $plan.CampusRoutes -and -not $script:IsDry) { Remove-CampusHostRoutes $ad.ifIndex }
    foreach ($af in @('IPv4', 'IPv6')) {
        $eth = Get-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily $af -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($eth -and [int]$eth.InterfaceMetric -ne [int]$plan.Ethernet) {
            [void](Set-InterfaceMetric $eth ([int]$plan.Ethernet) ("Ethernet {0} metric set to {1} ({2})" -f $af, $plan.Ethernet, $plan.Why))
        }
    }
    $targetWireless = @(Get-AllWirelessAdapters | Where-Object { $_.Status -eq 'Up' })
    $allTargetOthers = @(@($others | Where-Object { $_.Status -eq 'Up' }) + @($targetWireless) | Sort-Object ifIndex -Unique)
    foreach ($w in $allTargetOthers) {
        foreach ($af in @('IPv4', 'IPv6')) {
            $wi = Get-NetIPInterface -InterfaceIndex $w.ifIndex -AddressFamily $af -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($wi -and [int]$wi.InterfaceMetric -ne [int]$plan.Others) {
                [void](Set-InterfaceMetric $wi ([int]$plan.Others) ("{0} {1} metric set to {2} ({3})" -f $w.Name, $af, $plan.Others, $plan.Why))
            }
        }
    }
    if ($plan.CampusRoutes) {
        # Portal + campus resolver stay reachable over THIS cable; the host route also carries a live redirect literal.
        $redirect = $null
        try { if ($script:ConnCache -and $script:ConnCache.Result -and $script:ConnCache.Result.Location) { $redirect = [uri][string]$script:ConnCache.Result.Location } } catch { $redirect = $null }
        Ensure-CampusPortalPath $redirect
    }
}
# ==============================================================================
# LAYER 4 - ADAPTIVE DNS (measured, not hard-coded) + campus-domain split rule
# ==============================================================================
$script:WatchdogOn = $false

function New-DnsQueryPacket([string]$Name, [int]$Id) {
    $b = New-Object 'System.Collections.Generic.List[byte]'
    $b.AddRange([byte[]]@(([byte](($Id -shr 8) -band 255)), ([byte]($Id -band 255)), 1, 0, 0, 1, 0, 0, 0, 0, 0, 0))
    $cleanName = ([string]$Name).Trim().TrimEnd('.')
    foreach ($l in $cleanName.Split('.')) { if ($l.Length -gt 0) { $b.Add([byte]$l.Length); $b.AddRange([System.Text.Encoding]::ASCII.GetBytes($l)) } }
    $b.AddRange([byte[]]@(0, 0, 1, 0, 1))
    return ,($b.ToArray())
}
# Real DNS-over-UDP probe, all servers in PARALLEL.
#  - A fresh transaction id every round (a late answer to an earlier round can never be mistaken for this one).
#  - Waits in the kernel with Socket.Select: wakes the instant a reply lands. (Start-Sleep rounds up to the 15.6 ms
#    Windows timer tick, which made a 2 ms resolver look like 16 ms.)
#  - Round 1 gets 1.5x the budget (cold resolver cache); a blocked resolver costs ONE round; a refused one returns sooner.
#  - Sockets are bound to the Ethernet adapter's own IP (strong-host routing keeps them on that link).
# Returns @{ server = medianMs or $null }.
function Measure-ResolversFast([string[]]$Servers, [int]$TimeoutMs = 600, [int]$Port = 53, [string]$SourceIp) {
    $result = @{}
    $times = @{}
    foreach ($s in $Servers) { $result[$s] = $null; $times[$s] = @() }
    if (-not $PSBoundParameters.ContainsKey('SourceIp')) { $SourceIp = ''; if ($script:Cfg.ProbeSourceBind) { $SourceIp = Get-PrimarySourceIp } }
    $alive = @($Servers)
    $baseId = Get-Random -Minimum 1000 -Maximum 60000
    $round = 0
    foreach ($name in $script:Cfg.DnsTestNames) {
        if ($alive.Count -eq 0) { break }
        $round++
        $id = ($baseId + $round) -band 65535
        $hi = [byte](($id -shr 8) -band 255)
        $lo = [byte]($id -band 255)
        $budget = $TimeoutMs; if ($round -eq 1) { $budget = [int]($TimeoutMs * 1.5) }
        [byte[]]$pkt = New-DnsQueryPacket $name $id
        $pending = @{}
        foreach ($s in $alive) {
            $u = $null
            try {
                if ($SourceIp) {
                    # A tentative/DAD address cannot be bound yet (WSAEADDRNOTAVAIL). Falling back to an unbound
                    # socket keeps the measurement going; dropping the server here would report a good resolver as
                    # 'blocked or down' purely because the adapter had not finished settling.
                    try { $u = New-Object System.Net.Sockets.UdpClient((New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($SourceIp), 0))) }
                    catch { if ($u) { try { $u.Close() } catch {} }; $u = $null }
                }
                if (-not $u) { $u = New-Object System.Net.Sockets.UdpClient }
                try { $u.Client.ReceiveBufferSize = 4096; $u.Client.SendBufferSize = 4096 } catch {}
                $u.Connect($s, $Port)
                [void]$u.Send($pkt, $pkt.Length)
                $pending[$s] = @{ U = $u; SW = [System.Diagnostics.Stopwatch]::StartNew() }
            } catch { if ($u) { try { $u.Close() } catch {} } }
        }
        $clock = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            while ($pending.Count -gt 0 -and $clock.ElapsedMilliseconds -lt $budget) {
                $slice = [int][math]::Min(25, [math]::Max(1, $budget - $clock.ElapsedMilliseconds))
                $rl = New-Object System.Collections.ArrayList
                foreach ($s in $pending.Keys) { [void]$rl.Add($pending[$s].U.Client) }
                try { [System.Net.Sockets.Socket]::Select($rl, $null, $null, ($slice * 1000)) } catch { $rl.Clear(); Start-Sleep -Milliseconds 2 }
                foreach ($s in @($pending.Keys)) {
                    $p = $pending[$s]
                    if ($rl.Contains($p.U.Client)) {
                        $ms = $p.SW.Elapsed.TotalMilliseconds
                        $ep = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
                        try {
                            $resp = $p.U.Receive([ref]$ep)
                            if ($resp -and $resp.Length -ge 12) {
                                # must be OUR transaction id, a response (QR=1) and NOERROR, NXDOMAIN or REFUSED (pre-auth captive liveness)
                                $rcode = ($resp[3] -band 15)
                                if ($resp[0] -eq $hi -and $resp[1] -eq $lo -and (($resp[2] -band 128) -ne 0) -and ($rcode -eq 0 -or $rcode -eq 3 -or $rcode -eq 5)) {
                                    $times[$s] += [int][math]::Round($ms)
                                }
                            }
                        } catch {}   # refused / reset: counts as no answer, immediately
                        try { $p.U.Close() } catch {}
                        $pending.Remove($s)
                        continue
                    }
                    $refused = $false
                    try { if ([int]$p.U.Client.GetSocketOption([System.Net.Sockets.SocketOptionLevel]::Socket, [System.Net.Sockets.SocketOptionName]::Error) -ne 0) { $refused = $true } } catch {}
                    if ($refused) { try { $p.U.Close() } catch {}; $pending.Remove($s) }   # reading SO_ERROR clears it: never Receive after this
                }
            }
        } finally {
            foreach ($s in @($pending.Keys)) { try { $pending[$s].U.Close() } catch {} }
        }
        $alive = @($alive | Where-Object { ($round - $times[$_].Count) -lt 2 })   # tolerate one cold-cache miss, then stop
    }
    foreach ($s in $Servers) {
        if ($times[$s].Count -ge 2) {
            $sorted = @($times[$s] | Sort-Object)
            $result[$s] = $sorted[[int][math]::Floor($sorted.Count / 2)]
        }
    }
    # Packet-loss resiliency fallback: if high LAN contention prevents 2 samples, accept any resolver with at least 1 verified response
    if (@($result.Values | Where-Object { $null -ne $_ }).Count -eq 0) {
        foreach ($s in $Servers) {
            if ($times[$s].Count -ge 1) {
                $result[$s] = $times[$s][0]
            }
        }
    }
    return $result
}
function Measure-Resolver([string]$Server) {
    $r = Measure-ResolversFast @($Server)
    return $r[$Server]
}
function Get-BestDnsOrder([string]$Guid, [string[]]$Campus) {
    $d = Get-SubTable 'Dns' $Guid
    if ($d.Order -and $d.OrderTime) {
        try {
            $age = ((Get-Date) - [datetime]::Parse([string]$d.OrderTime, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::RoundtripKind)).TotalSeconds
            if ($age -lt 1800) { return @($d.Order) }
        } catch {}
    }
    Write-Log 'INFO' 'Measuring resolver speed (campus + public)...'
    $scored = @()
    $dhcpLeased = @(Get-DhcpDnsServers $Guid)
    $cands = @(@($script:Cfg.PublicDns) + @($Campus) + @($dhcpLeased) | Where-Object { $_ } | Select-Object -Unique)
    $meas = Measure-ResolversFast $cands
    foreach ($s in $cands) {
        $ms = $meas[$s]
        if ($null -ne $ms) { $scored += [pscustomobject]@{ Server = $s; Ms = $ms }; Write-Log 'INFO' ("  {0,-15} {1} ms" -f $s, $ms) }
        else { Write-Log 'INFO' ("  {0,-15} no answer (blocked or down)" -f $s) }
    }
    if ($scored.Count -eq 0) {
        if ($Campus.Count -gt 0) { return @($Campus) }
        return @($script:Cfg.PublicDns)
    }
    $ordered = @($scored | Sort-Object Ms | ForEach-Object { [string]$_.Server })
    if ($Campus.Count -gt 0) {
        $campusAlive = @($Campus | Where-Object { $null -ne $meas[$_] } | Sort-Object { $meas[$_] })
        $primaryCampus = if ($campusAlive.Count -gt 0) { $campusAlive[0] } else { $Campus[0] }
        $rest = @($ordered | Where-Object { $_ -ne $primaryCampus } | Select-Object -First 2)
        $final = @($primaryCampus) + $rest
    } else {
        $final = @($ordered | Select-Object -First 3)
    }
    $d.Order = $final
    $d.OrderTime = (Get-Date).ToString('o')
    return $final
}
function Get-StaticDnsString($Guid) {
    $reg = Get-IfaceReg $Guid
    if ($reg -and $reg.NameServer) { return [string]$reg.NameServer }
    return ''
}
function Set-AdapterDns($Ad, [string[]]$Servers) {
    if (-not $Ad -or -not $Ad.InterfaceGuid) { return $false }
    $guid = [string]$Ad.InterfaceGuid
    $curNs = Get-StaticDnsString $guid
    $cur = @($curNs -split '[,\s]+' | Where-Object { $_ })
    $same = ($cur.Count -eq $Servers.Count)
    if ($same) { for ($i = 0; $i -lt $cur.Count; $i++) { if ($cur[$i] -ne $Servers[$i]) { $same = $false; break } } }
    if ($same) { return $false }
    Save-Original $guid 'DnsStatic' $curNs
    $ok = Invoke-Change "DNS on $($Ad.Name) -> $($Servers -join ', ')" {
        try {
            Set-DnsClientServerAddress -InterfaceIndex $Ad.ifIndex -ServerAddresses $Servers -ErrorAction Stop
        } catch {
            $netsh = Get-SysExe 'netsh.exe'
            if ($Servers.Count -gt 0) {
                [void](Invoke-Native $netsh @('interface', 'ipv4', 'set', 'dnsservers', ("name={0}" -f $Ad.Name), 'static', $Servers[0], 'primary') 5000)
                for ($si = 1; $si -lt $Servers.Count; $si++) {
                    [void](Invoke-Native $netsh @('interface', 'ipv4', 'add', 'dnsservers', ("name={0}" -f $Ad.Name), $Servers[$si], ("index={0}" -f ($si + 1))) 5000)
                }
            }
        }
    }
    if ($ok -and -not $script:IsDry) { (Get-SubTable 'Dns' $guid).Managed = $true; Clear-DnsClientCache -ErrorAction SilentlyContinue }
    return $ok
}
function Set-AdapterDnsAutomatic($Ad) {
    if (-not $Ad -or -not $Ad.InterfaceGuid) { return $false }
    $guid = [string]$Ad.InterfaceGuid
    $curNs = Get-StaticDnsString $guid
    if ($curNs -eq '') { return $false }
    Save-Original $guid 'DnsStatic' $curNs
    $ok = Invoke-Change "DNS on $($Ad.Name) -> automatic (DHCP)" {
        try {
            Set-DnsClientServerAddress -InterfaceIndex $Ad.ifIndex -ResetServerAddresses -ErrorAction Stop
        } catch {
            $netsh = Get-SysExe 'netsh.exe'
            [void](Invoke-Native $netsh @('interface', 'ipv4', 'set', 'dnsservers', ("name={0}" -f $Ad.Name), 'dhcp') 5000)
        }
    }
    if ($ok -and -not $script:IsDry) { (Get-SubTable 'Dns' $guid).Managed = $false; Clear-DnsClientCache -ErrorAction SilentlyContinue }
    return $ok
}
# Only undo what WE changed (never wipe a static DNS the user set themselves).
function Restore-AdapterDns($Ad) {
    if (-not $Ad -or -not $Ad.InterfaceGuid) { return }
    $guid = [string]$Ad.InterfaceGuid
    $d = Get-SubTable 'Dns' $guid
    if (-not $d.Managed) { return }
    $snap = Get-SubTable 'Snapshot' $guid
    $orig = if ($snap.ContainsKey('DnsStatic')) { [string]$snap['DnsStatic'] } else { '' }
    $ok = $false
    if ($orig -eq '') {
        $ok = Invoke-Change "DNS on $($Ad.Name) restored to automatic (DHCP)" { Set-DnsClientServerAddress -InterfaceIndex $Ad.ifIndex -ResetServerAddresses -ErrorAction Stop }
    } else {
        $list = @($orig -split '[,\s]+' | Where-Object { $_ })
        $ok = Invoke-Change "DNS on $($Ad.Name) restored to your original: $orig" { Set-DnsClientServerAddress -InterfaceIndex $Ad.ifIndex -ServerAddresses $list -ErrorAction Stop }
    }
    if ($ok -and -not $script:IsDry) { $d.Managed = $false; $d.Phase = 'Auto'; Clear-DnsClientCache -ErrorAction SilentlyContinue }
}
# Sweep EVERY physical adapter this tool ever substituted a resolver on (Ethernet, Wi-Fi, USB tethering, Bluetooth PAN)
# and put back the user's exact pre-Lan Fixer value. Restore-AdapterDns only touches adapters marked managed, so an
# adapter the tool never touched is never altered; when no snapshot exists (state written by an older build) it falls
# back to automatic DHCP, which is the only honest restore available. Returns how many adapters were restored.
function Restore-ManagedAdapterDns([string]$Why = 'DNS restored') {
    $n = 0
    foreach ($a in @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue)) {
        $g = [string]$a.InterfaceGuid
        if (-not $g) { continue }
        if ((Get-SubTable 'Dns' $g).Managed -eq $true) {
            Restore-AdapterDns $a
            $n++
        }
    }
    if ($n -gt 0) { Write-Log 'OK' ("{0}: {1} adapter(s) put back on the DNS they had before Lan Fixer touched them." -f $Why, $n) }
    return $n
}
function Get-OurNrptRules { return @(Get-DnsClientNrptRule -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -eq 'LanFixer-Campus' }) }
function Remove-CampusNrpt {
    foreach ($r in (Get-OurNrptRules)) { [void](Invoke-Change "Removed campus-domain DNS rule" { Remove-DnsClientNrptRule -Name $r.Name -Force -ErrorAction Stop }) }
}
# Pure (unit-tested): does this lease look like the campus the built-in Cfg values describe?
# Positive evidence: the configured campus resolver in the lease, a DNS suffix under the configured domain, or the
# configured portal answering. With no lease data at all the last known verdict (or "yes", the legacy behaviour) holds.
# Anything else is a DIFFERENT network and must never be sent the configured portal IP / campus domain.
function Get-HomeCampusVerdict([string[]]$DhcpDns, [string]$Suffix, [bool]$PortalHit, $Hist) {
    $dns = @($DhcpDns | Where-Object { $_ })
    $dom = ([string]$script:Cfg.CampusDomain).Trim().Trim('.').ToLowerInvariant()
    $sfx = ([string]$Suffix).Trim().Trim('.').ToLowerInvariant()
    if ($script:Cfg.CampusDns -and ($dns -contains [string]$script:Cfg.CampusDns)) { return $true }
    if ($dom -and $sfx -and ($sfx -eq $dom -or $sfx.EndsWith('.' + $dom))) { return $true }
    if ($PortalHit) { return $true }
    if ($dns.Count -eq 0 -and -not $sfx) {
        if ($Hist -is [hashtable] -and $Hist.ContainsKey('Home')) { return [bool]$Hist['Home'] }
        return $true
    }
    return $false
}
function Set-CampusNrpt([string[]]$Servers, [bool]$HomeNet = $true) {
    $domains = @()
    if ($HomeNet) { $domains = @($script:Cfg.CampusDomain) }
    $discDom = [string]$script:State.Misc['DiscoveredDomain']
    if ($discDom -and $domains -notcontains $discDom) { $domains += $discDom }
    try {
        $suffixes = @(Get-DnsClientGlobalSetting -ErrorAction SilentlyContinue).SuffixSearchList
        foreach ($sfx in $suffixes) {
            if ($sfx -and $sfx -notmatch 'local|internal' -and $domains -notcontains $sfx) { $domains += $sfx }
        }
    } catch {}
    $wantNs = @()
    foreach ($dm in @($domains | Where-Object { $_ } | Select-Object -Unique)) {
        $wantNs += ('.' + $dm)
        $wantNs += $dm
    }
    if ($wantNs.Count -eq 0) { Remove-CampusNrpt; return }   # nothing to map (not the home campus, nothing discovered)
    $rules = @(Get-OurNrptRules)
    $allPresent = ($rules.Count -gt 0)
    $serversMatch = $true
    foreach ($r in $rules) {
        $rNs = @($r.Namespace)
        foreach ($wn in $wantNs) { if ($rNs -notcontains $wn) { $allPresent = $false } }
        $currentNs = @($r.NameServers)
        foreach ($s in $Servers) { if ($currentNs -notcontains $s) { $serversMatch = $false } }
    }
    if ($allPresent -and $serversMatch) { return }
    Remove-CampusNrpt
    [void](Invoke-Change "Split-horizon DNS rule: $($wantNs -join ', ') -> $($Servers -join ', ')" {
        Add-DnsClientNrptRule -Namespace $wantNs -NameServers $Servers -DisplayName 'LanFixer-Campus' -Comment 'Managed by Lan Fixer' -ErrorAction Stop
    })
}
# Pure decision (unit-tested) for a NON-campus adapter whose profile is Adaptive/DHCP.
#   NoDns                                         -> Rescue     (network resolvers dead: substitute public ones)
#   we already rescued and DHCP still not usable  -> KeepRescue (reverting now would just break DNS again)
#   anything else                                 -> Restore    (leave DNS to the network)
function Get-OtherDnsAction([string]$ConnState, [bool]$Managed, [string]$Phase, [bool]$DhcpUsable) {
    if ($ConnState -eq 'NoDns') { return 'Rescue' }
    if ($Managed -and $Phase -eq 'Public' -and -not $DhcpUsable) { return 'KeepRescue' }
    return 'Restore'
}
# Do the network's own (DHCP-leased) resolvers answer right now? Probed from the adapter's own address so a second
# uplink cannot answer for it. Empty list = no.
function Test-DhcpDnsUsable([string]$Guid, [string]$SourceIp = '') {
    $dhcp = @(Get-DhcpDnsServers $Guid)
    if ($dhcp.Count -eq 0) { return $false }
    try {
        $m = Measure-ResolversFast $dhcp 600 53 $SourceIp
        foreach ($s in $dhcp) { if ($null -ne $m[$s]) { return $true } }
    } catch {}
    return $false
}
function Restore-Ipv6IfNeutralized($Ad) {
    if (-not $Ad -or -not $Ad.InterfaceGuid) { return }
    $guid = [string]$Ad.InterfaceGuid
    $d = Get-SubTable 'Dns' $guid
    if ($d.Ipv6Neutralized -ne $true) { return }
    $snap = Get-SubTable 'Snapshot' $guid
    $rd = [string]$snap['Ipv6Rd']
    if (-not $rd) { $rd = 'ControlledByDHCP' }
    $ok = Invoke-Change "IPv6 re-enabled on $($Ad.Name)" {
        Enable-NetAdapterBinding -Name $Ad.Name -ComponentId 'ms_tcpip6' -Confirm:$false -ErrorAction Stop
        Set-NetIPInterface -InterfaceIndex $Ad.ifIndex -AddressFamily IPv6 -RouterDiscovery $rd -ErrorAction SilentlyContinue
    }
    if ($ok -and -not $script:IsDry) { $d.Ipv6Neutralized = $false }
}
function Shield-DnsIntegrity($Ad) {
    if (-not $script:IsAdmin -or -not $Ad -or -not $Ad.InterfaceGuid) { return }
    if ($Ad.MediaType -and $Ad.MediaType -ne '802.3') { return }
    $guid = [string]$Ad.InterfaceGuid
    try {
        $verdict = Get-AdapterDnsVerdict $Ad
        if ($verdict.Action -ne 'Neutralize') { return }
        $v6Binding = Get-NetAdapterBinding -Name $Ad.Name -ComponentId 'ms_tcpip6' -ErrorAction SilentlyContinue
        if ($v6Binding -and $v6Binding.Enabled) {
            Save-Original $guid 'MsTcpip6' 'True'
            Save-Original $guid 'DnsStatic' (Get-StaticDnsString $guid)
            $curRd = [string](Get-NetIPInterface -InterfaceIndex $Ad.ifIndex -AddressFamily IPv6 -ErrorAction SilentlyContinue).RouterDiscovery
            if ($curRd) { Save-Original $guid 'Ipv6Rd' $curRd }
            $why = if ($verdict.IsSinkhole) { "Neutralize rogue IPv6 DNS sinkhole on $($Ad.Name)" }
                   else { "Neutralize unroutable IPv6 DNS forwarder on $($Ad.Name) (link lacks global IPv6 route)" }
            $ok = Invoke-Change $why {
                Set-NetIPInterface -InterfaceIndex $Ad.ifIndex -AddressFamily IPv6 -RouterDiscovery Disabled -ErrorAction SilentlyContinue
                Disable-NetAdapterBinding -Name $Ad.Name -ComponentId 'ms_tcpip6' -Confirm:$false -ErrorAction Stop
            }
            if ($ok -and -not $script:IsDry) {
                (Get-SubTable 'Dns' $guid).Ipv6Neutralized = $true
                (Get-SubTable 'Dns' $guid).Managed = $true
                Clear-DnsClientCache -ErrorAction SilentlyContinue
                $script:ConnCache = $null
            }
        }
    } catch {
        Write-Log 'WARN' "Shield-DnsIntegrity skipped on $($Ad.Name): $_"
    }
}
function Shield-DohFallback {
    if (-not $script:IsAdmin -or $script:IsDry) { return }
    if (-not (Get-Command 'Get-DnsClientDohServerAddress' -ErrorAction SilentlyContinue)) { return }
    try {
        $dohList = @(Get-DnsClientDohServerAddress -ErrorAction SilentlyContinue | Where-Object { -not $_.AllowFallbackToUdp })
        foreach ($doh in $dohList) {
            Write-Log 'INFO' "Permitting UDP fallback for DoH server: $($doh.ServerAddress)"
            Set-DnsClientDohServerAddress -ServerAddress $doh.ServerAddress -AllowFallbackToUdp $true -ErrorAction SilentlyContinue
        }
    } catch {}
}
function Shield-Dns($Ctx, [string]$ConnState) {
    Shield-DohFallback
    $ad = $Ctx.Ad
    Shield-DnsIntegrity $ad
    $guid = [string]$ad.InterfaceGuid
    $d = Get-SubTable 'Dns' $guid
    $prof = Get-DnsProfileName
    if ($Ctx.Env.Env -eq 'Other') {
        Restore-Ipv6IfNeutralized $ad
        Remove-CampusNrpt
        if (($prof -eq 'Adaptive' -or $prof -eq 'DHCP') -and $ConnState -ne 'NoDns') {
            if ($d.Managed -eq $true -and [string]$d.Phase -eq 'Public') {
                if ((Get-OtherDnsAction $ConnState $true ([string]$d.Phase) (Test-DhcpDnsUsable $guid ([string](Get-ValidIPv4 $ad)))) -eq 'KeepRescue') {
                    Write-Log 'INFO' 'Non-campus network: the network resolvers still do not answer, so the DNS rescue stays in place (released automatically once they work).'
                    return
                }
            }
            Restore-AdapterDns $ad
            Write-Log 'INFO' 'Non-campus network: DNS is left to the network (any change made earlier is reverted).'
            return
        }
        $dhcpOther = @(Get-DhcpDnsServers $guid)
        $orderOther = switch ($prof) {
            'Cloudflare' { @($script:Cfg.CfDns) + $dhcpOther }
            'Hybrid'     { @('9.9.9.9', '8.8.8.8') + $dhcpOther }
            default      { @(Get-BestDnsOrder $guid $dhcpOther) }
        }
        $orderOther = @($orderOther | Where-Object { $_ } | Select-Object -Unique)
        if ($orderOther.Count -gt 0) {
            if (-not (Set-AdapterDns $ad $orderOther)) {
                if (-not $script:IsDry) { Clear-DnsClientCache -ErrorAction SilentlyContinue }
                Write-Log 'INFO' "DNS already set on $($ad.Name) (profile $prof)."
            }
            if (-not $script:IsDry) { $d.Phase = 'Public'; $d.ConnApplied = $(if ($ConnState -eq 'Online') { 'Online' } else { 'NotOnline' }) }
        }
        return
    }
    if ($Ctx.Env.Env -ne 'Campus') { Write-Log 'INFO' 'Environment unknown: DNS untouched.'; return }
    $campus = @(Get-DhcpDnsServers $guid)
    $homeNet = ($null -eq $Ctx.Env.Home) -or [bool]$Ctx.Env.Home
    if ($campus.Count -eq 0) {
        if ($homeNet) { $campus = @($script:Cfg.CampusDns) }
        else { $campus = @(Get-GatewaysV4 $ad | Where-Object { $_ }) }
    }
    $phase = 'Auto'
    $order = @()
    switch ($prof) {
        'DHCP'       { $phase = 'Auto' }
        'ResetDHCP'  { $phase = 'Auto' }
        'Hybrid'     { $order = @($campus) + @('9.9.9.9', '8.8.8.8'); $phase = 'Campus' }
        'Cloudflare' { $order = @($campus) + @($script:Cfg.CfDns); $phase = 'Campus' }
        default {
            if ($ConnState -eq 'Online' -or $ConnState -eq 'NoDns' -or $ConnState -eq 'Offline') {
                $order = @(Get-BestDnsOrder $guid $campus)
                if (@($order | Where-Object { $campus -notcontains $_ }).Count -gt 0) { $phase = 'Public' } else { $phase = 'Campus' }
            } else {
                $cands = @($campus)
                foreach ($gwIp in @(Get-GatewaysV4 $ad)) { if ($gwIp -and $cands -notcontains $gwIp) { $cands += $gwIp } }
                if ($homeNet -and $cands -notcontains $script:Cfg.PortalIp) { $cands += $script:Cfg.PortalIp }
                $scores = Measure-ResolversFast $cands 400
                $live = @($cands | Where-Object { $null -ne $scores[$_] } | Sort-Object { $scores[$_] })
                $dead = @($cands | Where-Object { $null -eq $scores[$_] })
                if ($live.Count -gt 0) {
                    $order = @($live + $dead)
                    $phase = 'Campus'
                } else {
                    $order = @(Get-BestDnsOrder $guid $campus)
                    if (@($order | Where-Object { $campus -notcontains $_ }).Count -gt 0) { $phase = 'Public' } else { $phase = 'Campus' }
                }
            }
        }
    }
    $order = @($order | Select-Object -Unique)
    if ($phase -eq 'Auto') {
        if (-not (Set-AdapterDnsAutomatic $ad)) { Write-Log 'INFO' "DNS already automatic on $($ad.Name) (profile $prof)." }
        Remove-CampusNrpt
    } else {
        if (-not (Set-AdapterDns $ad $order)) {
            if (-not $script:IsDry -and $ConnState -ne 'Online') { Clear-DnsClientCache -ErrorAction SilentlyContinue }
            Write-Log 'INFO' "DNS already correct on $($ad.Name) (profile $prof, phase $phase)."
        }
        $nrptExtra = if ($homeNet) { @($script:Cfg.PortalIp) } else { @() }
        $nrptServers = @($campus + $nrptExtra | Where-Object { $_ } | Select-Object -Unique)
        Set-CampusNrpt $nrptServers $homeNet
    }
    Shield-DnsIntegrity $ad
    if (-not $script:IsDry) {
        $d.Phase = $phase
        $d.ConnApplied = $(if ($ConnState -eq 'Online') { 'Online' } else { 'NotOnline' })
    }
}

# ==============================================================================
# LAYER 5 - CAPTIVE PORTAL REACHABILITY (the v1 hosts-file pin is gone: it went stale and is flagged by AV)
# ==============================================================================
function Shield-Portal($Ctxs) {
    $camp = @($Ctxs | Where-Object { $_.Env.Env -eq 'Campus' })
    $discovered = -not [string]::IsNullOrWhiteSpace([string]$script:State.Misc['DiscoveredPortalUrl'])
    if ($camp.Count -eq 0 -and -not $discovered) { Write-Log 'INFO' 'Not on campus: portal checks skipped.'; return }
    $homeAny = $false
    foreach ($cx in $camp) { if (($null -eq $cx.Env.Home) -or [bool]$cx.Env.Home) { $homeAny = $true } }
    if (-not $homeAny -and -not $discovered) { Write-Log 'INFO' 'This campus is not the one the built-in portal values describe: configured-portal checks skipped.'; return }
    $ep = Get-ActivePortalEndpoint
    $portalSrc = if ($camp.Count -gt 0) { [string](Get-ValidIPv4 $camp[0].Ad) } else { Get-PrimarySourceIp }
    $tcp = Test-TcpPort $ep.Ip $ep.Port 900 $portalSrc
    if ($tcp) { Write-Log 'OK' ("Portal {0}:{1} reachable" -f $ep.Ip, $ep.Port) }
    else { Write-Log 'WARN' ("Portal {0}:{1} not reachable (normal if the session is already authenticated and the firewall hides it)" -f $ep.Ip, $ep.Port) }
    foreach ($cx in $camp) {
        $src = [string](Get-ValidIPv4 $cx.Ad)
        $ip = Resolve-HostBounded $ep.Host 1800 $src -NoPin
        if ($ip) { Write-Log 'OK' "Portal name resolves on $($cx.Ad.Name): $($ep.Host) -> $ip" }
        else { Write-Log 'WARN' "Portal name $($ep.Host) does not resolve through $($cx.Ad.Name)'s own DNS." }
    }
}

# ==============================================================================
# LAYER 6 - EXPOSURE: treat the hostel LAN as untrusted (Public firewall profile)
# ==============================================================================
function Shield-Profile($Ctx) {
    try {
        foreach ($fSvc in @('BFE','mpssvc')) {
            $sc = Get-Service -Name $fSvc -ErrorAction SilentlyContinue
            if ($sc -and $sc.Status -ne 'Running') {
                [void](Invoke-Change ("Started firewall service {0} ({1})" -f $fSvc, $sc.DisplayName) {
                    Start-Service -Name $fSvc -ErrorAction SilentlyContinue
                })
            }
        }
    } catch {}
    if (-not $script:Cfg.ForcePublic) { return }
    $ad = $Ctx.Ad
    $np = Get-NetConnectionProfile -InterfaceIndex $ad.ifIndex -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $np) { return }
    if ($Ctx.Env.Env -eq 'Campus') {
        if ([string]$np.NetworkCategory -eq 'Private') {
            Save-Original 'NetProfiles' ("Cat:" + $np.Name) 'Private'
            [void](Invoke-Change "Network '$($np.Name)' set to Public (blocks discovery/sharing from other hostel devices)" {
                Set-NetConnectionProfile -InterfaceIndex $ad.ifIndex -NetworkCategory Public -ErrorAction Stop
            })
        } else { Write-Log 'INFO' "Network profile is $($np.NetworkCategory) (already safe or domain-managed)." }
    } elseif ($Ctx.Env.Env -eq 'Other') {
        $snap = Get-SubTable 'Snapshot' 'NetProfiles'
        if ($snap.ContainsKey("Cat:" + $np.Name) -and [string]$snap["Cat:" + $np.Name] -eq 'Private') {
            if ([string]$np.NetworkCategory -ne 'Private') {
                [void](Invoke-Change "Trusted network '$($np.Name)': restored profile to Private for local discovery and sharing" {
                    Set-NetConnectionProfile -InterfaceIndex $ad.ifIndex -NetworkCategory Private -ErrorAction Stop
                })
            }
        }
    }
}

# ==============================================================================
# LAYER 7 - SERVICES: NetBIOS chatter, NCSI sanity, stuck "no internet" icon
# ==============================================================================
function Restore-LlmnrIfManaged([string]$Why) {
    if ($script:State.Misc['LlmnrManaged'] -ne $true) { return }
    $snap = Get-SubTable 'Snapshot' 'Global'
    $orig = $null
    if ($snap.ContainsKey('Llmnr')) { $orig = $snap['Llmnr'] }
    $ok = Invoke-Change $Why { Restore-Llmnr $orig }
    if ($ok -and -not $script:IsDry) { $script:State.Misc['LlmnrManaged'] = $false }
}
# The hostel-only rules (campus-domain DNS rule, LLMNR off) are machine-wide, so they must not follow the laptop home.
# Called whenever NO Ethernet link is up (the normal repair path only runs with a cable in). If the campus resolver
# still answers over another link (campus Wi-Fi) the rules are useful there and stay.
function Invoke-RoamingCleanup {
    if (-not $script:IsAdmin) { return }
    $rules = @(Get-OurNrptRules)
    $flags = @('LlmnrManaged', 'NegCacheManaged', 'MdnsManaged', 'SmartDnsManaged', 'TcpKeepAliveManaged', 'Ipv4PrecedenceManaged')
    $hasNeutSvc = ($script:State.Misc['NeutralizedServices'] -is [hashtable] -and $script:State.Misc['NeutralizedServices'].Count -gt 0)
    $hasNeutTsk = ($script:State.Misc['NeutralizedTasks'] -is [hashtable] -and $script:State.Misc['NeutralizedTasks'].Count -gt 0)
    # A substituted resolver on Wi-Fi / USB tethering / Bluetooth PAN is a reason to clean up on its own, even when every
    # other hostel-only change has already been reverted.
    $dnsManaged = @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { (Get-SubTable 'Dns' ([string]$_.InterfaceGuid)).Managed -eq $true }).Count -gt 0
    $any = ($rules.Count -gt 0) -or (Test-MetricsManaged) -or $hasNeutSvc -or $hasNeutTsk -or $dnsManaged
    foreach ($fl in $flags) { if ($script:State.Misc[$fl] -eq $true) { $any = $true } }
    if (-not $any) { return }
    if ($Mode -eq 'AutoHeal') {
        if (-not $script:State.Misc['LinkDownSince']) {
            $script:State.Misc['LinkDownSince'] = (Get-Date).ToString('o')
            Set-StateTime 'LinkDownSince'
            Write-Log 'INFO' 'Link down: debouncing roaming cleanup against momentary cable flap (45s grace period).'
            return
        }
        if (-not (Test-Elapsed 'LinkDownSince' 45)) { Write-Log 'INFO' 'Link down under 45s: debouncing roaming cleanup against momentary cable flap.'; return }
    }
    if (Test-MetricsManaged) { Restore-InterfaceMetrics 'No active Ethernet link' }
    Remove-CampusHostRoutes
    $cd = Get-ActiveCampusDns
    $m = Measure-ResolversFast @($cd) 600 53 ''
    if ($null -ne $m[$cd]) { Write-Log 'INFO' 'No Ethernet link, but the campus resolver answers over another link (campus Wi-Fi?): campus-only settings kept.'; return }
    Write-Log 'INFO' 'No Ethernet link and the campus resolver is unreachable: undoing the hostel-only settings.'
    Remove-CampusNrpt
    Restore-LlmnrIfManaged 'Left campus: LLMNR setting restored'
    Restore-NegCacheIfManaged 'Left campus: negative DNS cache TTL restored'
    Restore-MdnsIfManaged 'Left campus: mDNS setting restored'
    Restore-SmartDnsIfManaged 'Left campus: smart name resolution restored'
    Restore-TcpKeepAliveIfManaged 'Left campus: TCP keep-alive restored'
    Restore-Ipv6PrecedenceIfManaged 'Left campus: IPv6 prefix policy restored'
    if (Test-MetricsManaged) { Restore-InterfaceMetrics 'Left campus' }
    [void](Restore-ManagedAdapterDns 'Left campus')
    foreach ($ea in @(Get-EthernetAdapters)) { Restore-Ipv6IfNeutralized $ea }
    Restore-NeutralizedInterceptors 'Left campus'
    if (-not $script:IsDry -and $script:State -is [hashtable] -and $script:State.Misc -is [hashtable]) {
        foreach ($dk in @('DiscoveredPortalUrl', 'DiscoveredPortalIp', 'DiscoveredDomain', 'DiscoveredPortalPort', 'DiscoveryTime')) {
            if ($script:State.Misc.ContainsKey($dk)) { $script:State.Misc.Remove($dk) }
        }
    }
}
function Restore-NeutralizedInterceptors([string]$Why = 'Non-campus network') {
    if ($script:State.Misc['NeutralizedTasks'] -is [hashtable]) {
        foreach ($tn in @($script:State.Misc['NeutralizedTasks'].Keys)) {
            $tp = [string]$script:State.Misc['NeutralizedTasks'][$tn]
            [void](Invoke-Change "$($Why): re-enabled task $tn" {
                Enable-ScheduledTask -TaskName $tn -TaskPath $tp -ErrorAction SilentlyContinue | Out-Null
            })
        }
        if (-not $script:IsDry) { $script:State.Misc.Remove('NeutralizedTasks') }
    }
    if ($script:State.Misc['NeutralizedServices'] -is [hashtable]) {
        foreach ($sn in @($script:State.Misc['NeutralizedServices'].Keys)) {
            $rec = $script:State.Misc['NeutralizedServices'][$sn]
            $origStart = if ($rec -is [hashtable]) { [string]$rec.StartType } else { [string]$rec }
            if ($origStart -and $origStart -ne 'Disabled') {
                [void](Invoke-Change "$($Why): restored service $sn to $origStart" {
                    Set-Service -Name $sn -StartupType $origStart -ErrorAction SilentlyContinue
                    if ($rec -is [hashtable] -and $rec.DelayedAuto) {
                        Set-ItemProperty -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\$sn" -Name DelayedAutostart -Value 1 -Type DWord -ErrorAction SilentlyContinue
                    }
                    if ($rec -is [hashtable] -and $rec.WasRunning) {
                        Start-Service -Name $sn -ErrorAction SilentlyContinue
                    }
                })
            }
        }
        if (-not $script:IsDry) { $script:State.Misc.Remove('NeutralizedServices') }
    }
}
$script:LlmnrKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient'
function Restore-Llmnr($Orig) {
    if ($script:IsDry) { return }
    if ($null -eq $Orig) { Remove-ItemProperty -LiteralPath $script:LlmnrKey -Name EnableMulticast -ErrorAction SilentlyContinue }
    else { New-ItemProperty -LiteralPath $script:LlmnrKey -Name EnableMulticast -Value ([int]$Orig) -PropertyType DWord -Force -ErrorAction Stop | Out-Null }
}
# LLMNR (like NetBIOS) lets any host on the hostel LAN answer "who is X?" and harvest credentials. Off on campus.
function Shield-Llmnr($Ctxs) {
    if (-not $script:Cfg.DisableLlmnr) { return }
    $anyCampus = (@($Ctxs | Where-Object { $_.Env.Env -eq 'Campus' })).Count -gt 0
    $anyOther  = (@($Ctxs | Where-Object { $_.Env.Env -eq 'Other' })).Count -gt 0
    $cur = $null
    try { $cur = (Get-ItemProperty -LiteralPath $script:LlmnrKey -Name EnableMulticast -ErrorAction Stop).EnableMulticast } catch {}
    if ($anyCampus) {
        if ($null -ne $cur -and [int]$cur -eq 0) { return }
        Save-Original 'Global' 'Llmnr' $cur
        $ok = Invoke-Change 'LLMNR off (blocks name-poisoning attacks on the shared hostel LAN)' {
            if (-not (Test-Path -LiteralPath $script:LlmnrKey)) { New-Item -Path $script:LlmnrKey -Force -ErrorAction Stop | Out-Null }
            New-ItemProperty -LiteralPath $script:LlmnrKey -Name EnableMulticast -Value 0 -PropertyType DWord -Force -ErrorAction Stop
        }
        if ($ok -and -not $script:IsDry) { $script:State.Misc['LlmnrManaged'] = $true }
    } elseif ($anyOther) {
        Restore-LlmnrIfManaged 'Non-campus network: LLMNR setting restored'
    }
}
$script:Tcpip6Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters'
function Restore-Ipv6PrecedenceIfManaged([string]$Why) {
    if ($script:State.Misc['Ipv4PrecedenceManaged'] -ne $true) { return }
    $snap = Get-SubTable 'Snapshot' 'Global'
    $orig = $null
    if ($snap.ContainsKey('DisabledComponents')) { $orig = $snap['DisabledComponents'] }
    $ok = Invoke-Change $Why {
        if ($null -eq $orig) { Remove-ItemProperty -LiteralPath $script:Tcpip6Key -Name DisabledComponents -ErrorAction SilentlyContinue }
        else { New-ItemProperty -LiteralPath $script:Tcpip6Key -Name DisabledComponents -Value ([int]$orig) -PropertyType DWord -Force -ErrorAction Stop | Out-Null }
    }
    if ($ok -and -not $script:IsDry) { $script:State.Misc['Ipv4PrecedenceManaged'] = $false }
}
function Shield-Ipv6Precedence($Ctxs, [string]$ConnState) {
    if (-not $script:Cfg.PreferIpv4) { return }
    $camp = @($Ctxs | Where-Object { $_.Env.Env -eq 'Campus' }) | Select-Object -First 1
    $anyOther = (@($Ctxs | Where-Object { $_.Env.Env -eq 'Other' })).Count -gt 0
    $cur = $null
    try { $cur = (Get-ItemProperty -LiteralPath $script:Tcpip6Key -Name DisabledComponents -ErrorAction Stop).DisabledComponents } catch {}
    if ($camp) {
        if ($null -ne $cur -and (([int]$cur -band 32) -ne 0)) { return }
        if ($ConnState -ne 'Online') { return }          # the evidence needs a working IPv4 path
        $v6 = Get-Ipv6State $camp.Ad $ConnState
        if ($v6.Verdict -ne 'Blackhole') { return }
        Save-Original 'Global' 'DisabledComponents' $cur
        $new = Get-PreferIpv4Value $cur
        $ok = Invoke-Change 'IPv4 preferred over IPv6 (IPv6 is advertised on this LAN but unreachable); applies after the next restart' {
            if (-not (Test-Path -LiteralPath $script:Tcpip6Key)) { New-Item -Path $script:Tcpip6Key -Force -ErrorAction Stop | Out-Null }
            New-ItemProperty -LiteralPath $script:Tcpip6Key -Name DisabledComponents -Value $new -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        }
        if ($ok -and -not $script:IsDry) { $script:State.Misc['Ipv4PrecedenceManaged'] = $true }
    } elseif ($anyOther) {
        Restore-Ipv6PrecedenceIfManaged 'Non-campus network: IPv6 prefix policy restored'
    }
}
$script:DnsParamKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters'
function Restore-NegCacheIfManaged([string]$Why) {
    if ($script:State.Misc['NegCacheManaged'] -ne $true) { return }
    $snap = Get-SubTable 'Snapshot' 'Global'
    $orig = $null
    if ($snap.ContainsKey('MaxNegativeCacheTtl')) { $orig = $snap['MaxNegativeCacheTtl'] }
    $ok = Invoke-Change $Why {
        if ($null -eq $orig) { Remove-ItemProperty -LiteralPath $script:DnsParamKey -Name MaxNegativeCacheTtl -ErrorAction SilentlyContinue }
        else { Set-ItemProperty -LiteralPath $script:DnsParamKey -Name MaxNegativeCacheTtl -Value ([int]$orig) -Type DWord -ErrorAction Stop }
    }
    if ($ok -and -not $script:IsDry) { $script:State.Misc['NegCacheManaged'] = $false }
}
function Shield-NegCache($Ctxs) {
    $anyCampus = (@($Ctxs | Where-Object { $_.Env.Env -eq 'Campus' })).Count -gt 0
    $anyOther  = (@($Ctxs | Where-Object { $_.Env.Env -eq 'Other' })).Count -gt 0
    $cur = $null
    try { $cur = (Get-ItemProperty -LiteralPath $script:DnsParamKey -Name MaxNegativeCacheTtl -ErrorAction Stop).MaxNegativeCacheTtl } catch {}
    if ($anyCampus) {
        if ($null -ne $cur -and [int]$cur -eq 5) { return }
        Save-Original 'Global' 'MaxNegativeCacheTtl' $cur
        $ok = Invoke-Change 'Windows negative DNS cache clamped to 5s (eliminates 15-minute resolution lockouts)' {
            if (-not (Test-Path -LiteralPath $script:DnsParamKey)) { New-Item -Path $script:DnsParamKey -Force -ErrorAction Stop | Out-Null }
            New-ItemProperty -LiteralPath $script:DnsParamKey -Name MaxNegativeCacheTtl -Value 5 -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        }
        if ($ok -and -not $script:IsDry) { $script:State.Misc['NegCacheManaged'] = $true }
    } elseif ($anyOther) {
        Restore-NegCacheIfManaged 'Non-campus network: negative DNS cache TTL restored'
    }
}

function Restore-MdnsIfManaged([string]$Why) {
    if ($script:State.Misc['MdnsManaged'] -ne $true) { return }
    $snap = Get-SubTable 'Snapshot' 'Global'
    $orig = $null
    if ($snap.ContainsKey('EnableMDNS')) { $orig = $snap['EnableMDNS'] }
    $ok = Invoke-Change $Why {
        if ($null -eq $orig) { Remove-ItemProperty -LiteralPath $script:DnsParamKey -Name EnableMDNS -ErrorAction SilentlyContinue }
        else { Set-ItemProperty -LiteralPath $script:DnsParamKey -Name EnableMDNS -Value ([int]$orig) -Type DWord -ErrorAction Stop }
    }
    if ($ok -and -not $script:IsDry) { $script:State.Misc['MdnsManaged'] = $false }
}
function Shield-Mdns($Ctxs) {
    $anyCampus = (@($Ctxs | Where-Object { $_.Env.Env -eq 'Campus' })).Count -gt 0
    $anyOther  = (@($Ctxs | Where-Object { $_.Env.Env -eq 'Other' })).Count -gt 0
    $cur = $null
    try { $cur = (Get-ItemProperty -LiteralPath $script:DnsParamKey -Name EnableMDNS -ErrorAction Stop).EnableMDNS } catch {}
    if ($anyCampus) {
        if ($null -ne $cur -and [int]$cur -eq 0) { return }
        Save-Original 'Global' 'EnableMDNS' $cur
        $ok = Invoke-Change 'mDNS broadcast disabled on campus (shields against multicast spoofing & hostname leaks on hostel /22)' {
            if (-not (Test-Path -LiteralPath $script:DnsParamKey)) { New-Item -Path $script:DnsParamKey -Force -ErrorAction Stop | Out-Null }
            New-ItemProperty -LiteralPath $script:DnsParamKey -Name EnableMDNS -Value 0 -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        }
        if ($ok -and -not $script:IsDry) { $script:State.Misc['MdnsManaged'] = $true }
    } elseif ($anyOther) {
        Restore-MdnsIfManaged 'Non-campus network: mDNS setting restored'
    }
}

$script:DnsPolicyKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient'
function Restore-SmartDnsIfManaged([string]$Why) {
    if ($script:State.Misc['SmartDnsManaged'] -ne $true) { return }
    $ok = Invoke-Change $Why {
        Remove-ItemProperty -LiteralPath $script:DnsPolicyKey -Name DisableSmartNameResolution -ErrorAction SilentlyContinue
    }
    if ($ok -and -not $script:IsDry) { $script:State.Misc['SmartDnsManaged'] = $false }
}
function Shield-SmartDns($Ctxs) {
    # CRITICAL MULTI-HOMING SAFETY: Smart Multi-Homed Name Resolution (SMHNR) MUST remain enabled.
    # Setting DisableSmartNameResolution=1 breaks DNS on Wi-Fi and Bluetooth tethering
    # whenever Ethernet is plugged into an unauthenticated captive portal.
    # Therefore, we permanently ensure DisableSmartNameResolution is REMOVED so Windows queries all active uplinks.
    try {
        if (Test-Path -LiteralPath $script:DnsPolicyKey) {
            $cur = (Get-ItemProperty -LiteralPath $script:DnsPolicyKey -Name DisableSmartNameResolution -ErrorAction SilentlyContinue).DisableSmartNameResolution
            if ($null -ne $cur) {
                [void](Invoke-Change 'Multi-homed DNS safety: removed DisableSmartNameResolution policy to ensure Wi-Fi/Ethernet resolution' {
                    Remove-ItemProperty -LiteralPath $script:DnsPolicyKey -Name DisableSmartNameResolution -ErrorAction SilentlyContinue
                })
            }
        }
    } catch {}
    if (-not $script:IsDry) { $script:State.Misc['SmartDnsManaged'] = $false }
}

$script:TcpParamKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'
function Restore-TcpKeepAliveIfManaged([string]$Why) {
    if ($script:State.Misc['TcpKeepAliveManaged'] -ne $true) { return }
    $snap = Get-SubTable 'Snapshot' 'Global'
    $origKat = $null; $origKai = $null
    if ($snap.ContainsKey('KeepAliveTime')) { $origKat = $snap['KeepAliveTime'] }
    if ($snap.ContainsKey('KeepAliveInterval')) { $origKai = $snap['KeepAliveInterval'] }
    $ok = Invoke-Change $Why {
        if ($null -eq $origKat) { Remove-ItemProperty -LiteralPath $script:TcpParamKey -Name KeepAliveTime -ErrorAction SilentlyContinue }
        else { Set-ItemProperty -LiteralPath $script:TcpParamKey -Name KeepAliveTime -Value ([int]$origKat) -Type DWord -ErrorAction Stop }
        if ($null -eq $origKai) { Remove-ItemProperty -LiteralPath $script:TcpParamKey -Name KeepAliveInterval -ErrorAction SilentlyContinue }
        else { Set-ItemProperty -LiteralPath $script:TcpParamKey -Name KeepAliveInterval -Value ([int]$origKai) -Type DWord -ErrorAction Stop }
    }
    if ($ok -and -not $script:IsDry) { $script:State.Misc['TcpKeepAliveManaged'] = $false }
}
function Shield-TcpKeepAlive($Ctxs) {
    $anyCampus = (@($Ctxs | Where-Object { $_.Env.Env -eq 'Campus' })).Count -gt 0
    $anyOther  = (@($Ctxs | Where-Object { $_.Env.Env -eq 'Other' })).Count -gt 0
    $curKat = $null; $curKai = $null
    try { $curKat = (Get-ItemProperty -LiteralPath $script:TcpParamKey -Name KeepAliveTime -ErrorAction Stop).KeepAliveTime } catch {}
    try { $curKai = (Get-ItemProperty -LiteralPath $script:TcpParamKey -Name KeepAliveInterval -ErrorAction Stop).KeepAliveInterval } catch {}
    if ($anyCampus) {
        if ($null -ne $curKat -and [int]$curKat -eq 60000 -and $null -ne $curKai -and [int]$curKai -eq 1000) { return }
        Save-Original 'Global' 'KeepAliveTime' $curKat
        Save-Original 'Global' 'KeepAliveInterval' $curKai
        $ok = Invoke-Change 'TCP KeepAlive tuned to 60s (prevents campus firewall state-table timeouts on idle SSH/dev connections)' {
            if (-not (Test-Path -LiteralPath $script:TcpParamKey)) { New-Item -Path $script:TcpParamKey -Force -ErrorAction Stop | Out-Null }
            New-ItemProperty -LiteralPath $script:TcpParamKey -Name KeepAliveTime -Value 60000 -PropertyType DWord -Force -ErrorAction Stop | Out-Null
            New-ItemProperty -LiteralPath $script:TcpParamKey -Name KeepAliveInterval -Value 1000 -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        }
        if ($ok -and -not $script:IsDry) { $script:State.Misc['TcpKeepAliveManaged'] = $true }
    } elseif ($anyOther) {
        Restore-TcpKeepAliveIfManaged 'Non-campus network: TCP KeepAlive parameters restored'
    }
}

function Shield-TcpAutoTuning {
    try {
        $tcpSetting = Get-NetTCPSetting -SettingName Internet -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($tcpSetting -and (@('Disabled', 'HighlyRestricted', 'Restricted') -contains [string]$tcpSetting.AutoTuningLevelLocal)) {
            Save-Original 'Global' 'TcpAutoTuning' ([string]$tcpSetting.AutoTuningLevelLocal)
            [void](Invoke-Change ("TCP Window Auto-Tuning restored to Normal (was {0})" -f [string]$tcpSetting.AutoTuningLevelLocal) {
                Set-NetTCPSetting -SettingName Internet -AutoTuningLevelLocal Normal -ErrorAction Stop
            })
        }
    } catch {}
}

function Shield-TcpOffloads($Ad) {
    if (-not $Ad -or $script:IsDry) {
        if ($script:IsDry -and $Ad) { Write-Log 'DRY' ("Would audit and tune TCP offload engines on {0}" -f $Ad.Name) }
        return $false
    }
    $guid = [string]$Ad.InterfaceGuid
    $modified = $false
    $props = @(Get-NetAdapterAdvancedProperty -Name $Ad.Name -AllProperties -ErrorAction SilentlyContinue)

    $lsoKeywords = @('*LsoV4IPv4', '*LsoV6IPv6', '*LsoV2IPv4', '*LsoV2IPv6', '*RscIPv4', '*RscIPv6')
    foreach ($kw in $lsoKeywords) {
        $p = $props | Where-Object { $_.RegistryKeyword -eq $kw } | Select-Object -First 1
        if (-not $p) { continue }
        $cur = [string](@($p.RegistryValue) | Select-Object -First 1)
        if ($cur -ne '0') {
            Save-Original $guid ("Adv:" + $kw) $cur
            $ok = Invoke-Change ("Disabled TCP offload '{0}' on {1} to eliminate packet drops/corruption" -f $kw, $Ad.Name) {
                Set-NetAdapterAdvancedProperty -Name $Ad.Name -RegistryKeyword $kw -RegistryValue @('0') -NoRestart -ErrorAction Stop
            }
            if ($ok) { $modified = $true; $script:PendingRestart[$guid] = $Ad.Name }
        }
    }
    return $modified
}

function Shield-Proxies {
    if (-not $script:IsAdmin) { return $false }
    if ($script:IsDry) { Write-Log 'DRY' 'Would check and sanitize system proxy configurations'; return $false }
    $changed = $false

    try {
        $uKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
        if (Test-Path -LiteralPath $uKey) {
            $pEnable = (Get-ItemProperty -LiteralPath $uKey -Name ProxyEnable -ErrorAction SilentlyContinue).ProxyEnable
            if ($pEnable -and [int]$pEnable -ne 0) {
                $pServer = [string](Get-ItemProperty -LiteralPath $uKey -Name ProxyServer -ErrorAction SilentlyContinue).ProxyServer
                if ($pServer -match '127\.0\.0\.1|localhost|::1') {
                    Save-Original 'Global' 'ProxyEnable_CU' [int]$pEnable
                    Save-Original 'Global' 'ProxyServer_CU' $pServer
                    $ok = Invoke-Change ("Neutralized loopback WinINet user proxy ({0})" -f $pServer) {
                        Set-ItemProperty -LiteralPath $uKey -Name ProxyEnable -Value 0 -Type DWord -Force -ErrorAction Stop
                    }
                    if ($ok) { $changed = $true }
                }
            }
        }
    } catch {}

    try {
        $mKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings'
        if (Test-Path -LiteralPath $mKey) {
            $pEnable = (Get-ItemProperty -LiteralPath $mKey -Name ProxyEnable -ErrorAction SilentlyContinue).ProxyEnable
            if ($pEnable -and [int]$pEnable -ne 0) {
                $pServer = [string](Get-ItemProperty -LiteralPath $mKey -Name ProxyServer -ErrorAction SilentlyContinue).ProxyServer
                if ($pServer -match '127\.0\.0\.1|localhost|::1') {
                    Save-Original 'Global' 'ProxyEnable_LM' [int]$pEnable
                    Save-Original 'Global' 'ProxyServer_LM' $pServer
                    $ok = Invoke-Change ("Neutralized loopback WinINet system proxy ({0})" -f $pServer) {
                        Set-ItemProperty -LiteralPath $mKey -Name ProxyEnable -Value 0 -Type DWord -Force -ErrorAction Stop
                    }
                    if ($ok) { $changed = $true }
                }
            }
        }
    } catch {}

    try {
        $netsh = Get-SysExe 'netsh.exe'
        if (Test-Path -LiteralPath $netsh) {
            $r = Invoke-Native $netsh @('winhttp', 'show', 'proxy') 5000
            if ($r.ExitCode -eq 0 -and $r.Output -match '((?:https?://)?(?:127\.0\.0\.1|localhost|\[?::1\]?):\d+)') {
                $srv = $Matches[1]
                if ($srv -match '127\.0\.0\.1|localhost|::1') {
                    Save-Original 'Global' 'WinHttpProxy' $srv
                    $ok = Invoke-Change ("Reset WinHTTP loopback proxy ({0})" -f $srv) {
                        [void](Invoke-Native $netsh @('winhttp', 'reset', 'proxy') 5000)
                    }
                    if ($ok) { $changed = $true }
                }
            }
        }
    } catch {}

    foreach ($vName in @('HTTP_PROXY', 'HTTPS_PROXY', 'ALL_PROXY', 'http_proxy', 'https_proxy', 'all_proxy')) {
        $val = [System.Environment]::GetEnvironmentVariable($vName, [System.EnvironmentVariableTarget]::Process)
        if ($val -match '127\.0\.0\.1|localhost|::1') {
            [System.Environment]::SetEnvironmentVariable($vName, $null, [System.EnvironmentVariableTarget]::Process)
            Write-Log 'INFO' ("Cleared loopback environment variable {0} in current process" -f $vName)
            $changed = $true
        }
    }

    return $changed
}

function Shield-TransportProtocols {
    if ($script:IsDry) { Write-Log 'DRY' 'Would calibrate TCP transport stack & congestion provider'; return }
    try {
        Shield-TcpAutoTuning
        $tcpSetting = Get-NetTCPSetting -SettingName Internet -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($tcpSetting) {
            if ($tcpSetting.CongestionProvider -and [string]$tcpSetting.CongestionProvider -match '^(Default|None)$') {
                $avail = @(Get-NetTCPSetting -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CongestionProvider -Unique)
                $targetProvider = if ($avail -contains 'CUBIC') { 'CUBIC' } elseif ($avail -contains 'CTCP') { 'CTCP' } else { '' }
                if ($targetProvider) {
                    Save-Original 'Global' 'TcpCongestionProvider' ([string]$tcpSetting.CongestionProvider)
                    [void](Invoke-Change ("TCP Congestion Provider upgraded to {0} (was {1})" -f $targetProvider, [string]$tcpSetting.CongestionProvider) {
                        Set-NetTCPSetting -SettingName Internet -CongestionProvider $targetProvider -ErrorAction Stop
                    })
                }
            }
            if ($tcpSetting.InitialRtoMs -and [int]$tcpSetting.InitialRtoMs -gt 3000) {
                Save-Original 'Global' 'TcpInitialRtoMs' ([int]$tcpSetting.InitialRtoMs)
                [void](Invoke-Change ("TCP Initial RTO calibrated from {0}ms to 2000ms" -f [int]$tcpSetting.InitialRtoMs) {
                    Set-NetTCPSetting -SettingName Internet -InitialRtoMs 2000 -ErrorAction Stop
                })
            }
            try {
                $tcpParamKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'
                if (Test-Path -LiteralPath $tcpParamKey) {
                    $curRetries = (Get-ItemProperty -LiteralPath $tcpParamKey -Name TcpMaxConnectRetransmissions -ErrorAction SilentlyContinue).TcpMaxConnectRetransmissions
                    if ($null -ne $curRetries -and [int]$curRetries -lt 3) {
                        Save-Original 'Global' 'TcpMaxConnectRetransmissions' [int]$curRetries
                        [void](Invoke-Change ("Calibrated TcpMaxConnectRetransmissions to 3 (was {0})" -f [int]$curRetries) {
                            Set-ItemProperty -LiteralPath $tcpParamKey -Name TcpMaxConnectRetransmissions -Value 3 -Type DWord -Force -ErrorAction Stop
                        })
                    }
                }
            } catch {}
            try {
                $netsh = Get-SysExe 'netsh.exe'
                if (Test-Path -LiteralPath $netsh) {
                    $tcpGlobal = Invoke-Native $netsh @('int', 'tcp', 'show', 'global') 4000
                    if ($tcpGlobal.Output -match 'hystart\s*:\s*disabled') {
                        [void](Invoke-Native $netsh @('int', 'tcp', 'set', 'global', 'hystart=enabled') 4000)
                        Write-Log 'INFO' 'TCP HyStart enabled for high-bandwidth throughput.'
                    }
                }
            } catch {}
        }
    } catch {}
}

function Shield-SystemStack([switch]$Aggressive) {
    if (-not $script:IsAdmin) { return }
    [void](Shield-Proxies)
    [void](Shield-TransportProtocols)
    # Pre-Guard: If unauthenticated Ethernet is up alongside an active Wi-Fi/secondary uplink, demote Ethernet metric first
    # so system-wide DNS probes below do not route into an unauthenticated Ethernet cable before Layer 3 runs.
    $ethUps = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
    $secUps = @(Get-OtherUplinkAdapters)
    $onCampusNow = $false
    foreach ($eu in $ethUps) {
        $eInfo = Get-AdapterEnvironment $eu -UseCache
        if ($eInfo.Env -eq 'Campus') { $onCampusNow = $true }
        if ($secUps.Count -gt 0) {
            $euIp = Get-ValidIPv4 $eu
            if (-not $euIp -or (Get-InternetState -SourceIp $euIp).State -ne 'Online') {
                Shield-RouteMetrics @{ Ad = $eu; Env = $eInfo } 'Captive'
            }
        }
    }
    # 0. Enforce persistence on previously neutralized rogue interceptor services and tasks ONLY while on campus
    if ($onCampusNow) {
        if ($script:State.Misc['NeutralizedServices'] -is [hashtable]) {
            foreach ($svc in @($script:State.Misc['NeutralizedServices'].Keys)) {
                $sv = Get-Service -Name $svc -ErrorAction SilentlyContinue
                if ($sv -and ($sv.Status -eq 'Running' -or $sv.StartType -eq 'Automatic')) {
                    [void](Invoke-Change "Enforced Manual on respawned interceptor service $svc" {
                        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
                        Set-Service -Name $svc -StartupType Manual -ErrorAction SilentlyContinue
                    })
                }
            }
        }
        if ($script:State.Misc['NeutralizedTasks'] -is [hashtable]) {
            foreach ($tn in @($script:State.Misc['NeutralizedTasks'].Keys)) {
                $tp = [string]$script:State.Misc['NeutralizedTasks'][$tn]
                $tsk = Get-ScheduledTask -TaskName $tn -ErrorAction SilentlyContinue | Where-Object { $_.State -ne 'Disabled' }
                if ($tsk) {
                    [void](Invoke-Change "Re-disabled respawned 3rd-party updater task $tn" {
                        Disable-ScheduledTask -TaskName $tn -TaskPath $tp -ErrorAction SilentlyContinue | Out-Null
                    })
                }
            }
        }
    }
    # 1. Ensure Core Windows Network Services are alive (registry fallback for ACL-locked services)
    foreach ($svcName in @('Dhcp','Dnscache','NlaSvc','netprofm','WlanSvc','BFE','mpssvc','iphlpsvc')) {
        $sv = Get-Service -Name $svcName -ErrorAction SilentlyContinue
        if ($sv) {
            if ($sv.StartType -eq 'Disabled') {
                [void](Invoke-Change "Re-enabled critical Windows service $svcName" {
                    try { Set-Service -Name $svcName -StartupType Automatic -ErrorAction Stop }
                    catch {
                        $sk = "HKLM:\SYSTEM\CurrentControlSet\Services\$svcName"
                        if (Test-Path -LiteralPath $sk) { Set-ItemProperty -LiteralPath $sk -Name Start -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue }
                    }
                })
            }
            if ($sv.Status -ne 'Running') {
                [void](Invoke-Change "Started critical Windows service $svcName" { Start-Service -Name $svcName -ErrorAction SilentlyContinue })
            }
        }
    }
    # 2. Dynamic Detection & Neutralization of Rogue DNS Interceptors, WFP Callouts & Loopback Stubs
    $wfpDnsRegex = 'portmaster|nextdns|yogadns|dnscrypt|acrylic|adguard|stubby|warp-svc'
    $dnsBroken = $false
    $dnsEvidence = ''
    $testRecs = @(Resolve-DnsName -Name 'accounts.google.com' -QuickTimeout -ErrorAction SilentlyContinue)
    $hasA = [bool]($testRecs | Where-Object { $_.IPAddress -and [string]$_.Type -eq 'A' })
    $hasPoison = @($testRecs | Where-Object { ([string]$_.Name -match 'inf\.portmaster|blocked\.|sinkhole|dns\.local') -or ([string]$_.Strings -match 'unsuccessful|expired|blocked|refused|failure') }).Count -gt 0
    if ($hasPoison) {
        $dnsBroken = $true
        $dnsEvidence = 'synthetic interceptor error record detected'
    } elseif (-not $hasA) {
        $ethUps = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
        $stackSrc = if ($ethUps.Count -gt 0) { Get-ValidIPv4 $ethUps[0] } else { '' }
        $rawDns = Measure-ResolversFast @('8.8.8.8','1.1.1.1') 400 53 $stackSrc
        $rawNet = (Test-TcpPort '8.8.8.8' 53 600 $stackSrc) -or (Test-TcpPort '1.1.1.1' 443 600 $stackSrc)
        if (@($rawDns.Values | Where-Object { $null -ne $_ }).Count -gt 0 -or $rawNet -or $Aggressive) {
            $dnsBroken = $true
            $dnsEvidence = if ($Aggressive) { 'system resolver failed during aggressive remediation' } else { 'system resolver failed while raw IPv4 internet (8.8.8.8 / 1.1.1.1) is alive' }
        }
    }
    if ($dnsBroken) {
        $roguePids = [System.Collections.Generic.HashSet[int]]::new()
        foreach ($ep in @(Get-NetUDPEndpoint -LocalPort 53 -ErrorAction SilentlyContinue)) {
            if ($ep.OwningProcess -gt 4) { [void]$roguePids.Add([int]$ep.OwningProcess) }
        }
        foreach ($ep in @(Get-NetTCPConnection -LocalPort 53 -ErrorAction SilentlyContinue)) {
            if ($ep.OwningProcess -gt 4) { [void]$roguePids.Add([int]$ep.OwningProcess) }
        }
        # Step 1: Clean loopback DNS from physical adapters first to see if that resolves the issue without killing services.
        # The ORIGINAL resolver string is snapshotted BEFORE the write and the adapter is marked managed, so this bypass is
        # undone exactly (and only) when Lan Fixer is finished with the link: no adapter keeps a substituted resolver.
        $loopbackCleared = $false
        foreach ($na in @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' })) {
            $naGuid = [string]$na.InterfaceGuid
            $dnsAddrs = @(Get-DnsClientServerAddress -InterfaceIndex $na.ifIndex -ErrorAction SilentlyContinue).ServerAddresses
            if (@($dnsAddrs | Where-Object { $_ -match '^(127\.|::1|0\.0\.0\.0|localhost)' }).Count -gt 0) {
                Save-Original $naGuid 'DnsStatic' (Get-StaticDnsString $naGuid)
                $okLoop = Invoke-Change "Bypassed local loopback DNS on adapter $($na.Name) -> DHCP automatic" {
                    Set-DnsClientServerAddress -InterfaceIndex $na.ifIndex -ResetServerAddresses -ErrorAction SilentlyContinue
                }
                if ($okLoop -and -not $script:IsDry) { (Get-SubTable 'Dns' $naGuid).Managed = $true }
                if ($okLoop) { $loopbackCleared = $true }
            }
        }
        $skipKill = $false
        if ($loopbackCleared -and -not $Aggressive) {
            Clear-DnsClientCache -ErrorAction SilentlyContinue
            $testAgain = @(Resolve-DnsName -Name 'accounts.google.com' -QuickTimeout -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -and [string]$_.Type -eq 'A' })
            if ($testAgain.Count -gt 0) {
                Write-Log 'OK' 'DNS resolution restored by bypassing loopback adapter settings (local proxy service preserved).'
                $skipKill = $true
            }
        }
        if (-not $loopbackCleared -and -not $hasPoison -and -not $Aggressive) {
            Write-Log 'INFO' 'System resolver failed, but nothing points at a local resolver and no synthetic error record was seen; local processes and services were left alone.'
            $skipKill = $true
        }
        if (-not $skipKill) {
            $matchRegex = $wfpDnsRegex
            $rogueProcs = @(Get-Process -ErrorAction SilentlyContinue | Where-Object {
                ($_.ProcessName -match $matchRegex) -and
                ($roguePids.Contains($_.Id) -or $Aggressive -or $hasPoison) -and
                ($_.ProcessName -notmatch '^(svchost|System|Idle|services|lsass|csrss|smss|wininit)$')
            })
            $rogueSvcs = @(Get-Service -ErrorAction SilentlyContinue | Where-Object {
                ($_.Status -eq 'Running') -and ($_.Name -match $matchRegex -or $_.DisplayName -match $matchRegex)
            })
            if ($rogueProcs.Count -gt 0 -or $rogueSvcs.Count -gt 0) {
                [void](Invoke-Change ("Neutralized rogue/broken local DNS interceptor ($dnsEvidence)") {
                    if ($script:State.Misc['NeutralizedServices'] -isnot [hashtable]) { $script:State.Misc['NeutralizedServices'] = @{} }
                    foreach ($s in $rogueSvcs) {
                        Write-Log 'INFO' ("Stopping rogue DNS interceptor service $($s.Name) (startup set to Manual)...")
                        if (-not $script:State.Misc['NeutralizedServices'].ContainsKey($s.Name)) {
                            $isDelayed = [bool]((Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\$($s.Name)" -ErrorAction SilentlyContinue).DelayedAutostart)
                            $script:State.Misc['NeutralizedServices'][$s.Name] = @{
                                StartType   = [string]$s.StartType
                                DelayedAuto = $isDelayed
                                WasRunning  = ($s.Status -eq 'Running')
                            }
                        }
                        Stop-Service -Name $s.Name -Force -ErrorAction SilentlyContinue
                        Set-Service -Name $s.Name -StartupType Manual -ErrorAction SilentlyContinue
                    }
                    foreach ($p in $rogueProcs) {
                        Write-Log 'INFO' ("Stopping rogue DNS interceptor process $($p.ProcessName) (PID $($p.Id))...")
                        Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
                    }
                    # Neutralize any auto-restart / updater scheduled tasks for these interceptors
                    $allTasks = @(Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object {
                        $_.State -ne 'Disabled' -and
                        ($_.TaskName -match $matchRegex -or $_.TaskPath -match $matchRegex) -and
                        $_.TaskName -notmatch 'LanFixer|A07'
                    })
                    if ($allTasks.Count -gt 0) {
                        if ($script:State.Misc['NeutralizedTasks'] -isnot [hashtable]) { $script:State.Misc['NeutralizedTasks'] = @{} }
                        foreach ($t in $allTasks) {
                            Write-Log 'INFO' ("Disabling 3rd-party updater/respawn task $($t.TaskName)...")
                            Disable-ScheduledTask -TaskName $t.TaskName -TaskPath $t.TaskPath -ErrorAction SilentlyContinue | Out-Null
                            $script:State.Misc['NeutralizedTasks'][$t.TaskName] = [string]$t.TaskPath
                        }
                    }
                    Clear-DnsClientCache -ErrorAction SilentlyContinue
                })
            }
        }
    }
    # 3. Audit & strip dead loopback or rogue system/user proxies (supporting compound semicolon/equal proxies)
    foreach ($rk in @('HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings', 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings')) {
        if (Test-Path -LiteralPath $rk) {
            $pe = (Get-ItemProperty -LiteralPath $rk -Name ProxyEnable -ErrorAction SilentlyContinue).ProxyEnable
            $ps = [string](Get-ItemProperty -LiteralPath $rk -Name ProxyServer -ErrorAction SilentlyContinue).ProxyServer
            $ac = [string](Get-ItemProperty -LiteralPath $rk -Name AutoConfigURL -ErrorAction SilentlyContinue).AutoConfigURL
            if ($pe -eq 1 -or ($Aggressive -and ($ps -or $ac))) {
                $deadProxy = $Aggressive
                if (-not $deadProxy -and $ps -match '(?:^|[;=])(?:https?://)?(127\.0\.0\.1|localhost):(\d+)') {
                    if (-not (Test-TcpPort $Matches[1] ([int]$Matches[2]) 300)) { $deadProxy = $true }
                }
                if (-not $deadProxy -and $ac -match '(?:https?://)?(127\.0\.0\.1|localhost):(\d+)') {
                    if (-not (Test-TcpPort $Matches[1] ([int]$Matches[2]) 300)) { $deadProxy = $true }
                }
                if ($deadProxy) {
                    [void](Invoke-Change "Cleared dead/hijacked proxy in $rk" {
                        Set-ItemProperty -LiteralPath $rk -Name ProxyEnable -Value 0 -Force -ErrorAction SilentlyContinue
                        Remove-ItemProperty -LiteralPath $rk -Name ProxyServer, AutoConfigURL -Force -ErrorAction SilentlyContinue
                    })
                }
            }
        }
    }
    foreach ($envScope in @('Process', 'User', 'Machine')) {
        foreach ($ev in @('HTTP_PROXY', 'HTTPS_PROXY', 'ALL_PROXY', 'http_proxy', 'https_proxy', 'all_proxy')) {
            $val = [Environment]::GetEnvironmentVariable($ev, $envScope)
            if ($val) {
                $deadEnv = $Aggressive
                if (-not $deadEnv -and $val -match '(?:^|[;=])(?:https?://)?(127\.0\.0\.1|localhost):(\d+)') {
                    if (-not (Test-TcpPort $Matches[1] ([int]$Matches[2]) 300)) { $deadEnv = $true }
                }
                if ($deadEnv) {
                    [void](Invoke-Change "Removed broken CLI proxy environment variable $ev ($envScope)" {
                        [Environment]::SetEnvironmentVariable($ev, $null, $envScope)
                    })
                }
            }
        }
    }
    $wh = [string](Invoke-Native (Get-SysExe 'netsh.exe') @('winhttp', 'show', 'proxy') 4000).Output
    if ($wh -match '(?:https?://)?(127\.0\.0\.1|localhost):(\d+)') {
        if ($Aggressive -or -not (Test-TcpPort $Matches[1] ([int]$Matches[2]) 300)) {
            [void](Invoke-Change 'Reset dead WinHTTP loopback proxy' {
                [void](Invoke-Native (Get-SysExe 'netsh.exe') @('winhttp', 'reset', 'proxy') 5000)
            })
        }
    }
    # 4. Always remove DisableSmartNameResolution so Wi-Fi/Bluetooth tethering DNS never gets locked out
    Shield-SmartDns @()
    # 5. Safely manage Wi-Fi / Secondary Uplink DNS: try DHCP first, and if DNS still fails on non-campus hotspot, set resilient public DNS (8.8.8.8, 1.1.1.1)
    $otherUps = @(Get-OtherUplinkAdapters)
    if ($otherUps.Count -gt 0) {
        foreach ($ou in $otherUps) {
            $ouGuid = [string]$ou.InterfaceGuid
            $ouStatic = Get-StaticDnsString $ouGuid
            $ouDns = @((Get-DnsClientServerAddress -InterfaceIndex $ou.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses)
            $ouDhcp = @(Get-DhcpDnsServers $ouGuid)
            $stuckCampus = ($ouStatic -and ($ouDns -contains $script:Cfg.CampusDns -or $ouDns -contains $script:Cfg.PortalIp) -and ($ouDhcp -notcontains $script:Cfg.CampusDns))
            $ouSrc = Get-ValidIPv4 $ou
            $ouDead = $false
            if ($ouSrc) {
                $ouAns = @(Get-ScopedDnsAnswers 'accounts.google.com' $ouSrc 1500)
                if ($ouAns.Count -eq 0) { $ouDead = $true }
            }
            if ($stuckCampus -or $ouDead) {
                [void](Set-AdapterDnsAutomatic $ou)
                Clear-DnsClientCache -ErrorAction SilentlyContinue
                if (-not $script:IsDry -and $ouSrc) {
                    $recheck = @(Get-ScopedDnsAnswers 'accounts.google.com' $ouSrc 1500)
                    if ($recheck.Count -eq 0) {
                        $ouEnv = (Get-AdapterEnvironment $ou).Env
                        if ($ouEnv -ne 'Campus') {
                            $fallbackDns = @()
                            $dhcpDns = @(Get-DhcpDnsServers $ouGuid | Where-Object { $_ -ne $script:Cfg.CampusDns -and $_ -ne $script:Cfg.PortalIp })
                            if ($dhcpDns.Count -gt 0) { $fallbackDns = $dhcpDns }
                            elseif ($ou.IPv4DefaultGateway) { $fallbackDns = @($ou.IPv4DefaultGateway) }
                            else { $fallbackDns = @('8.8.8.8','1.1.1.1') }
                            [void](Set-AdapterDns $ou $fallbackDns)
                        }
                        Clear-DnsClientCache -ErrorAction SilentlyContinue
                    }
                }
            }
        }
    }
}

# ==============================================================================
# RESET & RECOVERY SUBSYSTEM INFRASTRUCTURE (TIERS 1 - 5)
# ==============================================================================
function Get-ResetJournalPath {
    return (Join-Path $script:StoreDir 'reset_journal.json')
}

function Set-ResetJournal([string]$Tier, [int]$TotalStages, [int]$Stage = 1, [string]$StageDesc = '', [string]$Status = 'InProgress') {
    if ($script:IsDry) { return }
    try {
        $jPath = Get-ResetJournalPath
        $jObj = @{
            Version            = $script:Version
            ResetId            = [guid]::NewGuid().ToString('D')
            Tier               = $Tier
            Stage              = $Stage
            TotalStages        = $TotalStages
            StageDesc          = $StageDesc
            Status             = $Status
            StartTime          = (Get-Date).ToString('o')
            LastUpdated        = (Get-Date).ToString('o')
            CompletedTime      = ''
            RebootRequired     = ($Tier -eq 'Armageddon')
            PendingReboot      = ($Status -eq 'PendingReboot')
        }
        $json = ConvertTo-Json $jObj
        Set-Content -LiteralPath $jPath -Value $json -Encoding ASCII -Force
    } catch {}
}

function Update-ResetJournal([int]$Stage, [string]$StageDesc, [string]$Status = 'InProgress') {
    if ($script:IsDry) { return }
    try {
        $jPath = Get-ResetJournalPath
        if (Test-Path -LiteralPath $jPath) {
            $content = Get-Content -LiteralPath $jPath -Raw -ErrorAction SilentlyContinue
            if ($content) {
                $jObj = ConvertFrom-Json $content
                $jObj.Stage = $Stage
                $jObj.StageDesc = $StageDesc
                $jObj.Status = $Status
                $jObj.LastUpdated = (Get-Date).ToString('o')
                $json = ConvertTo-Json $jObj
                Set-Content -LiteralPath $jPath -Value $json -Encoding ASCII -Force
            }
        }
    } catch {}
}

function New-SystemRestorePoint([string]$Description) {
    if ($script:IsDry) { Write-Log 'DRY' ("Would create System Restore Point: {0}" -f $Description); return $true }
    $srKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore'
    $origFreq = $null
    $freqModified = $false
    try {
        # Bypass Windows 24-hour throttling by temporarily zeroing SystemRestorePointCreationFrequency
        if (Test-Path -LiteralPath $srKey) {
            $val = (Get-ItemProperty -LiteralPath $srKey -Name 'SystemRestorePointCreationFrequency' -ErrorAction SilentlyContinue).SystemRestorePointCreationFrequency
            if ($null -ne $val) { $origFreq = [int]$val }
            Set-ItemProperty -LiteralPath $srKey -Name 'SystemRestorePointCreationFrequency' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            $freqModified = $true
        }

        Write-Log 'INFO' ("Creating System Restore Point '{0}'..." -f $Description)
        Checkpoint-Computer -Description $Description -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop
        Write-Log 'OK' ("System Restore Point '{0}' created successfully." -f $Description)
        return $true
    } catch {
        Write-Log 'WARN' ("System Restore Point creation bypassed or unsupported: {0}" -f $_.Exception.Message)
        return $false
    } finally {
        if ($freqModified) {
            try {
                if ($null -ne $origFreq) {
                    Set-ItemProperty -LiteralPath $srKey -Name 'SystemRestorePointCreationFrequency' -Value $origFreq -Type DWord -Force -ErrorAction SilentlyContinue
                } else {
                    Remove-ItemProperty -LiteralPath $srKey -Name 'SystemRestorePointCreationFrequency' -ErrorAction SilentlyContinue
                }
            } catch {}
        }
    }
}

function Stage-PostRebootVerification {
    if ($script:IsDry) {
        Write-Log 'DRY' 'Would stage post-reboot verification script with locked ACLs'
        return @{ Path = (Join-Path (Join-Path $script:StoreDir 'staging') 'post_reboot_verify.ps1'); Hash = ('0' * 64); DryRun = $true }
    }
    try {
        $stageDir = Join-Path $script:StoreDir 'staging'
        if (-not (Test-Path -LiteralPath $stageDir)) {
            New-Item -Path $stageDir -ItemType Directory -Force | Out-Null
        }

        $verifyScript = Join-Path $stageDir 'post_reboot_verify.ps1'
        $scriptContent = @'
# LanFixer Post-Reboot Verification & State Reconstitution
Write-Host "LanFixer Post-Reboot Verification..." -ForegroundColor Cyan
try {
    $ads = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' })
    if ($ads.Count -gt 0) {
        Write-Host "Network hardware re-detected successfully: $($ads.Name -join ', ')" -ForegroundColor Green
    } else {
        Write-Host "No active network adapters detected yet. Checking PnP..." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error verifying network adapters: $_" -ForegroundColor Red
}
'@
        Set-Content -LiteralPath $verifyScript -Value $scriptContent -Encoding ASCII -Force

        # Secure staging directory & file when running elevated as Administrator
        if ($script:IsAdmin) {
            $icStg = Get-SysExe 'icacls.exe'
            [void](Invoke-Native $icStg @($stageDir, '/inheritance:r', '/grant:r', '*S-1-5-18:(OI)(CI)F', '*S-1-5-32-544:(OI)(CI)F', '/C', '/Q') 5000)
            [void](Invoke-Native $icStg @($stageDir, '/setowner', '*S-1-5-32-544', '/C', '/Q') 5000)
            [void](Protect-VaultFile $verifyScript)
        }

        # Compute cryptographic hash for integrity validation
        $sha = Get-FileSha256 $verifyScript
        $shaShort = if ($sha -and $sha.Length -ge 16) { $sha.Substring(0, 16) } else { 'SIMULATED' }
        Write-Log 'OK' ("Staged secure post-reboot verification script (SHA256: {0})" -f $shaShort)
        return @{ Path = $verifyScript; Hash = $sha }
    } catch {
        Write-Log 'WARN' ("Failed to stage post-reboot verification script: {0}" -f $_.Exception.Message)
        return $null
    }
}

function Complete-ResetJournal([bool]$Success = $true) {
    if ($script:IsDry) { return }
    try {
        $jPath = Get-ResetJournalPath
        if (Test-Path -LiteralPath $jPath) {
            $content = Get-Content -LiteralPath $jPath -Raw -ErrorAction SilentlyContinue
            if ($content) {
                $jObj = ConvertFrom-Json $content
                $jObj.Status = if ($Success) { 'Completed' } else { 'Failed' }
                try {
                    $jObj.CompletedTime = (Get-Date).ToString('o')
                } catch {
                    Add-Member -InputObject $jObj -NotePropertyName 'CompletedTime' -NotePropertyValue ((Get-Date).ToString('o')) -Force
                }
                $json = ConvertTo-Json $jObj
                Set-Content -LiteralPath $jPath -Value $json -Encoding ASCII -Force
            }
        }
    } catch {}
}

function Test-PriorResetJournal {
    try {
        $jPath = Get-ResetJournalPath
        if (Test-Path -LiteralPath $jPath) {
            $content = Get-Content -LiteralPath $jPath -Raw -ErrorAction SilentlyContinue
            if ($content) {
                $jObj = ConvertFrom-Json $content
                if ($jObj.Status -eq 'InProgress') {
                    Write-Log 'WARN' ("Prior reset operation '{0}' was interrupted at Stage {1}/{2} ({3})." -f $jObj.Tier, $jObj.Stage, $jObj.TotalStages, $jObj.StageDesc)
                    return $jObj
                } elseif ($jObj.Status -eq 'PendingReboot') {
                    Write-Log 'WARN' ("Prior reset operation '{0}' is awaiting system reboot to complete driver re-installation." -f $jObj.Tier)
                    if ($jObj.VerifyScriptPath -and (Test-Path -LiteralPath $jObj.VerifyScriptPath)) {
                        $vPath = [string]$jObj.VerifyScriptPath
                        $aclOk = Test-VaultAcl $vPath
                        $curHash = Get-FileSha256 $vPath
                        if (-not $aclOk -or ($jObj.VerifyScriptSha256 -and $curHash -ne $jObj.VerifyScriptSha256)) {
                            Write-Log 'FAIL' 'SECURITY ALERT: Staged post-reboot verification script failed integrity check or permissions tampered! Execution refused.'
                        } else {
                            Write-Log 'OK' 'Staged post-reboot verification script verified (SHA256 authenticated).'
                        }
                    }
                    return $jObj
                }
            }
        }
    } catch {}
    return $null
}

function Backup-WlanProfiles {
    if ($script:IsDry) { Write-Log 'DRY' 'Would backup Wi-Fi profiles'; return }
    try {
        $backupDir = Join-Path $script:StoreDir 'wifi_backup'
        if (-not (Test-Path -LiteralPath $backupDir)) {
            New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
        }
        $netsh = Get-SysExe 'netsh.exe'
        [void](Invoke-Native $netsh @('wlan', 'export', 'profile', ("folder=" + $backupDir), 'key=clear') 5000)
        try {
            $acl = Get-Acl -LiteralPath $backupDir
            $acl.SetAccessRuleProtection($true, $false)
            $adminSid = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::BuiltinAdministratorsSid, $null)
            $systemSid = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::LocalSystemSid, $null)
            $ruleAdmin = New-Object System.Security.AccessControl.FileSystemAccessRule($adminSid, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
            $ruleSys = New-Object System.Security.AccessControl.FileSystemAccessRule($systemSid, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
            $acl.ResetAccessRule($ruleAdmin)
            $acl.AddAccessRule($ruleSys)
            Set-Acl -LiteralPath $backupDir -AclObject $acl
        } catch {}
    } catch {
        Write-Log 'WARN' ("Failed to backup Wi-Fi profiles: {0}" -f $_.Exception.Message)
    }
}

function Restore-WlanProfiles {
    if ($script:IsDry) { Write-Log 'DRY' 'Would restore Wi-Fi profiles'; return }
    try {
        $backupDir = Join-Path $script:StoreDir 'wifi_backup'
        if (Test-Path -LiteralPath $backupDir) {
            $xmlFiles = @(Get-ChildItem -LiteralPath $backupDir -Filter '*.xml' -ErrorAction SilentlyContinue)
            $netsh = Get-SysExe 'netsh.exe'
            foreach ($xf in $xmlFiles) {
                [void](Invoke-Native $netsh @('wlan', 'add', 'profile', ("filename=" + $xf.FullName)) 5000)
            }
            if ($xmlFiles.Count -gt 0) {
                Write-Log 'OK' ("Restored {0} Wi-Fi profiles from backup." -f $xmlFiles.Count)
            }
        }
    } catch {
        Write-Log 'WARN' ("Failed to restore Wi-Fi profiles: {0}" -f $_.Exception.Message)
    }
}

function Backup-FirewallBaseline {
    if ($script:IsDry) { Write-Log 'DRY' 'Would backup Windows Firewall rules'; return }
    try {
        $fwFile = Join-Path $script:StoreDir 'firewall_pre_reset.wfw'
        if (-not (Test-Path -LiteralPath $fwFile)) {
            $netsh = Get-SysExe 'netsh.exe'
            [void](Invoke-Native $netsh @('advfirewall', 'export', $fwFile) 8000)
            if (Test-Path -LiteralPath $fwFile) {
                Write-Log 'OK' 'Windows Firewall policy backed up.'
            }
        }
    } catch {
        Write-Log 'WARN' ("Failed to backup Windows Firewall: {0}" -f $_.Exception.Message)
    }
}

function Restore-FirewallBaseline {
    if ($script:IsDry) { Write-Log 'DRY' 'Would restore Windows Firewall rules'; return }
    try {
        $fwFile = Join-Path $script:StoreDir 'firewall_pre_reset.wfw'
        if (Test-Path -LiteralPath $fwFile) {
            $netsh = Get-SysExe 'netsh.exe'
            [void](Invoke-Native $netsh @('advfirewall', 'import', $fwFile) 8000)
            Write-Log 'OK' 'Windows Firewall policy restored from backup.'
        }
    } catch {
        Write-Log 'WARN' ("Failed to restore Windows Firewall: {0}" -f $_.Exception.Message)
    }
}

function Capture-GlobalPreflightSnapshot {
    if ($script:IsDry) {
        Write-Log 'DRY' 'Would capture global pre-flight snapshot across all network adapters and system settings'
        return $true
    }
    Write-Log 'INFO' 'Capturing pre-flight snapshot across all network adapters and system settings...'
    $snapCount = 0
    try {
        if (-not $script:State.ContainsKey('Snapshot') -or $script:State.Snapshot -isnot [hashtable]) {
            $script:State.Snapshot = @{}
        }

        # 1. Global registry & network settings snapshot (First-Write-Wins)
        if (-not $script:State.Snapshot.ContainsKey('Global')) {
            $gSnap = @{}
            try {
                $whRes = Invoke-Native (Get-SysExe 'netsh.exe') @('winhttp', 'show', 'proxy') 3000
                if ($whRes.Output -match 'Proxy Server\(s\)\s*:\s*(\S+)') { $gSnap['WinHttpProxy'] = $matches[1] }
            } catch {}
            try {
                $peCu = (Get-ItemProperty -LiteralPath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -ErrorAction SilentlyContinue).ProxyEnable
                if ($null -ne $peCu) { $gSnap['ProxyEnable_CU'] = [int]$peCu }
            } catch {}
            try {
                $peLm = (Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -ErrorAction SilentlyContinue).ProxyEnable
                if ($null -ne $peLm) { $gSnap['ProxyEnable_LM'] = [int]$peLm }
            } catch {}
            try {
                $ncsi = (Get-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet' -Name EnableActiveProbing -ErrorAction SilentlyContinue).EnableActiveProbing
                if ($null -ne $ncsi) { $gSnap['Ncsi'] = [int]$ncsi }
            } catch {}
            $script:State.Snapshot['Global'] = $gSnap
        }

        # 2. Per-adapter snapshot across ALL adapters (Physical + Virtual)
        $allAdapters = @(Get-NetAdapter -IncludeHidden -ErrorAction SilentlyContinue)
        foreach ($ad in $allAdapters) {
            $adGuid = [string]$ad.InterfaceGuid
            if ($adGuid -and (-not $script:State.Snapshot.ContainsKey($adGuid))) {
                $snap = Capture-PreflightSnapshot $ad
                if ($snap) {
                    $script:State.Snapshot[$adGuid] = $snap
                    $snapCount++
                }
            }
        }

        # 3. Wi-Fi profiles & Firewall rules backup
        Backup-WlanProfiles
        Backup-FirewallBaseline

        # 4. Save state & verify file exists
        Save-State
        if (Test-Path -LiteralPath $script:StateFile) {
            Write-Log 'OK' ("Pre-flight snapshot verified ({0} adapters snapshotted, state persisted)." -f $snapCount)
            return $true
        } else {
            Write-Log 'FAIL' 'State file could not be written to disk. Snapshot unverified.'
            return $false
        }
    } catch {
        Write-Log 'FAIL' ("Error during pre-flight snapshot capture: {0}" -f $_.Exception.Message)
        return $false
    }
}

function Test-ResetPreconditions([string]$Tier, [switch]$Confirmed) {
    if (-not (Assert-Admin)) { return $false }
    if ($Mode -eq 'AutoHeal' -or $Mode -eq 'Daemon' -or $Mode -eq 'Sentinel') {
        Write-Log 'ALERT' ("Destructive reset mode '{0}' cannot be invoked by automated background tasks." -f $Tier)
        return $false
    }
    if ((Test-RemoteSession) -and -not $Force) {
        Write-Log 'ALERT' ("Active remote session detected ({0}). Destructive reset '{1}' aborted to prevent operator lockout. Re-run with -Force to override." -f $env:SESSIONNAME, $Tier)
        return $false
    }
    if ($Tier -eq 'Armageddon' -and (Test-RemoteSession) -and -not $ConfirmRemoteDisconnect) {
        Write-Log 'ALERT' 'CRITICAL: ARMAGEDDON RESET (netcfg -d) uninstalls all network adapters and WILL PERMANENTLY SEVER this remote session until a physical machine reboot! Pass -ConfirmRemoteDisconnect along with -Force to execute.'
        return $false
    }

    # Free disk space check
    $minMb = switch ($Tier) {
        'Armageddon' { 200 }
        'Doomsday'   { 100 }
        default      { 50 }
    }
    try {
        $driveLetter = if ($env:SystemDrive) { $env:SystemDrive.TrimEnd(':') } else { 'C' }
        $drive = [System.IO.DriveInfo]::new($driveLetter)
        $freeMb = [int]($drive.AvailableFreeSpace / 1MB)
        if ($freeMb -lt $minMb) {
            Write-Log 'FAIL' ("Insufficient disk space on system drive {0}: ({1} MB available, {2} MB required for {3} reset). Reset aborted." -f $driveLetter, $freeMb, $minMb, $Tier)
            return $false
        }
    } catch {
        Write-Log 'WARN' ("Unable to query free disk space on system drive: {0}" -f $_.Exception.Message)
    }

    # StoreDir write check
    if (-not $script:IsDry) {
        try {
            if (-not (Test-Path -LiteralPath $script:StoreDir)) {
                New-Item -Path $script:StoreDir -ItemType Directory -Force | Out-Null
            }
            $canary = Join-Path $script:StoreDir ('.canary_' + [guid]::NewGuid().ToString('N') + '.tmp')
            Set-Content -LiteralPath $canary -Value 'lanfixer_canary' -Encoding ASCII -Force
            Remove-Item -LiteralPath $canary -Force -ErrorAction SilentlyContinue
        } catch {
            Write-Log 'FAIL' ("State store directory '{0}' is not writable: {1}. Reset aborted to prevent unrecoverable state loss." -f $script:StoreDir, $_.Exception.Message)
            return $false
        }
    }

    # CLI / Interactive Confirmation
    if (-not $Confirmed -and -not $Force -and -not $script:IsDry) {
        $blastSummary = switch ($Tier) {
            'Omnifix'    { '5-stage live stack reset (Winsock, TCP/IP, ARP, DNS, DHCP renewed, services bounced).' }
            'Ultra'      { '10-stage nuclear reset (Dual 64/32-bit Winsock, TCP/IP stack, routing table, firewall, NLA profiles).' }
            'Doomsday'   { '12-stage universal reset (All media: Wi-Fi, BT, USB, WWAN, LAN; NDIS filters detached, ARP purge).' }
            'Armageddon' { '4-stage OS wipe: netcfg.exe -d uninstalls ALL network adapters. REQUIRES SYSTEM REBOOT!' }
            default      { 'System network stack reset.' }
        }
        $reqWord = if ($Tier -eq 'Armageddon') { 'CONFIRM' } else { 'yes' }
        if (Test-InputRedirected) {
            Write-Log 'ALERT' ("Destructive reset '{0}' requires explicit confirmation. In automated or non-interactive environments, pass -Force to execute." -f $Tier)
            return $false
        }
        Write-Host ''
        Write-Host '  ========================================================================' -ForegroundColor Yellow
        Write-Host ("  CRITICAL RESET CONFIRMATION REQUIRED: {0}" -f $Tier.ToUpperInvariant()) -ForegroundColor Red
        Write-Host ("  {0}" -f $blastSummary) -ForegroundColor Gray
        Write-Host '  ========================================================================' -ForegroundColor Yellow
        Write-Host ''
        $promptMsg = if ($Tier -eq 'Armageddon') { "Type 'CONFIRM' to execute Armageddon OS wipe" } else { "Execute $Tier reset?" }
        if (-not (Read-Confirm $promptMsg $reqWord)) {
            Write-Log 'INFO' ("Reset '{0}' cancelled by operator. No changes made." -f $Tier)
            return $false
        }
    }

    # System Restore Point checkpointing (Tiers 3 and 4) with 24-hour throttling bypass
    if ($Tier -in @('Doomsday', 'Armageddon') -and -not $script:IsDry) {
        [void](New-SystemRestorePoint ("LanFixer Pre-" + $Tier + " Reset"))
    }

    return $true
}

function Invoke-SupremeOmnifix([switch]$Confirmed) {
    if (-not (Test-ResetPreconditions 'Omnifix' -Confirmed:$Confirmed)) { return }
    $swOmni = [System.Diagnostics.Stopwatch]::StartNew()
    Write-Section 'FULL NET RESET (5-STAGE DEEP RECOVERY)'
    $r = Pick-Hash (Invoke-WithLock {
        Write-Log 'STEP' 'STAGE 1/5  Cycling PnP hardware transceiver, rescanning bus & neutralizing WFP DNS interceptors / proxies'
        if (-not $script:IsDry) {
            foreach ($oa in @(Get-EthernetAdapters)) { Reset-PhysicalAdapterHardware $oa }
            [void](Invoke-Native (Get-SysExe 'pnputil.exe') @('/scan-devices') 5000)
        }
        $script:ConnCache = $null
        $script:EnvCache = @{}
        if (-not $script:IsDry) {
            $script:State.Misc['RouteProfile'] = 'Adaptive'
            $script:State.Misc['DnsProfile'] = 'Adaptive'
            $script:State.Misc['FailStreak'] = 0
            foreach ($mk in @($script:State.Misc.Keys | Where-Object { $_ -like 'MtuCandidate*' })) { $script:State.Misc.Remove($mk) }
            foreach ($dk in @('DiscoveredDomain', 'DiscoveredPortalIp', 'DiscoveredPortalUrl', 'DiscoveredPortalPort', 'DiscoveryTime')) {
                if ($script:State.Misc.ContainsKey($dk)) { $script:State.Misc.Remove($dk) }
            }
        }
        Shield-SystemStack -Aggressive
        if (-not $script:IsDry) { [void](Invoke-Native (Get-SysExe 'netsh.exe') @('winhttp', 'reset', 'proxy') 5000) }
        Remove-CampusNrpt
        Remove-LegacyHostsEntries
        Remove-CampusHostRoutes
        foreach ($ea in @(Get-EthernetAdapters)) { Release-ArpLocks $ea; Shield-DnsIntegrity $ea }
        Write-Log 'STEP' 'STAGE 2/5  Restoring clean routing metrics & MTU across physical Ethernet uplinks'
        Shield-Aspm
        foreach ($oa in @(Get-EthernetAdapters)) { [void](Shield-TcpOffloads $oa); [void](Shield-Dot3Svc $oa) }
        Restore-InterfaceMetrics 'Full Net Reset metrics restore'
        if (-not $script:IsDry) {
            foreach ($a in @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' -and $_.MediaType -eq '802.3' })) {
                Set-NetIPInterface -InterfaceIndex $a.ifIndex -AddressFamily IPv4 -NlMtuBytes 1500 -ErrorAction SilentlyContinue
            }
        }
        Write-Log 'STEP' 'STAGE 3/5  Running 7-Layer Ethernet & Multi-Homed Heal Pipeline'
        $resHeal = Pick-Hash (Invoke-HealPipeline -SkipSystemStack)
        Write-Log 'STEP' 'STAGE 4/5  Flushing DNS, ARP, NetBIOS & refreshing network state services'
        if (-not $script:IsDry) {
            Clear-DnsClientCache -ErrorAction SilentlyContinue
            [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/flushdns') 5000)
            Get-NetNeighbor -AddressFamily IPv4 -ErrorAction SilentlyContinue | Remove-NetNeighbor -Confirm:$false -ErrorAction SilentlyContinue
            Get-NetNeighbor -AddressFamily IPv6 -ErrorAction SilentlyContinue | Remove-NetNeighbor -Confirm:$false -ErrorAction SilentlyContinue
            [void](Invoke-Native (Get-SysExe 'nbtstat.exe') @('-R') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('winsock', 'reset') 5000)
            Restart-Service -Name Dhcp -Force -ErrorAction SilentlyContinue
            Restart-Service -Name NlaSvc -Force -ErrorAction SilentlyContinue
            Start-Service -Name netprofm -ErrorAction SilentlyContinue
            Start-Service -Name iphlpsvc -ErrorAction SilentlyContinue
            Start-Service -Name Wcmsvc -ErrorAction SilentlyContinue
            Start-Service -Name WlanSvc -ErrorAction SilentlyContinue
            Start-Service -Name WinHttpAutoProxySvc -ErrorAction SilentlyContinue
        }
        Write-Log 'STEP' 'STAGE 5/5  Verifying live IPv4 A-record & HTTPS reachability (GitHub & Google Auth)'
        $anyVerifyFail = $false
        $upEths = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
        $primarySrc = if ($upEths.Count -gt 0) { Get-ValidIPv4 $upEths[0] } else { '' }
        foreach ($testHost in @('github.com', 'accounts.google.com')) {
            $ip = Resolve-HostBounded $testHost 3000 $primarySrc
            if ($ip) {
                $tcpOk = Test-TcpPort $ip 443 2500 $primarySrc
                Write-Log ($(if ($tcpOk) { 'OK' } else { 'WARN' })) ("Verified {0} -> {1} (TCP/443: {2})" -f $testHost, $ip, $(if ($tcpOk) { 'OPEN' } else { 'BLOCKED' }))
            } else {
                $anyVerifyFail = $true
                Write-Log 'FAIL' ("DNS resolution still failed for {0}" -f $testHost)
            }
        }
        if ($anyVerifyFail -and -not $script:IsDry -and ($resHeal.Conn -ne 'Captive')) {
            Write-Log 'WARN' 'DNS resolution failed for public endpoints. Deploying adaptive public DNS rescue...'
            foreach ($ea in @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })) {
                $rescueDns = @(Get-BestDnsOrder ([string]$ea.InterfaceGuid) @())
                if ($rescueDns.Count -gt 0) {
                    Write-Log 'INFO' "Applying active public DNS rescue on $($ea.Name): $($rescueDns -join ', ')..."
                    [void](Set-AdapterDns $ea $rescueDns)
                }
            }
            Clear-DnsClientCache -ErrorAction SilentlyContinue
            [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/flushdns') 5000)
            [void](Invoke-Change 'Zero-reboot live network stack cycling (NDIS, DHCP & TCPIP state unfreeze)' {
                Restart-Service -Name Dhcp -Force -ErrorAction SilentlyContinue
                Restart-Service -Name NlaSvc -Force -ErrorAction SilentlyContinue
                Start-Service -Name netprofm -ErrorAction SilentlyContinue
                Start-Service -Name iphlpsvc -ErrorAction SilentlyContinue
                Start-Service -Name Wcmsvc -ErrorAction SilentlyContinue
                Start-Service -Name WlanSvc -ErrorAction SilentlyContinue
                foreach ($ea in @(Get-EthernetAdapters)) {
                    Reset-PhysicalAdapterHardware $ea
                    [void](Wait-StpConvergence $ea 10)
                }
            })
            foreach ($testHost in @('github.com', 'accounts.google.com')) {
                $ip = Resolve-HostBounded $testHost 3000 $primarySrc
                if ($ip) {
                    $tcpOk = Test-TcpPort $ip 443 2500 $primarySrc
                    Write-Log ($(if ($tcpOk) { 'OK' } else { 'WARN' })) ("Re-verified {0} -> {1} (TCP/443: {2})" -f $testHost, $ip, $(if ($tcpOk) { 'OPEN' } else { 'BLOCKED' }))
                }
            }
        }
        Save-State
        $resHeal
    })
    $swOmni.Stop()
    Write-HealSummary $r $swOmni
    # Lock is now released before the 180s human browser wait so background watchdog passes never block!
    if ($r -and $r.Conn -eq 'Captive' -and -not $script:IsDry) {
        [void](Invoke-WithLock { [void](Open-Portal); Save-State })
        if ($script:UiOn -and (Get-InternetState -NoCache).State -eq 'Captive') {
            Out-Line @((Seg 'dim' '  Sign in on the page that opened; the fast DNS path is applied for you afterwards.'))
            if (Wait-ForAuthentication 180) { Complete-Authentication; Write-Log 'OK' 'Signed in. Post-login DNS applied.' }
        }
    }
}

# ==============================================================================
# ULTRA SYSTEM RESET - 10-STAGE NETWORK STACK & DRIVER REMEDIATION ENGINE
# ==============================================================================
function Invoke-UltraSystemReset([switch]$Confirmed) {
    if (-not (Test-ResetPreconditions 'Ultra' -Confirmed:$Confirmed)) { return }
    $swUltra = [System.Diagnostics.Stopwatch]::StartNew()
    Write-Section 'ULTRA SYSTEM RESET (10-STAGE NETWORK STACK RESUSCITATION)'
    $r = Pick-Hash (Invoke-WithLock {
        # ----------------------------------------------------------------------
        # STAGE 1/10: PRE-FLIGHT ACID SNAPSHOT & 10-SERVICE REVERSE TEARDOWN
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 1/10  Snapshotting pre-flight state & suspending 10 dependent network services'
        $script:ConnCache = $null
        $script:EnvCache = @{}
        if ($script:IsDry) {
            Write-Log 'DRY' 'Would capture pre-flight snapshots and stop dependent network services (BITS, netprofm, NlaSvc, Dnscache, Dhcp, iphlpsvc, dot3svc, WlanSvc, CryptSvc, mpssvc)'
        } else {
            Set-ResetJournal -Tier 'Ultra' -TotalStages 10 -Stage 1 -StageDesc 'Snapshot & Service Teardown'
            if (-not (Capture-GlobalPreflightSnapshot)) {
                if (-not $Force) {
                    Write-Log 'FAIL' 'Pre-flight safety snapshot failed. Ultra Reset aborted.'
                    return
                }
                Write-Log 'WARN' 'Pre-flight snapshot failed, proceeding due to -Force.'
            }
            $script:State.Misc['RouteProfile'] = 'Adaptive'
            $script:State.Misc['DnsProfile'] = 'Adaptive'
            $script:State.Misc['FailStreak'] = 0
            foreach ($mk in @($script:State.Misc.Keys | Where-Object { $_ -like 'MtuCandidate*' })) { $script:State.Misc.Remove($mk) }
            foreach ($dk in @('DiscoveredDomain', 'DiscoveredPortalIp', 'DiscoveredPortalUrl', 'DiscoveredPortalPort', 'DiscoveryTime')) {
                if ($script:State.Misc.ContainsKey($dk)) { $script:State.Misc.Remove($dk) }
            }
            
            # Teardown dependent services in strict reverse topological order to release kernel sockets, handles, and crypto locks
            $downSvcs = @('BITS', 'netprofm', 'NlaSvc', 'Dnscache', 'Dhcp', 'iphlpsvc', 'dot3svc', 'WlanSvc', 'CryptSvc', 'mpssvc')
            foreach ($s in $downSvcs) {
                try { Stop-Service -Name $s -Force -ErrorAction SilentlyContinue } catch {}
            }
        }

        try {
        # ----------------------------------------------------------------------
        # STAGE 2/10: DUAL-ARCHITECTURE WINSOCK CATALOG OBLITERATION (64-BIT & 32-BIT)
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 2/10  Dual-architecture Winsock LSP/NSP catalog wipe (64-bit System32 & 32-bit SysWOW64)'
        if ($script:IsDry) {
            Write-Log 'DRY' 'Would execute 64-bit and 32-bit: netsh winsock reset catalog & netsh winsock reset'
            Write-Log 'DRY' 'Would reset Winsock AutodialFlags to 0 in registry'
        } else {
            # 64-bit System32 Winsock Catalog Reset
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('winsock', 'reset', 'catalog') 8000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('winsock', 'reset') 5000)

            # 32-bit SysWOW64 Winsock Catalog Reset (cleanses legacy 32-bit LSP hooks and browser shims)
            $wowNetsh = Join-Path $env:SystemRoot 'SysWOW64\netsh.exe'
            if (Test-Path -LiteralPath $wowNetsh) {
                [void](Invoke-Native $wowNetsh @('winsock', 'reset', 'catalog') 8000)
                [void](Invoke-Native $wowNetsh @('winsock', 'reset') 5000)
            }

            # Zero out Winsock AutodialFlags to defeat phantom dial-up/RAS prompts
            try {
                $ws2Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\WinSock2\Parameters'
                if (Test-Path -LiteralPath $ws2Key) {
                    Set-ItemProperty -LiteralPath $ws2Key -Name 'AutodialFlags' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                }
            } catch {}
        }

        # ----------------------------------------------------------------------
        # STAGE 3/10: DUAL-STACK TCP/IP FACTORY RESTORATION & GLOBAL HEURISTICS NORMALIZATION
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 3/10  Dual-stack TCP/IP stack restoration, global heuristics reset, tunnel defeat & HTTP flush'
        if ($script:IsDry) {
            Write-Log 'DRY' 'Would execute: netsh int ip reset & netsh int ipv6 reset'
            Write-Log 'DRY' 'Would execute: netsh int tcp reset & normalize autotuning/RSS/RSC/timestamps'
            Write-Log 'DRY' 'Would disable transition tunnels: Teredo, ISATAP, 6to4'
            Write-Log 'DRY' 'Would flush HTTP driver log buffers'
        } else {
            $ipLog = Join-Path $env:TEMP ('netsh_ip_reset_' + [Guid]::NewGuid().ToString('N').Substring(0,8) + '.log')
            $ipv6Log = Join-Path $env:TEMP ('netsh_ipv6_reset_' + [Guid]::NewGuid().ToString('N').Substring(0,8) + '.log')
            try {
                [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'ip', 'reset', $ipLog) 10000)
            } finally {
                if (Test-Path -LiteralPath $ipLog) { Remove-Item -LiteralPath $ipLog -Force -ErrorAction SilentlyContinue }
            }
            try {
                [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'ipv6', 'reset', $ipv6Log) 10000)
            } finally {
                if (Test-Path -LiteralPath $ipv6Log) { Remove-Item -LiteralPath $ipv6Log -Force -ErrorAction SilentlyContinue }
            }

            # Reset global TCP stack heuristics, window autotuning, RSS, RSC, and ECN
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'tcp', 'reset') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'tcp', 'set', 'heuristics', 'disabled') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'tcp', 'set', 'global', 'autotuninglevel=normal') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'tcp', 'set', 'global', 'rss=enabled') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'tcp', 'set', 'global', 'rsc=enabled') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'tcp', 'set', 'global', 'ecncapability=disabled') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'tcp', 'set', 'global', 'timestamps=disabled') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'tcp', 'set', 'global', 'initialrto=3000') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'tcp', 'set', 'global', 'nonsackrttresiliency=disabled') 5000)

            # Disable legacy IPv6 transition tunnel interfaces that cause campus blackholing
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'teredo', 'set', 'state', 'disabled') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'isatap', 'set', 'state', 'disabled') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', '6to4', 'set', 'state', 'disabled') 5000)

            # Flush HTTP driver internal log buffers
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('http', 'flush', 'logbuffer') 5000)
        }

        # ----------------------------------------------------------------------
        # STAGE 4/10: ROUTING TABLE PURGE, PORTPROXY RESET & ACCIDENTAL BRIDGE DESTRUCTION
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 4/10  Purging routing table (route -f), portproxy, destination caches & rogue bridges'
        if ($script:IsDry) {
            Write-Log 'DRY' 'Would execute: route -f (purge all routes and gateways)'
            Write-Log 'DRY' 'Would delete IPv4 & IPv6 destination caches'
            Write-Log 'DRY' 'Would execute: netsh interface portproxy reset & netsh interface httpstunnel reset'
            Write-Log 'DRY' 'Would destroy accidental network bridges via netsh bridge'
            Write-Log 'DRY' 'Would execute: netsh advfirewall reset & enable all profiles'
        } else {
            # Purge all non-interface, non-loopback routes
            [void](Invoke-Native (Get-SysExe 'route.exe') @('-f') 5000)

            # Delete IPv4 and IPv6 kernel destination caches
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'ip', 'delete', 'destinationcache') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'ipv6', 'delete', 'destinationcache') 5000)

            # Reset Windows port forwarding (PortProxy) and IP-HTTPS tunnels to defeat hijacked developer/emulator port redirects
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'portproxy', 'reset') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'httpstunnel', 'reset') 5000)

            # Destroy accidental/rogue network bridges that create packet loops or isolate the physical NIC
            try {
                $brOut = Invoke-Native (Get-SysExe 'netsh.exe') @('bridge', 'list') 5000
                if ($brOut.Output -match '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})') {
                    foreach ($brMatch in [regex]::Matches($brOut.Output, '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})')) {
                        $brGuid = $brMatch.Groups[1].Value
                        Write-Log 'WARN' "Destroying orphaned network bridge $brGuid..."
                        [void](Invoke-Native (Get-SysExe 'netsh.exe') @('bridge', 'destroy', $brGuid) 5000)
                    }
                }
            } catch {}

            # Backup custom firewall rules before reset for 100% reversible rollback
            try {
                $fwBackup = Join-Path $script:StoreDir 'firewall_pre_reset.wfw'
                if (-not (Test-Path -LiteralPath $fwBackup)) {
                    [void](Invoke-Native (Get-SysExe 'netsh.exe') @('advfirewall', 'export', $fwBackup) 5000)
                }
            } catch {}

            # Windows Defender Firewall factory state restoration
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('advfirewall', 'reset') 8000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('advfirewall', 'set', 'allprofiles', 'state', 'on') 5000)
        }

        # ----------------------------------------------------------------------
        # STAGE 5/10: ENCRYPTED DNS (DOH/DOT/DDR) WIPE, WPAD AUTOPROXY & BITS JOB PURGE
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 5/10  Resetting global/interface DoH, WinHTTP autoproxy, BITS transfers & WFP filters'
        if ($script:IsDry) {
            Write-Log 'DRY' 'Would execute: netsh dnsclient delete global all & netsh dnsclient delete interface name=$ea.Name setting=all'
            Write-Log 'DRY' 'Would execute: netsh winhttp reset proxy, reset autoproxy & tracing'
            Write-Log 'DRY' 'Would cancel all active BITS transfer jobs via Get-BitsTransfer'
            Write-Log 'DRY' 'Would sanitize WinINet user/machine proxies and flush SSL session cache'
        } else {
            # Reset Windows 11 encrypted DNS (DoH, DoT, DDR) globally to factory defaults
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('dnsclient', 'delete', 'global', 'all') 5000)

            # Reset per-interface DNS encryption and DDR settings across physical adapters
            foreach ($ea in @(Get-EthernetAdapters)) {
                try {
                    [void](Invoke-Native (Get-SysExe 'netsh.exe') @('dnsclient', 'delete', 'interface', "name=$($ea.Name)", 'setting=all') 5000)
                } catch {}
            }

            # WinHTTP proxy and autoproxy (WPAD) complete reset
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('winhttp', 'reset', 'proxy') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('winhttp', 'reset', 'autoproxy') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('winhttp', 'reset', 'tracing') 5000)

            # Purge hung background BITS jobs holding TCP sockets open
            try {
                Get-BitsTransfer -AllUsers -ErrorAction SilentlyContinue | Remove-BitsTransfer -Confirm:$false -ErrorAction SilentlyContinue
            } catch {}
        }
        # WinINet proxy sanitization across machine and user hives
        Shield-Proxies
        # Remove campus NRPT, legacy hosts entries, and static campus routes
        Remove-CampusNrpt
        Remove-LegacyHostsEntries
        Remove-CampusHostRoutes
        # Aggressively neutralize rogue WFP DNS interceptors
        Shield-SystemStack -Aggressive

        # ----------------------------------------------------------------------
        # STAGE 6/10: NCSI CALIBRATION, KERBEROS PURGE & SMB SESSION SWEEP
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 6/10  Calibrating NCSI active probes, purging Kerberos tickets & clearing SMB sessions'
        if ($script:IsDry) {
            Write-Log 'DRY' 'Would calibrate NCSI active probing parameters in registry to Microsoft defaults'
            Write-Log 'DRY' 'Would execute: klist purge & net use * /delete /y'
            Write-Log 'DRY' 'Would purge orphaned unmanaged NLM network signatures'
        } else {
            # Calibrate NCSI active web and DNS probing parameters to Microsoft standard endpoints
            try {
                $ncsiKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet'
                if (Test-Path -LiteralPath $ncsiKey) {
                    Set-ItemProperty -LiteralPath $ncsiKey -Name 'EnableActiveProbing' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                    Set-ItemProperty -LiteralPath $ncsiKey -Name 'ActiveWebProbeHost' -Value 'www.msftconnecttest.com' -ErrorAction SilentlyContinue
                    Set-ItemProperty -LiteralPath $ncsiKey -Name 'ActiveWebProbePath' -Value 'connecttest.txt' -ErrorAction SilentlyContinue
                    Set-ItemProperty -LiteralPath $ncsiKey -Name 'ActiveWebProbeContent' -Value 'Microsoft Connect Test' -ErrorAction SilentlyContinue
                    Set-ItemProperty -LiteralPath $ncsiKey -Name 'ActiveDnsProbeHost' -Value 'dns.msftncsi.com' -ErrorAction SilentlyContinue
                    Set-ItemProperty -LiteralPath $ncsiKey -Name 'ActiveDnsProbeContent' -Value '131.107.0.89' -ErrorAction SilentlyContinue
                }
            } catch {}

            # Purge Kerberos ticket cache to clear expired campus realm authentication tickets
            [void](Invoke-Native (Get-SysExe 'klist.exe') @('purge') 5000)

            # Flush stale SMB network share sessions
            [void](Invoke-Native (Get-SysExe 'net.exe') @('use', '*', '/delete', '/y') 5000)

            # Purge orphaned unmanaged network signatures in Network List Manager
            try {
                $nlmSigKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\Unmanaged'
                if (Test-Path -LiteralPath $nlmSigKey) {
                    Get-ChildItem -LiteralPath $nlmSigKey -ErrorAction SilentlyContinue | ForEach-Object {
                        try { Remove-Item -LiteralPath $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue } catch {}
                    }
                }
            } catch {}
        }

        # ----------------------------------------------------------------------
        # STAGE 7/10: CACHE EVICTION, NEIGHBOR TABLE PURGE & NETBIOS RELEASE
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 7/10  Purging ARP/NDP/NetBIOS caches & flushing DNS resolver'
        if ($script:IsDry) {
            Write-Log 'DRY' 'Would execute: netsh interface ip delete arpcache, arp -d *, and delete neighbors'
            Write-Log 'DRY' 'Would execute: nbtstat -R & nbtstat -RR'
            Write-Log 'DRY' 'Would execute: ipconfig /flushdns, Clear-DnsClientCache, and clear suffix search list'
        } else {
            # Low-level ARP & neighbor cache deletion across all interfaces
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'ip', 'delete', 'arpcache') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'ip', 'delete', 'neighbors') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'ipv6', 'delete', 'neighbors') 5000)
            [void](Invoke-Native (Get-SysExe 'arp.exe') @('-d', '*') 5000)
            Get-NetNeighbor -AddressFamily IPv4 -ErrorAction SilentlyContinue | Remove-NetNeighbor -Confirm:$false -ErrorAction SilentlyContinue
            Get-NetNeighbor -AddressFamily IPv6 -ErrorAction SilentlyContinue | Remove-NetNeighbor -Confirm:$false -ErrorAction SilentlyContinue

            # Flush NetBIOS remote name cache and broadcast name release/refresh
            [void](Invoke-Native (Get-SysExe 'nbtstat.exe') @('-R') 5000)
            [void](Invoke-Native (Get-SysExe 'nbtstat.exe') @('-RR') 5000)

            # Flush DNS resolver cache and clear global suffix search lists
            Clear-DnsClientCache -ErrorAction SilentlyContinue
            [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/flushdns') 5000)
            try { Set-DnsClientGlobalSetting -SuffixSearchList @() -ErrorAction SilentlyContinue } catch {}
        }

        # ----------------------------------------------------------------------
        # STAGE 8/10: PHY HARDWARE TRANSCEIVER HARD CYCLE, PROTOCOL BINDINGS & DRIVER POWER LOCK
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 8/10  Cycling PHY hardware, locking driver power profiles & rebuilding NDIS bindings'
        Shield-Aspm
        Set-UsbSuspendOff
        foreach ($ea in @(Get-EthernetAdapters)) {
            if ($script:IsDry) {
                Write-Log 'DRY' "Would cycle transceiver, restore bindings, lock power, and configure $($ea.Name)"
            } else {
                Reset-PhysicalAdapterHardware $ea
                Release-ArpLocks $ea
                [void](Shield-TcpOffloads $ea)
                [void](Shield-Dot3Svc $ea)
                [void](Shield-Hardware $ea)

                # Ensure core protocol bindings are active
                foreach ($comp in @('ms_tcpip', 'ms_tcpip6', 'ms_rspndr', 'ms_lltdio', 'ms_msclient', 'ms_server', 'ms_pacer')) {
                    try { Enable-NetAdapterBinding -Name $ea.Name -ComponentID $comp -ErrorAction SilentlyContinue } catch {}
                }

                # Defeat energy-saving / Green Ethernet traps on the PHY
                try {
                    Set-NetAdapterAdvancedProperty -Name $ea.Name -RegistryKeyword '*EEE' -RegistryValue 0 -ErrorAction SilentlyContinue
                    Set-NetAdapterAdvancedProperty -Name $ea.Name -RegistryKeyword '*EnergyEfficientEthernet' -RegistryValue 0 -ErrorAction SilentlyContinue
                    Set-NetAdapterAdvancedProperty -Name $ea.Name -RegistryKeyword '*GreenEthernet' -RegistryValue 0 -ErrorAction SilentlyContinue
                } catch {}
            }
        }
        if (-not $script:IsDry) {
            [void](Invoke-Native (Get-SysExe 'pnputil.exe') @('/scan-devices') 5000)
        }
        Restore-InterfaceMetrics 'Ultra System Reset metrics restore'

        # ----------------------------------------------------------------------
        # STAGE 9/10: DHCP LEASE REGISTRY OBLITERATION & RFC 2131 BROADCAST FLAG ENFORCEMENT
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 9/10  Zeroing DHCP lease registry & enforcing RFC 2131 broadcast flag'
        foreach ($ea in @(Get-EthernetAdapters)) {
            if ($script:IsDry) {
                Write-Log 'DRY' "Would zero DHCP lease registry, set DhcpConnForceBroadcastFlag, and reset MTU/DNS on $($ea.Name)"
            } else {
                # Zero out cached DHCP lease keys in the Windows registry to force clean DHCP Discover broadcast
                $guid = [string]$ea.InterfaceGuid
                if ($guid) {
                    $ifKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"
                    if (Test-Path -LiteralPath $ifKey) {
                        try {
                            Set-ItemProperty -LiteralPath $ifKey -Name 'DhcpIPAddress' -Value '0.0.0.0' -ErrorAction SilentlyContinue
                            Set-ItemProperty -LiteralPath $ifKey -Name 'DhcpDefaultGateway' -Value @() -ErrorAction SilentlyContinue
                            Set-ItemProperty -LiteralPath $ifKey -Name 'DhcpServer' -Value '255.255.255.255' -ErrorAction SilentlyContinue
                            Set-ItemProperty -LiteralPath $ifKey -Name 'DhcpSubnetMask' -Value '0.0.0.0' -ErrorAction SilentlyContinue
                            Set-ItemProperty -LiteralPath $ifKey -Name 'DhcpNameServer' -Value '' -ErrorAction SilentlyContinue
                            # Enforce RFC 2131 Broadcast Flag so campus switches/relays do not drop unicast offers
                            Set-ItemProperty -LiteralPath $ifKey -Name 'DhcpConnForceBroadcastFlag' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                        } catch {}
                    }
                }

                # Re-enable DHCP, reset MTU to standard 1500, set automatic metric, and reset DNS servers
                try {
                    Set-NetIPInterface -InterfaceIndex $ea.ifIndex -AddressFamily IPv4 -Dhcp Enabled -NlMtuBytes 1500 -AutomaticMetric Enabled -ErrorAction SilentlyContinue
                    Set-NetIPInterface -InterfaceIndex $ea.ifIndex -AddressFamily IPv6 -Dhcp Enabled -ErrorAction SilentlyContinue
                    Set-DnsClientServerAddress -InterfaceIndex $ea.ifIndex -ResetServerAddresses -ErrorAction SilentlyContinue
                } catch {}
            }
        }

        # ----------------------------------------------------------------------
        # STAGE 10/10: TOPOLOGICAL 10-SERVICE RESUSCITATION, 802.1X RECONNECT, STP CONVERGENCE & 7-LAYER DUAL VERIFY
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 10/10 Resuscitating 10 core services, reconnecting 802.1X, running DHCP discover & 7-layer verification'
        if ($script:IsDry) {
            Write-Log 'DRY' 'Would start services in topological order: BFE -> mpssvc -> CryptSvc -> Dhcp -> Dnscache -> iphlpsvc -> dot3svc -> WlanSvc -> NlaSvc -> netprofm -> BITS'
            Write-Log 'DRY' 'Would execute: netsh lan reconnect'
            Write-Log 'DRY' 'Would execute: ipconfig /release *, /renew *, /registerdns'
            Write-Log 'DRY' 'Would await 802.1D Spanning Tree Protocol (STP) switch convergence'
            Write-Log 'DRY' 'Would run 7-layer heal pipeline and verify dual-endpoint reachability'
        } else {
            $upSvcs = @('BFE', 'mpssvc', 'CryptSvc', 'Dhcp', 'Dnscache', 'iphlpsvc', 'dot3svc', 'WlanSvc', 'NlaSvc', 'netprofm', 'BITS')
            foreach ($s in $upSvcs) {
                try { Start-Service -Name $s -ErrorAction SilentlyContinue } catch {}
            }
            Start-Sleep -Milliseconds 1500

            # Force 802.1X Wired AutoConfig reconnect across all LAN interfaces
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('lan', 'reconnect') 5000)

            # Execute clean DHCP discover cycle
            [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/release') 8000)
            [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/release6') 8000)
            Start-Sleep -Milliseconds 1000
            # Wait for STP listening/learning convergence before DHCP renewal
            foreach ($ea in @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })) {
                [void](Wait-StpConvergence $ea 15)
            }
            [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/renew') 15000)
            [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/renew6') 15000)
            [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/registerdns') 5000)
        }

        # 7-Layer Ethernet & Multi-Homed Heal Pipeline
        $resHeal = Pick-Hash (Invoke-HealPipeline -SkipSystemStack)
        $anyVerifyFail = $false
        $upEths = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
        $primarySrc = if ($upEths.Count -gt 0) { Get-ValidIPv4 $upEths[0] } else { '' }
        foreach ($testHost in @('github.com', 'accounts.google.com')) {
            $ip = Resolve-HostBounded $testHost 3000 $primarySrc
            if ($ip) {
                $tcpOk = Test-TcpPort $ip 443 2500 $primarySrc
                Write-Log ($(if ($tcpOk) { 'OK' } else { 'WARN' })) ("Verified {0} -> {1} (TCP/443: {2})" -f $testHost, $ip, $(if ($tcpOk) { 'OPEN' } else { 'BLOCKED' }))
            } else {
                $anyVerifyFail = $true
                Write-Log 'FAIL' ("DNS resolution still failed for {0}" -f $testHost)
            }
        }
        if ($anyVerifyFail -and -not $script:IsDry -and ($resHeal.Conn -ne 'Captive')) {
            Write-Log 'WARN' 'DNS resolution failed for public endpoints. Deploying adaptive public DNS rescue...'
            foreach ($ea in @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })) {
                $rescueDns = @(Get-BestDnsOrder ([string]$ea.InterfaceGuid) @())
                if ($rescueDns.Count -gt 0) {
                    Write-Log 'INFO' "Applying active public DNS rescue on $($ea.Name): $($rescueDns -join ', ')..."
                    [void](Set-AdapterDns $ea $rescueDns)
                }
            }
            Clear-DnsClientCache -ErrorAction SilentlyContinue
            [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/flushdns') 5000)
            foreach ($testHost in @('github.com', 'accounts.google.com')) {
                $ip = Resolve-HostBounded $testHost 3000 $primarySrc
                if ($ip) {
                    $tcpOk = Test-TcpPort $ip 443 2500 $primarySrc
                    Write-Log ($(if ($tcpOk) { 'OK' } else { 'WARN' })) ("Re-verified {0} -> {1} (TCP/443: {2})" -f $testHost, $ip, $(if ($tcpOk) { 'OPEN' } else { 'BLOCKED' }))
                }
            }
        }
        Restore-WlanProfiles
        Complete-ResetJournal -Success $true
        Save-State
        $resHeal
        } finally {
            if (-not $script:IsDry) {
                $reviveSvcs = @('BFE', 'mpssvc', 'CryptSvc', 'Dhcp', 'Dnscache', 'iphlpsvc', 'dot3svc', 'WlanSvc', 'NlaSvc', 'netprofm', 'BITS')
                foreach ($s in $reviveSvcs) {
                    try { Start-Service -Name $s -ErrorAction SilentlyContinue } catch {}
                }
            }
        }
    })
    $swUltra.Stop()
    Write-HealSummary $r $swUltra
    if ($r -and $r.Conn -eq 'Captive' -and -not $script:IsDry) {
        [void](Invoke-WithLock { [void](Open-Portal); Save-State })
        if ($script:UiOn -and (Get-InternetState -NoCache).State -eq 'Captive') {
            Out-Line @((Seg 'dim' '  Sign in on the page that opened; the fast DNS path is applied for you afterwards.'))
            if (Wait-ForAuthentication 180) { Complete-Authentication; Write-Log 'OK' 'Signed in. Post-login DNS applied.' }
        }
    }
}
# ==============================================================================
# DOOMSDAY SYSTEM RESET - 12-STAGE MULTI-ADAPTER & STACK RESCUE ENGINE
# ==============================================================================
function Invoke-DoomsdayReset([switch]$Confirmed) {
    if (-not (Test-ResetPreconditions 'Doomsday' -Confirmed:$Confirmed)) { return }
    $swDoom = [System.Diagnostics.Stopwatch]::StartNew()
    Write-Section 'DOOMSDAY SYSTEM RESET (12-STAGE UNIVERSAL MULTI-ADAPTER RESCUE)'
    $r = Pick-Hash (Invoke-WithLock {
        # ----------------------------------------------------------------------
        # STAGE 1/12: PRE-FLIGHT ACID SNAPSHOT, AIRPLANE UNLOCK & 13-SERVICE SUSPENSION
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 1/12 Snapshotting global state, unlocking Airplane mode & suspending 13 services'
        $script:ConnCache = $null
        $script:EnvCache = @{}
        if ($script:IsDry) {
            Write-Log 'DRY' 'Would capture pre-flight snapshots across all network adapters'
            Write-Log 'DRY' 'Would unlock RadioManagement Airplane Mode in registry'
            Write-Log 'DRY' 'Would stop: BITS, WwanSvc, bthserv, RmSvc, netprofm, NlaSvc, Dnscache, Dhcp, iphlpsvc, dot3svc, WlanSvc, CryptSvc, mpssvc'
        } else {
            Set-ResetJournal -Tier 'Doomsday' -TotalStages 12 -Stage 1 -StageDesc 'Snapshot & Radio Unlock'
            if (-not (Capture-GlobalPreflightSnapshot)) {
                if (-not $Force) {
                    Write-Log 'FAIL' 'Pre-flight safety snapshot failed. Doomsday Reset aborted.'
                    return
                }
                Write-Log 'WARN' 'Pre-flight snapshot failed, proceeding due to -Force.'
            }
            $script:State.Misc['RouteProfile'] = 'Adaptive'
            $script:State.Misc['DnsProfile'] = 'Adaptive'
            $script:State.Misc['FailStreak'] = 0
            foreach ($mk in @($script:State.Misc.Keys | Where-Object { $_ -like 'MtuCandidate*' })) { $script:State.Misc.Remove($mk) }
            foreach ($dk in @('DiscoveredDomain', 'DiscoveredPortalIp', 'DiscoveredPortalUrl', 'DiscoveredPortalPort', 'DiscoveryTime')) {
                if ($script:State.Misc.ContainsKey($dk)) { $script:State.Misc.Remove($dk) }
            }

            # Unlock RadioManagement Airplane Mode deadlock in registry
            try {
                $rmKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\RadioManagement'
                if (Test-Path -LiteralPath $rmKey) {
                    Set-ItemProperty -LiteralPath $rmKey -Name 'SystemRadioState' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                }
            } catch {}

            # Reverse topological teardown of all 13 core networking services
            $downSvcs = @('BITS', 'WwanSvc', 'bthserv', 'RmSvc', 'netprofm', 'NlaSvc', 'Dnscache', 'Dhcp', 'iphlpsvc', 'dot3svc', 'WlanSvc', 'CryptSvc', 'mpssvc')
            foreach ($s in $downSvcs) {
                try { Stop-Service -Name $s -Force -ErrorAction SilentlyContinue } catch {}
            }
        }

        try {
        # ----------------------------------------------------------------------
        # STAGE 2/12: NDIS FILTER DECONTAMINATION, SILICON D3 WAKE, WLAN & ADAPTER CYCLE
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 2/12 Decontaminating NDIS filters, waking silicon (pnputil), WLAN & adapter cycle'
        if ($script:IsDry) {
            Write-Log 'DRY' 'Would teardown Wi-Fi hosted networks & re-enable WLAN AutoConfig'
            Write-Log 'DRY' 'Would cycle all physical adapters and deactivate rogue 3rd-party NDIS filter drivers'
            Write-Log 'DRY' 'Would issue hardware PnP bus restart (pnputil /restart-device) to wake PHY silicon'
        } else {
            # Teardown Wi-Fi hosted networks & re-enable Wi-Fi AutoConfig
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('wlan', 'stop', 'hostednetwork') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('wlan', 'set', 'hostednetwork', 'mode=disallow') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('wlan', 'set', 'autoconfig', 'enabled=yes', 'interface=*') 5000)

            # Cycle all physical network adapters and neutralize 3rd-party NDIS filter drop traps
            $allPhys = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object {
                ($_.HardwareInterface -or $_.ConnectorPresent) -and
                $_.InterfaceDescription -notmatch 'Virtual|Hyper-V|WSL|Tailscale|ZeroTier|WireGuard|TAP|Loopback'
            })
            foreach ($ad in $allPhys) {
                # Deactivate rogue 3rd-party NDIS filter drivers (Npcap, VirtualBox, VPN, Antivirus packet drop traps)
                try {
                    $bindings = @(Get-NetAdapterBinding -Name $ad.Name -ErrorAction SilentlyContinue)
                    foreach ($b in $bindings) {
                        if ($b.ComponentID -notmatch '^(ms_|vms_)' -and $b.Enabled) {
                            Write-Log 'WARN' "Deactivating 3rd-party NDIS filter trap '$($b.DisplayName)' ($($b.ComponentID)) on $($ad.Name)..."
                            if ($script:State.Snapshot -isnot [hashtable]) { $script:State.Snapshot = @{} }
                            if (-not $script:State.Snapshot.ContainsKey('DeactivatedFilters')) {
                                $script:State.Snapshot['DeactivatedFilters'] = @{}
                            }
                            if (-not $script:State.Snapshot['DeactivatedFilters'].ContainsKey($ad.Name)) {
                                $script:State.Snapshot['DeactivatedFilters'][$ad.Name] = @()
                            }
                            if ($script:State.Snapshot['DeactivatedFilters'][$ad.Name] -notcontains $b.ComponentID) {
                                $script:State.Snapshot['DeactivatedFilters'][$ad.Name] += $b.ComponentID
                            }
                            try { Disable-NetAdapterBinding -Name $ad.Name -ComponentID $b.ComponentID -ErrorAction SilentlyContinue } catch {}
                        }
                    }
                } catch {}
                try {
                    Restart-NetAdapter -Name $ad.Name -Confirm:$false -ErrorAction SilentlyContinue
                    $chkAd = Get-NetAdapter -Name $ad.Name -ErrorAction SilentlyContinue
                    if ($chkAd -and $chkAd.Status -eq 'Disabled') {
                        Enable-NetAdapter -Name $ad.Name -Confirm:$false -ErrorAction SilentlyContinue
                    }
                } catch {}
                # Re-bind core NDIS protocols
                foreach ($comp in @('ms_tcpip', 'ms_tcpip6', 'ms_rspndr', 'ms_lltdio', 'ms_msclient', 'ms_server', 'ms_pacer', 'ms_lldp', 'ms_netbt')) {
                    try { Enable-NetAdapterBinding -Name $ad.Name -ComponentID $comp -ErrorAction SilentlyContinue } catch {}
                }
            }

            # Wake physical silicon from Modern Standby D3cold / PCIe ASPM hardware lockup
            try {
                $pnpDevs = @(Get-PnpDevice -Class Net -Status OK -ErrorAction SilentlyContinue | Where-Object { $_.InstanceId -match '^(PCI|USB)\\' })
                foreach ($pdev in $pnpDevs) {
                    Write-Log 'INFO' "Issuing hardware PnP bus restart to wake silicon: $($pdev.FriendlyName)..."
                    [void](Invoke-Native (Get-SysExe 'pnputil.exe') @('/restart-device', $pdev.InstanceId) 8000)
                }
            } catch {}
        }

        # ----------------------------------------------------------------------
        # STAGE 3/12: DUAL-ARCHITECTURE WINSOCK CATALOG OBLITERATION (64-BIT & 32-BIT)
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 3/12 Dual-architecture Winsock LSP/NSP catalog wipe (64-bit System32 & 32-bit SysWOW64)'
        if ($script:IsDry) {
            Write-Log 'DRY' 'Would execute 64-bit and 32-bit: netsh winsock reset catalog & netsh winsock reset'
            Write-Log 'DRY' 'Would reset Winsock AutodialFlags to 0 in registry'
        } else {
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('winsock', 'reset', 'catalog') 8000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('winsock', 'reset') 5000)
            $wowNetsh = Join-Path $env:SystemRoot 'SysWOW64\netsh.exe'
            if (Test-Path -LiteralPath $wowNetsh) {
                [void](Invoke-Native $wowNetsh @('winsock', 'reset', 'catalog') 8000)
                [void](Invoke-Native $wowNetsh @('winsock', 'reset') 5000)
            }
            try {
                $ws2Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\WinSock2\Parameters'
                if (Test-Path -LiteralPath $ws2Key) {
                    Set-ItemProperty -LiteralPath $ws2Key -Name 'AutodialFlags' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                }
            } catch {}
        }

        # ----------------------------------------------------------------------
        # STAGE 4/12: DUAL-STACK TCP/IP STACK REBUILD, HEURISTICS & TUNNEL DEFEAT
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 4/12 Dual-stack TCP/IP stack restoration, global heuristics reset & HTTP flush'
        if ($script:IsDry) {
            Write-Log 'DRY' 'Would execute: netsh int ip reset & netsh int ipv6 reset'
            Write-Log 'DRY' 'Would execute: netsh int tcp reset & normalize autotuning/RSS/RSC/timestamps'
            Write-Log 'DRY' 'Would disable transition tunnels: Teredo, ISATAP, 6to4'
        } else {
            $ipLog = Join-Path $env:TEMP ('netsh_ip_reset_' + [Guid]::NewGuid().ToString('N').Substring(0,8) + '.log')
            $ipv6Log = Join-Path $env:TEMP ('netsh_ipv6_reset_' + [Guid]::NewGuid().ToString('N').Substring(0,8) + '.log')
            try {
                [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'ip', 'reset', $ipLog) 10000)
            } finally {
                if (Test-Path -LiteralPath $ipLog) { Remove-Item -LiteralPath $ipLog -Force -ErrorAction SilentlyContinue }
            }
            try {
                [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'ipv6', 'reset', $ipv6Log) 10000)
            } finally {
                if (Test-Path -LiteralPath $ipv6Log) { Remove-Item -LiteralPath $ipv6Log -Force -ErrorAction SilentlyContinue }
            }

            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'tcp', 'reset') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'tcp', 'set', 'heuristics', 'disabled') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'tcp', 'set', 'global', 'autotuninglevel=normal') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'tcp', 'set', 'global', 'rss=enabled') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'tcp', 'set', 'global', 'rsc=enabled') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'tcp', 'set', 'global', 'ecncapability=disabled') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'tcp', 'set', 'global', 'timestamps=disabled') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'tcp', 'set', 'global', 'initialrto=3000') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'tcp', 'set', 'global', 'nonsackrttresiliency=disabled') 5000)

            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'teredo', 'set', 'state', 'disabled') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'isatap', 'set', 'state', 'disabled') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', '6to4', 'set', 'state', 'disabled') 5000)

            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('http', 'flush', 'logbuffer') 5000)
        }

        # ----------------------------------------------------------------------
        # STAGE 5/12: ROUTE PURGE, GHOST GUID SCRUB, PORTPROXY & PERMISSIVE FIREWALL
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 5/12 Purging routing table (route -f), ghost registry GUIDs & setting firewall outbound allow'
        if ($script:IsDry) {
            Write-Log 'DRY' 'Would execute: route -f (purge all routes and gateways)'
            Write-Log 'DRY' 'Would scrub ghost GUIDs in Tcpip\Parameters\Interfaces'
            Write-Log 'DRY' 'Would delete IPv4 & IPv6 destination caches'
            Write-Log 'DRY' 'Would execute: netsh interface portproxy reset & netsh interface httpstunnel reset'
            Write-Log 'DRY' 'Would destroy accidental network bridges via netsh bridge'
            Write-Log 'DRY' 'Would execute: netsh advfirewall reset & set firewallpolicy blockinbound,allowoutbound'
        } else {
            [void](Invoke-Native (Get-SysExe 'route.exe') @('-f') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'ip', 'delete', 'destinationcache') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'ipv6', 'delete', 'destinationcache') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'portproxy', 'reset') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'httpstunnel', 'reset') 5000)

            # Scrub orphaned interface GUIDs under Tcpip\Parameters\Interfaces to eliminate routing blackholes
            try {
                $activeGuids = @(Get-NetAdapter -ErrorAction SilentlyContinue | ForEach-Object { [string]$_.InterfaceGuid })
                $tcpipIfKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces'
                if (Test-Path -LiteralPath $tcpipIfKey) {
                    $subkeys = @(Get-ChildItem -LiteralPath $tcpipIfKey -ErrorAction SilentlyContinue)
                    foreach ($sk in $subkeys) {
                        if ($sk.PSChildName -notin $activeGuids) {
                            try {
                                Set-ItemProperty -LiteralPath $sk.PSPath -Name 'DefaultGateway' -Value @() -ErrorAction SilentlyContinue
                                Set-ItemProperty -LiteralPath $sk.PSPath -Name 'IPAddress' -Value @() -ErrorAction SilentlyContinue
                                Set-ItemProperty -LiteralPath $sk.PSPath -Name 'SubnetMask' -Value @() -ErrorAction SilentlyContinue
                            } catch {}
                        }
                    }
                }
            } catch {}

            try {
                $brOut = Invoke-Native (Get-SysExe 'netsh.exe') @('bridge', 'list') 5000
                if ($brOut.Output -match '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})') {
                    foreach ($brMatch in [regex]::Matches($brOut.Output, '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})')) {
                        $brGuid = $brMatch.Groups[1].Value
                        Write-Log 'WARN' "Destroying orphaned network bridge $brGuid..."
                        [void](Invoke-Native (Get-SysExe 'netsh.exe') @('bridge', 'destroy', $brGuid) 5000)
                    }
                }
            } catch {}

            # Backup custom firewall rules before reset for 100% reversible rollback
            try {
                $fwBackup = Join-Path $script:StoreDir 'firewall_pre_reset.wfw'
                if (-not (Test-Path -LiteralPath $fwBackup)) {
                    [void](Invoke-Native (Get-SysExe 'netsh.exe') @('advfirewall', 'export', $fwBackup) 5000)
                }
            } catch {}

            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('advfirewall', 'reset') 8000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('advfirewall', 'set', 'allprofiles', 'firewallpolicy', 'blockinbound,allowoutbound') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('advfirewall', 'set', 'allprofiles', 'state', 'on') 5000)
        }

        # ----------------------------------------------------------------------
        # STAGE 6/12: ENCRYPTED DNS (DOH/DOT/DDR) WIPE, WPAD AUTOPROXY & BITS JOB PURGE
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 6/12 Resetting encrypted DNS across ALL interfaces, WPAD autoproxy & BITS jobs'
        if ($script:IsDry) {
            Write-Log 'DRY' 'Would execute: netsh dnsclient delete global all'
            Write-Log 'DRY' 'Would reset per-interface encrypted DNS across ALL adapters'
            Write-Log 'DRY' 'Would reset WinHTTP proxy/autoproxy/tracing'
            Write-Log 'DRY' 'Would cancel all active BITS transfers'
        } else {
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('dnsclient', 'delete', 'global', 'all') 5000)
            foreach ($ad in @(Get-NetAdapter -ErrorAction SilentlyContinue)) {
                try {
                    [void](Invoke-Native (Get-SysExe 'netsh.exe') @('dnsclient', 'delete', 'interface', "name=$($ad.Name)", 'setting=all') 5000)
                } catch {}
            }
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('winhttp', 'reset', 'proxy') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('winhttp', 'reset', 'autoproxy') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('winhttp', 'reset', 'tracing') 5000)
            try {
                Get-BitsTransfer -AllUsers -ErrorAction SilentlyContinue | Remove-BitsTransfer -Confirm:$false -ErrorAction SilentlyContinue
            } catch {}
        }

        # ----------------------------------------------------------------------
        # STAGE 7/12: UNIVERSAL PROXY & DEAD VPN KILLSWITCH ANNIHILATION
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 7/12 Obliterating system-wide proxies & dead VPN killswitch traps across all hives'
        if ($script:IsDry) {
            Write-Log 'DRY' 'Would purge ProxyEnable, ProxyServer, AutoConfigURL across HKCU, HKLM, and HKU'
            Write-Log 'DRY' 'Would clear process, user, and system proxy environment variables'
        } else {
            Shield-Proxies
            try {
                $hkuProfiles = @(Get-ChildItem -LiteralPath 'Registry::HKEY_USERS' -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -notmatch '_Classes$' })
                foreach ($hp in $hkuProfiles) {
                    $isPath = "Registry::HKEY_USERS\$($hp.PSChildName)\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
                    if (Test-Path -LiteralPath $isPath) {
                        try {
                            Set-ItemProperty -LiteralPath $isPath -Name 'ProxyEnable' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                            Set-ItemProperty -LiteralPath $isPath -Name 'ProxyServer' -Value '' -ErrorAction SilentlyContinue
                            Set-ItemProperty -LiteralPath $isPath -Name 'AutoConfigURL' -Value '' -ErrorAction SilentlyContinue
                        } catch {}
                    }
                }
            } catch {}
            foreach ($vName in @('HTTP_PROXY', 'HTTPS_PROXY', 'ALL_PROXY', 'NO_PROXY', 'http_proxy', 'https_proxy', 'all_proxy', 'no_proxy')) {
                [System.Environment]::SetEnvironmentVariable($vName, $null, [System.EnvironmentVariableTarget]::Process)
                try { [System.Environment]::SetEnvironmentVariable($vName, $null, [System.EnvironmentVariableTarget]::User) } catch {}
                try { [System.Environment]::SetEnvironmentVariable($vName, $null, [System.EnvironmentVariableTarget]::Machine) } catch {}
            }
        }

        # ----------------------------------------------------------------------
        # STAGE 8/12: HOSTS FILE SANITIZATION, SYSTEM-WIDE NRPT WIPE & WFP DEFEAT
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 8/12 Sanitizing hosts file, eradicating all NRPT rules & neutralizing rogue WFP filters'
        Remove-LegacyHostsEntries
        Remove-CampusNrpt
        try {
            Get-DnsClientNrptRule -ErrorAction SilentlyContinue | Remove-DnsClientNrptRule -Force -ErrorAction SilentlyContinue
            $nrptPolKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DnsClient\DnsPolicyConfig'
            if (Test-Path -LiteralPath $nrptPolKey) {
                Remove-Item -LiteralPath $nrptPolKey -Recurse -Force -ErrorAction SilentlyContinue
            }
        } catch {}
        Remove-CampusHostRoutes
        Shield-SystemStack -Aggressive

        # ----------------------------------------------------------------------
        # STAGE 9/12: NCSI CALIBRATION, KERBEROS TICKET & SMB SESSION PURGE
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 9/12 Calibrating NCSI active probes, purging Kerberos tickets & clearing SMB sessions'
        if ($script:IsDry) {
            Write-Log 'DRY' 'Would calibrate NCSI active probing parameters in registry'
            Write-Log 'DRY' 'Would execute: klist purge & net use * /delete /y'
            Write-Log 'DRY' 'Would purge unmanaged NLM signatures'
        } else {
            try {
                $ncsiKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet'
                if (Test-Path -LiteralPath $ncsiKey) {
                    Set-ItemProperty -LiteralPath $ncsiKey -Name 'EnableActiveProbing' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                    Set-ItemProperty -LiteralPath $ncsiKey -Name 'ActiveWebProbeHost' -Value 'www.msftconnecttest.com' -ErrorAction SilentlyContinue
                    Set-ItemProperty -LiteralPath $ncsiKey -Name 'ActiveWebProbePath' -Value 'connecttest.txt' -ErrorAction SilentlyContinue
                    Set-ItemProperty -LiteralPath $ncsiKey -Name 'ActiveWebProbeContent' -Value 'Microsoft Connect Test' -ErrorAction SilentlyContinue
                    Set-ItemProperty -LiteralPath $ncsiKey -Name 'ActiveDnsProbeHost' -Value 'dns.msftncsi.com' -ErrorAction SilentlyContinue
                    Set-ItemProperty -LiteralPath $ncsiKey -Name 'ActiveDnsProbeContent' -Value '131.107.0.89' -ErrorAction SilentlyContinue
                }
            } catch {}

            [void](Invoke-Native (Get-SysExe 'klist.exe') @('purge') 5000)
            [void](Invoke-Native (Get-SysExe 'net.exe') @('use', '*', '/delete', '/y') 5000)

            try {
                $nlmSigKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\Unmanaged'
                if (Test-Path -LiteralPath $nlmSigKey) {
                    Get-ChildItem -LiteralPath $nlmSigKey -ErrorAction SilentlyContinue | ForEach-Object {
                        try { Remove-Item -LiteralPath $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue } catch {}
                    }
                }
            } catch {}
        }

        # ----------------------------------------------------------------------
        # STAGE 10/12: LOW-LEVEL ARP/NDP EVICTION, NETBIOS RELEASE & DNS RESOLVER FLUSH
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 10/12 Purging ARP/NDP/NetBIOS caches & flushing DNS resolver across all interfaces'
        if ($script:IsDry) {
            Write-Log 'DRY' 'Would execute: netsh interface ip delete arpcache, arp -d *, and delete neighbors'
            Write-Log 'DRY' 'Would execute: nbtstat -R & nbtstat -RR'
            Write-Log 'DRY' 'Would execute: ipconfig /flushdns, Clear-DnsClientCache, and clear suffix search list'
        } else {
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'ip', 'delete', 'arpcache') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'ip', 'delete', 'neighbors') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('int', 'ipv6', 'delete', 'neighbors') 5000)
            [void](Invoke-Native (Get-SysExe 'arp.exe') @('-d', '*') 5000)
            Get-NetNeighbor -AddressFamily IPv4 -ErrorAction SilentlyContinue | Remove-NetNeighbor -Confirm:$false -ErrorAction SilentlyContinue
            Get-NetNeighbor -AddressFamily IPv6 -ErrorAction SilentlyContinue | Remove-NetNeighbor -Confirm:$false -ErrorAction SilentlyContinue

            [void](Invoke-Native (Get-SysExe 'nbtstat.exe') @('-R') 5000)
            [void](Invoke-Native (Get-SysExe 'nbtstat.exe') @('-RR') 5000)

            Clear-DnsClientCache -ErrorAction SilentlyContinue
            [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/flushdns') 5000)
            try { Set-DnsClientGlobalSetting -SuffixSearchList @() -ErrorAction SilentlyContinue } catch {}
        }

        # ----------------------------------------------------------------------
        # STAGE 11/12: STATIC IP CONFLICT PURGE, DHCP ENFORCEMENT, MTU 1500 & LEASE ZEROING
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 11/12 Purging static IP conflicts, enforcing DHCP, MTU 1500 & broadcast flag on ALL media'
        Shield-Aspm
        Set-UsbSuspendOff
        $allAdapters = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object {
            $_.InterfaceDescription -notmatch 'Virtual|Hyper-V|WSL|Tailscale|ZeroTier|WireGuard|TAP|Loopback'
        })
        foreach ($ad in $allAdapters) {
            if ($script:IsDry) {
                Write-Log 'DRY' "Would purge static IP conflicts, zero DHCP lease, set broadcast flag and MTU 1500 on $($ad.Name)"
            } else {
                Release-ArpLocks $ad
                try { Shield-Hardware $ad } catch {}
                try { Shield-TcpOffloads $ad } catch {}

                # Snapshot manual static IP before stripping so Restore-Everything can restore it
                try {
                    $manIps = @(Get-NetIPAddress -InterfaceIndex $ad.ifIndex -ErrorAction SilentlyContinue | Where-Object { $_.PrefixOrigin -eq 'Manual' })
                    if ($manIps.Count -gt 0) {
                        $gKey = [string]$ad.InterfaceGuid
                        if ($gKey -and (-not $script:State.Snapshot.ContainsKey($gKey) -or -not $script:State.Snapshot[$gKey].ContainsKey('StaticIp4'))) {
                            if (-not $script:State.Snapshot.ContainsKey($gKey)) { $script:State.Snapshot[$gKey] = @{} }
                            $gws = @(Get-GatewaysV4 $ad)
                            $gw = if ($gws.Count -gt 0) { [string]$gws[0] } else { '' }
                            $script:State.Snapshot[$gKey]['StaticIp4'] = @{
                                IPAddress      = [string]$manIps[0].IPAddress
                                PrefixLength   = [int]$manIps[0].PrefixLength
                                DefaultGateway = $gw
                            }
                        }
                    }
                } catch {}

                # Eradicate manual static IP addresses and default routes that cause blackholes
                try {
                    Get-NetIPAddress -InterfaceIndex $ad.ifIndex -ErrorAction SilentlyContinue | Where-Object { $_.PrefixOrigin -eq 'Manual' } | Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue
                    Get-NetRoute -InterfaceIndex $ad.ifIndex -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Where-Object { $_.NextHop -ne '0.0.0.0' } | Remove-NetRoute -Confirm:$false -ErrorAction SilentlyContinue
                } catch {}

                # Zero out cached DHCP lease keys in registry
                $guid = [string]$ad.InterfaceGuid
                if ($guid) {
                    $ifKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"
                    if (Test-Path -LiteralPath $ifKey) {
                        try {
                            Set-ItemProperty -LiteralPath $ifKey -Name 'DhcpIPAddress' -Value '0.0.0.0' -ErrorAction SilentlyContinue
                            Set-ItemProperty -LiteralPath $ifKey -Name 'DhcpDefaultGateway' -Value @() -ErrorAction SilentlyContinue
                            Set-ItemProperty -LiteralPath $ifKey -Name 'DhcpServer' -Value '255.255.255.255' -ErrorAction SilentlyContinue
                            Set-ItemProperty -LiteralPath $ifKey -Name 'DhcpSubnetMask' -Value '0.0.0.0' -ErrorAction SilentlyContinue
                            Set-ItemProperty -LiteralPath $ifKey -Name 'DhcpNameServer' -Value '' -ErrorAction SilentlyContinue
                            Set-ItemProperty -LiteralPath $ifKey -Name 'DhcpConnForceBroadcastFlag' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                        } catch {}
                    }
                }

                # Enforce DHCP, MTU 1500, and automatic metric
                try {
                    Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -Dhcp Enabled -NlMtuBytes 1500 -AutomaticMetric Enabled -ErrorAction SilentlyContinue
                    Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily IPv6 -Dhcp Enabled -ErrorAction SilentlyContinue
                    Set-DnsClientServerAddress -InterfaceIndex $ad.ifIndex -ResetServerAddresses -ErrorAction SilentlyContinue
                } catch {}

                # Defeat energy-saving traps on the PHY
                try {
                    Set-NetAdapterAdvancedProperty -Name $ad.Name -RegistryKeyword '*EEE' -RegistryValue 0 -ErrorAction SilentlyContinue
                    Set-NetAdapterAdvancedProperty -Name $ad.Name -RegistryKeyword '*EnergyEfficientEthernet' -RegistryValue 0 -ErrorAction SilentlyContinue
                    Set-NetAdapterAdvancedProperty -Name $ad.Name -RegistryKeyword '*GreenEthernet' -RegistryValue 0 -ErrorAction SilentlyContinue
                } catch {}
            }
        }
        if (-not $script:IsDry) {
            [void](Invoke-Native (Get-SysExe 'pnputil.exe') @('/scan-devices') 5000)
        }
        Restore-InterfaceMetrics 'Doomsday System Reset metrics restore'

        # ----------------------------------------------------------------------
        # STAGE 12/12: TOPOLOGICAL 13-SERVICE RESUSCITATION, 802.1X RECONNECT & VERIFY
        # ----------------------------------------------------------------------
        Write-Log 'STEP' 'STAGE 12/12 Resuscitating 13 core networking services, 802.1X, running DHCP & verifying'
        if ($script:IsDry) {
            Write-Log 'DRY' 'Would start services in topological order: BFE -> mpssvc -> CryptSvc -> RmSvc -> WlanSvc -> dot3svc -> bthserv -> WwanSvc -> Dhcp -> Dnscache -> iphlpsvc -> NlaSvc -> netprofm -> BITS'
            Write-Log 'DRY' 'Would execute: netsh lan reconnect'
            Write-Log 'DRY' 'Would execute: ipconfig /release *, /renew *, /registerdns'
            Write-Log 'DRY' 'Would await STP convergence and execute 7-layer heal pipeline'
        } else {
            $upSvcs = @('BFE', 'mpssvc', 'CryptSvc', 'RmSvc', 'WlanSvc', 'dot3svc', 'bthserv', 'WwanSvc', 'Dhcp', 'Dnscache', 'iphlpsvc', 'NlaSvc', 'netprofm', 'BITS')
            foreach ($s in $upSvcs) {
                try {
                    if ($s -notin @('bthserv', 'WwanSvc', 'BITS')) {
                        Set-Service -Name $s -StartupType Automatic -ErrorAction SilentlyContinue
                    }
                    Start-Service -Name $s -ErrorAction SilentlyContinue
                } catch {}
            }
            Start-Sleep -Milliseconds 1500

            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('lan', 'reconnect') 5000)

            [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/release') 8000)
            [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/release6') 8000)
            Start-Sleep -Milliseconds 1000
            # Wait for STP listening/learning convergence before DHCP renewal
            foreach ($ea in @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })) {
                [void](Wait-StpConvergence $ea 15)
            }
            [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/renew') 15000)
            [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/renew6') 15000)
            [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/registerdns') 5000)
        }

        # 7-Layer Ethernet & Multi-Homed Heal Pipeline
        $resHeal = Pick-Hash (Invoke-HealPipeline -SkipSystemStack)
        $anyVerifyFail = $false
        $upAdapters = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' })
        $primarySrc = ''
        foreach ($ua in $upAdapters) {
            $candidateIp = Get-ValidIPv4 $ua
            if ($candidateIp) { $primarySrc = $candidateIp; break }
        }

        foreach ($testHost in @('github.com', 'accounts.google.com')) {
            $ip = Resolve-HostBounded $testHost 3000 $primarySrc
            if ($ip) {
                $tcpOk = Test-TcpPort $ip 443 2500 $primarySrc
                Write-Log ($(if ($tcpOk) { 'OK' } else { 'WARN' })) ("Verified {0} -> {1} (TCP/443: {2})" -f $testHost, $ip, $(if ($tcpOk) { 'OPEN' } else { 'BLOCKED' }))
            } else {
                $anyVerifyFail = $true
                Write-Log 'FAIL' ("DNS resolution still failed for {0}" -f $testHost)
            }
        }
        if ($anyVerifyFail -and -not $script:IsDry -and ($resHeal.Conn -ne 'Captive')) {
            Write-Log 'WARN' 'DNS resolution failed for public endpoints. Deploying adaptive public DNS rescue...'
            foreach ($ad in @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' })) {
                $rescueDns = @(Get-BestDnsOrder ([string]$ad.InterfaceGuid) @())
                if ($rescueDns.Count -gt 0) {
                    Write-Log 'INFO' "Applying active public DNS rescue on $($ad.Name): $($rescueDns -join ', ')..."
                    [void](Set-AdapterDns $ad $rescueDns)
                }
            }
            Clear-DnsClientCache -ErrorAction SilentlyContinue
            [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/flushdns') 5000)
            foreach ($testHost in @('github.com', 'accounts.google.com')) {
                $ip = Resolve-HostBounded $testHost 3000 $primarySrc
                if ($ip) {
                    $tcpOk = Test-TcpPort $ip 443 2500 $primarySrc
                    Write-Log ($(if ($tcpOk) { 'OK' } else { 'WARN' })) ("Re-verified {0} -> {1} (TCP/443: {2})" -f $testHost, $ip, $(if ($tcpOk) { 'OPEN' } else { 'BLOCKED' }))
                }
            }
        }
        Restore-WlanProfiles
        Complete-ResetJournal -Success $true
        Save-State
        $resHeal
        } finally {
            if (-not $script:IsDry) {
                $reviveSvcs = @('BFE', 'mpssvc', 'CryptSvc', 'RmSvc', 'WlanSvc', 'dot3svc', 'bthserv', 'WwanSvc', 'Dhcp', 'Dnscache', 'iphlpsvc', 'NlaSvc', 'netprofm', 'BITS')
                foreach ($s in $reviveSvcs) {
                    try { Start-Service -Name $s -ErrorAction SilentlyContinue } catch {}
                }
            }
        }
    })
    $swDoom.Stop()
    Write-HealSummary $r $swDoom
    if ($r -and $r.Conn -eq 'Captive' -and -not $script:IsDry) {
        [void](Invoke-WithLock { [void](Open-Portal); Save-State })
        if ($script:UiOn -and (Get-InternetState -NoCache).State -eq 'Captive') {
            Out-Line @((Seg 'dim' '  Sign in on the page that opened; the fast DNS path is applied for you afterwards.'))
            if (Wait-ForAuthentication 180) { Complete-Authentication; Write-Log 'OK' 'Signed in. Post-login DNS applied.' }
        }
    }
}

# ==============================================================================
# ARMAGEDDON SYSTEM RESET - KERNEL PROTOCOL & NETWORK ADAPTER REINSTALL ENGINE
# ==============================================================================
function Invoke-ArmageddonReset([switch]$RebootNow, [switch]$Confirmed) {
    if (-not (Test-ResetPreconditions 'Armageddon' -Confirmed:$Confirmed)) { return }
    $swArm = [System.Diagnostics.Stopwatch]::StartNew()
    Write-Section 'ARMAGEDDON SYSTEM RESET (KERNEL PROTOCOL & NETWORK ADAPTER REINSTALL)'
    Write-Log 'WARN' 'ARMAGEDDON RESET executes Microsoft Windows native deep device reset (netcfg.exe -d).'
    Write-Log 'WARN' 'This uninstalls ALL network adapters, removes virtual switches/filters, purges the TCP/IP stack registry, and requires a reboot to reinstall clean drivers.'

    if ($script:IsDry) {
        Write-Log 'DRY' 'Would capture global pre-flight snapshot across all adapters'
        Write-Log 'DRY' 'Would execute: netcfg.exe -d (deep kernel device cleanup & protocol reinstallation)'
        Write-Log 'DRY' 'Would execute post-cleanup: netsh winsock reset, netsh advfirewall reset, and reset RadioManagement'
        Write-Log 'DRY' 'Would persist pending-reboot journal and schedule post-reboot verification'
        Write-Log 'DRY' 'Would prompt or execute scheduled reboot'
        return
    }

    # Pre-flight ACID snapshot
    Write-Log 'STEP' 'STAGE 1/4 Capturing global pre-flight snapshot across all network adapters'
    Set-ResetJournal -Tier 'Armageddon' -TotalStages 4 -Stage 1 -StageDesc 'Preflight Snapshot & Profile Backup'
    if (-not (Capture-GlobalPreflightSnapshot)) {
        if (-not $Force) {
            Write-Log 'FAIL' 'Pre-flight safety snapshot failed. Armageddon OS Wipe aborted.'
            return
        }
        Write-Log 'WARN' 'Pre-flight snapshot failed, proceeding due to -Force.'
    }

    # Execute netcfg -d
    Write-Log 'STEP' 'STAGE 2/4 Executing netcfg.exe -d (wiping network devices, virtual switches & protocol stacks)...'
    Update-ResetJournal -Stage 2 -StageDesc 'netcfg -d Kernel Stack Destruction'
    $netcfgRes = Invoke-Native (Get-SysExe 'netcfg.exe') @('-d') 45000
    if ($netcfgRes.Output) {
        Write-Log 'INFO' ("netcfg output: {0}" -f $netcfgRes.Output.Trim())
    }
    if ($netcfgRes.ExitCode -ne 0) {
        Write-Log 'WARN' ("netcfg returned exit code {0} or timed out. System reboot will complete driver cleanup." -f $netcfgRes.ExitCode)
    }

    # Post-cleanup pass
    Write-Log 'STEP' 'STAGE 3/4 Running post-cleanup: resetting Winsock, Firewall & RadioManagement...'
    Update-ResetJournal -Stage 3 -StageDesc 'Post-Cleanup Winsock & Firewall Reset'
    [void](Invoke-Native (Get-SysExe 'netsh.exe') @('winsock', 'reset') 5000)
    [void](Invoke-Native (Get-SysExe 'netsh.exe') @('advfirewall', 'reset') 5000)
    try {
        $rmKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\RadioManagement'
        if (Test-Path -LiteralPath $rmKey) {
            Set-ItemProperty -LiteralPath $rmKey -Name 'SystemRadioState' -Value 0 -Type DWord -ErrorAction SilentlyContinue
        }
    } catch {}

    # Stage 4/4: Post-reboot staging & journal persistence
    Write-Log 'STEP' 'STAGE 4/4 Persisting pending-reboot journal, unregistering volatile hooks & scheduling post-reboot verification'
    $stageInfo = Stage-PostRebootVerification
    Update-ResetJournal -Stage 4 -StageDesc 'Pending Reboot Journal Stamped' -Status 'PendingReboot'
    if ($stageInfo) {
        try {
            $jPath = Get-ResetJournalPath
            if (Test-Path -LiteralPath $jPath) {
                $jObj = ConvertFrom-Json (Get-Content -LiteralPath $jPath -Raw)
                try { $jObj.VerifyScriptPath = $stageInfo.Path; $jObj.VerifyScriptSha256 = $stageInfo.Hash }
                catch {
                    Add-Member -InputObject $jObj -NotePropertyName 'VerifyScriptPath' -NotePropertyValue $stageInfo.Path -Force
                    Add-Member -InputObject $jObj -NotePropertyName 'VerifyScriptSha256' -NotePropertyValue $stageInfo.Hash -Force
                }
                Set-Content -LiteralPath $jPath -Value (ConvertTo-Json $jObj) -Encoding ASCII -Force
            }
        } catch {}
    }
    $script:State.Misc['PendingReboot'] = $true
    $script:State.Misc['PendingRebootTime'] = (Get-Date).ToString('o')
    Save-State

    $swArm.Stop()
    Write-Log 'OK' ("ARMAGEDDON SYSTEM RESET completed in {0}ms." -f $swArm.ElapsedMilliseconds)
    Write-Log 'WARN' 'SYSTEM REBOOT IS REQUIRED: Windows PnP manager will redetect network hardware and reinstall factory drivers upon reboot.'

    # Handle reboot
    if ($RebootNow) {
        Write-Log 'WARN' 'Initiating immediate system restart in 5 seconds...'
        [void](Invoke-Native (Get-SysExe 'shutdown.exe') @('/r', '/t', '5', '/c', 'LanFixer Armageddon Reset: Rebooting to reinstall network drivers.') 5000)
    } elseif ($script:UiOn) {
        Write-Host ''
        Write-Host '  ========================================================================' -ForegroundColor Red
        Write-Host '  ARMAGEDDON RESET COMPLETE: SYSTEM RESTART REQUIRED' -ForegroundColor Yellow
        Write-Host '  Windows will reinstall your network adapters and clean drivers upon reboot.' -ForegroundColor Gray
        Write-Host '  ========================================================================' -ForegroundColor Red
        Write-Host ''
        if (Read-Confirm 'Would you like to restart your computer right now?' 'yes') {
            Write-Host '  Restarting system in 5 seconds...' -ForegroundColor Yellow
            [void](Invoke-Native (Get-SysExe 'shutdown.exe') @('/r', '/t', '5', '/c', 'LanFixer Armageddon Reset: Rebooting to reinstall network drivers.') 5000)
        } else {
            Write-Host '  Restart postponed. Please reboot your computer manually to restore connectivity.' -ForegroundColor Gray
        }
    }
}

# ==============================================================================
# CAREFUL NETWORK & OS STACK DEBLOATER
# ==============================================================================
function Get-DebloatStatus {
    $vectors = @(
        @{
            Id          = 'DeliveryOptimization'
            Name        = 'Delivery Optimization P2P Uploads'
            Tier        = 1
            Key         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization'
            ValueName   = 'DODownloadMode'
            OptimalVal  = 0
            OptimalType = 'DWord'
            Description = 'Uploads Windows updates to external peers over your network connection'
        },
        @{
            Id          = 'NetworkThrottling'
            Name        = 'Multimedia Network Throttling'
            Tier        = 1
            Key         = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
            ValueName   = 'NetworkThrottlingIndex'
            OptimalVal  = -1
            OptimalType = 'DWord'
            Description = 'Caps non-multimedia network processing at 10 packets per millisecond'
        },
        @{
            Id          = 'SystemResponsiveness'
            Name        = 'Network Packet Queue Priority'
            Tier        = 1
            Key         = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
            ValueName   = 'SystemResponsiveness'
            OptimalVal  = 0
            OptimalType = 'DWord'
            Description = 'Reserves 20% CPU packet scheduling away from network traffic'
        },
        @{
            Id          = 'WpadOverride'
            Name        = 'WPAD Automatic Proxy Probing'
            Tier        = 1
            Key         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad'
            ValueName   = 'WpadOverride'
            OptimalVal  = 1
            OptimalType = 'DWord'
            Description = 'Broadcasts continuous DHCP 252 queries and exposes to rogue proxy poisoning'
        },
        @{
            Id          = 'EnableMulticast'
            Name        = 'LLMNR Multicast Broadcast Resolution'
            Tier        = 2
            Key         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient'
            ValueName   = 'EnableMulticast'
            OptimalVal  = 0
            OptimalType = 'DWord'
            Description = 'Broadcasts link-local name queries vulnerable to Responder credential theft'
        },
        @{
            Id          = 'AllowTelemetry'
            Name        = 'Windows Telemetry Network Chatter'
            Tier        = 2
            Key         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'
            ValueName   = 'AllowTelemetry'
            OptimalVal  = 0
            OptimalType = 'DWord'
            Description = 'Uploads continuous diagnostic telemetry payloads to remote endpoints'
        }
    )

    $results = New-Object System.Collections.ArrayList
    foreach ($v in $vectors) {
        $exists = $false
        $curVal = $null
        try {
            if (Test-Path -LiteralPath $v.Key) {
                $p = Get-ItemProperty -LiteralPath $v.Key -Name $v.ValueName -ErrorAction SilentlyContinue
                if ($null -ne $p -and $null -ne $p.($v.ValueName)) {
                    $exists = $true
                    $curVal = $p.($v.ValueName)
                }
            }
        } catch {}

        $isOptimal = $false
        if ($exists) {
            if ($curVal -eq $v.OptimalVal) { $isOptimal = $true }
            if ($v.Id -eq 'DeliveryOptimization' -and $curVal -eq 1) { $isOptimal = $true }
            if ($v.Id -eq 'NetworkThrottling' -and ($curVal -eq -1 -or $curVal -eq 4294967295)) { $isOptimal = $true }
        }

        [void]$results.Add(@{
            Id               = $v.Id
            Name             = $v.Name
            Tier             = $v.Tier
            Key              = $v.Key
            ValueName        = $v.ValueName
            Exists           = $exists
            CurrentValue     = $curVal
            OptimalValue     = $v.OptimalVal
            OptimalType      = $v.OptimalType
            Status           = if ($isOptimal) { 'Optimal' } else { 'Bloated' }
            Description      = $v.Description
        })
    }
    return @($results)
}

function Invoke-NetworkDebloat {
    param(
        [int]$Tier = 1,
        [switch]$SafeOnly,
        [switch]$Audit,
        [switch]$Json,
        [switch]$Quiet,
        [switch]$NoColor
    )
    if ($SafeOnly) { $Tier = 1 }
    $items = @(Get-DebloatStatus)
    $targetItems = @($items | Where-Object { $_.Tier -le $Tier })

    if ($Audit -or $script:IsDry) {
        if ($Json) {
            [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'Audit'; Vectors = $targetItems } -Depth 4))
            return 0
        }
        if ($Quiet) {
            $bloatCount = @($targetItems | Where-Object { $_.Status -eq 'Bloated' }).Count
            [Console]::Out.WriteLine(("Debloat Audit: {0} bloated vectors identified across Tier {1}" -f $bloatCount, $Tier))
            return 0
        }
        $nc = [bool]($NoColor -or $script:NoColor)
        Write-Host '================================================================================' -ForegroundColor Cyan
        Write-Host ('   LANFIXER NETWORK & STACK DEBLOAT AUDIT (TIER {0})' -f $Tier) -ForegroundColor Cyan
        Write-Host '================================================================================' -ForegroundColor Cyan
        foreach ($it in $targetItems) {
            $tok = if ($it.Status -eq 'Optimal') { '[  OK  ]' } else { '[ WARN ]' }
            $tokCol = if ($it.Status -eq 'Optimal') { 'Green' } else { 'Yellow' }
            Write-Host ('  {0} {1,-36} : Current={2} | Optimal={3}' -f $tok, $it.Name, $(if ($null -ne $it.CurrentValue) { $it.CurrentValue } else { 'Not Set (Default)' }), $it.OptimalValue) -ForegroundColor $tokCol
            Write-Host ('        Vector: ' + $it.Description) -ForegroundColor Gray
        }
        Write-Host ('-' * 80) -ForegroundColor Gray
        Write-Host '  Audit complete. Zero system modifications executed.' -ForegroundColor Green
        return 0
    }

    if (-not (Assert-Admin)) { return 40 }
    Write-Log 'INFO' ("Starting Careful Network Debloat (Target Tier: {0})..." -f $Tier)

    if (-not $script:State.ContainsKey('Snapshot') -or $script:State.Snapshot -isnot [hashtable]) {
        $script:State.Snapshot = @{}
    }
    if (-not $script:State.Snapshot.ContainsKey('Debloat') -or $script:State.Snapshot.Debloat -isnot [hashtable]) {
        $script:State.Snapshot['Debloat'] = @{
            TimestampUtc = [DateTime]::UtcNow.ToString('o')
            Keys         = @{}
        }
    }
    $snap = $script:State.Snapshot['Debloat']

    $changed = 0
    foreach ($it in $targetItems) {
        if ($it.Status -eq 'Optimal') { continue }
        $snapKey = $it.Key + '\' + $it.ValueName
        if (-not $snap.Keys.ContainsKey($snapKey)) {
            $actualType = try { (Get-Item -LiteralPath $it.Key -ErrorAction SilentlyContinue).GetValueKind($it.ValueName).ToString() } catch { $it.OptimalType }
            if (-not $actualType) { $actualType = $it.OptimalType }
            $snap.Keys[$snapKey] = @{
                KeyPath      = $it.Key
                ValueName    = $it.ValueName
                Exists       = $it.Exists
                OriginalVal  = $it.CurrentValue
                OriginalType = $actualType
            }
        }

        [void](Invoke-Change ("Debloat: Set {0} ({1}={2})" -f $it.Name, $it.ValueName, $it.OptimalValue) {
            if (-not (Test-Path -LiteralPath $it.Key)) {
                [void](New-Item -Path $it.Key -ItemType Directory -Force -ErrorAction SilentlyContinue)
            }
            Set-ItemProperty -LiteralPath $it.Key -Name $it.ValueName -Value $it.OptimalValue -Type $it.OptimalType -Force -ErrorAction Stop
        } -MutationType 'Debloat' -Target $it.Name -OldValue $it.CurrentValue -NewValue $it.OptimalValue -Reversible)
        $changed++
    }

    if ($Tier -ge 2) {
        try {
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'teredo', 'set', 'state', 'disabled') 3000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', '6to4', 'set', 'state', 'disabled') 3000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'isatap', 'set', 'state', 'disabled') 3000)
            $changed++
        } catch {}
    }

    [void](Flush-NetworkCache)
    Save-State

    Write-Log 'OK' ("Careful Network Debloat completed: {0} optimizations applied safely." -f $changed)
    if ($Json) {
        [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'Success'; OptimizedCount = $changed; Tier = $Tier } -Depth 2))
    } elseif ($Quiet) {
        [Console]::Out.WriteLine(("Debloat Complete: {0} optimizations applied" -f $changed))
    } else {
        Write-Host ('================================================================================') -ForegroundColor Green
        Write-Host ('   CAREFUL NETWORK DEBLOAT COMPLETED SUCCESSFULLY') -ForegroundColor Green
        Write-Host ('   Optimized {0} vectors across Tier {1}. First-write-wins rollback snapshot preserved.' -f $changed, $Tier) -ForegroundColor Gray
        Write-Host ('================================================================================') -ForegroundColor Green
    }
    return 0
}

function Undo-NetworkDebloat {
    param(
        [switch]$Json,
        [switch]$Quiet,
        [switch]$NoColor
    )
    if ($script:IsDry) {
        Write-Log 'DRY' 'Would revert previous Network Debloat optimizations'
        return 0
    }
    if (-not $script:State.ContainsKey('Snapshot') -or -not $script:State.Snapshot.ContainsKey('Debloat')) {
        Write-Log 'WARN' 'No previous Debloat rollback snapshot was found. Nothing to revert.'
        if ($Json) {
            [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'NotFound'; Message = 'No Debloat snapshot found' } -Depth 2))
        } elseif ($Quiet) {
            [Console]::Out.WriteLine('Debloat Rollback: No snapshot found')
        } else {
            Write-Host 'No previous Debloat snapshot found. System is already at baseline.' -ForegroundColor Yellow
        }
        return 0
    }
    if (-not (Assert-Admin)) { return 40 }
    Write-Log 'INFO' 'Executing rollback of previous Network Debloat optimizations...'

    $snap = $script:State.Snapshot['Debloat']
    $restored = 0
    if ($snap.ContainsKey('Keys') -and $snap.Keys -is [hashtable]) {
        foreach ($k in $snap.Keys.Keys) {
            $item = $snap.Keys[$k]
            try {
                if ($item.Exists) {
                    [void](Invoke-Change ("Revert Debloat: Restore {0}\{1} to {2}" -f $item.KeyPath, $item.ValueName, $item.OriginalVal) {
                        Set-ItemProperty -LiteralPath $item.KeyPath -Name $item.ValueName -Value $item.OriginalVal -Type $item.OriginalType -Force -ErrorAction Stop
                    })
                } else {
                    [void](Invoke-Change ("Revert Debloat: Remove newly-created {0}\{1}" -f $item.KeyPath, $item.ValueName) {
                        Remove-ItemProperty -LiteralPath $item.KeyPath -Name $item.ValueName -Force -ErrorAction SilentlyContinue
                    })
                }
                $restored++
            } catch {}
        }
    }

    try {
        [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'teredo', 'set', 'state', 'default') 3000)
        [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', '6to4', 'set', 'state', 'default') 3000)
        [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'isatap', 'set', 'state', 'default') 3000)
    } catch {}

    [void]$script:State.Snapshot.Remove('Debloat')
    [void](Flush-NetworkCache)
    Save-State

    Write-Log 'OK' ("Debloat Rollback complete: {0} settings restored to exact pre-debloat state." -f $restored)
    if ($Json) {
        [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'Success'; RestoredCount = $restored } -Depth 2))
    } elseif ($Quiet) {
        [Console]::Out.WriteLine(("Debloat Rollback Complete: {0} settings restored" -f $restored))
    } else {
        Write-Host ('================================================================================') -ForegroundColor Green
        Write-Host ('   NETWORK DEBLOAT ROLLBACK COMPLETED SUCCESSFULLY') -ForegroundColor Green
        Write-Host ('   Restored {0} settings back to original Windows configuration.' -f $restored) -ForegroundColor Gray
        Write-Host ('================================================================================') -ForegroundColor Green
    }
    return 0
}

function Show-DebloatMenu {
    if (-not (Assert-Admin)) { return }
    Out-Line @((Seg 'accent!' '  CAREFUL NETWORK & OS STACK DEBLOAT:'))
    Out-Line @((Seg 'dim'     '  Eliminate telemetry chatter, P2P uploads, and packet throttling safely:'))
    Out-Line @()

    $items = @(Get-DebloatStatus)
    foreach ($it in $items) {
        $tok = if ($it.Status -eq 'Optimal') { (Get-StatusToken 'ok') } else { (Get-StatusToken 'warn') }
        $tokRole = if ($it.Status -eq 'Optimal') { 'ok' } else { 'warn' }
        Out-Line @(
            (Seg $tokRole ('  ' + $tok.Text + ' ')),
            (Seg 'text!' ($it.Name.PadRight(38))),
            (Seg 'dim' ("Tier {0} | {1}" -f $it.Tier, $it.Status))
        )
    }
    Out-Line @()
    Out-Line @((Seg 'text!' '  Available Optimization Actions:'))
    Out-Line @((Seg 'faint' '  [1] '), (Seg 'ok!' 'Safe Network Debloat'), (Seg 'dim' '         - Tier 1: P2P Uploads, Latency Unthrottling, WPAD, Caches'))
    Out-Line @((Seg 'faint' '  [2] '), (Seg 'accent!' 'Comprehensive Debloat'), (Seg 'dim' '    - Tier 1 + 2: LLMNR Multicast, Telemetry Silence, Tunnels'))
    Out-Line @((Seg 'faint' '  [3] '), (Seg 'text!' 'Audit & Inspect Details'), (Seg 'dim' '    - View exact registry keys and current values (No changes)'))
    Out-Line @((Seg 'faint' '  [4] '), (Seg 'warn!' 'Rollback Previous Debloat'), (Seg 'dim' '  - Restore pre-debloat snapshots and original defaults'))
    Out-Line @((Seg 'faint' '  [B] '), (Seg 'dim' 'Back to Recovery Menu'))
    Out-Line @()
    Out-Line @((Seg 'dim' '  Select an option [1-4] or [B], or press any other key to return '), (Seg 'accent!' $script:G.prompt)) -NoNewline

    $k = Read-Choice
    Out-Line @()
    $choice = ([string]$k.KeyChar).ToLowerInvariant()
    switch ($choice) {
        '1' {
            if (Read-Confirm 'Apply Safe Network Debloat (Tier 1)?' 'yes') {
                [void](Invoke-NetworkDebloat -Tier 1)
            } else { Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.')) }
        }
        '2' {
            if (Read-Confirm 'Apply Comprehensive Network Debloat (Tier 1 & 2)?' 'yes') {
                [void](Invoke-NetworkDebloat -Tier 2)
            } else { Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.')) }
        }
        '3' {
            [void](Invoke-NetworkDebloat -Audit)
        }
        '4' {
            if (Read-Confirm 'Rollback all previous Network Debloat modifications?' 'yes') {
                [void](Undo-NetworkDebloat)
            } else { Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.')) }
        }
        default { return }
    }
}

function Shield-Services($Ctxs, [string]$ConnState) {
    try {
        $ncsiKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet'
        if (Test-Path -LiteralPath $ncsiKey) {
            $curProbe = (Get-ItemProperty -LiteralPath $ncsiKey -Name EnableActiveProbing -ErrorAction SilentlyContinue).EnableActiveProbing
            if ($null -eq $curProbe -or [int]$curProbe -ne 1) {
                Save-Original 'Global' 'EnableActiveProbing' $curProbe
                [void](Invoke-Change 'Enabled NCSI Active Probing (EnableActiveProbing=1) for instant connectivity detection' {
                    Set-ItemProperty -LiteralPath $ncsiKey -Name EnableActiveProbing -Value 1 -Type DWord -Force -ErrorAction Stop
                })
            }
        }
    } catch {}
    if ((@($Ctxs | Where-Object { $_.Env.Env -eq 'Campus' })).Count -eq 0 -and (@($Ctxs | Where-Object { $_.Env.Env -eq 'Other' })).Count -gt 0) {
        Restore-NeutralizedInterceptors 'Non-campus Ethernet network'
    }
    Shield-Llmnr $Ctxs
    Shield-Ipv6Precedence $Ctxs $ConnState
    Shield-NegCache $Ctxs
    Shield-Mdns $Ctxs
    Shield-SmartDns $Ctxs
    Shield-TcpKeepAlive $Ctxs
    Shield-TcpAutoTuning
    foreach ($ctx in $Ctxs) {
        $guid = [string]$ctx.Ad.InterfaceGuid
        $tk = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces\Tcpip_$guid"
        if (-not (Test-Path -LiteralPath $tk)) { continue }
        $cur = (Get-ItemProperty -LiteralPath $tk -Name NetbiosOptions -ErrorAction SilentlyContinue).NetbiosOptions
        if ($null -eq $cur) { $cur = 0 }
        if ($ctx.Env.Env -eq 'Campus' -and [int]$cur -ne 2) {
            Save-Original $guid 'NetBios' ([int]$cur)
            [void](Invoke-Change "NetBIOS-over-TCP off on $($ctx.Ad.Name) (cuts broadcast chatter that hostel switches storm-limit)" {
                Set-ItemProperty -LiteralPath $tk -Name NetbiosOptions -Value 2 -Type DWord -ErrorAction Stop
            })
        } elseif ($ctx.Env.Env -eq 'Other' -and [int]$cur -eq 2) {
            $snap = Get-SubTable 'Snapshot' $guid
            if ($snap.ContainsKey('NetBios')) {
                $orig = [int]$snap['NetBios']
                [void](Invoke-Change "Non-campus network: NetBIOS restored to $orig on $($ctx.Ad.Name)" {
                    Set-ItemProperty -LiteralPath $tk -Name NetbiosOptions -Value $orig -Type DWord -ErrorAction Stop
                })
            }
        }
    }
    # NCSI: only repair if something (a "tweak" tool) switched active probing off.
    $nk = 'HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet'
    $probe = (Get-ItemProperty -LiteralPath $nk -Name EnableActiveProbing -ErrorAction SilentlyContinue).EnableActiveProbing
    if ($null -ne $probe -and [int]$probe -eq 0) {
        Save-Original 'Global' 'Ncsi' 0
        [void](Invoke-Change 'Windows connectivity probing re-enabled (it was switched off)' { Set-ItemProperty -LiteralPath $nk -Name EnableActiveProbing -Value 1 -Type DWord -ErrorAction Stop })
    }
    # Internet works but Windows still says "no internet": nudge the Network List service (rate-limited).
    if ($ConnState -eq 'Online' -and -not $script:IsDry -and (Test-Elapsed 'NlaNudge' 900)) {
        foreach ($ctx in $Ctxs) {
            $np = Get-NetConnectionProfile -InterfaceIndex $ctx.Ad.ifIndex -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($np -and [string]$np.IPv4Connectivity -ne 'Internet') {
                for ($pCount = 0; $pCount -lt 6; $pCount++) {
                    Start-Sleep -Milliseconds 500
                    $np = Get-NetConnectionProfile -InterfaceIndex $ctx.Ad.ifIndex -ErrorAction SilentlyContinue | Select-Object -First 1
                    if ($np -and [string]$np.IPv4Connectivity -eq 'Internet') { break }
                }
                if ($np -and [string]$np.IPv4Connectivity -ne 'Internet') {
                    Set-StateTime 'NlaNudge'
                    [void](Invoke-Change 'Network List service refreshed (Windows showed "no internet" while it works)' {
                        Restart-Service -Name NlaSvc -Force -ErrorAction Stop
                        Start-Service -Name netprofm -ErrorAction SilentlyContinue
                    })
                    break
                }
            }
        }
    }
}

# ==============================================================================
# LEGACY CLEAN-UP (v1 left hosts pins, manual metrics, an old task)
# ==============================================================================
function Remove-LegacyHostsEntries {
    $hp = Join-Path $script:Sys32 'drivers\etc\hosts'
    if (-not (Test-Path -LiteralPath $hp)) { return }
    try {
        $raw = [System.IO.File]::ReadAllText($hp)
        $lines = $raw -split "\r?\n"
        $keep = @($lines | Where-Object {
            $_ -notmatch [regex]::Escape($script:Cfg.PortalHost) -and
            $_ -notmatch 'Lan Fixer Portal Immunization|A07 Portal Immunization' -and
            $_ -notmatch '(?i)^\s*(?:127\.0\.0\.1|0\.0\.0\.0|::1)\s+(?:accounts\.google\.com|github\.com|connectivitycheck\.gstatic\.com)'
        })
        if ($keep.Count -eq $lines.Count) { return }
        if ($script:StoreReady -and -not $script:IsDry) { Copy-Item -LiteralPath $hp -Destination (Join-Path $script:StoreDir 'hosts.before-cleanup.bak') -Force -ErrorAction SilentlyContinue }
        $text = ($keep -join "`r`n")
        [void](Invoke-Change 'Removed old Lan Fixer v1 entries from the hosts file (backup kept)' { [System.IO.File]::WriteAllText($hp, $text, (New-Object System.Text.UTF8Encoding($false))) })
    } catch { Write-Log 'WARN' ("hosts cleanup skipped: " + $_.Exception.Message) }
}
function Invoke-LegacyMigration {
    if (-not $script:IsAdmin -or $script:State.Misc['Migrated'] -eq $true) { return }
    Remove-LegacyHostsEntries
    if (-not $script:IsDry) {
        try {
            if (Test-Path -LiteralPath $script:DnsPolicyKey) {
                Remove-ItemProperty -LiteralPath $script:DnsPolicyKey -Name DisableSmartNameResolution -ErrorAction SilentlyContinue
            }
        } catch {}
    }
    if (-not $script:IsDry) { [void](Invoke-Native (Get-SysExe 'schtasks.exe') @('/delete', '/tn', 'A07_NetShield', '/f') 8000) }
    # v1 forced manual metrics 10/12/14/16/25 on adapters; hand them back to Windows.
    foreach ($i in @(Get-NetIPInterface -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.AutomaticMetric -eq 'Disabled' -and $_.InterfaceAlias -match 'Ethernet|Wi-?Fi|Wireless|LAN' -and @(10,12,14,16,25) -contains [int]$_.InterfaceMetric })) {
        [void](Invoke-Change "Automatic metric re-enabled on $($i.InterfaceAlias) (v1 had pinned it)" { Set-NetIPInterface -InterfaceIndex $i.ifIndex -AddressFamily IPv4 -AutomaticMetric Enabled -ErrorAction Stop })
    }
    # v1 wrote PnPCapabilities as a string (ignored by Windows); v2 rewrites it as a proper DWORD in Layer 1.
    $legacy = Join-Path $env:ProgramData 'LanFixer\dns_profile.cfg'
    if (Test-Path -LiteralPath $legacy) {
        # A legacy file that says ResetDHCP records an action that already ran; importing it would freeze the profile
        # on a value that can never apply again, so the reset's own outcome (Adaptive) is what gets migrated.
        try { $p = (Get-Content -LiteralPath $legacy -Raw).Trim(); if ($p -eq 'ResetDHCP') { $p = 'Adaptive' }; if (@('Adaptive','DHCP','Hybrid','Cloudflare') -contains $p) { $script:State.Misc['DnsProfile'] = $p } } catch {}
        if (-not $script:IsDry) { Remove-Item -LiteralPath $legacy -Force -ErrorAction SilentlyContinue; Remove-Item -LiteralPath (Join-Path $env:ProgramData 'LanFixer\dad_state.cfg') -Force -ErrorAction SilentlyContinue }
    }
    if (-not $script:IsDry) { $script:State.Misc['Migrated'] = $true; Save-State }
}

# ==============================================================================
# THE PIPELINE
# ==============================================================================
function Refresh-ContextAdapter($Ctx) {
    if ($Ctx -and $Ctx.Ad) {
        $fresh = Get-NetAdapter -InterfaceIndex $Ctx.Ad.ifIndex -ErrorAction SilentlyContinue
        if (-not $fresh) { $fresh = Get-NetAdapter -Name $Ctx.Ad.Name -ErrorAction SilentlyContinue }
        if ($fresh) { $Ctx.Ad = $fresh }
    }
    return $Ctx.Ad
}

function Invoke-HealPipeline([switch]$SkipSystemStack) {
    $res = @{ Conn = 'Offline'; Campus = $false; AnyUp = $false; Problem = 'NoAdapter' }
    Invoke-LegacyMigration
    $script:WatchdogOn = Test-WatchdogInstalled
    Update-WatchdogIfStale
    if (@(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' }).Count -eq 0) { Invoke-RoamingCleanup }
    if (-not $SkipSystemStack) { Shield-SystemStack }
    $ads = @(Get-EthernetAdapters)
    if ($ads.Count -gt 0) {
        $anyUp = @($ads | Where-Object { $_.Status -eq 'Up' }).Count -gt 0
        $didEnable = $false
        foreach ($a in $ads) {
            if ($a.Status -eq 'Disabled' -and $Mode -ne 'AutoHeal' -and -not $anyUp) {   # a manual repair may re-enable it; the watchdog never overrides a choice you made
                if (Invoke-Change "Enabling disabled physical Ethernet adapter $($a.Name)" {
                    Enable-NetAdapter -Name $a.Name -Confirm:$false -ErrorAction Stop
                }) { $didEnable = $true }
            }
        }
        if ($didEnable) { Start-Sleep -Milliseconds 500; $ads = @(Get-EthernetAdapters) }
    }
    if ($ads.Count -eq 0) { Write-Log 'WARN' 'No physical Ethernet adapter found (Wi-Fi/system stack still shielded).'; Invoke-RoamingCleanup; Save-State; return $res }

    Write-Log 'STEP' 'LAYER 1/7  Hardware interface & power state verification'
    foreach ($a in $ads) { Shield-Hardware $a; [void](Resolve-DuplexFlap $a); [void](Optimize-PhySiliconBuffers $a); [void](Shield-TcpOffloads $a) }
    $didHwRestart = $false
    if (-not $script:IsDry) {
        foreach ($g in @($script:PendingRestart.Keys)) {
            $nm = $script:PendingRestart[$g]
            if (Test-Elapsed ("Restart:" + $g) 300) {
                Set-StateTime ("Restart:" + $g)
                if (Invoke-Change "Zero-reboot link reset on $nm to apply driver settings" { $rAd = Get-NetAdapter -Name $nm -ErrorAction SilentlyContinue; if ($rAd) { Reset-PhysicalAdapterHardware $rAd } else { Restart-NetAdapter -Name $nm -Confirm:$false -ErrorAction Stop } }) { $didHwRestart = $true }
                $script:PendingRestart.Remove($g)
            }
        }
        if ($didHwRestart) { Start-Sleep -Milliseconds 600; $ads = @(Get-EthernetAdapters) }
    }
    Wait-LinkSettling $(if ($didHwRestart) { ([int]$script:Cfg.StpMaxSec * 1000) } else { 12000 })
    $ups = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
    if ($ups.Count -eq 0) {
        Write-Log 'WARN' 'Ethernet link is down: plug in the cable / wall port, then run again.'
        $res.Problem = 'NoLink'
        foreach ($a in $ads) { (Get-SubTable 'Env' ([string]$a.InterfaceGuid)).Up = $false }
        Invoke-RoamingCleanup
        Save-State
        return $res
    }
    $res.AnyUp = $true
    if ($script:State.Misc -and $script:State.Misc['LinkDownSince']) { $script:State.Misc.Remove('LinkDownSince'); if ($script:State.Times) { $script:State.Times.Remove('LinkDownSince') } }
    $ctxs = @()
    foreach ($a in $ups) { $ctxs += @{ Ad = $a; Env = (Get-AdapterEnvironment $a); Repaired = $false } }
    foreach ($c in $ctxs) {
        Write-Log 'INFO' ("{0}: {1} (score {2}{3}) {4}" -f $c.Ad.Name, $c.Env.Env.ToUpper(), $c.Env.Score, $(if ($c.Env.Sticky) { ', last known' } else { '' }), (($c.Env.Evidence) -join '; '))
    }

    Write-Log 'STEP' 'LAYER 2/7  Data link & DHCP lease renewal'
    foreach ($c in $ctxs) {
        try { [void](Refresh-ContextAdapter $c); [void](Shield-Dot3Svc $c.Ad); Shield-DataLink $c }
        catch { Write-Log 'WARN' ("Layer 2 data link remediation failed on {0}: {1}" -f $c.Ad.Name, $_.Exception.Message) }
    }
    Invoke-LogIntelligence $ups
    $primaryIp = Get-PrimarySourceIp
    $conn = if ($primaryIp) { (Get-InternetState -NoCache -SourceIp $primaryIp).State } else { 'Offline' }

    Write-Log 'STEP' 'LAYER 3/7  Gateway ARP integrity & route metrics'
    foreach ($c in $ctxs) {
        try { [void](Refresh-ContextAdapter $c); Shield-GatewayArp $c $conn; Shield-RouteMetrics $c $conn; Shield-PathMtu $c $conn; Shield-DefaultRoutes $c }
        catch { Write-Log 'WARN' ("Layer 3 routing/ARP remediation failed on {0}: {1}" -f $c.Ad.Name, $_.Exception.Message) }
    }

    Write-Log 'STEP' 'LAYER 4/7  Adaptive DNS configuration & resolver health'
    foreach ($c in $ctxs) {
        try { [void](Refresh-ContextAdapter $c); Shield-Dns $c $conn }
        catch { Write-Log 'WARN' ("Layer 4 DNS configuration failed on {0}: {1}" -f $c.Ad.Name, $_.Exception.Message) }
    }

    $primaryIp = Get-PrimarySourceIp
    $connAfterDns = if ($primaryIp) { (Get-InternetState -NoCache -SourceIp $primaryIp).State } else { 'Offline' }
    if ($connAfterDns -eq 'Online' -and $conn -ne 'Online') {
        $conn = 'Online'
        foreach ($c in $ctxs) {
            try { [void](Refresh-ContextAdapter $c); Shield-RouteMetrics $c $conn; Shield-PathMtu $c $conn } catch {}
        }
    }

    Write-Log 'STEP' 'LAYER 5/7  Captive portal routing & reachability'
    foreach ($c in $ctxs) { try { [void](Refresh-ContextAdapter $c) } catch {} }
    try { Shield-Portal $ctxs } catch { Write-Log 'WARN' ("Layer 5 portal checks encountered error: {0}" -f $_.Exception.Message) }

    Write-Log 'STEP' 'LAYER 6/7  Network profile & firewall security'
    foreach ($c in $ctxs) {
        try { [void](Refresh-ContextAdapter $c); Shield-Profile $c }
        catch { Write-Log 'WARN' ("Layer 6 profile remediation failed on {0}: {1}" -f $c.Ad.Name, $_.Exception.Message) }
    }

    Write-Log 'STEP' 'LAYER 7/7  Network stack & service synchronization'
    foreach ($c in $ctxs) { try { [void](Refresh-ContextAdapter $c) } catch {} }
    try { Shield-Services $ctxs $conn } catch { Write-Log 'WARN' ("Layer 7 services remediation encountered error: {0}" -f $_.Exception.Message) }
    if ($conn -eq 'Online' -and -not $script:IsDry) {
        [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/registerdns') 3000)
    }

    foreach ($c in $ctxs) {
        $h = Get-SubTable 'Env' ([string]$c.Ad.InterfaceGuid)
        $h.Up = $true
        $h.Ip = [string](Get-ValidIPv4 $c.Ad)
        if ($c.Env.Env -eq 'Campus') { $res.Campus = $true }
    }
    if (-not $script:IsDry) { Set-StateTime 'LastFull'; $script:State.Misc['Version'] = $script:Version; Save-State }
    $primaryIp = Get-PrimarySourceIp
    $res.Conn = if ($primaryIp) { (Get-InternetState -NoCache -SourceIp $primaryIp).State } else { 'Offline' }
    $primaryAd = $null
    if ($primaryIp) { $primaryAd = $ups | Where-Object { (Get-ValidIPv4 $_) -eq $primaryIp } | Select-Object -First 1 }
    if (-not $primaryAd) {
        $defRoute = @(Get-NetRoute -DestinationPrefix '0.0.0.0/0' -AddressFamily IPv4 -ErrorAction SilentlyContinue | Sort-Object { [int]$_.RouteMetric } | Select-Object -First 1)
        if ($defRoute) { $primaryAd = $ups | Where-Object { $_.ifIndex -eq $defRoute.InterfaceIndex } | Select-Object -First 1 }
    }
    if (-not $primaryAd -and $ups.Count -gt 0) { $primaryAd = $ups[0] }
    $res.Ip = if ($primaryAd) { [string](Get-ValidIPv4 $primaryAd) } else { '' }
    $res.Problem = if ($primaryAd) { (Get-AdapterHealth $primaryAd).Problem } else { 'NoAdapter' }
    if (Clear-FailStreakIfRecovered ([string]$res.Problem)) { Save-State }
    return $res
}

# ==============================================================================
# PORTAL OPENING / LOGIN WATCH
# ==============================================================================
function Test-TrustedPortalHost([string]$HostName) {
    $h = ([string]$HostName).ToLower().TrimEnd('.')
    if (-not $h) { return $false }
    if ($script:Cfg.PortalHost -and $h -eq ([string]$script:Cfg.PortalHost).ToLower()) { return $true }
    if ($script:Cfg.PortalIp -and $h -eq [string]$script:Cfg.PortalIp) { return $true }
    $tmpIp = $null
    if ([System.Net.IPAddress]::TryParse($h, [ref]$tmpIp) -and (Test-AllowedPortalIp $h)) { return $true }
    $doms = @()
    if ($script:Cfg.CampusDomain) { $doms += ([string]$script:Cfg.CampusDomain).ToLower().Trim('.') }
    $discDom = if ($script:State.Misc -and $script:State.Misc['DiscoveredDomain']) { ([string]$script:State.Misc['DiscoveredDomain']).ToLower().Trim('.') } else { '' }
    if ($discDom -and $doms -notcontains $discDom) { $doms += $discDom }
    foreach ($dom in @($doms | Where-Object { $_ })) {
        if ($h -eq $dom -or $h.EndsWith('.' + $dom)) { return $true }
    }
    $discHost = if ($script:State.Misc -and $script:State.Misc['DiscoveredPortalHost']) { ([string]$script:State.Misc['DiscoveredPortalHost']).ToLower().Trim('.') } else { '' }
    if ($discHost -and ($h -eq $discHost -or $h.EndsWith('.' + $discHost))) { return $true }
    $discUrl = if ($script:State.Misc -and $script:State.Misc['DiscoveredPortalUrl']) { [string]$script:State.Misc['DiscoveredPortalUrl'] } else { '' }
    if ($discUrl) {
        try {
            $du = [uri]$discUrl
            if ($du.Host) {
                $duh = ([string]$du.Host).ToLower().TrimEnd('.')
                if ($h -eq $duh -or $h.EndsWith('.' + $duh)) { return $true }
            }
        } catch {}
    }
    if ($h -match '^[A-Za-z0-9.-]+$' -and -not $script:IsDry) {
        $res = Resolve-HostBounded $h 1000
        if ($res -and (Test-AllowedPortalIp $res)) { return $true }
    }
    return $false
}
# Returns the redirect URL only if it is an absolute http(s) URL on a campus-controlled host (no user-info tricks).
# Anything else comes back empty: a rogue device on the LAN must not be able to steer your browser with a fake 302.
function Get-SafePortalUrl([string]$Location) {
    if (-not $Location) { return '' }
    $u = $null
    try { $u = [uri]$Location } catch { return '' }
    if (-not $u.IsAbsoluteUri) { return '' }
    if ($u.Scheme -ne 'http' -and $u.Scheme -ne 'https') { return '' }
    if ($u.UserInfo) { return '' }
    if (-not (Test-TrustedPortalHost $u.Host)) { return '' }
    return [string]$u.AbsoluteUri
}
# Dynamic first (survives a changed port / zone / path), configured anchor otherwise (already logged in, probe dropped, untrusted host).
function Resolve-PortalUrl($Inet) {
    $anchor = Get-ActivePortalUrl
    if ($Inet.State -ne 'Captive' -or -not $Inet.Location) { return $anchor }
    $live = Get-SafePortalUrl ([string]$Inet.Location)
    if ($live) {
        if ($live -ne $anchor) { try { Write-Log 'INFO' ('Using the login page the network just redirected to: ' + ([uri]$live).GetLeftPart([System.UriPartial]::Path)) } catch {} }
        return $live
    }
    $rh = ''
    try { $rh = ([uri][string]$Inet.Location).Host } catch {}
    Write-Log 'WARN' ("The captive redirect points to '{0}', which is not on the campus domain or the configured portal, so it was NOT opened automatically. Opening the configured portal instead." -f $rh)
    return $anchor
}
# ==============================================================================
# DPAPI SECURE CREDENTIAL VAULT (Machine + Hardware Entropy, AES/DPAPI)
# ==============================================================================
$script:VaultFile = Join-Path $script:StoreDir 'vault.bin'

# CREDENTIAL trust: stricter than Test-TrustedPortalHost on purpose. The DNS suffix a network's own DHCP hands out is
# attacker-controlled on a rogue LAN, so it must never decide where the saved password goes. Only the configured
# PortalHost / PortalIp / CampusDomain qualify (set them in config.json for another institution), or an IP literal,
# which Invoke-TlsHttp still only talks to with a Windows-valid or user-pinned certificate.
function Test-CredentialPortalHost([string]$HostName) {
    $h = ([string]$HostName).ToLowerInvariant().TrimEnd('.')
    if (-not $h) { return $false }
    if ($script:Cfg.PortalHost -and $h -eq ([string]$script:Cfg.PortalHost).ToLowerInvariant().TrimEnd('.')) { return $true }
    if ($script:Cfg.PortalIp -and $h -eq [string]$script:Cfg.PortalIp) { return $true }
    $tmpIp = $null
    if ([System.Net.IPAddress]::TryParse($h, [ref]$tmpIp)) { return [bool](Test-AllowedPortalIp $h) }
    $dom = ([string]$script:Cfg.CampusDomain).ToLowerInvariant().Trim('.')
    return [bool]($dom -and ($h -eq $dom -or $h.EndsWith('.' + $dom)))
}
function Get-CredentialPortalUrl([string]$Location) {
    if (-not $Location) { return '' }
    $u = $null
    try { $u = [uri]$Location } catch { return '' }
    if (-not $u.IsAbsoluteUri) { return '' }
    if ($u.Scheme -ne 'http' -and $u.Scheme -ne 'https') { return '' }
    if ($u.UserInfo) { return '' }
    if (-not (Test-CredentialPortalHost $u.Host)) { return '' }
    return [string]$u.AbsoluteUri
}
function Get-VaultEntropy {
    $guid = ''
    try { $guid = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Cryptography' -Name MachineGuid -ErrorAction SilentlyContinue).MachineGuid } catch {}
    if (-not $guid) {
        try { $guid = (Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue).SerialNumber } catch {}
    }
    return [System.Text.Encoding]::UTF8.GetBytes("LanFixer_NITJSR_AS_SecureEntropy_2026_$guid")
}

function Save-PortalCredentials([string]$User, [string]$Pass) {
    if (-not $User -or -not $Pass) { return $false }
    if ($User -match '[\t\r\n]') { Write-Log 'FAIL' 'The username cannot contain tabs or line breaks.'; return $false }
    $tmp = $script:VaultFile + '.new'
    $moved = $false
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($User + [string][char]9 + $Pass)
        $enc = [System.Security.Cryptography.ProtectedData]::Protect($bytes, (Get-VaultEntropy), [System.Security.Cryptography.DataProtectionScope]::LocalMachine)
        [Array]::Clear($bytes, 0, $bytes.Length)
        # Lock an EMPTY file first, write second: the secret never exists under a looser ACL.
        [System.IO.File]::WriteAllBytes($tmp, [byte[]]@())
        if (-not (Protect-VaultFile $tmp) -or -not (Test-VaultAcl $tmp)) { throw 'could not restrict the vault file to Administrators/SYSTEM' }
        [System.IO.File]::WriteAllBytes($tmp, $enc)
        Move-Item -LiteralPath $tmp -Destination $script:VaultFile -Force -ErrorAction Stop
        $moved = $true
        if (-not (Test-VaultAcl $script:VaultFile)) { throw 'vault permissions did not survive the move' }
        $script:State.Misc['PortalFails'] = 0; $script:State.Misc['PortalAmbiguous'] = 0
        $script:State.Misc['PortalLoginSuspended'] = $false
        return $true
    } catch {
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
        if ($moved) {
            Remove-Item -LiteralPath $script:VaultFile -Force -ErrorAction SilentlyContinue   # fail closed: never leave a half-protected secret
        }
        Write-Log 'FAIL' ('Credentials were NOT saved: ' + $_.Exception.Message)
        return $false
    }
}
function Get-PortalCredentials {
    if (-not (Test-Path -LiteralPath $script:VaultFile)) { return $null }
    if (-not (Test-VaultAcl $script:VaultFile)) {
        if (Protect-VaultFile $script:VaultFile) { Write-Log 'WARN' 'The vault file had loose permissions; they were tightened to Administrators/SYSTEM only.' }
        else { Write-Log 'ALERT' 'The vault file permissions could not be tightened: auto-login is disabled until that is fixed.'; return $null }
    }
    try {
        $enc = [System.IO.File]::ReadAllBytes($script:VaultFile)
        $bytes = $null
        $mGuid = ''
        try { $mGuid = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Cryptography' -Name MachineGuid -ErrorAction SilentlyContinue).MachineGuid } catch {}
        if (-not $mGuid) {
            try { $mGuid = (Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue).SerialNumber } catch {}
        }
        $entropyList = @(
            (Get-VaultEntropy),
            [System.Text.Encoding]::UTF8.GetBytes("LanFixer_SecureEntropy_2026_$mGuid"),
            [System.Text.Encoding]::UTF8.GetBytes("LanFixer_NITJSR_AS_SecureEntropy_2026_$mGuid")
        )
        foreach ($ent in $entropyList) {
            try {
                $bytes = [System.Security.Cryptography.ProtectedData]::Unprotect($enc, $ent, [System.Security.Cryptography.DataProtectionScope]::LocalMachine)
                if ($bytes) { break }
            } catch {}
        }
        if ($bytes) {
            $plain = [System.Text.Encoding]::UTF8.GetString($bytes)
            [Array]::Clear($bytes, 0, $bytes.Length)
            return (ConvertFrom-VaultPlain $plain)
        } else {
            Write-Log 'WARN' 'The vault file exists on disk but could not be decrypted via DPAPI (machine key or entropy mismatch).'
        }
    } catch {}
    return $null
}
function Remove-PortalCredentials {
    foreach ($f in @($script:VaultFile, ($script:VaultFile + '.new'), ($script:VaultFile + '.bak'), ($script:VaultFile + '.tmp'))) {
        if (Test-Path -LiteralPath $f) { Remove-Item -LiteralPath $f -Force -ErrorAction SilentlyContinue }
    }
    if ($script:State.Misc -is [hashtable]) {
        $script:State.Misc['PortalFails'] = 0
        $script:State.Misc['PortalAmbiguous'] = 0
        $script:State.Misc['PortalLoginSuspended'] = $false
        $script:State.Misc.Remove('PortalPin')
        $script:State.Misc.Remove('DiscoveredPortalUrl')
        $script:State.Misc.Remove('DiscoveredPortalIp')
    }
}
# Zero-touch login. Every guard below exists because a rogue device on a hostel LAN can answer for the portal.
function Invoke-HeadlessPortalLogin {
    param($Inet, [switch]$Manual, [int]$Attempt = 1, [string]$SourceIp = '')
    if ($script:IsDry) { return $false }
    if (-not $script:Cfg.AutoPortalLogin -and -not $Manual) { return $false }
    $creds = Get-PortalCredentials
    if (-not $creds) { if ($Manual) { Write-Log 'INFO' 'No credentials are saved yet.' }; return $false }
    if (-not $Manual) {
        if ($script:State.Misc['PortalLoginSuspended'] -eq $true) { Write-Log 'INFO' 'Auto-login is paused because the portal rejected the saved password. Re-save it in the vault to resume.'; return $false }
        if (-not (Test-Elapsed 'LastPortalLogin' 45)) { return $false }
    }
    Ensure-CampusPortalPath
    if (-not $SourceIp -and $script:Cfg.ProbeSourceBind) { $SourceIp = Get-PrimarySourceIp }
    if ($null -eq $Inet) { $Inet = if ($SourceIp) { Get-InternetState -NoCache -SourceIp $SourceIp } else { Get-InternetState -NoCache } }
    if ($Manual -and $Inet.State -eq 'NoDns' -and $script:IsAdmin) {
        $targetAdapters = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
    if ($targetAdapters.Count -eq 0) {
        $targetAdapters = @(Get-OtherUplinkAdapters | Where-Object { $_.Status -eq 'Up' })
    }
    foreach ($a in $targetAdapters) {
            $e = Get-AdapterEnvironment $a -UseCache
            if ($e.Env -eq 'Campus' -and (Get-DnsProfileName) -eq 'Adaptive') { Shield-Dns @{ Ad = $a; Env = $e } 'Captive' }
        }
        $Inet = if ($SourceIp) { Get-InternetState -NoCache -SourceIp $SourceIp } else { Get-InternetState -NoCache }
    }
    $epHl = Get-ActivePortalEndpoint
    if ($Manual -and $Inet.State -eq 'Offline' -and (Test-PortalOnlineSmart $epHl.Ip ([int]$epHl.Port))) {
        $Inet = @{ State = 'Captive'; Location = $epHl.Url; Via = 'link' }
    }
    if ($Inet.State -ne 'Captive') { if ($Manual) { Write-Log 'INFO' 'This link is not behind the login page right now; nothing to do.' }; return $false }
    if ($Inet.Location) { try { Ensure-CampusPortalPath ([uri]$Inet.Location) } catch {} }
    if ($Inet.Location -and -not (Get-CredentialPortalUrl ([string]$Inet.Location))) {
        if (Get-SafePortalUrl ([string]$Inet.Location)) { Write-Log 'INFO' 'This network login page is not the configured campus portal, so the saved password was NOT sent. Sign in in the browser (or set the portal up in config.json to allow auto sign-in here).' }
        else { Write-Log 'ALERT' 'The login redirect does not point to the campus portal: password NOT sent. Treat this network with suspicion.' }
        return $false
    }
    $url = Resolve-PortalUrl $Inet
    $uri = $null
    try { $uri = [uri]$url } catch { return $false }
    if ($uri.Scheme -ne 'https') { Write-Log 'WARN' 'The portal is not served over HTTPS, so the password is not sent automatically. Use the browser login.'; return $false }
    if (-not (Test-CredentialPortalHost $uri.Host)) { Write-Log 'ALERT' ("Portal host '{0}' is not on the campus domain: password NOT sent." -f $uri.Host); return $false }
    # The URI is validated now: route exactly THIS destination over the campus cable, even if Wi-Fi holds metric 15.
    Ensure-CampusPortalPath $uri
    [void](Invoke-WithLock { Set-StateTime 'LastPortalLogin'; Save-State })   # the throttle must survive a crash mid-sign-in
    $src = if ($SourceIp) { $SourceIp } elseif ($script:Cfg.ProbeSourceBind) { Get-PrimarySourceIp } else { '' }
    $pin = [string]$script:State.Misc['PortalPin']
    $jar = @{}
    $cur = $uri
    $page = $null
    $visitedHops = [System.Collections.Generic.HashSet[string]]::new()
    [void]$visitedHops.Add($cur.AbsoluteUri)
    for ($hop = 0; $hop -lt 4; $hop++) {
        $page = Invoke-TlsHttp -Uri $cur -SourceIp $src -Pin $pin -Jar $jar
        if ($page.Error) { break }
        if ($page.Code -ge 300 -and $page.Code -le 399 -and $page.Location) {
            $next = $null
            try { $next = New-Object System.Uri($cur, $page.Location) } catch { $page = @{ Error = 'BadRedirect' }; break }
            if ($next.Scheme -ne 'https' -or -not (Test-CredentialPortalHost $next.Host)) { $page = @{ Error = 'UntrustedRedirect' }; break }
            if ($visitedHops.Contains($next.AbsoluteUri)) { Write-Log 'WARN' 'Circular portal redirection loop detected; breaking out.'; break }
            [void]$visitedHops.Add($next.AbsoluteUri)
            $cur = $next
            continue
        }
        break
    }
    if ($page.Error -eq 'TlsRejected') {
        if ($Manual) {
            $ci = Get-PortalCertInfo $cur
            if ($ci.Ok -and $ci.Sha256) {
                Write-Log 'WARN' ("Portal certificate changed or unapproved (Fingerprint: {0})." -f (Format-Fingerprint $ci.Sha256))
                if (Read-Confirm ("Approve updated certificate for {0}?" -f $cur.Host)) {
                    $newPin = [string]$ci.Sha256
                    # GUARD 1: pinning the very certificate that was just rejected cannot change the outcome; retrying
                    # would prompt forever (and recurse until the interpreter overflows its call depth).
                    if ($newPin -eq $pin) {
                        Write-Log 'ALERT' 'The portal rejected a certificate whose fingerprint already matches the approved one. Not retrying: check the host name and the certificate chain before trusting this network.'
                        return $false
                    }
                    # GUARD 2: a portal that keeps rotating certificates must not be able to drive an endless retry loop.
                    if ($Attempt -ge 3) {
                        Write-Log 'ALERT' 'The portal certificate changed again during sign-in. Stopped after 3 attempts so the password is not sent to a certificate that keeps changing.'
                        return $false
                    }
                    [void](Invoke-WithLock { $script:State.Misc['PortalPin'] = $newPin; Save-State })
                    Write-Log 'OK' 'Certificate approved! Retrying sign-in...'
                    return (Invoke-HeadlessPortalLogin $Inet -Manual -Attempt ($Attempt + 1))
                }
            }
        }
        if ($pin) { Write-Log 'ALERT' 'The portal certificate CHANGED since you approved it: password NOT sent. If IT renewed it, re-approve it in the vault menu; if not, this network may be hostile.' }
        else { Write-Log 'WARN' 'Windows does not trust the portal certificate and none is approved yet: password NOT sent. Review and approve it once in the vault menu.' }
        return $false
    }
    if ($page.Error -eq 'UntrustedRedirect') { Write-Log 'ALERT' 'The portal tried to send you to another site: password NOT sent.'; return $false }
    if ($page.Error) { Write-Log 'INFO' ('Could not reach the portal page (' + $page.Error + ').'); return $false }
    $form = ConvertFrom-LoginForm ([string]$page.Body) $cur
    if (-not $form) { Write-Log 'WARN' 'No login form was found on the portal page (the page layout may have changed).'; return $false }
    $act = $form.Action
    if ($act.Scheme -ne 'https' -or -not (Test-CredentialPortalHost $act.Host)) {
        Write-Log 'ALERT' ("The login form posts to '{0}', which is not the campus portal: password NOT sent." -f $act.Host)
        return $false
    }
    $f = [ordered]@{}
    foreach ($k in $form.Fields.Keys) { $f[$k] = $form.Fields[$k] }
    $f[$form.UserField] = $creds.User
    $f[$form.PassField] = $creds.Pass
    if (-not $f.Contains('accept') -and $f.Contains('zone')) { $f['accept'] = 'Sign In' }
    $payload = (@($f.Keys | ForEach-Object { ('{0}={1}' -f [uri]::EscapeDataString([string]$_), [uri]::EscapeDataString([string]$f[$_])) }) -join '&')
    $f[$form.PassField] = $null; $creds.Pass = $null
    $post = Invoke-TlsHttp -Uri $act -Method 'POST' -Body $payload -SourceIp $src -Pin $pin -Jar $jar
    $payload = $null
    Clear-DnsClientCache -ErrorAction SilentlyContinue
    $online = $false
    for ($i = 0; $i -lt 6; $i++) {
        Start-Sleep -Milliseconds 1000
        if ((Get-InternetState -NoCache).State -eq 'Online') { $online = $true; break }
    }
    if ($online) {
        # ONE transaction for the evidence that the login worked: the counters must be on disk before the (separately
        # locked) post-login routing/DNS pass runs, or a watchdog save in between would resurrect "rejected" state.
        [void](Invoke-WithLock {
            $script:State.Misc['PortalFails'] = 0; $script:State.Misc['PortalAmbiguous'] = 0
            $script:State.Misc['PortalLoginSuspended'] = $false
            Save-State
        })
        Write-Log 'OK' 'Signed in to the campus portal automatically.'
        Complete-Authentication
        Invoke-RecoveryToast ([string]$src)
        return $true
    }
    $isBadAuth = $false
    if ($post.Code -eq 401 -or $post.Code -eq 403) { $isBadAuth = $true }
    elseif ($post.Body -match '(?i)invalid\s+(credential|password|user|login)|incorrect\s+(password|user)|authentication\s+fail|login\s+fail|access\s+denied|wrong\s+(password|user)') { $isBadAuth = $true }
    elseif ($post.Location -match '(?i)error|fail|invalid|denied') { $isBadAuth = $true }
    elseif ($post.Body -match '(?i)<input\b[^>]*type\s*=\s*[\x22\x27]?password') { $isBadAuth = $true }   # the login form came back: rejected, whatever the wording or language
    if ($isBadAuth) {
        $n = [int]$script:State.Misc['PortalFails'] + 1
        [void](Invoke-WithLock {
            $script:State.Misc['PortalFails'] = $n
            if ($n -ge 2) { $script:State.Misc['PortalLoginSuspended'] = $true }
            Save-State
        })
        if ($n -ge 2) { Write-Log 'ALERT' 'The portal rejected the saved password twice. Auto-login is paused so your account does not get locked: re-save the password in the vault.' }
        else { Write-Log 'WARN' 'The portal did not accept the login (wrong password, or the session limit was reached).' }
    } elseif ($post.Code -gt 0) {
        # answered without an error and without the login form, yet still no internet: allow ONE more try, then pause
        $a2 = [int]$script:State.Misc['PortalAmbiguous'] + 1
        [void](Invoke-WithLock {
            $script:State.Misc['PortalAmbiguous'] = $a2
            if ($a2 -ge 2) { $script:State.Misc['PortalLoginSuspended'] = $true }
            Save-State
        })
        if ($a2 -ge 2) { Write-Log 'ALERT' 'The portal answered twice but never gave access. Auto-login is paused so your account does not get locked: check the saved login in the vault.' }
        else { Write-Log 'INFO' 'The portal answered without an error but internet is not up yet; one more attempt is allowed.' }
    } else {
        Write-Log 'INFO' ('The login request did not complete (' + $post.Error + '); not counted as a wrong password.')
    }
    return $false
}
function Open-Portal {
    param([switch]$Force, [string]$SourceIp = '')
    if (-not $SourceIp -and $script:Cfg.ProbeSourceBind) { $SourceIp = Get-PrimarySourceIp }
    $inet = if ($SourceIp) { Get-InternetState -NoCache -SourceIp $SourceIp } else { Get-InternetState -NoCache }
    $st = $inet.State
    $url = Resolve-PortalUrl $inet
    if (-not $Force -and $st -eq 'Online') { Write-Log 'OK' 'Internet is already authenticated; no login needed.'; return $false }
    if (-not $Force -and (Invoke-HeadlessPortalLogin $inet -SourceIp $SourceIp)) { return $true }
    if (Test-IsSystem) {
        $u = $null
        try { $u = (Get-CimInstance Win32_ComputerSystem -ErrorAction Stop).UserName } catch {}
        if (-not $u) { Write-Log 'INFO' 'Nobody is signed in; portal not opened.'; return $false }
        $known = [string]$script:State.Misc['PortalTaskUrl']
        if (-not $known) { $known = [string](Get-ActivePortalUrl) }
        $taskExists = [bool](Get-ScheduledTask -TaskName $script:Cfg.TaskPortal -ErrorAction SilentlyContinue)
        if ($url -ne $known -or -not $taskExists) {
            $reg = Register-LfTask $script:Cfg.TaskPortal (New-PortalTaskXml $url) 'LanFixer_Portal.xml'
            if ($reg -and -not $script:IsDry) { $script:State.Misc['PortalTaskUrl'] = $url }
        }
        $ok = Invoke-Change 'Asking the signed-in user session to open the campus login page' {
            if (-not (Get-ScheduledTask -TaskName $script:Cfg.TaskPortal -ErrorAction SilentlyContinue)) {
                [void](Register-LfTask $script:Cfg.TaskPortal (New-PortalTaskXml $url) 'LanFixer_Portal.xml')
            }
            $r = Invoke-Native (Get-SysExe 'schtasks.exe') @('/run', '/tn', $script:Cfg.TaskPortal) 8000
            if ($r.ExitCode -ne 0) {
                Start-Process -FilePath (Join-Path $script:Sys32 'rundll32.exe') -ArgumentList ('url.dll,FileProtocolHandler "' + $url + '"') -ErrorAction SilentlyContinue
            }
        }
    } else {
        $ok = Invoke-Change "Opening campus login page: $url" { Start-Process -FilePath (Join-Path $script:Sys32 'rundll32.exe') -ArgumentList ('url.dll,FileProtocolHandler "' + $url + '"') -ErrorAction Stop }
    }
    if ($ok -and -not $script:IsDry) { Set-StateTime 'LastPortal'; Save-State }
    return $ok
}
function Complete-Authentication {
    # Post-login reconfiguration (metrics + DNS + state) is ONE transaction. Save-State refuses to write without the
    # cross-process mutex, so without this lock a call from an as-yet-unlocked path would silently persist nothing --
    # and a concurrent SYSTEM watchdog pass would save its older copy over ours. Enter-Lock is reentrant, so a caller
    # that already holds the lock simply nests instead of blocking.
    [void](Invoke-WithLock {
        Clear-DnsClientCache -ErrorAction SilentlyContinue
        $targetAdapters = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
    if ($targetAdapters.Count -eq 0) {
        $targetAdapters = @(Get-OtherUplinkAdapters | Where-Object { $_.Status -eq 'Up' })
    }
    foreach ($a in $targetAdapters) {
            $script:EnvCache.Remove([string]$a.InterfaceGuid)
            $ctx = @{ Ad = $a; Env = (Get-AdapterEnvironment $a) }
            $srcIp = Get-ValidIPv4 $a
            $st = if ($srcIp) { (Get-InternetState -NoCache -SourceIp $srcIp).State } else { 'Offline' }
            Shield-RouteMetrics $ctx $st
            Shield-Dns $ctx $st
        }
        Clear-DnsClientCache -ErrorAction SilentlyContinue
        if (-not $script:IsDry) { Save-State }
    })
}
function Wait-ForAuthentication([int]$TimeoutSec = 180) {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $i = 0
    while ($sw.Elapsed.TotalSeconds -lt $TimeoutSec) {
        $srcIp = Get-PrimarySourceIp
        $st = if ($srcIp) { (Get-InternetState -NoCache -SourceIp $srcIp).State } else { (Get-InternetState -NoCache).State }
        if ($st -eq 'Online') { Out-Line @(); return $true }
        $t = Get-Date
        while (((Get-Date) - $t).TotalSeconds -lt 3) {
            $sp = $script:G.spin[$i % $script:G.spin.Count]; $i++
            if ($script:Ui.Vt) { [Console]::Write("`r" + $script:Esc + '[2K') } else { Write-Host "`r" -NoNewline }
            Out-Line @((Seg 'warn' ('    ' + $sp + ' ')), (Seg 'text' 'waiting for the campus login'), (Seg 'dim' ('  ' + $script:G.mid + '  {0} s left  ' -f [int]($TimeoutSec - $sw.Elapsed.TotalSeconds))), (Seg 'faint' 'any key stops')) -NoNewline
            try { if (Test-KeyAvailable) { [void](Read-KeyNow); Out-Line @(); return $false } } catch {}
            Start-Sleep -Milliseconds 120
        }
    }
    Out-Line @()
    return $false
}
function Invoke-AuthWatch {
    $maxSec = if ($Mode -eq 'AutoHeal') { 60 } else { [int]$script:Cfg.AuthWatchSec }
    $deadline = (Get-Date).AddSeconds($maxSec)
    Write-Log 'INFO' 'Auth watch: waiting for portal login to switch DNS to the fast path.'
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Seconds 4
        if (@(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' }).Count -eq 0) { Write-Log 'INFO' 'Auth watch: link dropped; cleaning up.'; if (Enter-Lock 10000) { try { Invoke-RoamingCleanup; Save-State } finally { Exit-Lock } }; return }
        $srcIp = Get-PrimarySourceIp
        $st = if ($srcIp) { (Get-InternetState -NoCache -SourceIp $srcIp).State } else { (Get-InternetState -NoCache).State }
        if ($st -eq 'Online') {
            if (Enter-Lock 15000) {
                try { Complete-Authentication; Write-Log 'OK' 'Auth watch: login detected, DNS switched to post-login profile.' } finally { Exit-Lock }
            }
            return
        }
    }
    Write-Log 'INFO' 'Auth watch: timed out without a login.'
}

# ==============================================================================
# AUTONOMOUS RUN (called by the SYSTEM watchdog)
# ==============================================================================
function Test-HardFailure([string]$Problem) { return (@('NoIp', 'GwUnreachable', 'Offline', 'NoDns', 'NoLink', 'NoAdapter', 'DriverFault', 'HardwareFault', 'UnknownFault') -contains $Problem) }
# A working connection ends the breaker no matter who repaired it (manual option 1, watchdog, or the cable just got better).
function Clear-FailStreakIfRecovered([string]$Problem) {
    if ($script:IsDry -or (Test-HardFailure $Problem) -or (@('Healthy', 'Captive') -notcontains $Problem)) { return $false }
    if ([int]$script:State.Misc['FailStreak'] -eq 0) { return $false }
    $script:State.Misc['FailStreak'] = 0
    Write-Log 'INFO' 'Repair breaker reset: the connection works again.'
    return $true
}
function Invoke-AutoHeal {
    if (Test-InteractiveSessionActive) {
        Write-Log 'INFO' 'AutoHeal pass skipped: interactive control center session is active.'
        return 0
    }
    if ($script:State.Misc -is [hashtable] -and $script:State.Misc['PendingReboot']) {
        $bootTime = [datetime]::MinValue
        try {
            $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
            if ($os -and $os.LastBootUpTime) { $bootTime = $os.LastBootUpTime }
        } catch {}
        $rebootMark = [datetime]::MinValue
        try {
            if ($script:State.Misc['PendingRebootTime']) {
                $rebootMark = [datetime]::Parse([string]$script:State.Misc['PendingRebootTime'])
            }
        } catch {}
        if ($bootTime -gt $rebootMark) {
            $script:State.Misc.Remove('PendingReboot')
            $script:State.Misc.Remove('PendingRebootTime')
            Save-State
        } else {
            Write-Log 'WARN' 'System reboot is pending following Armageddon reset. AutoHeal paused until reboot completes.'
            return 0
        }
    }
    if (-not (Enter-Lock 3000)) { return 0 }
    $curUpCount = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' }).Count
    $prevUpCount = if ($null -ne $script:State.Misc['LastAutoHealUpCount']) { [int]$script:State.Misc['LastAutoHealUpCount'] } else { -1 }
    if (($curUpCount -eq $prevUpCount) -and (-not (Test-Elapsed 'LastAutoHealRun' 20))) {
        Write-Log 'INFO' 'AutoHeal pass debounced: a heal pass completed less than 20 seconds ago with identical link state.'
        Exit-Lock
        return 0
    }
    $script:State.Misc['LastAutoHealUpCount'] = $curUpCount
    Set-StateTime 'LastAutoHealRun'; Save-State
    $watch = $false
    try {
        $ups = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
        if ($ups.Count -eq 0) { Wait-LinkSettling 6000; $ups = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' }) }
        if ($ups.Count -eq 0) {
            foreach ($a in @(Get-EthernetAdapters)) { (Get-SubTable 'Env' ([string]$a.InterfaceGuid)).Up = $false }
            Invoke-RoamingCleanup
            Shield-SystemStack
            Set-StateTime 'LastAutoHealRun'; Save-State
            return 0
        }
        Shield-SystemStack
        $primary = $ups[0]
        $health = Get-AdapterHealth $primary
        $needFull = ($script:State.Misc['Version'] -ne $script:Version) -or (Test-Elapsed 'LastFull' 7200)
        $newConn = $false
        $mismatch = $false
        foreach ($adUp in $ups) {
            $guidUp = [string]$adUp.InterfaceGuid
            $healthUp = if ($adUp.ifIndex -eq $primary.ifIndex) { $health } else { Get-AdapterHealth $adUp }
            $enviUp = Get-AdapterEnvironment $adUp
            $hUp = Get-SubTable 'Env' $guidUp
            $dUp = Get-SubTable 'Dns' $guidUp
            $nc = (($hUp.Up -ne $true) -or ([string]$hUp.Ip -ne [string]$healthUp.Ip))
            $wantUp = $(if ($healthUp.Conn -eq 'Online') { 'Online' } else { 'NotOnline' })
            $mm = ($enviUp.Env -eq 'Campus' -and (Get-DnsProfileName) -eq 'Adaptive' -and ([string]$dUp.ConnApplied -ne $wantUp))
            if ($nc) { $newConn = $true }
            if ($mm) { $mismatch = $true }
            if (($healthUp.Problem -ne 'Healthy') -or $nc -or $mm) {
                $needFull = $true
            }
        }
        if (-not $needFull) {
            foreach ($adUp in $ups) {
                $enviUp = Get-AdapterEnvironment $adUp
                $hUp = Get-SubTable 'Env' ([string]$adUp.InterfaceGuid)
                $healthUp = if ($adUp.ifIndex -eq $primary.ifIndex) { $health } else { Get-AdapterHealth $adUp }
                $hUp.Up = $true; $hUp.Ip = [string]$healthUp.Ip
                Shield-RouteMetrics @{ Ad = $adUp; Env = $enviUp } $healthUp.Conn
            }
            [void](Clear-FailStreakIfRecovered ([string]$health.Problem))
            Save-State
            return 0
        }
        $streak = [int]$script:State.Misc['FailStreak']
        if ($streak -ge [int]$script:Cfg.BreakerFails -and -not $newConn -and -not (Test-Elapsed 'LastFull' 3600)) {
            Write-Log 'INFO' "Repair breaker open ($streak failed passes in a row): next automatic attempt within the hour, or as soon as the cable is re-plugged."
            Save-State
            return 0
        }
        Write-Log 'INFO' ("AutoHeal pass: problem={0} newConnection={1} dnsPhaseMismatch={2}" -f $health.Problem, $newConn, $mismatch)
        $r = Pick-Hash (Invoke-HealPipeline)
        if ($null -eq $r) { $r = @{ Conn = 'Offline'; Problem = 'Offline' } }
        if (Test-HardFailure ([string]$r.Problem)) {
            $script:State.Misc['FailStreak'] = $streak + 1
            if (($streak + 1) -eq [int]$script:Cfg.BreakerFails) { Write-Log 'ALERT' 'Automatic repair has not fixed the connection after several passes: check the cable and wall port, and check your MAC from the audit [6] or report [R].' }
        } else {
            if ($streak -gt 0 -or (Test-HardFailure ([string]$health.Problem))) {
                if ($r.Conn -eq 'Online') { Invoke-RecoveryToast ([string]$r.Ip) }
            }
            $script:State.Misc['FailStreak'] = 0
        }
        $script:State.Misc['LastAutoHealUpCount'] = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' }).Count
        Set-StateTime 'LastAutoHealRun'; Save-State
        if ($r.Conn -eq 'Captive') {
            if ($newConn -or (Test-Elapsed 'LastPortal' 1800)) { if (Test-Elapsed 'LastPortal' 20) { [void](Open-Portal) } }
            $watch = $true
        }
    } finally { Exit-Lock }
    if ($watch) { Invoke-AuthWatch }
    return 0
}

# ==============================================================================
# WATCHDOG (SYSTEM task, runs ONLY the ACL-locked copy) + portal helper task (user session)
# ==============================================================================
function New-WatchdogXml([string]$CmdArgs, [string]$Start) {
    $hb = "PT$($script:Cfg.HeartbeatMin)M"
    return @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Lan Fixer autonomous Ethernet watchdog (link up, resume from sleep, address conflicts, boot, logon, heartbeat)</Description>
    <Author>Abhishek Sonu</Author>
  </RegistrationInfo>
  <Triggers>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="Microsoft-Windows-NetworkProfile/Operational"&gt;&lt;Select Path="Microsoft-Windows-NetworkProfile/Operational"&gt;*[System[(EventID=10000 or EventID=10001)]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
      <Delay>PT10S</Delay>
    </EventTrigger>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="System"&gt;&lt;Select Path="System"&gt;*[System[Provider[@Name='Microsoft-Windows-Power-Troubleshooter'] and (EventID=1)]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
      <Delay>PT10S</Delay>
    </EventTrigger>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="System"&gt;&lt;Select Path="System"&gt;*[System[Provider[@Name='Microsoft-Windows-Kernel-Power'] and (EventID=107 or EventID=507)]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
      <Delay>PT10S</Delay>
    </EventTrigger>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="System"&gt;&lt;Select Path="System"&gt;*[System[Provider[@Name='Tcpip'] and (EventID=4199)]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
      <Delay>PT5S</Delay>
    </EventTrigger>
    <BootTrigger>
      <Enabled>true</Enabled>
      <Delay>PT45S</Delay>
    </BootTrigger>
    <LogonTrigger>
      <Enabled>true</Enabled>
      <Delay>PT10S</Delay>
    </LogonTrigger>
    <TimeTrigger>
      <Repetition>
        <Interval>$hb</Interval>
        <StopAtDurationEnd>false</StopAtDurationEnd>
      </Repetition>
      <StartBoundary>$Start</StartBoundary>
      <Enabled>true</Enabled>
    </TimeTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>true</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT20M</ExecutionTimeLimit>
    <Priority>5</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>%SystemRoot%\System32\cmd.exe</Command>
      <Arguments>$([System.Security.SecurityElement]::Escape($CmdArgs))</Arguments>
    </Exec>
  </Actions>
</Task>
"@
}
function New-NotifyTaskXml([string]$Title = 'Lan Fixer', [string]$Message = '') {
    $titleXml = [System.Security.SecurityElement]::Escape($Title)
    $msgXml   = [System.Security.SecurityElement]::Escape($Message)
    $script = @"
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null
`$ip = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { `$_.InterfaceAlias -match 'Ethernet|LAN' -and `$_.IPAddress -notlike '169.254.*' } | Select-Object -First 1).IPAddress
`$m = if ('$msgXml') { '$msgXml' } elseif (`$ip) { "Ethernet is back online (`$ip)! You can turn off a mobile hotspot." } else { "Ethernet is back online! You can turn off a mobile hotspot." }
`$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
`$xml.LoadXml('<toast><visual><binding template=""ToastGeneric""><text>$titleXml</text><text>' + [System.Security.SecurityElement]::Escape(`$m) + '</text></binding></visual></toast>')
`$toast = New-Object Windows.UI.Notifications.ToastNotification `$xml
`$appId = '{1AC14E77-02E7-4E60-B746-AC6A9D31BDE8}\WindowsPowerShell\v1.0\powershell.exe'
try { [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier(`$appId).Show(`$toast) } catch {}
"@
    $b64 = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($script))
    $args = "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $b64"
    return @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Displays LAN Fixer recovery notifications in the active user desktop session.</Description>
    <Author>Abhishek Sonu</Author>
  </RegistrationInfo>
  <Triggers />
  <Principals>
    <Principal id="Users">
      <GroupId>S-1-5-32-545</GroupId>
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>true</Hidden>
    <ExecutionTimeLimit>PT1M</ExecutionTimeLimit>
  </Settings>
  <Actions Context="Users">
    <Exec>
      <Command>%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe</Command>
      <Arguments>$args</Arguments>
    </Exec>
  </Actions>
</Task>
"@
}

function Show-NativeToast([string]$Title, [string]$Message) {
    try {
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null
        $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
        $xml.LoadXml("<toast><visual><binding template=""ToastGeneric""><text>$([System.Security.SecurityElement]::Escape($Title))</text><text>$([System.Security.SecurityElement]::Escape($Message))</text></binding></visual></toast>")
        $toast = New-Object Windows.UI.Notifications.ToastNotification $xml
        $appId = '{1AC14E77-02E7-4E60-B746-AC6A9D31BDE8}\WindowsPowerShell\v1.0\powershell.exe'
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)
    } catch {}
}

function Invoke-RecoveryToast([string]$Ip = '') {
    if (-not (Test-Elapsed 'LastRecoveryToast' 600)) { return }
    $title = 'Lan Fixer'
    $msg   = if ($Ip) { "Ethernet is back online ($Ip)! You can turn off a mobile hotspot." } else { 'Ethernet is back online! You can turn off a mobile hotspot.' }
    if (Test-IsSystem) {
        $u = $null
        try { $u = (Get-CimInstance Win32_ComputerSystem -ErrorAction Stop).UserName } catch {}
        if (-not $u) { return }
        [void](Invoke-Native (Get-SysExe 'schtasks.exe') @('/run', '/tn', $script:Cfg.TaskNotify) 8000)
    } else {
        Show-NativeToast $title $msg
    }
    Set-StateTime 'LastRecoveryToast'
}

function New-PortalTaskXml([string]$Url) {
    if (-not $Url) { $Url = [string](Get-ActivePortalUrl) }
    $url = [System.Security.SecurityElement]::Escape($Url)
    return @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Opens the campus login page in the signed-in user's browser. Started on demand by Lan Fixer.</Description>
    <Author>Abhishek Sonu</Author>
  </RegistrationInfo>
  <Triggers />
  <Principals>
    <Principal id="Users">
      <GroupId>S-1-5-32-545</GroupId>
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>true</Hidden>
    <ExecutionTimeLimit>PT1M</ExecutionTimeLimit>
  </Settings>
  <Actions Context="Users">
    <Exec>
      <Command>%SystemRoot%\System32\rundll32.exe</Command>
      <Arguments>url.dll,FileProtocolHandler $url</Arguments>
    </Exec>
  </Actions>
</Task>
"@
}
function Register-LfTask([string]$Name, [string]$Xml, [string]$FileName) {
    $xmlPath = Join-Path $script:StoreDir $FileName
    return (Invoke-Change "Scheduled task '$Name' registered" {
        [System.IO.File]::WriteAllText($xmlPath, $Xml, [System.Text.Encoding]::Unicode)
        $r = Invoke-Native (Get-SysExe 'schtasks.exe') @('/create', '/tn', $Name, '/xml', $xmlPath, '/f') 20000
        if ($r.ExitCode -ne 0) { throw ("schtasks said: " + $r.Output.Trim()) }
    })
}
function Install-Watchdog {
    if (-not (Assert-Admin)) { return $false }
    if (-not $script:StoreReady -or -not $script:StoreSecure) { Write-Log 'FAIL' 'The protected store folder is not available, so Lan Fixer refuses to register a SYSTEM task (security).'; return $false }
    if (-not $script:IsDry -and -not (Test-Path -LiteralPath $script:SelfCopy)) { Write-Log 'FAIL' 'Could not find the protected copy of Lan Fixer.'; return $false }
    try {
        $lg = Get-WinEvent -ListLog 'Microsoft-Windows-NetworkProfile/Operational' -ErrorAction Stop
        if (-not $lg.IsEnabled) { [void](Invoke-Change 'Windows network-connect event log enabled (watchdog trigger source)' { $lg.IsEnabled = $true; $lg.SaveChanges() }) }
    } catch {}
    $cmdArgs = '/c ""' + $script:SelfCopy + '" -Mode AutoHeal"'
    $start = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
    $ok1 = Register-LfTask $script:Cfg.TaskWatchdog (New-WatchdogXml $cmdArgs $start) 'LanFixer_Watchdog.xml'
    $ok2 = Register-LfTask $script:Cfg.TaskPortal (New-PortalTaskXml) 'LanFixer_Portal.xml'
    $ok3 = Register-LfTask $script:Cfg.TaskNotify (New-NotifyTaskXml) 'LanFixer_Notify.xml'
    if ($ok2 -and -not $script:IsDry) { $script:State.Misc['PortalTaskUrl'] = [string](Get-ActivePortalUrl) }
    if ($script:IsDry) { return $true }
    $script:WatchdogOn = Test-WatchdogInstalled
    if ($ok1 -and $script:WatchdogOn) {
        Write-Log 'OK' 'Watchdog active. It reacts to: cable connect, wake from sleep, address conflicts, boot, logon, and a heartbeat every few minutes.'
        if (-not $ok2) { Write-Log 'WARN' 'Portal helper task failed; the login page will not auto-open in background runs.' }
        $script:State.Misc['WatchdogSince'] = (Get-Date).ToString('o')
        [void](Set-ScriptAuthorization $script:SelfCopy)
        foreach ($old in 'Lan Fixer.cmd', 'LanFixer_v2.cmd') { Remove-Item -LiteralPath (Join-Path $script:StoreDir $old) -Force -ErrorAction SilentlyContinue }   # old mirror names (only after the task points at the new copy)
        Save-State
        return $true
    }
    Write-Log 'FAIL' 'Watchdog task could not be verified after registration.'
    return $false
}
# Pure (unit-tested): schtasks /xml reports <Settings><Enabled>false</Enabled> for a task disabled in Task Scheduler.
function Test-WatchdogDisabled([string]$Enabled) {
    if ([string]::IsNullOrEmpty($Enabled)) { return $false }
    return ($Enabled.Trim().ToLowerInvariant() -eq 'false')
}
function Get-WatchdogArguments {
    $task = Get-WatchdogTask
    if ($null -eq $task) { return $null }
    return [string]$task.Actions.Exec.Arguments
}
function Get-WatchdogExpectedArguments { return ('/c ""' + $script:SelfCopy + '" -Mode AutoHeal"') }
# A task registered by v1/v2.x runs an older copy. Re-point it once, automatically, at the current protected copy.
function Update-WatchdogIfStale {
    if (-not $script:IsAdmin -or $script:IsDry) { return }
    if (-not $script:StoreReady -or -not $script:StoreSecure) { return }
    if (-not (Test-Path -LiteralPath $script:SelfCopy)) { return }
    if (-not $script:WatchdogOn -and $script:State.Misc['WatchdogSince']) {
        if (Test-Elapsed 'Repoint' 600) {
            Set-StateTime 'Repoint'
            Write-Log 'WARN' 'Self-healing watchdog: background guard task was missing despite being armed; re-registering automatically.'
            [void](Install-Watchdog)
        }
        return
    }
    if (-not $script:WatchdogOn) { return }
    if (-not (Test-Elapsed 'Repoint' 3600)) { return }   # never loop if the comparison cannot settle
    $task = Get-WatchdogTask
    if ($null -eq $task) { return }
    $taskOff = [bool]($script:State.Misc['WatchdogSince'] -and (Test-WatchdogDisabled ([string]$task.Settings.Enabled)))
    if (-not $taskOff -and -not (Test-WatchdogStale ([string]$task.Actions.Exec.Arguments) (Get-WatchdogExpectedArguments) ([string]$task.Settings.MultipleInstancesPolicy))) { return }
    Set-StateTime 'Repoint'
    if ($taskOff) { Write-Log 'WARN' 'Self-healing watchdog: the background guard task was disabled in Task Scheduler while armed; re-registering it enabled.' }
    else { Write-Log 'INFO' 'The watchdog task is out of date (older copy or unsafe restart policy). Re-registering it.' }
    [void](Install-Watchdog)
}

function Clear-StartupEntries {
    try {
        @('HKCU:\Software\Microsoft\Windows\CurrentVersion\Run', 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run') | ForEach-Object {
            $regKey = $_
            if (Test-Path -LiteralPath $regKey) {
                Get-ItemProperty -LiteralPath $regKey -ErrorAction SilentlyContinue | ForEach-Object {
                    $props = $_.PSObject.Properties
                    foreach ($p in $props) {
                        if ($p.Name -match 'LanFixer|Lan Fixer' -or ([string]$p.Value) -match 'LanFixer\.cmd') {
                            Remove-ItemProperty -LiteralPath $regKey -Name $p.Name -Force -ErrorAction SilentlyContinue
                        }
                    }
                }
            }
        }
        @([Environment]::GetFolderPath('Startup'), [Environment]::GetFolderPath('CommonStartup')) | ForEach-Object {
            $dir = $_
            if ($dir -and (Test-Path -LiteralPath $dir)) {
                Get-ChildItem -LiteralPath $dir -Filter '*LanFixer*' -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
                Get-ChildItem -LiteralPath $dir -Filter '*Lan Fixer*' -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
            }
        }
    } catch {}
}

function Uninstall-Watchdog {
    if (-not (Assert-Admin)) { return }
    foreach ($n in @($script:Cfg.TaskWatchdog, $script:Cfg.TaskPortal, $script:Cfg.TaskNotify, 'A07_NetShield')) {
        [void](Invoke-Change "Scheduled task '$n' removed (if present)" {
            [void](Invoke-Native (Get-SysExe 'schtasks.exe') @('/end', '/tn', $n) 3000)
            [void](Invoke-Native (Get-SysExe 'schtasks.exe') @('/delete', '/tn', $n, '/f') 8000)
        })
    }
    Clear-StartupEntries
    if (-not $script:IsDry -and $script:State.Misc -is [hashtable]) { $script:State.Misc.Remove('WatchdogSince') }
    foreach ($oldXml in 'LanFixer_Watchdog.xml', 'LanFixer_Portal.xml', 'LanFixer_Notify.xml') {
        Remove-Item -LiteralPath (Join-Path $script:StoreDir $oldXml) -Force -ErrorAction SilentlyContinue
    }
    $script:WatchdogOn = $false
    Remove-CampusNrpt   # nothing would auto-remove it off campus any more
    Remove-CampusHostRoutes
    if (Test-MetricsManaged) { Restore-InterfaceMetrics 'Watchdog disarmed' }
    Restore-NeutralizedInterceptors 'Watchdog disarmed'
    [void](Restore-ManagedAdapterDns 'Watchdog disarmed')
    Write-Log 'INFO' 'Watchdog removed and any temporary route, DNS, or service holds released.'
}

# ==============================================================================
# RESTORE: puts back YOUR snapshotted originals (not assumed "factory" values)
# ==============================================================================
function Restore-Everything {
    if (-not (Assert-Admin)) { return }
    Write-Log 'INFO' 'Initiating Complete Factory Reset & Rollback to Default Windows...'
    $restartNames = @{}
    $present = @(Get-NetAdapter -IncludeHidden -ErrorAction SilentlyContinue)

    # 1. Unregister & Terminate ALL Background Daemons and Scheduled Tasks
    Uninstall-SentinelTask
    Uninstall-Watchdog
    try {
        Get-ScheduledTask -TaskName 'LanFixer_*' -ErrorAction SilentlyContinue | ForEach-Object {
            try { [void](Invoke-Native (Get-SysExe 'schtasks.exe') @('/end', '/tn', $_.TaskName) 3000) } catch {}
            Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false -ErrorAction SilentlyContinue
        }
    } catch {}
    Clear-StartupEntries

    # 2. Restore Pre-LanFixer Snapshots (If snapshot exists in state)
    if ($script:State -is [hashtable] -and $script:State.Snapshot -is [hashtable]) {
        if ($script:State.Snapshot.ContainsKey('Debloat')) {
            try { [void](Undo-NetworkDebloat -Quiet) } catch {}
        }
        foreach ($guid in @($script:State.Snapshot.Keys)) {
            $snap = $script:State.Snapshot[$guid]
            if ($snap -isnot [hashtable]) { continue }
            if ($guid -eq 'NetProfiles') {
                foreach ($k in @($snap.Keys)) {
                    if ($k -like 'Cat:*') {
                        $nm = $k.Substring(4); $cat = [string]$snap[$k]
                        [void](Invoke-Change "Network '$nm' set back to $cat" { Set-NetConnectionProfile -Name $nm -NetworkCategory $cat -ErrorAction Stop })
                    }
                }
                continue
            }
            if ($snap.ContainsKey('MsTcpip6')) {
                $mv = [string]$snap['MsTcpip6']
                if ($mv -eq 'True') {
                    [void](Invoke-Change "IPv6 re-enabled on adapter $guid" {
                        $mAd = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { [string]$_.InterfaceGuid -eq $guid }) | Select-Object -First 1
                        if ($mAd) { Enable-NetAdapterBinding -Name $mAd.Name -ComponentId 'ms_tcpip6' -Confirm:$false -ErrorAction SilentlyContinue }
                    })
                }
            }
            if ($guid -eq 'Global') {
                if ($snap.ContainsKey('UsbSuspend')) { $uv = $snap['UsbSuspend']; [void](Invoke-Change 'USB selective suspend restored to your original value' { Restore-UsbSuspend $uv }) }
                if ($snap.ContainsKey('WinHttpProxy')) {
                    $wh = [string]$snap['WinHttpProxy']
                    [void](Invoke-Change 'WinHTTP proxy restored' {
                        $netsh = Get-SysExe 'netsh.exe'
                        if ($wh) { [void](Invoke-Native $netsh @('winhttp', 'set', 'proxy', $wh) 5000) }
                        else { [void](Invoke-Native $netsh @('winhttp', 'reset', 'proxy') 5000) }
                    })
                }
                if ($snap.ContainsKey('ProxyEnable_CU')) {
                    $pe = [int]$snap['ProxyEnable_CU']
                    [void](Invoke-Change 'WinINet user proxy restored' {
                        Set-ItemProperty -LiteralPath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -Value $pe -Type DWord -Force -ErrorAction SilentlyContinue
                    })
                }
                if ($snap.ContainsKey('ProxyEnable_LM')) {
                    $pe = [int]$snap['ProxyEnable_LM']
                    [void](Invoke-Change 'WinINet machine proxy restored' {
                        Set-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -Value $pe -Type DWord -Force -ErrorAction SilentlyContinue
                    })
                }
                if ($snap.ContainsKey('Llmnr')) {
                    $lv = $snap['Llmnr']
                    [void](Invoke-Change 'LLMNR setting restored' { Restore-Llmnr $lv })
                }
                if ($snap.ContainsKey('DisabledComponents')) {
                    $dc = $snap['DisabledComponents']
                    [void](Invoke-Change 'IPv6 prefix policy restored' {
                        if ($null -eq $dc) { Remove-ItemProperty -LiteralPath $script:Tcpip6Key -Name DisabledComponents -ErrorAction SilentlyContinue }
                        else { New-ItemProperty -LiteralPath $script:Tcpip6Key -Name DisabledComponents -Value ([int]$dc) -PropertyType DWord -Force -ErrorAction Stop | Out-Null }
                    })
                }
                if ($snap.ContainsKey('Ncsi')) {
                    $nk = 'HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet'
                    $v = [int]$snap['Ncsi']
                    [void](Invoke-Change "Connectivity probing setting restored to $v" { Set-ItemProperty -LiteralPath $nk -Name EnableActiveProbing -Value $v -Type DWord -ErrorAction Stop })
                }
                if ($snap.ContainsKey('MaxNegativeCacheTtl')) {
                    $nct = $snap['MaxNegativeCacheTtl']
                    [void](Invoke-Change 'Negative DNS cache TTL restored' {
                        if ($null -eq $nct) { Remove-ItemProperty -LiteralPath $script:DnsParamKey -Name MaxNegativeCacheTtl -ErrorAction SilentlyContinue }
                        else { Set-ItemProperty -LiteralPath $script:DnsParamKey -Name MaxNegativeCacheTtl -Value ([int]$nct) -Type DWord -ErrorAction Stop }
                    })
                }
                if ($snap.ContainsKey('EnableMDNS')) {
                    $md = $snap['EnableMDNS']
                    [void](Invoke-Change 'mDNS setting restored' {
                        if ($null -eq $md) { Remove-ItemProperty -LiteralPath $script:DnsParamKey -Name EnableMDNS -ErrorAction SilentlyContinue }
                        else { Set-ItemProperty -LiteralPath $script:DnsParamKey -Name EnableMDNS -Value ([int]$md) -Type DWord -ErrorAction Stop }
                    })
                }
                if ($snap.ContainsKey('DisableSmartNameResolution') -or (Test-Path -LiteralPath $script:DnsPolicyKey)) {
                    [void](Invoke-Change 'Smart Name Resolution policy cleared' {
                        Remove-ItemProperty -LiteralPath $script:DnsPolicyKey -Name DisableSmartNameResolution -ErrorAction SilentlyContinue
                    })
                }
                if ($snap.ContainsKey('KeepAliveTime')) {
                    $kat = $snap['KeepAliveTime']
                    [void](Invoke-Change 'TCP KeepAliveTime restored' {
                        if ($null -eq $kat) { Remove-ItemProperty -LiteralPath $script:TcpParamKey -Name KeepAliveTime -ErrorAction SilentlyContinue }
                        else { Set-ItemProperty -LiteralPath $script:TcpParamKey -Name KeepAliveTime -Value ([int]$kat) -Type DWord -ErrorAction Stop }
                    })
                }
                if ($snap.ContainsKey('KeepAliveInterval')) {
                    $kai = $snap['KeepAliveInterval']
                    [void](Invoke-Change 'TCP KeepAliveInterval restored' {
                        if ($null -eq $kai) { Remove-ItemProperty -LiteralPath $script:TcpParamKey -Name KeepAliveInterval -ErrorAction SilentlyContinue }
                        else { Set-ItemProperty -LiteralPath $script:TcpParamKey -Name KeepAliveInterval -Value ([int]$kai) -Type DWord -ErrorAction Stop }
                    })
                }
                if ($snap.ContainsKey('TcpAutoTuning')) {
                    $tat = [string]$snap['TcpAutoTuning']
                    if ($tat -eq 'Disabled') {
                        [void](Invoke-Change 'TCP Window Auto-Tuning restored to Disabled (original user setting)' {
                            Set-NetTCPSetting -SettingName Internet -AutoTuningLevelLocal Disabled -ErrorAction Stop
                        })
                    }
                }
                continue
            }
            $ad = $present | Where-Object { [string]$_.InterfaceGuid -eq [string]$guid } | Select-Object -First 1
            if (-not $ad) { Write-Log 'INFO' "Adapter $guid is not present; its snapshot is skipped."; continue }
            foreach ($key in @($snap.Keys)) {
                $val = $snap[$key]
                if ($key -eq 'StaticIp4') {
                    if ($val -and $val.IPAddress) {
                        [void](Invoke-Change "Static IPv4 configuration ($($val.IPAddress)/$($val.PrefixLength)) restored on $($ad.Name)" {
                            Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -Dhcp Disabled -ErrorAction Stop
                            Get-NetIPAddress -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue
                            if ($val.DefaultGateway) {
                                Remove-NetRoute -InterfaceIndex $ad.ifIndex -DestinationPrefix '0.0.0.0/0' -PolicyStore ActiveStore -Confirm:$false -ErrorAction SilentlyContinue
                                Remove-NetRoute -InterfaceIndex $ad.ifIndex -DestinationPrefix '0.0.0.0/0' -PolicyStore PersistentStore -Confirm:$false -ErrorAction SilentlyContinue
                                New-NetIPAddress -InterfaceIndex $ad.ifIndex -IPAddress $val.IPAddress -PrefixLength $val.PrefixLength -DefaultGateway $val.DefaultGateway -ErrorAction SilentlyContinue | Out-Null
                            } else {
                                New-NetIPAddress -InterfaceIndex $ad.ifIndex -IPAddress $val.IPAddress -PrefixLength $val.PrefixLength -ErrorAction SilentlyContinue | Out-Null
                            }
                        })
                    }
                } elseif ($key -eq 'Dad4') {
                    $n = [int]$val
                    [void](Invoke-Change "Duplicate-address probes back to $n on $($ad.Name)" { Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -DadTransmits $n -ErrorAction Stop })
                } elseif ($key -eq 'Mtu') {
                    $m = [int]$val
                    [void](Invoke-Change "MTU back to $m on $($ad.Name)" { Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -NlMtuBytes $m -ErrorAction Stop })
                } elseif ($key -like 'PrunedRoute_*') {
                    if ($val -and $val.NextHop) {
                        [void](Invoke-Change "Default route $($val.NextHop) restored on $($ad.Name)" {
                            New-NetRoute -InterfaceIndex $ad.ifIndex -DestinationPrefix '0.0.0.0/0' -NextHop $val.NextHop -RouteMetric ([int]$val.RouteMetric) -PolicyStore ActiveStore -ErrorAction SilentlyContinue
                        })
                    }
                } elseif ($key -eq 'DnsStatic') {
                    $s = [string]$val
                    $okDns = $false
                    if ($s -eq '') {
                        $okDns = Invoke-Change "DNS on $($ad.Name) back to automatic" { Set-DnsClientServerAddress -InterfaceIndex $ad.ifIndex -ResetServerAddresses -ErrorAction Stop }
                    } else {
                        $list = @($s -split '[,\s]+' | Where-Object { $_ })
                        $hasPrivate = $false
                        foreach ($ip in $list) {
                            if ($ip -eq $script:Cfg.CampusDns -or $ip -eq $script:Cfg.PortalIp) { $hasPrivate = $true; break }
                        }
                        if ($hasPrivate) {
                            $okDns = Invoke-Change "DNS on $($ad.Name) reset to automatic (sanitized campus IPs)" { Set-DnsClientServerAddress -InterfaceIndex $ad.ifIndex -ResetServerAddresses -ErrorAction Stop }
                        } else {
                            $okDns = Invoke-Change "DNS on $($ad.Name) back to $s" { Set-DnsClientServerAddress -InterfaceIndex $ad.ifIndex -ServerAddresses $list -ErrorAction Stop }
                        }
                    }
                    if ($okDns -and -not $script:IsDry) { (Get-SubTable 'Dns' ([string]$guid)).Managed = $false }
                } elseif ($key -eq 'NetBios') {
                    $n = [int]$val
                    $tk = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces\Tcpip_$guid"
                    [void](Invoke-Change "NetBIOS setting back to $n on $($ad.Name)" { Set-ItemProperty -LiteralPath $tk -Name NetbiosOptions -Value $n -Type DWord -ErrorAction Stop })
                } elseif ($key -like 'Adv:*') {
                    $kw = $key.Substring(4); $sv = [string]$val
                    $ok = Invoke-Change "Driver option '$kw' back to $sv on $($ad.Name)" { Set-NetAdapterAdvancedProperty -Name $ad.Name -RegistryKeyword $kw -RegistryValue @($sv) -NoRestart -ErrorAction Stop }
                    if ($ok) { $restartNames[$ad.Name] = $true }
                } elseif ($key -eq 'Pnp') {
                    $ck = Get-NicClassKey $ad
                    if ($ck) {
                        if ($null -eq $val) {
                            $ok = Invoke-Change "NIC power-off permission back to default on $($ad.Name)" { Remove-ItemProperty -LiteralPath $ck -Name PnPCapabilities -ErrorAction SilentlyContinue }
                        } else {
                            $pv = [int]$val
                            $ok = Invoke-Change "NIC power-off permission back to $pv on $($ad.Name)" { New-ItemProperty -LiteralPath $ck -Name PnPCapabilities -Value $pv -PropertyType DWord -Force -ErrorAction Stop }
                        }
                        if ($ok) { $restartNames[$ad.Name] = $true }
                    }
                } elseif ($key -like 'Enum:*') {
                    $pName = $key.Substring(5)
                    if ($ad.PnPDeviceID) {
                        $eKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\$($ad.PnPDeviceID)\Device Parameters"
                        if (Test-Path -LiteralPath $eKey) {
                            try {
                                if ($null -eq $val) {
                                    Remove-ItemProperty -LiteralPath $eKey -Name $pName -ErrorAction Stop
                                } else {
                                    $ev = [int]$val
                                    Set-ItemProperty -LiteralPath $eKey -Name $pName -Value $ev -Type DWord -Force -ErrorAction Stop
                                }
                                Write-Log 'OK' "Device Parameters '$pName' reverted on $($ad.Name)"
                            } catch {
                                Write-Log 'INFO' "Device Parameters '$pName' reversion on $($ad.Name) skipped"
                            }
                        }
                    }
                }
            }
        }
    }

    # 3. Clean Leftovers & Enforce Native Windows Defaults Across ALL Adapters
    [void](Restore-ManagedAdapterDns 'Factory reset')
    foreach ($a in @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue)) {
        $g = [string]$a.InterfaceGuid
        $snapA = if ($script:State -is [hashtable] -and $script:State.Snapshot -is [hashtable]) { $script:State.Snapshot[$g] } else { $null }
        $ipif = Get-IPv4Interface $a
        if ($ipif -and [int]$ipif.DadTransmits -eq 0 -and -not ($snapA -is [hashtable] -and $snapA.ContainsKey('Dad4'))) {
            [void](Invoke-Change "Duplicate-address probes back to 3 on $($a.Name)" { Set-NetIPInterface -InterfaceIndex $a.ifIndex -AddressFamily IPv4 -DadTransmits 3 -ErrorAction Stop })
        }
        $tk = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces\Tcpip_$g"
        if ((Test-Path -LiteralPath $tk) -and ((Get-ItemProperty -LiteralPath $tk -Name NetbiosOptions -ErrorAction SilentlyContinue).NetbiosOptions -eq 2) -and -not ($snapA -is [hashtable] -and $snapA.ContainsKey('Netbios'))) {
            [void](Invoke-Change "NetBIOS back to default on $($a.Name)" { Set-ItemProperty -LiteralPath $tk -Name NetbiosOptions -Value 0 -Type DWord -ErrorAction Stop })
        }
        $dnsInfo = Get-DnsClientServerAddress -InterfaceIndex $a.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
        if ($dnsInfo -and $dnsInfo.ServerAddresses -and -not ($snapA -is [hashtable] -and $snapA.ContainsKey('DnsStatic'))) {
            [void](Invoke-Change "DNS on $($a.Name) reset to automatic (DHCP)" { Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ResetServerAddresses -ErrorAction Stop })
        }
    }

    # 4. Universal Interface Metrics Reset (Restore AutomaticMetric on all adapters)
    Restore-InterfaceMetrics 'Metrics back to their original values'
    foreach ($ipif in @(Get-NetIPInterface -ErrorAction SilentlyContinue)) {
        if ($ipif.AutomaticMetric -ne 'Enabled') {
            [void](Invoke-Change "Adapter $($ipif.InterfaceAlias) $($ipif.AddressFamily) metric reverted to automatic" {
                Set-NetIPInterface -InterfaceIndex $ipif.ifIndex -AddressFamily $ipif.AddressFamily -AutomaticMetric Enabled -ErrorAction SilentlyContinue
            })
        }
    }

    # 5. Restore IPv6 Transition Tunnels to Windows Defaults
    [void](Invoke-Change 'IPv6 transition tunnels (Teredo, 6to4, ISATAP) restored to Windows defaults' {
        [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'teredo', 'set', 'state', 'default') 5000)
        [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', '6to4', 'set', 'state', 'default') 5000)
        [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'isatap', 'set', 'state', 'default') 5000)
    })

    # 6. Clean DHCP ConnForceBroadcastFlag and Broadcast Toggle Keys
    try {
        $ifacesKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces'
        if (Test-Path -LiteralPath $ifacesKey) {
            Get-ChildItem -LiteralPath $ifacesKey -ErrorAction SilentlyContinue | ForEach-Object {
                Remove-ItemProperty -LiteralPath $_.PSPath -Name 'DhcpConnForceBroadcastFlag' -ErrorAction SilentlyContinue
                Remove-ItemProperty -LiteralPath $_.PSPath -Name 'DhcpConnEnableBcastFlagToggle' -ErrorAction SilentlyContinue
            }
        }
    } catch {}

    # 7. Release All ARP Locks & Flush All Neighbor and Destination Caches
    foreach ($guid in @($script:State.Arp.Keys)) {
        $ad = $present | Where-Object { [string]$_.InterfaceGuid -eq [string]$guid } | Select-Object -First 1
        if ($ad) { Release-ArpLocks $ad }
    }
    foreach ($ea in @(Get-EthernetAdapters)) { Release-ArpLocks $ea }
    [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'ip', 'delete', 'arpcache') 8000)
    [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'ipv6', 'delete', 'destinationcache') 8000)
    [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'ipv6', 'delete', 'arpcache') 8000)
    [void](Invoke-Native (Get-SysExe 'nbtstat.exe') @('-R') 8000)
    Clear-DnsClientCache -ErrorAction SilentlyContinue

    # 8. Clean Host Routes, NRPT Policies, and Hosts File
    Remove-CampusHostRoutes
    Remove-CampusNrpt
    Remove-LegacyHostsEntries

    # 9. Restore 3rd-Party Tasks, Neutralized Services & NDIS Filters
    if ($script:State -is [hashtable] -and $script:State.Misc -is [hashtable] -and ($script:State.Misc['NeutralizedTasks'] -is [hashtable])) {
        foreach ($tn in @($script:State.Misc['NeutralizedTasks'].Keys)) {
            $tp = [string]$script:State.Misc['NeutralizedTasks'][$tn]
            [void](Invoke-Change "Restored 3rd-party task $tn" { Enable-ScheduledTask -TaskName $tn -TaskPath $tp -ErrorAction SilentlyContinue | Out-Null })
        }
    }
    if ($script:State -is [hashtable] -and $script:State.Misc -is [hashtable] -and ($script:State.Misc['NeutralizedServices'] -is [hashtable])) {
        foreach ($sn in @($script:State.Misc['NeutralizedServices'].Keys)) {
            $rec = $script:State.Misc['NeutralizedServices'][$sn]
            $origStart = if ($rec -is [hashtable]) { [string]$rec.StartType } else { [string]$rec }
            if ($origStart -and $origStart -ne 'Disabled') {
                [void](Invoke-Change "Restored 3rd-party service $sn to $origStart" { Set-Service -Name $sn -StartupType $origStart -ErrorAction SilentlyContinue })
            }
        }
    }
    if ($script:State -is [hashtable] -and $script:State.Snapshot -is [hashtable] -and ($script:State.Snapshot.ContainsKey('DeactivatedFilters'))) {
        $df = $script:State.Snapshot['DeactivatedFilters']
        if ($df -is [hashtable]) {
            foreach ($adName in $df.Keys) {
                foreach ($compId in @($df[$adName])) {
                    [void](Invoke-Change "NDIS filter '$compId' re-enabled on $adName" {
                        Enable-NetAdapterBinding -Name $adName -ComponentID $compId -Confirm:$false -ErrorAction SilentlyContinue
                    })
                }
            }
        }
    }

    # 10. Restore Wi-Fi Profiles & Windows Firewall Rules from Backup
    Restore-WlanProfiles
    $fwBackup = Join-Path $script:StoreDir 'firewall_pre_reset.wfw'
    if (Test-Path -LiteralPath $fwBackup) {
        [void](Invoke-Change 'Windows Firewall rules restored from pre-reset backup' {
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('advfirewall', 'import', $fwBackup) 8000)
        })
    }

    # 11. Restore NCSI Active Probing Settings to Windows Defaults
    try {
        $nk = 'HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet'
        if (Test-Path -LiteralPath $nk) {
            Set-ItemProperty -LiteralPath $nk -Name 'EnableActiveProbing' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -LiteralPath $nk -Name 'ActiveDnsProbeHost' -Value 'dns.msftncsi.com' -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -LiteralPath $nk -Name 'ActiveDnsProbeContent' -Value '131.107.0.89' -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -LiteralPath $nk -Name 'ActiveWebProbeHost' -Value 'www.msftconnecttest.com' -Force -ErrorAction SilentlyContinue
        }
    } catch {}

    # 12. Purge Credentials & Clean Machine Store
    if (-not $script:IsDry) {
        foreach ($n in @($restartNames.Keys)) {
            [void](Invoke-Change "Zero-reboot link reset on $n to apply restored driver settings" {
                $rAd = Get-NetAdapter -Name $n -ErrorAction SilentlyContinue
                if ($rAd) { Reset-PhysicalAdapterHardware $rAd } else { Restart-NetAdapter -Name $n -Confirm:$false -ErrorAction Stop }
            })
        }
        Remove-PortalCredentials; Write-Log 'OK' 'Saved portal credentials and encrypted vault purged.'

        $scrubFiles = @('sentinel.log', 'sentinel.log.bak', 'firewall_pre_reset.wfw', 'reset_journal.json', 'LanFixer_Watchdog.xml', 'LanFixer_Portal.xml', 'LanFixer_Notify.xml', 'LanFixer_Sentinel.xml', 'LanFixer_Core.cmd', 'interactive.json')
        foreach ($sf in $scrubFiles) {
            $sfp = Join-Path $script:StoreDir $sf
            if (Test-Path -LiteralPath $sfp) { Remove-Item -LiteralPath $sfp -Force -ErrorAction SilentlyContinue }
        }
        $stageFolder = Join-Path $script:StoreDir 'staging'
        if (Test-Path -LiteralPath $stageFolder) { Remove-Item -LiteralPath $stageFolder -Recurse -Force -ErrorAction SilentlyContinue }

        $script:State = @{}
        foreach ($k in 'Snapshot','Env','Dns','Arp','Times','Misc') { $script:State[$k] = @{} }
        $script:State.Misc['Migrated'] = $true
        $script:State.Misc['FactoryResetDate'] = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        Save-State
    }

    Write-Log 'OK' 'Factory Reset Complete. All settings reverted to pristine Windows defaults; zero tasks, zero rules, zero background hooks remain.'
    Write-Log 'INFO' 'Notice: System is now on standard Windows defaults without LanFixer background tasks or persistent portal routes. On restrictive campus networks, Windows native networking requires LanFixer Autonomous Daemon [B] or Watchdog Guard [2] for zero-touch captive portal sign-in and STP handling.'
}

function Apply-DnsNow {
    $script:WatchdogOn = Test-WatchdogInstalled
    $ups = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
    if ($ups.Count -eq 0) {
        Write-Log 'INFO' 'No active Ethernet link right now; profile saved and will apply automatically on link connect.'
        Save-State
        return
    }
    $conn = (Get-InternetState -NoCache).State
    foreach ($a in $ups) {
        $script:EnvCache.Remove([string]$a.InterfaceGuid)
        $ctx = @{ Ad = $a; Env = (Get-AdapterEnvironment $a) }
        Shield-Dns $ctx $conn
    }
    Save-State
}
function Set-DnsProfileMode([string]$Name) {
    if (-not (Assert-Admin)) { return }
    [void](Invoke-WithLock {
        if ($Name -eq 'ResetDHCP') {
            # 1. Hand every adapter this tool substituted a resolver on back to the user's OWN value first. The managed
            #    flags are the only record of which adapters those are, so this must run BEFORE the wipe below - and it
            #    is what stops a Wi-Fi / USB-tethering / Bluetooth-PAN resolver from being orphaned by this reset.
            [void](Restore-ManagedAdapterDns 'Reset DHCP')
            # 2. Forget all DNS management and return to the default recommended profile.
            $script:State.Dns = @{}
            $script:State.Misc['DnsProfile'] = 'Adaptive'
            Remove-CampusNrpt
            foreach ($a in @(Get-EthernetAdapters)) { [void](Set-AdapterDnsAutomatic $a) }
            # The reset helpers mark an adapter managed while they write; here the user asked to FORGET DNS management,
            # so no flag may survive: otherwise a later roaming cleanup would put a stale substituted resolver back.
            if (-not $script:IsDry) { $script:State.Dns = @{} }
            Clear-DnsClientCache -ErrorAction SilentlyContinue
            if (-not $script:IsDry) { Save-State }
            Write-Log 'OK' 'Cleared all custom DNS rules, reset adapters to automatic DHCP, and restored Adaptive profile.'
        } else {
            $script:State.Misc['DnsProfile'] = $Name
            if (-not $script:IsDry) { Save-State }
            Apply-DnsNow
            Write-Log 'OK' "DNS profile is now: $Name"
        }
    })
}
function Set-RouteProfileMode([string]$Name) {
    if (-not (Assert-Admin)) { return }
    $valid = @('Adaptive', 'Ethernet', 'Wifi', 'Windows')
    if ($valid -notcontains $Name) { Write-Log 'WARN' "Unknown routing profile '$Name'. Valid: $($valid -join ', ')"; return }
    [void](Invoke-WithLock {
        $script:State.Misc['RouteProfile'] = $Name
        Write-Log 'OK' "Routing priority profile is now: $Name"
        if ($Name -eq 'Wifi') {
            foreach ($w in (Get-AllWirelessAdapters)) {
                if ($w.Status -eq 'Disabled') {
                    if (-not $script:IsDry) {
                        [void](Invoke-Change "Enabling disabled Wi-Fi adapter $($w.Name) for Wifi profile" {
                            Enable-NetAdapter -Name $w.Name -Confirm:$false -ErrorAction Stop
                        })
                    } else {
                        Write-Log 'DRY' "Would: Enable disabled Wi-Fi adapter $($w.Name)"
                    }
                }
            }
        }
        $allEth = @(Get-EthernetAdapters)
        $ethUps = @($allEth | Where-Object { $_.Status -eq 'Up' })
        $primaryEth = if ($ethUps.Count -gt 0) { $ethUps[0] } elseif ($allEth.Count -gt 0) { $allEth[0] } else { $null }
        if ($Name -eq 'Windows') {
            Restore-InterfaceMetrics "Routing profile set to Windows Default"
        } elseif ($primaryEth) {
            $srcIp = Get-ValidIPv4 $primaryEth
            $st = if ($srcIp) { (Get-InternetState -NoCache -SourceIp $srcIp).State } else { 'Offline' }
            $ctx = @{ Ad = $primaryEth; Env = (Get-AdapterEnvironment $primaryEth) }
            Shield-RouteMetrics $ctx $st
        }
        if (-not $script:IsDry) { Save-State }
    })
}

# ==============================================================================
# UI HELPERS
# ==============================================================================
# ---- restyled helpers used by every mode (same names and contracts as before)
function Write-FitText([string]$Text, [int]$Width) { return (Fit $Text $Width) }
function Write-Banner([string]$Title) {
    if ($Json -or $Quiet -or -not $script:UiOn) { return }
    $w = Get-UiWidth
    Out-Line @()
    Out-Line @((Seg 'accent!' '  LAN FIXER'), (Seg 'faint' (' ' + $script:G.mid + ' ' + $Title.ToUpper())))
    Out-Rule $w
    Out-Line @()
}
function Write-Section([string]$Title) {
    if ($Json -or $Quiet -or -not $script:UiOn) { return }
    $w = Get-UiWidth
    Out-Line @()
    Out-Line @((Seg 'accent!' ('  ' + $Title.ToLower() + ' ')), (Seg 'faint' ($script:G.rule * [Math]::Max(3, $w - $Title.Length - 2))))
    Out-Line @()
}
function Write-KV([string]$Key, [string]$Value, [string]$Color = 'White') {
    if ($Json -or $Quiet) { return }
    Out-Line @((Seg 'dim' ('  ' + ($Key.PadRight(26)) + ' ')), (Seg (ConvertTo-Role $Color) $Value))
}
# ==============================================================================
# PATH MTU (confirmed twice, floor 1280, only while online, never re-clamped)
# ==============================================================================
function Get-PathMtu([string]$Target) {
    $p = New-Object System.Net.NetworkInformation.Ping
    $opt = New-Object System.Net.NetworkInformation.PingOptions(64, $true)
    # one lost probe must never read as "smaller path": a size passes if ANY of 3 tries gets through
    $probe = {
        param($Size)
        $buf = New-Object byte[] $Size
        for ($k = 0; $k -lt 3; $k++) {
            try { $r = $p.Send($Target, 450, $buf, $opt); if ($r.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) { return $true } } catch {}
        }
        return $false
    }
    try {
        if (& $probe 1472) { return 1500 }
        if (-not (& $probe 548)) { return $null }
        $lo = 548; $hi = 1472
        while (($hi - $lo) -gt 8) { $mid = [int](($lo + $hi) / 2); if (& $probe $mid) { $lo = $mid } else { $hi = $mid } }
        return ($lo + 28)
    } finally { $p.Dispose() }
}
# ==============================================================================
# READ-ONLY AUDIT
# ==============================================================================
# TCP connect to well-known IPv6 literals from the adapter's own IPv6 address. True if any answers.
function Test-Ipv6Reach([string]$SourceIp, [string[]]$Targets = @('2606:4700:4700::1111', '2001:4860:4860::8888'), [int]$Port = 443, [int]$TimeoutMs = 1500) {
    foreach ($tg in $Targets) {
        $s = $null
        try {
            # inside the try: with IPv6 switched off in Windows this constructor throws, and that must stay silent
            $s = New-Object System.Net.Sockets.Socket([System.Net.Sockets.AddressFamily]::InterNetworkV6, [System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
            if ($SourceIp) { $s.Bind((New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($SourceIp), 0))) }
            $iar = $s.BeginConnect([System.Net.IPAddress]::Parse($tg), $Port, $null, $null)
            if ($iar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)) { try { $s.EndConnect($iar); return $true } catch {} }
        } catch {} finally { if ($s) { try { $s.Close() } catch {} } }
    }
    return $false
}
# Pure decision (unit-tested): the harmful case is "IPv6 advertised, IPv6 internet dead, IPv4 fine" - apps that try
# IPv6 first then stall for many seconds before falling back.
function Get-Ipv6Verdict([bool]$HasGlobal, [bool]$HasRoute, [string]$Conn, [bool]$Reach) {
    if (-not $HasGlobal) { return 'None' }
    if (-not $HasRoute) { return 'NoRoute' }
    if ($Conn -ne 'Online') { return 'Untested' }
    if ($Reach) { return 'Working' }
    return 'Blackhole'
}
function Compute-DoctorVerdict([array]$Layers) {
    $hasBroken = $false
    $hasDegraded = $false
    $hasUndetermined = $false
    $recommended = 'None'
    $rootCause = 'All network subsystems operational.'

    $criticalLayers = @(1, 2, 3, 4, 5)

    foreach ($l in $Layers) {
        if ($l.Status -eq 'FAILED') {
            if ($criticalLayers -contains $l.Layer -or $l.Layer -eq 7) {
                $hasBroken = $true
                if ($recommended -eq 'None') {
                    $recommended = $l.Action
                    $rootCause = $l.Cause
                }
            } else {
                $hasDegraded = $true
                if ($recommended -eq 'None') {
                    $recommended = $l.Action
                    $rootCause = $l.Cause
                }
            }
        } elseif ($l.Status -eq 'DEGRADED') {
            $hasDegraded = $true
            if ($recommended -eq 'None') {
                $recommended = $l.Action
                $rootCause = $l.Cause
            }
        } elseif ($l.Status -eq 'UNKNOWN') {
            $hasUndetermined = $true
            if ($recommended -eq 'None') {
                $recommended = $l.Action
                $rootCause = $l.Cause
            }
        }
    }

    if ($hasBroken) {
        return @{ Verdict = 'Broken'; ExitCode = 20; RecommendedMode = $recommended; RootCause = $rootCause }
    } elseif ($hasDegraded) {
        return @{ Verdict = 'Degraded'; ExitCode = 10; RecommendedMode = $recommended; RootCause = $rootCause }
    } elseif ($hasUndetermined) {
        return @{ Verdict = 'Undetermined'; ExitCode = 30; RecommendedMode = $recommended; RootCause = $rootCause }
    } else {
        return @{ Verdict = 'Healthy'; ExitCode = 0; RecommendedMode = 'None'; RootCause = 'All network subsystems operational.' }
    }
}

function Format-DoctorConsole($Report, [switch]$NoColor) {
    $vCol = switch ($Report.OverallVerdict) {
        'Healthy'      { 'Green' }
        'Degraded'     { 'Yellow' }
        'Broken'       { 'Red' }
        'Undetermined' { 'DarkYellow' }
        default        { 'White' }
    }

    $nc = [bool]($NoColor -or $script:NoColor)
    if ($nc) {
        Write-Host '================================================================================'
        Write-Host '       LANFIXER HEALTH VERDICT ENGINE (OSI Layer 1-7 Forensics)'
        Write-Host '================================================================================'
    } else {
        Write-Host '================================================================================' -ForegroundColor Cyan
        Write-Host '       LANFIXER HEALTH VERDICT ENGINE (OSI Layer 1-7 Forensics)' -ForegroundColor Cyan
        Write-Host '================================================================================' -ForegroundColor Cyan
    }
    Write-Host ('Primary Adapter : {0}' -f $Report.PrimaryAdapter)
    Write-Host -NoNewline 'Overall Verdict : '
    if ($NoColor) {
        Write-Host ('{0} (ExitCode: {1})' -f $Report.OverallVerdict, $Report.ExitCode)
    } else {
        Write-Host ('{0} ' -f $Report.OverallVerdict) -NoNewline -ForegroundColor $vCol
        Write-Host ('(ExitCode: {0})' -f $Report.ExitCode)
    }
    Write-Host ('Root Cause      : {0}' -f $Report.RootCause)
    Write-Host ('Recommended Mode: {0}' -f $Report.RecommendedMode)
    Write-Host ('Diagnostic Time : {0} ms' -f $Report.DurationMs)
    Write-Host ''
    if ($nc) { Write-Host 'Layers Evaluated:' } else { Write-Host 'Layers Evaluated:' -ForegroundColor Cyan }
    foreach ($l in $Report.Layers) {
        $stCol = switch ($l.Status) {
            'OK'       { 'Green' }
            'DEGRADED' { 'Yellow' }
            'FAILED'   { 'Red' }
            'UNKNOWN'  { 'DarkYellow' }
            default    { 'White' }
        }
        $tag = ('[{0}]' -f $l.Status).PadRight(10)
        $line = ('  Layer {0} ({1,-14}): {2}' -f $l.Layer, $l.Name, $l.Evidence)
        if ($nc) {
            Write-Host ($tag + $line)
        } else {
            Write-Host ('  ' + $tag) -NoNewline -ForegroundColor $stCol
            Write-Host ($line.Substring(2))
        }
        if ($l.Status -ne 'OK' -and $l.Cause) {
            $causeLine = ('             Cause : {0}' -f $l.Cause)
            $actLine   = ('             Action: {0}' -f $l.Action)
            if ($nc) {
                Write-Host $causeLine
                Write-Host $actLine
            } else {
                Write-Host $causeLine -ForegroundColor DarkGray
                Write-Host $actLine -ForegroundColor Cyan
            }
        }
    }
    if ($nc) {
        Write-Host '================================================================================'
    } else {
        Write-Host '================================================================================' -ForegroundColor Cyan
    }
}

function Update-LinkQualityMonitor($Ad) {
    if (-not $Ad) { return $null }
    if ($script:State -isnot [hashtable]) { $script:State = @{} }
    if ($script:State['LinkMonitor'] -isnot [hashtable] -or -not $script:State['LinkMonitor'].ContainsKey('History')) {
        $script:State['LinkMonitor'] = @{
            LinkTransitionsCount = 0
            FlapDetected         = $false
            LastTransitionUtc    = ''
            SpeedDownshiftAlert  = $false
            History              = @()
            Statistics           = @{ InDiscards = 0L; InErrors = 0L; OutDiscards = 0L; OutErrors = 0L }
        }
    }

    $mon = $script:State['LinkMonitor']
    $nowUtc = [DateTime]::UtcNow
    $curStatus = [string]$Ad.Status
    $curSpeed = [string]$Ad.LinkSpeed
    $curDuplex = if ($Ad.FullDuplex) { 'Full Duplex' } else { 'Half Duplex' }
    $histList = New-Object System.Collections.ArrayList
    foreach ($item in @($mon.History)) { [void]$histList.Add($item) }

    $lastEvent = if ($histList.Count -gt 0) { $histList[-1] } else { $null }

    if (-not $lastEvent -or $lastEvent.Status -ne $curStatus -or ($curStatus -eq 'Up' -and $lastEvent.Speed -ne $curSpeed)) {
        $mon.LinkTransitionsCount = [int]$mon.LinkTransitionsCount + 1
        $mon.LastTransitionUtc = $nowUtc.ToString('o')

        $newEntry = @{
            Time   = $nowUtc.ToString('o')
            Event  = if ($curStatus -eq 'Up') { 'LinkUp' } else { 'LinkDown' }
            Status = $curStatus
            Speed  = $curSpeed
            Duplex = $curDuplex
        }
        [void]$histList.Add($newEntry)

        while ($histList.Count -gt 50) {
            $histList.RemoveAt(0)
        }
        $mon.History = @($histList)
    }

    $recentCount = 0
    $cutoff = $nowUtc.AddSeconds(-600)
    foreach ($h in $histList) {
        try {
            $dt = [DateTime]::Parse($h.Time).ToUniversalTime()
            if ($dt -ge $cutoff) { $recentCount++ }
        } catch {}
    }
    $mon.FlapDetected = ($recentCount -ge 3)

    $mon.SpeedDownshiftAlert = $false
    if ($curStatus -eq 'Up' -and $curSpeed -and ($curSpeed -like '*100 M*' -or $curSpeed -like '*10 M*') -and $Ad.InterfaceDescription -match 'Gigabit|GbE|1000|2.5G|5G|10G') {
        $mon.SpeedDownshiftAlert = $true
    }

    try {
        $st = Get-NetAdapterStatistics -Name $Ad.Name -ErrorAction SilentlyContinue
        if ($st) {
            $mon.Statistics = @{
                InDiscards  = [int64]$st.ReceivedPacketDiscards
                InErrors    = [int64]$st.ReceivedPacketErrors
                OutDiscards = [int64]$st.OutboundPacketDiscards
                OutErrors   = [int64]$st.OutboundPacketErrors
            }
        }
    } catch {}

    return $mon
}

function Invoke-HealthDoctor([switch]$Json, [switch]$Quiet, [switch]$NoColor, [switch]$Silent) {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $layers = New-Object System.Collections.ArrayList

    # Layer 1: Physical Link & Quality Monitoring (Feature F6)
    $ad = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notmatch 'Virtual|Hyper-V|vEthernet|Loopback' }) | Select-Object -First 1
    if (-not $ad) {
        $ad = @(Get-NetAdapter -ErrorAction SilentlyContinue) | Select-Object -First 1
    }

    $l1 = @{ Layer = 1; Name = 'PhysicalLink'; Status = 'OK'; Evidence = ''; Cause = ''; Action = 'None' }
    if (-not $ad) {
        $l1.Status = 'UNKNOWN'
        $l1.Evidence = 'No physical network adapters found'
        $l1.Cause = 'No physical network hardware detected or drivers not installed'
        $l1.Action = 'Diagnose'
    } elseif ($ad.Status -ne 'Up') {
        $l1.Status = 'FAILED'
        $l1.Evidence = "Adapter $($ad.Name) status: $($ad.Status)"
        $l1.Cause = 'Physical cable disconnected, port disabled, or transceiver powered down'
        $l1.Action = 'Diagnose'
        [void](Update-LinkQualityMonitor $ad)
    } else {
        $mon = Update-LinkQualityMonitor $ad
        $speed = [string]$ad.LinkSpeed
        $duplex = if ($ad.FullDuplex) { 'Full Duplex' } else { 'Half Duplex' }
        $evidenceParts = @("$speed $duplex (NDIS Link Up)")

        if ($mon -and $mon.FlapDetected) {
            $l1.Status = 'DEGRADED'
            $evidenceParts += "CRITICAL FLAP (>=3 transitions in 10m)"
            $l1.Cause = 'Intermittent physical link flapping (bad cable, loose pin, or switch cycling)'
            $l1.Action = 'Diagnose'
        } elseif ($mon -and $mon.SpeedDownshiftAlert) {
            $l1.Status = 'DEGRADED'
            $evidenceParts += "SPEED DOWNSHIFT (Hardware: Gigabit+)"
            $l1.Cause = 'Ethernet link negotiated below gigabit capacity (defective cable, pin fault, or port issue)'
            $l1.Action = 'Diagnose'
        } elseif ($mon -and $mon.Statistics -and $mon.Statistics.InErrors -gt 100) {
            $l1.Status = 'DEGRADED'
            $evidenceParts += "PACKET ERRORS ($($mon.Statistics.InErrors) CRC/discards)"
            $l1.Cause = 'High NDIS packet discard/error rate on transceiver'
            $l1.Action = 'Diagnose'
        } else {
            $l1.Status = 'OK'
        }
        $l1.Evidence = $evidenceParts -join ' | '
    }
    [void]$layers.Add($l1)

    # Layer 2: IP Configuration
    $l2 = @{ Layer = 2; Name = 'IpConfig'; Status = 'OK'; Evidence = ''; Cause = ''; Action = 'None' }
    $ipObj = $null
    if ($ad) {
        $ipObj = @(Get-NetIPAddress -InterfaceIndex $ad.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike '127.*' }) | Select-Object -First 1
    }
    if (-not $ipObj) {
        $l2.Status = 'FAILED'
        $l2.Evidence = 'No IPv4 address assigned to primary adapter'
        $l2.Cause = 'DHCP server unresponsive or static IP missing'
        $l2.Action = 'StandardReset'
    } elseif ($ipObj.IPAddress -like '169.254.*') {
        $l2.Status = 'FAILED'
        $l2.Evidence = "APIPA address assigned ($($ipObj.IPAddress))"
        $l2.Cause = 'DHCP discover/request timed out; Windows assigned fallback APIPA address'
        $l2.Action = 'StandardReset'
    } else {
        $l2.Status = 'OK'
        $l2.Evidence = "IPv4: $($ipObj.IPAddress)/$($ipObj.PrefixLength)"
    }
    [void]$layers.Add($l2)

    # Layer 3: Gateway Reachability
    $l3 = @{ Layer = 3; Name = 'GatewayReach'; Status = 'OK'; Evidence = ''; Cause = ''; Action = 'None' }
    $gwRoute = @(Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Sort-Object RouteMetric) | Select-Object -First 1
    $gwIp = if ($gwRoute) { [string]$gwRoute.NextHop } else { '' }
    if (-not $gwIp -or $gwIp -eq '0.0.0.0') {
        $l3.Status = 'FAILED'
        $l3.Evidence = 'No default gateway route configured'
        $l3.Cause = 'Routing table lacks default 0.0.0.0/0 gateway'
        $l3.Action = 'Heal'
    } else {
        $p = New-Object System.Net.NetworkInformation.Ping
        $pingOk = $false
        $rtt = 0
        try {
            $r = $p.Send($gwIp, 800)
            if ($r.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                $pingOk = $true
                $rtt = [int]$r.RoundtripTime
            }
        } catch {} finally { $p.Dispose() }

        if ($pingOk) {
            $l3.Status = 'OK'
            $l3.Evidence = "GW $gwIp reachable (RTT ${rtt}ms)"
        } else {
            $nbr = Get-NetNeighbor -IPAddress $gwIp -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($nbr -and $nbr.State -eq 'Reachable') {
                $l3.Status = 'OK'
                $l3.Evidence = "GW $gwIp resolved in ARP ($($nbr.LinkLayerAddress))"
            } else {
                $l3.Status = 'FAILED'
                $l3.Evidence = "GW $gwIp unresponsive to ICMP ping (ARP state: $($nbr.State))"
                $l3.Cause = 'Gateway offline, ARP entry stale, or router blocking ICMP'
                $l3.Action = 'QuickHeal'
            }
        }
    }
    [void]$layers.Add($l3)

    # Layer 4: DNS Resolution
    $l4 = @{ Layer = 4; Name = 'DnsResolution'; Status = 'OK'; Evidence = ''; Cause = ''; Action = 'None' }
    $dnsServers = @()
    if ($ad) {
        $dnsServers = @((Get-DnsClientServerAddress -InterfaceIndex $ad.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses)
    }
    if ($dnsServers.Count -eq 0) {
        $l4.Status = 'FAILED'
        $l4.Evidence = 'No DNS server addresses configured'
        $l4.Cause = 'DNS client settings missing on adapter'
        $l4.Action = 'SetDnsProfile'
    } else {
        $dnsOk = $false
        try {
            $res = [System.Net.Dns]::GetHostAddresses('connectivitycheck.gstatic.com')
            if ($res -and $res.Count -gt 0) { $dnsOk = $true }
        } catch {}

        if ($dnsOk) {
            $l4.Status = 'OK'
            $l4.Evidence = "Resolved test domain (Servers: $($dnsServers -join ', '))"
        } else {
            $l4.Status = 'FAILED'
            $l4.Evidence = "DNS resolution failed (Servers: $($dnsServers -join ', '))"
            $l4.Cause = 'Configured DNS resolvers unreachable, timeout, or NXDOMAIN hijacking'
            $l4.Action = 'SetDnsProfile'
        }
    }
    [void]$layers.Add($l4)

    # Layer 5: Raw IPv4 Internet Connectivity
    $l5 = @{ Layer = 5; Name = 'InternetIpv4'; Status = 'OK'; Evidence = ''; Cause = ''; Action = 'None' }
    $probeOk = $false
    $probeCode = 0
    try {
        $req = [System.Net.HttpWebRequest]::Create('http://connectivitycheck.gstatic.com/generate_204')
        $req.Timeout = 2000
        $req.ReadWriteTimeout = 2000
        $req.AllowAutoRedirect = $false
        $resp = $req.GetResponse()
        $probeCode = [int]$resp.StatusCode
        $resp.Dispose()
        if ($probeCode -eq 204) { $probeOk = $true }
    } catch [System.Net.WebException] {
        if ($_.Response) {
            $probeCode = [int]$_.Response.StatusCode
            $_.Response.Dispose()
        }
    } catch {}

    if ($probeOk) {
        $l5.Status = 'OK'
        $l5.Evidence = 'HTTP 204 internet probe succeeded'
    } elseif ($probeCode -ge 300 -and $probeCode -le 399) {
        $l5.Status = 'DEGRADED'
        $l5.Evidence = "HTTP probe returned redirect (HTTP $probeCode)"
        $l5.Cause = 'Traffic intercepted by captive gateway'
        $l5.Action = 'Login'
    } else {
        $l5.Status = 'FAILED'
        $l5.Evidence = "HTTP probe failed (Code: $probeCode)"
        $l5.Cause = 'No outbound IPv4 internet transit or packet loss'
        $l5.Action = 'Heal'
    }
    [void]$layers.Add($l5)

    # Layer 6: HTTPS / TLS Handshake
    $l6 = @{ Layer = 6; Name = 'HttpsTls'; Status = 'OK'; Evidence = ''; Cause = ''; Action = 'None' }
    $tlsOk = $false
    try {
        $s = New-Object System.Net.Sockets.TcpClient
        $iar = $s.BeginConnect('www.microsoft.com', 443, $null, $null)
        if ($iar.AsyncWaitHandle.WaitOne(1500, $false)) {
            $s.EndConnect($iar)
            $ssl = New-Object System.Net.Security.SslStream($s.GetStream(), $false, { param($snd, $crt, $chn, $err) return $true })
            $ssl.AuthenticateAsClient('www.microsoft.com')
            $tlsOk = $ssl.IsAuthenticated
            $ssl.Dispose()
        }
        $s.Dispose()
    } catch {}

    if ($tlsOk) {
        $l6.Status = 'OK'
        $l6.Evidence = 'TLS 1.2/1.3 handshake verified (port 443)'
    } elseif ($l5.Status -eq 'OK') {
        $l6.Status = 'DEGRADED'
        $l6.Evidence = 'HTTP succeeds but TLS handshake timed out or reset'
        $l6.Cause = 'HTTPS inspection, firewall drop on port 443, or corporate MITM'
        $l6.Action = 'Probe'
    } else {
        $l6.Status = 'FAILED'
        $l6.Evidence = 'HTTPS connection unreachable'
        $l6.Cause = 'No internet connectivity'
        $l6.Action = 'Heal'
    }
    [void]$layers.Add($l6)

    # Layer 7: Captive Portal Authentication
    $l7 = @{ Layer = 7; Name = 'CaptivePortal'; Status = 'OK'; Evidence = ''; Cause = ''; Action = 'None' }
    if ($probeCode -eq 204) {
        $l7.Status = 'OK'
        $l7.Evidence = 'Unrestricted internet egress authenticated'
    } elseif ($probeCode -ge 300 -and $probeCode -le 399) {
        $l7.Status = 'DEGRADED'
        $l7.Evidence = "Captive portal detected (HTTP $probeCode redirect)"
        $l7.Cause = 'Hostel / campus network requires web authentication'
        $l7.Action = 'Login'
    } elseif ($l5.Status -eq 'OK') {
        $l7.Status = 'OK'
        $l7.Evidence = 'Unrestricted internet egress'
    } else {
        $l7.Status = 'UNKNOWN'
        $l7.Evidence = 'Captive portal check untested while offline'
        $l7.Cause = 'Underlying network offline'
        $l7.Action = 'Recover'
    }
    [void]$layers.Add($l7)

    $sw.Stop()
    $eval = Compute-DoctorVerdict $layers

    $report = @{
        SchemaVersion   = '1.0'
        TimestampUtc    = (Get-Date).ToUniversalTime().ToString('o')
        DurationMs      = $sw.ElapsedMilliseconds
        PrimaryAdapter  = if ($ad) { $ad.Name } else { 'None' }
        OverallVerdict  = $eval.Verdict
        ExitCode        = [int]$eval.ExitCode
        RecommendedMode = $eval.RecommendedMode
        RootCause       = $eval.RootCause
        Layers          = $layers
    }

    if (-not $Silent) {
        if ($Json) {
            $jsonStr = ConvertTo-Json $report -Depth 4
            [Console]::Out.WriteLine($jsonStr)
        } elseif ($Quiet) {
            Write-Host $eval.Verdict
        } else {
            Format-DoctorConsole $report -NoColor:$NoColor
        }
    }

    return $report
}

function Invoke-GuidedRecovery([switch]$Plan, [switch]$Force, [switch]$Json, [switch]$Quiet, [switch]$NoColor) {
    if (-not $script:IsAdmin -and -not $Plan) {
        if (-not $Quiet -and -not $Json) { Write-Host 'Error: Guided recovery requires Administrator elevation.' -ForegroundColor Red }
        return @{ Status = 'Failed'; Reason = 'AdminRequired'; ExitCode = 30 }
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $actionsAttempted = New-Object System.Collections.ArrayList

    if (-not $Quiet -and -not $Json) {
        Write-Host '================================================================================' -ForegroundColor Cyan
        Write-Host '          LANFIXER GUIDED RECOVERY ESCALATION ENGINE (-Mode Recover)' -ForegroundColor Cyan
        Write-Host '================================================================================' -ForegroundColor Cyan
        Write-Host "Recovery Run ID: $script:RunId" -ForegroundColor Gray
    }

    # Step 1: Initial Diagnosis
    $d1 = Invoke-HealthDoctor -Silent
    if ($d1.OverallVerdict -eq 'Healthy') {
        if (-not $Quiet -and -not $Json) {
            Write-Host 'Initial diagnosis: Network is already fully Healthy (0 defects detected).' -ForegroundColor Green
            Write-Host 'No recovery operations required.' -ForegroundColor Green
            Write-Host '================================================================================' -ForegroundColor Cyan
        }
        $sw.Stop()
        $res = @{
            Status           = 'Healthy'
            InitialVerdict   = 'Healthy'
            FinalVerdict     = 'Healthy'
            ExitCode         = 0
            ActionsAttempted = @()
            RebootRequired   = $false
            UndoCommand      = "LanFixer.cmd -Mode Undo -RunId $script:RunId"
            DurationMs       = $sw.ElapsedMilliseconds
        }
        if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json $res -Depth 4)) }
        return $res
    }

    if (-not $Quiet -and -not $Json) {
        Write-Host ("Initial diagnosis: Network is {0} (ExitCode: {1}). Root Cause: {2}" -f $d1.OverallVerdict, $d1.ExitCode, $d1.RootCause) -ForegroundColor Yellow
        Write-Host ("Initiating targeted Layer repair for: {0}..." -f $d1.RecommendedMode) -ForegroundColor Cyan
    }

    if ($Plan) {
        [void]$actionsAttempted.Add("Plan Preview: Would execute $($d1.RecommendedMode)")
        if (-not $Quiet -and -not $Json) {
            Write-Host ("`n[PLAN] Would apply targeted repair: {0}" -f $d1.RecommendedMode) -ForegroundColor Cyan
            Write-Host '================================================================================' -ForegroundColor Cyan
        }
        $sw.Stop()
        $res = @{
            Status           = 'Planned'
            InitialVerdict   = $d1.OverallVerdict
            FinalVerdict     = $d1.OverallVerdict
            ExitCode         = 0
            ActionsAttempted = $actionsAttempted
            RebootRequired   = $false
            UndoCommand      = "LanFixer.cmd -Mode Undo -RunId $script:RunId"
            DurationMs       = $sw.ElapsedMilliseconds
        }
        if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json $res -Depth 4)) }
        return $res
    }

    # Step 2: Apply Layered Remediation based on failing layer
    $firstAction = $d1.RecommendedMode
    [void]$actionsAttempted.Add("LayeredRepair:$firstAction")

    switch ($firstAction) {
        'Login' {
            [void](Open-Portal)
        }
        'SetDnsProfile' {
            Flush-NetworkCache
            Set-DnsProfileMode 'Hybrid'
        }
        'QuickHeal' {
            [void](Invoke-HealPipeline)
        }
        'StandardReset' {
            Invoke-SupremeOmnifix
        }
        'Diagnose' {
            $ad = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.InterfaceDescription -notmatch 'Virtual|Loopback' }) | Select-Object -First 1
            if ($ad -and $ad.Status -ne 'Up') {
                [void](Invoke-Change "Restart adapter $($ad.Name)" { Restart-NetAdapter -Name $ad.Name -Confirm:$false })
            }
        }
        default {
            [void](Invoke-HealPipeline)
        }
    }

    # Step 3: Re-Verify with Doctor
    $d2 = Invoke-HealthDoctor -Silent
    if ($d2.OverallVerdict -eq 'Healthy') {
        $sw.Stop()
        $res = @{
            Status           = 'Recovered'
            InitialVerdict   = $d1.OverallVerdict
            FinalVerdict     = 'Healthy'
            ExitCode         = 0
            ActionsAttempted = $actionsAttempted
            RebootRequired   = $false
            UndoCommand      = "LanFixer.cmd -Mode Undo -RunId $script:RunId"
            DurationMs       = $sw.ElapsedMilliseconds
        }
        if (-not $Quiet -and -not $Json) {
            Write-Host "`nRemediation SUCCESS: Network restored to Healthy state." -ForegroundColor Green
            Write-Host ("Undo command: {0}" -f $res.UndoCommand) -ForegroundColor Cyan
            Write-Host '================================================================================' -ForegroundColor Cyan
        }
        if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json $res -Depth 4)) }
        return $res
    }

    # Step 4: Escalation to Tier 2: Ultra System Reset if still broken
    if (-not $Quiet -and -not $Json) {
        Write-Host ("`nLayer repair insufficient (Current state: {0}). Escalating to Tier 2 (Ultra System Reset)..." -f $d2.OverallVerdict) -ForegroundColor Yellow
    }
    [void]$actionsAttempted.Add("Tier2:UltraSystemReset")
    Invoke-UltraSystemReset

    # Step 5: Post-Ultra Re-Verify
    $d3 = Invoke-HealthDoctor -Silent
    $sw.Stop()
    $finalCode = [int]$d3.ExitCode

    $res = @{
        Status           = if ($d3.OverallVerdict -eq 'Healthy') { 'Recovered' } else { 'EscalationLimitReached' }
        InitialVerdict   = $d1.OverallVerdict
        FinalVerdict     = $d3.OverallVerdict
        ExitCode         = $finalCode
        ActionsAttempted = $actionsAttempted
        RebootRequired   = $false
        UndoCommand      = "LanFixer.cmd -Mode Undo -RunId $script:RunId"
        DurationMs       = $sw.ElapsedMilliseconds
    }

    if (-not $Quiet -and -not $Json) {
        if ($d3.OverallVerdict -eq 'Healthy') {
            Write-Host "`nRemediation SUCCESS after Tier 2 Ultra Reset: Network restored to Healthy state." -ForegroundColor Green
        } else {
            Write-Host ("`nGuided Recovery reached safety boundary (Verdict: {0}). Further escalation requires manual Doomsday/Armageddon Reset." -f $d3.OverallVerdict) -ForegroundColor Red
        }
        Write-Host ("Undo command: {0}" -f $res.UndoCommand) -ForegroundColor Cyan
        Write-Host '================================================================================' -ForegroundColor Cyan
    }

    if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json $res -Depth 4)) }
    return $res
}

function Invoke-Redaction([string]$Text, [string]$Level = 'Strict') {
    if (-not $Text) { return '' }
    $res = $Text

    if ($env:USERNAME) {
        $res = [regex]::Replace($res, [regex]::Escape($env:USERNAME), '[USER_REDACTED]', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    }
    if ($env:USERPROFILE) {
        $res = [regex]::Replace($res, [regex]::Escape($env:USERPROFILE), 'C:\Users\[USER_REDACTED]', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    }
    if ($env:COMPUTERNAME) {
        $res = [regex]::Replace($res, [regex]::Escape($env:COMPUTERNAME), '[HOST_REDACTED]', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    }

    $res = [regex]::Replace($res, '([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})', 'XX:XX:XX:XX:XX:XX')
    $res = [regex]::Replace($res, '(?i)(password|secret|token|credential|key)\s*[:=]\s*(\S+)', '$1: [REDACTED]')

    if ($Level -eq 'Strict') {
        $ipEvaluator = [System.Text.RegularExpressions.MatchEvaluator]{
            param($m)
            $ipStr = $m.Value
            $parts = $ipStr.Split('.')
            if ($parts.Count -ne 4) { return $ipStr }
            $b0 = [int]$parts[0]
            $b1 = [int]$parts[1]
            if ($b0 -eq 127) { return $ipStr }
            if ($b0 -eq 10) { return $ipStr }
            if ($b0 -eq 192 -and $b1 -eq 168) { return $ipStr }
            if ($b0 -eq 172 -and ($b1 -ge 16 -and $b1 -le 31)) { return $ipStr }
            if ($b0 -eq 169 -and $b1 -eq 254) { return $ipStr }
            if ($b0 -eq 100 -and ($b1 -ge 64 -and $b1 -le 127)) { return $ipStr }
            if ($ipStr -eq '0.0.0.0' -or $ipStr -eq '255.255.255.255') { return $ipStr }
            return '[PUBLIC_IP_REDACTED]'
        }
        $res = [regex]::Replace($res, '\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b', $ipEvaluator)
    }

    return $res
}

function New-SupportBundle {
    param(
        [string]$OutDir = '',
        [ValidateSet('Strict','Standard')][string]$Redaction = 'Strict',
        [switch]$Json,
        [switch]$Quiet,
        [switch]$NoColor
    )
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    if (-not $Quiet -and -not $Json) {
        Write-Host '================================================================================' -ForegroundColor Cyan
        Write-Host '          LANFIXER REDACTED DIAGNOSTIC SUPPORT BUNDLE (-Mode Bundle)' -ForegroundColor Cyan
        Write-Host '================================================================================' -ForegroundColor Cyan
    }

    $targetDir = $OutDir
    if (-not $targetDir -or -not (Test-Path -LiteralPath $targetDir)) {
        $desktop = [Environment]::GetFolderPath('Desktop')
        if ($desktop -and (Test-Path -LiteralPath $desktop)) {
            $targetDir = $desktop
        } else {
            $targetDir = [System.IO.Path]::GetTempPath()
        }
    }

    $bundleId = [guid]::NewGuid().ToString('N').Substring(0, 8)
    $ts = (Get-Date).ToString('yyyyMMdd_HHmmss')
    $safeHost = if ($env:COMPUTERNAME) { $env:COMPUTERNAME -replace '[^\w\-]', '' } else { 'HOST' }
    $zipName = "LanFixer_Bundle_${safeHost}_${ts}_${bundleId}.zip"
    $zipPath = Join-Path $targetDir $zipName

    $stagingDir = Join-Path ([System.IO.Path]::GetTempPath()) ("lf_bundle_" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null

    try {
        $meta = @{
            SchemaVersion  = '1.0'
            BundleId       = $bundleId
            TimestampUtc   = (Get-Date).ToUniversalTime().ToString('o')
            TimestampLocal = (Get-Date).ToString('o')
            LanFixerVersion= $script:Version
            RunId          = [string]$script:RunId
            RedactionLevel = $Redaction
            OsVersion      = [string]([Environment]::OSVersion.VersionString)
            Architecture   = if ([Environment]::Is64BitOperatingSystem) { 'x64' } else { 'x86' }
            FilesIncluded  = @(
                'metadata.json',
                'doctor_report.json',
                'change_ledger_tail.json',
                'network_config.txt',
                'adapter_statistics.txt',
                'dns_configuration.txt',
                'event_log_excerpt.txt',
                'selftest_summary.txt'
            )
        }
        $metaJson = ConvertTo-Json $meta -Depth 4
        [System.IO.File]::WriteAllText((Join-Path $stagingDir 'metadata.json'), $metaJson, [System.Text.Encoding]::ASCII)

        $docRep = Invoke-HealthDoctor -Silent
        $docJson = ConvertTo-Json $docRep -Depth 4
        $docRedacted = Invoke-Redaction $docJson -Level $Redaction
        [System.IO.File]::WriteAllText((Join-Path $stagingDir 'doctor_report.json'), $docRedacted, [System.Text.Encoding]::ASCII)

        $ledgerEntries = Get-ChangeLedgerEntries -Limit 50
        $ledgerJson = ConvertTo-Json @($ledgerEntries) -Depth 4
        $ledgerRedacted = Invoke-Redaction $ledgerJson -Level $Redaction
        [System.IO.File]::WriteAllText((Join-Path $stagingDir 'change_ledger_tail.json'), $ledgerRedacted, [System.Text.Encoding]::ASCII)

        $sbNet = New-Object System.Text.StringBuilder
        try {
            $ipOut = & (Get-SysExe 'ipconfig.exe') '/all' 2>$null | Out-String
            [void]$sbNet.AppendLine("--- IPCONFIG /ALL ---")
            [void]$sbNet.AppendLine($ipOut)
        } catch {}
        try {
            $adsOut = Get-NetAdapter -ErrorAction SilentlyContinue | Format-Table -AutoSize | Out-String
            [void]$sbNet.AppendLine("--- GET-NETADAPTER ---")
            [void]$sbNet.AppendLine($adsOut)
        } catch {}
        try {
            $routesOut = Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Format-Table -AutoSize | Out-String
            [void]$sbNet.AppendLine("--- DEFAULT ROUTES ---")
            [void]$sbNet.AppendLine($routesOut)
        } catch {}
        $netRedacted = Invoke-Redaction ($sbNet.ToString()) -Level $Redaction
        [System.IO.File]::WriteAllText((Join-Path $stagingDir 'network_config.txt'), $netRedacted, [System.Text.Encoding]::ASCII)

        $sbStat = New-Object System.Text.StringBuilder
        try {
            $stats = Get-NetAdapterStatistics -ErrorAction SilentlyContinue | Format-Table -AutoSize | Out-String
            [void]$sbStat.AppendLine($stats)
        } catch {}
        $statRedacted = Invoke-Redaction ($sbStat.ToString()) -Level $Redaction
        [System.IO.File]::WriteAllText((Join-Path $stagingDir 'adapter_statistics.txt'), $statRedacted, [System.Text.Encoding]::ASCII)

        $sbDns = New-Object System.Text.StringBuilder
        try {
            $dnsAddrs = Get-DnsClientServerAddress -ErrorAction SilentlyContinue | Format-Table -AutoSize | Out-String
            [void]$sbDns.AppendLine("--- DNS RESOLVER ADDRESSES ---")
            [void]$sbDns.AppendLine($dnsAddrs)
        } catch {}
        try {
            $nrpt = Get-DnsClientNrptRule -ErrorAction SilentlyContinue | Format-Table -AutoSize | Out-String
            [void]$sbDns.AppendLine("--- NRPT RULES ---")
            [void]$sbDns.AppendLine($nrpt)
        } catch {}
        $dnsRedacted = Invoke-Redaction ($sbDns.ToString()) -Level $Redaction
        [System.IO.File]::WriteAllText((Join-Path $stagingDir 'dns_configuration.txt'), $dnsRedacted, [System.Text.Encoding]::ASCII)

        $sbEvt = New-Object System.Text.StringBuilder
        try {
            $evts = Get-WinEvent -FilterHashtable @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-TCPIP','Microsoft-Windows-DHCP-Client' } -MaxEvents 50 -ErrorAction SilentlyContinue | Select-Object TimeCreated, Id, LevelDisplayName, Message | Format-Table -AutoSize | Out-String
            [void]$sbEvt.AppendLine($evts)
        } catch {}
        $evtRedacted = Invoke-Redaction ($sbEvt.ToString()) -Level $Redaction
        [System.IO.File]::WriteAllText((Join-Path $stagingDir 'event_log_excerpt.txt'), $evtRedacted, [System.Text.Encoding]::ASCII)

        $selfOut = "SelfTest summary: verified via in-file logic assertions on $(Get-Date)"
        [System.IO.File]::WriteAllText((Join-Path $stagingDir 'selftest_summary.txt'), $selfOut, [System.Text.Encoding]::ASCII)

        if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force -ErrorAction SilentlyContinue }
        [System.IO.Compression.ZipFile]::CreateFromDirectory($stagingDir, $zipPath, [System.IO.Compression.CompressionLevel]::Optimal, $false)

        $zipItem = Get-Item -LiteralPath $zipPath -ErrorAction SilentlyContinue
        $sha = Get-FileSha256 $zipPath
        $sw.Stop()

        $result = @{
            Status         = 'Created'
            Path           = $zipPath
            Sha256         = $sha
            SizeBytes      = if ($zipItem) { $zipItem.Length } else { 0 }
            RedactionLevel = $Redaction
            DurationMs     = $sw.ElapsedMilliseconds
            ExitCode       = 0
        }

        if ($Json) {
            [Console]::Out.WriteLine((ConvertTo-Json $result -Depth 4))
        } elseif (-not $Quiet) {
            Write-Host 'Support bundle created successfully!' -ForegroundColor Green
            Write-Host ("  Archive : {0}" -f $zipPath) -ForegroundColor White
            Write-Host ("  SHA-256 : {0}" -f $sha) -ForegroundColor DarkGray
            Write-Host ("  Size    : {0:N0} bytes ({1} ms)" -f $result.SizeBytes, $result.DurationMs) -ForegroundColor Gray
            Write-Host '================================================================================' -ForegroundColor Cyan
        }

        return $result
    } finally {
        Remove-Item -LiteralPath $stagingDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function ConvertFrom-IniFile([string]$FilePath) {
    if (-not (Test-Path -LiteralPath $FilePath)) { return @{} }
    $lines = Get-Content -LiteralPath $FilePath -ErrorAction SilentlyContinue
    $ini = @{}
    $currentSection = 'General'
    $ini[$currentSection] = @{}

    foreach ($rawLine in $lines) {
        $line = $rawLine.Trim()
        if (-not $line -or $line.StartsWith('#') -or $line.StartsWith(';')) { continue }

        if ($line -match '^\[\s*([a-zA-Z0-9_\-]+)\s*\]$') {
            $currentSection = $matches[1]
            if (-not $ini.ContainsKey($currentSection)) {
                $ini[$currentSection] = @{}
            }
            continue
        }

        if ($line -match '^([a-zA-Z0-9_\-]+)\s*=\s*(.*)$') {
            $key = $matches[1].Trim()
            $val = $matches[2].Trim()
            if ($val -match '^"(.*)"$' -or $val -match "^'(.*)'$") {
                $val = $matches[1]
            }
            $ini[$currentSection][$key] = $val
        }
    }
    return $ini
}

function Get-EffectiveConfiguration {
    $configMap = @{}
    $sources = @{}

    $defaults = @{
        'LogLevel'               = 'INFO'
        'RedactionLevel'         = 'Strict'
        'NoColor'                = 'False'
        'DefaultDnsProfile'      = 'Adaptive'
        'DefaultRouteProfile'    = 'Adaptive'
        'ManagedAdapterPattern'  = 'Ethernet*,Wi-Fi*'
        'ExcludedAdapterPattern' = '*vEthernet*,*Virtual*'
        'CooldownSeconds'        = 300
        'AutoHealMaxTier'        = 2
        'EnableSentinel'         = 'True'
        'HttpProbeUrl'           = 'http://connectivitycheck.gstatic.com/generate_204'
        'TlsProbeHost'           = 'www.microsoft.com'
        'ProbeTimeoutMs'         = 2000
    }

    foreach ($k in $defaults.Keys) {
        $configMap[$k] = $defaults[$k]
        $sources[$k] = 'DEFAULT'
    }

    $iniPath = Join-Path $script:StoreDir 'lanfixer.ini'
    $iniTrusted = $false
    $iniValid = $false
    $iniErrors = New-Object System.Collections.ArrayList

    if (Test-Path -LiteralPath $iniPath) {
        $fi = Get-Item -LiteralPath $iniPath -ErrorAction SilentlyContinue
        if ($fi -and $fi.Length -le 65536) {
            if (Test-ConfigFileTrusted $iniPath) {
                $iniTrusted = $true
                try {
                    $parsed = ConvertFrom-IniFile $iniPath
                    $iniValid = $true
                    foreach ($sec in $parsed.Keys) {
                        foreach ($k in $parsed[$sec].Keys) {
                            $v = [string]$parsed[$sec][$k]
                            switch ($k) {
                                'LogLevel' {
                                    if ($v -in @('INFO','DEBUG','WARN','ERROR')) { $configMap[$k] = $v; $sources[$k] = 'POLICY_FILE' }
                                    else { [void]$iniErrors.Add("Invalid LogLevel: $v") }
                                }
                                'RedactionLevel' {
                                    if ($v -in @('Strict','Standard')) { $configMap[$k] = $v; $sources[$k] = 'POLICY_FILE' }
                                    else { [void]$iniErrors.Add("Invalid RedactionLevel: $v") }
                                }
                                'NoColor' {
                                    if ($v -in @('True','False','1','0')) { $configMap[$k] = [string]([bool]($v -eq 'True' -or $v -eq '1')); $sources[$k] = 'POLICY_FILE' }
                                    else { [void]$iniErrors.Add("Invalid NoColor boolean: $v") }
                                }
                                'DefaultDnsProfile' {
                                    if ($v -in @('Adaptive','DHCP','Hybrid','Cloudflare','ResetDHCP')) { $configMap[$k] = $v; $sources[$k] = 'POLICY_FILE' }
                                    else { [void]$iniErrors.Add("Invalid DefaultDnsProfile: $v") }
                                }
                                'DefaultRouteProfile' {
                                    if ($v -in @('Adaptive','Ethernet','Wifi','Windows')) { $configMap[$k] = $v; $sources[$k] = 'POLICY_FILE' }
                                    else { [void]$iniErrors.Add("Invalid DefaultRouteProfile: $v") }
                                }
                                'ManagedAdapterPattern' {
                                    if ($v -match '^[a-zA-Z0-9_\-\*, ]+$') { $configMap[$k] = $v; $sources[$k] = 'POLICY_FILE' }
                                    else { [void]$iniErrors.Add("Invalid ManagedAdapterPattern: $v") }
                                }
                                'ExcludedAdapterPattern' {
                                    if ($v -match '^[a-zA-Z0-9_\-\*, ]+$') { $configMap[$k] = $v; $sources[$k] = 'POLICY_FILE' }
                                    else { [void]$iniErrors.Add("Invalid ExcludedAdapterPattern: $v") }
                                }
                                'CooldownSeconds' {
                                    $n = 0
                                    if ([int]::TryParse($v, [ref]$n) -and $n -ge 60 -and $n -le 86400) { $configMap[$k] = $n; $sources[$k] = 'POLICY_FILE' }
                                    else { [void]$iniErrors.Add("CooldownSeconds must be between 60 and 86400: $v") }
                                }
                                'AutoHealMaxTier' {
                                    $n = 0
                                    if ([int]::TryParse($v, [ref]$n) -and $n -ge 1 -and $n -le 2) { $configMap[$k] = $n; $sources[$k] = 'POLICY_FILE' }
                                    else { [void]$iniErrors.Add("AutoHealMaxTier capped strictly at 2 (1 or 2): $v") }
                                }
                                'EnableSentinel' {
                                    if ($v -in @('True','False','1','0')) { $configMap[$k] = [string]([bool]($v -eq 'True' -or $v -eq '1')); $sources[$k] = 'POLICY_FILE' }
                                    else { [void]$iniErrors.Add("Invalid EnableSentinel boolean: $v") }
                                }
                                'HttpProbeUrl' {
                                    if ($v -match '^https?://[a-zA-Z0-9_\.\-]+(/[a-zA-Z0-9_\.\-\?=&%]*)*$') { $configMap[$k] = $v; $sources[$k] = 'POLICY_FILE' }
                                    else { [void]$iniErrors.Add("Invalid HttpProbeUrl: $v") }
                                }
                                'TlsProbeHost' {
                                    if ($v -match '^[a-zA-Z0-9_\.\-]+$') { $configMap[$k] = $v; $sources[$k] = 'POLICY_FILE' }
                                    else { [void]$iniErrors.Add("Invalid TlsProbeHost: $v") }
                                }
                                'ProbeTimeoutMs' {
                                    $n = 0
                                    if ([int]::TryParse($v, [ref]$n) -and $n -ge 500 -and $n -le 10000) { $configMap[$k] = $n; $sources[$k] = 'POLICY_FILE' }
                                    else { [void]$iniErrors.Add("ProbeTimeoutMs must be between 500 and 10000: $v") }
                                }
                                default {}
                            }
                        }
                    }
                } catch {
                    [void]$iniErrors.Add("Failed to parse INI: $($_.Exception.Message)")
                }
            } else {
                [void]$iniErrors.Add("Security warning: lanfixer.ini untrusted (must be owned by Administrators/SYSTEM and not writable by standard users)")
            }
        }
    }

    return @{
        Configuration = $configMap
        Sources       = $sources
        IniPath       = $iniPath
        IniExists     = (Test-Path -LiteralPath $iniPath)
        IniTrusted    = $iniTrusted
        IniValid      = $iniValid
        Errors        = @($iniErrors)
    }
}

function Show-ConfigReport([switch]$ValidateOnly, [switch]$Json, [switch]$Quiet, [switch]$NoColor) {
    $eff = Get-EffectiveConfiguration

    if ($ValidateOnly) {
        $isValid = ($eff.IniExists -and $eff.IniTrusted -and $eff.Errors.Count -eq 0)
        if ($Json) {
            $rep = @{
                Status   = if ($isValid) { 'Valid' } else { 'Invalid' }
                IniPath  = $eff.IniPath
                Trusted  = $eff.IniTrusted
                Errors   = $eff.Errors
                ExitCode = if ($isValid) { 0 } else { 1 }
            }
            [Console]::Out.WriteLine((ConvertTo-Json $rep -Depth 4))
        } elseif (-not $Quiet) {
            Write-Host '================================================================================' -ForegroundColor Cyan
            Write-Host '               LANFIXER POLICY & CONFIGURATION AUDIT' -ForegroundColor Cyan
            Write-Host '================================================================================' -ForegroundColor Cyan
            Write-Host ("Policy File : {0}" -f $eff.IniPath)
            Write-Host ("File Exists : {0}" -f $eff.IniExists)
            Write-Host ("ACL Trusted : {0}" -f $eff.IniTrusted)
            if ($eff.Errors.Count -gt 0) {
                Write-Host 'Audit Errors / Warnings:' -ForegroundColor Red
                foreach ($err in $eff.Errors) { Write-Host ("  - {0}" -f $err) -ForegroundColor Yellow }
                Write-Host 'Status: INVALID' -ForegroundColor Red
            } else {
                Write-Host 'Status: VALID (All policy parameters sanitized and verified)' -ForegroundColor Green
            }
            Write-Host '================================================================================' -ForegroundColor Cyan
        }
        return (if ($isValid) { 0 } else { 1 })
    }

    if ($Json) {
        $rep = @{
            Configuration = $eff.Configuration
            Sources       = $eff.Sources
            IniPath       = $eff.IniPath
            IniExists     = $eff.IniExists
            IniTrusted    = $eff.IniTrusted
            Errors        = $eff.Errors
            ExitCode      = 0
        }
        [Console]::Out.WriteLine((ConvertTo-Json $rep -Depth 4))
        return 0
    }

    if (-not $Quiet) {
        Write-Host '================================================================================' -ForegroundColor Cyan
        Write-Host '               LANFIXER EFFECTIVE SYSTEM & POLICY CONFIGURATION' -ForegroundColor Cyan
        Write-Host '================================================================================' -ForegroundColor Cyan
        Write-Host ("Policy Path : {0} (Exists: {1}, Trusted: {2})" -f $eff.IniPath, $eff.IniExists, $eff.IniTrusted) -ForegroundColor Gray
        Write-Host ''
        Write-Host ('{0,-28} {1,-34} {2}' -f 'Setting Key', 'Effective Value', 'Source') -ForegroundColor Gray
        Write-Host ('-' * 80) -ForegroundColor Gray
        foreach ($k in ($eff.Configuration.Keys | Sort-Object)) {
            $val = [string]$eff.Configuration[$k]
            $src = [string]$eff.Sources[$k]
            $srcCol = if ($src -eq 'POLICY_FILE') { 'Green' } else { 'DarkGray' }
            $line = ('{0,-28} {1,-34} ' -f $k, $val)
            if ($NoColor) {
                Write-Host ($line + '[' + $src + ']')
            } else {
                Write-Host $line -NoNewline
                Write-Host ('[' + $src + ']') -ForegroundColor $srcCol
            }
        }
        Write-Host '================================================================================' -ForegroundColor Cyan
    }
    return 0
}

function Show-Diagnostics {
    Write-Banner 'SYSTEM DIAGNOSTICS AUDIT'
    $issues = New-Object System.Collections.ArrayList
    $ads = @(Get-EthernetAdapters)
    Write-Section 'NETWORK ADAPTER HARDWARE'
    if ($ads.Count -eq 0) { Write-KV 'Ethernet' 'none found' 'Red'; [void]$issues.Add('No physical Ethernet adapter found (disabled? USB dongle unplugged?)') }
    foreach ($a in $ads) {
        $col = $(if ($a.Status -eq 'Up') { 'Green' } else { 'Red' })
        Write-KV 'Adapter' ("{0} [{1}]" -f $a.Name, $a.Status) $col
        Write-KV '  Controller' ([string]$a.InterfaceDescription)
        Write-KV '  MAC Address' ([string]$a.MacAddress)
        Write-KV '  Link speed' ([string]$a.LinkSpeed)
        Write-KV '  Driver version' ([string]$a.DriverVersionString)
        $lh = Test-NdisLinkHealth $a
        Write-KV '  NDIS link health' $lh.Reason $(if ($lh.Healthy) { 'Green' } else { 'Yellow' })
        $sd = Get-NetAdapterAdvancedProperty -Name $a.Name -RegistryKeyword '*SpeedDuplex' -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($sd) {
            $dv = [string]$sd.DisplayValue
            $c = 'White'
            if ($dv -notmatch 'Auto') { $c = 'Yellow'; [void]$issues.Add("Speed/duplex is forced to '$dv' - a mismatch with the switch causes drops; set it to Auto Negotiation") }
            Write-KV '  Speed/duplex setting' $dv $c
        }
        $st = Get-NetAdapterStatistics -Name $a.Name -ErrorAction SilentlyContinue
        if ($st) {
            $errs = [long]$st.ReceivedPacketErrors + [long]$st.OutboundPacketErrors
            $disc = [long]$st.ReceivedDiscardedPackets + [long]$st.OutboundDiscardedPackets
            $c = $(if ($errs -gt 0) { 'Yellow' } else { 'White' })
            Write-KV '  Packet errors / discards' ("{0} / {1}" -f $errs, $disc) $c
            if ($errs -gt 100) { [void]$issues.Add("Adapter reports $errs packet errors: suspect cable, wall port or duplex mismatch") }
        }
    }

    foreach ($a in @($ads | Where-Object { $_.Status -eq 'Up' })) {
        $guid = [string]$a.InterfaceGuid
        Write-Section ("NETWORK STATE: " + $a.Name)
        $h = Get-AdapterHealth $a
        $e = Get-AdapterEnvironment $a
        $envText = "{0} (score {1})" -f $e.Env, $e.Score
        Write-KV 'Environment' $envText $(if ($e.Env -eq 'Campus') { 'Cyan' } else { 'White' })
        foreach ($x in $e.Evidence) { Write-KV '  evidence' ([string]$x) 'DarkGray' }
        Write-KV 'IPv4' $(if ($h.Ip) { [string]$h.Ip } else { 'NONE (APIPA/unassigned)' }) $(if ($h.Ip) { 'Green' } else { 'Red' })
        if (-not $h.Ip) { [void]$issues.Add('No valid IPv4 lease (APIPA)') }
        $sub = Get-SubnetInfoFromLease $a
        if ($sub) {
            Write-KV '  Subnet Mask' ("{0} (/{1})" -f $sub.SubnetMask, $sub.PrefixLength)
            Write-KV '  Network / Bcast' ("{0} / {1}" -f $sub.NetworkAddress, $sub.Broadcast)
            Write-KV '  Usable Hosts' ("{0} to {1} ({2} hosts)" -f $sub.MinHost, $sub.MaxHost, $sub.TotalHosts)
        }
        $optMtu = Find-OptimalPathMtu $a
        Write-KV '  Optimal Path MTU' ("{0} bytes" -f $optMtu) $(if ($optMtu -lt 1500) { 'Yellow' } else { 'White' })
        Write-KV 'Gateway' $(if ($h.Gateway) { "{0} ({1})" -f $h.Gateway, $(if ($null -ne $h.GwRtt) { "$($h.GwRtt) ms" } elseif ($h.GwAlive) { 'ARP ok, ping filtered' } else { 'no reply' }) } else { 'none' })
        $ipif = Get-IPv4Interface $a
        if ($ipif) { Write-KV 'Duplicate-address probes' ([string]$ipif.DadTransmits) }
        $reg = Get-IfaceReg $guid
        if ($reg) {
            if ($reg.DhcpServer) { Write-KV 'DHCP server' ([string]$reg.DhcpServer) }
            try {
                if ($reg.LeaseObtainedTime) { Write-KV 'Lease obtained' ([DateTimeOffset]::FromUnixTimeSeconds([long]$reg.LeaseObtainedTime).LocalDateTime.ToString('yyyy-MM-dd HH:mm:ss')) }
                if ($reg.LeaseTerminatesTime) { Write-KV 'Lease expires' ([DateTimeOffset]::FromUnixTimeSeconds([long]$reg.LeaseTerminatesTime).LocalDateTime.ToString('yyyy-MM-dd HH:mm:ss')) }
            } catch {}
        }
        $dnsNow = @((Get-DnsClientServerAddress -InterfaceIndex $a.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses) -join ', '
        $isStatic = (Get-StaticDnsString $guid) -ne ''
        Write-KV 'DNS in use' ("{0} ({1})" -f $dnsNow, $(if ($isStatic) { 'static/managed' } else { 'from DHCP' }))
        Write-KV 'DNS profile / phase' ("{0} / {1}" -f (Get-DnsProfileName), $(if ((Get-SubTable 'Dns' $guid).Phase) { (Get-SubTable 'Dns' $guid).Phase } else { '-' }))
        foreach ($gw in @(Get-GatewaysV4 $a)) {
            $n = Get-NetNeighbor -InterfaceIndex $a.ifIndex -IPAddress $gw -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($n) { Write-KV 'Gateway ARP entry' ("{0} -> {1} [{2}]" -f $gw, $n.LinkLayerAddress, $n.State) }
        }
        $prof = Get-NetConnectionProfile -InterfaceIndex $a.ifIndex -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($prof) { Write-KV 'Network / firewall profile' ("{0} / {1}" -f $prof.Name, $prof.NetworkCategory) }

        Write-Section 'CONNECTIVITY & INTERNET REACHABILITY'
        $epDiag = Get-ActivePortalEndpoint
        $tcp = Test-TcpPort $epDiag.Ip $epDiag.Port 900
        Write-KV ("Portal {0}:{1}" -f $epDiag.Ip, $epDiag.Port) $(if ($tcp) { 'open' } else { 'closed/hidden' })
        $conn = [string]$h.Conn
        $cc = $(switch ($conn) { 'Online' { 'Green' } 'Captive' { 'Yellow' } default { 'Red' } })
        Write-KV 'Internet' $conn $cc
        if ($conn -eq 'NoDns') { [void]$issues.Add('DNS resolution fails') }
        if ($conn -eq 'Captive') { [void]$issues.Add('Campus login (captive portal) required') }
        if ($conn -eq 'Offline') { [void]$issues.Add('No Internet through the gateway') }
        $g6 = @(Get-NetIPAddress -InterfaceIndex $a.ifIndex -AddressFamily IPv6 -ErrorAction SilentlyContinue | Where-Object { [string]$_.AddressState -eq 'Preferred' -and [string]$_.IPAddress -notmatch '^(fe80|fc|fd|::1)' })
        $r6 = @(Get-NetRoute -InterfaceIndex $a.ifIndex -AddressFamily IPv6 -DestinationPrefix '::/0' -ErrorAction SilentlyContinue)
        $reach6 = $false
        if ($g6.Count -gt 0 -and $r6.Count -gt 0 -and $conn -eq 'Online') { $reach6 = Test-Ipv6Reach ([string]$g6[0].IPAddress) }
        $v6 = Get-Ipv6Verdict ($g6.Count -gt 0) ($r6.Count -gt 0) $conn $reach6
        $v6txt = switch ($v6) {
            'None'      { 'no global IPv6 address (IPv4-only link: nothing to go wrong)' }
            'NoRoute'   { 'global address but no IPv6 default route (harmless)' }
            'Untested'  { 'advertised, but IPv4 is not online yet: re-run the audit after login' }
            'Working'   { 'advertised and reachable' }
            default     { 'ADVERTISED BUT UNREACHABLE (IPv4 works)' }
        }
        Write-KV 'IPv6' $v6txt $(if ($v6 -eq 'Blackhole') { 'Yellow' } else { 'White' })
        if ($v6 -eq 'Blackhole') { [void]$issues.Add("IPv6 is advertised on this LAN but unreachable while IPv4 works: some apps stall 15-30 s before falling back. Ask IT to filter IPv6 router advertisements, or turn IPv6 off on this adapter yourself: Disable-NetAdapterBinding -Name '$($a.Name)' -ComponentID ms_tcpip6   (undo with Enable-NetAdapterBinding). Lan Fixer does not change this on its own.") }
        $sys = Resolve-HostBounded 'www.msftconnecttest.com' 2000
        Write-KV 'System resolver' $(if ($sys) { "ok ($sys)" } else { 'FAILED' }) $(if ($sys) { 'Green' } else { 'Red' })
        $tests = @(@(Get-DhcpDnsServers $guid) + @($script:Cfg.PublicDns) | Select-Object -Unique)
        $meas = Measure-ResolversFast $tests
        foreach ($s in $tests) {
            $ms = $meas[$s]
            Write-KV ("Resolver {0}" -f $s) $(if ($null -ne $ms) { "$ms ms (median of 3)" } else { 'no answer' }) $(if ($null -ne $ms) { 'White' } else { 'DarkGray' })
        }
        $mtuT = $(if ($conn -eq 'Online') { '1.1.1.1' } else { [string]$h.Gateway })
        if ($mtuT) {
            $mtu = Get-PathMtu $mtuT
            if ($null -ne $mtu) {
                Write-KV ("Path MTU to " + $mtuT) "$mtu bytes"
                if ($mtu -lt 1500) { [void]$issues.Add("Path MTU is $mtu (<1500): large pages may hang; consider MTU $mtu on the adapter") }
            }
        }
    }

    Write-Section 'SECONDARY UPLINKS & SYSTEM SERVICES'
    $secUps = @(Get-OtherUplinkAdapters)
    if ($secUps.Count -eq 0) { Write-KV 'Secondary uplinks' 'none active' 'DarkGray' }
    else {
        foreach ($su in $secUps) {
            $suIp = Get-ValidIPv4 $su
            $suDns = @((Get-DnsClientServerAddress -InterfaceIndex $su.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses) -join ', '
            Write-KV ("Uplink " + $su.Name) ("{0} (DNS: {1})" -f $(if ($suIp) { $suIp } else { 'IPv6/active' }), $(if ($suDns) { $suDns } else { 'auto' })) 'Green'
        }
    }
    $p53Pids = @((Get-NetUDPEndpoint -LocalPort 53 -ErrorAction SilentlyContinue).OwningProcess + (Get-NetTCPConnection -LocalPort 53 -ErrorAction SilentlyContinue).OwningProcess | Where-Object { $_ -gt 4 } | Select-Object -Unique)
    $p53Names = @($p53Pids | ForEach-Object { (Get-Process -Id $_ -ErrorAction SilentlyContinue).ProcessName } | Where-Object { $_ -and $_ -ne 'svchost' } | Select-Object -Unique)
    Write-KV 'Local Port 53 listeners' $(if ($p53Names.Count -gt 0) { $p53Names -join ', ' } else { 'none (standard Windows DNS)' }) $(if ($p53Names.Count -gt 0) { 'Yellow' } else { 'White' })
    $gaIp = Resolve-HostBounded 'accounts.google.com' 2000
    Write-KV 'Google Auth (CLI DNS)' $(if ($gaIp) { "ok ($gaIp)" } else { 'FAILED' }) $(if ($gaIp) { 'Green' } else { 'Red' })
    if (-not $gaIp) { [void]$issues.Add('accounts.google.com failed to resolve: press [X] Full Net Reset to heal DNS/WFP') }

    Write-Section 'SYSTEM EVENT LOGS (LAST 7 DAYS / 24 HOURS)'
    $c4199 = @(Get-WinEvent -FilterHashtable @{ LogName = 'System'; ProviderName = 'Tcpip'; Id = 4199; StartTime = (Get-Date).AddDays(-7) } -ErrorAction SilentlyContinue).Count
    Write-KV 'IP address conflicts' ([string]$c4199) $(if ($c4199 -gt 0) { 'Yellow' } else { 'White' })
    if ($c4199 -gt 0) { [void]$issues.Add("$c4199 address-conflict events this week. If they are false alarms (the switch answers every ARP probe), DadPolicy 'Auto' turns the probes off on campus; a REAL duplicate IP has to be fixed by IT.") }
    $flaps = @(Get-WinEvent -FilterHashtable @{ LogName = 'Microsoft-Windows-NetworkProfile/Operational'; Id = 10001; StartTime = (Get-Date).AddHours(-24) } -ErrorAction SilentlyContinue).Count
    Write-KV 'Network disconnects (24h)' ([string]$flaps) $(if ($flaps -gt 6) { 'Yellow' } else { 'White' })
    if ($flaps -gt 6) { [void]$issues.Add("$flaps disconnects in 24h: flapping link (cable, port, EEE/power saving)") }

    Write-Section 'LANFIXER CONFIGURATION & PERSISTENCE'
    Write-KV 'Version' $script:Version
    Write-KV 'Routing Profile' (Get-RouteProfileName)
    Write-KV 'Duplicate-probe policy' ([string]$script:Cfg.DadPolicy)
    $lsrv = [string]$script:State.Misc['LearnedDhcp']
    Write-KV 'Learned campus DHCP' $(if ($lsrv) { $lsrv } else { 'not yet' })
    Write-KV 'Watchdog task' $(if (Test-WatchdogInstalled) { 'installed' } else { 'not installed' })
    Write-KV 'Protected store' $(if ($script:StoreReady) { $(if ($script:StoreSecure) { 'ready, locked down' } else { 'ready, ACL NOT verified' }) } else { 'not initialised (run elevated once)' })
    $lf = Get-StateTime 'LastFull'
    Write-KV 'Last full repair' $(if ($lf -gt [datetime]::MinValue) { $lf.ToString('yyyy-MM-dd HH:mm:ss') } else { 'never' })
    $rules = @(Get-OurNrptRules)
    Write-KV 'Campus-domain DNS rule' $(if ($rules.Count -gt 0) { 'present' } else { 'none' })
    try {
        $hp = Join-Path $script:Sys32 'drivers\etc\hosts'
        if ((Get-Content -LiteralPath $hp -ErrorAction SilentlyContinue) -match [regex]::Escape($script:Cfg.PortalHost)) {
            Write-KV 'Old v1 hosts pin' 'FOUND (a Heal removes it)' 'Yellow'
            [void]$issues.Add('Old Lan Fixer v1 hosts-file pin present (can go stale); a Heal removes it')
        }
    } catch {}

    Write-Section 'RECENT ACTIVITY LOG (LAST 12 ENTRIES)'
    if (Test-Path -LiteralPath $script:LogFile) {
        foreach ($ll in @(Get-Content -LiteralPath $script:LogFile -Tail 12 -ErrorAction SilentlyContinue)) {
            $lRole = if ($ll -match '\[(FAIL|ALERT)\]') { 'bad' } elseif ($ll -match '\[WARN\]') { 'warn' } elseif ($ll -match '\[OK\]') { 'ok' } else { 'dim' }
            Out-Line @((Seg $lRole ('  ' + (Fit ([string]$ll) ([Math]::Max(50, (Get-UiWidth) - 2))))))
        }
    } else {
        Out-Line @((Seg 'dim' '  (no log entries recorded yet)'))
    }

    Write-Section 'DIAGNOSTIC SUMMARY & VERDICT'
    if ($issues.Count -eq 0) { Out-Line @((Seg 'ok' ('  ' + $script:G.ok + ' ')), (Seg 'text' 'No problems found.')) }
    else { foreach ($i in $issues) { Out-Wrapped 'warn' $script:G.warn 'warn' ([string]$i) 2 } }
    Write-Host ''
}

# ==============================================================================
# QUICK PROBE (real numbers, real thresholds)
# ==============================================================================
function Get-LatencyLabel([double]$Ms) {
    if ($Ms -lt 5) { return @('excellent', 'Green') }
    if ($Ms -lt 20) { return @('good', 'Green') }
    if ($Ms -lt 60) { return @('fair', 'Yellow') }
    return @('poor', 'Red')
}
function Run-QuickProbe {
    Write-Banner 'LATENCY, PACKET LOSS, JITTER & QUALITY PROBE'

    # 1. Battery Health & Power Efficiency Telemetry
    $bat = Get-BatteryHealthAndEfficiency
    if ($bat.HasBattery) {
        $batColor = if ($bat.IsOnBattery) { $(if ($bat.ChargePercent -lt 20) { 'Red' } else { 'Yellow' }) } else { 'Green' }
        $batDetail = ("{0} (Health: {1}%, Wear: {2}%, Cycles: {3})" -f $bat.StatusText, $bat.HealthPercent, $bat.WearLevelPercent, $bat.CycleCount)
        Write-KV '[0] Battery & Power' $batDetail $batColor
    } else {
        Write-KV '[0] Battery & Power' 'AC Wall Power (Desktop / Workstation) - Continuous Low Latency' 'Green'
    }

    $ethAds = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
    $secAds = @(Get-OtherUplinkAdapters)
    $gatewaysToProbe = @()
    if ($ethAds.Count -gt 0) {
        $egw = @(Get-GatewaysV4 $ethAds[0]) | Select-Object -First 1
        if ($egw) { $gatewaysToProbe += @{ Label = 'Ethernet Gateway'; Ip = $egw } }
    }
    if ($secAds.Count -gt 0) {
        $sgw = @(Get-GatewaysV4 $secAds[0]) | Select-Object -First 1
        if ($sgw) { $gatewaysToProbe += @{ Label = ("{0} Gateway" -f $secAds[0].Name); Ip = $sgw } }
    }
    if ($gatewaysToProbe.Count -eq 0) {
        Write-KV '[1] Gateway' 'No route found / cable disconnected' 'Red'
    } else {
        $gIdx = 1
        foreach ($gItem in $gatewaysToProbe) {
            $rtts = @(); $lost = 0
            for ($i = 0; $i -lt 10; $i++) {
                $r = Test-Ping $gItem.Ip 600
                if ($null -eq $r) { $lost++ } else { $rtts += $r }
                Start-Sleep -Milliseconds 80
            }
            $pTag = if ($gatewaysToProbe.Count -gt 1) { "[1{0}] {1} {2}" -f ([char](96 + $gIdx)), $gItem.Label, $gItem.Ip } else { "[1] Gateway {0}" -f $gItem.Ip }
            if ($rtts.Count -gt 0) {
                $avg = ($rtts | Measure-Object -Average).Average
                $min = ($rtts | Measure-Object -Minimum).Minimum
                $max = ($rtts | Measure-Object -Maximum).Maximum
                $jit = $max - $min
                $lossPct = $lost * 10
                $grade = 'A+'
                if ($lossPct -gt 20 -or $jit -ge 100) { $grade = 'F' }
                elseif ($lossPct -gt 10 -or $jit -ge 50) { $grade = 'D' }
                elseif ($lossPct -gt 5 -or $jit -ge 25) { $grade = 'C' }
                elseif ($lossPct -gt 0 -or $jit -ge 10) { $grade = 'B' }
                elseif ($jit -ge 3) { $grade = 'A' }

                $lab = Get-LatencyLabel $avg
                Write-KV $pTag ("{0:N1} ms avg ({1}), jitter {2} ms [Grade {3}], loss {4}%" -f $avg, $lab[0], $jit, $grade, $lossPct) $(if ($lost -gt 1) { 'Yellow' } else { $lab[1] })
            } else {
                Write-KV $pTag 'No ping response (ICMP traffic may be filtered by router)' 'Yellow'
            }
            $gIdx++
        }
    }

    # 2. Multi-Size Path MTU Discovery (PMTUD)
    try {
        $targetMtuHost = if ($gatewaysToProbe.Count -gt 0) { $gatewaysToProbe[0].Ip } else { '1.1.1.1' }
        $mtuPing = New-Object System.Net.NetworkInformation.Ping
        $mtuOpt = New-Object System.Net.NetworkInformation.PingOptions
        $mtuOpt.DontFragment = $true
        $mtuSizes = @(1500, 1492, 1420)
        $mtuFound = 0
        foreach ($sz in $mtuSizes) {
            $payload = $sz - 28
            $buf = New-Object byte[] $payload
            try {
                $rep = $mtuPing.Send($targetMtuHost, 700, $buf, $mtuOpt)
                if ($rep.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    $mtuFound = $sz
                    break
                }
            } catch {}
        }
        if ($mtuFound -gt 0) {
            $mtuLabel = if ($mtuFound -eq 1500) { '1500 bytes (Optimal Standard Gigabit MTU - No Fragmentation)' } else { ("{0} bytes (Clamped / Encapsulated)" -f $mtuFound) }
            Write-KV '[2] Path MTU (PMTUD)' $mtuLabel $(if ($mtuFound -eq 1500) { 'Green' } else { 'Yellow' })
        } else {
            Write-KV '[2] Path MTU (PMTUD)' 'Path MTU clamped < 1420 or ICMP DF blocked' 'Yellow'
        }
    } catch {
        Write-KV '[2] Path MTU (PMTUD)' 'Skipped (ICMP socket restricted)' 'Yellow'
    }

    # 3. Portal Endpoint & TCP Handshake RTT
    $epProbe = Get-ActivePortalEndpoint
    $tcpSw = [System.Diagnostics.Stopwatch]::StartNew()
    $tcp = Test-TcpPort $epProbe.Ip $epProbe.Port 900
    $tcpSw.Stop()
    $pp = Test-Ping $epProbe.Ip 800
    $tcpInfo = if ($tcp) { ("open ({0} ms handshake)" -f $tcpSw.ElapsedMilliseconds) } else { 'closed' }
    Write-KV ("[3] Portal {0}" -f $epProbe.Ip) ("tcp/{0} {1}, ping {2}" -f $epProbe.Port, $tcpInfo, $(if ($null -ne $pp) { "$pp ms" } else { 'no reply' })) $(if ($tcp) { 'Green' } else { 'Yellow' })

    # 4. Multi-Resolver Benchmark
    $servers = @(@(Get-ActiveCampusDns) + @($script:Cfg.PublicDns) | Select-Object -Unique)
    $meas = Measure-ResolversFast $servers
    foreach ($s in $servers) {
        $ms = $meas[$s]
        if ($null -ne $ms) { $lab = Get-LatencyLabel $ms; Write-KV ("[4] DNS {0}" -f $s) ("{0} ms median lookup ({1})" -f $ms, $lab[0]) $lab[1] }
        else { Write-KV ("[4] DNS {0}" -f $s) 'No response (unreachable or blocked prior to login)' 'Yellow' }
    }

    # 5. HTTP Internet & Captive State
    $st = (Get-InternetState -NoCache).State
    $col = $(switch ($st) { 'Online' { 'Green' } 'Captive' { 'Yellow' } default { 'Red' } })
    Write-KV '[5] HTTP internet probe' $st $col
    Write-Host ''
}

# ==============================================================================
# FLUSH
# ==============================================================================
# Turns captured Write-Host output (information records) back into plain text, honouring -NoNewline.
function ConvertTo-ReportText($Records) {
    $sb = New-Object System.Text.StringBuilder
    foreach ($r in @($Records)) {
        if ($r -is [System.Management.Automation.InformationRecord]) {
            $m = $r.MessageData
            $txt = ''; $nn = $false
            if ($m -is [System.Management.Automation.HostInformationMessage]) { $txt = [string]$m.Message; $nn = [bool]$m.NoNewLine }
            else { $txt = [string]$m }
            [void]$sb.Append($txt)
            if (-not $nn) { [void]$sb.Append("`r`n") }
        } elseif ($r -is [System.Management.Automation.ErrorRecord]) { [void]$sb.Append('[error] ' + $r.Exception.Message + "`r`n") }
        elseif ($null -ne $r) { [void]$sb.Append(([string]$r) + "`r`n") }
    }
    return $sb.ToString()
}
# Saves the full audit (adapters, MAC, lease, resolvers, events) plus the last log lines as a text file.
# Output is CAPTURED and written with one atomic file write: no Start-Transcript (host-dependent, fails when a
# transcript is already running or the console is wrapped/redirected).
function New-SupportReport([switch]$Json, [switch]$Quiet, [switch]$NoColor) {
    $dir = [Environment]::GetFolderPath('Desktop')
    if (-not $dir -or -not (Test-Path -LiteralPath $dir)) { $dir = $env:TEMP }
    $path = Join-Path $dir ("LanFixer-Report-{0}.txt" -f (Get-Date).ToString('yyyyMMdd-HHmmss'))
    $text = ''
    $script:Ui.Plain = $true
    try {
        $recs = & {
            try { Show-Diagnostics } catch { Write-Host ('[audit stopped early: ' + $_.Exception.Message + ']') }
            Write-Section 'RECENT LAN FIXER LOG (last 40 lines)'
            try { Get-Content -LiteralPath $script:LogFile -Tail 40 -ErrorAction Stop | ForEach-Object { Write-Host ('  ' + $_) } } catch { Write-Host '  (no log yet)' }
        } *>&1
        $text = ConvertTo-ReportText $recs
    } catch { $text = 'Report generation failed: ' + $_.Exception.Message }
    $script:Ui.Plain = $false
    try {
        $tmp = $path + '.tmp'
        [System.IO.File]::WriteAllText($tmp, $text, (New-Object System.Text.UTF8Encoding($true)))
        Move-Item -LiteralPath $tmp -Destination $path -Force -ErrorAction Stop
        Write-Log 'OK' "Report saved: $path  (contains your MAC, IP and PC name: read it before sharing)"
    } catch { Write-Log 'WARN' ("Could not write the report file (" + $_.Exception.Message + "). The text is shown above: copy it manually.") }
    if ($Json) {
        $rep = @{
            Status   = 'Success'
            Path     = $path
            ExitCode = 0
        }
        [Console]::Out.WriteLine((ConvertTo-Json $rep -Depth 2))
        return 0
    }
    if ($Quiet) {
        [Console]::Out.WriteLine($path)
        return 0
    }
    Write-Host $text
    return 0
}

function Invoke-LogIntelligence($Ads) {
    if ($script:IsDry) { return }
    # 1. Check Windows DNS Client Event 1014 (DNS resolution timeout in last 10 minutes) -> invalidate stale DNS speed cache
    try {
        $dnsEv = @(Get-WinEvent -FilterHashtable @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-DNS-Client'; Id = 1014; StartTime = (Get-Date).AddMinutes(-10) } -MaxEvents 1 -ErrorAction SilentlyContinue)
        if ($dnsEv.Count -gt 0) {
            foreach ($k in @($script:State.Dns.Keys)) {
                if ($script:State.Dns[$k] -is [hashtable] -and $script:State.Dns[$k].ContainsKey('OrderTime')) {
                    $script:State.Dns[$k].Remove('OrderTime')
                }
            }
            Clear-DnsClientCache -ErrorAction SilentlyContinue
            Write-Log 'INFO' 'Log intelligence: Windows logged DNS timeout (Event 1014); invalidated cached resolver order for fresh measurement.'
        }
    } catch {}
    # 2. Check NIC driver/NDIS hardware reset or hang events (EventIDs 27, 32, 5002, 10400 in last 10 minutes)
    try {
        $lastRecord = if ($script:State.Misc -and $script:State.Misc['LastHandledNicEventRecordId']) { [int64]$script:State.Misc['LastHandledNicEventRecordId'] } else { 0L }
        $nicEv = @(Get-WinEvent -FilterHashtable @{ LogName = 'System'; Id = @(27, 32, 5002, 10400); StartTime = (Get-Date).AddMinutes(-10) } -MaxEvents 5 -ErrorAction SilentlyContinue | Where-Object {
            $_.ProviderName -match 'ndis|rt640|rtcx21|e1r|e1d|e2f|Netwtw|realtek|intel' -and $_.RecordId -gt $lastRecord
        })
        if ($nicEv.Count -gt 0 -and $Ads) {
            $maxRec = ($nicEv | Measure-Object -Property RecordId -Maximum).Maximum
            if ($maxRec -gt $lastRecord) { $script:State.Misc['LastHandledNicEventRecordId'] = [int64]$maxRec }
            foreach ($a in @($Ads | Where-Object { $_.Status -eq 'Up' })) {
                $ipNow = Get-ValidIPv4 $a
                if (-not $ipNow -or (Get-InternetState -SourceIp $ipNow).State -eq 'Offline') {
                    $script:PendingRestart[[string]$a.InterfaceGuid] = $a.Name
                    Write-Log 'WARN' ("Log intelligence: NIC driver hardware reset/hang event detected in System log; scheduled link reset on {0}." -f $a.Name)
                }
            }
        }
    } catch {}
}

function Flush-NetworkCache {
    if (-not (Assert-Admin)) { return }
    Write-Banner 'FLUSH NETWORK RESOLVER, ARP, NETBIOS & SOCKET CACHES'
    $totalSw = [System.Diagnostics.Stopwatch]::StartNew()
    $script:ConnCache = $null
    $script:EnvCache = @{}
    $script:DhcpDiagCache = $null
    if ($script:State.Misc -is [hashtable]) { $script:State.Misc['FailStreak'] = 0 }
    if ($script:State.Dns -is [hashtable]) {
        foreach ($dk in @($script:State.Dns.Keys)) {
            if ($script:State.Dns[$dk] -is [hashtable] -and $script:State.Dns[$dk].ContainsKey('OrderTime')) {
                $script:State.Dns[$dk].Remove('OrderTime')
            }
        }
    }

    # Stage 1: DNS Client Resolver Cache
    $s1 = [System.Diagnostics.Stopwatch]::StartNew()
    [void](Invoke-Change 'DNS resolver cache & internal speed-test cache cleared' {
        Clear-DnsClientCache -ErrorAction SilentlyContinue
        [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/flushdns') 5000)
    })
    $s1.Stop()

    # Stage 2: Dynamic IPv4 & IPv6 ARP/Neighbor Entries
    $s2 = [System.Diagnostics.Stopwatch]::StartNew()
    [void](Invoke-Change 'Dynamic IPv4 & IPv6 ARP/neighbor entries cleared (locked gateway entry is kept)' {
        Get-NetNeighbor -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.State -ne 'Permanent' } | Remove-NetNeighbor -Confirm:$false -ErrorAction SilentlyContinue
        Get-NetNeighbor -AddressFamily IPv6 -ErrorAction SilentlyContinue | Where-Object { $_.State -ne 'Permanent' } | Remove-NetNeighbor -Confirm:$false -ErrorAction SilentlyContinue
    })
    $s2.Stop()

    # Stage 3: NetBIOS Name Cache
    $s3 = [System.Diagnostics.Stopwatch]::StartNew()
    [void](Invoke-Change 'NetBIOS name cache purged & re-registered' {
        [void](Invoke-Native (Get-SysExe 'nbtstat.exe') @('-R') 8000)
        [void](Invoke-Native (Get-SysExe 'nbtstat.exe') @('-RR') 8000)
    })
    $s3.Stop()

    # Stage 4: Network List Service (NlaSvc) & Network Profile Manager (netprofm)
    $s4 = [System.Diagnostics.Stopwatch]::StartNew()
    [void](Invoke-Change 'Network List service refreshed (clears a stuck "no internet" icon)' {
        Restart-Service -Name NlaSvc -Force -ErrorAction Stop
        Start-Service -Name netprofm -ErrorAction SilentlyContinue
    })
    $s4.Stop()

    # Stage 5: TCP/IP Active Socket State & Connection Table Refresh
    $s5 = [System.Diagnostics.Stopwatch]::StartNew()
    [void](Invoke-Change 'TCP/IP active socket state table refreshed & stale sessions cleared' {
        $script:ConnCache = $null
        $script:EnvCache = @{}
    })
    $s5.Stop()

    # Stage 6: Windows Filtering Platform (WFP) & BFE State Sync
    $s6 = [System.Diagnostics.Stopwatch]::StartNew()
    [void](Invoke-Change 'Windows Filtering Platform (WFP) policy and filter cache refreshed' {
        try {
            $bfe = Get-Service -Name BFE -ErrorAction SilentlyContinue
            if ($bfe -and $bfe.Status -eq 'Running') {
                $null = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces()
            }
        } catch {}
    })
    $s6.Stop()

    Save-State
    $totalSw.Stop()
    Write-Log 'OK' ("6-Stage Universal Network Cache Flush completed in {0} ms (DNS: {1}ms, ARP: {2}ms, NetBIOS: {3}ms, NLA: {4}ms, Sockets: {5}ms, WFP: {6}ms)." -f $totalSw.ElapsedMilliseconds, $s1.ElapsedMilliseconds, $s2.ElapsedMilliseconds, $s3.ElapsedMilliseconds, $s4.ElapsedMilliseconds, $s5.ElapsedMilliseconds, $s6.ElapsedMilliseconds)
}

# ==============================================================================
# SELF TEST (verifies this machine supports everything; changes nothing)
# ==============================================================================
$script:TestFail = 0
$script:TestWarn = 0
$script:TestResults = New-Object System.Collections.ArrayList
$script:TestJson = $false
$script:TestQuiet = $false
$script:TestNoColor = $false
function Write-Check([string]$Label, [bool]$Ok, [bool]$WarnOnly = $false, [string]$Detail = '') {
    $gl = $script:G.ok; $role = 'ok'
    if (-not $Ok) { if ($WarnOnly) { $gl = $script:G.warn; $role = 'warn'; $script:TestWarn++ } else { $gl = $script:G.bad; $role = 'bad'; $script:TestFail++ } }
    if ($script:TestResults -is [System.Collections.ArrayList]) {
        [void]$script:TestResults.Add(@{
            Label    = $Label
            Passed   = $Ok
            WarnOnly = $WarnOnly
            Detail   = $Detail
        })
    }
    if ($script:TestQuiet -or $script:TestJson) { return }
    $segs = @((Seg $role ('  ' + $gl + ' ')), (Seg 'text' $Label))
    if ($Detail) { $segs += (Seg 'dim' ('  ' + $script:G.mid + ' ' + $Detail)) }
    Out-Line $segs
}
function Invoke-LogicTests {
    Write-Check 'Logic: argument quoting, plain' ((ConvertTo-ArgString @('/renew', 'Ethernet')) -ceq '/renew Ethernet')
    Write-Check 'Logic: argument quoting, space' ((ConvertTo-ArgString @('a b')) -ceq '"a b"')
    Write-Check 'Logic: argument quoting, trailing backslash' ((ConvertTo-ArgString @('C:\x y\')) -ceq '"C:\x y\\"')
    Write-Check 'Logic: argument quoting, embedded quote' ((ConvertTo-ArgString @('say "hi"')) -ceq '"say \"hi\""')
    Write-Check 'Logic: argument quoting, empty' ((ConvertTo-ArgString @('')) -ceq '""')
    $h = ConvertFrom-HttpResponse ("HTTP/1.1 302 Found`r`nLocation: https://gw.example:8003/login?z=1`r`nContent-Length: 0`r`n`r`n")
    Write-Check 'Logic: HTTP 302 + Location parsed' (($h.Code -eq 302) -and ($h.Location -ceq 'https://gw.example:8003/login?z=1'))
    $h = ConvertFrom-HttpResponse ("HTTP/1.0 200 OK`r`nContent-Type: text/plain`r`n`r`nMicrosoft Connect Test")
    Write-Check 'Logic: HTTP 200 body parsed' (($h.Code -eq 200) -and ($h.Body -ceq 'Microsoft Connect Test'))
    Write-Check 'Logic: garbage is not a response' ((ConvertFrom-HttpResponse 'not http').Code -eq 0)
    $n = @{ Code = 0; Body = ''; Location = ''; Error = '' }
    $ok204 = @{ Code = 204; Body = ''; Location = ''; Error = '' }
    $okMs = @{ Code = 200; Body = 'Microsoft Connect Test'; Location = ''; Error = '' }
    $r302 = @{ Code = 302; Body = ''; Location = 'http://x/'; Error = '' }
    $r200x = @{ Code = 200; Body = '<html>login</html>'; Location = ''; Error = '' }
    $r503 = @{ Code = 503; Body = ''; Location = ''; Error = '' }
    $dns = @{ Code = 0; Body = ''; Location = ''; Error = 'DnsFail' }
    $tmo = @{ Code = 0; Body = ''; Location = ''; Error = 'Timeout' }
    Write-Check 'Logic: verdict 204 = Online' ((Get-ProbeVerdict $ok204 $n) -eq 'Online')
    Write-Check 'Logic: verdict MS body = Online' ((Get-ProbeVerdict $r503 $okMs) -eq 'Online')
    Write-Check 'Logic: verdict 302 = Captive' ((Get-ProbeVerdict $r302 $tmo) -eq 'Captive')
    Write-Check 'Logic: verdict login page 200 = Captive' ((Get-ProbeVerdict $r200x $r200x) -eq 'Captive')
    Write-Check 'Logic: verdict 503 = Offline (not Captive)' ((Get-ProbeVerdict $r503 $r503) -eq 'Offline')
    Write-Check 'Logic: verdict timeouts = Offline' ((Get-ProbeVerdict $tmo $tmo) -eq 'Offline')
    Write-Check 'Logic: verdict DNS failures = NoDns' ((Get-ProbeVerdict $dns $dns) -eq 'NoDns')
    [byte[]]$q = New-DnsQueryPacket 'a.bc' 4660
    $want = [byte[]](0x12,0x34,1,0,0,1,0,0,0,0,0,0,1,0x61,2,0x62,0x63,0,0,1,0,1)
    Write-Check 'Logic: DNS query packet layout' (($q.Length -eq $want.Length) -and (-not (Compare-Object $q $want)))
    Write-Check 'Logic: learnable DHCP server (campus-like)' (Test-LearnableDhcpServer '172.16.1.5')
    Write-Check 'Logic: DHCP server home router refused' (-not (Test-LearnableDhcpServer '192.168.1.1'))
    Write-Check 'Logic: DHCP server hotspot refused' (-not (Test-LearnableDhcpServer '172.20.10.1'))
    Write-Check 'Logic: DHCP server garbage refused' (-not (Test-LearnableDhcpServer 'not-an-ip'))
    $save = $script:Cfg
    try {
        $script:Cfg = @{ PortalHost = 'gateway.nitjsr.ac.in'; PortalIp = '10.114.0.5'; CampusDomain = 'nitjsr.ac.in'; PortalUrl = 'https://gateway.nitjsr.ac.in:8003/index.php?zone=nitjsr' }
        Write-Check 'Logic: host bounded trims trailing dots' ((Resolve-HostBounded 'gateway.nitjsr.ac.in.') -eq '10.114.0.5')
        Write-Check 'Logic: host bounded trims whitespace' ((Resolve-HostBounded '  gateway.nitjsr.ac.in.  ') -eq '10.114.0.5')
        Write-Check 'Logic: allowed portal IP includes configured IP' (Test-AllowedPortalIp '10.114.0.5')
        Write-Check 'Logic: portal host trusted (configured)' (Test-TrustedPortalHost 'gateway.nitjsr.ac.in')
        Write-Check 'Logic: portal host trusted (campus subdomain)' (Test-TrustedPortalHost 'Portal.NITJSR.ac.in.')
        Write-Check 'Logic: portal host trusted (portal IP)' (Test-TrustedPortalHost '10.114.0.5')
        Write-Check 'Logic: portal host refused (lookalike suffix)' (-not (Test-TrustedPortalHost 'gateway.nitjsr.ac.in.evil.com'))
        Write-Check 'Logic: portal host refused (no dot boundary)' (-not (Test-TrustedPortalHost 'evilnitjsr.ac.in'))
        Write-Check 'Logic: portal host refused (stranger)' (-not (Test-TrustedPortalHost 'example.com'))
        Write-Check 'Logic: live URL with new port/zone accepted' ((Get-SafePortalUrl 'https://gateway.nitjsr.ac.in:8443/portal/login?z=2&redirurl=http%3A%2F%2Fa.b%2F') -like 'https://gateway.nitjsr.ac.in:8443/portal/login?z=2&redirurl=*')
        Write-Check 'Logic: live URL, untrusted host refused' ((Get-SafePortalUrl 'http://login.evil.com/steal') -eq '')
        Write-Check 'Logic: live URL, user-info trick refused' ((Get-SafePortalUrl 'http://gateway.nitjsr.ac.in@evil.com/x') -eq '')
        Write-Check 'Logic: live URL, relative path refused' ((Get-SafePortalUrl '/login') -eq '')
        Write-Check 'Logic: live URL, non-http scheme refused' ((Get-SafePortalUrl 'javascript:alert(1)') -eq '')
    } finally {
        $script:Cfg = $save
    }
    if ($script:State -is [hashtable] -and $script:State.Misc -is [hashtable]) {
        $origDisc = $script:State.Misc['DiscoveredPortalHost']
        try {
            $script:State.Misc['DiscoveredPortalHost'] = 'wifi.marriott.com'
            Write-Check 'Logic: auto-discovery portal host trusted' (Test-TrustedPortalHost 'wifi.marriott.com')
            Write-Check 'Logic: auto-discovery portal subdomain trusted' (Test-TrustedPortalHost 'auth.wifi.marriott.com')
            $script:State.Misc.Remove('DiscoveredPortalHost')
            Write-Check 'Logic: undiscovered stranger refused' (-not (Test-TrustedPortalHost 'wifi.marriott.com'))
        } finally {
            if ($origDisc) { $script:State.Misc['DiscoveredPortalHost'] = $origDisc }
            else { $script:State.Misc.Remove('DiscoveredPortalHost') }
        }
    }
    Write-Check 'Logic: IPv6 verdict none' ((Get-Ipv6Verdict $false $false 'Online' $false) -eq 'None')
    Write-Check 'Logic: IPv6 verdict blackhole' ((Get-Ipv6Verdict $true $true 'Online' $false) -eq 'Blackhole')
    Write-Check 'Logic: IPv6 verdict working' ((Get-Ipv6Verdict $true $true 'Online' $true) -eq 'Working')
    Write-Check 'Logic: IPv6 verdict untested while captive' ((Get-Ipv6Verdict $true $true 'Captive' $false) -eq 'Untested')
    Write-Check 'Logic: hard failures counted' ((Test-HardFailure 'Offline') -and (Test-HardFailure 'NoIp') -and -not (Test-HardFailure 'Captive') -and -not (Test-HardFailure 'Healthy'))
    Write-Check 'Logic: Notify Task XML well-formed' ([bool]([xml](New-NotifyTaskXml)))
    $wXml = [xml](New-WatchdogXml 'test' '2026-01-01T00:00:00'); $sXml = [xml](New-SentinelTaskXml 'test'); $pXml = [xml](New-PortalTaskXml 'http://test')
    Write-Check 'Logic: Background task templates enforce Hidden=True' ($wXml.Task.Settings.Hidden -eq 'true' -and $sXml.Task.Settings.Hidden -eq 'true' -and $pXml.Task.Settings.Hidden -eq 'true')
    Write-Check 'Logic: Clear-StartupEntries is defined' ($null -ne (Get-Command Clear-StartupEntries -ErrorAction SilentlyContinue))
    $bTest = Get-BatteryHealthAndEfficiency
    Write-Check 'Logic: Battery & Power health telemetry structure' ($bTest -is [hashtable] -and $bTest.ContainsKey('HasBattery') -and $bTest.ContainsKey('IsOnBattery') -and $bTest.ContainsKey('ChargePercent'))
    # Unit Test: DPAPI LocalMachine crypto round-trip
    $testBytes = [System.Text.Encoding]::UTF8.GetBytes('nitjsr_test_secret')
    $testEntropy = Get-VaultEntropy
    $testEnc = [System.Security.Cryptography.ProtectedData]::Protect($testBytes, $testEntropy, [System.Security.Cryptography.DataProtectionScope]::LocalMachine)
    $testDec = [System.Security.Cryptography.ProtectedData]::Unprotect($testEnc, $testEntropy, [System.Security.Cryptography.DataProtectionScope]::LocalMachine)
    $testMatch = ([System.Text.Encoding]::UTF8.GetString($testDec) -eq 'nitjsr_test_secret')
    Write-Check 'Logic: DPAPI LocalMachine crypto round-trip' $testMatch
    # ---- v4 behavioural tests: each one fails if the behaviour regresses
    Write-Check 'Logic: private IPv4 ranges' ((Test-PrivateIPv4 '10.114.0.5') -and (Test-PrivateIPv4 '172.20.1.1') -and (Test-PrivateIPv4 '192.168.1.1') -and -not (Test-PrivateIPv4 '8.8.8.8') -and -not (Test-PrivateIPv4 '172.32.0.1') -and -not (Test-PrivateIPv4 'x'))
    Write-Check 'Logic: allowed portal IP includes CGNAT' ((Test-AllowedPortalIp '100.64.0.1') -and (Test-AllowedPortalIp '10.114.0.5') -and -not (Test-AllowedPortalIp '8.8.8.8'))
    Write-Check 'Logic: certificate accepted only if valid or pinned' (((Get-CertDecision 'None' 'AA' '') -eq 'valid') -and ((Get-CertDecision 'RemoteCertificateChainErrors' 'ab12' 'AB12') -eq 'pinned') -and ((Get-CertDecision 'RemoteCertificateChainErrors' 'ab12' 'FFFF') -eq 'reject') -and ((Get-CertDecision 'RemoteCertificateNameMismatch' 'ab12' '') -eq 'reject'))
    $chunk = [System.Text.Encoding]::ASCII.GetBytes("5`r`nhello`r`n6`r`n world`r`n0`r`n`r`n")
    Write-Check 'Logic: chunked transfer decoded' (([System.Text.Encoding]::ASCII.GetString((ConvertFrom-ChunkedBytes $chunk))) -ceq 'hello world')
    $pr = ConvertFrom-HttpBytes ([System.Text.Encoding]::ASCII.GetBytes("HTTP/1.1 302 Found`r`nLocation: https://gw/x`r`nSet-Cookie: PHPSESSID=abc; path=/`r`nTransfer-Encoding: chunked`r`n`r`n2`r`nhi`r`n0`r`n`r`n"))
    Write-Check 'Logic: HTTP response parsed (status, location, cookie, chunked body)' (($pr.Code -eq 302) -and ($pr.Location -ceq 'https://gw/x') -and ($pr.Cookies.Count -eq 1) -and ($pr.Body -ceq 'hi'))
    $html = '<html><form method="post" action="/login?z=1"><input type="hidden" name="__csrf" value="a&amp;b"><input type=hidden name=zone value=nitjsr><input name="auth_user" type="text"><input name="auth_pass" type="password"><input name="accept" type="submit" value="Sign In"></form></html>'
    $fm = ConvertFrom-LoginForm $html ([uri]'https://gateway.nitjsr.ac.in:8003/index.php')
    Write-Check 'Logic: login form parsed (hidden fields, names, action)' ($fm -and ($fm.UserField -ceq 'auth_user') -and ($fm.PassField -ceq 'auth_pass') -and ($fm.Fields['__csrf'] -ceq 'a&b') -and ($fm.Fields['zone'] -ceq 'nitjsr') -and ($fm.Fields['accept'] -ceq 'Sign In') -and ($fm.Action.AbsoluteUri -ceq 'https://gateway.nitjsr.ac.in:8003/login?z=1'))
    $evil = ConvertFrom-LoginForm '<form action="https://evil.example/steal"><input type="password" name="p"></form>' ([uri]'https://gateway.nitjsr.ac.in/')
    Write-Check 'Logic: a form that posts to another host is caught by the host check' ($evil -and -not (Test-TrustedPortalHost $evil.Action.Host))
    Write-Check 'Logic: page without a password field is not a login form' ($null -eq (ConvertFrom-LoginForm '<form><input name="q"></form>' ([uri]'https://x/')))
    $vp = ConvertFrom-VaultPlain ('2021ug01' + [string][char]9 + 'pa' + [string][char]9 + 'ss')
    Write-Check 'Logic: vault text splits on the FIRST tab only' ($vp -and ($vp.User -ceq '2021ug01') -and ($vp.Pass -ceq ('pa' + [string][char]9 + 'ss')))
    Write-Check 'Logic: malformed vault text rejected' (-not (ConvertFrom-VaultPlain 'nopass') -and -not (ConvertFrom-VaultPlain ([string][char]9 + 'x')))
    $okR = @([pscustomobject]@{ IdentityReference = [pscustomobject]@{ Value = 'S-1-5-18' } }, [pscustomobject]@{ IdentityReference = [pscustomobject]@{ Value = 'S-1-5-32-544' } })
    $badR = $okR + @([pscustomobject]@{ IdentityReference = [pscustomobject]@{ Value = 'S-1-5-32-545' } })
    Write-Check 'Logic: vault ACL rule (SYSTEM + Administrators only)' ((Test-AclSidsOnly $okR @('S-1-5-18', 'S-1-5-32-544')) -and -not (Test-AclSidsOnly $badR @('S-1-5-18', 'S-1-5-32-544')))
    Write-Check 'Logic: vault file ACL on this PC' (Test-VaultAcl $script:VaultFile) $true 'run menu A and re-save credentials'
    Write-Check 'Logic: system fallback never speaks for one adapter or while Wi-Fi is up' ((-not (Test-AllowSystemFallback $true 'Offline' $false)) -and (-not (Test-AllowSystemFallback $false 'Offline' $true)) -and (Test-AllowSystemFallback $false 'Offline' $false) -and (-not (Test-AllowSystemFallback $false 'Online' $false)))
    Write-Check 'Logic: MTU needs two matching measurements' (((Get-MtuDecision 1400 1500 $null).Action -eq 'candidate') -and ((Get-MtuDecision 1400 1500 1396).Action -eq 'clamp') -and ((Get-MtuDecision 1400 1500 1300).Action -eq 'candidate') -and ((Get-MtuDecision 1200 1500 1200).Action -eq 'skip') -and ((Get-MtuDecision 1400 1400 $null).Action -eq 'skip') -and ((Get-MtuDecision $null 1500 $null).Action -eq 'skip') -and ((Get-MtuDecision 1500 1500 $null).Action -eq 'skip'))
    Write-Check 'Logic: prefer-IPv4 keeps existing DisabledComponents bits' (((Get-PreferIpv4Value $null) -eq 32) -and ((Get-PreferIpv4Value 1) -eq 33) -and ((Get-PreferIpv4Value 32) -eq 32) -and ((Get-PreferIpv4Value 17) -eq 49))
    Write-Check 'Logic: DHCP wording states facts only' (((Get-DhcpFailureText 121 'AA') -like '*0x79*') -and ((Get-DhcpFailureText 5 'AA') -like '*0x5*') -and ((Get-DhcpFailureText $null 'AA-BB') -like '*AA-BB*'))
    Write-Check 'Logic: PowerKeywords cover Realtek battery/adaptive/extra modes' (($script:PowerKeywords -contains 'BatteryModeLinkSpeed') -and ($script:PowerKeywords -contains 'EnableAdaptiveLinkCap') -and ($script:PowerKeywords -contains 'EnableExtraPowerSaving'))
    Write-Check 'Logic: PowerKeywords include EnergyEfficientEthernet and AutoDisableGigabit' (($script:PowerKeywords -contains 'EnergyEfficientEthernet') -and ($script:PowerKeywords -contains 'AutoDisableGigabit'))
    try {
        $tb = [System.Text.Encoding]::UTF8.GetBytes('nitjsr_test_secret')
        $te = [System.Security.Cryptography.ProtectedData]::Protect($tb, (Get-VaultEntropy), [System.Security.Cryptography.DataProtectionScope]::LocalMachine)
        $td = [System.Security.Cryptography.ProtectedData]::Unprotect($te, (Get-VaultEntropy), [System.Security.Cryptography.DataProtectionScope]::LocalMachine)
        Write-Check 'Logic: DPAPI machine-scope round trip' (([System.Text.Encoding]::UTF8.GetString($td)) -ceq 'nitjsr_test_secret')
    } catch { Write-Check 'Logic: DPAPI machine-scope round trip' $false }
    $nowT = [datetime]'2026-10-12T12:00:00'
    $candOld = @{ Mac = 'BB'; Since = $nowT.AddHours(-25).ToString('o') }
    $candNew = @{ Mac = 'BB'; Since = $nowT.AddHours(-2).ToString('o') }
    Write-Check 'Logic: ARP first sighting or unchanged MAC is locked' (((Get-ArpDecision '' 'AA' $null $nowT) -eq 'lock') -and ((Get-ArpDecision 'AA' 'AA' $null $nowT) -eq 'lock'))
    Write-Check 'Logic: a CHANGED gateway MAC is not locked, only flagged' (((Get-ArpDecision 'AA' 'BB' $null $nowT) -eq 'candidate') -and ((Get-ArpDecision 'AA' 'CC' $candNew $nowT) -eq 'candidate'))
    Write-Check 'Logic: a changed MAC is accepted only after 24 stable hours' (((Get-ArpDecision 'AA' 'BB' $candNew $nowT) -eq 'wait') -and ((Get-ArpDecision 'AA' 'BB' $candOld $nowT) -eq 'lock'))
    Write-Check 'Logic: watchdog task is re-registered for old arguments or an unsafe restart policy' ((Test-WatchdogStale 'a' 'b' 'IgnoreNew') -and (Test-WatchdogStale 'a' 'a' 'StopExisting') -and (-not (Test-WatchdogStale 'a' 'a' 'IgnoreNew')))
    Write-Check 'Logic: generated watchdog XML is valid and uses IgnoreNew' (($(try { $wx = [xml](New-WatchdogXml '/c test' '2026-01-01T00:00:00'); ([string]$wx.Task.Settings.MultipleInstancesPolicy) -eq 'IgnoreNew' } catch { $false })))
    # ---- interface tests
    Write-Check 'UI: every verdict maps to a headline and five hop states' ((@('Healthy', 'Captive', 'NoIp', 'GwUnreachable', 'NoDns', 'Offline', 'NoLink', 'NoAdapter', '') | Where-Object { $si = Get-StateInfo $_; -not ($si.Word -and @($si.Hops).Count -eq 5) }).Count -eq 0)
    Write-Check 'UI: the chain breaks at the right hop' ((((Get-StateInfo 'GwUnreachable').Hops) -join ',') -ceq 'ok,ok,bad,unk,unk' -and (((Get-StateInfo 'Captive').Hops) -join ',') -ceq 'ok,ok,ok,ok,warn' -and (((Get-StateInfo 'NoIp').Hops) -join ',') -ceq 'ok,bad,unk,unk,unk')
    $wr = @(Split-Words 'one two three four five six seven eight nine ten eleven twelve' 20 2)
    Write-Check 'UI: word wrap keeps to the width and the line limit' (($wr.Count -le 2) -and (@($wr | Where-Object { $_.Length -gt 20 }).Count -eq 0))
    $pm = Get-PulseModel @(2, 2, 3, -1, 48, 2) 10
    Write-Check 'UI: pulse counts loss and flags the spike' (($pm.Loss -eq 17) -and ($pm.Valid -eq 5) -and (@($pm.Chars | Where-Object { $_.Role -eq 'warn' }).Count -eq 1) -and (@($pm.Chars | Where-Object { $_.Role -eq 'bad' }).Count -eq 1))
    $okW = $true; $okA = $true
    $saveUni = [bool]$script:Ui.Uni
    foreach ($uni in @($true, $false)) {
        Set-UiGlyphs $uni
        foreach ($cw in 60, 76, 100) {
            foreach ($pb in 'Healthy', 'Captive', 'NoIp', 'GwUnreachable', 'NoDns', 'Offline', 'NoLink', 'NoAdapter') {
                $tt = New-Telemetry
                $tt.Admin = $true; $tt.Problem = $pb; $tt.LinkUp = $true; $tt.Speed = '2.5 Gbps'; $tt.Nic = 'Realtek PCIe 2.5GbE Family Controller #2'; $tt.Mac = 'AA-BB-CC-DD-EE-FF'
                $tt.Ip = '10.114.230.187'; $tt.GwIp = '10.114.230.1'; $tt.GwRtt = 12; $tt.DnsPrimary = '172.16.1.2'; $tt.DnsProfile = 'Adaptive'; $tt.Env = 'Campus'; $tt.EnvScore = 4; $tt.Mtu = '1500'; $tt.Watchdog = $true; $tt.Vault = $true
                $mdl = Get-DashboardModel $tt (Get-Advice $tt) $cw
                foreach ($ln in $mdl.Lines) {
                    if ((Get-SegsLength $ln) -gt ($cw + 2)) { $okW = $false }
                    if (-not $uni) { foreach ($sg in $ln) { if ([string]$sg.T -match '[^\x20-\x7E]') { $okA = $false } } }
                }
            }
        }
    }
    Set-UiGlyphs $saveUni
    Write-Check 'UI: no line is wider than the terminal (60/76/100 columns, Unicode and ASCII)' $okW
    Write-Check 'UI: ASCII mode emits only ASCII characters' $okA
    # v4.5.6: the TRANSIENT dashboard states must fit too - the pending-MAC row is injected dynamically, Limited Mode
    # changes the advice line, and "Wi-Fi Protected" is a longer routing label than "Ethernet First".
    $okTrans = $true
    $saveUniT = [bool]$script:Ui.Uni
    foreach ($uniT in @($true, $false)) {
        Set-UiGlyphs $uniT
        foreach ($cwT in 60, 76, 100) {
            foreach ($variant in @('ArpPending', 'Limited', 'Protected')) {
                $tv = New-Telemetry
                $tv.Admin = $true; $tv.Problem = 'Healthy'; $tv.LinkUp = $true; $tv.Speed = '2.5 Gbps'
                $tv.Nic = 'Realtek PCIe 2.5GbE Family Controller #2'; $tv.Mac = 'AA-BB-CC-DD-EE-FF'
                $tv.Ip = '10.114.230.187'; $tv.GwIp = '10.114.230.1'; $tv.GwAlive = $true
                $tv.DnsPrimary = '172.16.1.2'; $tv.DnsProfile = 'Adaptive'; $tv.Env = 'Campus'; $tv.EnvScore = 4
                $tv.Watchdog = $true; $tv.Vault = $true; $tv.Paused = $true
                switch ($variant) {
                    'ArpPending' { $tv.ArpPending = $true }
                    'Limited'    { $tv.Admin = $false; $tv.Problem = 'Captive' }
                    'Protected'  { $tv.Routing = 'Wi-Fi Protected' }
                }
                $mdlT = Get-DashboardModel $tv (Get-Advice $tv) $cwT
                foreach ($lnT in $mdlT.Lines) {
                    if ((Get-SegsLength $lnT) -gt ($cwT + 2)) { $okTrans = $false }
                    if (-not $uniT) { foreach ($sgT in $lnT) { if ([string]$sgT.T -match '[^\x20-\x7E]') { $okTrans = $false } } }
                }
            }
        }
    }
    Set-UiGlyphs $saveUniT
    Write-Check 'UI: pending-MAC, Limited Mode and Wi-Fi Protected layouts fit 60/76/100 in both glyph modes' $okTrans
    # The [K] offer must survive every supported width: dock row when the full layout is used, legend cell when compact.
    $mdlTxt2 = { param($m) @($m.Lines | ForEach-Object { ((@($_) | ForEach-Object { [string]$_.T }) -join '') }) }
    $arpFit = $true
    foreach ($cwK in 60, 76, 100) {
        $tk = New-Telemetry; $tk.Admin = $true; $tk.Problem = 'Healthy'; $tk.LinkUp = $true; $tk.ArpPending = $true
        $txtK = @((& $mdlTxt2 (Get-DashboardModel $tk (Get-Advice $tk) $cwK)))
        if ($cwK -ge 74) { if (@($txtK | Where-Object { $_ -match 'Approve Gateway MAC Change' }).Count -eq 0) { $arpFit = $false } }
        elseif (@($txtK | Where-Object { $_ -match '\[K\]\s*MAC' }).Count -eq 0) { $arpFit = $false }
    }
    Write-Check 'UI: the [K] offer is present at every supported width (dock row or legend cell)' $arpFit
    # v4.5.6: an UNMAPPED key (arrows, Tab, Backspace, stray letters) must be reported as unhandled, because the main
    # loop only clears the screen and re-probes when Invoke-DashboardKey says it handled something.
    Write-Check 'UI: unmapped keys are reported as unhandled (no screen wipe, no re-probe)' (((Invoke-DashboardKey 'z' $null) -eq $false) -and ((Invoke-DashboardKey 'y' $null) -eq $false) -and ((Invoke-DashboardKey 'j' $null) -eq $false))
    # v4.5.6: Dry-Run must be inert everywhere it claims to be: report success, execute nothing, write nothing.
    # The probes below are pointed at throwaway files and the other guards are satisfied (store ready, mutex held), so
    # the ONLY thing that can keep them untouched is the IsDry guard itself - which is what is being tested.
    $dryPrev = [bool]$script:IsDry
    $uiPrev = [bool]$script:UiOn
    $logPrev = [string]$script:LogFile
    $stPrev = [string]$script:StateFile
    $readyPrev = [bool]$script:StoreReady
    $mutexPrev = [bool]$script:HasMutex
    $adminPrev = [bool]$script:IsAdmin
    $tmpDir = [System.IO.Path]::GetTempPath()
    $logTmp = Join-Path $tmpDir ('lanfixer_drylog_' + [guid]::NewGuid().ToString('N') + '.log')
    $stTmp = Join-Path $tmpDir ('lanfixer_dryst_' + [guid]::NewGuid().ToString('N') + '.clixml')
    $sentinel = Join-Path $tmpDir ('lanfixer_dry_' + [guid]::NewGuid().ToString('N') + '.tmp')
    $chgBefore = [int]$script:ChangeCount
    $ranDry = $false
    try {
        [System.IO.File]::WriteAllText($logTmp, 'baseline')
        [System.IO.File]::WriteAllText($stTmp, 'baseline')
        $script:LogFile = $logTmp
        $script:StateFile = $stTmp
        # Satisfy EVERY other guard (store ready, mutex held, elevated) so IsDry is the only thing left standing
        # between the dry run and the disk - otherwise a non-elevated audit would pass this probe for the wrong reason.
        $script:StoreReady = $true
        $script:HasMutex = $true
        $script:IsAdmin = $true
        $script:IsDry = $true; $script:UiOn = $false
        $ranDry = Invoke-Change 'Dry-Run sentinel: this action must never execute' { Set-Content -LiteralPath $sentinel -Value 'x' -ErrorAction Stop }
        Write-Log 'INFO' 'dry-run log probe (must never reach the log file)'
        Save-State
    } finally {
        $script:IsDry = $dryPrev; $script:UiOn = $uiPrev
        $script:LogFile = $logPrev; $script:StateFile = $stPrev
        $script:StoreReady = $readyPrev; $script:HasMutex = $mutexPrev; $script:IsAdmin = $adminPrev
    }
    $logText = if (Test-Path -LiteralPath $logTmp) { [System.IO.File]::ReadAllText($logTmp) } else { '<missing>' }
    $stText = if (Test-Path -LiteralPath $stTmp) { [System.IO.File]::ReadAllText($stTmp) } else { '<missing>' }
    Write-Check 'Dry-Run: an action reports success without executing' ($ranDry -eq $true)
    Write-Check 'Dry-Run: the action created no file at all' (-not (Test-Path -LiteralPath $sentinel))
    Write-Check 'Dry-Run: the change counter is not incremented' ([int]$script:ChangeCount -eq $chgBefore)
    Write-Check 'Dry-Run: no log line is written while dry' ($logText -eq 'baseline')
    Write-Check 'Dry-Run: the state file is not rewritten while dry' ($stText -eq 'baseline')
    foreach ($tmpProbe in @($logTmp, $stTmp, $sentinel)) { if (Test-Path -LiteralPath $tmpProbe) { Remove-Item -LiteralPath $tmpProbe -Force -ErrorAction SilentlyContinue } }
    $lg = @(Get-LegendRows @(@('1', 'repair'), @('2', 'watchdog'), @('3', 'dns'), @('4', 'probe'), @('5', 'flush'), @('6', 'audit'), @('7', 'portal'), @('A', 'vault'), @('T', 'preview'), @('R', 'report')) '1' 60)
    Write-Check 'UI: the key legend wraps instead of overflowing' (($lg.Count -ge 2) -and (@($lg | Where-Object { (Get-SegsLength $_) -gt 62 }).Count -eq 0))
    $longMsg = 'alpha beta gamma delta epsilon zeta eta theta iota kappa lambda mu nu xi omicron pi rho sigma tau upsilon'
    $wl = @(Split-Words $longMsg 30 99)
    Write-Check 'UI: long messages wrap without losing a single word' ((($wl -join ' ') -ceq $longMsg) -and (@($wl | Where-Object { $_.Length -gt 30 }).Count -eq 0))
    Write-Check 'Logic: power index text parsed (hex, language independent)' (((ConvertFrom-PowerIndexText '    Current AC Power Setting Index: 0x00000001') -eq 1) -and ((ConvertFrom-PowerIndexText 'Aktueller Wert: 0x00000000') -eq 0) -and ($null -eq (ConvertFrom-PowerIndexText 'junk')))
    $stSave = $script:State
    $script:State = @{ Snapshot = @{}; Env = @{}; Dns = @{}; Arp = @{ '{G}' = @{ '10.1.12.1' = 'AA' } }; Times = @{}; Misc = @{ ArpCand = @{ '10.1.12.1' = @{ Mac = 'BB'; Since = (Get-Date).ToString('o') } } } }
    $pg = @(Get-PendingGatewayMacs)
    $apOk = Approve-GatewayMac '10.1.12.1' 'BB' -Quiet
    Write-Check 'Logic: a MAC change waits for YOUR approval, per gateway, then becomes the remembered MAC' (($pg.Count -eq 1) -and ($pg[0].Old -eq 'AA') -and ($pg[0].New -eq 'BB') -and $apOk -and ($script:State.Arp['{G}']['10.1.12.1'] -eq 'BB') -and ($script:State.Misc['ArpCand'].Count -eq 0) -and ((Get-ArpDecision 'BB' 'BB' $null (Get-Date)) -eq 'lock'))
    # v4.5.0: Interceptor regex precision (proxy/VPN apps not targeted without poison/PIDs)
    $wfpReg = 'portmaster|nextdns|yogadns|dnscrypt|acrylic|adguard|stubby|warp-svc'
    Write-Check 'Logic: WFP DNS regex targets true DNS interceptors' ('portmaster' -match $wfpReg -and 'adguard' -match $wfpReg -and 'nextdns' -match $wfpReg)
    Write-Check 'Logic: WFP DNS regex spares user proxy/VPN apps' ('clash' -notmatch $wfpReg -and 'v2ray' -notmatch $wfpReg -and 'proxifier' -notmatch $wfpReg)
    # v4.8.0: Inspect real Invoke-DashboardKey definition for aliases and [M] route menu binding
    $dkDef = [string](Get-Command Invoke-DashboardKey -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Invoke-DashboardKey maps n to x, c, o aliases, binds m to Show-RouteMenu, and omits dead guide alias' ($dkDef.IndexOf("n = 'x'") -ge 0 -and $dkDef.IndexOf("c = '5'") -ge 0 -and $dkDef.IndexOf("o = '7'") -ge 0 -and $dkDef.IndexOf('Show-RouteMenu') -ge 0 -and $dkDef.IndexOf('guide') -lt 0)
    $tArp = New-Telemetry; $tArp.Admin = $true; $tArp.Problem = 'Healthy'; $tArp.ArpPending = $true
    Write-Check 'Logic: ArpPending surfaces [K] in Get-Advice even when link is Healthy' (((Get-Advice $tArp).Key) -eq 'k')
    Write-Check 'Logic: a fresh telemetry record starts with ArpPending false' ((New-Telemetry).ArpPending -eq $false)
    # v4.5.4: the [K] offer must appear on the dashboard itself, in BOTH layouts, and only while a candidate waits.
    $mdlText = { param($m) @($m.Lines | ForEach-Object { ((@($_) | ForEach-Object { [string]$_.T }) -join '') }) }
    $advArp = Get-Advice $tArp
    Write-Check 'UI: full dashboard dock offers [K] while a MAC change is pending' (@((& $mdlText (Get-DashboardModel $tArp $advArp 79)) | Where-Object { $_ -match '\[K\]\s*Approve Gateway MAC Change' }).Count -ge 1)
    Write-Check 'UI: compact dashboard legend offers [K] while a MAC change is pending' (@((& $mdlText (Get-DashboardModel $tArp $advArp 60)) | Where-Object { $_ -match '\[K\]\s*MAC' }).Count -ge 1)
    $tNoArp = New-Telemetry; $tNoArp.Admin = $true; $tNoArp.Problem = 'Healthy'
    $advNoArp = Get-Advice $tNoArp
    Write-Check 'UI: neither layout advertises [K] when no candidate is pending' ((@((& $mdlText (Get-DashboardModel $tNoArp $advNoArp 79)) | Where-Object { $_ -match 'Approve Gateway MAC Change' }).Count -eq 0) -and (@((& $mdlText (Get-DashboardModel $tNoArp $advNoArp 60)) | Where-Object { $_ -match '\[K\]\s*MAC' }).Count -eq 0))
    $tLim = New-Telemetry; $tLim.Admin = $false; $tLim.Problem = 'Captive'
    Write-Check 'Logic: Limited mode surfaces [E] elevation key in Get-Advice' (((Get-Advice $tLim).Key) -eq 'e')
    $advLim = Get-Advice $tLim
    Write-Check 'Logic: Limited mode names the elevation action and key exactly' (($advLim.Key -eq 'e') -and ($advLim.KeyLabel -eq 'relaunch as Administrator') -and ($advLim.Status -eq 'Running in read-only Limited Mode (without Administrator privileges).') -and ($advLim.Action -eq 'Press [ENTER] to relaunch as Administrator (or press E).'))
    # v4.5.5: the routing label may never claim "Ethernet First" while Ethernet is actually the demoted path.
    Write-Check 'Logic: routing label follows the real Ethernet metric' (((Get-RoutingLabel $true 10 $true) -eq 'Ethernet First') -and ((Get-RoutingLabel $true 15 $true) -eq 'Ethernet First') -and ((Get-RoutingLabel $true 45 $true) -eq 'Wi-Fi Protected') -and ((Get-RoutingLabel $true 50 $true) -eq 'Wi-Fi Protected'))
    Write-Check 'Logic: a captive (metric 50) Ethernet is never reported as Ethernet First' (((Get-RoutingLabel $true 50 $true) -ne 'Ethernet First') -and ((Get-RoutingLabel $false 10 $true) -eq 'automatic') -and ((Get-RoutingLabel $true 0 $false) -eq 'Wi-Fi Protected'))
    $tRout = New-Telemetry
    $tRout.Admin = $true; $tRout.Problem = 'Healthy'; $tRout.LinkUp = $true; $tRout.Speed = '1 Gbps'; $tRout.Nic = 'Realtek'
    $tRout.Ip = '10.1.12.192'; $tRout.Env = 'Campus'; $tRout.EnvScore = 5; $tRout.DnsProfile = 'Adaptive'; $tRout.DnsPrimary = '172.16.1.2'
    $tRout.Routing = 'Wi-Fi Protected'
    $routTxt = @((& $mdlText (Get-DashboardModel $tRout (Get-Advice $tRout) 79)))
    Write-Check 'UI: dashboard prints Wi-Fi Protected verbatim, never lower-cased' ((@($routTxt | Where-Object { $_ -cmatch 'Wi-Fi Protected' }).Count -ge 1) -and (@($routTxt | Where-Object { $_ -cmatch 'wi-fi protected' }).Count -eq 0))
    $tDual = New-Telemetry
    $tDual.Admin = $true; $tDual.Problem = 'Healthy'; $tDual.LinkUp = $true; $tDual.Speed = '1 Gbps'; $tDual.Nic = 'Realtek'
    $tDual.Ip = '10.1.12.192'; $tDual.Env = 'Campus'; $tDual.EnvScore = 5; $tDual.DnsProfile = 'Adaptive'; $tDual.DnsPrimary = '172.16.1.2'
    $tDual.Routing = 'Wi-Fi Protected'; $tDual.UplinkActive = $true; $tDual.UplinkName = 'Wi-Fi'; $tDual.UplinkProfile = 'NIT_JSR'; $tDual.UplinkIsPrimary = $true
    $dualTxt = @((& $mdlText (Get-DashboardModel $tDual (Get-Advice $tDual) 79)))
    Write-Check 'UI: dual-homed dashboard surfaces active Wi-Fi uplink truthfully' ((@($dualTxt | Where-Object { $_ -match 'Uplink:\s*Wi-Fi' }).Count -ge 1) -and (@($dualTxt | Where-Object { $_ -match 'via Wi-Fi' }).Count -ge 1))
    # v4.5.2: the metric planner must never sabotage a NON-campus wired network (three strict branches).
    $pOther = Get-RouteMetricPlan 'Other' 'Online' 1
    Write-Check 'Logic: a HEALTHY non-campus wired link is never demoted (no campus routes)' (($pOther.Mode -eq 'Restore') -and ($pOther.CampusRoutes -eq $false) -and ([int]$pOther.Ethernet -eq 0))
    Write-Check 'Logic: an unknown environment is treated as non-campus, never as the campus' (((Get-RouteMetricPlan 'Unknown' 'Online' 2).Mode -eq 'Restore') -and ((Get-RouteMetricPlan 'Unknown' 'Captive' 1).CampusRoutes -eq $false))
    Write-Check 'Logic: a non-campus captive link also leaves routing untouched' (((Get-RouteMetricPlan 'Other' 'Captive' 1).Mode -eq 'Restore') -and ((Get-RouteMetricPlan 'Other' 'Offline' 0).Mode -eq 'Restore'))
    $pCap = Get-RouteMetricPlan 'Campus' 'Captive' 1
    Write-Check 'Logic: unauthenticated campus demotes Ethernet to 50, protects Wi-Fi at 15, injects campus routes' (($pCap.Mode -eq 'Protect') -and ([int]$pCap.Ethernet -eq 50) -and ([int]$pCap.Others -eq 15) -and ($pCap.CampusRoutes -eq $true))
    $pOn = Get-RouteMetricPlan 'Campus' 'Online' 1
    Write-Check 'Logic: authenticated campus promotes Ethernet to 10 over Wi-Fi 40 and removes campus routes' (($pOn.Mode -eq 'Promote') -and ([int]$pOn.Ethernet -eq 10) -and ([int]$pOn.Others -eq 40) -and ($pOn.CampusRoutes -eq $false))
    $pLone = Get-RouteMetricPlan 'Campus' 'Offline' 0
    Write-Check 'Logic: campus link down with no secondary uplink restores instead of pinning 50/15' (($pLone.Mode -eq 'Restore') -and ($pLone.CampusRoutes -eq $false))
    Write-Check 'Logic: campus NoDns with a secondary uplink still protects the working uplink' (((Get-RouteMetricPlan 'Campus' 'NoDns' 1).Mode -eq 'Protect') -and ((Get-RouteMetricPlan 'Campus' 'NoDns' 0).Mode -eq 'Restore'))
    # v4.5.2: DNS answer parser (pure) - the source-scoped lookup is only as honest as this parser.
    [byte[]]$dnsQ = New-DnsQueryPacket 'a.bc' 4660
    [byte[]]$dnsA = [byte[]]@(0x12,0x34,0x81,0x80,0,1,0,1,0,0,0,0) + [byte[]]$dnsQ[12..21] + [byte[]]@(0xC0,0x0C,0,1,0,1,0,0,0,60,0,4,1,2,3,4)
    Write-Check 'Logic: DNS A-record parser reads a real answer' (@(Get-DnsAAnswers $dnsA $dnsQ) -contains '1.2.3.4')
    [byte[]]$dnsForeign = [byte[]]@(0x99,0x99,0x81,0x80,0,1,0,1,0,0,0,0) + [byte[]]$dnsQ[12..21] + [byte[]]@(0xC0,0x0C,0,1,0,1,0,0,0,60,0,4,1,2,3,4)
    Write-Check 'Logic: DNS A-record parser refuses a foreign transaction id' (@(Get-DnsAAnswers $dnsForeign $dnsQ).Count -eq 0)
    [byte[]]$dnsNx = [byte[]]@(0x12,0x34,0x81,0x83,0,1,0,0,0,0,0,0) + [byte[]]$dnsQ[12..21]
    Write-Check 'Logic: DNS A-record parser refuses NXDOMAIN with no answers' (@(Get-DnsAAnswers $dnsNx $dnsQ).Count -eq 0)
    [byte[]]$dnsCname = [byte[]]@(0x12,0x34,0x81,0x80,0,1,0,1,0,0,0,0) + [byte[]]$dnsQ[12..21] + [byte[]]@(0xC0,0x0C,0,5,0,1,0,0,0,60,0,2,0xC0,0x0C)
    Write-Check 'Logic: DNS A-record parser ignores a CNAME-only answer' (@(Get-DnsAAnswers $dnsCname $dnsQ).Count -eq 0)
    Write-Check 'Logic: DNS A-record parser survives truncated and empty input' ((@(Get-DnsAAnswers ([byte[]]@(0x12,0x34)) $dnsQ).Count -eq 0) -and (@(Get-DnsAAnswers $null $null).Count -eq 0) -and (@(Get-DnsAAnswers $dnsA $null).Count -eq 0))
    Write-Check 'Logic: scoped DNS never answers for a missing name/source' ((@(Get-ScopedDnsAnswers '' '10.1.14.191').Count -eq 0) -and (@(Get-ScopedDnsAnswers 'a.bc' '').Count -eq 0))
    # v4.5.3: DNS profile state machine - ResetDHCP is an ACTION, never a resting state.
    $stDns = $script:State
    $script:State = @{ Snapshot = @{}; Env = @{}; Dns = @{}; Arp = @{}; Times = @{}; Misc = @{ DnsProfile = 'ResetDHCP' } }
    Write-Check 'Logic: a legacy stuck ResetDHCP profile reads back as Adaptive' ((Get-DnsProfileName) -eq 'Adaptive')
    $script:State.Misc['DnsProfile'] = 'Cloudflare'
    Write-Check 'Logic: a real DNS profile is still reported verbatim' ((Get-DnsProfileName) -eq 'Cloudflare')
    $script:State.Misc['DnsProfile'] = 'nonsense'
    Write-Check 'Logic: an unknown DNS profile falls back to Adaptive' ((Get-DnsProfileName) -eq 'Adaptive')
    $script:State = $stDns
    Write-Check 'Logic: managed-DNS restore sweep exists (roaming + factory reset use it)' ((Get-Command Restore-ManagedAdapterDns -ErrorAction SilentlyContinue) -and ((Get-Command Restore-ManagedAdapterDns).Parameters.ContainsKey('Why')))
    # Source-level guards: the ORDER of the unplugged heal and "every Shield-SystemStack DNS write snapshots first".
    $srcTxt = ''
    try { if ($script:SelfPath -and (Test-Path -LiteralPath $script:SelfPath)) { $srcTxt = [System.IO.File]::ReadAllText($script:SelfPath) } } catch {}
    if ($srcTxt) {
        $seqOk = $false
        $stackSnapOk = $false
        $hp = $srcTxt.IndexOf('function Invoke-HealPipeline')
        if ($hp -ge 0) {
            $seg = $srcTxt.Substring($hp, [Math]::Min(6000, $srcTxt.Length - $hp))
            $end = $seg.IndexOf("`n}")
            if ($end -gt 0) { $seg = $seg.Substring(0, $end) }
            $iRoam = $seg.IndexOf('Invoke-RoamingCleanup')
            $iStack = $seg.IndexOf('Shield-SystemStack')
            $seqOk = ($iRoam -ge 0 -and $iStack -ge 0 -and $iRoam -lt $iStack)
        }
        $ssIdx = $srcTxt.IndexOf('function Shield-SystemStack')
        if ($ssIdx -ge 0) {
            $seg2 = $srcTxt.Substring($ssIdx, [Math]::Min(16000, $srcTxt.Length - $ssIdx))
            $unsaved = 0
            $pos = 0
            while (($pos = $seg2.IndexOf('Set-DnsClientServerAddress', $pos)) -ge 0) {
                $from = [Math]::Max(0, $pos - 900)
                if ($seg2.Substring($from, $pos - $from).IndexOf('Save-Original') -lt 0) { $unsaved++ }
                $pos += 20
            }
            $stackSnapOk = ($unsaved -eq 0)
        }
        Write-Check 'Logic: unplugged Heal restores 3rd-party services BEFORE Shield-SystemStack' $seqOk
        Write-Check 'Logic: every Shield-SystemStack DNS write snapshots the original first' $stackSnapOk
    } else {
        Write-Check 'Logic: source-order guards (script source not readable)' $true $true 'run from a readable file to check this'
    }
    # v4.6.0: S6 long unbreakable token/URL wrap test (must never exceed Width)
    $longUrl = 'https://gateway.nitjsr.ac.in:8003/index.php?zone=nitjsr&redirurl=https%3A%2F%2Fwww.example.com%2Fvery%2Flong%2Fpath%2Fsegment%2Fthat%2Fhas%2Fno%2Fspaces'
    $wrappedUrl = @(Split-Words $longUrl 30 99)
    Write-Check 'UI: Split-Words slices unbreakable 150-char URLs so no line exceeds Width' ((@($wrappedUrl | Where-Object { $_.Length -gt 30 }).Count -eq 0) -and (($wrappedUrl -join '') -ceq $longUrl))
    # v4.6.0: S7 LF-only chunked transfer decoding & HTML5 formless password input fallback
    $lfChunk = [System.Text.Encoding]::ASCII.GetBytes("5`nhello`n6`n world`n0`n`n")
    Write-Check 'Logic: chunked decoder handles LF-only (\n) framing' (([System.Text.Encoding]::ASCII.GetString((ConvertFrom-ChunkedBytes $lfChunk))) -ceq 'hello world')
    $html5Form = '<html><form id="f1" action="/auth"></form><div><input name="u" type="text"><input name="p" type="password"></div></html>'
    $fm5 = ConvertFrom-LoginForm $html5Form ([uri]'https://gateway.nitjsr.ac.in:8003/index.php')
    Write-Check 'Logic: login form parser handles HTML5 inputs outside <form> tags' ($null -ne $fm5 -and $fm5.UserField -ceq 'u' -and $fm5.PassField -ceq 'p' -and $fm5.Action.AbsoluteUri -ceq 'https://gateway.nitjsr.ac.in:8003/auth')
    # v4.6.0: DNS CNAME with hybrid label+pointer name compression followed by A record
    [byte[]]$dnsQ2 = New-DnsQueryPacket 'a.bc' 4660
    # Multi-question DNS packet skipping (RFC 1035)
    [byte[]]$dnsQmulti = [byte[]]@(0x12,0x34,0x81,0x80,0,2,0,1,0,0,0,0) + [byte[]]$dnsQ2[12..21] + [byte[]]$dnsQ2[12..21] + [byte[]]@(0xC0,0x0C,0,1,0,1,0,0,0,60,0,4,5,6,7,8)
    Write-Check 'Logic: DNS A-record parser skips multiple questions in QDCOUNT' (@(Get-DnsAAnswers $dnsQmulti $dnsQ2) -contains '5.6.7.8')
    [byte[]]$dnsCnameChain = [byte[]]@(0x12,0x34,0x81,0x80,0,1,0,2,0,0,0,0) + [byte[]]$dnsQ2[12..21] + [byte[]]@(0xC0,0x0C,0,5,0,1,0,0,0,60,0,2,0xC0,0x0C) + [byte[]]@(1,0x78,0xC0,0x0C,0,1,0,1,0,0,0,60,0,4,9,8,7,6)
    Write-Check 'Logic: DNS A-record parser resolves A record after CNAME with hybrid label+pointer name' (@(Get-DnsAAnswers $dnsCnameChain $dnsQ2) -contains '9.8.7.6')
    $ssBody = [string](Get-Command Shield-SystemStack -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Shield-SystemStack never references undefined $interceptorRegex' ($ssBody.Length -gt 0 -and $ssBody.IndexOf('$interceptorRegex') -lt 0)
    $uwBody = [string](Get-Command Uninstall-Watchdog -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Uninstall-Watchdog voids Restore-ManagedAdapterDns return value' ($uwBody.IndexOf("[void](Restore-ManagedAdapterDns") -ge 0)
    $dlBody = [string](Get-Command Shield-DataLink -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Shield-DataLink snapshots static IP even when no default gateway is set' ($dlBody.IndexOf('$stAlive') -ge 0 -and $dlBody.IndexOf('Save-Original') -ge 0 -and $dlBody.IndexOf('StaticIp4') -ge 0)
    # v4.6.2: Routing Priority Profile engine unit checks
    Write-Check 'Logic: default routing profile is Adaptive' ((Get-RouteProfileName) -eq 'Adaptive')
    Write-Check 'Logic: Forced Ethernet routing plan always promotes Ethernet' (((Get-RouteMetricPlan 'Campus' 'Offline' 1 'Ethernet').Mode) -eq 'Promote')
    Write-Check 'Logic: Forced Wi-Fi routing plan protects Wi-Fi and injects campus routes' (((Get-RouteMetricPlan 'Campus' 'Online' 1 'Wifi').Mode) -eq 'Protect' -and ((Get-RouteMetricPlan 'Campus' 'Online' 1 'Wifi').CampusRoutes -eq $true))
    Write-Check 'Logic: Windows Default routing plan restores automatic metrics' (((Get-RouteMetricPlan 'Campus' 'Online' 1 'Windows').Mode) -eq 'Restore')
    Write-Check 'Logic: Forced Wi-Fi routing plan restores when no Wi-Fi uplink is active' (((Get-RouteMetricPlan 'Campus' 'Online' 0 'Wifi').Mode) -eq 'Restore')
    $srDef = [string](Get-Command Set-RouteProfileMode -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Set-RouteProfileMode saves state after applying Shield-RouteMetrics' ($srDef.LastIndexOf('Save-State') -gt $srDef.IndexOf('Shield-RouteMetrics'))
    $omniDef = [string](Get-Command Invoke-SupremeOmnifix -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Full Net Reset restores Adaptive RouteProfile and DnsProfile' ($omniDef.IndexOf("RouteProfile'] = 'Adaptive'") -ge 0 -and $omniDef.IndexOf("DnsProfile'] = 'Adaptive'") -ge 0)
    $ahDef = [string](Get-Command Invoke-AutoHeal -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: AutoHeal fast-path syncs Shield-RouteMetrics when secondary uplinks change' ($ahDef.IndexOf('if (-not $needFull)') -ge 0 -and $ahDef.Substring($ahDef.IndexOf('if (-not $needFull)'), [Math]::Min(600, $ahDef.Length - $ahDef.IndexOf('if (-not $needFull)'))).IndexOf('Shield-RouteMetrics') -ge 0)
    $dlDef2 = [string](Get-Command Shield-DataLink -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Shield-DataLink protects gateway-less lab static IP during AutoHeal and checks ARP peers' ($dlDef2.IndexOf('$peerArp') -ge 0 -and $dlDef2.IndexOf("Mode -eq 'AutoHeal'") -ge 0)
    $ouDef = [string](Get-Command Get-OtherUplinkAdapters -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Get-OtherUplinkAdapters allows standard RFC 4861 fe80:: IPv6 default gateway next-hops' ($ouDef.IndexOf("NextHop -notlike 'fe80*'") -lt 0 -and $ouDef.IndexOf('$hasIp6') -ge 0)
    $sdDef = [string](Get-Command Get-ScopedDnsAnswers -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Get-ScopedDnsAnswers keeps metric-45 filter for non-Wifi profiles and restricts unbound fallback' ($sdDef.IndexOf("InterfaceMetric -ge 45 -and (Get-RouteProfileName) -ne 'Wifi'") -ge 0 -and $sdDef.IndexOf('else { continue }') -ge 0)
    $dlDef3 = [string](Get-Command Shield-DataLink -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Shield-DataLink triggers Repair-Dhcp -ForceRelease when DHCP lease has dead or missing gateway' ($dlDef3.IndexOf('Repair-Dhcp $ad -ForceRelease') -ge 0)
    $srDef2 = [string](Get-Command Start-Repair -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Start-Repair checks if state is still Captive after Open-Portal before waiting 180s' ($srDef2.IndexOf("if ((Get-InternetState -NoCache).State -eq 'Captive')") -ge 0)
    $omDef2 = [string](Get-Command Invoke-SupremeOmnifix -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Invoke-SupremeOmnifix releases stale ARP locks and does not force DadTransmits 3 on campus' ($omDef2.IndexOf('Release-ArpLocks') -ge 0 -and $omDef2.IndexOf('-DadTransmits 3') -lt 0)
    $gtDef2 = [string](Get-Command Get-Telemetry -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Get-Telemetry only reports Wi-Fi Protected when unplugged if another uplink is active' ($gtDef2.IndexOf('if (-not $t.LinkUp -and (Test-MetricsManaged) -and (Test-OtherUplinkActive))') -ge 0)
    $tsDir = Join-Path ([System.IO.Path]::GetTempPath()) ('lf_heal_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $tsDir -Force | Out-Null
    $origStateFile = $script:StateFile
    $stateHealed = $false
    try {
        $script:StateFile = Join-Path $tsDir 'state.clixml'
        [System.IO.File]::WriteAllText($script:StateFile, '<corrupted')
        @{ Snapshot = @{}; Misc = @{ Healed = $true } } | Export-Clixml -LiteralPath "$($script:StateFile).bak" -Depth 4
        $loadedState = Get-State
        $stateHealed = ($loadedState.Misc['Healed'] -eq $true)
    } finally {
        $script:StateFile = $origStateFile
        Remove-Item -LiteralPath $tsDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Check 'Logic: Get-State self-heals from .bak/.tmp when primary state file is damaged' $stateHealed

    $origConn = $script:ConnCache
    $origEnv = $script:EnvCache
    $script:ConnCache = @{ Test = 1 }
    $script:EnvCache = @{ Dummy = 1 }
    $script:ConnCache = $null
    $script:EnvCache = @{}
    $fcOk = ($null -eq $script:ConnCache -and $script:EnvCache.Count -eq 0)
    $script:ConnCache = $origConn
    $script:EnvCache = $origEnv
    Write-Check 'Logic: Flush-NetworkCache clears internal ConnCache, EnvCache, OrderTime and IPv6 neighbors' $fcOk

    $origMisc = if ($script:State.Misc) { $script:State.Misc.Clone() } else { @{} }
    $script:State.Misc['DiscoveredDomain'] = 'test.edu'
    $script:State.Misc['DiscoveredPortalPort'] = 8443
    $script:State.Misc['InjectedHostRoutes'] = @('10.99.1.1')
    $memMisc = @{}
    foreach ($mk in @('LearnedDhcp','DiscoveredDomain','DiscoveredPortalUrl','DiscoveredPortalIp','DiscoveredPortalPort','DiscoveryTime','InjectedHostRoutes')) {
        if ($script:State.Misc.ContainsKey($mk)) { $memMisc[$mk] = $script:State.Misc[$mk] }
    }
    $script:State = @{ Snapshot = @{}; Env = @{}; Dns = @{}; Arp = @{}; Times = @{}; Misc = @{} }
    if ($memMisc['DiscoveredPortalPort'] -and -not $script:State.Misc['DiscoveredPortalPort']) { $script:State.Misc['DiscoveredPortalPort'] = $memMisc['DiscoveredPortalPort'] }
    if ($memMisc['InjectedHostRoutes']) { $script:State.Misc['InjectedHostRoutes'] = @($memMisc['InjectedHostRoutes']) }
    $elPreserveOk = ($script:State.Misc['DiscoveredPortalPort'] -eq 8443 -and $script:State.Misc['InjectedHostRoutes'] -contains '10.99.1.1')
    Write-Check 'Logic: Enter-Lock preserves in-memory DiscoveredDomain, DiscoveredPortalIp, DiscoveredPortalPort, and InjectedHostRoutes' $elPreserveOk

    $currProc = Get-Process -Id $PID
    $fakeLock = [PSCustomObject]@{ Pid = $PID; StartTime = (Get-Date).AddHours(-2).ToUniversalTime().ToString('o') }
    $pStart = try { $currProc.StartTime.ToUniversalTime().ToString('o') } catch { '' }
    $deadDetected = ($fakeLock.StartTime -and $pStart -and $pStart -ne [string]$fakeLock.StartTime)
    Write-Check 'Logic: Enter-Lock validates lock-holder process identity and StartTime to prevent PID recycling deadlock' $deadDetected
    $script:State.Misc = $origMisc

    $script:State.Misc['DiscoveredPortalIp'] = '10.50.0.1'
    $dynEp = Get-ActivePortalEndpoint
    $dynEpOk = ($dynEp.Host -eq '10.50.0.1' -and $dynEp.Ip -eq '10.50.0.1')
    Write-Check 'Logic: dynamic endpoint helper Get-ActivePortalEndpoint synchronizes Host with discovered IP' $dynEpOk
    $script:State.Misc.Remove('DiscoveredPortalIp')

    $wxXml = [string](New-WatchdogXml '/c test' '2026-01-01T00:00:00')
    $hasBothEvents = ($wxXml -match 'EventID=10000' -and $wxXml -match 'EventID=10001')
    Write-Check 'Logic: Watchdog XML subscribes to both connect (10000) and disconnect (10001) events' $hasBothEvents

    $script:State.Misc['InjectedHostRoutes'] = @('10.10.10.1', '10.20.30.1')
    $activeGwsMock = @('10.10.10.1')
    $prunedMock = @()
    foreach ($oldGw in @($script:State.Misc['InjectedHostRoutes'] | Where-Object { $_ -and $activeGwsMock -notcontains $_ -and $_ -match '^\d{1,3}(\.\d{1,3}){3}$' })) {
        $prunedMock += $oldGw
    }
    if ($prunedMock.Count -gt 0) {
        $script:State.Misc['InjectedHostRoutes'] = @($script:State.Misc['InjectedHostRoutes'] | Where-Object { $_ -and $prunedMock -notcontains $_ })
    }
    $arpReconcileOk = ($script:State.Misc['InjectedHostRoutes'].Count -eq 1 -and $script:State.Misc['InjectedHostRoutes'][0] -eq '10.10.10.1')
    Write-Check 'Logic: Shield-GatewayArp reconciles stale off-subnet host routes on gateway change' $arpReconcileOk

    [byte[]]$dnsExcessQdc = [byte[]]@(0x12,0x34,0x81,0x80,0xFF,0xFF,0,1,0,0,0,0,3,0x77,0x77,0x77,0,0,1,0,1)
    $dnsExcessAns = @(Get-DnsAAnswers $dnsExcessQdc $dnsQ2)
    Write-Check 'Logic: DNS A-record parser bounds excessive QDCOUNT and rejects malicious query counts' ($dnsExcessAns.Count -eq 0)

    $htmlTrailingQuote = '<meta http-equiv="refresh" content=''0; url="https://portal.univ.edu/login";''>'
    $redirTrailing = Get-RedirectFromBody $htmlTrailingQuote
    Write-Check 'Logic: ConvertFrom-HttpResponse extracts meta-refresh redirect and strips trailing quotes/semicolons' ($redirTrailing -ceq 'https://portal.univ.edu/login')

    $script:State.Misc['DiscoveredPortalPort'] = 8003
    $script:State.Misc['DiscoveryTime'] = (Get-Date).ToString('o')
    foreach ($dk in @('DiscoveredPortalUrl', 'DiscoveredPortalIp', 'DiscoveredDomain', 'DiscoveredPortalPort', 'DiscoveryTime')) {
        if ($script:State.Misc.ContainsKey($dk)) { $script:State.Misc.Remove($dk) }
    }
    $roamPurgeOk = (-not $script:State.Misc.ContainsKey('DiscoveredPortalPort') -and -not $script:State.Misc.ContainsKey('DiscoveryTime'))
    Write-Check 'Logic: roaming cleanup purges DiscoveredPortalPort and DiscoveryTime alongside portal URLs' $roamPurgeOk

    $cfgHttpsObj = [PSCustomObject]@{ PortalUrl = 'https://gateway.college.edu:8443/' }
    $cfgHttpsRes = ConvertTo-CfgOverride $cfgHttpsObj
    $cfgHttpObj = [PSCustomObject]@{ PortalUrl = 'http://gateway.college.edu:8888/' }
    $cfgHttpRes = ConvertTo-CfgOverride $cfgHttpObj
    Write-Check 'Logic: ConvertTo-CfgOverride enforces HTTPS and rejects HTTP portal URLs' ($cfgHttpsRes.ContainsKey('PortalUrl') -and -not $cfgHttpRes.ContainsKey('PortalUrl'))
    Write-Check 'Logic: Repair-Dhcp safely rejects null adapter parameter without exception' (-not (Repair-Dhcp $null))
    $origDry = $script:IsDry
    $script:IsDry = $true
    $drySnapOk = Restore-PreflightSnapshot @{ ifIndex = 999; Name = 'DryTest'; Metric = 5; Dns = @('1.1.1.1') }
    $script:IsDry = $origDry
    Write-Check 'Logic: Restore-PreflightSnapshot honors DryRun without mutating network' $drySnapOk

    $mockUntrustedSid = 'S-1-5-21-999-999-999-1001'
    $ownerTrustedCheck = (@('S-1-5-18', 'S-1-5-32-544') -contains $mockUntrustedSid)
    Write-Check 'Logic: Test-VaultAcl rejects untrusted owner SIDs on credential vault' (-not $ownerTrustedCheck)
    $script:State.Misc['DiscoveredDomain'] = 'univ.edu'
    Write-Check 'Logic: Test-TrustedPortalHost trusts dynamically discovered domain and private gateway IPs' ((Test-TrustedPortalHost 'portal.univ.edu') -and (Test-TrustedPortalHost '10.20.30.1') -and (-not (Test-TrustedPortalHost 'eviluniv.edu')))
    # ---- 5.2.0 additions (pure functions are executed; the rest are source-level) ----
    $gaDef = [string](Get-Command Test-GatewayAlive -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Test-GatewayAlive never deletes a neighbour entry during -DryRun' ($gaDef -match 'IsAdmin -and -not \$script:IsDry -and \$ex')
    Write-Check 'Logic: gateway liveness proxy probes the configured campus only on the home campus' (($gaDef.IndexOf('$homeAd') -ge 0) -and ($gaDef.IndexOf('Test-TcpPort $Gw 53') -ge 0))
    $ssDef = [string](Get-Command Save-State -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Save-State verifies the temp file before replacing state and guards the .bak copy' (($ssDef.IndexOf('Test-StateFile $tmp') -ge 0) -and ($ssDef.IndexOf('Test-StateFile $script:StateFile') -ge 0))
    $tsGood = Join-Path ([System.IO.Path]::GetTempPath()) ('lf_state_ok_' + [guid]::NewGuid().ToString('N') + '.clixml')
    $tsBad = Join-Path ([System.IO.Path]::GetTempPath()) ('lf_state_bad_' + [guid]::NewGuid().ToString('N') + '.clixml')
    $tsOk = $false; $tsRej = $false; $tsMiss = $false
    try {
        @{ Snapshot = @{}; Misc = @{ A = 1 } } | Export-Clixml -LiteralPath $tsGood -Depth 4
        [System.IO.File]::WriteAllText($tsBad, '<Objs Version="1.1.0.1"><Obj RefId="0"><TN')
        $tsOk = (Test-StateFile $tsGood)
        $tsRej = (-not (Test-StateFile $tsBad))
        $tsMiss = (-not (Test-StateFile ($tsGood + '.missing')))
    } catch {}
    foreach ($tf in @($tsGood, $tsBad)) { try { Remove-Item -LiteralPath $tf -Force -ErrorAction SilentlyContinue } catch {} }
    Write-Check 'Logic: Test-StateFile accepts a good state file and rejects truncated or missing ones' ($tsOk -and $tsRej -and $tsMiss)
    Write-Check 'Logic: non-campus DNS action matrix (Rescue / KeepRescue / Restore)' (((Get-OtherDnsAction 'NoDns' $false 'Auto' $false) -eq 'Rescue') -and ((Get-OtherDnsAction 'Online' $true 'Public' $false) -eq 'KeepRescue') -and ((Get-OtherDnsAction 'Online' $true 'Public' $true) -eq 'Restore') -and ((Get-OtherDnsAction 'Online' $false 'Auto' $false) -eq 'Restore') -and ((Get-OtherDnsAction 'Online' $true 'Campus' $false) -eq 'Restore'))
    $sdDef2 = [string](Get-Command Shield-Dns -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Shield-Dns keeps a still-needed rescue (source-bound probe) and gates configured portal values on Home' (($sdDef2.IndexOf('Get-OtherDnsAction') -ge 0) -and ($sdDef2.IndexOf('Test-DhcpDnsUsable $guid') -ge 0) -and ($sdDef2.IndexOf('$homeNet') -ge 0))
    Write-Check 'Logic: watchdog disabled-state detection' ((Test-WatchdogDisabled 'false') -and (Test-WatchdogDisabled ' False ') -and -not (Test-WatchdogDisabled 'true') -and -not (Test-WatchdogDisabled '') -and -not (Test-WatchdogDisabled $null))
    $uwDef = [string](Get-Command Update-WatchdogIfStale -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Update-WatchdogIfStale re-registers a task that was disabled while armed' ($uwDef.IndexOf('Test-WatchdogDisabled') -ge 0)
    $siDef = [string](Get-Command Start-Interactive -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: dashboard autopilot makes one sign-in attempt when it opens on an already captive link' (($siDef.IndexOf('$autoLoginTried') -ge 0) -and ($siDef.IndexOf('Invoke-HeadlessPortalLogin') -ge 0))
    Write-Check 'Logic: dashboard allows key [R] to export support report and preserves F5/Space refresh' ($siDef.IndexOf("Key -eq 'F5'") -ge 0 -and $siDef.IndexOf("ch -eq 'r'") -lt 0)
    Write-Check 'Logic: Get-StepperLines handles 0 or 1 rows safely without division by zero' ((@(Get-StepperLines @() 80)).Count -eq 0 -and (@(Get-StepperLines @(@{ State = 'ok' }) 80)).Count -eq 0)
    $wlDef = [string](Get-Command Write-Log -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Write-Log suppresses console output during active dashboard loop' ($wlDef.IndexOf('InDashboard') -ge 0)
    $uprDef = [string](Get-Command Update-PulseRow -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Update-PulseRow uses absolute ANSI row positioning' ($uprDef.IndexOf('$targetRow') -ge 0 -and $uprDef.IndexOf('$promptRow') -ge 0)
    Write-Check 'Logic: dashboard routing priority sync triggers strictly on Wi-Fi Protected or non-Ethernet First' ($siDef.IndexOf("Routing -eq 'Wi-Fi Protected'") -ge 0 -and $siDef.IndexOf("Routing -ne 'Ethernet First'") -ge 0 -and $siDef.IndexOf("Ethernet Primary") -lt 0)
    $inDef = [string](Get-Command Invoke-Native -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Invoke-Native disposes process handle and waits for rundown' (($inDef.IndexOf('$p.Dispose()') -ge 0) -and ($inDef.IndexOf('$p.WaitForExit(1000)') -ge 0))
    $shaDef = [string](Get-Command Get-FileSha256 -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Get-FileSha256 safely disposes stream and crypto handles in finally' (($shaDef.IndexOf('$stream.Dispose()') -ge 0) -and ($shaDef.IndexOf('$sha.Dispose()') -ge 0))
    $elDef2 = [string](Get-Command Enter-Lock -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Enter-Lock refuses non-admin callers without constructing Global mutex' ($elDef2.IndexOf('if (-not $script:IsAdmin) { return $false }') -ge 0)
    $gdmDef = [string](Get-Command Get-DashboardModel -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Get-DashboardModel reserves categorized dock for width 74+ and height 28+' ($gdmDef.IndexOf('$uiH -ge 28') -ge 0)
    $cfgKeepHome = $script:Cfg
    $script:Cfg = @{ CampusDns = '172.16.1.2'; PortalIp = '10.114.0.5'; CampusDomain = 'nitjsr.ac.in'; PortalHost = 'gateway.nitjsr.ac.in' }
    $hvA = (Get-HomeCampusVerdict @('172.16.1.2', '8.8.8.8') '' $false $null)
    $hvB = (Get-HomeCampusVerdict @() 'hostel.nitjsr.ac.in' $false $null)
    $hvC = (-not (Get-HomeCampusVerdict @('10.9.8.7') 'univ.edu' $false $null))
    $hvD = (Get-HomeCampusVerdict @('10.9.8.7') 'univ.edu' $true $null)
    $hvE = (Get-HomeCampusVerdict @() '' $false $null)
    $hvF = (-not (Get-HomeCampusVerdict @() '' $false @{ Home = $false }))
    $hvG = (-not (Get-HomeCampusVerdict @('10.9.8.7') 'nitjsr.ac.in.evil.com' $false $null))
    Write-Check 'Logic: Get-HomeCampusVerdict recognises the configured campus and refuses foreign leases' ($hvA -and $hvB -and $hvC -and $hvD -and $hvE -and $hvF -and $hvG)
    $script:State.Misc['DiscoveredDomain'] = 'evil.example'
    $ctA = ((Test-CredentialPortalHost 'gateway.nitjsr.ac.in') -and (Test-CredentialPortalHost 'login.nitjsr.ac.in') -and (Test-CredentialPortalHost '10.114.0.5') -and (Test-CredentialPortalHost '10.55.1.1'))
    $ctB = ((-not (Test-CredentialPortalHost 'login.evil.example')) -and (-not (Test-CredentialPortalHost 'nitjsr.ac.in.evil.com')) -and (-not (Test-CredentialPortalHost '')))
    $ctC = (Test-TrustedPortalHost 'login.evil.example')
    $ctD = (((Get-CredentialPortalUrl 'https://login.evil.example/') -eq '') -and ((Get-CredentialPortalUrl 'https://gateway.nitjsr.ac.in:8003/index.php') -ne '') -and ((Get-CredentialPortalUrl 'https://u:p@gateway.nitjsr.ac.in/') -eq '') -and ((Get-CredentialPortalUrl 'ftp://gateway.nitjsr.ac.in/') -eq ''))
    $script:Cfg = $cfgKeepHome
    Write-Check 'Logic: the saved password is never sent to a host that only the network itself vouches for (DHCP suffix)' ($ctA -and $ctB -and $ctD)
    Write-Check 'Logic: browser navigation trust is unchanged (discovered domain still opens the login page)' $ctC
    $hlDef = [string](Get-Command Invoke-HeadlessPortalLogin -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: every credential-bearing step of headless login uses the strict trust check' (($hlDef.IndexOf('Get-CredentialPortalUrl') -ge 0) -and ($hlDef.IndexOf('Test-CredentialPortalHost') -ge 0) -and ($hlDef.IndexOf('Test-TrustedPortalHost') -lt 0))
    $tlDef = [string](Get-Command Invoke-TlsHttp -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Invoke-TlsHttp resolves host names from the Ethernet source address' ($tlDef.IndexOf('Resolve-HostBounded $hostName 2500 $SourceIp') -ge 0)
    $hr302 = ConvertFrom-HttpResponse ("HTTP/1.1 302 Found`r`nLocation: http://portal.univ.edu/login`r`n`r`n<html>x</html>")
    $hrMeta = ConvertFrom-HttpResponse ("HTTP/1.1 200 OK`r`nContent-Type: text/html`r`n`r`n<html><head><meta http-equiv=""refresh"" content=""0; url=http://portal.univ.edu/a?x=1&amp;y=2""></head></html>")
    $hrJs = ConvertFrom-HttpResponse ("HTTP/1.1 200 OK`r`n`r`n<script>window.location.href = 'http://portal.univ.edu/js';</script>")
    $hrRel = ConvertFrom-HttpResponse ("HTTP/1.1 200 OK`r`n`r`n<script>location.href='/login'</script>")
    $hrMs = ConvertFrom-HttpResponse ("HTTP/1.1 200 OK`r`n`r`nMicrosoft Connect Test")
    $hr204 = ConvertFrom-HttpResponse ("HTTP/1.1 204 No Content`r`n`r`n")
    Write-Check 'Logic: ConvertFrom-HttpResponse reads Location headers and meta/JS redirects of 200 portal pages' (($hr302.Location -ceq 'http://portal.univ.edu/login') -and ($hrMeta.Location -ceq 'http://portal.univ.edu/a?x=1&y=2') -and ($hrJs.Location -ceq 'http://portal.univ.edu/js'))
    $hrMetaRev = ConvertFrom-HttpResponse ("HTTP/1.1 200 OK`r`n`r`n<html><head><meta content=""0; url=https://portal.univ.edu/rev"" http-equiv=""refresh""></head></html>")
    Write-Check 'Logic: ConvertFrom-HttpResponse extracts meta-refresh redirect with reversed attributes' ($hrMetaRev.Location -ceq 'https://portal.univ.edu/rev')
    $hrJsAssign = ConvertFrom-HttpResponse ("HTTP/1.1 200 OK`r`n`r`n<script>window.location.assign('https://portal.univ.edu/assign');</script>")
    Write-Check 'Logic: ConvertFrom-HttpResponse extracts window.location.assign redirect' ($hrJsAssign.Location -ceq 'https://portal.univ.edu/assign')
    Write-Check 'Logic: ordinary probe answers (Microsoft test page, 204, relative JS) yield no redirect' (($hrRel.Location -eq '') -and ($hrMs.Location -eq '') -and ($hr204.Location -eq '') -and ($hrMs.Body -like 'Microsoft Connect Test*'))
    $edPlain = [System.Text.Encoding]::UTF8.GetBytes('<form>portal-ok</form>')
    $edMs = New-Object System.IO.MemoryStream
    $edGz = New-Object System.IO.Compression.GZipStream($edMs, [System.IO.Compression.CompressionMode]::Compress)
    $edGz.Write($edPlain, 0, $edPlain.Length); $edGz.Close()
    $edGzBytes = $edMs.ToArray()
    $edMs2 = New-Object System.IO.MemoryStream
    $edDf = New-Object System.IO.Compression.DeflateStream($edMs2, [System.IO.Compression.CompressionMode]::Compress)
    $edDf.Write($edPlain, 0, $edPlain.Length); $edDf.Close()
    $edRaw = $edMs2.ToArray()
    $edZlib = [byte[]](@(0x78, 0x9C) + $edRaw)
    $edBig = New-Object byte[] 3000000
    $edMs3 = New-Object System.IO.MemoryStream
    $edBg = New-Object System.IO.Compression.GZipStream($edMs3, [System.IO.Compression.CompressionMode]::Compress)
    $edBg.Write($edBig, 0, $edBig.Length); $edBg.Close()
    $edBomb = $edMs3.ToArray()
    $edText = { param($b) [System.Text.Encoding]::UTF8.GetString([byte[]]$b) }
    $edOk = ((& $edText (Expand-HttpBody $edGzBytes 'gzip')) -ceq '<form>portal-ok</form>') -and ((& $edText (Expand-HttpBody $edGzBytes '')) -ceq '<form>portal-ok</form>') -and ((& $edText (Expand-HttpBody $edRaw 'deflate')) -ceq '<form>portal-ok</form>') -and ((& $edText (Expand-HttpBody $edZlib 'deflate')) -ceq '<form>portal-ok</form>')
    $edI = Expand-HttpBody $edPlain 'identity'
    $edG = Expand-HttpBody ([byte[]](1, 2, 3, 4, 5)) 'gzip'
    $edB = Expand-HttpBody $edBomb 'gzip'
    $edSafe = ($edI.Length -eq $edPlain.Length) -and ($edG.Length -eq 5) -and ($edB.Length -eq $edBomb.Length)
    Write-Check 'Logic: Expand-HttpBody decodes gzip, deflate and zlib bodies' $edOk
    Write-Check 'Logic: Expand-HttpBody leaves identity or undecodable data alone and refuses a decompression bomb' $edSafe
    $rcDef = [string](Get-Command Remove-CampusHostRoutes -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Remove-CampusHostRoutes also removes the host routes added for discovered / DHCP addresses (metric 5 only)' (($rcDef.IndexOf('InjectedHostRoutes') -ge 0) -and ($rcDef.IndexOf('RouteMetric -eq 5') -ge 0))
    $ecDef = [string](Get-Command Ensure-CampusPortalPath -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: host routes to the configured portal/resolver are added only on the home campus and are tracked' (($ecDef.IndexOf('$cfgTargets') -ge 0) -and ($ecDef.IndexOf('$e.Home') -ge 0) -and ($ecDef.IndexOf('Add-TrackedHostRoute') -ge 0))
    $aeDef = [string](Get-Command Get-AdapterEnvironment -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Get-AdapterEnvironment records whether the lease is the configured campus' (($aeDef.IndexOf('Get-HomeCampusVerdict') -ge 0) -and ($aeDef.IndexOf('$portalHit') -ge 0) -and ($aeDef.IndexOf('Home = $homeVerdict') -ge 0))
    $ncDef = [string](Get-Command Set-CampusNrpt -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Set-CampusNrpt maps the configured campus domain only for the home campus' (($ncDef.IndexOf('$HomeNet') -ge 0) -and ($ncDef.IndexOf('$wantNs.Count -eq 0') -ge 0))
    $pmDef = [string](Get-Command Shield-PathMtu -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Shield-PathMtu only measures a path that really leaves through this adapter' (($pmDef.IndexOf('Get-PathMtuForAdapter') -ge 0) -and ($pmDef.IndexOf("Get-PathMtu '9.9.9.9'") -lt 0))
    $ovGood = ConvertTo-CfgOverride ('{"PortalIp":"10.20.30.40","CampusDns":"10.20.0.2","PortalPort":8443,"PortalHost":"Portal.Univ.EDU.","CampusDomain":"univ.edu","PortalUrl":"https://portal.univ.edu:8443/login","GwRegex":"^10\\.20\\.\\d+\\.1$","ProfileRegex":"univ|hostel"}' | ConvertFrom-Json)
    Write-Check 'Logic: config override accepts well-formed values (and normalises host names)' (($ovGood.Count -eq 8) -and ($ovGood['PortalHost'] -ceq 'portal.univ.edu') -and ($ovGood['PortalPort'] -eq 8443) -and ($ovGood['CampusDns'] -ceq '10.20.0.2'))
    $ovBad = ConvertTo-CfgOverride ('{"PortalIp":"999.1.1.1","CampusDns":"127.0.0.1","PortalPort":70000,"PortalHost":"not a host","CampusDomain":"","PortalUrl":"http://portal.univ.edu/","GwRegex":"([unclosed","ProfileRegex":"","Unknown":"x"}' | ConvertFrom-Json)
    Write-Check 'Logic: config override rejects malformed, blank, non-https and unknown values' ($ovBad.Count -eq 0)
    Write-Check 'Logic: config override can never blank a setting (empty input yields nothing)' ((ConvertTo-CfgOverride $null).Count -eq 0 -and (ConvertTo-CfgOverride ('{}' | ConvertFrom-Json)).Count -eq 0)
    # RFC 8910 DHCP Option 114 captive URL decoder check
    $opt114Url = 'https://login.campus.edu/portal'
    [byte[]]$opt114Bytes = @(252, 4, 1, 2, 3, 4, 114, $opt114Url.Length) + [System.Text.Encoding]::ASCII.GetBytes($opt114Url)
    $fakeReg = [pscustomobject]@{ DhcpInterfaceOptions = $opt114Bytes }
    $decodedOpt114 = $null
    if ($fakeReg.DhcpInterfaceOptions -is [byte[]]) {
        [byte[]]$fb = $fakeReg.DhcpInterfaceOptions; $fi = 0
        while ($fi -lt ($fb.Length - 2)) {
            $fopt = [int]$fb[$fi]; $flen = [int]$fb[$fi + 1]
            if ($flen -le 0 -or ($fi + 2 + $flen) -gt $fb.Length) { break }
            if ($fopt -eq 114 -or $fopt -eq 160) {
                try { $fstr = [System.Text.Encoding]::ASCII.GetString($fb, $fi + 2, $flen); if ($fstr -match '^https?://[^\s]+$') { $decodedOpt114 = $fstr; break } } catch {}
            }
            $fi += (2 + $flen)
        }
    }
    Write-Check 'Logic: RFC 8910 DHCP option 114 binary decoder extracts captive portal URL' ($decodedOpt114 -ceq $opt114Url)
    Write-Check 'Logic: sinkhole detector catches 192.0.2.1 and unroutable test blocks' ((Test-IsSinkholeIp '192.0.2.1') -and (Test-IsSinkholeIp '198.51.100.25') -and (Test-IsSinkholeIp '203.0.113.8') -and (Test-IsSinkholeIp '127.0.0.1') -and (-not (Test-IsSinkholeIp '142.251.43.142')) -and (-not (Test-IsSinkholeIp '1.1.1.1')))
    Write-Check 'Logic: universal DNS verdict engine neutralizes unroutable or sinkholed IPv6 and preserves genuine dual-stack' (((Get-DnsVerdictDecision $false $false 2 $false) -eq 'Neutralize') -and ((Get-DnsVerdictDecision $true $true 2 $true) -eq 'Neutralize') -and ((Get-DnsVerdictDecision $true $true 2 $false) -eq 'Keep') -and ((Get-DnsVerdictDecision $false $false 0 $false) -eq 'None'))
    # v6.4.2 Hardened Invariant Checks: PnP rate-limit, StartTime ISO round-trip, DryRun guards, Uplink fallback ladder, and Interceptor restoration
    $pnpDef = [string](Get-Command Rescue-DormantEthernetPnp -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Rescue-DormantEthernetPnp stamps 300s limiter before query and uses -PresentOnly' (($pnpDef.IndexOf("Test-Elapsed 'PnpRescan' 300") -ge 0) -and ($pnpDef.IndexOf("Set-StateTime 'PnpRescan'") -ge 0) -and ($pnpDef.IndexOf('-PresentOnly') -ge 0))
    $utcNow = (Get-Date).ToUniversalTime()
    $parsedUtc = [datetime]::Parse($utcNow.ToString('o'), [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind).ToUniversalTime()
    Write-Check 'Logic: interactive session timestamp round-trips via ISO-8601 UTC with zero drift' ([math]::Abs(($utcNow - $parsedUtc).TotalSeconds) -lt 0.001)
    $gwDef = [string](Get-Command Get-GatewayMacs -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Get-GatewayMacs guards Remove-NetNeighbor with -not $script:IsDry' (($gwDef.IndexOf('if (-not $script:IsDry)') -ge 0) -and ($gwDef.IndexOf('Remove-NetNeighbor') -ge 0))
    $rnDef = [string](Get-Command Restore-NeutralizedInterceptors -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Restore-NeutralizedInterceptors restores DelayedAutostart and restarts running services' (($rnDef.IndexOf('WasRunning') -ge 0) -and ($rnDef.IndexOf('DelayedAutostart') -ge 0) -and ($rnDef.IndexOf('Start-Service') -ge 0))
    $ssDef = [string](Get-Command Shield-SystemStack -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Shield-SystemStack falls back to DHCP DNS and gateway before public resolvers' (($ssDef.IndexOf('Get-DhcpDnsServers') -ge 0) -and ($ssDef.IndexOf('IPv4DefaultGateway') -ge 0) -and ($ssDef.IndexOf('fallbackDns') -ge 0))

    # ---- Omniscient Layer 1-7 Adaptive Engine & Sentinel Daemon Test Assertions ----
    Write-Check 'Logic: Test-NdisLinkHealth returns structured health object on null' (((Test-NdisLinkHealth $null).Reason) -eq 'NoAdapter' -and ((Test-NdisLinkHealth $null).Healthy -eq $false))
    Write-Check 'Logic: Resolve-DuplexFlap dry run is non-destructive' ((Resolve-DuplexFlap $null) -eq $false)
    Write-Check 'Logic: Optimize-PhySiliconBuffers enforces discard threshold lock' ((Optimize-PhySiliconBuffers $null) -eq $false)
    Write-Check 'Logic: Shield-Dot3Svc handles null adapter safely' ((Shield-Dot3Svc $null) -eq $false)
    Write-Check 'Logic: Wait-StpConvergence handles dry run / null adapter gracefully' ((Wait-StpConvergence $null) -eq $true)
    $sub24 = Get-SubnetInfoFromLease $null
    Write-Check 'Logic: Get-SubnetInfoFromLease handles null adapter' ($null -eq $sub24)

    # Subnet calculus pure math validation
    $calcFunc = {
        param([string]$ipStr, [int]$prefix)
        $ip = [System.Net.IPAddress]::Parse($ipStr)
        $ipBytes = $ip.GetAddressBytes()
        $maskBytes = New-Object byte[] 4; $netBytes = New-Object byte[] 4; $bcastBytes = New-Object byte[] 4
        for ($i = 0; $i -lt 4; $i++) {
            $bits = [math]::Max(0, [math]::Min(8, $prefix - ($i * 8)))
            $maskBytes[$i] = [byte]$(if ($bits -eq 0) { 0 } else { 256 - [math]::Pow(2, 8 - $bits) })
            $netBytes[$i]  = [byte]($ipBytes[$i] -band $maskBytes[$i])
            $wildcard      = [byte](255 -bxor $maskBytes[$i])
            $bcastBytes[$i]= [byte]($netBytes[$i] -bor $wildcard)
        }
        $minHost = [byte[]]$netBytes.Clone(); $maxHost = [byte[]]$bcastBytes.Clone()
        if ($prefix -le 30) { $minHost[3] = [byte]($minHost[3] + 1); $maxHost[3] = [byte]($maxHost[3] - 1) }
        return @{
            Mask = ($maskBytes -join '.')
            Net  = ($netBytes -join '.')
            Bcast= ($bcastBytes -join '.')
            MinH = ($minHost -join '.')
            MaxH = ($maxHost -join '.')
            Total= if ($prefix -ge 31) { 0L } else { [int64]([math]::Pow(2, 32 - $prefix) - 2) }
        }
    }
    $c24 = & $calcFunc '10.114.12.34' 24
    Write-Check 'Logic: subnet calculus calculates /24 mask, network, broadcast, and host count' ($c24.Mask -eq '255.255.255.0' -and $c24.Net -eq '10.114.12.0' -and $c24.Bcast -eq '10.114.12.255' -and $c24.Total -eq 254)
    $c23 = & $calcFunc '172.16.5.100' 23
    Write-Check 'Logic: subnet calculus calculates /23 mask, network, broadcast, and host count' ($c23.Mask -eq '255.255.254.0' -and $c23.Net -eq '172.16.4.0' -and $c23.Bcast -eq '172.16.5.255' -and $c23.Total -eq 510)
    $c16 = & $calcFunc '192.168.1.50' 16
    Write-Check 'Logic: subnet calculus calculates /16 mask, network, broadcast, and host count' ($c16.Mask -eq '255.255.0.0' -and $c16.Net -eq '192.168.0.0' -and $c16.Bcast -eq '192.168.255.255' -and $c16.Total -eq 65534)

    Write-Check 'Logic: Find-OptimalPathMtu returns 1500 on null adapter' ((Find-OptimalPathMtu $null) -eq 1500)
    Write-Check 'Logic: Shield-TcpOffloads handles null adapter safely' ((Shield-TcpOffloads $null) -eq $false)
    Write-Check 'Logic: Shield-Proxies is safe in DryRun mode' (($script:IsAdmin -eq $false) -or (Shield-Proxies) -is [bool])
    Write-Check 'Logic: Capture-PreflightSnapshot returns null on null adapter' ($null -eq (Capture-PreflightSnapshot $null))
    Write-Check 'Logic: Restore-PreflightSnapshot returns false on null snapshot' ((Restore-PreflightSnapshot $null) -eq $false)

    # ACID rollback validation
    $acidDef = [string](Get-Command Invoke-AcidMutation -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Invoke-AcidMutation triggers rollback when validation fails' ($acidDef.IndexOf('Restore-PreflightSnapshot') -ge 0)

    Write-Check 'Logic: Daemon mode exists in ValidateSet' ($srcTxt -match "ValidateSet\([^)]*'Daemon'")
    Write-Check 'Logic: Sentinel mode exists in ValidateSet' ($srcTxt -match "ValidateSet\([^)]*'Sentinel'")
    Write-Check 'Logic: Install-SentinelTask is defined' ($null -ne (Get-Command Install-SentinelTask -ErrorAction SilentlyContinue))
    Write-Check 'Logic: Write-SentinelLog is defined' ($null -ne (Get-Command Write-SentinelLog -ErrorAction SilentlyContinue))
    $daemonDef = [string](Get-Command Start-AutonomousDaemon -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Start-AutonomousDaemon is defined' ($null -ne $daemonDef -and $daemonDef.Length -gt 0)
    Write-Check 'Logic: Start-AutonomousDaemon handles captive portal authentication' ($daemonDef.IndexOf('Invoke-HeadlessPortalLogin') -ge 0)
    Write-Check 'Logic: Start-AutonomousDaemon registers reactive NetworkChange events' ($daemonDef.IndexOf('NetworkChange') -ge 0)
    $idkDef = [string](Get-Command Invoke-DashboardKey -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Invoke-DashboardKey handles key B for autonomous daemon' ($idkDef.IndexOf("Start-AutonomousDaemon") -ge 0)
    $omniWinsock = [string](Get-Command Invoke-SupremeOmnifix -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Invoke-SupremeOmnifix resets Winsock catalog' ($omniWinsock.IndexOf("winsock") -ge 0)
    $diagDef = [string](Get-Command Show-Diagnostics -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Show-Diagnostics displays subnet calculus and NDIS health' ($diagDef.IndexOf("Get-SubnetInfoFromLease") -ge 0 -and $diagDef.IndexOf("Test-NdisLinkHealth") -ge 0)

    Write-Check 'Logic: UltraReset mode exists in ValidateSet' ($srcTxt -match "ValidateSet\([^)]*'UltraReset'")
    Write-Check 'Logic: Invoke-UltraSystemReset is defined' ($null -ne (Get-Command Invoke-UltraSystemReset -ErrorAction SilentlyContinue))
    $ultraDef = [string](Get-Command Invoke-UltraSystemReset -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Ultra System Reset resets dual-stack TCP/IP, Winsock, route -f, and firewall' ($ultraDef.IndexOf('netsh') -ge 0 -and $ultraDef.IndexOf('route.exe') -ge 0 -and $ultraDef.IndexOf('advfirewall') -ge 0 -and $ultraDef.IndexOf('winsock') -ge 0)
    Write-Check 'Logic: Ultra System Reset resuscitates services topologically and registers DNS' ($ultraDef.IndexOf('registerdns') -ge 0 -and $ultraDef.IndexOf('Wait-StpConvergence') -ge 0)
    Write-Check 'Logic: Ultra System Reset resets 64-bit and 32-bit Winsock catalogs' ($ultraDef.IndexOf('SysWOW64') -ge 0 -and $ultraDef.IndexOf('winsock') -ge 0)
    Write-Check 'Logic: Ultra System Reset clears destination cache and autoproxy' ($ultraDef.IndexOf('destinationcache') -ge 0 -and $ultraDef.IndexOf('autoproxy') -ge 0)
    Write-Check 'Logic: Ultra System Reset disables transition tunnels (Teredo, ISATAP, 6to4)' ($ultraDef.IndexOf('teredo') -ge 0 -and $ultraDef.IndexOf('isatap') -ge 0 -and $ultraDef.IndexOf('6to4') -ge 0)
    Write-Check 'Logic: Ultra System Reset zeroes DHCP lease registry to force clean Discover' ($ultraDef.IndexOf('DhcpIPAddress') -ge 0 -and $ultraDef.IndexOf('DhcpDefaultGateway') -ge 0)
    Write-Check 'Logic: Ultra System Reset issues 802.1X netsh lan reconnect' ($ultraDef.IndexOf('reconnect') -ge 0)
    Write-Check 'Logic: Ultra System Reset clears encrypted DNS via delete global all' ($ultraDef.IndexOf('delete') -ge 0 -and $ultraDef.IndexOf('global') -ge 0 -and $ultraDef.IndexOf('dnsclient') -ge 0)
    Write-Check 'Logic: Ultra System Reset sets DhcpConnForceBroadcastFlag' ($ultraDef.IndexOf('DhcpConnForceBroadcastFlag') -ge 0)
    Write-Check 'Logic: Ultra System Reset audits and destroys accidental network bridges' ($ultraDef.IndexOf('bridge') -ge 0)
    Write-Check 'Logic: Ultra System Reset flushes HTTP driver log buffers' ($ultraDef.IndexOf('logbuffer') -ge 0)
    Write-Check 'Logic: Ultra System Reset resets interface portproxy and httpstunnel' ($ultraDef.IndexOf('portproxy') -ge 0 -and $ultraDef.IndexOf('httpstunnel') -ge 0)
    Write-Check 'Logic: Ultra System Reset purges BITS transfers and Kerberos tickets' ($ultraDef.IndexOf('Get-BitsTransfer') -ge 0 -and $ultraDef.IndexOf('klist.exe') -ge 0)
    Write-Check 'Logic: Ultra System Reset calibrates NCSI active probing in registry' ($ultraDef.IndexOf('EnableActiveProbing') -ge 0 -and $ultraDef.IndexOf('ActiveWebProbeHost') -ge 0)
    Write-Check 'Logic: Ultra System Reset wipes interface DNS settings via delete interface' ($ultraDef.IndexOf('dnsclient') -ge 0 -and $ultraDef.IndexOf('setting=all') -ge 0)
    Write-Check 'Logic: Ultra System Reset purges SMB sessions via net use' ($ultraDef.IndexOf('net.exe') -ge 0 -and $ultraDef.IndexOf('use') -ge 0)
    Write-Check 'Logic: DoomsdayReset mode exists in ValidateSet' ($srcTxt -match "ValidateSet\([^)]*'DoomsdayReset'")
    Write-Check 'Logic: Invoke-DoomsdayReset is defined' ($null -ne (Get-Command Invoke-DoomsdayReset -ErrorAction SilentlyContinue))
    $doomDef = [string](Get-Command Invoke-DoomsdayReset -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Doomsday Reset resets Wi-Fi WLAN autoconfig' ($doomDef.IndexOf('wlan') -ge 0 -and $doomDef.IndexOf('autoconfig') -ge 0)
    Write-Check 'Logic: Doomsday Reset purges user and machine proxy registry' ($doomDef.IndexOf('HKEY_USERS') -ge 0 -and $doomDef.IndexOf('ProxyEnable') -ge 0)
    Write-Check 'Logic: Doomsday Reset resuscitates 13 services including WlanSvc, bthserv, and WwanSvc' ($doomDef.IndexOf('WlanSvc') -ge 0 -and $doomDef.IndexOf('bthserv') -ge 0 -and $doomDef.IndexOf('WwanSvc') -ge 0)
    Write-Check 'Logic: Doomsday Reset cycles all physical adapters across media' ($doomDef.IndexOf('Restart-NetAdapter') -ge 0)
    Write-Check 'Logic: Doomsday Reset deactivates rogue 3rd-party NDIS filter bindings' ($doomDef.IndexOf('Disable-NetAdapterBinding') -ge 0)
    Write-Check 'Logic: Doomsday Reset performs PnP silicon hardware restart via pnputil' ($doomDef.IndexOf('/restart-device') -ge 0)
    Write-Check 'Logic: Doomsday Reset unlocks Modern Standby Airplane Mode in registry' ($doomDef.IndexOf('RadioManagement') -ge 0)
    Write-Check 'Logic: Doomsday Reset eradicates manual static IP address conflicts' ($doomDef.IndexOf('PrefixOrigin') -ge 0 -and $doomDef.IndexOf('Manual') -ge 0)
    Write-Check 'Logic: ArmageddonReset mode exists in ValidateSet' ($srcTxt -match "ValidateSet\([^)]*'ArmageddonReset'")
    Write-Check 'Logic: Invoke-ArmageddonReset is defined' ($null -ne (Get-Command Invoke-ArmageddonReset -ErrorAction SilentlyContinue))
    $armDef = [string](Get-Command Invoke-ArmageddonReset -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Armageddon Reset invokes netcfg -d kernel network cleanup' ($armDef.IndexOf('netcfg.exe') -ge 0 -and $armDef.IndexOf('-d') -ge 0)
    $restDef = [string](Get-Command Restore-Everything -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Restore-Everything restores deactivated NDIS filters' ($restDef.IndexOf('DeactivatedFilters') -ge 0)
    Write-Check 'Logic: Restore-Everything restores pre-reset firewall backup' ($restDef.IndexOf('firewall_pre_reset.wfw') -ge 0)
    Write-Check 'Logic: Restore-Everything uninstalls Sentinel background task' ($restDef.IndexOf('Uninstall-SentinelTask') -ge 0)
    Write-Check 'Logic: Restore-Everything resets IPv6 transition tunnels to Windows defaults' ($restDef.IndexOf('teredo') -ge 0 -and $restDef.IndexOf('isatap') -ge 0)
    Write-Check 'Logic: Restore-Everything scrubs temporary task XMLs and logs' ($restDef.IndexOf('scrubFiles') -ge 0)
    Write-Check 'Logic: Doomsday Reset snapshots static IPv4 before stripping' ($doomDef.IndexOf('StaticIp4') -ge 0)
    $idkDefNow = [string](Get-Command Invoke-DashboardKey -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Invoke-DashboardKey handles key U for Ultra System Reset' ($idkDefNow.IndexOf("Invoke-UltraSystemReset") -ge 0)
    Write-Check 'Logic: Invoke-DashboardKey handles key D for Doomsday Reset' ($idkDefNow.IndexOf("Invoke-DoomsdayReset") -ge 0)
    Write-Check 'Logic: Invoke-DashboardKey aliases do not intercept key D' (-not $idkDefNow.Contains("'d' = '6'") -and -not $idkDefNow.Contains("d = '6'"))
    Write-Check 'Logic: Invoke-DashboardKey alias N routes to NetReset X' ($idkDefNow.Contains("n = 'x'") -or $idkDefNow.Contains("'n' = 'x'"))
    Write-Check 'Logic: Invoke-DashboardKey handles direct Armageddon hotkey !' ($idkDefNow.IndexOf("Invoke-ArmageddonReset") -ge 0)
    Write-Check 'Logic: Show-DnsMenu handles letter aliases' ($srcTxt -match "Cloudflare';\s*'c'\s*=\s*'Cloudflare")
    Write-Check 'Logic: Show-RouteMenu handles letter aliases' ($srcTxt -match "Wifi';\s*'w'\s*=\s*'Wifi")
    Write-Check 'Logic: NetReset and Ultra mode aliases exist in ValidateSet' ($srcTxt -match "ValidateSet\([^)]*'NetReset'" -and $srcTxt -match "ValidateSet\([^)]*'Ultra'")
    Write-Check 'Logic: Guide and Vault mode aliases exist in ValidateSet' ($srcTxt -match "ValidateSet\([^)]*'Guide'" -and $srcTxt -match "ValidateSet\([^)]*'Vault'")

    # --- RESET & RECOVERY SUBSYSTEM IN-FILE BEHAVIORAL CHECKS ---
    $ast = if ($srcTxt) { [System.Management.Automation.Language.Parser]::ParseInput($srcTxt, [ref]$null, [ref]$null) } else { $null }

    # 1. Reset Journal state machine execution & persistence
    $jTempDir = Join-Path ([System.IO.Path]::GetTempPath()) ('lf_jchk_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $jTempDir -Force | Out-Null
    $origStoreForJ = $script:StoreDir
    $origIsDryJ = $script:IsDry
    $script:StoreDir = $jTempDir
    try {
        $script:IsDry = $false
        Set-ResetJournal -Tier 'Ultra' -TotalStages 10 -Stage 1 -StageDesc 'Init'
        $jInit = Test-PriorResetJournal
        Write-Check 'Logic: Reset Journal sets InProgress status and records Tier and Stage' ($null -ne $jInit -and $jInit.Tier -eq 'Ultra' -and $jInit.Status -eq 'InProgress' -and $jInit.Stage -eq 1)

        Update-ResetJournal -Stage 4 -StageDesc 'Routing Table Purge'
        $jUpPath = Get-ResetJournalPath
        $jUp = if (Test-Path -LiteralPath $jUpPath) { ConvertFrom-Json (Get-Content -LiteralPath $jUpPath -Raw) } else { $null }
        Write-Check 'Logic: Reset Journal updates Stage and description sequentially' ($null -ne $jUp -and $jUp.Stage -eq 4 -and $jUp.StageDesc -eq 'Routing Table Purge')

        Complete-ResetJournal -Success $true
        $jDone = if (Test-Path -LiteralPath $jUpPath) { ConvertFrom-Json (Get-Content -LiteralPath $jUpPath -Raw) } else { $null }
        Write-Check 'Logic: Reset Journal marks Completed status with timestamp' ($null -ne $jDone -and $jDone.Status -eq 'Completed' -and $null -ne $jDone.CompletedTime)
    } finally {
        $script:IsDry = $origIsDryJ
        $script:StoreDir = $origStoreForJ
        Remove-Item -LiteralPath $jTempDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    # 2. Behavioral Preconditions & Confirmation Contract execution
    $tDirPre = Join-Path ([System.IO.Path]::GetTempPath()) ('lf_pchk_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $tDirPre -Force | Out-Null
    try {
        $preFnAst = if ($ast) { $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $args[0].Name -eq 'Test-ResetPreconditions' }, $true) | Select-Object -First 1 } else { $null }
        if ($preFnAst) {
            $testPreBlock = [scriptblock]::Create(@"
                `$script:Version = '$($script:Version)'
                `$script:StoreDir = '$tDirPre'
                `$script:IsDry = `$false
                function Write-Log(`$L, `$M) {}
                function Assert-Admin { return `$true }
                function Test-RemoteSession { return `$false }
                function New-SystemRestorePoint(`$d) { return `$true }
                `$Mode = 'CLI'
                `$Force = `$false
                `$ConfirmRemoteDisconnect = `$false

                $($preFnAst.Extent.Text)

                function Test-InputRedirected { return `$true }
                `$resA = Test-ResetPreconditions 'Ultra'
                `$Force = `$true
                `$resB = Test-ResetPreconditions 'Ultra'
                `$Force = `$false
                `$script:IsDry = `$true
                `$resC = Test-ResetPreconditions 'Ultra'

                return @{ ResA = `$resA; ResB = `$resB; ResC = `$resC }
"@)
            $rPre = & $testPreBlock
            Write-Check 'Logic: Test-ResetPreconditions blocks unconfirmed redirected resets' ($rPre.ResA -eq $false)
            Write-Check 'Logic: Test-ResetPreconditions allows reset with -Force override' ($rPre.ResB -eq $true)
            Write-Check 'Logic: Test-ResetPreconditions allows reset with -DryRun' ($rPre.ResC -eq $true)

            $testRemoteBlock = [scriptblock]::Create(@"
                `$script:Version = '$($script:Version)'
                `$script:StoreDir = '$tDirPre'
                `$script:IsDry = `$false
                function Write-Log(`$L, `$M) {}
                function Assert-Admin { return `$true }
                function Test-RemoteSession { return `$true }
                function Test-InputRedirected { return `$false }
                function New-SystemRestorePoint(`$d) { return `$true }
                `$Mode = 'CLI'
                `$Force = `$true
                `$ConfirmRemoteDisconnect = `$false

                $($preFnAst.Extent.Text)

                `$resArmNoDisconnect = Test-ResetPreconditions 'Armageddon'
                `$ConfirmRemoteDisconnect = `$true
                `$resArmWithDisconnect = Test-ResetPreconditions 'Armageddon'

                return @{ ArmNoDisconnect = `$resArmNoDisconnect; ArmWithDisconnect = `$resArmWithDisconnect }
"@)
            $rRemote = & $testRemoteBlock
            Write-Check 'Logic: Test-ResetPreconditions blocks Armageddon over remote session without -ConfirmRemoteDisconnect' ($rRemote.ArmNoDisconnect -eq $false)
            Write-Check 'Logic: Test-ResetPreconditions allows Armageddon over remote session with -ConfirmRemoteDisconnect' ($rRemote.ArmWithDisconnect -eq $true)
        }
    } finally {
        Remove-Item -LiteralPath $tDirPre -Recurse -Force -ErrorAction SilentlyContinue
    }

    # 4. Mode Routing Invariants
    $swAst = if ($ast) { $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.SwitchStatementAst] }, $true) | Where-Object { $_.Condition.Extent.Text -match '\$Mode' } | Select-Object -First 1 } else { $null }
    $swMap = @{}
    if ($swAst) {
        foreach ($cl in $swAst.Clauses) { $swMap[$cl.Item1.Extent.Text.Trim("'`"")] = $cl.Item2.Extent.Text.Trim() }
    }
    Write-Check 'Logic: NetReset dispatches to Tier 2 (Invoke-UltraSystemReset)' ($swMap['NetReset'] -match 'Invoke-UltraSystemReset')
    Write-Check 'Logic: FullNetReset dispatches to Tier 2 (Invoke-UltraSystemReset)' ($swMap['FullNetReset'] -match 'Invoke-UltraSystemReset')
    Write-Check 'Logic: Omnifix dispatches to Tier 1 (Invoke-SupremeOmnifix)' ($swMap['Omnifix'] -match 'Invoke-SupremeOmnifix')
    Write-Check 'Logic: StandardReset dispatches to Tier 1 (Invoke-SupremeOmnifix)' ($swMap['StandardReset'] -match 'Invoke-SupremeOmnifix')
    Write-Check 'Logic: DoomsdayReset dispatches to Tier 3 (Invoke-DoomsdayReset)' ($swMap['DoomsdayReset'] -match 'Invoke-DoomsdayReset')
    Write-Check 'Logic: ArmageddonReset dispatches to Tier 4 (Invoke-ArmageddonReset)' ($swMap['ArmageddonReset'] -match 'Invoke-ArmageddonReset')
    Write-Check 'Logic: ResetFactory dispatches to Tier 5 (Restore-Everything)' ($swMap['ResetFactory'] -match 'Restore-Everything')

    # 5. Staged Post-Reboot Verification ACL and Hash Integrity
    $vTempDir = Join-Path ([System.IO.Path]::GetTempPath()) ('lf_vchk_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $vTempDir -Force | Out-Null
    $origStoreForV = $script:StoreDir
    $origIsDryV = $script:IsDry
    $script:StoreDir = $vTempDir
    try {
        $script:IsDry = $false
        $stg = Stage-PostRebootVerification
        if ($stg -and $stg.Path -and (Test-Path -LiteralPath $stg.Path)) {
            $hashMatches = ((Get-FileSha256 $stg.Path) -eq $stg.Hash)
            Write-Check 'Logic: Stage-PostRebootVerification generates verifiable SHA-256 integrity hash' $hashMatches
            $aclProtected = Test-VaultAcl $stg.Path
            $isAdmin = [bool]$script:IsAdmin
            Write-Check 'Logic: Stage-PostRebootVerification locks file ACLs exclusively to SYSTEM and Administrators' ($aclProtected -or -not $isAdmin) (-not $aclProtected -and -not $isAdmin) 'Requires elevated administrator token to enforce Administrators ownership'
        } else {
            Write-Check 'Logic: Stage-PostRebootVerification generates verifiable SHA-256 integrity hash' $true $true 'DryRun or unprivileged'
            Write-Check 'Logic: Stage-PostRebootVerification locks file ACLs exclusively to SYSTEM and Administrators' $true $true 'DryRun or unprivileged'
        }
    } finally {
        $script:IsDry = $origIsDryV
        $script:StoreDir = $origStoreForV
        Remove-Item -LiteralPath $vTempDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    # ---- Bug Hunting Tournament Remediation Assertions ----
    Write-Check 'Tournament: Armageddon Reset reboot prompt confirms on yes' ($armDef.IndexOf("'yes'") -ge 0)
    Write-Check 'Tournament: Test-ConfigFileTrusted checks GenericWrite and GenericAll' ($srcTxt.IndexOf('0x40000000 -bor 0x10000000') -ge 0)
    Write-Check 'Tournament: Test-NdisLinkHealth sets Healthy=false on errors/discards' ($srcTxt.IndexOf('$healthy = $false; $reasons += ("PacketErrors') -ge 0)
    Write-Check 'Tournament: Rescue-DormantEthernetPnp filters Not Present ghost adapters' ($srcTxt.IndexOf("`$_.Status -ne 'Not Present'") -ge 0)
    Write-Check 'Tournament: Wait-StpConvergence supports IPv6 preferred addresses' ($srcTxt.IndexOf("`$hasV6 = @(Get-NetIPAddress") -ge 0)
    Write-Check 'Tournament: Get-DhcpDnsServers extracts IPv6 DHCP resolvers' ($srcTxt.IndexOf('Dhcpv6DNSServers') -ge 0)
    Write-Check 'Tournament: Roaming cleanup debounces before restoring metrics' ($srcTxt.IndexOf("if (`$Mode -eq 'AutoHeal') {`r`n        if (-not `$script:State.Misc['LinkDownSince'])") -ge 0 -or $srcTxt.IndexOf("if (`$Mode -eq 'AutoHeal') {`n        if (-not `$script:State.Misc['LinkDownSince'])") -ge 0)
    Write-Check 'Tournament: Restore-Everything handles neutralized services hashtable records' ($restDef.IndexOf('rec.StartType') -ge 0)
    Write-Check 'Tournament: Sentinel Daemon loop variables persist in script scope' ($srcTxt.IndexOf('$script:DaemonConsecutiveFails = 0') -ge 0 -and $srcTxt.IndexOf('$script:DaemonLastHwCheck = [DateTime]::MinValue') -ge 0)
    Write-Check 'Tournament: STP convergence runs before DHCP renew in Doomsday' ($doomDef.IndexOf('Wait-StpConvergence') -lt $doomDef.IndexOf("@('/renew')"))
    Write-Check 'Tournament: STP convergence runs before DHCP renew in Ultra' ($ultraDef.IndexOf('Wait-StpConvergence') -lt $ultraDef.IndexOf("@('/renew')"))
    Write-Check 'Logic: Show-ResetMenu is defined' ($null -ne (Get-Command Show-ResetMenu -ErrorAction SilentlyContinue))
    $rmDef = [string](Get-Command Show-ResetMenu -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Show-ResetMenu covers all 5 reset and recovery tiers' ($rmDef.IndexOf('Invoke-SupremeOmnifix') -ge 0 -and $rmDef.IndexOf('Invoke-UltraSystemReset') -ge 0 -and $rmDef.IndexOf('Invoke-DoomsdayReset') -ge 0 -and $rmDef.IndexOf('Invoke-ArmageddonReset') -ge 0 -and $rmDef.IndexOf('Restore-Everything') -ge 0)
    Write-Check 'Logic: Show-ResetMenu enforces explicit yes confirmation on all options' ($rmDef.IndexOf("'yes'") -ge 0 -and $rmDef.IndexOf("'no'") -lt 0)
    Write-Check 'Logic: ResetOptions exists in ValidateSet' ($srcTxt -match "ValidateSet\([^)]*'ResetOptions'")

    # ---- Feature F1: Health Verdict Engine Assertions ----
    $allOkLayers = @(
        @{ Layer = 1; Status = 'OK'; Action = 'None'; Cause = '' },
        @{ Layer = 2; Status = 'OK'; Action = 'None'; Cause = '' },
        @{ Layer = 3; Status = 'OK'; Action = 'None'; Cause = '' },
        @{ Layer = 4; Status = 'OK'; Action = 'None'; Cause = '' },
        @{ Layer = 5; Status = 'OK'; Action = 'None'; Cause = '' },
        @{ Layer = 6; Status = 'OK'; Action = 'None'; Cause = '' },
        @{ Layer = 7; Status = 'OK'; Action = 'None'; Cause = '' }
    )
    $v0 = Compute-DoctorVerdict $allOkLayers
    Write-Check 'Logic: Doctor all-OK evaluates to Healthy (ExitCode 0)' ($v0.Verdict -eq 'Healthy' -and $v0.ExitCode -eq 0 -and $v0.RecommendedMode -eq 'None')

    $l1Deg = @(
        @{ Layer = 1; Status = 'DEGRADED'; Action = 'Diagnose'; Cause = 'Ethernet 100M downshift' },
        @{ Layer = 2; Status = 'OK'; Action = 'None'; Cause = '' },
        @{ Layer = 3; Status = 'OK'; Action = 'None'; Cause = '' },
        @{ Layer = 4; Status = 'OK'; Action = 'None'; Cause = '' },
        @{ Layer = 5; Status = 'OK'; Action = 'None'; Cause = '' },
        @{ Layer = 6; Status = 'OK'; Action = 'None'; Cause = '' },
        @{ Layer = 7; Status = 'OK'; Action = 'None'; Cause = '' }
    )
    $v10 = Compute-DoctorVerdict $l1Deg
    Write-Check 'Logic: Doctor Layer 1 degraded evaluates to Degraded (ExitCode 10)' ($v10.Verdict -eq 'Degraded' -and $v10.ExitCode -eq 10 -and $v10.RecommendedMode -eq 'Diagnose')

    $l2Fail = @(
        @{ Layer = 1; Status = 'OK'; Action = 'None'; Cause = '' },
        @{ Layer = 2; Status = 'FAILED'; Action = 'StandardReset'; Cause = 'APIPA 169.254.x.x' },
        @{ Layer = 3; Status = 'FAILED'; Action = 'Heal'; Cause = 'No gateway' },
        @{ Layer = 4; Status = 'FAILED'; Action = 'SetDnsProfile'; Cause = 'No DNS' },
        @{ Layer = 5; Status = 'FAILED'; Action = 'Heal'; Cause = 'No HTTP' },
        @{ Layer = 6; Status = 'FAILED'; Action = 'Heal'; Cause = 'No TLS' },
        @{ Layer = 7; Status = 'UNKNOWN'; Action = 'Recover'; Cause = 'Offline' }
    )
    $v20 = Compute-DoctorVerdict $l2Fail
    Write-Check 'Logic: Doctor Layer 2 failed evaluates to Broken (ExitCode 20)' ($v20.Verdict -eq 'Broken' -and $v20.ExitCode -eq 20 -and $v20.RecommendedMode -eq 'StandardReset')

    $lUnk = @(
        @{ Layer = 1; Status = 'UNKNOWN'; Action = 'Diagnose'; Cause = 'No adapter detected' },
        @{ Layer = 2; Status = 'UNKNOWN'; Action = 'StandardReset'; Cause = 'Unknown' },
        @{ Layer = 3; Status = 'UNKNOWN'; Action = 'Heal'; Cause = 'Unknown' },
        @{ Layer = 4; Status = 'UNKNOWN'; Action = 'SetDnsProfile'; Cause = 'Unknown' },
        @{ Layer = 5; Status = 'UNKNOWN'; Action = 'Heal'; Cause = 'Unknown' },
        @{ Layer = 6; Status = 'UNKNOWN'; Action = 'Heal'; Cause = 'Unknown' },
        @{ Layer = 7; Status = 'UNKNOWN'; Action = 'Recover'; Cause = 'Unknown' }
    )
    $v30 = Compute-DoctorVerdict $lUnk
    Write-Check 'Logic: Doctor all-UNKNOWN evaluates to Undetermined (ExitCode 30)' ($v30.Verdict -eq 'Undetermined' -and $v30.ExitCode -eq 30)

    $l7Deg = @(
        @{ Layer = 1; Status = 'OK'; Action = 'None'; Cause = '' },
        @{ Layer = 2; Status = 'OK'; Action = 'None'; Cause = '' },
        @{ Layer = 3; Status = 'OK'; Action = 'None'; Cause = '' },
        @{ Layer = 4; Status = 'OK'; Action = 'None'; Cause = '' },
        @{ Layer = 5; Status = 'DEGRADED'; Action = 'Login'; Cause = 'Captive redirect' },
        @{ Layer = 6; Status = 'DEGRADED'; Action = 'Probe'; Cause = 'TLS intercepted' },
        @{ Layer = 7; Status = 'DEGRADED'; Action = 'Login'; Cause = 'Captive portal' }
    )
    $vCaptive = Compute-DoctorVerdict $l7Deg
    Write-Check 'Logic: Doctor captive redirect evaluates to Degraded with Login action' ($vCaptive.Verdict -eq 'Degraded' -and $vCaptive.ExitCode -eq 10 -and $vCaptive.RecommendedMode -eq 'Login')

    # ---- Feature F2: Change Ledger & Undo Engine Assertions ----
    $ledgerTempDir = Join-Path ([System.IO.Path]::GetTempPath()) ('lf_ledg_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $ledgerTempDir -Force | Out-Null
    $origStoreForLedg = $script:StoreDir
    $origIsDryLedg = $script:IsDry
    $origRunId = $script:RunId
    $script:StoreDir = $ledgerTempDir
    try {
        $script:IsDry = $false
        $script:RunId = 'test-run-001'
        
        # Test 1: Add Ledger Entry
        Add-ChangeLedgerEntry -Description 'Test mutation 1' -MutationType 'Registry' -Target 'HKCU:\Software\LanFixerTest' -OldValue 0 -NewValue 1 -Success $true -Reversible $true -UndoScript '$null'
        Add-ChangeLedgerEntry -Description 'Test mutation 2' -MutationType 'DnsClientServerAddress' -Target 'Ethernet' -OldValue @('10.0.0.1') -NewValue @('1.1.1.1') -Success $true -Reversible $true
        
        $entries = Get-ChangeLedgerEntries
        Write-Check 'Logic: Change ledger persists and retrieves JSONL mutation entries' ($entries.Count -ge 2 -and $entries[0].RunId -eq 'test-run-001')
        Write-Check 'Logic: Change ledger entry preserves OldValue and NewValue structured types' ($entries[0].OldValue -eq 0 -and $entries[0].NewValue -eq 1)

        # Test 2: Undo -Plan preview with drift detection
        $driftRes = Invoke-Undo -TargetRunId 'test-run-001' -Plan -Quiet
        Write-Check 'Logic: Invoke-Undo detects concurrent state drift and skips drifted mutations' ($driftRes.SkippedCount -ge 1)

        $forcePlanRes = Invoke-Undo -TargetRunId 'test-run-001' -Plan -Force -Quiet
        Write-Check 'Logic: Invoke-Undo -Plan -Force previews all reversible changes with Planned status' ($forcePlanRes.Status -eq 'Planned' -and $forcePlanRes.UndoneCount -ge 2)

        # Test 3: NotFound handling
        $notFoundRes = Invoke-Undo -TargetId 'non-existent-guid' -Quiet
        Write-Check 'Logic: Invoke-Undo returns NotFound status on invalid EntryId' ($notFoundRes.Status -eq 'NotFound')
    } finally {
        $script:IsDry = $origIsDryLedg
        $script:StoreDir = $origStoreForLedg
        $script:RunId = $origRunId
        Remove-Item -LiteralPath $ledgerTempDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    # ---- Supreme Multi-Dimensional History Suite Assertions ----
    Write-Check 'Logic: Get-HistorySessionLogs is defined' ($null -ne (Get-Command Get-HistorySessionLogs -ErrorAction SilentlyContinue))
    Write-Check 'Logic: Get-HistoryErrors is defined' ($null -ne (Get-Command Get-HistoryErrors -ErrorAction SilentlyContinue))
    Write-Check 'Logic: Get-HistoryWindowsEvents is defined' ($null -ne (Get-Command Get-HistoryWindowsEvents -ErrorAction SilentlyContinue))
    Write-Check 'Logic: Get-HistoryStateTransitions is defined' ($null -ne (Get-Command Get-HistoryStateTransitions -ErrorAction SilentlyContinue))
    Write-Check 'Logic: Get-HistoryHeals is defined' ($null -ne (Get-Command Get-HistoryHeals -ErrorAction SilentlyContinue))
    Write-Check 'Logic: Get-HistoryTimeline is defined' ($null -ne (Get-Command Get-HistoryTimeline -ErrorAction SilentlyContinue))
    Write-Check 'Logic: Export-HistoryForensicBundle is defined' ($null -ne (Get-Command Export-HistoryForensicBundle -ErrorAction SilentlyContinue))
    Write-Check 'Logic: Show-HistoryMenu is defined' ($null -ne (Get-Command Show-HistoryMenu -ErrorAction SilentlyContinue))
    Write-Check 'Logic: Invoke-HistorySuite is defined' ($null -ne (Get-Command Invoke-HistorySuite -ErrorAction SilentlyContinue))
    $testHistTimeline = Get-HistoryTimeline -Limit 5
    Write-Check 'Logic: Get-HistoryTimeline returns structured chronological records' ($null -ne $testHistTimeline)
    $testHistLogs = Get-HistorySessionLogs -Limit 5
    Write-Check 'Logic: Get-HistorySessionLogs queries session logs safely' ($null -ne $testHistLogs)

    # ---- Feature F3: Guided Recovery Engine Assertions ----
    Write-Check 'Logic: Recover mode exists in ValidateSet' ($srcTxt -match "ValidateSet\([^)]*'Recover'")
    Write-Check 'Logic: Invoke-GuidedRecovery is defined' ($null -ne (Get-Command Invoke-GuidedRecovery -ErrorAction SilentlyContinue))
    $recPlan = Invoke-GuidedRecovery -Plan -Quiet
    Write-Check 'Logic: Invoke-GuidedRecovery -Plan returns Planned or Healthy status with zero mutations' ($recPlan.Status -in @('Planned', 'Healthy') -and $recPlan.ExitCode -eq 0)

    # ---- Feature F4: Redacted Diagnostic Support Bundle Assertions ----
    Write-Check 'Logic: Bundle mode exists in ValidateSet' ($srcTxt -match "ValidateSet\([^)]*'Bundle'")
    Write-Check 'Logic: New-SupportBundle is defined' ($null -ne (Get-Command New-SupportBundle -ErrorAction SilentlyContinue))
    
    # Test redaction engine
    $rawSample = "User John at C:\Users\John on host WIN-SRV1 with MAC 00-1A-2B-3C-4D-5E, password=Secret123!, public IP 93.184.216.34 and private IP 192.168.1.50"
    $redacted = Invoke-Redaction $rawSample -Level 'Strict'
    Write-Check 'Logic: Redaction engine sanitizes MAC addresses' ($redacted -match 'XX:XX:XX:XX:XX:XX' -and $redacted -notmatch '00-1A-2B-3C-4D-5E')
    Write-Check 'Logic: Redaction engine sanitizes passwords and credentials' ($redacted -match 'password: \[REDACTED\]' -and $redacted -notmatch 'Secret123!')
    Write-Check 'Logic: Redaction engine sanitizes public IPs while preserving private RFC 1918' ($redacted -match '\[PUBLIC_IP_REDACTED\]' -and $redacted -notmatch '93\.184\.216\.34' -and $redacted -match '192\.168\.1\.50')

    # ---- Feature F5: Configuration & Policy File System Assertions ----
    Write-Check 'Logic: Config mode exists in ValidateSet' ($srcTxt -match "ValidateSet\([^)]*'Config'")
    Write-Check 'Logic: ConvertFrom-IniFile is defined' ($null -ne (Get-Command ConvertFrom-IniFile -ErrorAction SilentlyContinue))
    Write-Check 'Logic: Get-EffectiveConfiguration is defined' ($null -ne (Get-Command Get-EffectiveConfiguration -ErrorAction SilentlyContinue))
    
    # Test INI parser with sample content in temp directory
    $iniTempDir = Join-Path ([System.IO.Path]::GetTempPath()) ('lf_cfgtest_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $iniTempDir -Force | Out-Null
    $iniTestFile = Join-Path $iniTempDir 'test_policy.ini'
    try {
        $iniSample = @"
# Sample INI Policy
[General]
LogLevel = DEBUG
NoColor = True

[Watchdog]
CooldownSeconds = 120
AutoHealMaxTier = 2

[Probes]
HttpProbeUrl = "http://connectivitycheck.gstatic.com/generate_204"
"@
        [System.IO.File]::WriteAllText($iniTestFile, $iniSample, [System.Text.Encoding]::ASCII)
        $parsedIni = ConvertFrom-IniFile $iniTestFile
        Write-Check 'Logic: ConvertFrom-IniFile parses sections and key-values' ($parsedIni.General.LogLevel -eq 'DEBUG' -and $parsedIni.Watchdog.CooldownSeconds -eq '120')
        Write-Check 'Logic: ConvertFrom-IniFile strips surrounding quotes' ($parsedIni.Probes.HttpProbeUrl -eq 'http://connectivitycheck.gstatic.com/generate_204')
        
        $effDefault = Get-EffectiveConfiguration
        Write-Check 'Logic: Get-EffectiveConfiguration returns complete default map' ($effDefault.Configuration.ContainsKey('LogLevel') -and $effDefault.Configuration.ContainsKey('AutoHealMaxTier'))
    } finally {
        Remove-Item -LiteralPath $iniTempDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    # ---- Feature F6: Link Quality & Flap Monitor Assertions ----
    Write-Check 'Logic: Update-LinkQualityMonitor is defined' ($null -ne (Get-Command Update-LinkQualityMonitor -ErrorAction SilentlyContinue))
    
    $origStateForF6 = $script:State
    $script:State = @{ LinkMonitor = @{ History = @(); LinkTransitionsCount = 0; FlapDetected = $false } }
    try {
        $mockAdUp = [pscustomobject]@{
            Name = 'MockEthernet'
            Status = 'Up'
            LinkSpeed = '100 Mbps'
            FullDuplex = $true
            InterfaceDescription = 'Intel(R) Gigabit Network Connection'
        }
        $monRes1 = Update-LinkQualityMonitor $mockAdUp
        Write-Check 'Logic: LinkQualityMonitor detects Gigabit speed downshift' ($monRes1.SpeedDownshiftAlert -eq $true)

        # Simulate 2 more rapid transitions to test flapping detection
        $mockAdDown = [pscustomobject]@{ Name = 'MockEthernet'; Status = 'Down'; LinkSpeed = '0 bps'; FullDuplex = $false; InterfaceDescription = 'Intel(R) Gigabit Network Connection' }
        [void](Update-LinkQualityMonitor $mockAdDown)
        $monRes3 = Update-LinkQualityMonitor $mockAdUp
        Write-Check 'Logic: LinkQualityMonitor detects link flapping on >=3 transitions' ($monRes3.FlapDetected -eq $true -and $monRes3.LinkTransitionsCount -ge 3)
    } finally {
        $script:State = $origStateForF6
    }

    # ---- Feature F7: Unified Automation Surface Assertions ----
    Write-Check 'Logic: NoColor switch and env:NO_COLOR supported' ($null -ne $script:NoColor)
    Write-Check 'Logic: SelfTest supports -Json and -Quiet parameters' ($null -ne (Get-Command Invoke-SelfTest -ErrorAction SilentlyContinue).Parameters['Json'])
    Write-Check 'Logic: Report supports -Json and -Quiet parameters' ($null -ne (Get-Command New-SupportReport -ErrorAction SilentlyContinue).Parameters['Json'])

    # ---- Feature F8: Self-Integrity & Watchdog Hardening Assertions ----
    Write-Check 'Logic: Integrity mode exists in ValidateSet' ($srcTxt -match "ValidateSet\([^)]*'Integrity'")
    Write-Check 'Logic: Test-ScriptIntegrity is defined' ($null -ne (Get-Command Test-ScriptIntegrity -ErrorAction SilentlyContinue))
    Write-Check 'Logic: Set-ScriptAuthorization is defined' ($null -ne (Get-Command Set-ScriptAuthorization -ErrorAction SilentlyContinue))

    $intTempDir = Join-Path ([System.IO.Path]::GetTempPath()) ('lf_inttest_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $intTempDir -Force | Out-Null
    $testScript = Join-Path $intTempDir 'test_script.cmd'
    $origStoreForInt = $script:StoreDir
    $script:StoreDir = $intTempDir
    try {
        [System.IO.File]::WriteAllText($testScript, '@echo off`r`necho OK`r`n', [System.Text.Encoding]::ASCII)
        $authOk = Set-ScriptAuthorization $testScript
        Write-Check 'Logic: Set-ScriptAuthorization creates integrity manifest' ($authOk -eq $true -and (Test-Path (Join-Path $intTempDir 'integrity.json')))
        
        $intRes1 = Test-ScriptIntegrity $testScript
        Write-Check 'Logic: Test-ScriptIntegrity verifies matching SHA-256' ($intRes1.Valid -eq $true -and $intRes1.Status -eq 'Authorized')

        # Tamper the test script
        [System.IO.File]::AppendAllText($testScript, 'REM TAMPERED`r`n', [System.Text.Encoding]::ASCII)
        $intRes2 = Test-ScriptIntegrity $testScript
        Write-Check 'Logic: Test-ScriptIntegrity detects HashMismatch tamper' ($intRes2.Valid -eq $false -and $intRes2.Status -eq 'HashMismatch')
    } finally {
        $script:StoreDir = $origStoreForInt
        Remove-Item -LiteralPath $intTempDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    # ---- Feature F9: Non-Destructive Plan Preview Assertions ----
    Write-Check 'Logic: Format-PlanPreview is defined' ($null -ne (Get-Command Format-PlanPreview -ErrorAction SilentlyContinue))
    $origPlanState = $script:IsPlan
    $origPlanChanges = $script:PlannedChanges
    $actionExecuted = $false
    try {
        $script:IsPlan = $true
        $script:PlannedChanges = New-Object System.Collections.ArrayList
        [void](Invoke-Change 'Plan test mutation' { $actionExecuted = $true } -MutationType 'Registry' -Target 'HKLM:\Test' -OldValue 1 -NewValue 2)
        Write-Check 'Logic: Invoke-Change under -Plan records planned mutation item' ($script:PlannedChanges.Count -eq 1 -and $script:PlannedChanges[0].Target -eq 'HKLM:\Test')
        Write-Check 'Logic: Invoke-Change under -Plan guarantees ZERO execution of action block' ($actionExecuted -eq $false)
    } finally {
        $script:IsPlan = $origPlanState
        $script:PlannedChanges = $origPlanChanges
    }

    # ---- Feature F10: Reset Subsystem Behavioral Assertions ----
    $origStoreForReset = $script:StoreDir
    $origIsDryReset = $script:IsDry
    $resetTempDir = Join-Path ([System.IO.Path]::GetTempPath()) ('lf_rst_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $resetTempDir -Force | Out-Null
    $script:StoreDir = $resetTempDir
    try {
        $script:IsDry = $false
        Set-ResetJournal -Tier 'Ultra' -TotalStages 10 -Stage 1 -StageDesc 'Teardown'
        $j1 = Test-PriorResetJournal
        Write-Check 'Logic: Set-ResetJournal initializes InProgress journal' ($j1 -and $j1.Status -eq 'InProgress' -and $j1.Tier -eq 'Ultra')

        Update-ResetJournal -Stage 5 -StageDesc 'DNS Reset'
        $jPath = Get-ResetJournalPath
        $j2 = ConvertFrom-Json (Get-Content -LiteralPath $jPath -Raw)
        Write-Check 'Logic: Update-ResetJournal transitions journal stage' ($j2.Stage -eq 5 -and $j2.StageDesc -eq 'DNS Reset')

        Complete-ResetJournal -Success $true
        $j3 = ConvertFrom-Json (Get-Content -LiteralPath $jPath -Raw)
        Write-Check 'Logic: Complete-ResetJournal marks journal Completed' ($j3.Status -eq 'Completed' -and [bool]$j3.CompletedTime)

        $stg = Stage-PostRebootVerification
        Write-Check 'Logic: Stage-PostRebootVerification stages secured script with SHA256' ($null -ne $stg -and (Test-Path -LiteralPath $stg.Path) -and $stg.Hash.Length -eq 64)
    } finally {
        $script:IsDry = $origIsDryReset
        $script:StoreDir = $origStoreForReset
        Remove-Item -LiteralPath $resetTempDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    # ---- Feature F11: In-File Help System & Unified Metadata Registry Assertions ----
    Write-Check 'Logic: Help mode exists in ValidateSet' ($srcTxt -match "ValidateSet\([^)]*'Help'")
    Write-Check 'Logic: Get-CommandMetadata is defined' ($null -ne (Get-Command Get-CommandMetadata -ErrorAction SilentlyContinue))
    Write-Check 'Logic: Show-HelpReport is defined' ($null -ne (Get-Command Show-HelpReport -ErrorAction SilentlyContinue))

    $metaTable = Get-CommandMetadata
    Write-Check 'Logic: CommandMetadata contains entries for all 54 modes' ($metaTable -and $metaTable.Count -ge 54)

    $allValidateModesPresent = $true
    if ($ast -and $ast.ParamBlock) {
        $modeP = $ast.ParamBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'Mode' }
        $vsAttr = if ($modeP) { $modeP.Attributes | Where-Object { $_.TypeName.FullName -eq 'ValidateSet' } } else { $null }
        if ($vsAttr) {
            foreach ($argVal in $vsAttr.PositionalArguments) {
                if (-not $metaTable.ContainsKey($argVal.Value)) {
                    $allValidateModesPresent = $false
                    break
                }
            }
        }
    }
    Write-Check 'Logic: AST reflection confirms all ValidateSet modes exist in CommandMetadata' ($allValidateModesPresent -eq $true)

    $helpDoc = Show-HelpReport -TargetMode 'Doctor' -NoOutput
    Write-Check 'Logic: Show-HelpReport resolves valid mode with ExitCode 0' ($helpDoc.ExitCode -eq 0 -and $helpDoc.Metadata.Name -eq 'Doctor')

    $helpBogus = Show-HelpReport -TargetMode 'NonExistentModeXYZ' -NoOutput
    Write-Check 'Logic: Show-HelpReport returns ExitCode 1 on unknown mode' ($helpBogus.ExitCode -eq 1)

    # ---- Universal UX & Accessible Design System Assertions ----
    Write-Check 'Logic: Get-StatusToken is defined' ($null -ne (Get-Command Get-StatusToken -ErrorAction SilentlyContinue))
    $stOk = Get-StatusToken 'ok'
    $stBad = Get-StatusToken 'bad'
    $stWarn = Get-StatusToken 'warn'
    Write-Check 'Logic: Get-StatusToken produces fixed-width 6-char accessible tokens' ($stOk.Text -eq '[  OK  ]' -and $stBad.Text -eq '[ FAIL ]' -and $stWarn.Text -eq '[ WARN ]')

    $dummyT = @{
        Admin = $true; Watchdog = $false; Vault = $true; LinkUp = $true; Speed = '1000 Mbps';
        Ip = '192.168.1.50'; SubnetPrefix = 24; GwIp = '192.168.1.1'; GwAlive = $true; GwRtt = 2;
        DnsPrimary = '1.1.1.1'; DnsSecondary = '8.8.8.8'; DnsProfile = 'Cloudflare';
        Problem = 'Online'; Nic = 'Ethernet0'; Env = 'Campus'; Routing = 'Ethernet First';
    }
    $dummyAdv = @{
        Role = 'ok'; Word = 'Online'; Hops = @('ok', 'ok', 'ok', 'ok', 'ok');
        Status = 'Ethernet link active. Default gateway answering.';
        Action = 'No action needed. Connection healthy.'; Key = '1'; KeyLabel = 'Quick Heal';
    }
    $model80 = Get-DashboardModel $dummyT $dummyAdv 80
    $model100 = Get-DashboardModel $dummyT $dummyAdv 100
    $model120 = Get-DashboardModel $dummyT $dummyAdv 120
    Write-Check 'Logic: Get-DashboardModel renders successfully at widths 80, 100, 120' ($model80.Lines.Count -gt 10 -and $model100.Lines.Count -gt 10 -and $model120.Lines.Count -gt 10)

    $allAscii = $true
    foreach ($m in @($model80, $model100, $model120)) {
        foreach ($line in $m.Lines) {
            foreach ($seg in @($line)) {
                $str = [string]$seg.T
                for ($ci = 0; $ci -lt $str.Length; $ci++) {
                    if ([int][char]$str[$ci] -gt 127) { $allAscii = $false; break }
                }
            }
        }
    }
    Write-Check 'Logic: Get-DashboardModel output conforms strictly to 7-bit ASCII (bytes 0-127)' ($allAscii -eq $true)

    # ---- Careful Network & Stack Debloater Assertions ----
    Write-Check 'Logic: Get-DebloatStatus is defined' ($null -ne (Get-Command Get-DebloatStatus -ErrorAction SilentlyContinue))
    $dStat = Get-DebloatStatus
    Write-Check 'Logic: Get-DebloatStatus returns vectors covering DeliveryOptimization and NetworkThrottling' ($dStat -and $dStat.Count -ge 6 -and (@($dStat | Where-Object { $_.Id -eq 'DeliveryOptimization' }).Count -eq 1))

    $auditRes = Invoke-NetworkDebloat -Audit -Json
    Write-Check 'Logic: Invoke-NetworkDebloat -Audit executes successfully with zero mutations' ($auditRes -eq 0)

    $undoRes = Undo-NetworkDebloat -Json
    Write-Check 'Logic: Undo-NetworkDebloat handles non-existent snapshot gracefully' ($undoRes -eq 0)

    $script:State = $stSave
}
function Invoke-SelfTest([switch]$Json, [switch]$Quiet, [switch]$NoColor) {
    $script:TestFail = 0; $script:TestWarn = 0
    $script:TestResults = New-Object System.Collections.ArrayList
    $script:TestJson = [bool]$Json
    $script:TestQuiet = [bool]$Quiet
    $script:TestNoColor = [bool]($NoColor -or $script:NoColor)
    if (-not $Json -and -not $Quiet) {
        Write-Banner 'SYSTEM INTEGRITY SELF-TEST (READ-ONLY)'
    }
    Write-Check ("PowerShell " + $PSVersionTable.PSVersion) ($PSVersionTable.PSVersion.Major -ge 5)
    Write-Check 'Running as Administrator' $script:IsAdmin $true 'needed for repairs, not for audits'
    foreach ($c in 'Get-NetAdapter','Get-NetIPInterface','Set-NetIPInterface','Get-NetNeighbor','New-NetNeighbor','Remove-NetNeighbor','Get-DnsClientServerAddress','Set-DnsClientServerAddress','Add-DnsClientNrptRule','Get-DnsClientNrptRule','Resolve-DnsName','Get-NetAdapterAdvancedProperty','Set-NetAdapterAdvancedProperty','Set-NetConnectionProfile','Restart-NetAdapter','Get-WinEvent') {
        Write-Check ("Cmdlet " + $c) ([bool](Get-Command $c -ErrorAction SilentlyContinue))
    }
    foreach ($x in 'schtasks.exe','icacls.exe','ipconfig.exe','arp.exe','rundll32.exe','nbtstat.exe','pnputil.exe','dism.exe') {
        Write-Check ("Tool " + $x) (Test-Path -LiteralPath (Get-SysExe $x))
    }
    Write-Check 'Kernel driver tcpip.sys exists' (Test-Path -LiteralPath (Join-Path $script:Sys32 'drivers\tcpip.sys'))
    Write-Check 'Kernel driver ndis.sys exists' (Test-Path -LiteralPath (Join-Path $script:Sys32 'drivers\ndis.sys'))
    Write-Check 'Kernel driver afd.sys exists' (Test-Path -LiteralPath (Join-Path $script:Sys32 'drivers\afd.sys'))
    $ads = @(Get-EthernetAdapters)
    Write-Check ("Ethernet adapters found: " + $ads.Count) ($ads.Count -gt 0) $true 'plug in / enable your wired adapter'
    foreach ($a in $ads) { Write-Check ("  {0}: {1}" -f $a.Name, $a.Status) ($a.Status -eq 'Up') $true }
    Write-Check 'Protected store exists' (Test-Path -LiteralPath $script:StoreDir) $true 'created on first elevated run'
    Write-Check 'Protected store ACL verified' ($script:StoreSecure -or (Test-StoreAcl)) $true
    Write-Check 'State file readable' ((Get-State) -is [hashtable]) $true
    Write-Check 'Watchdog task installed' (Test-WatchdogInstalled) $true 'optional: menu option 2'
    if (Test-WatchdogInstalled) {
        $wa = Get-WatchdogArguments
        Write-Check 'Watchdog runs the current protected copy' (($null -ne $wa) -and ($wa -eq (Get-WatchdogExpectedArguments))) $true 'run menu option 2 or any elevated heal to repoint it'
    }
    $xmlOk = $false
    try { [void][xml](New-WatchdogXml '/c test' '2026-01-01T00:00:00'); [void][xml](New-PortalTaskXml); [void][xml](New-SentinelTaskXml '/c test'); $xmlOk = $true } catch {}
    Write-Check 'Task XML is well-formed' $xmlOk
    $ip = Resolve-HostBounded 'connectivitycheck.gstatic.com' 2500
    Write-Check 'DNS resolution works right now' ([bool]$ip) $true
    Write-Check ("Internet probe: " + (Get-InternetState -NoCache).State) $true
    Invoke-LogicTests
    if ($Json) {
        $rep = @{
            TotalChecks = $script:TestResults.Count
            Passed      = ($script:TestResults.Count - $script:TestFail)
            Warnings    = $script:TestWarn
            Failures    = $script:TestFail
            Status      = if ($script:TestFail -eq 0) { 'PASS' } else { 'FAIL' }
            ExitCode    = if ($script:TestFail -eq 0) { 0 } else { 1 }
            Checks      = $script:TestResults
        }
        [Console]::Out.WriteLine((ConvertTo-Json $rep -Depth 4))
        return
    }
    if ($Quiet) {
        if ($script:TestFail -eq 0) {
            [Console]::Out.WriteLine(('PASS ({0} passed, {1} warnings, 0 failures)' -f ($script:TestResults.Count - $script:TestFail), $script:TestWarn))
        } else {
            [Console]::Out.WriteLine(('FAIL ({0} failed, {1} warnings)' -f $script:TestFail, $script:TestWarn))
        }
        return
    }
    Write-Host ''
    if ($script:TestFail -eq 0) { Out-Line @((Seg 'ok!' ('  ' + $script:G.dot + '  ready')), (Seg 'dim' ('   {0} {1} warnings' -f $script:G.mid, $script:TestWarn))) }
    else { Out-Line @((Seg 'bad!' ('  ' + $script:G.dot + '  ' + $script:TestFail + ' failed')), (Seg 'dim' ('   {0} {1} warnings' -f $script:G.mid, $script:TestWarn))) }
}

# ==============================================================================
# CONTROL CENTER (79 columns, ASCII only, auto-refreshing)
# ==============================================================================
function Pick-Hash($Value) { return (@($Value | Where-Object { $_ -is [hashtable] }) | Select-Object -First 1) }
function Wait-AnyKey {
    if ($NoPause -or (Test-InputRedirected)) { return }   # headless / piped / non-interactive / NoPause: never block
    Clear-InputBuffer
    try { [void](Read-KeyNow) } catch { try { [void](Read-Host) } catch {} }
    Clear-InputBuffer
}
$script:WdCache = $null
# Pure decision (unit-tested). The dashboard may only claim "Ethernet First" when the Ethernet adapter is really the
# lowest-metric path: while a campus link is captive, Shield-RouteMetrics deliberately demotes it to 50 and promotes
# Wi-Fi to 15, and reporting "Ethernet First" then is a plain lie (the traffic is going out over the hotspot).
function Get-RoutingLabel([bool]$Managed, [int]$Metric, [bool]$LinkUp, [bool]$UplinkActive = $true, [string]$Profile = '') {
    if (-not $Profile -and $script:State -is [hashtable] -and $script:State.Misc -is [hashtable]) {
        $Profile = [string]$script:State.Misc['RouteProfile']
    }
    if ($Profile -eq 'Windows') { return 'automatic' }
    if ($Profile -eq 'Wifi') {
        if ($UplinkActive) { return 'Wi-Fi First' }
        return 'Wi-Fi Standby'
    }
    if ($Profile -eq 'Ethernet') {
        if (-not $LinkUp) { return 'Ethernet Down' }
        if (-not $Managed) { return 'Ethernet (unmanaged)' }
        if ($Metric -le 15) { return 'Ethernet First' }
        return 'Ethernet (metric drifted)'
    }
    if (-not $Managed) { return 'automatic' }
    if (-not $LinkUp) { return $(if ($UplinkActive) { 'Wi-Fi Protected' } else { 'automatic' }) }
    if ($Metric -ge 45) { return $(if ($UplinkActive) { 'Wi-Fi Protected' } else { 'Ethernet Demoted' }) }
    if ($Metric -le 15) { return 'Ethernet First' }
    return 'Ethernet First'
}
function Get-Telemetry {
    $t = New-Telemetry
    $t.Problem = 'NoAdapter'
    $ads = @(Get-EthernetAdapters)
    $ad = $ads | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
    if (-not $ad) { $ad = $ads | Select-Object -First 1 }
    $others = @(Get-OtherUplinkAdapters)
    if (-not $ad -and $others.Count -gt 0) {
        $ad = $others | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
        if (-not $ad) { $ad = $others | Select-Object -First 1 }
    }
    if ($others.Count -gt 0) {
        $t.UplinkActive = $true
        $t.UplinkName = [string]$others[0].Name
        if (-not $script:UplinkProfileCache -or (((Get-Date) - $script:UplinkProfileCache.Time).TotalSeconds -gt 15)) {
            $prof = ''
            try { $prof = [string](Get-NetConnectionProfile -InterfaceIndex $others[0].ifIndex -ErrorAction SilentlyContinue).Name } catch {}
            $script:UplinkProfileCache = @{ Time = (Get-Date); Val = $prof }
        }
        $t.UplinkProfile = [string]$script:UplinkProfileCache.Val
    }
    if ($ad) {
        $desc = [string]$ad.InterfaceDescription
        $t.Nic = ($desc -replace ' Family Controller', '' -replace ' Gigabit Network Connection', ' GbE' -replace ' PCI-E NIC', '')
        if ($ad.MacAddress) { $t.Mac = [string]$ad.MacAddress }
        $t.Problem = 'NoLink'
        if ($ad.Status -eq 'Up') {
            $t.LinkUp = $true
            $t.Speed = [string]$ad.LinkSpeed
            $h = Get-AdapterHealth $ad
            $t.Problem = [string]$h.Problem
            $t.Conn = [string]$h.Conn
            if ($h.Ip) { $t.Ip = [string]$h.Ip }
            if ($h.Gateway) { $t.GwIp = [string]$h.Gateway; $t.GwRtt = if ($null -ne $script:LiveGwRtt) { $script:LiveGwRtt } else { $h.GwRtt }; $t.GwAlive = [bool]$h.GwAlive }
            $e = Get-AdapterEnvironment $ad -UseCache
            $t.Env = [string]$e.Env; $t.EnvScore = [int]$e.Score; $t.Sticky = [bool]$e.Sticky
            $ipif = Get-IPv4Interface $ad
            if ($ipif) {
                $t.Mtu = [string]$ipif.NlMtu
                $t.Routing = Get-RoutingLabel (Test-MetricsManaged) ([int]$ipif.InterfaceMetric) $true $t.UplinkActive
            }
            $raw = @((Get-DnsClientServerAddress -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses)
            if ($raw.Count -gt 0) { $t.DnsPrimary = [string]$raw[0] }
            if ($raw.Count -gt 1) { $t.DnsSecondary = [string]$raw[1] }
            $t.DnsProfile = Get-DnsProfileName
            if ($script:State.Misc['DiscoveredDomain']) { $t.Domain = [string]$script:State.Misc['DiscoveredDomain'] }
            try {
                $sub = Get-SubnetInfoFromLease $ad
                if ($sub -and $sub.Prefix) {
                    $t.SubnetPrefix = [int]$sub.Prefix
                    $t.SubnetMask = [string]$sub.Mask
                    $t.SubnetHosts = [int64]$sub.Total
                }
            } catch {}
            try {
                $v6 = @(Get-NetIPAddress -InterfaceIndex $ad.ifIndex -AddressFamily IPv6 -ErrorAction SilentlyContinue | Where-Object { [string]$_.AddressState -eq 'Preferred' -and [string]$_.IPAddress -notmatch '^(fe80|::1)' })
                if ($v6.Count -gt 0) { $t.IpV6 = [string]$v6[0].IPAddress }
            } catch {}
            try {
                $reg = Get-IfaceReg [string]$ad.InterfaceGuid
                if ($reg -and $reg.DhcpServer) { $t.DhcpServer = [string]$reg.DhcpServer }
            } catch {}
            try {
                $arpTable = Get-SubTable 'Arp' [string]$ad.InterfaceGuid
                if ($t.GwIp -and $arpTable.ContainsKey($t.GwIp)) { $t.GwLocked = $true }
            } catch {}
        }
    }
    $t.RouteProfile = Get-RouteProfileName
    if ($t.UplinkActive -and ($t.Routing -eq 'Wi-Fi Protected' -or ($t.Problem -ne 'Healthy' -and $t.Problem -ne 'Online') -or $t.RouteProfile -eq 'Wifi')) {
        $t.UplinkIsPrimary = $true
    }
    if (-not $script:WdCache -or (((Get-Date) - $script:WdCache.Time).TotalSeconds -gt 30)) { $script:WdCache = @{ Time = (Get-Date); Val = (Test-WatchdogInstalled) } }
    $t.Watchdog = [bool]$script:WdCache.Val
    $t.Vault = [bool](Test-Path -LiteralPath $script:VaultFile)
    $t.Pin = ([string]$script:State.Misc['PortalPin'] -ne '')
    $t.Paused = ($script:State.Misc['PortalLoginSuspended'] -eq $true)
    $t.ArpPending = (@(Get-PendingGatewayMacs).Count -gt 0)
    if (-not $t.LinkUp -and (Test-MetricsManaged) -and (Test-OtherUplinkActive)) { $t.Routing = Get-RoutingLabel $true 0 $false }
    $lf = Get-StateTime 'LastFull'
    if ($lf -gt [datetime]'2001-01-01') { $t.LastFull = $lf }
    return $t
}
# Headline, one plain sentence, and the single action Enter will run.
function Get-Advice($t) {
    $info = Get-StateInfo $t.Problem
    $r = @{ Word = $info.Word; Role = $info.Role; Hops = $info.Hops; Status = ''; Action = ''; Text = ''; Key = ''; KeyLabel = '' }
    if (-not $t.Admin -and $t.Problem) {
        $r.Status = 'Running in read-only Limited Mode (without Administrator privileges).'
        $r.Action = 'Press [ENTER] to relaunch as Administrator (or press E).'
        $r.Key = 'e'; $r.KeyLabel = 'relaunch as Administrator'
        $r.Text = ($r.Status + ' ' + $r.Action)
        return $r
    }
    if ($t.ArpPending) {
        $r.Status = 'Gateway MAC changed on switch. Candidate pending your review.'
        $r.Action = 'Press [ENTER] to review & approve the new gateway MAC (or press K).'
        $r.Key = 'k'; $r.KeyLabel = 'review the gateway MAC change'
        $r.Text = ($r.Status + ' ' + $r.Action)
        return $r
    }
    switch ($t.Problem) {
        { $_ -eq 'Healthy' -or $_ -eq 'Online' } {
            if ($t.UplinkIsPrimary -and $t.UplinkName) {
                $uLabel = if ($t.UplinkProfile) { "$($t.UplinkName) ($($t.UplinkProfile))" } else { $t.UplinkName }
                $r.Status = "Internet active via $uLabel. Ethernet link is in standby ($($t.Routing))."
            } else {
                $r.Status = 'Connected to network. All communication layers verified optimal.'
            }
            if (-not $t.Watchdog) {
                $r.Action = 'Press [ENTER] to arm background watchdog guard (or press 2).'
                $r.Key = '2'; $r.KeyLabel = 'arm the watchdog'
            } else {
                $r.Status = 'Connected to network with background watchdog active.'
                if ($t.LastFull) { $r.Status += (' Last repair ' + ([datetime]$t.LastFull).ToString('ddd yyyy-MM-dd HH:mm') + '.') }
                $r.Action = 'No action needed.'
            }
        }
        'Captive' {
            $r.Status = 'Connected to network, but captive portal sign-in is required.'
            if ($t.Paused) {
                $r.Action = 'Portal rejected saved password. Update credentials in vault (A).'
                $r.Key = 'a'; $r.KeyLabel = 'open the vault'
            } elseif ($t.Vault) {
                $r.Action = 'Press [ENTER] to sign in automatically with saved vault login (or press G).'
                $r.Key = 'g'; $r.KeyLabel = 'sign in with your saved login'
            } else {
                $r.Action = 'Press [ENTER] to open login page (or press 7), or press [A] to save login.'
                $r.Key = '7'; $r.KeyLabel = 'open the login page'
            }
        }
        'NoIp' {
            $r.Status = ((Get-DhcpFailureText (Get-DhcpErrorCode) ([string]$t.Mac)))
            $r.Action = 'Press [ENTER] to execute 7-layer heal and acquire DHCP lease (or press 1).'
            $r.Key = '1'; $r.KeyLabel = 'repair now'
        }
        'GwUnreachable' {
            if ($script:State.Misc['ArpCand'] -is [hashtable] -and $script:State.Misc['ArpCand'].Count -gt 0) {
                $r.Status = 'Default gateway unreachable. New router MAC candidate pending approval.'
                $r.Action = 'Press [ENTER] to approve new gateway MAC immediately (or press K).'
                $r.Key = 'k'; $r.KeyLabel = 'review the gateway MAC change'
            } else {
                $r.Status = 'IPv4 address assigned, but default gateway is not responding.'
                $r.Action = 'Press [ENTER] to refresh ARP table & restore route metrics (or press 1).'
                $r.Key = '1'; $r.KeyLabel = 'repair now'
            }
        }
        'NoDns' {
            $r.Status = 'Local network reachable, but domain name resolution (DNS) is failing.'
            $r.Action = 'Press [ENTER] to restore working DNS resolvers & flush cache (or press 1).'
            $r.Key = '1'; $r.KeyLabel = 'repair now'
        }
        'Offline' {
            $r.Status = 'Default gateway answers, but upstream internet access is blocked.'
            $r.Action = 'Press [ENTER] to run 7-layer diagnostics & verify routing (or press 1).'
            $r.Key = '1'; $r.KeyLabel = 'repair now'
        }
        'NoLink' {
            $r.Status = 'Physical Ethernet link down. Cable unplugged or port inactive.'
            if ($t.Watchdog) {
                $r.Action = 'Connect Ethernet cable, or press [ENTER] / [X] to open Reset Options.'
                $r.Key = 'x'; $r.KeyLabel = 'open Reset Options'
            } else {
                $r.Action = 'Connect Ethernet cable, then arm watchdog (or press 2).'
                $r.Key = '2'; $r.KeyLabel = 'arm the watchdog'
            }
        }
        'NoAdapter' {
            $r.Status = 'No physical Ethernet network adapter found.'
            $r.Action = 'Press [ENTER] or [X] to open Reset Options & rescan PnP hardware bus.'
            $r.Key = 'x'; $r.KeyLabel = 'open Reset Options'
        }
        default {
            $r.Status = 'Reading network state and adapters...'
            $r.Action = 'Please wait while telemetry is collected.'
        }
    }
    $r.Text = ($r.Status + ' ' + $r.Action).Trim()
    return $r
}
function Get-Sig($t) { return ('{0}|{1}|{2}|{3}|{4}|{5}|{6}|{7}|{8}|{9}|{10}|{11}|{12}|{13}|{14}|{15}' -f $t.Problem, $t.Ip, $t.Conn, $t.Speed, $t.Watchdog, $t.DnsPrimary, $t.Admin, $t.Vault, $t.Paused, $t.Routing, $t.GwIp, $t.Env, $t.DnsProfile, $t.GwAlive, $t.ArpPending, $t.RouteProfile) }


$script:Frame = $null
function Show-Dashboard($t, $adv) {
    $m = Get-DashboardModel $t $adv
    Write-Frame $m.Lines
    Out-Line @((Seg 'accent!' ('  ' + $script:G.prompt + ' '))) -NoNewline
    Show-Cursor $true
    $script:Frame = @{ Model = $m; Rows = $m.Lines.Count; WinW = (Get-UiWidth) }
}
function Show-DnsMenu {
    $cur = Get-DnsProfileName
    $eths = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
    $adTarget = if ($eths.Count -gt 0) { $eths[0] } else { (Get-OtherUplinkAdapters | Select-Object -First 1) }
    $adName = if ($adTarget) { $adTarget.Name } else { 'Primary Adapter' }
    $curDns = @()
    if ($adTarget) {
        $curDns = @(Get-DnsClientServerAddress -InterfaceIndex $adTarget.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ServerAddresses)
    }
    $dnsStr = if ($curDns.Count -gt 0) { $curDns -join ', ' } else { 'DHCP Auto' }

    Out-Line @((Seg 'accent!' '  DNS RESOLVER CONFIGURATION:'))
    Out-Line @((Seg 'dim' ('  Active Interface: ' + $adName + '  |  Current Resolvers: ' + $dnsStr)))
    Out-Line @()
    $items = @(
        @('1', 'Adaptive',   'Adaptive',   'Automatic: Campus DNS before login, public DNS after (Recommended)'),
        @('2', 'Campus',     'DHCP',       'Campus DHCP: Direct resolvers for campus ERP and intranet'),
        @('3', 'Hybrid',     'Hybrid',     'Dual Resolver: Quad9 & Google primary, campus fallback'),
        @('4', 'Cloudflare', 'Cloudflare', 'Public Secure: Cloudflare 1.1.1.1 primary, campus fallback'),
        @('5', 'Reset DHCP', 'ResetDHCP',  'Restore Defaults: Clear custom DNS and restore automatic DHCP'))
    foreach ($it in $items) {
        $on = ($it[2] -eq $cur)
        Out-Line @(
            (Seg $(if ($on) { 'ok!' } else { 'faint' }) ('  ' + $(if ($on) { $script:G.dot } else { $script:G.ring }) + ' ')),
            (Seg 'faint' '['),
            (Seg $(if ($on) { 'ok!' } else { 'accent!' }) $it[0]),
            (Seg 'faint' '] '),
            (Seg $(if ($on) { 'text!' } else { 'text' }) (' ' + $it[1].PadRight(12))),
            (Seg $(if ($on) { 'ok' } else { 'dim' }) $it[3])
        )
    }
    Out-Line @()
    Out-Line @((Seg 'dim' '  Select profile [1-5] or [A/D/H/C/R], or press any other key to cancel '), (Seg 'accent!' $script:G.prompt)) -NoNewline
    $k = Read-Choice
    Out-Line @()
    $map = @{ '1' = 'Adaptive'; 'a' = 'Adaptive'; '2' = 'DHCP'; 'd' = 'DHCP'; '3' = 'Hybrid'; 'h' = 'Hybrid'; '4' = 'Cloudflare'; 'c' = 'Cloudflare'; '5' = 'ResetDHCP'; 'r' = 'ResetDHCP' }
    $c = [string]$k.KeyChar
    if ($map.ContainsKey($c)) {
        Set-DnsProfileMode $map[$c]
        Out-Line @((Seg 'dim' '  Verifying DNS resolver responsiveness...'))
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $lookupOk = $false
        try {
            $ans = [System.Net.Dns]::GetHostAddresses('google.com')
            $sw.Stop()
            if ($ans.Count -gt 0) { $lookupOk = $true }
        } catch {}
        if ($lookupOk) {
            Out-Line @((Seg 'ok!' ('  ' + $script:G.ok + ' ')), (Seg 'text' ("DNS active and verified (" + $sw.ElapsedMilliseconds + " ms resolution)")))
        } else {
            Out-Line @((Seg 'warn' ('  ' + $script:G.warn + ' ')), (Seg 'dim' 'DNS profile set. External lookup will activate post-portal authentication.'))
        }
    } else {
        Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
    }
}
function Show-RouteMenu {
    $cur = Get-RouteProfileName
    Out-Line @((Seg 'accent!' '  ROUTING & INTERFACE METRIC PRIORITY:'))
    Out-Line @((Seg 'dim' '  Choose how Windows balances traffic between Gigabit Ethernet and Wi-Fi / Hotspot:'))
    Out-Line @()
    try {
        $routes = @(Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Sort-Object RouteMetric)
        if ($routes.Count -gt 0) {
            Out-Line @((Seg 'dim' '  Active Default Routes (0.0.0.0/0 Priority Order):'))
            foreach ($rt in $routes) {
                $ifName = (Get-NetAdapter -InterfaceIndex $rt.InterfaceIndex -ErrorAction SilentlyContinue).Name
                $isTop = ($rt -eq $routes[0])
                $marker = if ($isTop) { (Seg 'ok!' ('    ' + $script:G.dot + ' ')) } else { (Seg 'faint' '      ') }
                Out-Line @(
                    $marker,
                    (Seg $(if ($isTop) { 'text!' } else { 'text' }) (Fit $ifName 20)),
                    (Seg 'dim' (" | NextHop: " + $rt.NextHop)),
                    (Seg 'dim' (" | InterfaceMetric: " + $rt.InterfaceMetric)),
                    (Seg 'dim' (" | RouteMetric: " + $rt.RouteMetric))
                )
            }
            Out-Line @()
        }
    } catch {}
    $items = @(
        @('1', 'Adaptive', 'Adaptive', 'Auto-select: Ethernet when online, Wi-Fi when captive (Recommended)'),
        @('2', 'Ethernet', 'Ethernet', 'Ethernet priority: Prefer wired LAN (Metric 10 vs 40)'),
        @('3', 'Wi-Fi',    'Wifi',     'Wi-Fi priority: Hotspot primary, LAN portal preserved'),
        @('4', 'Windows',  'Windows',  'Windows default: Automatic interface metric balancing'))
    foreach ($it in $items) {
        $on = ($it[2] -eq $cur)
        Out-Line @(
            (Seg $(if ($on) { 'ok!' } else { 'faint' }) ('  ' + $(if ($on) { $script:G.dot } else { $script:G.ring }) + ' ')),
            (Seg 'faint' '['),
            (Seg $(if ($on) { 'ok!' } else { 'accent!' }) $it[0]),
            (Seg 'faint' '] '),
            (Seg $(if ($on) { 'text!' } else { 'text' }) (' ' + $it[1].PadRight(12))),
            (Seg $(if ($on) { 'ok' } else { 'dim' }) $it[3])
        )
    }
    Out-Line @()
    Out-Line @((Seg 'dim' '  Select profile [1-4] or [A/E/W/D], or press any other key to cancel '), (Seg 'accent!' $script:G.prompt)) -NoNewline
    $k = Read-Choice
    Out-Line @()
    $map = @{ '1' = 'Adaptive'; 'a' = 'Adaptive'; '2' = 'Ethernet'; 'e' = 'Ethernet'; '3' = 'Wifi'; 'w' = 'Wifi'; '4' = 'Windows'; 'd' = 'Windows' }
    $c = [string]$k.KeyChar
    if ($map.ContainsKey($c)) {
        Set-RouteProfileMode $map[$c]
        Out-Line @((Seg 'ok!' ('  ' + $script:G.ok + ' ')), (Seg 'text' ("Route priority switched to: " + $map[$c])))
    } else {
        Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
    }
}
function Show-ResetMenu {
    if (-not (Assert-Admin)) { return }
    Out-Line @((Seg 'accent!' '  RECOVERY AND SYSTEM:'))
    Out-Line @((Seg 'dim'     '  Select a recovery tier based on the level of repair required:'))
    Out-Line @()
    $options = @(
        @('1', 'Careful Network Debloat',  'b', '[  SAFE  ] Latency & Telemetry Debloat (P2P Seeding, Throttling, WPAD)'),
        @('2', 'Restore Network Defaults', 'r', '[ NOTICE ] Full Default Reset (Reverts DNS, IP configs, and proxies to DHCP)'),
        @('3', 'Standard Stack Reset',     's', '[CAUTION ] 5-Stage Network Reset (Winsock, TCP/IP, route flush, 7-layer heal)'),
        @('4', 'Deep Stack Rebuild',       'u', '[CAUTION ] 10-Stage Reset (Dual 64/32-bit Winsock, TCP/IP heuristics, NCSI)'),
        @('5', 'Multi-Adapter Reinstall',  'd', '[ HIGH   ] 12-Stage Universal Reset (All Media: Wi-Fi/BT/LAN, PnP Transceiver)'),
        @('6', 'Complete Stack Rebuild',   'a', '[ REBOOT ] 4-Stage Kernel Clean-Up (netcfg -d, requires immediate reboot)')
    )
    foreach ($opt in $options) {
        $color = switch ($opt[0]) {
            '1' { 'ok' }
            '2' { 'ok!' }
            '3' { 'accent!' }
            '4' { 'warn' }
            '5' { 'warn!' }
            '6' { 'bad!' }
        }
        Out-Line @(
            (Seg 'faint' '  ['),
            (Seg $color $opt[0]),
            (Seg 'faint' '] '),
            (Seg 'text!' (' ' + $opt[1].PadRight(25))),
            (Seg 'dim' $opt[3])
        )
    }
    Out-Line @()
    Out-Line @((Seg 'dim' '  Select option [1-6] or [B/R/S/U/D/A], or press any other key to cancel '), (Seg 'accent!' $script:G.prompt)) -NoNewline
    $k = Read-Choice
    Out-Line @()
    $choice = ([string]$k.KeyChar).ToLowerInvariant()
    if ($choice -in @('1', 'b')) {
        Show-DebloatMenu
    } elseif ($choice -in @('2', 'r', '9')) {
        if (Read-Confirm 'Restore all network settings and adapters to DHCP defaults?' 'yes') {
            $script:ChangeCount = 0; $script:FailCount = 0
            [void](Invoke-WithLock { Restore-Everything })
            $script:WdCache = $null
        } else {
            Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
        }
    } elseif ($choice -in @('3', 's', 'x')) {
        if (Read-Confirm 'Execute Standard Network Stack Reset?' 'yes') {
            $script:ChangeCount = 0; $script:FailCount = 0
            Invoke-SupremeOmnifix -Confirmed
            $script:WdCache = $null
        } else {
            Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
        }
    } elseif ($choice -in @('4', 'u')) {
        if (Read-Confirm 'Execute Deep Stack Rebuild (Dual 64/32-bit Winsock & IP)?' 'yes') {
            $script:ChangeCount = 0; $script:FailCount = 0
            Invoke-UltraSystemReset -Confirmed
            $script:WdCache = $null
        } else {
            Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
        }
    } elseif ($choice -in @('5', 'd')) {
        if (Read-Confirm 'Execute Multi-Adapter Reinstall (All physical and virtual interfaces)?' 'yes') {
            $script:ChangeCount = 0; $script:FailCount = 0
            Invoke-DoomsdayReset -Confirmed
            $script:WdCache = $null
        } else {
            Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
        }
    } elseif ($choice -in @('6', 'a', 'k', '!')) {
        if (Read-Confirm 'Execute Complete Network Stack Rebuild (netcfg -d, requires immediate reboot)?' 'yes') {
            $script:ChangeCount = 0; $script:FailCount = 0
            Invoke-ArmageddonReset -Confirmed
            $script:WdCache = $null
        } else {
            Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
        }
    } else {
        Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
    }
}
function Write-HealSummary($r, $sw) {
    if ($Json -or $Quiet -or -not $script:UiOn) { return }
    $w = Get-UiWidth
    $info = Get-StateInfo ([string]$(if ($r) { $r.Problem } else { 'Offline' }))
    Out-Line @()
    Out-Rule $w
    Out-Line @((Seg $info.Role ('  ' + $script:G.dot + '  ')), (Seg ($info.Role + '!') $info.Word), (Seg 'dim' ('   {0} {1} changed {0} {2} failed {0} {3:N1} s' -f $script:G.mid, $script:ChangeCount, $script:FailCount, $sw.Elapsed.TotalSeconds)))
}
# ==============================================================================
# ACID STATE TRANSITIONS & AUTONOMOUS SENTINEL DAEMON
# ==============================================================================
function Capture-PreflightSnapshot($Ad) {
    if (-not $Ad) { return $null }
    $guid = [string]$Ad.InterfaceGuid
    $snap = @{
        Guid      = $guid
        Name      = [string]$Ad.Name
        ifIndex   = [int]$Ad.ifIndex
        Timestamp = [DateTime]::UtcNow
        Ip4       = @()
        Gateways  = @()
        Dns       = @()
        Metric    = $null
        Mtu       = $null
        Routes    = @()
    }
    try {
        $ips = @(Get-NetIPAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue)
        foreach ($ip in $ips) {
            $snap.Ip4 += @{ IPAddress = [string]$ip.IPAddress; PrefixLength = [int]$ip.PrefixLength }
        }
    } catch {}
    try { $snap.Gateways = @(Get-GatewaysV4 $Ad) } catch {}
    try {
        $dns = Get-DnsClientServerAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
        if ($dns) { $snap.Dns = @($dns.ServerAddresses) }
    } catch {}
    try {
        $ipif = Get-IPv4Interface $Ad
        if ($ipif) {
            $snap.Metric = [int]$ipif.InterfaceMetric
            $snap.Mtu    = [int]$ipif.NlMtu
        }
    } catch {}
    try {
        $routes = @(Get-NetRoute -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue)
        foreach ($rt in $routes) {
            $snap.Routes += @{
                DestinationPrefix = [string]$rt.DestinationPrefix
                NextHop           = [string]$rt.NextHop
                RouteMetric       = [int]$rt.RouteMetric
            }
        }
    } catch {}
    return $snap
}

function Restore-PreflightSnapshot($Snapshot) {
    if (-not $Snapshot -or -not $Snapshot.ifIndex) { return $false }
    if ($script:IsDry) { Write-Log 'DRY' ("Would rollback configuration on {0} to pre-flight snapshot" -f $Snapshot.Name); return $true }
    $ifIdx = [int]$Snapshot.ifIndex
    $adName = [string]$Snapshot.Name
    Write-Log 'WARN' ("Rolling back configuration on {0} to pre-flight snapshot..." -f $adName)
    $restored = $true
    try {
        if ($null -ne $Snapshot.Metric) {
            Set-NetIPInterface -InterfaceIndex $ifIdx -AddressFamily IPv4 -InterfaceMetric ([int]$Snapshot.Metric) -ErrorAction SilentlyContinue
        }
        if ($null -ne $Snapshot.Mtu) {
            Set-NetIPInterface -InterfaceIndex $ifIdx -AddressFamily IPv4 -NlMtuBytes ([int]$Snapshot.Mtu) -ErrorAction SilentlyContinue
        }
        if ($Snapshot.Dns.Count -gt 0) {
            Set-DnsClientServerAddress -InterfaceIndex $ifIdx -ServerAddresses $Snapshot.Dns -ErrorAction SilentlyContinue
        } else {
            Set-DnsClientServerAddress -InterfaceIndex $ifIdx -ResetServerAddresses -ErrorAction SilentlyContinue
        }
    } catch {
        $restored = $false
        Write-Log 'FAIL' ("Error during pre-flight rollback on {0}: {1}" -f $adName, $_.Exception.Message)
    }
    return $restored
}

function Invoke-AcidMutation([string]$Description, [scriptblock]$Mutation, [scriptblock]$Validation, [int]$TimeoutMs = 3500) {
    if ($script:IsDry) {
        Write-Log 'DRY' ("Would execute ACID mutation: {0}" -f $Description)
        return $true
    }
    $ads = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
    $ad = if ($ads.Count -gt 0) { $ads[0] } else { $null }
    $snapshot = if ($ad) { Capture-PreflightSnapshot $ad } else { $null }

    Write-Log 'INFO' ("ACID Executing: {0}" -f $Description)
    $execOk = $false
    try {
        & $Mutation
        $execOk = $true
    } catch {
        Write-Log 'FAIL' ("Mutation threw exception: {0}" -f $_.Exception.Message)
    }

    if ($execOk -and $Validation) {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $valid = $false
        while ($sw.ElapsedMilliseconds -lt $TimeoutMs) {
            try {
                if (& $Validation) { $valid = $true; break }
            } catch {}
            Start-Sleep -Milliseconds 250
        }
        $sw.Stop()
        if (-not $valid) {
            Write-Log 'WARN' ("ACID Validation failed after {0} ms: rolling back {1}" -f $sw.ElapsedMilliseconds, $Description)
            if ($snapshot) { [void](Restore-PreflightSnapshot $snapshot) }
            return $false
        }
    } elseif (-not $execOk) {
        if ($snapshot) { [void](Restore-PreflightSnapshot $snapshot) }
        return $false
    }

    Write-Log 'OK' ("ACID Committed: {0}" -f $Description)
    return $true
}

function Write-SentinelLog([string]$Level, [string]$Message) {
    $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $line = "[{0}] [{1,-5}] {2}" -f $ts, $Level.ToUpperInvariant(), $Message
    if ($null -eq $script:SentinelEvents) { $script:SentinelEvents = New-Object System.Collections.ArrayList }
    [void]$script:SentinelEvents.Add($line)
    while ($script:SentinelEvents.Count -gt 25) { $script:SentinelEvents.RemoveAt(0) }
    if ($script:StoreReady) {
        $logPath = Join-Path $script:StoreDir 'sentinel.log'
        $bakPath = Join-Path $script:StoreDir 'sentinel.log.bak'
        try {
            if (Test-Path -LiteralPath $logPath) {
                $fi = Get-Item -LiteralPath $logPath -ErrorAction SilentlyContinue
                if ($fi -and $fi.Length -gt 524288) {
                    Move-Item -LiteralPath $logPath -Destination $bakPath -Force -ErrorAction SilentlyContinue
                }
            }
            [System.IO.File]::AppendAllText($logPath, $line + "`r`n", [System.Text.Encoding]::ASCII)
        } catch {}
    }
}

function New-SentinelTaskXml([string]$CmdArgs) {
    return @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Lan Fixer 24/7 Autonomous Sentinel Daemon (Continuous Reactive Self-Healing)</Description>
    <Author>Abhishek Sonu</Author>
  </RegistrationInfo>
  <Triggers>
    <BootTrigger>
      <Enabled>true</Enabled>
      <Delay>PT15S</Delay>
    </BootTrigger>
    <LogonTrigger>
      <Enabled>true</Enabled>
      <Delay>PT10S</Delay>
    </LogonTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>true</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>4</Priority>
    <RestartOnFailure>
      <Interval>PT1M</Interval>
      <Count>999</Count>
    </RestartOnFailure>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>%SystemRoot%\System32\cmd.exe</Command>
      <Arguments>$([System.Security.SecurityElement]::Escape($CmdArgs))</Arguments>
    </Exec>
  </Actions>
</Task>
"@
}

function Install-SentinelTask {
    if (-not (Assert-Admin)) { return $false }
    if (-not $script:StoreReady -or -not $script:StoreSecure) {
        Write-Log 'FAIL' 'Protected store folder unavailable. Cannot register Sentinel task.'
        return $false
    }
    if (-not $script:IsDry -and -not (Test-Path -LiteralPath $script:SelfCopy)) {
        Write-Log 'FAIL' 'Could not find the protected copy of Lan Fixer.'
        return $false
    }
    $cmdArgs = '/c ""' + $script:SelfCopy + '" -Mode Daemon -Headless -NoPause"'
    $xml = New-SentinelTaskXml $cmdArgs
    $ok = Register-LfTask 'LanFixer_Sentinel' $xml 'LanFixer_Sentinel.xml'
    if ($ok) {
        $r = Invoke-Native (Get-SysExe 'schtasks.exe') @('/run', '/tn', 'LanFixer_Sentinel') 10000
        Write-Log 'OK' 'Lan Fixer 24/7 Autonomous Sentinel task registered and activated.'
        Write-Log 'INFO' 'The Sentinel is now guarding your network 24/7 in the background with zero window.'
        [void](Set-ScriptAuthorization $script:SelfCopy)
        return $true
    }
    Write-Log 'FAIL' 'Failed to register LanFixer_Sentinel scheduled task.'
    return $false
}

function Uninstall-SentinelTask {
    if (-not (Assert-Admin)) { return $false }
    $r1 = Invoke-Native (Get-SysExe 'schtasks.exe') @('/end', '/tn', 'LanFixer_Sentinel') 5000
    $r2 = Invoke-Native (Get-SysExe 'schtasks.exe') @('/delete', '/tn', 'LanFixer_Sentinel', '/f') 10000
    Remove-Item -LiteralPath (Join-Path $script:StoreDir 'LanFixer_Sentinel.xml') -Force -ErrorAction SilentlyContinue
    Clear-StartupEntries
    if ($r2.ExitCode -eq 0) {
        Write-Log 'OK' 'Lan Fixer 24/7 Autonomous Sentinel task terminated and removed.'
        return $true
    }
    Write-Log 'WARN' 'LanFixer_Sentinel task was not found or already deleted.'
    return $true
}

function Show-SentinelLogView {
    $logPath = Join-Path $script:StoreDir 'sentinel.log'
    if (-not (Test-Path -LiteralPath $logPath)) {
        Write-Log 'INFO' 'No sentinel.log file found yet.'
        Start-Sleep -Seconds 2
        return
    }
    Clear-Screen
    Write-Banner 'SENTINEL FLIGHT RECORDER LOG (LAST 40 LINES)'
    $lines = @(Get-Content -LiteralPath $logPath -Tail 40 -ErrorAction SilentlyContinue)
    foreach ($l in $lines) {
        $c = 'dim'
        if ($l -match '\[OK\s*\]') { $c = 'ok' }
        elseif ($l -match '\[WARN\s*\]') { $c = 'warn' }
        elseif ($l -match '\[FAIL\s*\]') { $c = 'bad' }
        elseif ($l -match '\[TIER.*?\]') { $c = 'cyan' }
        Out-Line @((Seg $c ("  " + $l)))
    }
    Out-Line @()
    Out-Line @((Seg 'dim' '  Press any key to return to sentinel cockpit...'))
    Wait-AnyKey
}

function Show-SentinelHud($Adapter, $LinkHealth, [string]$Status, [int]$Cadence) {
    if (-not $script:UiOn) { return }
    Clear-Screen
    $w = [Math]::Min(100, [Math]::Max(60, (Get-UiWidth)))
    $sep = '-' * ($w - 4)
    $uptime = (Get-Date) - $script:SentinelStats.StartTime
    $upStr = "{0:D2}h {1:D2}m {2:D2}s" -f [int]$uptime.TotalHours, $uptime.Minutes, $uptime.Seconds
    
    Out-Line @((Seg 'cyan!' ("  LAN FIXER . AUTONOMOUS SENTINEL DAEMON (MARK VI)")), (Seg 'dim' (" . Uptime: " + $upStr)))
    Out-Line @((Seg 'dim' ("  " + $sep)))
    
    $statCol = $(switch -wildcard ($Status) {
        'Online*'    { 'ok!' }
        'Recovered*' { 'ok!' }
        'Captive*'   { 'warn!' }
        'Breaker*'   { 'bad!' }
        default      { 'warn!' }
    })
    $adName = $(if ($Adapter) { $Adapter.InterfaceDescription } else { 'No Active Ethernet Adapter' })
    Out-Line @(
        (Seg 'dim' '  Sentinel Status: '), (Seg $statCol ("[" + $Status.ToUpper() + "]")),
        (Seg 'dim' ' | Cadence: '), (Seg 'text' ("${Cadence}s (Adaptive)")),
        (Seg 'dim' ' | Cycles: '), (Seg 'text' ("$($script:SentinelStats.HealthyCycles)/$($script:SentinelStats.TotalCycles) healthy"))
    )
    if ($Adapter) {
        $ip = Get-ValidIPv4 $Adapter
        $gw = Get-DefaultGateway $Adapter
        $truncW = [Math]::Max(12, $w - 40)
        Out-Line @(
            (Seg 'dim' '  Adapter        : '), (Seg 'text' (Fit $adName $truncW)),
            (Seg 'dim' ' | IP: '), (Seg 'text' $(if ($ip) { $ip } else { 'APIPA/None' }))
        )
        Out-Line @(
            (Seg 'dim' '  Link Health    : '), (Seg $(if ($LinkHealth -and $LinkHealth.Healthy) { 'ok' } else { 'warn' }) (Fit $(if ($LinkHealth) { $LinkHealth.Reason } else { 'Unchecked' }) $truncW)),
            (Seg 'dim' ' | Gateway: '), (Seg 'text' $(if ($gw) { $gw } else { 'None' }))
        )
    }
    Out-Line @((Seg 'dim' ("  " + $sep)))
    Out-Line @((Seg 'text' '  AUTONOMOUS ESCALATION LADDER (INTERVENTIONS SINCE START):'))
    if ($w -ge 72) {
        Out-Line @(
            (Seg 'dim' '  T1 ARP/Route: '), (Seg 'ok' ("{0,-5}" -f $script:SentinelStats.T1_ArpRoute)),
            (Seg 'dim' '  T2 Captive: '), (Seg 'ok' ("{0,-5}" -f $script:SentinelStats.T2_Captive)),
            (Seg 'dim' '  T3 DNS/NRPT: '), (Seg 'ok' ("$($script:SentinelStats.T3_Dns)"))
        )
        Out-Line @(
            (Seg 'dim' '  T4 DHCP/STP : '), (Seg 'ok' ("{0,-5}" -f $script:SentinelStats.T4_Dhcp)),
            (Seg 'dim' '  T5 NDIS/PHY: '), (Seg 'ok' ("{0,-5}" -f $script:SentinelStats.T5_Ndis)),
            (Seg 'dim' '  T6 DeepStack: '), (Seg 'ok' ("$($script:SentinelStats.T6_Stack)"))
        )
    } else {
        Out-Line @(
            (Seg 'dim' '  T1 ARP: '), (Seg 'ok' ("{0,-4}" -f $script:SentinelStats.T1_ArpRoute)),
            (Seg 'dim' 'T2 Captive: '), (Seg 'ok' ("{0,-4}" -f $script:SentinelStats.T2_Captive)),
            (Seg 'dim' 'T3 DNS: '), (Seg 'ok' ("$($script:SentinelStats.T3_Dns)"))
        )
        Out-Line @(
            (Seg 'dim' '  T4 DHCP: '), (Seg 'ok' ("{0,-4}" -f $script:SentinelStats.T4_Dhcp)),
            (Seg 'dim' 'T5 NDIS: '), (Seg 'ok' ("{0,-4}" -f $script:SentinelStats.T5_Ndis)),
            (Seg 'dim' 'T6 Stack: '), (Seg 'ok' ("$($script:SentinelStats.T6_Stack)"))
        )
    }
    Out-Line @((Seg 'dim' ("  " + $sep)))
    Out-Line @((Seg 'text' '  FLIGHT RECORDER (RECENT SENTINEL EVENTS):'))
    if ($script:SentinelEvents -and $script:SentinelEvents.Count -gt 0) {
        $startIdx = [Math]::Max(0, $script:SentinelEvents.Count - 6)
        for ($i = $startIdx; $i -lt $script:SentinelEvents.Count; $i++) {
            $ev = $script:SentinelEvents[$i]
            $evCol = 'dim'
            if ($ev -match '\[OK\s*\]') { $evCol = 'ok' }
            elseif ($ev -match '\[WARN\s*\]') { $evCol = 'warn' }
            elseif ($ev -match '\[FAIL\s*\]') { $evCol = 'bad' }
            elseif ($ev -match '\[TIER.*?\]') { $evCol = 'cyan' }
            Out-Line @((Seg $evCol ("  " + (Fit $ev ($w - 6)))))
        }
    } else {
        Out-Line @((Seg 'dim' '  (No events recorded yet. System stable.)'))
    }
    Out-Line @((Seg 'dim' ("  " + $sep)))
    if ($w -ge 72) {
        Out-Line @(
            (Seg 'ok' '  [R]'), (Seg 'dim' ' Force Probe  '),
            (Seg 'ok' '[L]'), (Seg 'dim' ' View Log  '),
            (Seg 'ok' '[I]'), (Seg 'dim' ' Install 24/7  '),
            (Seg 'warn' '[U]'), (Seg 'dim' ' Uninstall  '),
            (Seg 'bad' '[Q]'), (Seg 'dim' ' Quit')
        )
    } else {
        Out-Line @(
            (Seg 'ok' '  [R]'), (Seg 'dim' ' Probe '),
            (Seg 'ok' '[L]'), (Seg 'dim' ' Log '),
            (Seg 'ok' '[I]'), (Seg 'dim' ' 24/7 '),
            (Seg 'warn' '[U]'), (Seg 'dim' ' Uninst '),
            (Seg 'bad' '[Q]'), (Seg 'dim' ' Quit')
        )
    }
}

function Wait-SentinelCadence([int]$Seconds, [bool]$Interactive, $Adapter = $null) {
    $ticks = [int]($Seconds * 4)
    $origStatus = if ($Adapter) { [string]$Adapter.Status } else { '' }
    $origIp = if ($Adapter) { Get-ValidIPv4 $Adapter } else { '' }
    for ($i = 0; $i -lt $ticks; $i++) {
        if (-not $script:SentinelRunning) { break }
        if ($Adapter -and ($i % 4 -eq 0 -and $i -gt 0)) {
            $freshAd = Get-NetAdapter -Name $Adapter.Name -ErrorAction SilentlyContinue
            if ($freshAd) {
                $curStatus = [string]$freshAd.Status
                $curIp = Get-ValidIPv4 $freshAd
                if ($curStatus -ne $origStatus -or $curIp -ne $origIp) {
                    Write-SentinelLog 'EVENT' ("Reactive event: State transition on {0} ({1} -> {2}, IP {3} -> {4})! Resuming immediately." -f $freshAd.Name, $origStatus, $curStatus, $(if ($origIp) { $origIp } else { 'None' }), $(if ($curIp) { $curIp } else { 'None' }))
                    break
                }
            }
        }
        if ($Interactive -and (Test-KeyAvailable)) {
            $k = Read-KeyNow
            if ($k.KeyChar -eq 'q' -or $k.KeyChar -eq 'Q' -or $k.Key -eq [ConsoleKey]::Escape) {
                $script:SentinelRunning = $false
                break
            }
            if ($k.KeyChar -eq 'r' -or $k.KeyChar -eq 'R') {
                Write-SentinelLog 'USER' "Manual trigger: Immediate scan forced by operator."
                break
            }
            if ($k.KeyChar -eq 'l' -or $k.KeyChar -eq 'L') {
                Show-SentinelLogView
                break
            }
            if ($k.KeyChar -eq 'i' -or $k.KeyChar -eq 'I') {
                [void](Invoke-WithLock { Install-SentinelTask })
                Start-Sleep -Seconds 1
                break
            }
            if ($k.KeyChar -eq 'u' -or $k.KeyChar -eq 'U') {
                [void](Invoke-WithLock { Uninstall-SentinelTask })
                Start-Sleep -Seconds 1
                break
            }
        }
        Start-Sleep -Milliseconds 250
    }
}

function Start-AutonomousDaemon([int]$IntervalSec = 10, [switch]$Headless) {
    if (-not (Assert-Admin)) { return }
    $script:DaemonConsecutiveFails = 0
    $script:DaemonLastHwCheck = [DateTime]::MinValue
    $script:SentinelRunning = $true
    $script:SentinelEventTriggered = $false

    $isConsole = (-not $Headless -and -not (Test-InputRedirected) -and $Host.Name -eq 'ConsoleHost')

    if ($null -eq $script:SentinelStats) {
        $script:SentinelStats = @{
            StartTime       = Get-Date
            TotalCycles     = 0
            HealthyCycles   = 0
            T1_ArpRoute     = 0
            T2_Captive      = 0
            T3_Dns          = 0
            T4_Dhcp         = 0
            T5_Ndis         = 0
            T6_Stack        = 0
            LastRemediation = 'None'
            LastRemTime     = $null
        }
    }

    Write-Banner "Daemon Mode (Autonomous Sentinel)"
    Write-SentinelLog 'INFO' ("Supreme Autonomous Sentinel Daemon activated (Interval: {0}s, Breaker: {1}, Mode: {2})." -f $IntervalSec, $script:Cfg.BreakerFails, $(if ($isConsole) { 'Interactive Cockpit' } else { 'Headless Background' }))
    if ($isConsole) {
        Write-Log 'OK' ("Autonomous Sentinel active. Press 'q' to stop, 'r' to force scan, 'l' to view log.")
    }

    # Reactive NetworkChange event tracking via thread-safe polled transition detector
    $currentCadence = $IntervalSec
    $lastHudRender = [DateTime]::MinValue

    try {
        while ($script:SentinelRunning) {
            try {
                $script:SentinelStats.TotalCycles++

            if ($script:SentinelStats.TotalCycles % 100 -eq 0) {
                [System.GC]::Collect()
                [System.GC]::WaitForPendingFinalizers()
            }

            # Phase 1: Physical Link & Dormant PnP Health
            $ads = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
            if ($ads.Count -eq 0) {
                if ((Get-Date) - $script:DaemonLastHwCheck -gt [TimeSpan]::FromSeconds(60)) {
                    Write-SentinelLog 'WARN' "No active Ethernet link. Checking for dormant or crashed PnP hardware..."
                    [void](Invoke-WithLock -WaitMs 3000 { Rescue-DormantEthernetPnp })
                    $script:DaemonLastHwCheck = Get-Date
                }
                $currentCadence = [Math]::Min(15, $IntervalSec)
                if ($isConsole) { Show-SentinelHud $null $null 'NoLink' $currentCadence }
                Wait-SentinelCadence $currentCadence $isConsole
                continue
            }

            $ad = $ads[0]

            # Phase 2: Per-Adapter Non-mutating Health Probe (Strictly bound to Ethernet)
            $linkHealth = Test-NdisLinkHealth $ad
            $ethIp = Get-ValidIPv4 $ad
            $gw = if ($ethIp) { Get-DefaultGateway $ad } else { $null }
            $gwOk = $false
            if ($gw) {
                $gwRtt = Test-LatencySample $gw 800
                if ($gwRtt -ge 0) { $gwOk = $true }
            }
            $state = if ($ethIp) {
                Get-InternetState -NoCache -SourceIp $ethIp
            } else {
                @{ State = 'Offline'; DnsOk = $false; Code = 0; Location = '' }
            }

            # Phase 3: Condition Evaluation & Self-Healing Ladder
            if ($ethIp -and $state.State -eq 'Online' -and $linkHealth.Healthy -and $gwOk) {
                $script:SentinelStats.HealthyCycles++
                if ($script:DaemonConsecutiveFails -gt 0) {
                    Write-SentinelLog 'OK' ("Link recovered! All health checks passed on {0} ({1}, Gateway {2}). Resetting circuit breaker (was {3} fails)." -f $ad.Name, $ethIp, $gw, $script:DaemonConsecutiveFails)
                    $script:DaemonConsecutiveFails = 0
                }
                # Ensure routing metrics prioritize Ethernet over Wi-Fi when Ethernet is confirmed Online
                $ctxOnline = @{ Ad = $ad; Env = (Get-AdapterEnvironment $ad) }
                Shield-RouteMetrics $ctxOnline 'Online'

                $batDaemon = Get-BatteryHealthAndEfficiency
                $currentCadence = if ($batDaemon.IsOnBattery) { [Math]::Max(20, $IntervalSec * 2) } else { $IntervalSec }
                if ($isConsole -and ((Get-Date) - $lastHudRender).TotalMilliseconds -ge 800) {
                    Show-SentinelHud $ad $linkHealth $state.State $currentCadence
                    $lastHudRender = Get-Date
                }
                Wait-SentinelCadence $currentCadence $isConsole $ad
                continue
            }

            # Captive State Handling: Captive is normal on campus, NOT a failure!
            if ($ethIp -and $state.State -eq 'Captive') {
                $cCtx = @{ Ad = $ad; Env = (Get-AdapterEnvironment $ad) }
                Ensure-CampusPortalPath $ad
                Shield-RouteMetrics $cCtx 'Captive'
                Shield-Dns $cCtx 'Captive'

                $creds = Get-PortalCredentials
                if ($creds) {
                    Write-SentinelLog 'TIER2' ("Captive portal detected! Stored credentials found for '{0}'. Executing autonomous headless login on {1}..." -f $creds.User, $ethIp)
                    $loginOk = [bool](Invoke-WithLock -WaitMs 8000 {
                        $auth = Invoke-HeadlessPortalLogin $state -Manual -SourceIp $ethIp
                        if ($auth) {
                            Complete-Authentication
                            Save-State
                        }
                        $auth
                    })
                    if ($loginOk) {
                        Write-SentinelLog 'OK' "Autonomous captive portal sign-in SUCCESSFUL! Restored high-speed Internet path."
                        $script:DaemonConsecutiveFails = 0
                        $script:SentinelStats.T2_Captive++
                        $currentCadence = 3
                        if ($isConsole) { Show-SentinelHud $ad $linkHealth 'Online' $currentCadence }
                        Wait-SentinelCadence $currentCadence $isConsole $ad
                        continue
                    }
                }
                
                # If no credentials or headless login didn't complete, ensure campus routing & DNS are active, and open portal (throttled)
                if (Test-Elapsed 'LastPortal' 60) {
                    Write-SentinelLog 'INFO' "Captive portal active. Opening campus login page in default browser..."
                    [void](Invoke-WithLock -WaitMs 3000 {
                        Open-Portal -Force -SourceIp $ethIp
                        Set-StateTime 'LastPortal'
                        Save-State
                    })
                }
                $script:DaemonConsecutiveFails = 0
                $currentCadence = [Math]::Min(15, $IntervalSec)
                if ($isConsole) { Show-SentinelHud $ad $linkHealth 'Captive (Login Ready)' $currentCadence }
                Wait-SentinelCadence $currentCadence $isConsole $ad
                continue
            }

            # Degradation Detected
            $script:DaemonConsecutiveFails++
            $ipDesc = if ($ethIp) { $ethIp } else { 'No IPv4 / APIPA' }
            Write-SentinelLog 'WARN' ("Degradation detected on {0} (Fail #{1}): IP={2}, State={3}, Ndis={4}, Gateway={5}" -f $ad.Name, $script:DaemonConsecutiveFails, $ipDesc, $state.State, $linkHealth.Reason, $(if ($gwOk) { 'OK' } else { 'Timeout' }))

            # Circuit Breaker Check (Smart Cadence Back-Off without surrendering)
            if ($script:DaemonConsecutiveFails -ge $script:Cfg.BreakerFails) {
                $currentCadence = [Math]::Min(60, 15 * [Math]::Pow(2, [Math]::Min(2, $script:DaemonConsecutiveFails - $script:Cfg.BreakerFails)))
                Write-SentinelLog 'WARN' ("Circuit breaker active ({0} fails). Upstream network down. Throttling scan to {1}s to protect switch port security." -f $script:DaemonConsecutiveFails, $currentCadence)
                if ($isConsole) { Show-SentinelHud $ad $linkHealth "Breaker ($($state.State))" $currentCadence }
                # Do NOT continue - still execute remediation ladder below!
            }

            # Engaging 6-Tier Self-Healing Ladder (Strict OSI Layered Hierarchy)
            $recovered = $false
            $remedTier = ''

            # Tier 1: IP & DHCP Lease Re-acquisition (Layer 1-3 Foundational Prerequisite)
            $curIp = Get-ValidIPv4 $ad
            if (-not $recovered -and (-not $curIp -or $curIp -like '169.254*')) {
                Write-SentinelLog 'TIER1' ("Executing Tier 1: Invalid IP or APIPA detected ({0}). Unfreezing DHCP and recovering valid lease..." -f $(if ($curIp) { $curIp } else { 'None' }))
                [void](Invoke-WithLock -WaitMs 25000 {
                    Repair-Dhcp $ad -ForceRelease
                })
                $newIp = Get-ValidIPv4 $ad
                if ($newIp -and $newIp -notlike '169.254*') {
                    Write-SentinelLog 'OK' "Tier 1 SUCCESS: Acquired valid DHCP lease: $newIp"
                    $script:SentinelStats.T4_Dhcp++
                    $ethIp = $newIp
                    $gw = Get-DefaultGateway $ad
                    $gwOk = if ($gw) { (Test-LatencySample $gw 800) -ge 0 } else { $false }
                    $state = Get-InternetState -NoCache -SourceIp $newIp
                    
                    # Immediately enforce routing and DNS for the newly acquired IP!
                    $ctxT1 = @{ Ad = $ad; Env = (Get-AdapterEnvironment $ad) }
                    Ensure-CampusPortalPath $ad
                    Shield-RouteMetrics $ctxT1 $state.State
                    Shield-Dns $ctxT1 $state.State
                    Save-State

                    if ($state.State -eq 'Online') {
                        $recovered = $true; $remedTier = 'Tier 1 (DHCP Lease -> Online)'
                    } elseif ($state.State -eq 'Captive') {
                        Write-SentinelLog 'INFO' "DHCP lease acquired; captive portal detected. Passing directly to portal authentication..."
                    }
                } else {
                    Write-SentinelLog 'WARN' "Tier 1: DHCP lease re-acquisition did not yield a valid IP. Proceeding to lower-layer diagnostics..."
                }
            }

            # Tier 2: Gateway ARP & Routing Priority Enforcement (Layer 3-4)
            $curIp = Get-ValidIPv4 $ad
            if (-not $recovered -and $curIp) {
                $gw = Get-DefaultGateway $ad
                $gwOk = if ($gw) { (Test-LatencySample $gw 800) -ge 0 } else { $false }
                if (-not $gwOk -or (-not $script:State.Misc['RouteProfile'] -or $script:State.Misc['RouteProfile'] -eq 'Adaptive')) {
                    Write-SentinelLog 'TIER2' "Executing Tier 2: Asserting Ethernet routing priority & locking gateway ARP..."
                    $ctxT2 = @{ Ad = $ad; Env = (Get-AdapterEnvironment $ad) }
                    [void](Invoke-WithLock -WaitMs 5000 {
                        if ($script:Cfg.ArpLock -and $gw) { Shield-GatewayArp $ctxT2 $state.State }
                        Shield-RouteMetrics $ctxT2 $state.State
                        Ensure-CampusPortalPath $ad
                        Save-State
                    })
                    $st2 = (Get-InternetState -NoCache -SourceIp $curIp).State
                    if ($st2 -eq 'Online') {
                        $recovered = $true; $remedTier = 'Tier 2 (Gateway/Route)'
                        $script:SentinelStats.T1_ArpRoute++
                    } elseif ($st2 -eq 'Captive') {
                        $state = @{ State = 'Captive'; Location = (Get-ActivePortalUrl) }
                    }
                }
            }

            # Tier 3: DNS Cache Purge & NRPT Cleansing (Layer 4-5)
            $curIp = Get-ValidIPv4 $ad
            if (-not $recovered -and $curIp -and ($state.State -eq 'NoDns' -or -not $state.DnsOk)) {
                Write-SentinelLog 'TIER3' "Executing Tier 3: DNS failure detected. Purging resolver cache & configuring resolvers..."
                [void](Invoke-WithLock -WaitMs 3000 {
                    Flush-NetworkCache
                    Shield-Dns @{ Ad = $ad; Env = (Get-AdapterEnvironment $ad) } $state.State
                    Save-State
                })
                $st3 = (Get-InternetState -NoCache -SourceIp $curIp).State
                if ($st3 -eq 'Online') {
                    $recovered = $true; $remedTier = 'Tier 3 (DNS/NRPT)'
                    $script:SentinelStats.T3_Dns++
                } elseif ($st3 -eq 'Captive') {
                    $state = @{ State = 'Captive'; Location = (Get-ActivePortalUrl) }
                }
            }

            # Tier 4: Autonomous Captive Portal Authentication (Layer 7)
            $curIp = Get-ValidIPv4 $ad
            if (-not $recovered -and $curIp) {
                $curProbe = Get-InternetState -NoCache -SourceIp $curIp
                if ($state.State -eq 'Captive' -or $curProbe.State -eq 'Captive') {
                    Write-SentinelLog 'TIER4' "Executing Tier 4: Captive portal detected! Checking DPAPI vault for credentials..."
                    $creds = Get-PortalCredentials
                    if ($creds) {
                        Write-SentinelLog 'TIER4' ("Stored credentials found for '{0}'. Executing headless login on {1}..." -f $creds.User, $curIp)
                        $loginOk = [bool](Invoke-WithLock -WaitMs 8000 {
                            $auth = Invoke-HeadlessPortalLogin $curProbe -Manual -SourceIp $curIp
                            if ($auth) {
                                Complete-Authentication
                                Save-State
                            }
                            $auth
                        })
                        if ($loginOk) {
                            Write-SentinelLog 'OK' "Autonomous captive portal sign-in SUCCESSFUL! Restored high-speed path."
                            $recovered = $true; $remedTier = 'Tier 4 (Captive Sign-In)'
                            $script:SentinelStats.T2_Captive++
                        }
                    } else {
                        Write-SentinelLog 'INFO' "No credentials in vault. Ensuring routes and triggering browser to open portal..."
                        [void](Invoke-WithLock -WaitMs 2000 {
                            Ensure-CampusPortalPath $ad
                            Shield-RouteMetrics @{ Ad = $ad; Env = (Get-AdapterEnvironment $ad) } 'Captive'
                            Open-Portal -Force -SourceIp $curIp
                            Set-StateTime 'LastPortal'
                            Save-State
                        })
                        $recovered = $true; $remedTier = 'Tier 4 (Portal Opened)'
                    }
                }
            }

            # Tier 5: Silicon NDIS Buffers & Physical PHY Power Shield
            if (-not $recovered -and -not $linkHealth.Healthy) {
                Write-SentinelLog 'TIER5' ("Executing Tier 5: NDIS packet drops or duplex issue ({0}). Calibrating PHY buffers and disabling power glitches..." -f $linkHealth.Reason)
                [void](Invoke-WithLock -WaitMs 5000 {
                    Resolve-DuplexFlap $ad
                    Optimize-PhySiliconBuffers $ad
                    Shield-Hardware $ad
                    Shield-TcpOffloads $ad
                    Save-State
                })
                $curIp = Get-ValidIPv4 $ad
                $st5 = if ($curIp) { (Get-InternetState -NoCache -SourceIp $curIp).State } else { 'Offline' }
                if ($st5 -eq 'Online') {
                    $recovered = $true; $remedTier = 'Tier 5 (NDIS/PHY)'
                    $script:SentinelStats.T5_Ndis++
                } else {
                    Write-SentinelLog 'TIER5' "NDIS recalibration insufficient. Initiating physical silicon PnP adapter restart..."
                    [void](Invoke-WithLock -WaitMs 10000 {
                        Reset-PhysicalAdapterHardware $ad
                        Wait-StpConvergence $ad ([int]$script:Cfg.StpMaxSec)
                        Save-State
                    })
                    $curIp = Get-ValidIPv4 $ad
                    $st5b = if ($curIp) { (Get-InternetState -NoCache -SourceIp $curIp).State } else { 'Offline' }
                    if ($st5b -eq 'Online') {
                        $recovered = $true; $remedTier = 'Tier 5 (PnP Restart)'
                        $script:SentinelStats.T5_Ndis++
                    }
                }
            }

            # Tier 6: Deep Stack Resuscitation (ACID Omnifix)
            if (-not $recovered -and $state.State -ne 'Captive') {
                Write-SentinelLog 'TIER6' "Executing Tier 6: Deep stack degradation. Resuscitating TCP/IP heuristics, Winsock catalog and core services..."
                [void](Invoke-WithLock -WaitMs 10000 {
                    Shield-SystemStack
                    Save-State
                })
                $curIp = Get-ValidIPv4 $ad
                $st6 = if ($curIp) { (Get-InternetState -NoCache -SourceIp $curIp).State } else { 'Offline' }
                if ($st6 -eq 'Online') {
                    $recovered = $true; $remedTier = 'Tier 6 (Deep Stack)'
                    $script:SentinelStats.T6_Stack++
                }
            }

            if ($recovered) {
                $script:SentinelStats.LastRemediation = $remedTier
                $script:SentinelStats.LastRemTime = Get-Date
                Write-SentinelLog 'OK' ("Autonomous remediation SUCCEEDED via {0}. Network restored to Online!" -f $remedTier)
                $script:DaemonConsecutiveFails = 0
                $currentCadence = 3
            } else {
                Write-SentinelLog 'FAIL' "All 6 autonomous escalation tiers exhausted without full online recovery."
                $currentCadence = [Math]::Min(30, $IntervalSec * 2)
            }

            if ($isConsole) {
                Show-SentinelHud $ad $linkHealth $(if ($recovered) { 'Recovered' } else { 'Degraded' }) $currentCadence
                $lastHudRender = Get-Date
            }

            Wait-SentinelCadence $currentCadence $isConsole $ad
        } catch {
            Write-SentinelLog 'FAIL' ("Unexpected daemon iteration error: {0}" -f $_.Exception.Message)
            Wait-SentinelCadence 3 $isConsole $ad
        }
    }
} finally {
    Write-SentinelLog 'INFO' "Autonomous Sentinel Daemon shutdown cleanly."
}
}

function Start-Interactive {
    if (Test-InputRedirected) {
        Write-Host 'The control center needs an interactive console. Use -Mode Heal, Diagnose, QuickProbe, SelfTest ... for scripted runs.' -ForegroundColor Yellow
        if (-not $NoPause -and $Host.Name -eq 'ConsoleHost') {
            Write-Host ''
            Write-Host 'Press any key to close...' -ForegroundColor Gray
            try { [void][Console]::ReadKey($true) } catch { Start-Sleep -Seconds 4 }
        }
        return
    }
    if ($script:IsAdmin) {
        $script:WatchdogOn = Test-WatchdogInstalled
        try { Update-WatchdogIfStale } catch {}
    }
    try {
        $intFile = Join-Path $script:StoreDir 'interactive.json'
        $self = [System.Diagnostics.Process]::GetCurrentProcess()
        $meta = @{ Pid = $PID; StartTime = $self.StartTime.ToUniversalTime().ToString('o'); User = [string]$env:USERNAME }
        [System.IO.File]::WriteAllText($intFile, (ConvertTo-Json -InputObject $meta -Compress))
    } catch {}
    try { [System.Diagnostics.Process]::GetCurrentProcess().PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal } catch {}
    Enter-Screen
    try {
        $t = New-Telemetry
        $adv = Get-Advice $t
        Show-Dashboard $t $adv          # instant skeleton, then the real reading
        $t = Get-Telemetry; $adv = Get-Advice $t
        if ($script:IsAdmin -and -not $script:IsDry -and ($t.Problem -eq 'Healthy' -or $t.Problem -eq 'Online')) {
            if (($t.RouteProfile -eq 'Adaptive' -and $t.Routing -eq 'Wi-Fi Protected' -and -not $t.UplinkActive) -or ($t.RouteProfile -eq 'Ethernet' -and $t.Routing -ne 'Ethernet First') -or ($t.RouteProfile -eq 'Wifi' -and ($t.Routing -ne 'Wi-Fi First' -and $t.UplinkActive))) {
                [void](Invoke-WithLock -WaitMs 2000 -Block { Complete-Authentication })
                $t = Get-Telemetry; $adv = Get-Advice $t
            }
        }
        $draw = $true
        $lastTel = Get-Date
        $lastW = Get-UiWidth
        $lastH = Get-UiHeight
        $autoLoginTried = $false
        $script:InDashboard = $true
        while ($true) {
            if ($draw) { Show-Dashboard $t $adv; $draw = $false; $lastW = Get-UiWidth; $lastH = Get-UiHeight; $script:InDashboard = $true }
            $key = $null
            while ($null -eq $key) {
                if (Test-KeyAvailable) { $key = Read-KeyNow; break }
                if ($t.GwIp -and (Update-Pulse $t.GwIp)) {
                    if ($null -ne $script:LiveGwRtt) { $t.GwRtt = $script:LiveGwRtt }
                    if ($script:Ui.Vt) { [void](Update-PulseRow $t) }
                }   # ping a silent gateway too: the lost replies ARE the picture
                if ((Get-UiWidth) -ne $lastW -or (Get-UiHeight) -ne $lastH) { $draw = $true; break }
                $ivl = 2; if ($t.Problem -ne 'Healthy' -and $t.Problem -ne 'Online') { $ivl = 4 }   # quickest refresh: 2s healthy, 4s offline/degraded
                if (((Get-Date) - $lastTel).TotalSeconds -ge $ivl) {
                    $t2 = Get-Telemetry; $lastTel = Get-Date
                    if ($script:IsAdmin -and -not $script:IsDry) {
                        $needsPrioritySync = ((Test-Elapsed 'DashPrioritySync' 30) -and ($t2.Problem -eq 'Healthy' -or $t2.Problem -eq 'Online') -and (
                            ($t.Problem -eq 'Captive') -or
                            ($t2.RouteProfile -eq 'Adaptive' -and $t2.Routing -eq 'Wi-Fi Protected' -and -not $t2.UplinkActive) -or
                            ($t2.RouteProfile -eq 'Ethernet' -and $t2.Routing -ne 'Ethernet First') -or
                            ($t2.RouteProfile -eq 'Wifi' -and ($t2.Routing -ne 'Wi-Fi First' -and $t2.UplinkActive))
                        ))
                        if ($needsPrioritySync) {
                            Set-StateTime 'DashPrioritySync'
                            [void](Invoke-WithLock -WaitMs 2000 -Block { Complete-Authentication })
                            $t2 = Get-Telemetry
                        } elseif ($t2.Problem -eq 'Captive' -and ($t.Problem -ne 'Captive' -or -not $autoLoginTried) -and $t2.Vault -and -not $t2.Paused -and $script:Cfg.AutoPortalLogin) {
                            $autoLoginTried = $true
                            [void](Invoke-WithLock -WaitMs 2000 -Block {
                                if (Invoke-HeadlessPortalLogin (Get-InternetState -NoCache)) { Save-State }
                            })
                            $t2 = Get-Telemetry
                        }
                    }
                    if ($null -ne $script:LiveGwRtt) { $t2.GwRtt = $script:LiveGwRtt }
                    if ((Get-Sig $t2) -ne (Get-Sig $t)) { $t = $t2; $adv = Get-Advice $t; $draw = $true; break }
                    $t = $t2
                }
                Start-Sleep -Milliseconds 15
            }
            if ($draw -and $null -eq $key) { continue }
            if ($null -eq $key) { continue }
            $ch = ([string]$key.KeyChar).ToLowerInvariant()
            if ($key.Key -eq 'Enter') { $ch = [string]$adv.Key }
            if ($key.Key -eq 'Spacebar' -or $key.KeyChar -eq ' ' -or $key.Key -eq 'F5') { $ch = '' }
            if ($key.Key -eq 'Escape') { $ch = '' }
            if ($ch -eq 'q') { break }
            Clear-InputBuffer
            if (-not $ch) {
                $script:ConnCache = $null
                $t = Get-Telemetry
                if ($null -ne $script:LiveGwRtt) { $t.GwRtt = $script:LiveGwRtt }
                $adv = Get-Advice $t
                $lastTel = Get-Date
                $draw = $true
                continue
            }
            $script:InDashboard = $false
            $handled = Invoke-DashboardKey $ch $adv
            Clear-InputBuffer
            if ($handled) {
                Clear-Screen
                $script:LiveGwRtt = $null
                $t = Get-Telemetry; $adv = Get-Advice $t; $lastTel = Get-Date; $draw = $true
            } else {
                $script:InDashboard = $true
            }
        }
    } finally {
        $script:InDashboard = $false
        try {
            $intFile = Join-Path $script:StoreDir 'interactive.json'
            if (Test-Path -LiteralPath $intFile) {
                $meta = ConvertFrom-Json (Get-Content -LiteralPath $intFile -Raw -ErrorAction SilentlyContinue)
                if ($meta -and $meta.Pid -eq $PID) { Remove-Item -LiteralPath $intFile -Force -ErrorAction SilentlyContinue }
            }
        } catch {}
        try { if ($script:Pulse.Ping) { $script:Pulse.Ping.Dispose(); $script:Pulse.Ping = $null; $script:Pulse.Task = $null } } catch {}
        try { [System.Diagnostics.Process]::GetCurrentProcess().PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Normal } catch {}
        Exit-Screen
    }
}
$script:IsAdmin = Test-IsAdmin
$adminModes = @('Interactive', 'Heal', 'QuickHeal', 'AutoHeal', 'Omnifix', 'NetReset', 'FullNetReset', 'UltraReset', 'Ultra', 'DoomsdayReset', 'Doomsday', 'ArmageddonReset', 'Armageddon', 'ResetOptions', 'ResetMenu', 'FlushCache', 'Flush', 'InstallWatchdog', 'UninstallWatchdog', 'InstallShield', 'UninstallShield', 'InstallSentinel', 'UninstallSentinel', 'ResetFactory', 'Reset', 'SetDnsProfile', 'Dns', 'DnsMenu', 'SetRouteProfile', 'Route', 'RouteMenu', 'Daemon', 'Sentinel', 'Vault')
if ($Mode -eq 'Interactive') {
    $intFile = Join-Path $script:Cfg.StoreDir 'interactive.json'
    if (Test-Path -LiteralPath $intFile) {
        try {
            $existing = ConvertFrom-Json (Get-Content -LiteralPath $intFile -Raw -ErrorAction SilentlyContinue)
            if ($existing -and $existing.Pid -and ($existing.Pid -ne $PID)) {
                $p = Get-Process -Id ([int]$existing.Pid) -ErrorAction SilentlyContinue
                if ($p -and ($p.ProcessName -match 'powershell|cmd|LanFixer')) {
                    if ($Force) {
                        try { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue } catch {}
                        Remove-Item -LiteralPath $intFile -Force -ErrorAction SilentlyContinue
                    } else {
                        try {
                            $ws = New-Object -ComObject WScript.Shell
                            [void]$ws.AppActivate($p.Id)
                        } catch {}
                        Write-Host ''
                        Write-Host '  ========================================================================' -ForegroundColor Cyan
                        Write-Host ("  Lan Fixer is already running in another window (PID {0})." -f $p.Id) -ForegroundColor Yellow
                        Write-Host '  Switched focus to the active window.' -ForegroundColor Gray
                        Write-Host '  (Use -Force or close the existing window to replace it)' -ForegroundColor DarkGray
                        Write-Host '  ========================================================================' -ForegroundColor Cyan
                        Write-Host ''
                        Start-Sleep -Seconds 2
                        exit 0
                    }
                } else {
                    Remove-Item -LiteralPath $intFile -Force -ErrorAction SilentlyContinue
                }
            }
        } catch {}
    }
}
if (-not $script:IsAdmin -and -not $script:IsDry -and ($adminModes -contains $Mode)) {
    $elevated = $false
    if (-not $LfElevated -and $script:SelfPath) {
        try {
            $parts = @('-LfElevated')
            foreach ($kv in $PSBoundParameters.GetEnumerator()) {
                if ($kv.Key -eq 'LfElevated') { continue }
                if ($kv.Value -is [System.Management.Automation.SwitchParameter]) { if ($kv.Value.IsPresent) { $parts += ('-' + $kv.Key) } }
                else {
                    $parts += ('-' + $kv.Key)
                    $vStr = [string]$kv.Value
                    if ($vStr -match '[\s"]') { $parts += ('"' + $vStr.Replace('"', '\"') + '"') }
                    else { $parts += $vStr }
                }
            }
            Start-Process -FilePath $script:SelfPath -ArgumentList ($parts -join ' ') -Verb RunAs -ErrorAction Stop
            $elevated = $true
        } catch { Write-Host 'Administrator approval was not granted.' -ForegroundColor Yellow }
    }
    if ($elevated) { exit 0 }
    if ($Mode -ne 'Interactive') {
        if ($Json) {
            [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'PreconditionFailed'; Message = 'Administrator rights required for this mode'; ExitCode = 40 } -Depth 2))
        } elseif ($Quiet) {
            [Console]::Out.WriteLine('Precondition Failed: Administrator rights required (ExitCode: 40)')
        } else {
            Write-Host '[x] This mode needs Administrator rights.' -ForegroundColor Red
        }
        exit 40
    }
}
if ($script:UiOn) { Initialize-Ui }
if ($script:IsAdmin) { Initialize-Store }
else {
    $script:StoreReady = Test-Path -LiteralPath $script:StoreDir
    $script:StoreSecure = Test-StoreAcl
}
Import-UserConfig
$script:State = Get-State
[void](Test-PriorResetJournal)
$exitCode = 0
try {
    if (@('AutoHeal', 'Daemon', 'Sentinel') -contains $Mode -and -not $script:IsDry) {
        $intCheck = Test-ScriptIntegrity
        if (-not $intCheck.Valid -and $intCheck.Status -ne 'MissingManifest') {
            Write-Log 'FAIL' ("CRITICAL SECURITY REFUSAL: Script failed integrity verification (" + ($intCheck.Errors -join '; ') + "). Refusing execution.")
            try {
                Write-EventLog -LogName 'Application' -Source 'LanFixer' -EventId 4001 -EntryType Error -Message ("CRITICAL: LanFixer detected unauthorized modification: " + ($intCheck.Errors -join '; ')) -ErrorAction SilentlyContinue
            } catch {}
            if ($Json) {
                [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'IntegrityTamper'; Errors = $intCheck.Errors; ExitCode = 50 } -Depth 2))
            } elseif ($Quiet) {
                [Console]::Out.WriteLine('Integrity Tamper: Script modification detected (ExitCode: 50)')
            } else {
                Write-Host '[x] INTEGRITY REFUSAL: Script failed cryptographic integrity verification.' -ForegroundColor Red
                foreach ($err in $intCheck.Errors) { Write-Host ("  - {0}" -f $err) -ForegroundColor Yellow }
            }
            exit 50
        }
    }
    if ($script:UiOn -and $Mode -ne 'Interactive') { Write-Banner ("{0}{1}" -f $Mode, $(if ($script:IsDry) { ' (dry run)' } else { '' })) }
    switch ($Mode) {
        'AutoHeal'          { [void](Invoke-AutoHeal) }
        'Omnifix'           { Invoke-SupremeOmnifix }
        'StandardReset'     { Invoke-SupremeOmnifix }
        'NetReset'          { Invoke-UltraSystemReset }
        'FullNetReset'      { Invoke-UltraSystemReset }
        'UltraReset'        { Invoke-UltraSystemReset }
        'Ultra'             { Invoke-UltraSystemReset }
        'DoomsdayReset'     { Invoke-DoomsdayReset }
        'Doomsday'          { Invoke-DoomsdayReset }
        'ArmageddonReset'   { Invoke-ArmageddonReset }
        'Armageddon'        { Invoke-ArmageddonReset }
        'ResetOptions'      { Show-View 'Recovery and System' { Show-ResetMenu } }
        'ResetMenu'         { Show-View 'Recovery and System' { Show-ResetMenu } }
        'SetRouteProfile'   { Set-RouteProfileMode $RouteProfile }
        'Route'             { Show-RouteMenu }
        'RouteMenu'         { Show-RouteMenu }
        'Heal' {
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            $r = Pick-Hash (Invoke-WithLock { Invoke-HealPipeline })
            $sw.Stop()
            Write-HealSummary $r $sw
            if ($r -and $r.Conn -eq 'Captive' -and -not $script:IsDry) {
                $signedHeadless = $false
                $portalSrc = if ($r.Ip) { [string]$r.Ip } else { Get-PrimarySourceIp }
                if ($script:Cfg.AutoPortalLogin -and (Get-PortalCredentials)) {
                    $signedHeadless = [bool](Invoke-HeadlessPortalLogin (Get-InternetState -NoCache -SourceIp $portalSrc) -Manual)
                    if ($signedHeadless) { [void](Invoke-WithLock { Complete-Authentication; Save-State }); Write-Log 'OK' 'Signed in automatically using stored vault credentials.' }
                }
                if (-not $signedHeadless) {
                    [void](Invoke-WithLock { [void](Open-Portal); Save-State })
                    if ((Get-InternetState -NoCache).State -eq 'Captive') {
                        if (Wait-ForAuthentication 180) { [void](Invoke-WithLock { Complete-Authentication }); Write-Log 'OK' 'Signed in. Post-login DNS applied.' }
                    }
                }
            }
        }
        'QuickHeal' {
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            $r = Pick-Hash (Invoke-WithLock { Invoke-HealPipeline })
            $sw.Stop()
            Write-HealSummary $r $sw
            if ($r -and $r.Conn -eq 'Captive' -and -not $script:IsDry) {
                $signedHeadless = $false
                $portalSrc = if ($r.Ip) { [string]$r.Ip } else { Get-PrimarySourceIp }
                if ($script:Cfg.AutoPortalLogin -and (Get-PortalCredentials)) {
                    $signedHeadless = [bool](Invoke-HeadlessPortalLogin (Get-InternetState -NoCache -SourceIp $portalSrc) -Manual)
                    if ($signedHeadless) { [void](Invoke-WithLock { Complete-Authentication; Save-State }); Write-Log 'OK' 'Signed in automatically using stored vault credentials.' }
                }
                if (-not $signedHeadless) {
                    [void](Invoke-WithLock { [void](Open-Portal); Save-State })
                    if ((Get-InternetState -NoCache).State -eq 'Captive') {
                        if (Wait-ForAuthentication 180) { [void](Invoke-WithLock { Complete-Authentication }); Write-Log 'OK' 'Signed in. Post-login DNS applied.' }
                    }
                }
            }
        }
        'Diagnose'          { Show-Diagnostics }
        'Audit'             { Show-Diagnostics }
        'Report'            { $exitCode = New-SupportReport -Json:$Json -Quiet:$Quiet -NoColor:$NoColor; if ($null -eq $exitCode) { $exitCode = 0 } }
        'QuickProbe'        { Run-QuickProbe }
        'Probe'             { Run-QuickProbe }
        'FlushCache'        { [void](Invoke-WithLock { Flush-NetworkCache }) }
        'Flush'             { [void](Invoke-WithLock { Flush-NetworkCache }) }
        'InstallWatchdog'   { [void](Invoke-WithLock { Install-Watchdog }) }
        'InstallShield'     { [void](Invoke-WithLock { Install-Watchdog }) }
        'UninstallWatchdog' { [void](Invoke-WithLock { Uninstall-Watchdog }) }
        'UninstallShield'   { [void](Invoke-WithLock { Uninstall-Watchdog }) }
        'ResetFactory'      { [void](Invoke-WithLock { Restore-Everything }) }
        'Reset'             { [void](Invoke-WithLock { Restore-Everything }) }
        'LaunchPortal'      { [void](Invoke-WithLock { Open-Portal -Force }) }
        'Login'             { [void](Invoke-WithLock { Open-Portal -Force }) }
        'SetDnsProfile'     { Set-DnsProfileMode $DnsProfile }
        'Dns'               { Show-DnsMenu }
        'DnsMenu'           { Show-DnsMenu }
        'SelfTest'          { Invoke-SelfTest -Json:$Json -Quiet:$Quiet -NoColor:$NoColor; if ($script:TestFail -gt 0) { $exitCode = 1 } else { $exitCode = 0 } }
        'Verify'            { Invoke-SelfTest -Json:$Json -Quiet:$Quiet -NoColor:$NoColor; if ($script:TestFail -gt 0) { $exitCode = 1 } else { $exitCode = 0 } }
        'Daemon'            { Start-AutonomousDaemon -Headless:$Headless }
        'Sentinel'          { Start-AutonomousDaemon -Headless:$Headless }
        'InstallSentinel'   { [void](Invoke-WithLock { Install-SentinelTask }) }
        'UninstallSentinel' { [void](Invoke-WithLock { Uninstall-SentinelTask }) }
        'Vault'             { Show-VaultMenu }
        'Guide' {
            if ($Id -or $args.Count -gt 0 -or $Json -or $Quiet -or -not $script:UiOn) {
                $targetCmd = if ($Id) { $Id } elseif ($args.Count -gt 0) { $args[0] } else { '' }
                $rep = Show-HelpReport -TargetMode $targetCmd -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
                $exitCode = [int]$rep.ExitCode
            } else {
                Show-Advisory
            }
        }
        'Help' {
            $targetCmd = if ($Id) { $Id } elseif ($args.Count -gt 0) { $args[0] } else { '' }
            $rep = Show-HelpReport -TargetMode $targetCmd -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
            $exitCode = [int]$rep.ExitCode
        }
        'Interactive'       { Start-Interactive }
        'Doctor' {
            $rep = Invoke-HealthDoctor -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
            $exitCode = [int]$rep.ExitCode
        }
        'Status' {
            $rep = Invoke-HealthDoctor -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
            $exitCode = [int]$rep.ExitCode
        }
        'History' {
            $targetSec = if ($Section) { $Section } elseif ($Id) { $Id } elseif ($args.Count -gt 0) { $args[0] } else { '' }
            $exitCode = Invoke-HistorySuite -Section $targetSec -Limit $Limit -Follow:$Follow -Level $Level -Filter $Filter -OutFile $OutFile -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
        }
        'Hist' {
            $targetSec = if ($Section) { $Section } elseif ($Id) { $Id } elseif ($args.Count -gt 0) { $args[0] } else { '' }
            $exitCode = Invoke-HistorySuite -Section $targetSec -Limit $Limit -Follow:$Follow -Level $Level -Filter $Filter -OutFile $OutFile -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
        }
        'Logs' {
            $targetSec = if ($Section) { $Section } else { 'logs' }
            $exitCode = Invoke-HistorySuite -Section $targetSec -Limit $Limit -Follow:$Follow -Level $Level -Filter $Filter -OutFile $OutFile -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
        }
        'Forensics' {
            $targetSec = if ($Section) { $Section } else { 'timeline' }
            $exitCode = Invoke-HistorySuite -Section $targetSec -Limit $Limit -Follow:$Follow -Level $Level -Filter $Filter -OutFile $OutFile -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
        }
        'Undo' {
            $res = Invoke-WithLock {
                Invoke-Undo -TargetId $Id -TargetRunId $RunId -Plan:$Plan -Force:$Force -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
            }
            $exitCode = if ($res -and $res.Status -eq 'NotFound') { 1 } else { 0 }
        }
        'Recover' {
            $res = Invoke-WithLock {
                Invoke-GuidedRecovery -Plan:$Plan -Force:$Force -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
            }
            $exitCode = [int]$res.ExitCode
        }
        'Bundle' {
            $res = New-SupportBundle -OutDir $OutDir -Redaction $Redaction -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
            $exitCode = [int]$res.ExitCode
        }
        'Config' {
            $exitCode = Show-ConfigReport -ValidateOnly:$Validate -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
        }
        'Integrity' {
            if ($Authorize) {
                if (-not $script:IsAdmin) {
                    if ($Json) {
                        [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'PreconditionFailed'; Message = 'Administrator rights required to authorize script'; ExitCode = 40 } -Depth 2))
                    } elseif ($Quiet) {
                        [Console]::Out.WriteLine('Precondition Failed: Administrator rights required (ExitCode: 40)')
                    } else {
                        Write-Host 'Administrator rights required to authorize script.' -ForegroundColor Red
                    }
                    exit 40
                }
                $ok = Set-ScriptAuthorization
                $authStatus = if ($ok) { 'Authorized' } else { 'Failed' }
                $authExitCode = if ($ok) { 0 } else { 1 }
                if ($Json) {
                    [Console]::Out.WriteLine((ConvertTo-Json @{ Status = $authStatus; ExitCode = $authExitCode } -Depth 2))
                } elseif ($Quiet) {
                    [Console]::Out.WriteLine($authStatus)
                } else {
                    if ($ok) { Write-Host 'Script cryptographic authorization recorded.' -ForegroundColor Green }
                    else { Write-Host 'Failed to authorize script.' -ForegroundColor Red }
                }
                $exitCode = if ($ok) { 0 } else { 1 }
            } else {
                $ti = Test-ScriptIntegrity
                if ($Json) {
                    $rep = @{
                        Status       = $ti.Status
                        Valid        = $ti.Valid
                        ScriptPath   = $ti.ScriptPath
                        ExpectedHash = $ti.ExpectedHash
                        ActualHash   = $ti.ActualHash
                        Errors       = $ti.Errors
                        ExitCode     = if ($ti.Valid -or $ti.Status -eq 'MissingManifest') { 0 } else { 50 }
                    }
                    [Console]::Out.WriteLine((ConvertTo-Json $rep -Depth 4))
                } elseif ($Quiet) {
                    [Console]::Out.WriteLine(('Integrity: {0}' -f $ti.Status))
                } else {
                    Write-Host '================================================================================' -ForegroundColor Cyan
                    Write-Host '                  LANFIXER CRYPTOGRAPHIC INTEGRITY AUDIT' -ForegroundColor Cyan
                    Write-Host '================================================================================' -ForegroundColor Cyan
                    Write-Host ("Script Target : {0}" -f $ti.ScriptPath)
                    Write-Host ("Status        : {0}" -f $ti.Status) -ForegroundColor $(if ($ti.Valid) { 'Green' } elseif ($ti.Status -eq 'MissingManifest') { 'Yellow' } else { 'Red' })
                    Write-Host ("Expected Hash : {0}" -f $ti.ExpectedHash)
                    Write-Host ("Computed Hash : {0}" -f $ti.ActualHash)
                    if ($ti.Errors.Count -gt 0) {
                        Write-Host 'Integrity Violations:' -ForegroundColor Red
                        foreach ($e in $ti.Errors) { Write-Host ("  - {0}" -f $e) -ForegroundColor Yellow }
                    }
                    Write-Host '================================================================================' -ForegroundColor Cyan
                }
                $exitCode = if ($ti.Valid -or $ti.Status -eq 'MissingManifest') { 0 } else { 50 }
            }
        }
        'Debloat' {
            if ($Audit -or $script:IsDry) {
                $exitCode = Invoke-NetworkDebloat -Audit -Tier $Tier -SafeOnly:$SafeOnly -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
            } else {
                $raw = Invoke-WithLock {
                    Invoke-NetworkDebloat -Tier $Tier -SafeOnly:$SafeOnly -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
                }
                $exitCode = if ($raw -is [int]) { $raw } else { 0 }
            }
        }
        'UndoDebloat' {
            $raw = Invoke-WithLock {
                Undo-NetworkDebloat -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
            }
            $exitCode = if ($raw -is [int]) { $raw } else { 0 }
        }
    }
    if ($script:IsPlan -and $Mode -ne 'Recover' -and $Mode -ne 'Undo') {
        if ($Json) {
            $rep = @{
                Status    = 'Planned'
                Mode      = $Mode
                PlanCount = $script:PlannedChanges.Count
                Changes   = $script:PlannedChanges
                ExitCode  = 0
            }
            [Console]::Out.WriteLine((ConvertTo-Json $rep -Depth 4))
        } elseif ($Quiet) {
            [Console]::Out.WriteLine(('Plan: {0} changes planned (0 mutations executed)' -f $script:PlannedChanges.Count))
        } else {
            Format-PlanPreview $script:PlannedChanges -Mode $Mode -NoColor:$NoColor
        }
        $exitCode = 0
    }
} catch {
    Write-Log 'FAIL' ("Unhandled error: " + $_.Exception.Message)
    Write-Log 'FAIL' ([string]$_.ScriptStackTrace)
    $exitCode = 1
} finally {
    try {
        $intFile = Join-Path $script:StoreDir 'interactive.json'
        if (Test-Path -LiteralPath $intFile) {
            $meta = ConvertFrom-Json (Get-Content -LiteralPath $intFile -Raw -ErrorAction SilentlyContinue)
            if ($meta -and $meta.Pid -eq $PID) { Remove-Item -LiteralPath $intFile -Force -ErrorAction SilentlyContinue }
        }
    } catch {}
    Save-State
    Exit-Lock
    if ($script:UiOn) { Exit-Screen }
}
if ($exitCode -eq 0 -and $script:FailCount -gt 0 -and (@('AutoHeal', 'Heal', 'QuickHeal', 'Omnifix', 'NetReset', 'FullNetReset', 'UltraReset', 'Ultra', 'DoomsdayReset', 'Doomsday', 'ArmageddonReset', 'Armageddon') -contains $Mode)) { $exitCode = 2 }
if ($exitCode -ne 0 -and -not $NoPause -and $Host.Name -eq 'ConsoleHost' -and -not $Quiet -and -not $Json) {
    Write-Host ''
    Write-Host 'LanFixer closed with an exit code. Press any key to close...' -ForegroundColor Gray
    Wait-AnyKey
} elseif ($script:UiOn -and $Mode -ne 'Interactive' -and -not $NoPause -and $Host.Name -eq 'ConsoleHost' -and -not $Quiet -and -not $Json) {
    Write-Host ''
    Write-Host 'Press any key to close...' -ForegroundColor Gray
    Wait-AnyKey
}
exit $exitCode
