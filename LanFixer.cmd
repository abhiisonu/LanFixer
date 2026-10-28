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
    Lan Fixer 4.9.0 - Supreme self-healing Ethernet stabilizer for campus/hostel LANs (Windows 10/11, Ethernet only).
    Author: A.S.
.DESCRIPTION
    Single file, ASCII only. Run it normally for the control center, or use -Mode:
      Interactive | Heal | AutoHeal | Diagnose | QuickProbe | FlushCache | InstallWatchdog |
      UninstallWatchdog | ResetFactory | LaunchPortal | SetDnsProfile | SelfTest | Report
    Add -DryRun to see exactly what would change without changing anything.
    Every change is snapshotted first, so ResetFactory restores YOUR original values.
.NOTES
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
    [ValidateSet('Interactive','Heal','AutoHeal','Omnifix','FullNetReset','Diagnose','QuickProbe','FlushCache','InstallWatchdog','UninstallWatchdog','InstallShield','UninstallShield','ResetFactory','LaunchPortal','SetDnsProfile','SetRouteProfile','SelfTest','Report')]
    [string]$Mode = 'Interactive',
    [ValidateSet('Adaptive','DHCP','Hybrid','Cloudflare','ResetDHCP')]
    [string]$DnsProfile = 'Adaptive',
    [ValidateSet('Adaptive','Ethernet','Wifi','Windows')]
    [string]$RouteProfile = 'Adaptive',
    [switch]$DryRun,
    [switch]$NoPause,
    [Parameter(DontShow)][switch]$LfElevated
)

$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
try { Add-Type -AssemblyName System.Security -ErrorAction SilentlyContinue } catch {}

# ==============================================================================
# CONFIG (edit here, nowhere else)
# ==============================================================================
$script:Version = '4.9.0'
$script:Sys32   = Join-Path $env:SystemRoot 'System32'
$script:SelfPath = if ($env:LANFIXER_SELF) { $env:LANFIXER_SELF } elseif ($PSCommandPath) { $PSCommandPath } else { '' }
$script:IsDry   = [bool]$DryRun
$script:UiOn    = ($Mode -ne 'AutoHeal')
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
$script:VirtRegex = 'Virtual|Hyper-V|VMware|VirtualBox|\bTAP\b|\bTUN\b|\bWSL\b|Bluetooth|Tailscale|ZeroTier|WireGuard|Wintun|RNDIS|Remote NDIS|Loopback|Npcap|OpenVPN|AnyConnect|Fortinet|PANGP'
$script:PowerKeywords = @('*EEE','EEE','EEELinkAdvertisement','EnableGreenEthernet','GreenEthernet','PowerSavingMode','AutoPowerSaveModeEnabled','ULPMode','EnableSavePowerNow','ReduceSpeedOnPowerDown','AdvancedEEE','GigaLite','*SelectiveSuspend','BatteryModeLinkSpeed','EnableBatteryModeLinkSpeed','EnableExtraPowerSaving','EnableAdaptiveLinkCap','*IdleRestriction','IdleRestriction')
$script:StoreReady  = $false
$script:StoreSecure = $false
$script:State       = @{}
$script:EnvCache    = @{}
$script:ConnCache   = $null
$script:ChangeCount = 0
$script:FailCount   = 0
$script:Mutex          = $null
$script:HasMutex       = $false
$script:LockDepth      = 0
$script:CancelHandler  = $null

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
    param([string]$Description, [scriptblock]$Action)
    if ($script:IsDry) { Write-Log 'DRY' "Would: $Description"; return $true }
    $ErrorActionPreference = 'Stop'
    try {
        & $Action | Out-Null
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
            $res.TimedOut = $true
            return $res
        }
        $p.WaitForExit()
        $res.ExitCode = $p.ExitCode
        $res.Output = ([string]$so.Result + [string]$se.Result)
    } catch { $res.Output = $_.Exception.Message }
    return $res
}
function Get-SysExe([string]$Name) { return (Join-Path $script:Sys32 $Name) }

# ---- state (Clixml, written atomically, lives in the ACL-locked store) --------
function Get-State {
    $s = $null
    try { if (Test-Path -LiteralPath $script:StateFile) { $s = Import-Clixml -LiteralPath $script:StateFile -ErrorAction Stop } } catch { $s = $null }
    if ($s -isnot [hashtable]) { $s = @{} }
    foreach ($k in 'Snapshot','Env','Dns','Arp','Times','Misc') { if ($s[$k] -isnot [hashtable]) { $s[$k] = @{} } }
    return $s
}
function Save-State {
    if (-not $script:StoreReady -or $script:IsDry) { return }
    # Never write without the lock: a long-idle menu window would otherwise overwrite newer watchdog state
    # (including the snapshot of your ORIGINAL settings) with its stale in-memory copy when it exits.
    if (-not $script:IsAdmin -or -not $script:HasMutex) { return }   # non-admin: the store is read-only for you anyway
    try {
        $tmp = "$($script:StateFile).tmp"
        $script:State | Export-Clixml -LiteralPath $tmp -Depth 8 -Force -ErrorAction Stop
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
    if ((Test-Path -LiteralPath $script:VaultFile) -and -not (Test-VaultAcl $script:VaultFile)) {
        if (Protect-VaultFile $script:VaultFile) { Write-Log 'WARN' 'The vault file had loose permissions; they were tightened to Administrators/SYSTEM only.' }
    }
}
function Get-FileSha256([string]$Path) {
    try {
        $stream = [System.IO.File]::OpenRead($Path)
        $sha = [System.Security.Cryptography.SHA256]::Create()
        $hash = $sha.ComputeHash($stream)
        $stream.Close(); $stream.Dispose(); $sha.Dispose()
        return ([System.BitConverter]::ToString($hash) -replace '-').ToUpperInvariant()
    } catch {
        try { return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToUpperInvariant() } catch { return $null }
    }
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
                    $h1 = Get-FileSha256 $script:SelfCopy
                    $h2 = Get-FileSha256 $script:SelfPath
                    if ($h1 -and $h2 -and ($h1 -eq $h2)) { $need = $false }
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
# LOCKING (abandoned-mutex safe, because StopExisting can kill a holder)
# ==============================================================================
function Enter-Lock([int]$TimeoutMs = 1000) {
    try {
        if (-not $script:Mutex) { $script:Mutex = New-Object System.Threading.Mutex($false, 'Global\LanFixer_Lock') }
        if ($script:LockDepth -gt 0) {
            $script:LockDepth++
            $script:HasMutex = $true
            return $true
        }
        $got = $false
        try { $got = $script:Mutex.WaitOne($TimeoutMs) } catch [System.Threading.AbandonedMutexException] { $got = $true }
        if ($got) {
            $script:LockDepth = 1
            $script:HasMutex = $true
            $memLearned = if ($script:State -is [hashtable] -and $script:State.Misc -is [hashtable]) { $script:State.Misc['LearnedDhcp'] } else { $null }
            $memEnv = if ($script:State -is [hashtable] -and $script:State.Env -is [hashtable]) { $script:State.Env.Clone() } else { @{} }
            $script:State = Get-State
            if ($memLearned -and -not $script:State.Misc['LearnedDhcp']) { $script:State.Misc['LearnedDhcp'] = $memLearned }
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
    if ($script:LockDepth -gt 0) {
        $script:LockDepth--
        if ($script:LockDepth -eq 0) {
            if ($script:Mutex) { try { $script:Mutex.ReleaseMutex() } catch {} }
            $script:HasMutex = $false
        }
    }
}
function Invoke-WithLock {
    param([scriptblock]$Block, [int]$WaitMs = 20000)
    if (-not $script:IsAdmin) { return (& $Block) }   # read-only/limited mode: no shared lock needed (and a standard user cannot open it)
    if (-not (Enter-Lock $WaitMs)) { Write-Log 'WARN' 'Another Lan Fixer operation is running. Try again in a moment.'; return $null }
    try { return (& $Block) } finally { Exit-Lock }
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
function Test-TcpPort([string]$Address, [int]$Port, [int]$TimeoutMs = 800) {
    $c = New-Object System.Net.Sockets.TcpClient
    try {
        $iar = $c.BeginConnect($Address, $Port, $null, $null)
        if ($iar.AsyncWaitHandle.WaitOne($TimeoutMs, $false) -and $c.Connected) { $c.EndConnect($iar); return $true }
        return $false
    } catch { return $false } finally { try { $c.Close() } catch {} }
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
    foreach ($s in @($pending.Keys)) { try { $pending[$s].Close() } catch {} }
    return $out
}
# DNS lookup with a hard time limit (HttpWebRequest/GetHostAddresses alone can block for many seconds).
# $SourceIp pins the lookup to ONE link: while a second uplink is up, the system-wide resolver answers from ITS DNS,
# so a dead Ethernet resolver looks healthy. In that case only this adapter's own resolvers may answer; when none
# does, the truthful answer is "no DNS on this link" ($null) and Invoke-HttpProbe reports DnsFail for that adapter.
function Resolve-HostBounded([string]$Name, [int]$TimeoutMs = 2500, [string]$SourceIp = '') {
    if (-not $Name) { return $null }
    $cleanName = $Name.Trim().TrimEnd('.')
    if (-not $cleanName) { return $null }
    if ($script:Cfg.PortalHost -and ($cleanName.ToLower() -eq ([string]$script:Cfg.PortalHost).TrimEnd('.').ToLower()) -and $script:Cfg.PortalIp) {
        return [string]$script:Cfg.PortalIp
    }
    if ($SourceIp -and (Test-OtherUplinkActive)) {
        $bounded = @(Get-ScopedDnsAnswers $cleanName $SourceIp 1200)
        if ($bounded.Count -eq 0) { return $null }
        return [string]$bounded[0]
    }
    try {
        $ar = [System.Net.Dns]::BeginGetHostAddresses($cleanName, $null, $null)
        $ok = $ar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)   # the runtime owns this handle: closing it early breaks later connects
        if ($ok) {
            $ips = [System.Net.Dns]::EndGetHostAddresses($ar)
            foreach ($ip in $ips) { if ($ip.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork) { return $ip.ToString() } }
        }
    } catch {}
    try {
        $dnsRec = Resolve-DnsName -Name $cleanName -Type A -QuickTimeout -DnsOnly -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($dnsRec -and $dnsRec.IPAddress) { return [string]$dnsRec.IPAddress }
    } catch {}
    return $null
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
    if ($cut -ge 0) {
        $head = $Raw.Substring(0, $cut)
        $body = $Raw.Substring($cut + $skip)
        if ($body.Length -gt 128) { $body = $body.Substring(0, 128) }
        $r.Body = $body
    }
    $lm = [regex]::Match($head, '(?im)^Location:[ \t]*(\S+)')
    if ($lm.Success) { $r.Location = $lm.Groups[1].Value }
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
                if (($txt -notmatch '^HTTP/\d\.\d\s+200') -or (($total - $he - 4) -ge 40)) { break }
            }
        }
        if ($total -eq 0) { $r.Error = 'NoResponse'; return $r }
        $p = ConvertFrom-HttpResponse ([System.Text.Encoding]::ASCII.GetString($buf, 0, $total))
        $r.Code = $p.Code; $r.Body = $p.Body; $r.Location = $p.Location
        if ($r.Code -eq 0) { $r.Error = 'BadResponse' }
    } catch { $r.Error = $_.Exception.Message }
    finally { try { $sock.Close() } catch {} }
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

function Remove-CampusHostRoutes([int]$InterfaceIndex = 0) {
    if ($script:IsDry) { return }
    foreach ($hip in @($script:Cfg.PortalIp, $script:Cfg.CampusDns) | Where-Object { $_ }) {
        if ($InterfaceIndex -gt 0) {
            Remove-NetRoute -InterfaceIndex $InterfaceIndex -DestinationPrefix "$hip/32" -PolicyStore ActiveStore -Confirm:$false -ErrorAction SilentlyContinue
            Remove-NetRoute -InterfaceIndex $InterfaceIndex -DestinationPrefix "$hip/32" -PolicyStore PersistentStore -Confirm:$false -ErrorAction SilentlyContinue
        } else {
            Remove-NetRoute -DestinationPrefix "$hip/32" -PolicyStore ActiveStore -Confirm:$false -ErrorAction SilentlyContinue
            Remove-NetRoute -DestinationPrefix "$hip/32" -PolicyStore PersistentStore -Confirm:$false -ErrorAction SilentlyContinue
        }
    }
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
            if (-not $ad) { if (-not $script:IsDry) { $orig.Remove($k) }; continue }
            $af = [string]$rec.Af
            $ok = $false
            if ([string]$rec.Auto -eq 'Enabled') {
                $ok = Invoke-Change ('{0}: {1} {2} metric back to automatic' -f $Why, $rec.Alias, $af) { Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily $af -AutomaticMetric Enabled -ErrorAction Stop }
            } else {
                $mv = [int]$rec.Metric
                $ok = Invoke-Change ('{0}: {1} {2} metric back to {3}' -f $Why, $rec.Alias, $af, $mv) { Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily $af -InterfaceMetric $mv -ErrorAction Stop }
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
    if ($CurrentMtu -lt 1500) { return @{ Action = 'skip'; Value = 0 } }     # already lowered (by us or by you)
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
        if ([System.Net.IPAddress]::TryParse($hostName, [ref]$tmp)) { $ip = $hostName } else { $ip = Resolve-HostBounded $hostName 2500 }
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
                        $headerEndIdx = $ci + 4
                        $hStr = [System.Text.Encoding]::ASCII.GetString($curBytes, 0, $ci)
                        $mCl = [regex]::Match($hStr, '(?i)Content-Length:\s*(\d+)')
                        if ($mCl.Success) { $contentLength = [int]$mCl.Groups[1].Value }
                        if ($hStr -match '(?i)Transfer-Encoding:\s*chunked') { $isChunked = $true }
                        break
                    }
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
        if ($ssl) { try { $ssl.Dispose() } catch {} }
        if ($sock) { try { $sock.Close() } catch {} }
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
            elseif ($type -eq 'submit') { if (-not $fields.Contains($name)) { $fields[$name] = $val } }
            elseif ($type -eq '' -or $type -eq 'text' -or $type -eq 'email' -or $type -eq 'tel') {
                $candidates += @{ Name = $name; Id = $id }
            }
        }
        if (-not $pass) { continue }
        foreach ($c in $candidates) {
            $comb = ($c.Name + ' ' + $c.Id)
            if ($comb -match '(?i)user|login|email|auth|account|id') { $user = $c.Name; break }
        }
        if (-not $user -and $candidates.Count -gt 0) { $user = $candidates[0].Name }
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
            elseif ($type -eq 'submit') { if (-not $fields.Contains($name)) { $fields[$name] = $val } }
            elseif ($type -eq '' -or $type -eq 'text' -or $type -eq 'email' -or $type -eq 'tel') { $candidates += @{ Name = $name; Id = $id } }
        }
        if ($pass) {
            foreach ($c in $candidates) { if (($c.Name + ' ' + $c.Id) -match '(?i)user|login|email|auth|account|id') { $user = $c.Name; break } }
            if (-not $user -and $candidates.Count -gt 0) { $user = $candidates[0].Name }
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

# Host routes that keep the campus portal and the campus resolver reachable over the UNAUTHENTICATED cable while
# every other destination keeps using the working secondary uplink (Wi-Fi / Bluetooth / USB tethering).
# Called by the metric engine, by the vault's certificate/test actions and by the portal client, so no code path can
# reach 10.114.0.5 over the mobile hotspot and time out.
function Ensure-CampusPortalPath([uri]$RedirectUri = $null) {
    if (-not $script:IsAdmin -or $script:IsDry) { return }
    $targets = @($script:Cfg.PortalIp, $script:Cfg.CampusDns)
    if ($RedirectUri -and $RedirectUri.Host) {
        $hostIp = $null
        if ([System.Net.IPAddress]::TryParse([string]$RedirectUri.Host, [ref]$hostIp) -and ($hostIp.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork)) {
            # Only a private/CGNAT/known-gateway literal: never add a host route for an arbitrary public address.
            if (Test-AllowedPortalIp ([string]$RedirectUri.Host)) { $targets += [string]$RedirectUri.Host }
        }
    }
    $targets = @($targets | Where-Object { $_ } | Select-Object -Unique)
    if ($targets.Count -eq 0) { return }
    foreach ($a in @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })) {
        $e = Get-AdapterEnvironment $a -UseCache
        if ($e.Env -ne 'Campus') { continue }
        $gw4 = @(Get-GatewaysV4 $a) | Select-Object -First 1
        if (-not $gw4) { continue }
        foreach ($hip in $targets) {
            $have = @(Get-NetRoute -InterfaceIndex $a.ifIndex -DestinationPrefix "$hip/32" -PolicyStore ActiveStore -ErrorAction SilentlyContinue | Select-Object -First 1)
            if ($have -and ([string]$have[0].NextHop -eq [string]$gw4)) { continue }
            # A route left pointing at a previous gateway (VRRP/HSRP failover) is worse than no route at all.
            if ($have) { Remove-NetRoute -InterfaceIndex $a.ifIndex -DestinationPrefix "$hip/32" -PolicyStore ActiveStore -Confirm:$false -ErrorAction SilentlyContinue }
            New-NetRoute -InterfaceIndex $a.ifIndex -DestinationPrefix "$hip/32" -NextHop $gw4 -RouteMetric 5 -PolicyStore ActiveStore -ErrorAction SilentlyContinue | Out-Null
        }
    }
}

