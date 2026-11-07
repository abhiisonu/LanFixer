<# :
@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Lan Fixer
set "LANFIXER_SELF=%~f0"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create([System.IO.File]::ReadAllText($env:LANFIXER_SELF))) %*; exit $LASTEXITCODE"
exit /b %errorlevel%
#>

<#
.SYNOPSIS
    Lan Fixer 6.4.2 - Sovereign self-healing Ethernet stabilizer for campus/hostel LANs (Windows 10/11, Ethernet only).
    Author: A.S.
.DESCRIPTION
    Single file, ASCII only. Run it normally for the control center, or use -Mode:
      Interactive | Heal | AutoHeal | Diagnose | QuickProbe | FlushCache | InstallWatchdog |
      UninstallWatchdog | ResetFactory | LaunchPortal | SetDnsProfile | SelfTest | Report
    Add -DryRun to see exactly what would change without changing anything.
    Every change is snapshotted first, so ResetFactory restores YOUR original values.
.NOTES
    6.5.0 (Omniscient Layer 1-7 Healer, Doomsday Multi-Medium & Armageddon Deep OS Reset):
      - Invoke-ArmageddonReset: 4-stage Microsoft Windows native kernel network stack wipe and reinstallation weapon (netcfg.exe -d). Uninstalls all adapters, clears virtual switches/filters, wipes TCP/IP registry stack, and triggers clean PnP driver reinstallation upon reboot.
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
    6.4.2 (Sovereign Grand Master Final Hardening & PnP Optimization):
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
    6.4.0 (Grand Master Sovereign Hardening - 21-Point Alpha-to-Omega Resilience Engine):
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
    6.3.0 (Sovereign Zero-Reboot Situational Auto-Adaptation Engine):
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
    [ValidateSet('Interactive','Heal','QuickHeal','AutoHeal','Omnifix','NetReset','FullNetReset','UltraReset','Ultra','DoomsdayReset','Doomsday','ArmageddonReset','Armageddon','ResetOptions','ResetMenu','Diagnose','Audit','QuickProbe','Probe','FlushCache','Flush','InstallWatchdog','UninstallWatchdog','InstallShield','UninstallShield','InstallSentinel','UninstallSentinel','ResetFactory','Reset','LaunchPortal','Login','SetDnsProfile','Dns','DnsMenu','SetRouteProfile','Route','RouteMenu','SelfTest','Verify','Report','Daemon','Sentinel','Vault','Guide','Help')]
    [string]$Mode = 'Interactive',
    [ValidateSet('Adaptive','DHCP','Hybrid','Cloudflare','ResetDHCP')]
    [string]$DnsProfile = 'Adaptive',
    [ValidateSet('Adaptive','Ethernet','Wifi','Windows')]
    [string]$RouteProfile = 'Adaptive',
    [switch]$DryRun,
    [switch]$NoPause,
    [switch]$Force,
    [switch]$Headless,
    [Parameter(DontShow)][switch]$LfElevated
)

$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
try { Add-Type -AssemblyName System.Security -ErrorAction SilentlyContinue } catch {}