# Pinning: only a certificate YOU looked at and approved is ever accepted when Windows does not trust it.
function Get-PortalCertInfo([uri]$TargetUri = $null) {
    $u = $TargetUri
    if (-not $u) {
        try { $u = [uri][string]$script:Cfg.PortalUrl } catch { return @{ Ok = $false; Error = 'BadPortalUrl' } }
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
[System.Runtime.InteropServices.DllImport("kernel32.dll")] public static extern System.IntPtr GetStdHandle(int h);
[System.Runtime.InteropServices.DllImport("kernel32.dll")] public static extern bool GetConsoleMode(System.IntPtr h, out uint m);
[System.Runtime.InteropServices.DllImport("kernel32.dll")] public static extern bool SetConsoleMode(System.IntPtr h, uint m);
'@
        }
        $h = [LanFixer.Native]::GetStdHandle(-11)
        [uint32]$m = 0
        if (-not [LanFixer.Native]::GetConsoleMode($h, [ref]$m)) { return $false }
        if (($m -band 4) -ne 0) { return $true }
        return [bool][LanFixer.Native]::SetConsoleMode($h, ($m -bor 4))
    } catch { return $false }
}

function Set-ConsoleQuickEdit([bool]$Enable) {
    # Only the legacy console has the "a click freezes the output" QuickEdit behaviour. Windows Terminal does not,
    # so never compile the native helper there (less startup work, less for antivirus to look at).
    if ($env:WT_SESSION -or (Test-InputRedirected)) { return }
    try {
        if (-not ('LanFixer.Native' -as [type])) { [void](Enable-VtMode) }
        if (-not ('LanFixer.Native' -as [type])) { return }
        $h = [LanFixer.Native]::GetStdHandle(-10)
        if ($h -eq [System.IntPtr]::Zero -or $h.ToInt64() -eq -1) { return }
        [uint32]$m = 0
        if (-not [LanFixer.Native]::GetConsoleMode($h, [ref]$m)) { return }
        if (-not $Enable) {
            $script:SavedInputMode = $m
            [void][LanFixer.Native]::SetConsoleMode($h, (($m -band (-bnot 0x0040)) -bor 0x0080))
        } elseif ($null -ne $script:SavedInputMode) {
            [void][LanFixer.Native]::SetConsoleMode($h, $script:SavedInputMode)
            $script:SavedInputMode = $null
        }
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
    Set-ConsoleQuickEdit $false
    Clear-InputBuffer
    if ($script:Ui.Vt -and $env:LANFIXER_NOALT -ne '1') { [Console]::Write($script:Esc + '[?1049h'); $script:Ui.Alt = $true }
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
    if ($p.Gw -ne $Gw) { $p.Gw = $Gw; $p.Hist.Clear(); $p.Task = $null; $script:LiveGwRtt = $null }
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
    if (-not $p.Task -and (((Get-Date) - $p.Last).TotalMilliseconds -ge 1200)) {
        if (-not $p.Ping) { $p.Ping = New-Object System.Net.NetworkInformation.Ping }
        try { $p.Task = $p.Ping.SendPingAsync($Gw, 900); $p.Last = Get-Date } catch { try { $p.Ping.Dispose() } catch {}; $p.Ping = $null; $p.Task = $null }
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
    }
}

# Hop model for the stepper: label, value, state per hop.
function Get-HopRows($t, $adv) {
    $st = $adv.Hops
    $curRtt = if ($null -ne $script:LiveGwRtt) { $script:LiveGwRtt } else { $t.GwRtt }
    $gw = 'None'
    if ($t.GwIp) { $gw = $t.GwIp; if ($null -ne $curRtt) { $gw += (' {0}ms' -f $curRtt) } elseif ($t.GwAlive) { $gw += ' arp' } }
    $link = 'Down'; if ($t.LinkUp) { $link = $t.Speed }
    $ip = 'None'; if ($t.Ip) { $ip = $t.Ip }
    $dns = '-'; if ($t.DnsPrimary) { $dns = $t.DnsPrimary }
    $net = '-'
    switch ($t.Problem) { { $_ -eq 'Healthy' -or $_ -eq 'Online' } { $net = 'Reachable' } 'Captive' { $net = 'Sign-In' } 'Offline' { $net = 'Blocked' } }
    return @(
        @{ Label = 'Link'; Value = $link; State = $st[0] },
        @{ Label = 'Address'; Value = $ip; State = $st[1] },
        @{ Label = 'Gateway'; Value = $gw; State = $st[2] },
        @{ Label = 'DNS'; Value = $dns; State = $st[3] },
        @{ Label = 'Internet'; Value = $net; State = $st[4] })
}

function Get-StepperLines($Rows, [int]$Width) {
    $n = $Rows.Count
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
    if ($t.LinkUp) { $right = ('Ethernet ' + $script:G.mid + ' ' + $t.Speed) } elseif ($t.Problem) { $right = 'Ethernet' }
    $heroL = @((Seg 'faint' '  ['), (Seg ($adv.Role + '!') (' ' + $script:G.dot + ' ' + $adv.Word.ToUpper() + ' ')), (Seg 'faint' ']'))
    $hp = ($w + 2) - (Get-SegsLength $heroL) - $right.Length
    [void]$L.Add(@($heroL + (Seg 'text' (' ' * [Math]::Max(2, $hp))) + (Seg 'dim' $right)))
    # path
    foreach ($ln in @(Get-StepperLines (Get-HopRows $t $adv) $w)) { [void]$L.Add($ln) }
    [void]$L.Add(@())
    $pulseIdx = $L.Count
    [void]$L.Add((Get-PulseSegs $t ([Math]::Max(4, [Math]::Min(36, $w - 54)))))
    [void]$L.Add(@())
    # facts
    $cw = [int][Math]::Floor(($w - 4) / 2)
    $net = '-'; if ($t.Env) { $net = ($t.Env + ' ' + $script:G.mid + ' Score ' + $t.EnvScore); if ($t.Sticky) { $net += ' (Remembered)' } }
    $dnsv = '-'; if ($t.DnsProfile) { $dnsv = $t.DnsProfile; if ($t.DnsPrimary) { $dnsv += (' ' + $script:G.mid + ' ' + $t.DnsPrimary) } }
    $rout = if ($t.Routing) {
        switch ($t.Routing.ToLower()) {
            'ethernet first'  { 'Ethernet First' }
            'wi-fi protected' { 'Wi-Fi Protected' }
            'automatic'       { if ($t.RouteProfile -and $t.RouteProfile -ne 'Adaptive') { "Auto ($($t.RouteProfile))" } else { 'Automatic' } }
            default           { $t.Routing }
        }
    } else { 'Automatic' }
    $curRtt = if ($null -ne $script:LiveGwRtt) { $script:LiveGwRtt } else { $t.GwRtt }
    $gwVal = if ($t.GwIp) { if ($null -ne $curRtt) { '{0} ({1} ms)' -f $t.GwIp, $curRtt } elseif ($t.GwAlive) { '{0} (ARP)' -f $t.GwIp } else { $t.GwIp } } else { '-' }
    $facts = @(
        @(@('Adapter', $t.Nic), @('Network', $net)),
        @(@('Lease', $t.Ip), @('DNS', $dnsv)),
        @(@('Gateway', $gwVal), @('Routing', $rout)))
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
        [void]$L.Add(@((Seg $(if ($adv.Key -eq '1') { 'ok!' } else { 'text' }) ('  [1] Smart 7-Layer Heal'.PadRight($col1W + 2))), (Seg 'text' '[3] DNS Profile Engine')))
        [void]$L.Add(@((Seg $(if ($adv.Key -eq '2') { 'ok!' } else { 'text' }) ('  [2] Arm Watchdog Guard'.PadRight($col1W + 2))), (Seg 'text' '[M] Routing Priority Engine')))
        [void]$L.Add(@((Seg $(if ($adv.Key -eq 'a') { 'ok!' } else { 'text' }) ('  [A] Portal Login Vault'.PadRight($col1W + 2))), (Seg 'text' '[4] Live Latency Probe')))
        [void]$L.Add(@((Seg $(if ($adv.Key -eq '7') { 'ok!' } else { 'text' }) ('  [7] Open Portal Page'.PadRight($col1W + 2))), (Seg 'text' '[5] Flush DNS & ARP Caches')))
        [void]$L.Add(@((Seg $(if ($adv.Key -eq 'g') { 'ok!' } else { 'text' }) ('  [G] Headless Auto-Login'.PadRight($col1W + 2))), (Seg 'text' '[6] System Diagnostics Audit')))
        if ($uiH -eq 0 -or $uiH -ge 32) { [void]$L.Add(@()) }
        [void]$L.Add(@((Seg 'accent!' ('  PREVIEW & REPORTS'.PadRight($col1W + 2))), (Seg 'accent!' 'SYSTEM & RECOVERY')))
        [void]$L.Add(@((Seg 'text' ('  [T] Dry-Run Simulation'.PadRight($col1W + 2))), (Seg 'text' '[8] Disarm Watchdog')))
        [void]$L.Add(@((Seg 'text' ('  [R] Export Support Report'.PadRight($col1W + 2))), (Seg 'text' '[9] Factory Reset')))
        [void]$L.Add(@((Seg 'text' ('  [S] Run Self-Test Suite'.PadRight($col1W + 2))), (Seg 'text' '[0] Guide')))
        [void]$L.Add(@((Seg $(if ($adv.Key -eq 'x') { 'ok!' } else { 'accent!' }) ('  [X] Full Net Reset'.PadRight($col1W + 2))), (Seg 'dim' '[Q] Quit')))
        if ($t.ArpPending) { [void]$L.Add(@((Seg 'warn!' ('  [K] Approve Gateway MAC Change'.PadRight($col1W + 2))), (Seg 'warn' 'Router MAC changed; review to lock ARP'))) }
    } else {
        $legend = @(@('1', 'Heal'), @('X', 'NetReset'), @('2', 'Guard'), @('A', 'Vault'), @('7', 'Portal'), @('G', 'Login'), @('3', 'DNS'), @('M', 'Route'), @('4', 'Probe'), @('5', 'Flush'), @('6', 'Audit'), @('T', 'Test'), @('R', 'Report'), @('S', 'Verify'), @('8', 'Disarm'), @('9', 'Reset'), @('0', 'Guide'), @('Q', 'Quit'))
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
    $up = $f.Rows - $f.Model.PulseIdx
    $sparkWidth = [Math]::Max(4, [Math]::Min(36, $f.Model.Width - 54))
    $segs = Get-PulseSegs $t $sparkWidth
    $e = $script:Esc
    [Console]::Write($e + '[' + $up + 'A' + "`r" + (ConvertTo-AnsiString $segs) + $e + '[K' + $e + '[' + $up + 'B' + $e + '[5G')
    return $true
}

# ==============================================================================
# VIEWS AND MENUS
# ==============================================================================
function Show-View([string]$Title, [scriptblock]$Body, [switch]$NoWait) {
    Clear-Screen
    Show-Cursor $true
    Write-Banner $Title
    try { & $Body } catch { Write-Log 'FAIL' ('Operation failed: ' + $_.Exception.Message) }
    if (-not $NoWait) {
        Out-Line @()
        Out-Line @((Seg 'dim' '  Press any key to return to dashboard...'))
        Wait-AnyKey
    }
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
    Out-Line @((Seg 'dim' '  * Plug in Ethernet cable  '), (Seg 'faint' '-> '), (Seg 'ok!' '[1] Smart 7-Layer Heal '), (Seg 'dim' '(repairs adapter, IP lease & routes)'))
    Out-Line @()
    Out-Line @((Seg 'accent!' '  COMMON SYMPTOMS & 1-TOUCH FIXES'.PadRight(50)), (Seg 'accent!' 'ACTION'))
    Out-Line @((Seg 'faint' ('  ' + ($script:G.rule * $w))))
    $matrix = @(
        # 1. Connection & Initial Setup
        @('Cable in, no IP / APIPA (169.254.x.x)',       '1', 'Smart 7-Layer Heal'),
        @('Campus portal login required for internet',   'A', 'Portal Login Vault'),
        @('Auto-repair on cable plug or system wake',    '2', 'Arm Background Watchdog'),
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
        @('Preview repairs safely without changes',      'T', 'Dry-Run Simulation'),
        @('Verify system cmdlets & security integrity',  'S', 'Run Self-Test Suite'),
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
        Out-Line @((Seg 'accent' '  [S]'), (Seg 'text' ' Save / Update   '), (Seg 'accent' '[T]'), (Seg 'text' ' Test Login   '), (Seg 'accent' '[P]'), (Seg 'text' ' Certificate Pinning   '), (Seg 'accent' '[C]'), (Seg 'text' ' Clear Credentials'))
        Out-Line @((Seg 'dim' '  Press any other key to return '), (Seg 'accent!' $script:G.prompt)) -NoNewline
        $k = Read-Choice
        Out-Line @()
        Out-Line @()
        switch (([string]$k.KeyChar).ToLower()) {
            's' {
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
            't' {
                if (-not (Assert-Admin)) { Out-Line @(); Out-Line @((Seg 'dim' '  press any key')); Wait-AnyKey; continue }
                [void](Invoke-WithLock { [void](Invoke-HeadlessPortalLogin -Manual); Save-State })
                Out-Line @(); Out-Line @((Seg 'dim' '  press any key')); Wait-AnyKey
            }
            'p' {
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
            'c' {
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

function Start-Repair([string]$Title = 'repair') {
    Show-View $Title {
        if (-not (Assert-Admin)) { return }
        $script:ChangeCount = 0; $script:FailCount = 0
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $r = Pick-Hash (Invoke-WithLock { Invoke-HealPipeline })
        $sw.Stop()
        Write-HealSummary $r $sw
        if ($r -and $r.Conn -eq 'Captive') {
            [void](Invoke-WithLock { [void](Open-Portal); Save-State })
            if ((Get-InternetState -NoCache).State -eq 'Captive') {
                Out-Line @((Seg 'dim' '  Sign in on the page that opened; the fast DNS path is applied for you afterwards.'))
                if (Wait-ForAuthentication 180) { [void](Invoke-WithLock { Complete-Authentication }); Write-Log 'OK' 'Signed in. Post-login DNS applied.' }
            }
        }
    }
}

function Invoke-DashboardKey([string]$Key, $adv) {
    $aliases = @{ w = '2'; n = '3'; p = '4'; f = '5'; c = '5'; d = '6'; o = '7'; u = '8'; v = 'a'; l = 'g'; h = '0'; '?' = '0' }
    if ($aliases.ContainsKey($Key)) { $Key = $aliases[$Key] }
    switch ($Key) {
        '0' { Show-Advisory }
        '1' { Start-Repair 'repair' }
        'm' { Show-View 'routing priority' { Show-RouteMenu } -NoWait }
        'x' {
            Show-View 'full net reset (emergency recovery)' {
                if (-not (Assert-Admin)) { return }
                Out-Line @((Seg 'warn' '  NOTICE: Full Net Reset performs comprehensive network stack recovery:'))
                Out-Wrapped 'faint' $script:G.mid 'text' 'Rescan PnP hardware bus, clear orphaned proxies, and clean WFP filters' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Normalize route metrics, reset MTU to standard 1500, and set routing to Adaptive' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Execute 7-layer heal pipeline, flush DNS/ARP caches, and clear NetBIOS' 4
                Out-Wrapped 'faint' $script:G.mid 'text' 'Synchronize DHCP Client and Network Location Awareness (NlaSvc) services' 4
                Out-Line @()
                if (Read-Confirm 'Proceed with Full Net Reset?' 'yes') {
                    $script:ChangeCount = 0; $script:FailCount = 0
                    Invoke-SupremeOmnifix
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
                        [void](Invoke-WithLock { [void](Open-Portal); Save-State })
                        if ((Get-InternetState -NoCache).State -eq 'Captive') {
                            Out-Line @((Seg 'dim' '  Sign in on the page that opened; the fast DNS path is applied for you afterwards.'))
                            if (Wait-ForAuthentication 180) { [void](Invoke-WithLock { Complete-Authentication }); Write-Log 'OK' 'Signed in. Post-login DNS applied.' }
                        }
                    }
                }
            }
        }
        '3' { Show-View 'dns profile' { Show-DnsMenu } -NoWait }
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
                    Start-Process -FilePath (Join-Path $script:Sys32 'cmd.exe') -ArgumentList ('/c ""' + $script:SelfPath + '" -LfElevated"') -Verb RunAs -ErrorAction Stop
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
                        if ($inet.State -eq 'Offline' -and (Test-TcpPort $script:Cfg.PortalIp $script:Cfg.PortalPort 900)) {
                            $inet = @{ State = 'Captive'; Location = $script:Cfg.PortalUrl; Via = 'link' }
                        } else {
                            Write-Log 'WARN' ("Link state is '{0}' (not behind captive portal). Run [1] Smart 7-Layer Heal first." -f $inet.State)
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
    $r = Invoke-Native (Get-SysExe 'powercfg.exe') @(('/get{0}valueindex' -f $Mode), $Scheme, $script:UsbSub, $script:UsbSet) 5000
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
    [void](Invoke-Native $pcfg @('/s', [string]$Rec.Scheme) 5000)
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
    $ckey = ('{0}|{1}' -f $SourceIp, $explicit)
    if (-not $NoCache -and $script:ConnCache -and $script:ConnCache.Key -eq $ckey -and (((Get-Date) - $script:ConnCache.Time).TotalSeconds -lt 6)) { return $script:ConnCache.Result }
    $none = @{ Code = 0; Body = ''; Location = ''; Error = '' }
    $p1 = Invoke-HttpProbe 'connectivitycheck.gstatic.com' '/generate_204' 2500 $SourceIp
    $p2 = $none
    if ($p1.Code -ne 204) { $p2 = Invoke-HttpProbe 'www.msftconnecttest.com' '/connecttest.txt' 2500 $SourceIp }
    $state = Get-ProbeVerdict $p1 $p2
    $via = 'link'
    if ((Test-AllowSystemFallback $explicit $state (Test-OtherUplinkActive))) {
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
    if ($state -eq 'Captive') { if ($p1.Location) { $loc = [string]$p1.Location } elseif ($p2.Location) { $loc = [string]$p2.Location } }
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
        if ((Test-TcpPort $Gw 80 400) -or (Test-TcpPort $Gw 443 400) -or (Test-TcpPort $script:Cfg.PortalIp $script:Cfg.PortalPort 500) -or ($null -ne (Test-Ping $script:Cfg.CampusDns 500))) {
            return @{ Alive = $true; Rtt = $null; Via = 'arp' }
        }
        return @{ Alive = $false; Rtt = $null; Via = '' }
    }
    if ($script:IsAdmin -and $ex -and [string]$ex.State -ne 'Permanent') {
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
function Get-EthernetAdapters {
    return @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object {
        $_.MediaType -eq '802.3' -and $_.InterfaceDescription -notmatch $script:VirtRegex
    })
}
function Get-IfaceReg([string]$Guid) {
    try { return (Get-ItemProperty -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$Guid" -ErrorAction Stop) } catch { return $null }
}
function Get-DhcpDnsServers([string]$Guid) {
    $reg = Get-IfaceReg $Guid
    if ($reg -and $reg.DhcpNameServer) {
        return @(([string]$reg.DhcpNameServer) -split '[,\s]+' | Where-Object { $_ -match '^\d{1,3}(\.\d{1,3}){3}$' })
    }
    return @()
}
function Get-GatewaysV4($Ad) {
    return @(Get-NetRoute -InterfaceIndex $Ad.ifIndex -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue |
        Where-Object { $_.NextHop -and $_.NextHop -ne '0.0.0.0' } | ForEach-Object { [string]$_.NextHop } | Select-Object -Unique)
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
    foreach ($g in $gws) { if ($g -match $cfg.GwRegex) { $score += 1; [void]$ev.Add("gateway $g matches hostel pattern"); break } }
    $sfx = ''
    try { $sfx = [string](Get-DnsClient -InterfaceIndex $Ad.ifIndex -ErrorAction SilentlyContinue).ConnectionSpecificSuffix } catch {}
    if (-not $sfx -and $reg -and $reg.DhcpDomain) { $sfx = [string]$reg.DhcpDomain }
    if ($sfx -and $sfx -match [regex]::Escape($cfg.CampusDomain)) { $score += 2; [void]$ev.Add("DNS suffix '$sfx'") }
    try {
        $np = Get-NetConnectionProfile -InterfaceIndex $Ad.ifIndex -ErrorAction SilentlyContinue
        if ($np -and $np.Name -match $cfg.ProfileRegex) { $score += 1; [void]$ev.Add("network name '$($np.Name)'") }
    } catch {}
    # Learned fingerprint: the DHCP server seen when the evidence was strong. Survives a changed DNS IP / suffix.
    $dhcpSrv = ''
    if ($reg -and $reg.DhcpServer) { $dhcpSrv = [string]$reg.DhcpServer }
    $learnedSrv = [string]$script:State.Misc['LearnedDhcp']
    $learnedBonus = 0
    if ($dhcpSrv -and $learnedSrv -and ($dhcpSrv -eq $learnedSrv)) { $learnedBonus = 1; $score += 1; [void]$ev.Add("DHCP server $dhcpSrv matches the campus server learned earlier") }
    if ($score -lt $cfg.CampusThreshold -and $ip) {
        if (Test-TcpPort $cfg.PortalIp $cfg.PortalPort 700) { $score += 2; [void]$ev.Add("portal $($cfg.PortalIp):$($cfg.PortalPort) open") }
        if ($null -ne (Test-Ping $cfg.PortalIp 700)) { $score += 1; [void]$ev.Add("portal firewall answers ping") }
        if ($null -ne (Test-Ping $cfg.CampusDns 700)) { $score += 1; [void]$ev.Add("campus DNS answers ping") }
    }

    $envName = 'Unknown'
    $sticky = $false
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
        $h.Time = (Get-Date).ToString('o')
    }
    $info = @{ Env = $envName; Score = $score; Evidence = @($ev); Sticky = $sticky; Ip = $ip; Gateways = $gws }
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
    $h.Conn = (Get-InternetState -SourceIp $h.Ip).State
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
    $minWait = if ($MaxMs -gt 12000) { 8000 } else { 2000 }
    while ($sw.ElapsedMilliseconds -lt $MaxMs) {
        $ups = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
        if ($ups.Count -eq 0) {
            if ($sw.ElapsedMilliseconds -ge $minWait) { break }
        } else {
            $pending = 0
            foreach ($a in $ups) {
                if (-not (Get-ValidIPv4 $a)) { $pending++ }
                elseif (@(Get-GatewaysV4 $a).Count -eq 0 -and $sw.ElapsedMilliseconds -lt 4000) { $pending++ }
            }
            if ($pending -eq 0) { break }
        }
        Start-Sleep -Milliseconds 250
    }
    Write-Log 'INFO' ("Link settling finished after {0} ms" -f $sw.ElapsedMilliseconds)
}

function Test-WatchdogInstalled {
    $r = Invoke-Native (Get-SysExe 'schtasks.exe') @('/query', '/tn', $script:Cfg.TaskWatchdog) 8000
    return ($r.ExitCode -eq 0)
}

# ==============================================================================
# LAYER 1 - HARDWARE & POWER SHIELD (only touches settings the driver really exposes)
# ==============================================================================
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
    # Windows Power Scheme: Disable USB Selective Suspend so the USB host controller never sleeps the dongle
    Set-UsbSuspendOff
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
    # Step 1: renew (or release+renew if recovering a stale lease with dead gateway)
    if ($script:IsDry) { Write-Log 'DRY' "Would: DHCP renew on $($Ad.Name)"; return $false }
    if ($ForceRelease) {
        Write-Log 'INFO' "Releasing stale DHCP lease on $($Ad.Name) before renew..."
        [void](Invoke-Native $ipconfig @('/release', $Ad.Name) 10000)
    }
    Write-Log 'INFO' "DHCP renew attempted on $($Ad.Name)..."
    $r = Invoke-Native $ipconfig @('/renew', $Ad.Name) 15000
    if ($r.ExitCode -eq 0) { Write-Log 'OK' "DHCP renew completed on $($Ad.Name)" }
    for ($i = 0; $i -lt 12; $i++) {
        if ($(if ($ForceRelease) { Test-DhcpLeaseUsable $Ad } else { [bool](Get-ValidIPv4 $Ad) })) { Write-Log 'OK' 'Lease acquired.'; return $true }
        Start-Sleep -Milliseconds 500
    }
    # Step 2: link reset (rate-limited so a dead port cannot cause a loop)
    if (Test-Elapsed ("Restart:" + $guid) 300) {
        Set-StateTime ("Restart:" + $guid)
        [void](Invoke-Change "Link reset on $($Ad.Name)" { Restart-NetAdapter -Name $Ad.Name -Confirm:$false -ErrorAction Stop })
        $script:PendingRestart.Remove($guid)
        # Adaptive STP convergence window (up to 45s, instant early-exit on lease acquisition)
        for ($i = 0; $i -lt 90; $i++) { if (Get-ValidIPv4 $Ad) { Write-Log 'OK' 'Lease acquired after link reset.'; return $true }; Start-Sleep -Milliseconds 500 }
    } else {
        Write-Log 'INFO' 'Link reset skipped (done less than 5 minutes ago).'
    }
    # Step 3: release + renew
    [void](Invoke-Change "DHCP release/renew on $($Ad.Name)" {
        [void](Invoke-Native $ipconfig @('/release', $Ad.Name) 10000)
        $r = Invoke-Native $ipconfig @('/renew', $Ad.Name) 25000
        if ($r.TimedOut) { throw 'ipconfig /renew timed out' }
        if ($r.ExitCode -ne 0) { Write-Log 'WARN' ('ipconfig /renew said: ' + (([string]$r.Output -replace '\s+', ' ').Trim())) }
    })
    for ($i = 0; $i -lt 16; $i++) { if (Get-ValidIPv4 $Ad) { Write-Log 'OK' 'Lease acquired after release/renew.'; return $true }; Start-Sleep -Milliseconds 500 }
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
            $snap = Get-SubTable 'Snapshot' $guid
            $orig = if ($snap.ContainsKey('Dad4')) { [int]$snap['Dad4'] } else { [int]$script:Cfg.DefaultDad }
            if ($cur -eq [int]$script:Cfg.CampusDad -and $orig -ne $cur) {
                [void](Invoke-Change "Non-campus network: duplicate-address probes restored to $orig on $($ad.Name)" {
                    Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -DadTransmits $orig -ErrorAction Stop
                })
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
            $script:EnvCache.Remove($guid)
            $Ctx.Env = Get-AdapterEnvironment $ad
        }
    }
    if (-not (Get-ValidIPv4 $ad)) {
        $Ctx.Repaired = (Repair-Dhcp $ad)
        $script:EnvCache.Remove($guid)
        $Ctx.Env = Get-AdapterEnvironment $ad
    } elseif ($ipif -and [string]$ipif.Dhcp -eq 'Enabled') {
        $curGw = @(Get-GatewaysV4 $ad) | Select-Object -First 1
        $gwOk = if ($curGw) { (Test-GatewayAlive $ad $curGw).Alive } else { $false }
        if (-not $gwOk) {
            Write-Log 'WARN' "IPv4 lease is present on $($ad.Name), but default gateway is $(if ($curGw) { "$curGw (unreachable)" } else { 'missing' }). Refreshing DHCP lease..."
            $Ctx.Repaired = (Repair-Dhcp $ad -ForceRelease)
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
        Remove-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -Confirm:$false -ErrorAction SilentlyContinue
        [void](Test-Ping $Gw 700)
        Start-Sleep -Milliseconds 200
        $n = Get-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -AddressFamily IPv4 -ErrorAction SilentlyContinue |
             Where-Object { $_.LinkLayerAddress -and $_.LinkLayerAddress -notmatch '^(00-)+00$' -and @('Unreachable','Incomplete') -notcontains [string]$_.State } | Select-Object -First 1
        if ($n) { $macs += ([string]$n.LinkLayerAddress).ToUpper() }
    }
    return $macs
}
function Remove-GatewayLock($Ad, [string]$Gw) {
    Remove-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -PolicyStore ActiveStore -Confirm:$false -ErrorAction SilentlyContinue
    Remove-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -PolicyStore PersistentStore -Confirm:$false -ErrorAction SilentlyContinue
    Remove-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -Confirm:$false -ErrorAction SilentlyContinue
    [void](Invoke-Native (Get-SysExe 'arp.exe') @('-d', $Gw) 5000)
    $t = Get-SubTable 'Arp' ([string]$Ad.InterfaceGuid)
    $t.Remove($Gw)
}
function Release-ArpLocks($Ad) {
    $t = Get-SubTable 'Arp' ([string]$Ad.InterfaceGuid)
    foreach ($gw in @($t.Keys)) {
        [void](Invoke-Change "Gateway ARP lock released: $gw" { Remove-GatewayLock $Ad $gw })
    }
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
            if ($ConnState -ne 'Offline') { Write-Log 'INFO' "Gateway ARP lock for $gw verified."; continue }
            Write-Log 'WARN' "Connectivity lost while ARP-locked: re-learning gateway $gw (the MAC may have changed)."
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
# Layer 3 Path MTU Clamping: Eliminates campus router blackhole drops on large TCP frames
function Shield-PathMtu($Ctx, [string]$ConnState) {
    if (-not $script:Cfg.AutoClampMtu) { return }
    $ad = $Ctx.Ad
    if ($Ctx.Env.Env -eq 'Other') {
        $snap = Get-SubTable 'Snapshot' ([string]$ad.InterfaceGuid)
        if ($snap.ContainsKey('Mtu')) {
            $orig = [int]$snap['Mtu']
            $ipif = Get-IPv4Interface $ad
            if ($ipif -and [int]$ipif.NlMtu -ne $orig) {
                [void](Invoke-Change "Non-campus network: restoring MTU to $orig on $($ad.Name)" {
                    Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -NlMtuBytes $orig -ErrorAction Stop
                })
            }
        }
        return
    }
    if ($Ctx.Env.Env -ne 'Campus' -or $ConnState -ne 'Online') { return }
    if ($script:IsDry) { Write-Log 'DRY' 'Would measure the path MTU and lower the adapter MTU only if a blackhole is confirmed twice.'; return }
    $ipif = Get-IPv4Interface $ad
    if (-not $ipif -or [int]$ipif.NlMtu -lt 1500) { return }
    $pmtu = Get-PathMtu '9.9.9.9'
    $d = Get-MtuDecision $pmtu ([int]$ipif.NlMtu) $script:State.Misc['MtuCandidate']
    if ($d.Action -eq 'candidate') { $script:State.Misc['MtuCandidate'] = $d.Value; Write-Log 'INFO' ("A path MTU of {0} was measured; it is applied only if the next measurement agrees." -f $d.Value) }
    elseif ($d.Action -eq 'clamp') {
        Save-Original ([string]$ad.InterfaceGuid) 'Mtu' ([int]$ipif.NlMtu)
        $v = [int]$d.Value
        $ok = Invoke-Change "Adapter MTU lowered to $v on $($ad.Name) (path MTU confirmed twice)" { Set-NetIPInterface -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -NlMtuBytes $v -ErrorAction Stop }
        if ($ok) { $script:State.Misc.Remove('MtuCandidate') }
    } else { if ($null -ne $script:State.Misc['MtuCandidate']) { $script:State.Misc.Remove('MtuCandidate') } }
}
# Layer 3 Route Shield: Verify reachability and prune unreachable duplicate default gateways
function Shield-DefaultRoutes($Ctx) {
    $ad = $Ctx.Ad
    if ($Ctx.Env.Env -ne 'Campus') { return }
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
            if ($routes.Count -gt 0) {
                Save-Original ([string]$ad.InterfaceGuid) ("PrunedRoute_$dgw") @{ DestinationPrefix = '0.0.0.0/0'; NextHop = $dgw; RouteMetric = [int]$routes[0].RouteMetric }
            }
            [void](Invoke-Change "Pruned dead default gateway route $dgw on $($ad.Name) (prevents blackhole routing)" {
                Remove-NetRoute -InterfaceIndex $ad.ifIndex -DestinationPrefix '0.0.0.0/0' -NextHop $dgw -Confirm:$false -ErrorAction Stop
            })
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
    $ad = $Ctx.Ad
    $others = @(Get-OtherUplinkAdapters)
    $plan = Get-RouteMetricPlan ([string]$Ctx.Env.Env) $ConnState $others.Count
    if ($plan.Mode -eq 'Restore') {
        if (-not $script:IsDry) { Remove-CampusHostRoutes $ad.ifIndex }
        if (Test-MetricsManaged) { Restore-InterfaceMetrics ([string]$plan.Why) }
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
    foreach ($w in $others) {
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
                        # must be OUR transaction id, a response (QR=1) and NOERROR
                        if ($resp.Length -ge 12 -and $resp[0] -eq $hi -and $resp[1] -eq $lo -and (($resp[2] -band 128) -ne 0) -and (($resp[3] -band 15) -eq 0)) {
                            $times[$s] += [int][math]::Round($ms)
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
        foreach ($s in @($pending.Keys)) { try { $pending[$s].U.Close() } catch {} }
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
        Set-DnsClientServerAddress -InterfaceIndex $Ad.ifIndex -ServerAddresses $Servers -ErrorAction Stop
    }
    if ($ok -and -not $script:IsDry) { (Get-SubTable 'Dns' $guid).Managed = $true; Clear-DnsClientCache -ErrorAction SilentlyContinue }
    return $ok
}
function Set-AdapterDnsAutomatic($Ad) {
    $guid = [string]$Ad.InterfaceGuid
    $curNs = Get-StaticDnsString $guid
    if ($curNs -eq '') { return $false }
    Save-Original $guid 'DnsStatic' $curNs
    $ok = Invoke-Change "DNS on $($Ad.Name) -> automatic (DHCP)" { Set-DnsClientServerAddress -InterfaceIndex $Ad.ifIndex -ResetServerAddresses -ErrorAction Stop }
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
function Set-CampusNrpt([string[]]$Servers) {
    $nsSub = '.' + $script:Cfg.CampusDomain
    $nsApex = $script:Cfg.CampusDomain
    $rules = @(Get-OurNrptRules)
    $hasSub = $false; $hasApex = $false; $serversMatch = $true
    foreach ($r in $rules) {
        if (@($r.Namespace) -contains $nsSub) { $hasSub = $true }
        if (@($r.Namespace) -contains $nsApex) { $hasApex = $true }
        $currentNs = @($r.NameServers)
        foreach ($s in $Servers) { if ($currentNs -notcontains $s) { $serversMatch = $false } }
    }
    if ($hasSub -and $hasApex -and $serversMatch) { return }
    Remove-CampusNrpt
    [void](Invoke-Change "Campus-domain DNS rule: *$nsSub & $nsApex -> $($Servers -join ', ')" {
        Add-DnsClientNrptRule -Namespace @($nsSub, $nsApex) -NameServers $Servers -DisplayName 'LanFixer-Campus' -Comment 'Managed by Lan Fixer' -ErrorAction Stop
    })
}
function Shield-Dns($Ctx, [string]$ConnState) {
    $ad = $Ctx.Ad
    $guid = [string]$ad.InterfaceGuid
    $d = Get-SubTable 'Dns' $guid
    if ($Ctx.Env.Env -eq 'Other') {
        Restore-AdapterDns $ad
        Remove-CampusNrpt
        Write-Log 'INFO' 'Non-campus network: DNS is left to the network (any change made earlier is reverted).'
        return
    }
    if ($Ctx.Env.Env -ne 'Campus') { Write-Log 'INFO' 'Environment unknown: DNS untouched.'; return }
    $prof = Get-DnsProfileName
    $campus = @(Get-DhcpDnsServers $guid)
    if ($campus.Count -eq 0) { $campus = @($script:Cfg.CampusDns) }
    $phase = 'Auto'
    $order = @()
    switch ($prof) {
        'DHCP'       { $phase = 'Auto' }
        'ResetDHCP'  { $phase = 'Auto' }
        'Hybrid'     { $order = @('9.9.9.9', '8.8.8.8') + $campus; $phase = 'Public' }
        'Cloudflare' { $order = @($script:Cfg.CfDns) + $campus; $phase = 'Public' }
        default {
            if ($ConnState -eq 'Online') {
                $order = @(Get-BestDnsOrder $guid $campus)
                if (@($order | Where-Object { $campus -notcontains $_ }).Count -gt 0) { $phase = 'Public' } else { $phase = 'Campus' }
            } else {
                $cands = @($campus)
                if ($cands -notcontains $script:Cfg.PortalIp) { $cands += $script:Cfg.PortalIp }
                $scores = Measure-ResolversFast $cands 400
                $live = @($cands | Where-Object { $null -ne $scores[$_] } | Sort-Object { $scores[$_] })
                $dead = @($cands | Where-Object { $null -eq $scores[$_] })
                $order = if ($live.Count -gt 0) { @($live + $dead) } else { @($cands) }
                $phase = 'Campus'
            }
        }
    }
    $order = @($order | Select-Object -Unique)
    if ($phase -eq 'Auto') {
        if (-not (Set-AdapterDnsAutomatic $ad)) { Write-Log 'INFO' "DNS already automatic on $($ad.Name) (profile $prof)." }
        Remove-CampusNrpt
    } else {
        if (-not (Set-AdapterDns $ad $order)) { Write-Log 'INFO' "DNS already correct on $($ad.Name) (profile $prof, phase $phase)." }
        $nrptServers = @($campus + $script:Cfg.PortalIp | Select-Object -Unique)
        Set-CampusNrpt $nrptServers
    }
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
    if ($camp.Count -eq 0) { Write-Log 'INFO' 'Not on campus: portal checks skipped.'; return }
    $tcp = Test-TcpPort $script:Cfg.PortalIp $script:Cfg.PortalPort 900
    if ($tcp) { Write-Log 'OK' ("Portal {0}:{1} reachable" -f $script:Cfg.PortalIp, $script:Cfg.PortalPort) }
    else { Write-Log 'WARN' ("Portal {0}:{1} not reachable (normal if the session is already authenticated and the firewall hides it)" -f $script:Cfg.PortalIp, $script:Cfg.PortalPort) }
    $ip = Resolve-HostBounded $script:Cfg.PortalHost 1800
    if ($ip) { Write-Log 'OK' "Portal name resolves: $($script:Cfg.PortalHost) -> $ip" }
    else { Write-Log 'WARN' "Portal name $($script:Cfg.PortalHost) does not resolve with the current DNS." }
}

# ==============================================================================
# LAYER 6 - EXPOSURE: treat the hostel LAN as untrusted (Public firewall profile)
# ==============================================================================
function Shield-Profile($Ctx) {
    if (-not $script:Cfg.ForcePublic -or $Ctx.Env.Env -ne 'Campus') { return }
    $np = Get-NetConnectionProfile -InterfaceIndex $Ctx.Ad.ifIndex -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $np) { return }
    if ([string]$np.NetworkCategory -eq 'Private') {
        Save-Original 'NetProfiles' ("Cat:" + $np.Name) 'Private'
        [void](Invoke-Change "Network '$($np.Name)' set to Public (blocks discovery/sharing from other hostel devices)" {
            Set-NetConnectionProfile -InterfaceIndex $Ctx.Ad.ifIndex -NetworkCategory Public -ErrorAction Stop
        })
    } else { Write-Log 'INFO' "Network profile is $($np.NetworkCategory) (already safe or domain-managed)." }
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
    if (Test-MetricsManaged) { Restore-InterfaceMetrics 'No active Ethernet link' }
    Remove-CampusHostRoutes
    $cd = [string]$script:Cfg.CampusDns
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
    Restore-NeutralizedInterceptors 'Left campus'
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
            $origStart = [string]$script:State.Misc['NeutralizedServices'][$sn]
            if ($origStart -and $origStart -ne 'Disabled') {
                [void](Invoke-Change "$($Why): restored service $sn to $origStart" {
                    Set-Service -Name $sn -StartupType $origStart -ErrorAction SilentlyContinue
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
            [void](Invoke-Change 'TCP Window Auto-Tuning restored to Normal (was Disabled by third-party optimizer)' {
                Set-NetTCPSetting -SettingName Internet -AutoTuningLevelLocal Normal -ErrorAction Stop
            })
        }
    } catch {}
}

function Shield-SystemStack([switch]$Aggressive) {
    if (-not $script:IsAdmin) { return }
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
        $rawDns = Measure-ResolversFast @('8.8.8.8','1.1.1.1') 400 53 ''
        $rawNet = ($null -ne (Test-Ping '8.8.8.8' 500)) -or (Test-TcpPort '1.1.1.1' 443 600)
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
            $dnsAddrs = @(Get-DnsClientServerAddress -InterfaceIndex $na.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses
            if (@($dnsAddrs | Where-Object { $_ -match '^(127\.|::1)' }).Count -gt 0) {
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
        if (-not $skipKill) {
            $matchRegex = $wfpDnsRegex
            $rogueProcs = @(Get-Process -ErrorAction SilentlyContinue | Where-Object {
                ($roguePids.Contains($_.Id) -or (($Aggressive -or $hasPoison) -and ($_.ProcessName -match $matchRegex))) -and
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
                            $script:State.Misc['NeutralizedServices'][$s.Name] = [string]$s.StartType
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
        $sysOk = Resolve-DnsName -Name 'accounts.google.com' -Type A -QuickTimeout -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress }
        $hasStuckCampusDns = $false
        foreach ($ou in $otherUps) {
            $ouDns = @(Get-DnsClientServerAddress -InterfaceIndex $ou.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses
            if ($ouDns -contains $script:Cfg.CampusDns -or $ouDns -contains $script:Cfg.PortalIp) { $hasStuckCampusDns = $true }
        }
        if (-not $sysOk -or $hasStuckCampusDns) {
            # Every secondary-uplink DNS change goes through the same snapshotting helpers that Ethernet uses:
            # the user's ORIGINAL Wi-Fi / USB-tethering / Bluetooth-PAN resolver string is recorded first and the
            # adapter is marked managed, so it can be restored exactly when this link is no longer ours to manage.
            foreach ($ou in $otherUps) { [void](Set-AdapterDnsAutomatic $ou) }
            Clear-DnsClientCache -ErrorAction SilentlyContinue
            if (-not $script:IsDry) {
                $recheckOk = Resolve-DnsName -Name 'accounts.google.com' -Type A -QuickTimeout -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress }
                if (-not $recheckOk) {
                    foreach ($ou in $otherUps) {
                        $ouEnv = (Get-AdapterEnvironment $ou).Env
                        if ($ouEnv -ne 'Campus') { [void](Set-AdapterDns $ou @('8.8.8.8','1.1.1.1')) }
                    }
                    Clear-DnsClientCache -ErrorAction SilentlyContinue
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
        Write-Log 'STEP' 'STAGE 1/5  Rescanning PnP hardware bus & neutralizing WFP DNS interceptors / dead proxies'
        if (-not $script:IsDry) { [void](Invoke-Native (Get-SysExe 'pnputil.exe') @('/scan-devices') 5000) }
        if (-not $script:IsDry) {
            $script:State.Misc['RouteProfile'] = 'Adaptive'
            $script:State.Misc['DnsProfile'] = 'Adaptive'
        }
        Shield-SystemStack -Aggressive
        if (-not $script:IsDry) { [void](Invoke-Native (Get-SysExe 'netsh.exe') @('winhttp', 'reset', 'proxy') 5000) }
        Remove-CampusNrpt
        Remove-LegacyHostsEntries
        Remove-CampusHostRoutes
        foreach ($ea in @(Get-EthernetAdapters)) { Release-ArpLocks $ea }
        Write-Log 'STEP' 'STAGE 2/5  Restoring clean routing metrics & MTU across all physical uplinks'
        Restore-InterfaceMetrics 'Full Net Reset metrics restore'
        if (-not $script:IsDry) {
            foreach ($i in @(Get-NetIPInterface -ErrorAction SilentlyContinue | Where-Object { $_.ConnectionState -eq 'Connected' })) {
                Set-NetIPInterface -InterfaceIndex $i.ifIndex -AddressFamily $i.AddressFamily -AutomaticMetric Enabled -ErrorAction SilentlyContinue
            }
            foreach ($a in @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' })) {
                Set-NetIPInterface -InterfaceIndex $a.ifIndex -AddressFamily IPv4 -NlMtuBytes 1500 -ErrorAction SilentlyContinue
            }
        }
        Write-Log 'STEP' 'STAGE 3/5  Running 7-Layer Ethernet & Multi-Homed Heal Pipeline'
        $resHeal = Pick-Hash (Invoke-HealPipeline -SkipSystemStack)
        Write-Log 'STEP' 'STAGE 4/5  Flushing DNS, ARP, NetBIOS & refreshing network state services'
        if (-not $script:IsDry) {
            Clear-DnsClientCache -ErrorAction SilentlyContinue
            [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/flushdns') 5000)
            Get-NetNeighbor -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.State -ne 'Permanent' } | Remove-NetNeighbor -Confirm:$false -ErrorAction SilentlyContinue
            [void](Invoke-Native (Get-SysExe 'nbtstat.exe') @('-R') 5000)
            Restart-Service -Name NlaSvc -Force -ErrorAction SilentlyContinue
            Start-Service -Name netprofm -ErrorAction SilentlyContinue
        }
        Write-Log 'STEP' 'STAGE 5/5  Verifying live IPv4 A-record & HTTPS reachability (GitHub & Google Auth)'
        $anyVerifyFail = $false
        foreach ($testHost in @('github.com', 'accounts.google.com')) {
            $ip = Resolve-HostBounded $testHost 3000
            if ($ip) {
                $tcpOk = Test-TcpPort $ip 443 2500
                Write-Log ($(if ($tcpOk) { 'OK' } else { 'WARN' })) ("Verified {0} -> {1} (TCP/443: {2})" -f $testHost, $ip, $(if ($tcpOk) { 'OPEN' } else { 'BLOCKED' }))
            } else {
                $anyVerifyFail = $true
                Write-Log 'FAIL' ("DNS resolution still failed for {0}" -f $testHost)
            }
        }
        if ($anyVerifyFail -and -not $script:IsDry -and ($resHeal.Conn -ne 'Captive')) {
            [void](Invoke-Change 'Resetting corrupted Winsock catalog (fallback recovery)' {
                [void](Invoke-Native (Get-SysExe 'netsh.exe') @('winsock', 'reset', 'catalog') 8000)
            })
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
    if ($ConnState -eq 'Online' -and -not $script:IsDry) {
        foreach ($ctx in $Ctxs) {
            $np = Get-NetConnectionProfile -InterfaceIndex $ctx.Ad.ifIndex -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($np -and [string]$np.IPv4Connectivity -ne 'Internet') {
                Start-Sleep -Seconds 5
                $np = Get-NetConnectionProfile -InterfaceIndex $ctx.Ad.ifIndex -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($np -and [string]$np.IPv4Connectivity -ne 'Internet' -and (Test-Elapsed 'NlaNudge' 900)) {
                    Set-StateTime 'NlaNudge'
                    [void](Invoke-Change 'Network List service refreshed (Windows showed "no internet" while it works)' { Restart-Service -Name NlaSvc -Force -ErrorAction Stop })
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
function Invoke-HealPipeline([switch]$SkipSystemStack) {
    $res = @{ Conn = 'Offline'; Campus = $false; AnyUp = $false; Problem = 'NoAdapter' }
    Invoke-LegacyMigration
    $script:WatchdogOn = Test-WatchdogInstalled
    Update-WatchdogIfStale
    if (@(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' }).Count -eq 0) { Invoke-RoamingCleanup }
    if (-not $SkipSystemStack) { Shield-SystemStack }
    $ads = @(Get-EthernetAdapters)
    if ($ads.Count -gt 0) {
        foreach ($a in $ads) {
            if ($a.Status -eq 'Disabled' -and $Mode -ne 'AutoHeal') {   # a manual repair may re-enable it; the watchdog never overrides a choice you made
                [void](Invoke-Change "Enabling disabled physical Ethernet adapter $($a.Name)" {
                    Enable-NetAdapter -Name $a.Name -Confirm:$false -ErrorAction Stop
                })
            }
        }
    }
    if ($ads.Count -eq 0) { Write-Log 'WARN' 'No physical Ethernet adapter found (Wi-Fi/system stack still shielded).'; Invoke-RoamingCleanup; Save-State; return $res }

    Write-Log 'STEP' 'LAYER 1/7  Hardware interface & power state verification'
    foreach ($a in $ads) { Shield-Hardware $a }
    $didHwRestart = $false
    if (-not $script:IsDry) {
        foreach ($g in @($script:PendingRestart.Keys)) {
            $nm = $script:PendingRestart[$g]
            if (Test-Elapsed ("Restart:" + $g) 300) {
                Set-StateTime ("Restart:" + $g)
                if (Invoke-Change "Link reset on $nm to apply driver settings" { Restart-NetAdapter -Name $nm -Confirm:$false -ErrorAction Stop }) { $didHwRestart = $true }
            }
        }
        $script:PendingRestart = @{}
    }
    $needLongSettling = $didHwRestart
    if (-not $needLongSettling) {
        foreach ($a in $ads) {
            if ($a.Status -eq 'Up' -and -not (Get-ValidIPv4 $a)) { $needLongSettling = $true; break }
        }
    }
    Wait-LinkSettling $(if ($needLongSettling) { ([int]$script:Cfg.StpMaxSec * 1000) } else { 12000 })
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
    $ctxs = @()
    foreach ($a in $ups) { $ctxs += @{ Ad = $a; Env = (Get-AdapterEnvironment $a); Repaired = $false } }
    foreach ($c in $ctxs) {
        Write-Log 'INFO' ("{0}: {1} (score {2}{3}) {4}" -f $c.Ad.Name, $c.Env.Env.ToUpper(), $c.Env.Score, $(if ($c.Env.Sticky) { ', last known' } else { '' }), (($c.Env.Evidence) -join '; '))
    }

    Write-Log 'STEP' 'LAYER 2/7  Data link & DHCP lease renewal'
    foreach ($c in $ctxs) { Shield-DataLink $c }
    $conn = (Get-InternetState -NoCache).State

    Write-Log 'STEP' 'LAYER 3/7  Gateway ARP integrity & route metrics'
    foreach ($c in $ctxs) { Shield-GatewayArp $c $conn; Shield-RouteMetrics $c $conn; Shield-PathMtu $c $conn; Shield-DefaultRoutes $c }

    Write-Log 'STEP' 'LAYER 4/7  Adaptive DNS configuration & resolver health'
    foreach ($c in $ctxs) { Shield-Dns $c $conn }

    $connAfterDns = (Get-InternetState -NoCache).State
    if ($connAfterDns -eq 'Online' -and $conn -ne 'Online') {
        $conn = 'Online'
        foreach ($c in $ctxs) { Shield-RouteMetrics $c $conn; Shield-PathMtu $c $conn }
    }

    Write-Log 'STEP' 'LAYER 5/7  Captive portal routing & reachability'
    Shield-Portal $ctxs

    Write-Log 'STEP' 'LAYER 6/7  Network profile & firewall security'
    foreach ($c in $ctxs) { Shield-Profile $c }

    Write-Log 'STEP' 'LAYER 7/7  Network stack & service synchronization'
    Shield-Services $ctxs $conn

    foreach ($c in $ctxs) {
        $h = Get-SubTable 'Env' ([string]$c.Ad.InterfaceGuid)
        $h.Up = $true
        $h.Ip = [string](Get-ValidIPv4 $c.Ad)
        if ($c.Env.Env -eq 'Campus') { $res.Campus = $true }
    }
    if (-not $script:IsDry) { Set-StateTime 'LastFull'; $script:State.Misc['Version'] = $script:Version; Save-State }
    $res.Conn = (Get-InternetState -NoCache).State
    $res.Problem = (Get-AdapterHealth $ups[0]).Problem
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
    $dom = ([string]$script:Cfg.CampusDomain).ToLower().Trim('.')
    return ($h -eq $dom -or $h.EndsWith('.' + $dom))
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
    $anchor = [string]$script:Cfg.PortalUrl
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
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($User + [string][char]9 + $Pass)
        $enc = [System.Security.Cryptography.ProtectedData]::Protect($bytes, (Get-VaultEntropy), [System.Security.Cryptography.DataProtectionScope]::LocalMachine)
        [Array]::Clear($bytes, 0, $bytes.Length)
        # Lock an EMPTY file first, write second: the secret never exists under a looser ACL.
        [System.IO.File]::WriteAllBytes($tmp, [byte[]]@())
        if (-not (Protect-VaultFile $tmp) -or -not (Test-VaultAcl $tmp)) { throw 'could not restrict the vault file to Administrators/SYSTEM' }
        [System.IO.File]::WriteAllBytes($tmp, $enc)
        Move-Item -LiteralPath $tmp -Destination $script:VaultFile -Force -ErrorAction Stop
        if (-not (Test-VaultAcl $script:VaultFile)) { throw 'vault permissions did not survive the move' }
        $script:State.Misc['PortalFails'] = 0; $script:State.Misc['PortalAmbiguous'] = 0
        $script:State.Misc['PortalLoginSuspended'] = $false
        return $true
    } catch {
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $script:VaultFile -Force -ErrorAction SilentlyContinue   # fail closed: never leave a half-protected secret
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
        }
    } catch {}
    return $null
}
function Remove-PortalCredentials {
    foreach ($f in @($script:VaultFile, ($script:VaultFile + '.new'))) { if (Test-Path -LiteralPath $f) { Remove-Item -LiteralPath $f -Force -ErrorAction SilentlyContinue } }
    $script:State.Misc['PortalFails'] = 0; $script:State.Misc['PortalAmbiguous'] = 0
    $script:State.Misc['PortalLoginSuspended'] = $false
}
# Zero-touch login. Every guard below exists because a rogue device on a hostel LAN can answer for the portal.
function Invoke-HeadlessPortalLogin {
    param($Inet, [switch]$Manual, [int]$Attempt = 1)
    if ($script:IsDry) { return $false }
    if (-not $script:Cfg.AutoPortalLogin -and -not $Manual) { return $false }
    $creds = Get-PortalCredentials
    if (-not $creds) { if ($Manual) { Write-Log 'INFO' 'No credentials are saved yet.' }; return $false }
    if (-not $Manual) {
        if ($script:State.Misc['PortalLoginSuspended'] -eq $true) { Write-Log 'INFO' 'Auto-login is paused because the portal rejected the saved password. Re-save it in the vault to resume.'; return $false }
        if (-not (Test-Elapsed 'LastPortalLogin' 45)) { return $false }
    }
    Ensure-CampusPortalPath
    if ($null -eq $Inet) { $Inet = Get-InternetState -NoCache }
    if ($Manual -and $Inet.State -eq 'NoDns' -and $script:IsAdmin) {
        foreach ($a in @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })) {
            $e = Get-AdapterEnvironment $a -UseCache
            if ($e.Env -eq 'Campus' -and (Get-DnsProfileName) -eq 'Adaptive') { Shield-Dns @{ Ad = $a; Env = $e } 'Captive' }
        }
        $Inet = Get-InternetState -NoCache
    }
    if ($Manual -and $Inet.State -eq 'Offline' -and (Test-TcpPort $script:Cfg.PortalIp $script:Cfg.PortalPort 900)) {
        $Inet = @{ State = 'Captive'; Location = $script:Cfg.PortalUrl; Via = 'link' }
    }
    if ($Inet.State -ne 'Captive') { if ($Manual) { Write-Log 'INFO' 'This link is not behind the login page right now; nothing to do.' }; return $false }
    if ($Inet.Location -and -not (Get-SafePortalUrl ([string]$Inet.Location))) {
        Write-Log 'ALERT' 'The login redirect does not point to the campus portal: password NOT sent. Treat this network with suspicion.'
        return $false
    }
    $url = Resolve-PortalUrl $Inet
    $uri = $null
    try { $uri = [uri]$url } catch { return $false }
    if ($uri.Scheme -ne 'https') { Write-Log 'WARN' 'The portal is not served over HTTPS, so the password is not sent automatically. Use the browser login.'; return $false }
    if (-not (Test-TrustedPortalHost $uri.Host)) { Write-Log 'ALERT' ("Portal host '{0}' is not on the campus domain: password NOT sent." -f $uri.Host); return $false }
    # The URI is validated now: route exactly THIS destination over the campus cable, even if Wi-Fi holds metric 15.
    Ensure-CampusPortalPath $uri
    [void](Invoke-WithLock { Set-StateTime 'LastPortalLogin'; Save-State })   # the throttle must survive a crash mid-sign-in
    $src = ''; if ($script:Cfg.ProbeSourceBind) { $src = Get-PrimarySourceIp }
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
            if ($next.Scheme -ne 'https' -or -not (Test-TrustedPortalHost $next.Host)) { $page = @{ Error = 'UntrustedRedirect' }; break }
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
    if ($act.Scheme -ne 'https' -or -not (Test-TrustedPortalHost $act.Host)) {
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
    param([switch]$Force)
    $inet = Get-InternetState -NoCache
    $st = $inet.State
    $url = Resolve-PortalUrl $inet
    if (-not $Force -and $st -eq 'Online') { Write-Log 'OK' 'Internet is already authenticated; no login needed.'; return $false }
    if (-not $Force -and (Invoke-HeadlessPortalLogin $inet)) { return $true }
    if (Test-IsSystem) {
        $u = $null
        try { $u = (Get-CimInstance Win32_ComputerSystem -ErrorAction Stop).UserName } catch {}
        if (-not $u) { Write-Log 'INFO' 'Nobody is signed in; portal not opened.'; return $false }
        $known = [string]$script:State.Misc['PortalTaskUrl']
        if (-not $known) { $known = [string]$script:Cfg.PortalUrl }
        if ($url -ne $known) {
            # The helper task opens a fixed URL: point it at the verified live one first.
            $reg = Register-LfTask $script:Cfg.TaskPortal (New-PortalTaskXml $url) 'LanFixer_Portal.xml'
            if ($reg -and -not $script:IsDry) { $script:State.Misc['PortalTaskUrl'] = $url }
        }
        $ok = Invoke-Change 'Asking the signed-in user session to open the campus login page' {
            $r = Invoke-Native (Get-SysExe 'schtasks.exe') @('/run', '/tn', $script:Cfg.TaskPortal) 8000
            if ($r.ExitCode -ne 0) { throw 'portal task missing (run Install Watchdog again)' }
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
            Shield-RouteMetrics $ctx 'Online'
            Shield-Dns $ctx 'Online'
        }
        Clear-DnsClientCache -ErrorAction SilentlyContinue
        if (-not $script:IsDry) { Save-State }
    })
}
function Wait-ForAuthentication([int]$TimeoutSec = 180) {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $i = 0
    while ($sw.Elapsed.TotalSeconds -lt $TimeoutSec) {
        if ((Get-InternetState -NoCache).State -eq 'Online') { Out-Line @(); return $true }
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
        if ((Get-InternetState -NoCache).State -eq 'Online') {
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
function Test-HardFailure([string]$Problem) { return (@('NoIp', 'GwUnreachable', 'Offline', 'NoDns') -contains $Problem) }
# A working connection ends the breaker no matter who repaired it (manual option 1, watchdog, or the cable just got better).
function Clear-FailStreakIfRecovered([string]$Problem) {
    if ($script:IsDry -or (Test-HardFailure $Problem)) { return $false }
    if ([int]$script:State.Misc['FailStreak'] -eq 0) { return $false }
    $script:State.Misc['FailStreak'] = 0
    Write-Log 'INFO' 'Repair breaker reset: the connection works again.'
    return $true
}
function Invoke-AutoHeal {
    if (-not (Enter-Lock 3000)) { return 0 }
    if (-not (Test-Elapsed 'LastAutoHealRun' 20)) {
        Write-Log 'INFO' 'AutoHeal pass debounced: a heal pass completed less than 20 seconds ago.'
        Exit-Lock
        return 0
    }
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
        $guid = [string]$primary.InterfaceGuid
        $health = Get-AdapterHealth $primary
        $envi = Get-AdapterEnvironment $primary
        $h = Get-SubTable 'Env' $guid
        $d = Get-SubTable 'Dns' $guid
        $newConn = (($h.Up -ne $true) -or ([string]$h.Ip -ne [string]$health.Ip))
        $want = $(if ($health.Conn -eq 'Online') { 'Online' } else { 'NotOnline' })
        $mismatch = ($envi.Env -eq 'Campus' -and (Get-DnsProfileName) -eq 'Adaptive' -and ([string]$d.ConnApplied -ne $want))
        $needFull = ($health.Problem -ne 'Healthy') -or $newConn -or $mismatch -or ($script:State.Misc['Version'] -ne $script:Version) -or (Test-Elapsed 'LastFull' 7200)
        if (-not $needFull) {
            $h.Up = $true; $h.Ip = [string]$health.Ip
            Shield-RouteMetrics @{ Ad = $primary; Env = $envi } $health.Conn
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
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="Microsoft-Windows-NetworkProfile/Operational"&gt;&lt;Select Path="Microsoft-Windows-NetworkProfile/Operational"&gt;*[System[(EventID=10000)]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
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
function Get-WatchdogArguments {
    $task = Get-WatchdogTask
    if ($null -eq $task) { return $null }
    return [string]$task.Actions.Exec.Arguments
}
function Get-WatchdogExpectedArguments { return ('/c ""' + $script:SelfCopy + '" -Mode AutoHeal"') }
# A task registered by v1/v2.x runs an older copy. Re-point it once, automatically, at the current protected copy.
function Update-WatchdogIfStale {
    if (-not $script:IsAdmin -or $script:IsDry -or -not $script:WatchdogOn) { return }
    if (-not $script:StoreReady -or -not $script:StoreSecure) { return }
    if (-not (Test-Path -LiteralPath $script:SelfCopy)) { return }
    if (-not (Test-Elapsed 'Repoint' 3600)) { return }   # never loop if the comparison cannot settle
    $task = Get-WatchdogTask
    if ($null -eq $task) { return }
    if (-not (Test-WatchdogStale ([string]$task.Actions.Exec.Arguments) (Get-WatchdogExpectedArguments) ([string]$task.Settings.MultipleInstancesPolicy))) { return }
    Set-StateTime 'Repoint'
    Write-Log 'INFO' 'The watchdog task is out of date (older copy or unsafe restart policy). Re-registering it.'
    [void](Install-Watchdog)
}
function Uninstall-Watchdog {
    if (-not (Assert-Admin)) { return }
    foreach ($n in @($script:Cfg.TaskWatchdog, $script:Cfg.TaskPortal, $script:Cfg.TaskNotify, 'A07_NetShield')) {
        [void](Invoke-Change "Scheduled task '$n' removed (if present)" { [void](Invoke-Native (Get-SysExe 'schtasks.exe') @('/delete', '/tn', $n, '/f') 8000) })
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
    Write-Log 'INFO' 'Restoring from the snapshot taken before Lan Fixer changed anything...'
    $restartNames = @{}
    $present = @(Get-NetAdapter -IncludeHidden -ErrorAction SilentlyContinue)
    foreach ($guid in @($script:State.Snapshot.Keys)) {
        $snap = $script:State.Snapshot[$guid]
        if ($guid -eq 'NetProfiles') {
            foreach ($k in @($snap.Keys)) {
                if ($k -like 'Cat:*') {
                    $nm = $k.Substring(4); $cat = [string]$snap[$k]
                    [void](Invoke-Change "Network '$nm' set back to $cat" { Set-NetConnectionProfile -Name $nm -NetworkCategory $cat -ErrorAction Stop })
                }
            }
            continue
        }
        if ($guid -eq 'Global') {
            if ($snap.ContainsKey('UsbSuspend')) { $uv = $snap['UsbSuspend']; [void](Invoke-Change 'USB selective suspend restored to your original value' { Restore-UsbSuspend $uv }) }
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
                # The snapshot has been honoured: this adapter is no longer ours to manage.
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
            }
        }
    }
    # Any adapter this tool ever substituted a resolver on is restored here as well: the snapshot loop above only covers
    # adapters that HAVE a snapshot, while state written by an older build could leave a managed flag with no snapshot.
    [void](Restore-ManagedAdapterDns 'Factory reset')
    # Leftovers from builds that kept no snapshot: touch ONLY values that match what this tool sets, never a value you chose yourself.
    foreach ($a in @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue)) {
        $g = [string]$a.InterfaceGuid
        $snapA = $script:State.Snapshot[$g]
        $ipif = Get-IPv4Interface $a
        if ($ipif -and [int]$ipif.DadTransmits -eq 0 -and -not ($snapA -is [hashtable] -and $snapA.ContainsKey('Dad4'))) {
            [void](Invoke-Change "Duplicate-address probes back to 3 on $($a.Name) (0 is the campus value this tool sets)" { Set-NetIPInterface -InterfaceIndex $a.ifIndex -AddressFamily IPv4 -DadTransmits 3 -ErrorAction Stop })
        }
        $tk = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces\Tcpip_$g"
        if ((Test-Path -LiteralPath $tk) -and ((Get-ItemProperty -LiteralPath $tk -Name NetbiosOptions -ErrorAction SilentlyContinue).NetbiosOptions -eq 2) -and -not ($snapA -is [hashtable] -and $snapA.ContainsKey('Netbios'))) {
            [void](Invoke-Change "NetBIOS back to default on $($a.Name) (2 is the disabled campus value this tool sets)" { Set-ItemProperty -LiteralPath $tk -Name NetbiosOptions -Value 0 -Type DWord -ErrorAction Stop })
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
    foreach ($guid in @($script:State.Arp.Keys)) {
        $ad = $present | Where-Object { [string]$_.InterfaceGuid -eq [string]$guid } | Select-Object -First 1
        if ($ad) { Release-ArpLocks $ad }
    }
    Restore-InterfaceMetrics 'Metrics back to their original values'
    if ($script:State.Misc['NegCacheManaged'] -eq $true) { Restore-NegCacheIfManaged 'Negative DNS cache setting reverted' }
    if ($script:State.Misc['MdnsManaged'] -eq $true) { Restore-MdnsIfManaged 'mDNS setting reverted' }
    if ($script:State.Misc['SmartDnsManaged'] -eq $true) { Restore-SmartDnsIfManaged 'Smart Name Resolution setting reverted' }
    if ($script:State.Misc['TcpKeepAliveManaged'] -eq $true) { Restore-TcpKeepAliveIfManaged 'TCP KeepAlive setting reverted' }
    Remove-CampusNrpt
    Remove-LegacyHostsEntries
    Uninstall-Watchdog
    if ($script:State.Misc['NeutralizedTasks'] -is [hashtable]) {
        foreach ($tn in @($script:State.Misc['NeutralizedTasks'].Keys)) {
            $tp = [string]$script:State.Misc['NeutralizedTasks'][$tn]
            [void](Invoke-Change "Restored 3rd-party task $tn" {
                Enable-ScheduledTask -TaskName $tn -TaskPath $tp -ErrorAction SilentlyContinue | Out-Null
            })
        }
    }
    if ($script:State.Misc['NeutralizedServices'] -is [hashtable]) {
        foreach ($sn in @($script:State.Misc['NeutralizedServices'].Keys)) {
            $origStart = [string]$script:State.Misc['NeutralizedServices'][$sn]
            if ($origStart -and $origStart -ne 'Disabled') {
                [void](Invoke-Change "Restored 3rd-party service $sn to $origStart" {
                    Set-Service -Name $sn -StartupType $origStart -ErrorAction SilentlyContinue
                })
            }
        }
    }
    if (-not $script:IsDry) {
        foreach ($n in @($restartNames.Keys)) { [void](Invoke-Change "Link reset on $n to apply restored driver settings" { Restart-NetAdapter -Name $n -Confirm:$false -ErrorAction Stop }) }
        Clear-DnsClientCache -ErrorAction SilentlyContinue
        [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'ip', 'delete', 'arpcache') 8000)
        [void](Invoke-Native (Get-SysExe 'nbtstat.exe') @('-R') 8000)
        if (Test-Path -LiteralPath $script:VaultFile) { Remove-PortalCredentials; Write-Log 'OK' 'Saved portal credentials deleted.' }
        $script:State = @{}
        foreach ($k in 'Snapshot','Env','Dns','Arp','Times','Misc') { $script:State[$k] = @{} }
        $script:State.Misc['Migrated'] = $true
        Save-State
    }
    Write-Log 'OK' 'Restore finished. Your original network settings are back; Lan Fixer left no tasks, rules or hosts entries.'
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
        $ethUps = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
        if ($ethUps.Count -gt 0) {
            $st = (Get-InternetState -NoCache).State
            foreach ($eu in $ethUps) {
                $ctx = @{ Ad = $eu; Env = (Get-AdapterEnvironment $eu) }
                Shield-RouteMetrics $ctx $st
            }
        } else {
            if (($Name -eq 'Windows' -or $Name -eq 'Adaptive') -and (Test-MetricsManaged)) {
                Restore-InterfaceMetrics "Routing profile set to $Name"
            }
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
        $tcp = Test-TcpPort $script:Cfg.PortalIp $script:Cfg.PortalPort 900
        Write-KV ("Portal {0}:{1}" -f $script:Cfg.PortalIp, $script:Cfg.PortalPort) $(if ($tcp) { 'open' } else { 'closed/hidden' })
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
    $ads = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
    $gw = $null
    if ($ads.Count -gt 0) { $gw = @(Get-GatewaysV4 $ads[0]) | Select-Object -First 1 }
    else {
        $secAds = @(Get-OtherUplinkAdapters)
        if ($secAds.Count -gt 0) { $gw = @(Get-GatewaysV4 $secAds[0]) | Select-Object -First 1 }
    }
    if ($gw) {
        $rtts = @(); $lost = 0
        for ($i = 0; $i -lt 10; $i++) {
            $r = Test-Ping $gw 600
            if ($null -eq $r) { $lost++ } else { $rtts += $r }
            Start-Sleep -Milliseconds 120
        }
        if ($rtts.Count -gt 0) {
            $avg = ($rtts | Measure-Object -Average).Average
            $jit = ($rtts | Measure-Object -Maximum).Maximum - ($rtts | Measure-Object -Minimum).Minimum
            $lab = Get-LatencyLabel $avg
            Write-KV "[1] Gateway $gw" ("{0:N1} ms avg ({1}), jitter {2} ms, loss {3}%" -f $avg, $lab[0], $jit, ($lost * 10)) $(if ($lost -gt 1) { 'Yellow' } else { $lab[1] })
        } else { Write-KV "[1] Gateway $gw" 'No ping response (ICMP traffic may be filtered by router)' 'Yellow' }
    } else { Write-KV '[1] Gateway' 'No route found / cable disconnected' 'Red' }
    $tcp = Test-TcpPort $script:Cfg.PortalIp $script:Cfg.PortalPort 900
    $pp = Test-Ping $script:Cfg.PortalIp 800
    Write-KV ("[2] Portal {0}" -f $script:Cfg.PortalIp) ("tcp/{0} {1}, ping {2}" -f $script:Cfg.PortalPort, $(if ($tcp) { 'open' } else { 'closed' }), $(if ($null -ne $pp) { "$pp ms" } else { 'no reply' })) $(if ($tcp) { 'Green' } else { 'Yellow' })
    $servers = @(@($script:Cfg.CampusDns) + @($script:Cfg.PublicDns) | Select-Object -Unique)
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

function Flush-NetworkCache {
    if (-not (Assert-Admin)) { return }
    Write-Banner 'FLUSH DNS, ARP & NETBIOS CACHES'
    [void](Invoke-Change 'DNS resolver cache cleared' {
        Clear-DnsClientCache -ErrorAction SilentlyContinue
        [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/flushdns') 5000)
    })
    [void](Invoke-Change 'Dynamic ARP entries cleared (locked gateway entry is kept)' {
        Get-NetNeighbor -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.State -ne 'Permanent' } | Remove-NetNeighbor -Confirm:$false -ErrorAction SilentlyContinue
    })
    [void](Invoke-Change 'NetBIOS name cache purged' { [void](Invoke-Native (Get-SysExe 'nbtstat.exe') @('-R') 8000) })
    [void](Invoke-Change 'Network List service refreshed (clears a stuck "no internet" icon)' {
        Restart-Service -Name NlaSvc -Force -ErrorAction Stop
        Start-Service -Name netprofm -ErrorAction SilentlyContinue
    })
    Write-Log 'OK' 'Network resolver and neighbor caches flushed successfully.'
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
    Write-Check 'Logic: Invoke-DashboardKey maps n, c, o aliases, binds m to Show-RouteMenu, and omits dead guide alias' ($dkDef.IndexOf("n = '3'") -ge 0 -and $dkDef.IndexOf("c = '5'") -ge 0 -and $dkDef.IndexOf("o = '7'") -ge 0 -and $dkDef.IndexOf('Show-RouteMenu') -ge 0 -and $dkDef.IndexOf('guide') -lt 0)
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
    Write-Check 'Logic: AutoHeal fast-path syncs Shield-RouteMetrics when secondary uplinks change' ($ahDef.IndexOf('if (-not $needFull)') -ge 0 -and $ahDef.Substring($ahDef.IndexOf('if (-not $needFull)'), 350).IndexOf('Shield-RouteMetrics') -ge 0)
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
    try { [void][xml](New-WatchdogXml '/c test' '2026-01-01T00:00:00'); [void][xml](New-PortalTaskXml); $xmlOk = $true } catch {}
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
function Get-RoutingLabel([bool]$Managed, [int]$Metric, [bool]$LinkUp) {
    if (-not $Managed) { return 'automatic' }
    if (-not $LinkUp) { return 'Wi-Fi Protected' }
    if ($Metric -le 15) { return 'Ethernet First' }
    if ($Metric -ge 45) { return 'Wi-Fi Protected' }
    return 'Ethernet First'
}
function Get-Telemetry {
    $t = New-Telemetry
    $t.Problem = 'NoAdapter'
    $ads = @(Get-EthernetAdapters)
    $ad = $ads | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
    if (-not $ad) { $ad = $ads | Select-Object -First 1 }
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
                $t.Routing = Get-RoutingLabel (Test-MetricsManaged) ([int]$ipif.InterfaceMetric) $true
            }
            $raw = @((Get-DnsClientServerAddress -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses)
            if ($raw.Count -gt 0) { $t.DnsPrimary = [string]$raw[0] }
            $t.DnsProfile = Get-DnsProfileName
        }
    }
    if (-not $script:WdCache -or (((Get-Date) - $script:WdCache.Time).TotalSeconds -gt 30)) { $script:WdCache = @{ Time = (Get-Date); Val = (Test-WatchdogInstalled) } }
    $t.Watchdog = [bool]$script:WdCache.Val
    $t.Vault = [bool](Test-Path -LiteralPath $script:VaultFile)
    $t.Pin = ([string]$script:State.Misc['PortalPin'] -ne '')
    $t.Paused = ($script:State.Misc['PortalLoginSuspended'] -eq $true)
    $t.ArpPending = (@(Get-PendingGatewayMacs).Count -gt 0)
    $t.RouteProfile = Get-RouteProfileName
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
            $r.Status = 'Connected to network. All communication layers verified optimal.'
            if (-not $t.Watchdog) {
                $r.Action = 'Press [ENTER] to arm background watchdog guard (or press 2).'
                $r.Key = '2'; $r.KeyLabel = 'arm the watchdog'
            } else {
                $r.Status = 'Connected to network with background watchdog active.'
                if ($t.LastFull) { $r.Status += (' Last repair ' + ([datetime]$t.LastFull).ToString('ddd HH:mm') + '.') }
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
                $r.Action = 'Connect Ethernet cable, or press [ENTER] / [X] to run Full Net Reset.'
                $r.Key = 'x'; $r.KeyLabel = 'run Full Net Reset'
            } else {
                $r.Action = 'Connect Ethernet cable, then arm watchdog (or press 2).'
                $r.Key = '2'; $r.KeyLabel = 'arm the watchdog'
            }
        }
        'NoAdapter' {
            $r.Status = 'No physical Ethernet network adapter found.'
            $r.Action = 'Press [ENTER] or [X] to rescan PnP hardware bus & heal Wi-Fi/system stack.'
            $r.Key = 'x'; $r.KeyLabel = 'run Full Net Reset'
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
    Out-Line @((Seg 'dim' '  Select profile [1-5], or press any other key to cancel '), (Seg 'accent!' $script:G.prompt)) -NoNewline
    $k = Read-Choice
    Out-Line @()
    $map = @{ '1' = 'Adaptive'; '2' = 'DHCP'; '3' = 'Hybrid'; '4' = 'Cloudflare'; '5' = 'ResetDHCP' }
    $c = [string]$k.KeyChar
    if ($map.ContainsKey($c)) {
        Set-DnsProfileMode $map[$c]
        Out-Line @()
        Out-Line @((Seg 'dim' '  press any key to return'))
        Wait-AnyKey
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
    Out-Line @((Seg 'dim' '  Select profile [1-4], or press any other key to cancel '), (Seg 'accent!' $script:G.prompt)) -NoNewline
    $k = Read-Choice
    Out-Line @()
    $map = @{ '1' = 'Adaptive'; '2' = 'Ethernet'; '3' = 'Wifi'; '4' = 'Windows' }
    $c = [string]$k.KeyChar
    if ($map.ContainsKey($c)) {
        Set-RouteProfileMode $map[$c]
        Out-Line @()
        Out-Line @((Seg 'dim' '  press any key to return'))
        Wait-AnyKey
    }
}
function Write-HealSummary($r, $sw) {
    $w = Get-UiWidth
    $info = Get-StateInfo ([string]$(if ($r) { $r.Problem } else { 'Offline' }))
    Out-Line @()
    Out-Rule $w
    Out-Line @((Seg $info.Role ('  ' + $script:G.dot + '  ')), (Seg ($info.Role + '!') $info.Word), (Seg 'dim' ('   {0} {1} changed {0} {2} failed {0} {3:N1} s' -f $script:G.mid, $script:ChangeCount, $script:FailCount, $sw.Elapsed.TotalSeconds)))
}
function Start-Interactive {
    if (Test-InputRedirected) { Write-Host 'The control center needs a real console. Use -Mode Heal, Diagnose, QuickProbe, SelfTest ... for scripted runs.' -ForegroundColor Yellow; return }
    if ($script:IsAdmin) { [void](Invoke-WithLock -WaitMs 3000 -Block { $script:WatchdogOn = Test-WatchdogInstalled; Update-WatchdogIfStale }) }
    Enter-Screen
    try {
        $t = New-Telemetry
        $adv = Get-Advice $t
        Show-Dashboard $t $adv          # instant skeleton, then the real reading
        $t = Get-Telemetry; $adv = Get-Advice $t
        $draw = $true
        $lastTel = Get-Date
        $lastW = Get-UiWidth
        while ($true) {
            if ($draw) { Show-Dashboard $t $adv; $draw = $false; $lastW = Get-UiWidth }
            $key = $null
            while ($null -eq $key) {
                if (Test-KeyAvailable) { $key = Read-KeyNow; break }
                if ($t.GwIp -and (Update-Pulse $t.GwIp)) {
                    if ($null -ne $script:LiveGwRtt) { $t.GwRtt = $script:LiveGwRtt }
                    if ($script:Ui.Vt) {
                        if (-not (Update-PulseRow $t)) { Show-Dashboard $t $adv }
                    }
                }   # ping a silent gateway too: the lost replies ARE the picture
                if ((Get-UiWidth) -ne $lastW) { $draw = $true; break }
                $ivl = 12; if ($t.Problem -ne 'Healthy' -and $t.Problem -ne 'Online') { $ivl = 25 }   # probes can take seconds while the network is down: ask less often then
                if (((Get-Date) - $lastTel).TotalSeconds -ge $ivl) {
                    $t2 = Get-Telemetry; $lastTel = Get-Date
                    if ($null -ne $script:LiveGwRtt) { $t2.GwRtt = $script:LiveGwRtt }
                    if ((Get-Sig $t2) -ne (Get-Sig $t)) { $t = $t2; $adv = Get-Advice $t; $draw = $true; break }
                    $t = $t2
                }
                Start-Sleep -Milliseconds 60
            }
            if ($draw -and $null -eq $key) { continue }
            if ($null -eq $key) { continue }
            $ch = ([string]$key.KeyChar).ToLower()
            if ($key.Key -eq 'Enter') { $ch = [string]$adv.Key }
            if ($key.Key -eq 'Spacebar' -or $key.KeyChar -eq ' ') { $ch = '' }
            if ($key.Key -eq 'Escape') { $ch = '' }
            if ($ch -eq 'q') { break }
            Clear-InputBuffer
            if (-not $ch) { $t = Get-Telemetry; if ($null -ne $script:LiveGwRtt) { $t.GwRtt = $script:LiveGwRtt }; $adv = Get-Advice $t; $lastTel = Get-Date; $draw = $true; continue }
            $handled = Invoke-DashboardKey $ch $adv
            Clear-InputBuffer
            if ($handled) {
                Clear-Screen
                $script:LiveGwRtt = $null
                $t = Get-Telemetry; $adv = Get-Advice $t; $lastTel = Get-Date; $draw = $true
            }
        }
    } finally { Exit-Screen }
}
$script:IsAdmin = Test-IsAdmin
$adminModes = @('Interactive', 'Heal', 'AutoHeal', 'Omnifix', 'FullNetReset', 'FlushCache', 'InstallWatchdog', 'UninstallWatchdog', 'InstallShield', 'UninstallShield', 'ResetFactory', 'SetDnsProfile', 'SetRouteProfile')
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
            $argLine = '/c ""' + $script:SelfPath + '" ' + ($parts -join ' ') + '"'
            Start-Process -FilePath (Join-Path $script:Sys32 'cmd.exe') -ArgumentList $argLine -Verb RunAs -ErrorAction Stop
            $elevated = $true
        } catch { Write-Host 'Administrator approval was not granted.' -ForegroundColor Yellow }
    }
    if ($elevated) { exit 0 }
    if ($Mode -ne 'Interactive') { Write-Host '[x] This mode needs Administrator rights.' -ForegroundColor Red; exit 1 }
}
if ($script:UiOn) { Initialize-Ui }
if ($script:IsAdmin) { Initialize-Store }
$script:State = Get-State
$exitCode = 0
try {
    if ($script:UiOn -and $Mode -ne 'Interactive') { Write-Banner ("{0}{1}" -f $Mode, $(if ($script:IsDry) { ' (dry run)' } else { '' })) }
    switch ($Mode) {
        'AutoHeal' { [void](Invoke-AutoHeal) }
        'Omnifix'      { Invoke-SupremeOmnifix }
        'FullNetReset' { Invoke-SupremeOmnifix }
        'SetRouteProfile' { Set-RouteProfileMode $RouteProfile }
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
        'Diagnose'   { Show-Diagnostics }
        'Report'     { New-SupportReport }
        'QuickProbe' { Run-QuickProbe }
        'FlushCache' { [void](Invoke-WithLock { Flush-NetworkCache }) }
        'InstallWatchdog'   { [void](Invoke-WithLock { Install-Watchdog }) }
        'InstallShield'     { [void](Invoke-WithLock { Install-Watchdog }) }
        'UninstallWatchdog' { [void](Invoke-WithLock { Uninstall-Watchdog }) }
        'UninstallShield'   { [void](Invoke-WithLock { Uninstall-Watchdog }) }
        'ResetFactory'      { [void](Invoke-WithLock { Restore-Everything }) }
        'LaunchPortal'      { [void](Invoke-WithLock { Open-Portal -Force }) }
        'SetDnsProfile'     { Set-DnsProfileMode $DnsProfile }
        'SelfTest'          { Invoke-SelfTest }
        'Interactive'       { Start-Interactive }
    }
} catch {
    Write-Log 'FAIL' ("Unhandled error: " + $_.Exception.Message)
    Write-Log 'FAIL' ([string]$_.ScriptStackTrace)
    $exitCode = 1
} finally {
    Save-State
    Exit-Lock
    if ($script:UiOn) { Exit-Screen }
}
if ($exitCode -eq 0 -and $script:FailCount -gt 0 -and (@('AutoHeal', 'Heal', 'Omnifix', 'FullNetReset') -contains $Mode)) { $exitCode = 2 }
if ($script:UiOn -and $Mode -ne 'Interactive' -and -not $NoPause -and $Host.Name -eq 'ConsoleHost') {
    Write-Host ''
    Write-Host 'Press any key to close...' -ForegroundColor Gray
    Wait-AnyKey
}
exit $exitCode