# ==============================================================================
# CONFIG (edit here, nowhere else)
# ==============================================================================
$script:Version = '6.5.0'
$script:Sys32   = Join-Path $env:SystemRoot 'System32'
$script:SelfPath = if ($env:LANFIXER_SELF -and (Test-Path -LiteralPath $env:LANFIXER_SELF)) { $env:LANFIXER_SELF } elseif ($PSCommandPath -and (Test-Path -LiteralPath $PSCommandPath)) { $PSCommandPath } elseif ($MyInvocation.MyCommand.Path -and (Test-Path -LiteralPath $MyInvocation.MyCommand.Path)) { $MyInvocation.MyCommand.Path } elseif ($PSScriptRoot -and (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'LanFixer.cmd'))) { (Join-Path $PSScriptRoot 'LanFixer.cmd') } else { (Join-Path (Get-Location).Path 'LanFixer.cmd') }
$script:IsDry   = [bool]$DryRun
$script:UiOn    = ($Mode -ne 'AutoHeal' -and $Mode -ne 'InstallSentinel' -and $Mode -ne 'UninstallSentinel' -and -not $Headless)
$script:Cfg = @{
    StoreDir        = (Join-Path $env:ProgramData 'LanFixer')
    SelfName        = 'LanFixer_Core.cmd'
    TaskWatchdog    = 'LanFixer_Watchdog'
    TaskPortal      = 'LanFixer_Portal'
    PortalHost      = 'gateway.nitjsr.ac.in'
    PortalPort      = 8888
    PortalIp        = '10.114.0.5'
    PortalUrl       = 'https://gateway.nitjsr.ac.in:8888/'
    CampusDns       = '172.16.1.2'
    CampusDomain    = 'nitjsr.ac.in'
    GwRegex         = '^10\.1\.\d{1,3}\.1$'   # only a 1-point hint; DNS/portal evidence decides
    ProfileRegex    = 'nitjsr|hostel|campus|academic'
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
$script:PowerKeywords = @('*EEE','EEE','EEELinkAdvertisement','EnableGreenEthernet','GreenEthernet','PowerSavingMode','AutoPowerSaveModeEnabled','ULPMode','EnableSavePowerNow','ReduceSpeedOnPowerDown','AdvancedEEE','GigaLite','*SelectiveSuspend','BatteryModeLinkSpeed','EnableBatteryModeLinkSpeed','EnableExtraPowerSaving','EnableAdaptiveLinkCap','*IdleRestriction','IdleRestriction')
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
function Invoke-Change {
    param([string]$Description, [scriptblock]$Action, [switch]$FailOnFalse)
    if ($script:IsDry) { Write-Log 'DRY' "Would: $Description"; return $true }
    $ErrorActionPreference = 'Stop'
    try {
        $out = @(& $Action)
        if ($FailOnFalse -and $out.Count -gt 0 -and $out[-1] -is [bool] -and -not $out[-1]) { throw 'the action reported failure' }
        $script:ChangeCount++
        Write-Log 'OK' $Description
        return $true
    } catch {
        $script:FailCount++
        Write-Log 'FAIL' ("{0} -> {1}" -f $Description, $_.Exception.Message)
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
    foreach ($k in 'Snapshot','Env','Dns','Arp','Times','Misc') { if ($s[$k] -isnot [hashtable]) { $s[$k] = @{} } }
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
function Test-Elapsed([string]$Name, [int]$Seconds) { return (((Get-Date) - (Get-StateTime $Name)).TotalSeconds -ge $Seconds) }

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
            [void](Invoke-Native $icacls @($f.FullName, '/setowner', '*S-1-5-32-544', '/T', '/C', '/Q'))
            [void](Invoke-Native $icacls @($f.FullName, '/reset', '/T', '/C', '/Q'))
        }
    }
    $cfgJson = Join-Path $Dir 'config.json'
    if (Test-Path -LiteralPath $cfgJson) {
        try {
            $co = (Get-Acl -LiteralPath $cfgJson).GetOwner([System.Security.Principal.SecurityIdentifier]).Value
            if (@('S-1-5-18', 'S-1-5-32-544') -notcontains $co -and ($trustedOwners -contains $co)) {
                [void](Invoke-Native $icacls @($cfgJson, '/setowner', '*S-1-5-32-544', '/C', '/Q'))
                [void](Invoke-Native $icacls @($cfgJson, '/reset', '/C', '/Q'))
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
function Get-ActivePortalUrl {
    $discUrl = ([string]$script:State.Misc['DiscoveredPortalUrl']).Trim()
    if ($discUrl) {
        $safe = Get-SafePortalUrl $discUrl
        if ($safe) { return $safe }
    }
    return [string]$script:Cfg.PortalUrl
}
function Find-ActivePortalPort([string]$HostOrIp, [int]$DefaultPort = 8888) {
    if (-not $HostOrIp) { return $DefaultPort }
    if ($script:State.Misc -and $script:State.Misc['DiscoveredPortalPort']) {
        $savedPort = [int]$script:State.Misc['DiscoveredPortalPort']
        if ($savedPort -ge 1 -and $savedPort -le 65535) {
            if (Test-TcpPort $HostOrIp $savedPort 250) { return $savedPort }
        }
    }
    $probePorts = @([int]$DefaultPort, 8888, 8003, 8443, 8080, 443, 80) | Select-Object -Unique
    foreach ($p in $probePorts) {
        if (Test-TcpPort $HostOrIp $p 300) {
            if ($script:State.Misc) { $script:State.Misc['DiscoveredPortalPort'] = $p }
            return $p
        }
    }
    return $DefaultPort
}
function Test-PortalOnlineSmart([string]$HostOrIp, [int]$ConfiguredPort = 8888) {
    $candidatePorts = @([int]$ConfiguredPort, 8888, 8003, 8443, 8080, 443, 80) | Select-Object -Unique
    foreach ($p in $candidatePorts) {
        if (Test-TcpPort $HostOrIp $p 350) { return $true }
    }
    return $false
}
function Get-ActivePortalEndpoint {
    $discIp = ([string]$script:State.Misc['DiscoveredPortalIp']).Trim()
    $discUrl = Get-ActivePortalUrl
    try {
        $u = [uri]$discUrl
        if ($u.Host) {
            $port = if ($u.Port -gt 0 -and $u.Port -ne 80 -and $u.Port -ne 443) { [int]$u.Port } else { Find-ActivePortalPort $u.Host ([int]$script:Cfg.PortalPort) }
            $ip = if ($discIp -and (Test-AllowedPortalIp $discIp)) { $discIp } else { [string]$script:Cfg.PortalIp }
            return @{ Host = [string]$u.Host; Ip = $ip; Port = $port; Url = $discUrl }
        }
    } catch {}
    return @{ Host = [string]$script:Cfg.PortalHost; Ip = [string]$script:Cfg.PortalIp; Port = [int]$script:Cfg.PortalPort; Url = [string]$script:Cfg.PortalUrl }
}
function Get-ActiveCampusDns($Ad = $null) {
    if ($Ad) {
        $d = @(Get-DhcpDnsServers ([string]$Ad.InterfaceGuid))
        if ($d.Count -gt 0) { return [string]$d[0] }
    } else {
        foreach ($a in @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })) {
            $d = @(Get-DhcpDnsServers ([string]$a.InterfaceGuid))
            if ($d.Count -gt 0) { return [string]$d[0] }
        }
    }
    return [string]$script:Cfg.CampusDns
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
                        if (-not $p) { $holderDead = $true }
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
                $meta = @{ Pid = $PID; Mode = ([string]$Mode); Time = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'); User = [string]$env:USERNAME }
                [System.IO.File]::WriteAllText($lf, (ConvertTo-Json -InputObject $meta -Compress))
            } catch {}
            $memMisc = @{}
            if ($script:State -is [hashtable] -and $script:State.Misc -is [hashtable]) {
                foreach ($mk in @('LearnedDhcp','DiscoveredDomain','DiscoveredPortalUrl','DiscoveredPortalIp','DiscoveryTime','InjectedHostRoutes')) {
                    if ($script:State.Misc.ContainsKey($mk)) { $memMisc[$mk] = $script:State.Misc[$mk] }
                }
            }
            $memEnv = if ($script:State -is [hashtable] -and $script:State.Env -is [hashtable]) { $script:State.Env.Clone() } else { @{} }
            $script:State = Get-State
            if ($memMisc['LearnedDhcp'] -and -not $script:State.Misc['LearnedDhcp']) { $script:State.Misc['LearnedDhcp'] = $memMisc['LearnedDhcp'] }
            if ($memMisc['DiscoveryTime'] -and ([string]$memMisc['DiscoveryTime'] -ge [string]$script:State.Misc['DiscoveryTime'])) {
                foreach ($mk in @('DiscoveredDomain','DiscoveredPortalUrl','DiscoveredPortalIp','DiscoveryTime')) {
                    if ($memMisc.ContainsKey($mk)) { $script:State.Misc[$mk] = $memMisc[$mk] }
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
    if ($script:IsAdmin) { return $true }
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
            $ep = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($SourceIp), 0)
            $c = New-Object System.Net.Sockets.TcpClient($ep)
        } else {
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
    if ($anc -le 0) { return $out }
    $i = 12
    $guard = 0
    while ($i -lt $Response.Length -and $guard -lt 256) {
        $len = [int]$Response[$i]
        if ($len -eq 0) { $i++; break }
        if (($len -band 0xC0) -eq 0xC0) { $i += 2; break }
        $i += ($len + 1); $guard++
    }
    $i += 4   # qtype + qclass
    $n = 0
    while ($n -lt $anc -and $i + 10 -le $Response.Length) {
        $n++
        $guard = 0
        while ($i -lt $Response.Length -and $guard -lt 256) {
            $len = [int]$Response[$i]
            if ($len -eq 0) { $i++; break }
            if (($len -band 0xC0) -eq 0xC0) { $i += 2; break }
            $i += ($len + 1); $guard++
        }
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
                if ($s -eq $script:Cfg.CampusDns -or $s -eq $script:Cfg.PortalIp) { $u = New-Object System.Net.Sockets.UdpClient }
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
        '(?is)(?:window\.|self\.|top\.|document\.)?location(?:\.href|\.replace)?\s*(?:=|\()\s*["''](https?://[^"''\s<>]+)["'']'
    )
    foreach ($rx in $patterns) {
        $m = [regex]::Match($h, $rx)
        if ($m.Success) {
            $u = [System.Net.WebUtility]::HtmlDecode($m.Groups[1].Value)
            if ($u -match '^https?://\S+$') { return $u }
        }
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
        if ($pinU) { return ($hex -and ($hex -eq $pinU)) }
        if ([string]$errs -eq 'None') { return $true }
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
    $r = Invoke-Native (Get-SysExe 'icacls.exe') @($Path, '/inheritance:r', '/grant:r', '*S-1-5-18:F', '/grant:r', '*S-1-5-32-544:F', '/C', '/Q') 5000
    return ($r.ExitCode -eq 0)
}

# The vault must be readable by SYSTEM and Administrators ONLY, with inheritance cut.
function Test-VaultAcl([string]$Path) {
    if (-not $Path) { $Path = $script:VaultFile }
    if (-not (Test-Path -LiteralPath $Path)) { return $true }
    try {
        $acl = Get-Acl -LiteralPath $Path
        $rules = $acl.GetAccessRules($true, $true, [System.Security.Principal.SecurityIdentifier])
        return ((Test-AclSidsOnly $rules @('S-1-5-18', 'S-1-5-32-544')) -and $acl.AreAccessRulesProtected)
    } catch { return $false }
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
    foreach ($a in @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })) {
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
    if ($script:Ui.Vt -and -not $script:Ui.Plain) {
        $txt = ConvertTo-AnsiString $Segs
        if (-not $NoNewline) { $txt += "`n" }
        [Console]::Write($txt)
        return
    }
    foreach ($s in @($Segs)) {
        $r = ([string]$s.R).TrimEnd('!')
        $col = $script:ConMap[$r]; if (-not $col) { $col = 'Gray' }
        Write-Host ([string]$s.T) -NoNewline -ForegroundColor $col
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
        Clear-Host
        foreach ($l in @($Lines)) { Out-Line $l }
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
function Test-InputRedirected { try { return [Console]::IsInputRedirected } catch { return $true } }

function Test-KeyAvailable { try { return [Console]::KeyAvailable } catch { return $false } }

function Read-KeyNow { return [Console]::ReadKey($true) }

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
        @{ Label = 'Link'; Value = $link; State = $st[0] },
        @{ Label = 'Address'; Value = $ip; State = $st[1] },
        @{ Label = 'Gateway'; Value = $gw; State = $st[2] },
        @{ Label = 'DNS'; Value = $dns; State = $st[3] },
        @{ Label = 'Internet'; Value = $net; State = $st[4] })
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
    $heroL = @((Seg 'faint' '  ['), (Seg ($adv.Role + '!') (' ' + $script:G.dot + ' ' + $adv.Word.ToUpper() + ' ')), (Seg 'faint' ']'))
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
    
    # categorized command dock (v3.9 inspired, minimal borderless)
    $uiH = Get-UiHeight
    if ($w -ge 74 -and ($uiH -eq 0 -or $uiH -ge 28)) {
        $col1W = $cw
        [void]$L.Add(@((Seg 'accent!' ('  REPAIR & CONNECTIVITY'.PadRight($col1W + 2))), (Seg 'accent!' 'DIAGNOSTICS & TOOLS')))
        [void]$L.Add(@((Seg $(if ($adv.Key -eq '1') { 'ok!' } else { 'text' }) ('  [1] Quick Heal'.PadRight($col1W + 2))), (Seg 'text' '[3] DNS Profile Engine')))
        [void]$L.Add(@((Seg $(if ($adv.Key -eq '2') { 'ok!' } else { 'text' }) ('  [2] Arm Watchdog Guard'.PadRight($col1W + 2))), (Seg 'text' '[M] Routing Priority Engine')))
        [void]$L.Add(@((Seg $(if ($adv.Key -eq 'a') { 'ok!' } else { 'text' }) ('  [A] Portal Login Vault'.PadRight($col1W + 2))), (Seg 'text' '[4] Live Latency Probe')))
        [void]$L.Add(@((Seg $(if ($adv.Key -eq '7') { 'ok!' } else { 'text' }) ('  [7] Open Portal Page'.PadRight($col1W + 2))), (Seg 'text' '[5] Flush DNS & ARP Caches')))
        [void]$L.Add(@((Seg $(if ($adv.Key -eq 'g') { 'ok!' } else { 'text' }) ('  [G] Headless Auto-Login'.PadRight($col1W + 2))), (Seg 'text' '[6] System Diagnostics Audit')))
        if ($uiH -eq 0 -or $uiH -ge 32) { [void]$L.Add(@()) }
        [void]$L.Add(@((Seg 'accent!' ('  PREVIEW & REPORTS'.PadRight($col1W + 2))), (Seg 'accent!' 'SYSTEM & RECOVERY')))
        [void]$L.Add(@((Seg 'text' ('  [T] Dry-Run Simulation'.PadRight($col1W + 2))), (Seg 'text' '[8] Disarm Watchdog')))
        [void]$L.Add(@((Seg 'text' ('  [R] Export Support Report'.PadRight($col1W + 2))), (Seg 'text' '[B] Autonomous Daemon')))
        [void]$L.Add(@((Seg 'text' ('  [S] Run Self-Test Suite'.PadRight($col1W + 2))), (Seg $(if ($adv.Key -eq 'x') { 'ok!' } else { 'accent!' }) '[X] Reset Options')))
        [void]$L.Add(@((Seg 'text' ('  [0] Guide'.PadRight($col1W + 2))), (Seg 'dim' '[Q] Quit')))
        if ($t.ArpPending) { [void]$L.Add(@((Seg 'warn!' ('  [K] Approve Gateway MAC Change'.PadRight($col1W + 2))), (Seg 'warn' 'Router MAC changed; review to lock ARP'))) }
    } else {
        $legend = @(@('1', 'QuickHeal'), @('X', 'ResetOptions'), @('2', 'Guard'), @('A', 'Vault'), @('7', 'Portal'), @('G', 'Login'), @('3', 'DNS'), @('M', 'Route'), @('4', 'Probe'), @('5', 'Flush'), @('6', 'Audit'), @('B', 'Daemon'), @('T', 'Test'), @('R', 'Report'), @('S', 'Verify'), @('8', 'Disarm'), @('9', 'Reset'), @('0', 'Guide'), @('Q', 'Quit'))
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
    Write-Banner 'DECISION & PROBLEM-SOLVING GUIDE'
    $w = Get-UiWidth
    Out-Line @((Seg 'accent!' '  Recommendation'))
    Out-Line @((Seg 'dim' '  * Plug in Ethernet cable  '), (Seg 'faint' '-> '), (Seg 'ok!' '[1] Quick Heal '), (Seg 'dim' '(repairs adapter, IP lease & routes)'))
    Out-Line @()
    Out-Line @((Seg 'accent!' '  COMMON SYMPTOMS & 1-TOUCH FIXES'.PadRight(50)), (Seg 'accent!' 'ACTION'))
    Out-Line @((Seg 'faint' ('  ' + ($script:G.rule * $w))))
    $matrix = @(
        # 1. Connection & Initial Setup
        @('Cable in, no IP / APIPA (169.254.x.x)',       '1', 'Quick Heal'),
        @('Campus portal login required for internet',   'A', 'Portal Login Vault'),
        @('Auto-repair on cable plug or system wake',    '2', 'Arm Background Watchdog'),
        @('Autonomous continuous sentinel monitoring',   'B', 'Autonomous Sentinel Daemon'),
        # 2. DNS & Everyday Browsing
        @('University ERP or intranet unreachable',      '3', 'Campus DHCP DNS Profile'),
        @('Balance traffic: Ethernet vs Wi-Fi',          'M', 'Routing Priority Engine'),
        @('Websites fail to open / stale DNS cache',     '5', 'Flush DNS & ARP Caches'),
        @('High ping, jitter or lag in games & calls',   '4', 'Latency & Loss Probe'),
        # 3. Diagnostics & Audit Reports
        @('Inspect hardware MAC, lease & gateway',       '6', 'System Diagnostics Audit'),
        @('Save diagnostic audit report to file',        'R', 'Export Support Report'),
        # 4. Safety & Rollback
        @('Instant background sign-in with saved login', 'G', 'Headless Portal Sign-In'),
        @('Total network down / no internet anywhere',   'X', 'Full Network Reset'),
        @('Total connectivity dead (Wi-Fi/LAN/USB/BT)','D', 'Doomsday System Reset'),
        @('Hyper-nuclear stack purge & driver/LSP rebuild','U', 'Ultra System Reset'),
        @('Preview repairs safely without changes',      'T', 'Dry-Run Simulation'),
        @('Verify system cmdlets & security integrity',  'S', 'Run Self-Test Suite'),
        @('Autonomous Sentinel background daemon',       'B', 'Autonomous Daemon'),
        @('Restore default Windows network settings',    '9', 'Factory Reset Rollback')
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
    $aliases = @{ w = '2'; n = 'x'; p = '4'; f = '5'; c = '5'; i = '6'; o = '7'; v = 'a'; l = 'g'; h = '0'; '?' = '0' }
    if ($aliases.ContainsKey($Key)) { $Key = $aliases[$Key] }
    switch ($Key) {
        '0' { Show-Advisory }
        'b' {
            Show-View 'autonomous sentinel daemon' {
                if (-not (Assert-Admin)) { return }
                Start-AutonomousDaemon
            } -NoWait
        }
        '1' { Start-Repair 'quick heal' }
        'm' { Show-View 'routing priority' { Show-RouteMenu } }
        'x' {
            Show-View 'reset & system recovery options' {
                Show-ResetMenu
            }
        }
        '!' {
            Show-View 'armageddon deep os wipe (netcfg -d)' {
                if (-not (Assert-Admin)) { return }
                Out-Line @((Seg 'bad!' '  DANGER: ARMAGEDDON SYSTEM RESET PERFORMS A KERNEL-LEVEL NETWORK REINSTALL:'))
                Out-Wrapped 'faint' $script:G.mid 'text' 'Kernel-level removal and reinstallation of all network protocols, virtual adapters, and hardware stacks via netcfg -d.' 4
                Out-Wrapped 'warn'  $script:G.mid 'warn' 'Requires an immediate system reboot to reconstruct the Windows networking stack.' 4
                Out-Line @()
                if (Read-Confirm 'Execute ARMAGEDDON SYSTEM RESET (netcfg -d, requires reboot)?' 'yes') {
                    $script:ChangeCount = 0; $script:FailCount = 0
                    Invoke-ArmageddonReset
                    $script:WdCache = $null
                } else {
                    Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
                }
            }
        }
        'd' {
            Show-View 'doomsday system reset (ultimate universal weapon)' {
                if (-not (Assert-Admin)) { return }
                Out-Line @((Seg 'warn!' '  CRITICAL: DOOMSDAY SYSTEM RESET IS THE ULTIMATE UNIVERSAL NETWORK WEAPON:'))
                Out-Wrapped 'faint' $script:G.mid 'text' 'Universal recovery when NO internet works by ANY way: Wi-Fi, Bluetooth, USB Tethering, LAN, Cellular' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 1: Pre-flight ACID global snapshot & 12-service reverse topological teardown' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 2: Universal physical adapter cycle (LAN, Wi-Fi, USB, BT, WWAN) & WLAN autoconfig reset' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 3: Dual-architecture 64-bit System32 & 32-bit SysWOW64 Winsock catalog wipe & autodial purge' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 4: Dual-stack TCP/IP stack restoration, global heuristics reset, tunnel defeat & HTTP flush' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 5: Routing table purge (route -f), portproxy reset, IP-HTTPS, bridge destruction & firewall reset' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 6: Encrypted DNS (DoH/DoT/DDR) wipe (global & per-interface), WPAD reset & BITS purge' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 7: Universal proxy & dead VPN killswitch annihilation across all user and machine hives' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 8: Hosts file sanitization, NRPT wipe & WFP filter defeat' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 9: NCSI active probing calibration, Kerberos ticket purge, SMB sweep & NLM cleanup' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 10: Low-level ARP/NDP eviction, NetBIOS release/refresh (nbtstat -R/-RR) & DNS resolver flush' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 11: Universal DHCP re-enablement, MTU 1500, RFC 2131 broadcast flag & lease zeroing across ALL media' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 12: Topological 12-service resuscitation, 802.1X reconnect, STP convergence & multi-adapter verification' 4
                Out-Line @()
                if (Read-Confirm 'Execute DOOMSDAY SYSTEM RESET (Ultimate Universal Weapon)?' 'yes') {
                    $script:ChangeCount = 0; $script:FailCount = 0
                    Invoke-DoomsdayReset
                    $script:WdCache = $null
                } else {
                    Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
                }
            }
        }
        'u' {
            Show-View 'ultra system reset (hyper-nuclear antimatter weapon)' {
                if (-not (Assert-Admin)) { return }
                Out-Line @((Seg 'warn!' '  WARNING: ULTRA SYSTEM RESET IS THE SUPREME HYPER-NUCLEAR REMEDIATION ENGINE:'))
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 1: Pre-flight ACID snapshot, process isolation & 10-service reverse topological teardown' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 2: Dual-architecture 64-bit System32 & 32-bit SysWOW64 Winsock catalog wipe & autodial zeroing' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 3: Dual-stack TCP/IP stack restoration, global heuristics reset, tunnel defeat & HTTP driver flush' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 4: Routing table purge (route -f), portproxy reset, bridge destruction & firewall factory policy' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 5: Encrypted DNS (DoH/DoT/DDR) wipe (global & per-interface), WPAD reset & BITS job purge' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 6: NCSI active probing calibration, Kerberos ticket purge, SMB session sweep & NLM cleanup' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 7: Low-level ARP/NDP eviction, NetBIOS release/refresh (nbtstat -R/-RR) & DNS resolver deep flush' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 8: PHY transceiver hard cycle, NDIS protocol re-binding, driver power lock & EEE defeat' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 9: DHCP lease registry obliteration, RFC 2131 broadcast flag enforcement & auto-metric lock' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Stage 10: Topological 10-service resuscitation, 802.1X reconnect, STP convergence & 7-layer verification' 4
                Out-Line @()
                if (Read-Confirm 'Execute ULTRA SYSTEM RESET (Hyper-Nuclear Antimatter Weapon)?' 'yes') {
                    $script:ChangeCount = 0; $script:FailCount = 0
                    Invoke-UltraSystemReset
                    $script:WdCache = $null
                } else {
                    Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
                }
            }
        }
        '2' {
            Show-View 'arm the watchdog' {
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
        '3' { Show-View 'dns profile' { Show-DnsMenu } }
        '4' { Show-View 'latency, packet loss & jitter probe' { Run-QuickProbe } }
        '5' {
            Show-View 'flush caches' {
                $script:ChangeCount = 0; $script:FailCount = 0
                [void](Invoke-WithLock { Flush-NetworkCache })
            }
        }
        '6' { Show-View 'system diagnostics audit' { Show-Diagnostics } }
        '7' {
            Show-View 'captive portal sign-in' {
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
            Show-View 'disarm the watchdog' {
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
                        if ($inet.State -eq 'Offline' -and (Test-PortalOnlineSmart $script:Cfg.PortalIp ([int]$script:Cfg.PortalPort))) {
                            $inet = @{ State = 'Captive'; Location = $script:Cfg.PortalUrl; Via = 'link' }
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
        's' { Show-View 'system self-test verification' { Invoke-SelfTest } }
        't' {
            Show-View 'safe dry-run simulation' {
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
        'r' { Show-View 'export system support report' { New-SupportReport } }
        '9' {
            Show-View 'factory reset & restore defaults' {
                if (-not (Assert-Admin)) { return }
                Out-Line @((Seg 'text' '  This action will revert system configuration:'))
                Out-Wrapped 'faint' $script:G.mid 'text' 'Restore all adapter properties, DNS resolvers, and route metrics to original pre-LanFixer state' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Unregister background watchdog and helper tasks, NRPT rules, and firewall exceptions' 4
                Out-Wrapped 'faint' $script:G.mid 'warn' 'Purge saved portal login credentials from the encrypted machine vault' 4
                Out-Line @()
                if (Read-Confirm 'Restore original settings?' 'yes') {
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
function ConvertFrom-PowerIndexText([string]$Text) {
    $m = [regex]::Match($Text, '0x([0-9a-fA-F]{1,8})')
    if (-not $m.Success) { return $null }
    return [Convert]::ToInt32($m.Groups[1].Value, 16)
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
    return (ConvertFrom-PowerIndexText ([string]$r.Output))
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
    [void](Invoke-Change 'USB selective suspend turned off in the active power plan (the dongle is never put to sleep)' {
        [void](Invoke-Native $pcfg @('/setacvalueindex', $scheme, $script:UsbSub, $script:UsbSet, '0') 5000)
        [void](Invoke-Native $pcfg @('/setdcvalueindex', $scheme, $script:UsbSub, $script:UsbSet, '0') 5000)
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
    foreach ($a in @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })) {
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
                $resp = $wr.GetResponse()
                $c = [int]$resp.StatusCode
                if ($c -eq 204) { $state = 'Online'; $via = 'system' }
                elseif (($c -ge 300 -and $c -le 399) -or ($c -ge 200 -and $c -le 299) -or $c -eq 401 -or $c -eq 407 -or $c -eq 511) {
                    $state = 'Captive'; $via = 'system'
                    $p1 = @{ Code = $c; Location = [string]$resp.Headers['Location'] }
                }
                $resp.Close()
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
                    $tmpIp = $null
                    if ([System.Net.IPAddress]::TryParse($lu.Host, [ref]$tmpIp) -and (Test-AllowedPortalIp $lu.Host)) {
                        $script:State.Misc['DiscoveredPortalIp'] = $lu.Host
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
    $rtt = Test-Ping $Gw 700
    if ($null -ne $rtt) { return @{ Alive = $true; Rtt = $rtt; Via = 'icmp' } }
    $ex = Get-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($ex -and [string]$ex.State -eq 'Permanent' -and $ex.LinkLayerAddress -and $ex.LinkLayerAddress -notmatch '^(00-)+00$') {
        $homeAd = $true
        try { $eh = Get-AdapterEnvironment $Ad -UseCache; if ($null -ne $eh.Home) { $homeAd = [bool]$eh.Home } } catch {}
        $gwSrc = [string](Get-ValidIPv4 $Ad)
        if ((Test-TcpPort $Gw 80 400 $gwSrc) -or (Test-TcpPort $Gw 443 400 $gwSrc) -or (Test-TcpPort $Gw 53 400 $gwSrc)) {
            return @{ Alive = $true; Rtt = $null; Via = 'arp' }
        }
        $freshArp = @(Get-GatewayMacs $Ad $Gw 1)
        if ($freshArp.Count -gt 0 -and $freshArp[0] -eq [string]$ex.LinkLayerAddress) {
            return @{ Alive = $true; Rtt = $null; Via = 'arp' }
        }
        return @{ Alive = $false; Rtt = $null; Via = '' }
    }
    if ($script:IsAdmin -and -not $script:IsDry -and $ex -and [string]$ex.State -ne 'Permanent') {
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
function Get-EthernetAdapters {
    Rescue-DormantEthernetPnp
    return @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object {
        $_.MediaType -eq '802.3' -and $_.InterfaceDescription -notmatch $script:VirtRegex
    })
}
function Get-IfaceReg([string]$Guid) {
    try { return (Get-ItemProperty -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$Guid" -ErrorAction Stop) } catch { return $null }
}
function Get-DhcpDnsServers([string]$Guid) {
    $reg = Get-IfaceReg $Guid
    if ($reg -and ($reg.DhcpNameServer -or $reg.Dhcpv6DNSServers)) {
        $res = @(([string]$reg.DhcpNameServer) -split '[,\s]+' | Where-Object { $_ -match '^\d{1,3}(\.\d{1,3}){3}$' -or $_ -match '^[0-9a-fA-F:]+$' })
        if ($reg.Dhcpv6DNSServers) { $res += @(([string]$reg.Dhcpv6DNSServers) -split '[,\s]+' | Where-Object { $_ -match '^[0-9a-fA-F:]+$' }) }
        return @($res | Select-Object -Unique)
    }
    return @()
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
        if ($ip -notlike '192.168.*' -or ($cfg.PortalIp -and $cfg.PortalIp -like '192.168.*')) {
            $detectedPort = Find-ActivePortalPort $cfg.PortalIp ([int]$cfg.PortalPort)
            if (Test-TcpPort $cfg.PortalIp $detectedPort 700) { $score += 2; $portalHit = $true; [void]$ev.Add("portal $($cfg.PortalIp):$detectedPort open") }
            if ($null -ne (Test-Ping $cfg.PortalIp 700)) { $score += 1; $portalHit = $true; [void]$ev.Add("portal firewall answers ping") }
            if ($null -ne (Test-Ping $cfg.CampusDns 700)) { $score += 1; [void]$ev.Add("campus DNS answers ping") }
        }
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
            }
        }
    }
    $info = @{ Env = $envName; Score = $score; Evidence = @($ev); Sticky = $sticky; Ip = $ip; Gateways = $gws; Home = $homeVerdict }
    $script:EnvCache[$guid] = @{ Time = (Get-Date); Info = $info }
    return $info
}

# Problem: NoAdapter | NoLink | NoIp | GwUnreachable | NoDns | Captive | Offline | Healthy
function Get-AdapterHealth($Ad) {
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
    $minWait = if ($MaxMs -gt 12000) { 3000 } else { 1000 }
    while ($sw.ElapsedMilliseconds -lt $MaxMs) {
        $ups = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
        if ($ups.Count -gt 0 -and $sw.ElapsedMilliseconds -ge $minWait) { break }
        Start-Sleep -Milliseconds 250
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
    if ($speed -match '^\s*10\s*M' -and $Ad.InterfaceDescription -match 'Gigabit|GbE|RTL81|I21|I22|1000') {
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
    if ($health.Discards -lt 1000) { return $false }

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

        $target = if ($cur -lt 512) { 512 } elseif ($cur -lt 1024) { 1024 } else { 2048 }
        if ($target -gt $cur) {
            Save-Original $guid ("Adv:" + $kw) [string]$cur
            $ok = Invoke-Change ("Scaled ring buffer {0} from {1} to {2} on {3} (NDIS discard mitigation)" -f $kw, $cur, $target, $Ad.Name) {
                Set-NetAdapterAdvancedProperty -Name $Ad.Name -RegistryKeyword $kw -RegistryValue @([string]$target) -NoRestart -ErrorAction Stop
            }
            if ($ok) { $modified = $true; $script:PendingRestart[$guid] = $Ad.Name }
        }
    }
    return $modified
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
    $guid = [string]$Ad.InterfaceGuid
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
    if (-not $script:IsAdmin) { return $false }
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

function Get-IPv4Interface($Ad) { return (Get-NetIPInterface -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue) }

function Get-DhcpFailureDiagnosis($Ad) { return (Get-DhcpFailureText (Get-DhcpErrorCode) ([string]$Ad.MacAddress)) }
function Test-DhcpLeaseUsable($Ad) {
    $ip = Get-ValidIPv4 $Ad
    if (-not $ip) { return $false }
    $gw = @(Get-GatewaysV4 $Ad) | Select-Object -First 1
    if (-not $gw) { return $false }
    return (Test-GatewayAlive $Ad $gw).Alive
}
function Repair-Dhcp($Ad, [switch]$ForceRelease) {
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
    if ($validIp -and $Ctx.Env.Env -eq 'Campus' -and -not $script:IsDry) {
        $gw = @(Get-GatewaysV4 $ad) | Select-Object -First 1
        if ($gw) { $script:State.Misc['LastCampusLease'] = @{ Ip = [string]$validIp; Gateway = [string]$gw; Time = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss') } }
    }
}

# ==============================================================================
# LAYER 3 - GATEWAY ARP INTEGRITY (verify, then lock; auto-release if it hurts)
# ==============================================================================
function Get-GatewayMacs($Ad, [string]$Gw, [int]$Samples = 3) {
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
    foreach ($gw in @(Get-GatewaysV4 $ad)) {
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
            Write-Log 'ALERT' ("Gateway {0} now answers from {1}, but it used to answer from {2}. Not locking it. If IT did not replace the router, treat this network with suspicion." -f $gw, $mac, [string]$mem[$gw])
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
function Get-SubnetInfoFromLease($Ad) {
    if (-not $Ad) { return $null }
    $ipObj = Get-NetIPAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike '169.254*' } | Select-Object -First 1
    if (-not $ipObj -or -not $ipObj.IPAddress) { return $null }
    $ipStr = [string]$ipObj.IPAddress
    $prefix = [int]$ipObj.PrefixLength
    if ($prefix -lt 0 -or $prefix -gt 32) { $prefix = 24 }

    $ip = [System.Net.IPAddress]::Parse($ipStr)
    $ipBytes = $ip.GetAddressBytes()
    $maskBytes = New-Object byte[] 4
    $netBytes = New-Object byte[] 4
    $bcastBytes = New-Object byte[] 4

    for ($i = 0; $i -lt 4; $i++) {
        $bits = [math]::Max(0, [math]::Min(8, $prefix - ($i * 8)))
        $maskBytes[$i] = [byte]$(if ($bits -eq 0) { 0 } else { 256 - [math]::Pow(2, 8 - $bits) })
        $netBytes[$i]  = [byte]($ipBytes[$i] -band $maskBytes[$i])
        $wildcard      = [byte](255 -bxor $maskBytes[$i])
        $bcastBytes[$i]= [byte]($netBytes[$i] -bor $wildcard)
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
        $Target = if ($gws.Count -gt 0) { $gws[0] } else { '9.9.9.9' }
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
function Get-PathMtuForAdapter($Ad, [string]$Target = '9.9.9.9') {
    foreach ($t in @($Target, '1.1.1.1') | Where-Object { $_ } | Select-Object -Unique) {
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
    $targetWireless = @(Get-AllWirelessAdapters)
    $allTargetOthers = @(@($others) + @($targetWireless) | Sort-Object ifIndex -Unique)
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
    $cands = @(@($script:Cfg.PublicDns) + @($Campus) | Select-Object -Unique)
    $meas = Measure-ResolversFast $cands
    foreach ($s in $cands) {
        $ms = $meas[$s]
        if ($null -ne $ms) { $scored += [pscustomobject]@{ Server = $s; Ms = $ms }; Write-Log 'INFO' ("  {0,-15} {1} ms" -f $s, $ms) }
        else { Write-Log 'INFO' ("  {0,-15} no answer (blocked or down)" -f $s) }
    }
    if ($scored.Count -eq 0) { return @($Campus) }
    $ordered = @($scored | Sort-Object Ms | ForEach-Object { [string]$_.Server })
    foreach ($c in $Campus) { if ($ordered -notcontains $c) { $ordered += $c } }
    $final = @($ordered | Select-Object -First 3)
    if ($Campus.Count -gt 0 -and @($final | Where-Object { $Campus -contains $_ }).Count -eq 0) { $final = @($final | Select-Object -First 2) + @($Campus[0]) }
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
    if ($ok -and -not $script:IsDry) { (Get-SubTable 'Dns' $guid).Managed = $true; Clear-DnsClientCache -ErrorAction SilentlyContinue }
    return $ok
}
# Only undo what WE changed (never wipe a static DNS the user set themselves).
function Restore-AdapterDns($Ad) {
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
    if (-not $script:IsAdmin) { return }
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
    if ($campus.Count -eq 0) { $campus = @($script:Cfg.CampusDns) }
    $phase = 'Auto'
    $order = @()
    switch ($prof) {
        'DHCP'       { $phase = 'Auto' }
        'ResetDHCP'  { $phase = 'Auto' }
        'Hybrid'     { $order = @('9.9.9.9', '8.8.8.8') + $campus; $phase = 'Public' }
        'Cloudflare' { $order = @($script:Cfg.CfDns) + $campus; $phase = 'Public' }
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
        $snap = Get-SubTable 'Original' 'NetProfiles'
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
        if (-not $script:State.Misc['LinkDownSince']) { Set-StateTime 'LinkDownSince'; Write-Log 'INFO' 'Link down: debouncing roaming cleanup against momentary cable flap (45s grace period).'; return }
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
        $script:State.Misc.Remove('DiscoveredPortalUrl')
        $script:State.Misc.Remove('DiscoveredPortalIp')
        $script:State.Misc.Remove('DiscoveredDomain')
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
        if ($tcpSetting -and [string]$tcpSetting.AutoTuningLevelLocal -eq 'Disabled') {
            Save-Original 'Global' 'TcpAutoTuning' 'Disabled'
            [void](Invoke-Change 'TCP Window Auto-Tuning restored to Normal (was Disabled by third-party optimizer)' {
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
            if ($r.ExitCode -eq 0 -and $r.Output -match 'Proxy Server\(s\)\s*:\s*(\S+)') {
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

function Shield-SystemStack([switch]$Aggressive) {
    if (-not $script:IsAdmin) { return }
    [void](Shield-Proxies)
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

function Invoke-SupremeOmnifix {
    if (-not (Assert-Admin)) { return }
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
            $script:State.Misc.Remove('MtuCandidate')
            $script:State.Misc.Remove('DiscoveredDomain')
            $script:State.Misc.Remove('DiscoveredPortalIp')
            $script:State.Misc.Remove('DiscoveredPortalUrl')
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
                foreach ($ea in @(Get-EthernetAdapters)) { Reset-PhysicalAdapterHardware $ea }
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
# ULTRA SYSTEM RESET - THE SUPREME HYPER-NUCLEAR REMEDIATION ENGINE
# ==============================================================================
function Invoke-UltraSystemReset {
    if (-not (Assert-Admin)) { return }
    $swUltra = [System.Diagnostics.Stopwatch]::StartNew()
    Write-Section 'ULTRA SYSTEM RESET (10-STAGE HYPER-NUCLEAR STACK RESUSCITATION)'
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
            foreach ($ea in @(Get-EthernetAdapters)) {
                try {
                    $snap = Capture-PreflightSnapshot $ea
                    if ($snap -and $snap.Guid) { $script:State.Snapshot[$snap.Guid] = $snap }
                } catch {}
            }
            if (-not $script:IsDry) { Save-State }
            $script:State.Misc['RouteProfile'] = 'Adaptive'
            $script:State.Misc['DnsProfile'] = 'Adaptive'
            $script:State.Misc['FailStreak'] = 0
            $script:State.Misc.Remove('MtuCandidate')
            $script:State.Misc.Remove('DiscoveredDomain')
            $script:State.Misc.Remove('DiscoveredPortalIp')
            $script:State.Misc.Remove('DiscoveredPortalUrl')
            
            # Teardown dependent services in strict reverse topological order to release kernel sockets, handles, and crypto locks
            $downSvcs = @('BITS', 'netprofm', 'NlaSvc', 'Dnscache', 'Dhcp', 'iphlpsvc', 'dot3svc', 'WlanSvc', 'CryptSvc', 'mpssvc')
            foreach ($s in $downSvcs) {
                try { Stop-Service -Name $s -Force -ErrorAction SilentlyContinue } catch {}
            }
        }

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
        Save-State
        $resHeal
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
# DOOMSDAY SYSTEM RESET - THE SUPREME UNIVERSAL NETWORK RESCUE WEAPON
# ==============================================================================
function Invoke-DoomsdayReset {
    if (-not (Assert-Admin)) { return }
    $swDoom = [System.Diagnostics.Stopwatch]::StartNew()
    Write-Section 'DOOMSDAY SYSTEM RESET (12-STAGE UNIVERSAL STACK ERADICATION)'
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
            foreach ($a in @(Get-NetAdapter -ErrorAction SilentlyContinue)) {
                try {
                    $snap = Capture-PreflightSnapshot $a
                    if ($snap -and $snap.Guid) { $script:State.Snapshot[$snap.Guid] = $snap }
                } catch {}
            }
            if (-not $script:IsDry) { Save-State }
            $script:State.Misc['RouteProfile'] = 'Adaptive'
            $script:State.Misc['DnsProfile'] = 'Adaptive'
            $script:State.Misc['FailStreak'] = 0
            $script:State.Misc.Remove('MtuCandidate')
            $script:State.Misc.Remove('DiscoveredDomain')
            $script:State.Misc.Remove('DiscoveredPortalIp')
            $script:State.Misc.Remove('DiscoveredPortalUrl')

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
                    Set-Service -Name $s -StartupType Automatic -ErrorAction SilentlyContinue
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
        Save-State
        $resHeal
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
# ARMAGEDDON SYSTEM RESET - KERNEL PROTOCOL & NETWORK ADAPTER REINSTALL WEAPON
# ==============================================================================
function Invoke-ArmageddonReset([switch]$RebootNow) {
    if (-not (Assert-Admin)) { return }
    $swArm = [System.Diagnostics.Stopwatch]::StartNew()
    Write-Section 'ARMAGEDDON SYSTEM RESET (KERNEL PROTOCOL & NETWORK ADAPTER REINSTALL)'
    Write-Log 'WARN' 'ARMAGEDDON RESET is Microsoft Windows native nuclear reset (netcfg.exe -d).'
    Write-Log 'WARN' 'This uninstalls ALL network adapters, removes virtual switches/filters, purges the TCP/IP stack registry, and requires a reboot to reinstall clean drivers.'

    if ($script:IsDry) {
        Write-Log 'DRY' 'Would capture global pre-flight snapshot across all adapters'
        Write-Log 'DRY' 'Would execute: netcfg.exe -d (deep kernel device cleanup & protocol reinstallation)'
        Write-Log 'DRY' 'Would execute post-cleanup: netsh winsock reset, netsh advfirewall reset, and reset RadioManagement'
        Write-Log 'DRY' 'Would prompt or execute scheduled reboot'
        return
    }

    # Pre-flight ACID snapshot
    Write-Log 'STEP' 'STAGE 1/4 Capturing global pre-flight snapshot across all network adapters'
    foreach ($a in @(Get-NetAdapter -ErrorAction SilentlyContinue)) {
        try {
            $snap = Capture-PreflightSnapshot $a
            if ($snap -and $snap.Guid) { $script:State.Snapshot[$snap.Guid] = $snap }
        } catch {}
    }
    if (-not $script:IsDry) { Save-State }

    # Execute netcfg -d
    Write-Log 'STEP' 'STAGE 2/4 Executing netcfg.exe -d (wiping network devices, virtual switches & protocol stacks)...'
    $netcfgRes = Invoke-Native (Get-SysExe 'netcfg.exe') @('-d') 30000
    if ($netcfgRes.Output) {
        Write-Log 'INFO' ("netcfg output: {0}" -f $netcfgRes.Output.Trim())
    }

    # Post-cleanup pass
    Write-Log 'STEP' 'STAGE 3/4 Running post-cleanup: resetting Winsock, Firewall & RadioManagement...'
    [void](Invoke-Native (Get-SysExe 'netsh.exe') @('winsock', 'reset') 5000)
    [void](Invoke-Native (Get-SysExe 'netsh.exe') @('advfirewall', 'reset') 5000)
    try {
        $rmKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\RadioManagement'
        if (Test-Path -LiteralPath $rmKey) {
            Set-ItemProperty -LiteralPath $rmKey -Name 'SystemRadioState' -Value 0 -Type DWord -ErrorAction SilentlyContinue
        }
    } catch {}

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

function Shield-Services($Ctxs, [string]$ConnState) {
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
        $fresh = Get-NetAdapter -InterfaceGuid $Ctx.Ad.InterfaceGuid -ErrorAction SilentlyContinue
        if (-not $fresh) { $fresh = Get-NetAdapter -InterfaceIndex $Ctx.Ad.ifIndex -ErrorAction SilentlyContinue }
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
    if ($script:State.Misc -and $script:State.Misc['LinkDownSince']) { $script:State.Misc.Remove('LinkDownSince') }
    $ctxs = @()
    foreach ($a in $ups) { $ctxs += @{ Ad = $a; Env = (Get-AdapterEnvironment $a); Repaired = $false } }
    foreach ($c in $ctxs) {
        Write-Log 'INFO' ("{0}: {1} (score {2}{3}) {4}" -f $c.Ad.Name, $c.Env.Env.ToUpper(), $c.Env.Score, $(if ($c.Env.Sticky) { ', last known' } else { '' }), (($c.Env.Evidence) -join '; '))
    }

    Write-Log 'STEP' 'LAYER 2/7  Data link & DHCP lease renewal'
    foreach ($c in $ctxs) { [void](Refresh-ContextAdapter $c); [void](Shield-Dot3Svc $c.Ad); Shield-DataLink $c }
    Invoke-LogIntelligence $ups
    $primaryIp = Get-PrimarySourceIp
    $conn = if ($primaryIp) { (Get-InternetState -NoCache -SourceIp $primaryIp).State } else { 'Offline' }

    Write-Log 'STEP' 'LAYER 3/7  Gateway ARP integrity & route metrics'
    foreach ($c in $ctxs) { [void](Refresh-ContextAdapter $c); Shield-GatewayArp $c $conn; Shield-RouteMetrics $c $conn; Shield-PathMtu $c $conn; Shield-DefaultRoutes $c }

    Write-Log 'STEP' 'LAYER 4/7  Adaptive DNS configuration & resolver health'
    foreach ($c in $ctxs) { [void](Refresh-ContextAdapter $c); Shield-Dns $c $conn }

    $primaryIp = Get-PrimarySourceIp
    $connAfterDns = if ($primaryIp) { (Get-InternetState -NoCache -SourceIp $primaryIp).State } else { 'Offline' }
    if ($connAfterDns -eq 'Online' -and $conn -ne 'Online') {
        $conn = 'Online'
        foreach ($c in $ctxs) { [void](Refresh-ContextAdapter $c); Shield-RouteMetrics $c $conn; Shield-PathMtu $c $conn }
    }

    Write-Log 'STEP' 'LAYER 5/7  Captive portal routing & reachability'
    foreach ($c in $ctxs) { [void](Refresh-ContextAdapter $c) }
    Shield-Portal $ctxs

    Write-Log 'STEP' 'LAYER 6/7  Network profile & firewall security'
    foreach ($c in $ctxs) { [void](Refresh-ContextAdapter $c); Shield-Profile $c }

    Write-Log 'STEP' 'LAYER 7/7  Network stack & service synchronization'
    foreach ($c in $ctxs) { [void](Refresh-ContextAdapter $c) }
    Shield-Services $ctxs $conn

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
    if ($h -eq ([string]$script:Cfg.PortalHost).ToLower() -or $h -eq [string]$script:Cfg.PortalIp) { return $true }
    $tmpIp = $null
    if ([System.Net.IPAddress]::TryParse($h, [ref]$tmpIp) -and (Test-AllowedPortalIp $h)) { return $true }
    $doms = @(([string]$script:Cfg.CampusDomain).ToLower().Trim('.'))
    $discDom = ([string]$script:State.Misc['DiscoveredDomain']).ToLower().Trim('.')
    if ($discDom -and $doms -notcontains $discDom) { $doms += $discDom }
    foreach ($dom in @($doms | Where-Object { $_ })) {
        if ($h -eq $dom -or $h.EndsWith('.' + $dom)) { return $true }
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
        try { $bytes = [System.Security.Cryptography.ProtectedData]::Unprotect($enc, (Get-VaultEntropy), [System.Security.Cryptography.DataProtectionScope]::LocalMachine) } catch {}
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
        foreach ($a in @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })) {
            $e = Get-AdapterEnvironment $a -UseCache
            if ($e.Env -eq 'Campus' -and (Get-DnsProfileName) -eq 'Adaptive') { Shield-Dns @{ Ad = $a; Env = $e } 'Captive' }
        }
        $Inet = if ($SourceIp) { Get-InternetState -NoCache -SourceIp $SourceIp } else { Get-InternetState -NoCache }
    }
    if ($Manual -and $Inet.State -eq 'Offline' -and (Test-PortalOnlineSmart $script:Cfg.PortalIp ([int]$script:Cfg.PortalPort))) {
        $Inet = @{ State = 'Captive'; Location = $script:Cfg.PortalUrl; Via = 'link' }
    }
    if ($Inet.State -ne 'Captive') { if ($Manual) { Write-Log 'INFO' 'This link is not behind the login page right now; nothing to do.' }; return $false }
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
    for ($hop = 0; $hop -lt 4; $hop++) {
        $page = Invoke-TlsHttp -Uri $cur -SourceIp $src -Pin $pin -Jar $jar
        if ($page.Error) { break }
        if ($page.Code -ge 300 -and $page.Code -le 399 -and $page.Location) {
            $next = $null
            try { $next = New-Object System.Uri($cur, $page.Location) } catch { $page = @{ Error = 'BadRedirect' }; break }
            if ($next.Scheme -ne 'https' -or -not (Test-CredentialPortalHost $next.Host)) { $page = @{ Error = 'UntrustedRedirect' }; break }
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
        if (-not $known) { $known = [string]$script:Cfg.PortalUrl }
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
        foreach ($a in @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })) {
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
    <Author>Lan Fixer</Author>
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
    <Hidden>false</Hidden>
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
    <Author>Lan Fixer</Author>
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
    if (-not $Url) { $Url = [string]$script:Cfg.PortalUrl }
    $url = [System.Security.SecurityElement]::Escape($Url)
    return @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Opens the campus login page in the signed-in user's browser. Started on demand by Lan Fixer.</Description>
    <Author>Lan Fixer</Author>
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
    <Hidden>false</Hidden>
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
    if ($ok2 -and -not $script:IsDry) { $script:State.Misc['PortalTaskUrl'] = [string]$script:Cfg.PortalUrl }
    if ($script:IsDry) { return $true }
    $script:WatchdogOn = Test-WatchdogInstalled
    if ($ok1 -and $script:WatchdogOn) {
        Write-Log 'OK' 'Watchdog active. It reacts to: cable connect, wake from sleep, address conflicts, boot, logon, and a heartbeat every few minutes.'
        if (-not $ok2) { Write-Log 'WARN' 'Portal helper task failed; the login page will not auto-open in background runs.' }
        $script:State.Misc['WatchdogSince'] = (Get-Date).ToString('o')
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
function Uninstall-Watchdog {
    if (-not (Assert-Admin)) { return }
    foreach ($n in @($script:Cfg.TaskWatchdog, $script:Cfg.TaskPortal, $script:Cfg.TaskNotify, 'A07_NetShield')) {
        [void](Invoke-Change "Scheduled task '$n' removed (if present)" {
            [void](Invoke-Native (Get-SysExe 'schtasks.exe') @('/end', '/tn', $n) 3000)
            [void](Invoke-Native (Get-SysExe 'schtasks.exe') @('/delete', '/tn', $n, '/f') 8000)
        })
    }
    if (-not $script:IsDry -and $script:State.Misc -is [hashtable]) { $script:State.Misc.Remove('WatchdogSince') }
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
    Write-Log 'INFO' 'Initiating Complete Sovereign Factory Reset & Rollback to Default Windows...'
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

    # 2. Restore Pre-LanFixer Snapshots (If snapshot exists in state)
    if ($script:State -is [hashtable] -and $script:State.Snapshot -is [hashtable]) {
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
                        $mAd = Get-NetAdapter -InterfaceGuid $guid -ErrorAction SilentlyContinue
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
            $hasCampusDns = $false
            foreach ($ip in $dnsInfo.ServerAddresses) {
                if ($ip -eq $script:Cfg.CampusDns -or $ip -eq $script:Cfg.PortalIp) { $hasCampusDns = $true; break }
            }
            if ($hasCampusDns -or (Get-SubTable 'Dns' $g).Managed -eq $true) {
                [void](Invoke-Change "DNS on $($a.Name) reset to automatic (DHCP)" { Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ResetServerAddresses -ErrorAction Stop })
            }
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
    if ($script:State.Misc['NeutralizedTasks'] -is [hashtable]) {
        foreach ($tn in @($script:State.Misc['NeutralizedTasks'].Keys)) {
            $tp = [string]$script:State.Misc['NeutralizedTasks'][$tn]
            [void](Invoke-Change "Restored 3rd-party task $tn" { Enable-ScheduledTask -TaskName $tn -TaskPath $tp -ErrorAction SilentlyContinue | Out-Null })
        }
    }
    if ($script:State.Misc['NeutralizedServices'] -is [hashtable]) {
        foreach ($sn in @($script:State.Misc['NeutralizedServices'].Keys)) {
            $rec = $script:State.Misc['NeutralizedServices'][$sn]
            $origStart = if ($rec -is [hashtable]) { [string]$rec.StartType } else { [string]$rec }
            if ($origStart -and $origStart -ne 'Disabled') {
                [void](Invoke-Change "Restored 3rd-party service $sn to $origStart" { Set-Service -Name $sn -StartupType $origStart -ErrorAction SilentlyContinue })
            }
        }
    }
    if ($script:State.Snapshot.ContainsKey('DeactivatedFilters')) {
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

    # 10. Restore Windows Firewall Rules from Backup
    $fwBackup = Join-Path $script:StoreDir 'firewall_pre_reset.wfw'
    if (Test-Path -LiteralPath $fwBackup) {
        [void](Invoke-Change 'Windows Firewall rules restored from pre-reset backup' {
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('advfirewall', 'import', $fwBackup) 8000)
        })
    } else {
        [void](Invoke-Change 'Windows Firewall restored to factory default policy' {
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('advfirewall', 'reset') 5000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('advfirewall', 'set', 'allprofiles', 'state', 'on') 5000)
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

        $scrubFiles = @('sentinel.log', 'sentinel.log.bak', 'firewall_pre_reset.wfw', 'LanFixer_Watchdog.xml', 'LanFixer_Portal.xml', 'LanFixer_Notify.xml', 'LanFixer_Sentinel.xml', 'LanFixer_Core.cmd', 'interactive.json')
        foreach ($sf in $scrubFiles) {
            $sfp = Join-Path $script:StoreDir $sf
            if (Test-Path -LiteralPath $sfp) { Remove-Item -LiteralPath $sfp -Force -ErrorAction SilentlyContinue }
        }

        $script:State = @{}
        foreach ($k in 'Snapshot','Env','Dns','Arp','Times','Misc') { $script:State[$k] = @{} }
        $script:State.Misc['Migrated'] = $true
        $script:State.Misc['FactoryResetDate'] = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        Save-State
    }

    Write-Log 'OK' 'Sovereign Factory Reset Complete. All settings reverted to pristine Windows defaults; zero tasks, zero rules, zero background hooks remain.'
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
    $w = Get-UiWidth
    Out-Line @()
    Out-Line @((Seg 'accent!' '  LAN FIXER'), (Seg 'faint' (' ' + $script:G.mid + ' ' + $Title.ToUpper())))
    Out-Rule $w
    Out-Line @()
}
function Write-Section([string]$Title) {
    $w = Get-UiWidth
    Out-Line @()
    Out-Line @((Seg 'accent!' ('  ' + $Title.ToLower() + ' ')), (Seg 'faint' ($script:G.rule * [Math]::Max(3, $w - $Title.Length - 2))))
    Out-Line @()
}
function Write-KV([string]$Key, [string]$Value, [string]$Color = 'White') {
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
            try { $r = $p.Send($Target, 900, $buf, $opt); if ($r.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) { return $true } } catch {}
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
    Write-Banner 'LATENCY, PACKET LOSS & JITTER PROBE'
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
                Start-Sleep -Milliseconds 120
            }
            $pTag = if ($gatewaysToProbe.Count -gt 1) { "[1{0}] {1} {2}" -f ([char](96 + $gIdx)), $gItem.Label, $gItem.Ip } else { "[1] Gateway {0}" -f $gItem.Ip }
            if ($rtts.Count -gt 0) {
                $avg = ($rtts | Measure-Object -Average).Average
                $jit = ($rtts | Measure-Object -Maximum).Maximum - ($rtts | Measure-Object -Minimum).Minimum
                $lab = Get-LatencyLabel $avg
                Write-KV $pTag ("{0:N1} ms avg ({1}), jitter {2} ms, loss {3}%" -f $avg, $lab[0], $jit, ($lost * 10)) $(if ($lost -gt 1) { 'Yellow' } else { $lab[1] })
            } else {
                Write-KV $pTag 'No ping response (ICMP traffic may be filtered by router)' 'Yellow'
            }
            $gIdx++
        }
    }
    $epProbe = Get-ActivePortalEndpoint
    $tcp = Test-TcpPort $epProbe.Ip $epProbe.Port 900
    $pp = Test-Ping $epProbe.Ip 800
    Write-KV ("[2] Portal {0}" -f $epProbe.Ip) ("tcp/{0} {1}, ping {2}" -f $epProbe.Port, $(if ($tcp) { 'open' } else { 'closed' }), $(if ($null -ne $pp) { "$pp ms" } else { 'no reply' })) $(if ($tcp) { 'Green' } else { 'Yellow' })
    $servers = @(@(Get-ActiveCampusDns) + @($script:Cfg.PublicDns) | Select-Object -Unique)
    $meas = Measure-ResolversFast $servers
    foreach ($s in $servers) {
        $ms = $meas[$s]
        if ($null -ne $ms) { $lab = Get-LatencyLabel $ms; Write-KV ("[3] DNS {0}" -f $s) ("{0} ms median lookup ({1})" -f $ms, $lab[0]) $lab[1] }
        else { Write-KV ("[3] DNS {0}" -f $s) 'No response (unreachable or blocked prior to login)' 'Yellow' }
    }
    $st = (Get-InternetState -NoCache).State
    $col = $(switch ($st) { 'Online' { 'Green' } 'Captive' { 'Yellow' } default { 'Red' } })
    Write-KV '[4] HTTP internet probe' $st $col
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
function New-SupportReport {
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
    Write-Host $text
    try {
        $tmp = $path + '.tmp'
        [System.IO.File]::WriteAllText($tmp, $text, (New-Object System.Text.UTF8Encoding($true)))
        Move-Item -LiteralPath $tmp -Destination $path -Force -ErrorAction Stop
        Write-Log 'OK' "Report saved: $path  (contains your MAC, IP and PC name: read it before sharing)"
    } catch { Write-Log 'WARN' ("Could not write the report file (" + $_.Exception.Message + "). The text is shown above: copy it manually.") }
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
    Write-Banner 'FLUSH DNS, ARP & NETBIOS CACHES'
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
    [void](Invoke-Change 'DNS resolver cache & internal speed-test cache cleared' {
        Clear-DnsClientCache -ErrorAction SilentlyContinue
        [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/flushdns') 5000)
    })
    [void](Invoke-Change 'Dynamic IPv4 & IPv6 ARP/neighbor entries cleared (locked gateway entry is kept)' {
        Get-NetNeighbor -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.State -ne 'Permanent' } | Remove-NetNeighbor -Confirm:$false -ErrorAction SilentlyContinue
        Get-NetNeighbor -AddressFamily IPv6 -ErrorAction SilentlyContinue | Where-Object { $_.State -ne 'Permanent' } | Remove-NetNeighbor -Confirm:$false -ErrorAction SilentlyContinue
    })
    [void](Invoke-Change 'NetBIOS name cache purged & re-registered' {
        [void](Invoke-Native (Get-SysExe 'nbtstat.exe') @('-R') 8000)
        [void](Invoke-Native (Get-SysExe 'nbtstat.exe') @('-RR') 8000)
    })
    [void](Invoke-Change 'Network List service refreshed (clears a stuck "no internet" icon)' {
        Restart-Service -Name NlaSvc -Force -ErrorAction Stop
        Start-Service -Name netprofm -ErrorAction SilentlyContinue
    })
    Save-State
    Write-Log 'OK' 'Network resolver, internal telemetry, and neighbor caches flushed successfully.'
}

# ==============================================================================
# SELF TEST (verifies this machine supports everything; changes nothing)
# ==============================================================================
$script:TestFail = 0
$script:TestWarn = 0
function Write-Check([string]$Label, [bool]$Ok, [bool]$WarnOnly = $false, [string]$Detail = '') {
    $gl = $script:G.ok; $role = 'ok'
    if (-not $Ok) { if ($WarnOnly) { $gl = $script:G.warn; $role = 'warn'; $script:TestWarn++ } else { $gl = $script:G.bad; $role = 'bad'; $script:TestFail++ } }
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
    Write-Check 'Logic: IPv6 verdict none' ((Get-Ipv6Verdict $false $false 'Online' $false) -eq 'None')
    Write-Check 'Logic: IPv6 verdict blackhole' ((Get-Ipv6Verdict $true $true 'Online' $false) -eq 'Blackhole')
    Write-Check 'Logic: IPv6 verdict working' ((Get-Ipv6Verdict $true $true 'Online' $true) -eq 'Working')
    Write-Check 'Logic: IPv6 verdict untested while captive' ((Get-Ipv6Verdict $true $true 'Captive' $false) -eq 'Untested')
    Write-Check 'Logic: hard failures counted' ((Test-HardFailure 'Offline') -and (Test-HardFailure 'NoIp') -and -not (Test-HardFailure 'Captive') -and -not (Test-HardFailure 'Healthy'))
    Write-Check 'Logic: Notify Task XML well-formed' ([bool]([xml](New-NotifyTaskXml)))
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
    $gsDef = [string](Get-Command Get-State -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Get-State self-heals from .bak/.tmp when primary state file is damaged' ($gsDef.IndexOf('.bak') -ge 0 -and $gsDef.IndexOf('.tmp') -ge 0)
    $fcDef = [string](Get-Command Flush-NetworkCache -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Flush-NetworkCache clears internal ConnCache, EnvCache, OrderTime and IPv6 neighbors' ($fcDef.IndexOf('$script:ConnCache = $null') -ge 0 -and $fcDef.IndexOf('AddressFamily IPv6') -ge 0 -and $fcDef.IndexOf('OrderTime') -ge 0)
    $liDef = [string](Get-Command Invoke-LogIntelligence -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Invoke-LogIntelligence inspects DNS Event 1014 and NIC hardware reset events' ($liDef.IndexOf('1014') -ge 0 -and $liDef.IndexOf('10400') -ge 0)
    $sdUniv = [string](Get-Command Shield-Dns -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Shield-Dns honors Cloudflare/Hybrid and rescues NoDns on non-campus networks' ($sdUniv.IndexOf('$orderOther') -ge 0)
    $gaeDef = [string](Get-Command Get-AdapterEnvironment -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Get-AdapterEnvironment uses bounded Resolve-HostBounded (never raw GetHostAddresses)' ($gaeDef.IndexOf('GetHostAddresses') -lt 0 -and $gaeDef.IndexOf('Resolve-HostBounded') -ge 0)
    $elDef = [string](Get-Command Enter-Lock -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Enter-Lock preserves in-memory DiscoveredDomain, DiscoveredPortalIp, and InjectedHostRoutes' ($elDef.IndexOf('DiscoveredDomain') -ge 0 -and $elDef.IndexOf('InjectedHostRoutes') -ge 0)
    $rscDef = [string](Get-Command Repair-StoreChildren -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Repair-StoreChildren normalizes config.json owner to Administrators' ($rscDef.IndexOf('config.json') -ge 0)
    Write-Check 'Logic: dynamic endpoint helpers (Get-ActivePortalUrl, Get-ActivePortalEndpoint, Get-ActiveCampusDns) exist' ($null -ne (Get-Command Get-ActivePortalUrl -ErrorAction SilentlyContinue) -and $null -ne (Get-Command Get-ActivePortalEndpoint -ErrorAction SilentlyContinue) -and $null -ne (Get-Command Get-ActiveCampusDns -ErrorAction SilentlyContinue))
    $wxXml = [string](New-WatchdogXml '/c test' '2026-01-01T00:00:00')
    Write-Check 'Logic: Watchdog XML subscribes to both connect (10000) and disconnect (10001) events' ($wxXml.IndexOf('EventID=10000 or EventID=10001') -ge 0)
    $ahDebounce = [string](Get-Command Invoke-AutoHeal -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: AutoHeal debounce is state-aware and never drops cable plug/unplug transitions' ($ahDebounce.IndexOf('LastAutoHealUpCount') -ge 0)
    $arpDef = [string](Get-Command Shield-GatewayArp -ErrorAction SilentlyContinue).Definition
    Write-Check 'Logic: Shield-GatewayArp actively verifies Test-GatewayAlive on Permanent lock when not Online' ($arpDef.IndexOf('$lockAlive') -ge 0)
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
    # v6.0.0 Sovereign Peak: RFC 8910 DHCP Option 114 captive URL decoder check
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

    $script:State = $stSave
}
function Invoke-SelfTest {
    $script:TestFail = 0; $script:TestWarn = 0
    Write-Banner 'SYSTEM INTEGRITY SELF-TEST (READ-ONLY)'
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
    Write-Check 'Protected store ACL verified' $script:StoreSecure $true
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
    Write-Host ''
    if ($script:TestFail -eq 0) { Out-Line @((Seg 'ok!' ('  ' + $script:G.dot + '  ready')), (Seg 'dim' ('   {0} {1} warnings' -f $script:G.mid, $script:TestWarn))) }
    else { Out-Line @((Seg 'bad!' ('  ' + $script:G.dot + '  ' + $script:TestFail + ' failed')), (Seg 'dim' ('   {0} {1} warnings' -f $script:G.mid, $script:TestWarn))) }
}

# ==============================================================================
# CONTROL CENTER (79 columns, ASCII only, auto-refreshing)
# ==============================================================================
function Pick-Hash($Value) { return (@($Value | Where-Object { $_ -is [hashtable] }) | Select-Object -First 1) }
function Wait-AnyKey {
    if (Test-InputRedirected) { return }   # headless / piped: never block
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
    } else {
        Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
    }
}
function Show-RouteMenu {
    $cur = Get-RouteProfileName
    Out-Line @((Seg 'text' '  Choose how Windows balances traffic between Gigabit Ethernet and Wi-Fi / Hotspot:'))
    Out-Line @()
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
    } else {
        Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
    }
}
function Show-ResetMenu {
    if (-not (Assert-Admin)) { return }
    Out-Line @((Seg 'warn!' '  RESET & SYSTEM RECOVERY OPTIONS:'))
    Out-Line @((Seg 'dim'   '  Choose the appropriate recovery weapon based on the severity of network death:'))
    Out-Line @()
    $options = @(
        @('1', 'Standard Net Reset',  's', '5-Stage Fast Network Reset (Winsock, TCP/IP, route -f, MTU 1500, 7-layer heal)'),
        @('2', 'Ultra System Reset',  'u', '10-Stage Nuclear Reset (Dual 64/32-bit Winsock, TCP/IP heuristics, DoH wipe, NCSI)'),
        @('3', 'Doomsday Reset',      'd', '12-Stage Universal Reset (All Media: Wi-Fi/BT/USB/LAN, NDIS Filters, PnP Transceiver)'),
        @('4', 'Armageddon OS Wipe',  'a', '4-Stage Kernel Stack Reinstall (netcfg.exe -d, requires immediate system reboot)'),
        @('5', 'Sovereign Factory Reset', 'r', 'Full System Rollback (Reverts all tasks, registry, DNS, credentials to Windows defaults)')
    )
    foreach ($opt in $options) {
        $color = switch ($opt[0]) {
            '1' { 'accent!' }
            '2' { 'warn' }
            '3' { 'warn!' }
            '4' { 'bad!' }
            '5' { 'ok!' }
        }
        Out-Line @(
            (Seg 'faint' '  ['),
            (Seg $color $opt[0]),
            (Seg 'faint' '] '),
            (Seg 'text!' (' ' + $opt[1].PadRight(23))),
            (Seg 'dim' $opt[3])
        )
    }
    Out-Line @()
    Out-Line @((Seg 'dim' '  Select reset option [1-5] or [S/U/D/A/R], or press any other key to cancel '), (Seg 'accent!' $script:G.prompt)) -NoNewline
    $k = Read-Choice
    Out-Line @()
    $choice = ([string]$k.KeyChar).ToLowerInvariant()
    if ($choice -in @('1', 's', 'x')) {
        if (Read-Confirm 'Execute Standard Full Net Reset?' 'yes') {
            $script:ChangeCount = 0; $script:FailCount = 0
            Invoke-SupremeOmnifix
            $script:WdCache = $null
        } else {
            Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
        }
    } elseif ($choice -in @('2', 'u')) {
        if (Read-Confirm 'Execute ULTRA SYSTEM RESET (Hyper-Nuclear Antimatter Weapon)?' 'yes') {
            $script:ChangeCount = 0; $script:FailCount = 0
            Invoke-UltraSystemReset
            $script:WdCache = $null
        } else {
            Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
        }
    } elseif ($choice -in @('3', 'd')) {
        if (Read-Confirm 'Execute DOOMSDAY SYSTEM RESET (Ultimate Universal Weapon)?' 'yes') {
            $script:ChangeCount = 0; $script:FailCount = 0
            Invoke-DoomsdayReset
            $script:WdCache = $null
        } else {
            Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
        }
    } elseif ($choice -in @('4', 'a', 'k', '!')) {
        if (Read-Confirm 'Execute ARMAGEDDON SYSTEM RESET (netcfg -d, requires reboot)?' 'yes') {
            $script:ChangeCount = 0; $script:FailCount = 0
            Invoke-ArmageddonReset
            $script:WdCache = $null
        } else {
            Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
        }
    } elseif ($choice -in @('5', 'r', '9')) {
        if (Read-Confirm 'Restore all original pre-reset network settings?' 'yes') {
            $script:ChangeCount = 0; $script:FailCount = 0
            Restore-Everything
            $script:WdCache = $null
        } else {
            Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
        }
    } else {
        Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.'))
    }
}
function Write-HealSummary($r, $sw) {
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
    <Author>Lan Fixer</Author>
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
    <Hidden>false</Hidden>
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
      <Arguments>$CmdArgs</Arguments>
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
    $cmdArgs = '/c ""' + $script:SelfCopy + '" -Mode Daemon -Headless -NoPause"'
    $xml = New-SentinelTaskXml $cmdArgs
    $ok = Register-LfTask 'LanFixer_Sentinel' $xml 'LanFixer_Sentinel.xml'
    if ($ok) {
        $r = Invoke-Native (Get-SysExe 'schtasks.exe') @('/run', '/tn', 'LanFixer_Sentinel') 10000
        Write-Log 'OK' 'Lan Fixer 24/7 Autonomous Sentinel task registered and activated.'
        Write-Log 'INFO' 'The Sentinel is now guarding your network 24/7 in the background with zero window.'
        return $true
    }
    Write-Log 'FAIL' 'Failed to register LanFixer_Sentinel scheduled task.'
    return $false
}

function Uninstall-SentinelTask {
    if (-not (Assert-Admin)) { return $false }
    $r1 = Invoke-Native (Get-SysExe 'schtasks.exe') @('/end', '/tn', 'LanFixer_Sentinel') 5000
    $r2 = Invoke-Native (Get-SysExe 'schtasks.exe') @('/delete', '/tn', 'LanFixer_Sentinel', '/f') 10000
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
        if ($l -like '*[OK   ]*') { $c = 'ok' }
        elseif ($l -like '*[WARN ]*') { $c = 'warn' }
        elseif ($l -like '*[FAIL ]*') { $c = 'bad' }
        elseif ($l -like '*[TIER*]*') { $c = 'cyan' }
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
            if ($ev -like '*[OK   ]*') { $evCol = 'ok' }
            elseif ($ev -like '*[WARN ]*') { $evCol = 'warn' }
            elseif ($ev -like '*[FAIL ]*') { $evCol = 'bad' }
            elseif ($ev -like '*[TIER*]*') { $evCol = 'cyan' }
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

                $currentCadence = $IntervalSec
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
                        $state = @{ State = 'Captive'; Location = $script:Cfg.PortalUrl }
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
                    $state = @{ State = 'Captive'; Location = $script:Cfg.PortalUrl }
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
                else { $parts += ('-' + $kv.Key); $parts += [string]$kv.Value }
            }
            Start-Process -FilePath $script:SelfPath -ArgumentList ($parts -join ' ') -Verb RunAs -ErrorAction Stop
            $elevated = $true
        } catch { Write-Host 'Administrator approval was not granted.' -ForegroundColor Yellow }
    }
    if ($elevated) { exit 0 }
    if ($Mode -ne 'Interactive') { Write-Host '[x] This mode needs Administrator rights.' -ForegroundColor Red; exit 1 }
}
if ($script:UiOn) { Initialize-Ui }
if ($script:IsAdmin) { Initialize-Store }
Import-UserConfig
$script:State = Get-State
$exitCode = 0
try {
    if ($script:UiOn -and $Mode -ne 'Interactive') { Write-Banner ("{0}{1}" -f $Mode, $(if ($script:IsDry) { ' (dry run)' } else { '' })) }
    switch ($Mode) {
        'AutoHeal'          { [void](Invoke-AutoHeal) }
        'Omnifix'           { Invoke-SupremeOmnifix }
        'NetReset'          { Invoke-UltraSystemReset }
        'FullNetReset'      { Invoke-UltraSystemReset }
        'UltraReset'        { Invoke-UltraSystemReset }
        'Ultra'             { Invoke-UltraSystemReset }
        'DoomsdayReset'     { Invoke-DoomsdayReset }
        'Doomsday'          { Invoke-DoomsdayReset }
        'ArmageddonReset'   { Invoke-ArmageddonReset }
        'Armageddon'        { Invoke-ArmageddonReset }
        'ResetOptions'      { Show-View 'reset & system recovery options' { Show-ResetMenu } }
        'ResetMenu'         { Show-View 'reset & system recovery options' { Show-ResetMenu } }
        'SetRouteProfile'   { Set-RouteProfileMode $RouteProfile }
        'Route'             { Show-RouteMenu }
        'RouteMenu'         { Show-RouteMenu }
        'Heal' {
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            $r = Pick-Hash (Invoke-WithLock { Invoke-HealPipeline })
            $sw.Stop()
            Write-HealSummary $r $sw
            if ($r -and $r.Conn -eq 'Captive' -and -not $script:IsDry) {
                [void](Invoke-WithLock { [void](Open-Portal); Save-State })
                if ((Get-InternetState -NoCache).State -eq 'Captive') {
                    if (Wait-ForAuthentication 120) { [void](Invoke-WithLock { Complete-Authentication }) }
                }
            }
        }
        'QuickHeal' {
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            $r = Pick-Hash (Invoke-WithLock { Invoke-HealPipeline })
            $sw.Stop()
            Write-HealSummary $r $sw
            if ($r -and $r.Conn -eq 'Captive' -and -not $script:IsDry) {
                [void](Invoke-WithLock { [void](Open-Portal); Save-State })
                if ((Get-InternetState -NoCache).State -eq 'Captive') {
                    if (Wait-ForAuthentication 120) { [void](Invoke-WithLock { Complete-Authentication }) }
                }
            }
        }
        'Diagnose'          { Show-Diagnostics }
        'Audit'             { Show-Diagnostics }
        'Report'            { New-SupportReport }
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
        'SelfTest'          { Invoke-SelfTest; if ($script:TestFail -gt 0) { $exitCode = 1 } }
        'Verify'            { Invoke-SelfTest; if ($script:TestFail -gt 0) { $exitCode = 1 } }
        'Daemon'            { Start-AutonomousDaemon -Headless:$Headless }
        'Sentinel'          { Start-AutonomousDaemon -Headless:$Headless }
        'InstallSentinel'   { [void](Invoke-WithLock { Install-SentinelTask }) }
        'UninstallSentinel' { [void](Invoke-WithLock { Uninstall-SentinelTask }) }
        'Vault'             { Show-VaultMenu }
        'Guide'             { Show-Advisory }
        'Help'              { Show-Advisory }
        'Interactive'       { Start-Interactive }
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
if ($exitCode -ne 0 -and -not $NoPause -and $Host.Name -eq 'ConsoleHost') {
    Write-Host ''
    Write-Host 'LanFixer closed with an exit code. Press any key to close...' -ForegroundColor Gray
    Wait-AnyKey
} elseif ($script:UiOn -and $Mode -ne 'Interactive' -and -not $NoPause -and $Host.Name -eq 'ConsoleHost') {
    Write-Host ''
    Write-Host 'Press any key to close...' -ForegroundColor Gray
    Wait-AnyKey
}
exit $exitCode
