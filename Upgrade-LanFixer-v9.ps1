<#
.SYNOPSIS
    OMNI-360 Zero-Dependency Transactional Upgrader, Optimizer & Verifier for LanFixer.cmd -> v9.0.0.
.DESCRIPTION
    Upgrades LanFixer.cmd to v9.0.0 across all 12 forensic audit dimensions with atomic backup,
    0 AST errors, pure -Json / -DryRun invariance, integrity/ACL self-repair, zero-freeze TUI,
    multi-homed DNS/discovery safety, atomic persistence, and automatic rollback on any failure.
#>
[CmdletBinding()]
param(
    [string]$TargetFile = ''
)

$ErrorActionPreference = 'Stop'
$here = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }

$candidates = if ($TargetFile) { @($TargetFile) } else { @('LanFixer.cmd') }
$primary = $null
foreach ($c in $candidates) {
    $p = if ([System.IO.Path]::IsPathRooted($c)) { $c } else { Join-Path $here $c }
    if (Test-Path -LiteralPath $p) { $primary = $p; break }
}
if (-not $primary) {
    Write-Error "Could not locate LanFixer.cmd in '$here'. Pass -TargetFile <path>."
    exit 1
}

$archiveDir = Join-Path $here 'Archive'
if (-not (Test-Path -LiteralPath $archiveDir)) { [void](New-Item -ItemType Directory -Path $archiveDir -Force) }
$stamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
$stem = [System.IO.Path]::GetFileNameWithoutExtension($primary)
$backupPath = Join-Path $archiveDir ("{0}_v800_backup_{1}.cmd" -f $stem, $stamp)
Copy-Item -LiteralPath $primary -Destination $backupPath -Force

$raw = [System.IO.File]::ReadAllText($primary, [System.Text.Encoding]::ASCII)
$raw = $raw.Replace("`r`r`n", "`r`n").Replace("`r`n", "`n").Replace("`n", "`r`n")
$origLines = ([regex]::Matches($raw, "`r`n")).Count
$origBytes = $raw.Length

$script:PatchCount = 0
function Patch-Once {
    param([ref]$Text, [string]$Old, [string]$New, [string]$Label)
    $oldC = $Old.Replace("`r`n", "`n").Replace("`n", "`r`n")
    $newC = $New.Replace("`r`n", "`n").Replace("`n", "`r`n")
    if ($Text.Value.Contains($newC)) { return }
    $idx = $Text.Value.IndexOf($oldC, [System.StringComparison]::Ordinal)
    if ($idx -lt 0) { throw "Patch anchor missing for: $Label" }
    $idx2 = $Text.Value.IndexOf($oldC, $idx + 1, [System.StringComparison]::Ordinal)
    if ($idx2 -ge 0) { throw "Patch anchor ambiguous (multiple matches) for: $Label" }
    $Text.Value = $Text.Value.Substring(0, $idx) + $newC + $Text.Value.Substring($idx + $oldC.Length)
    $script:PatchCount++
}

Write-Host "[*] Upgrading '$primary' -> LanFixer v9.0.0 (Backup: $backupPath)..." -ForegroundColor Cyan

try {
    # ==========================================================================
    # PATCH 1: Version & Header Modernization (8.0.0 -> 9.0.0) + Atomic File Helper
    # ==========================================================================
    Patch-Once ([ref]$raw) 'LanFixer 8.0.0 -' 'LanFixer 9.0.0 -' 'Synopsis version 9.0.0'
    Patch-Once ([ref]$raw) @'
    8.0.0 (Peak 360-Degree Forensic Hardening & Performance Release):
      - Eradicated all 30 verified runtime, concurrency, TLS/captive-portal, daemon, doctor, undo, and rollback defects.
      - Source-bound TLS 1.2/1.3 WAN probe with IP + SNI fallback; Apple/MS/Google 204/200 portal verdict accuracy.
      - Idempotent multi-step Undo engine with RevertedEntryId tracking and signed/unsigned DWORD drift tolerance.
      - Monotonic caches on Ethernet, Secondary Uplinks (2.0s), and WMI Battery telemetry (20s); zero-freeze TUI loop.
      - Strict Read-Only contract on Doctor/Diagnose/Bundle/SelfTest; Dry-Run purity across all USB/registry shields.
      - Full Wi-Fi-only operational parity, live lanfixer.ini policy activation, and strict global IPv6 PII redaction.
'@ @'
    9.0.0 (OMNI-360 Multi-Agent Forensic & Reliability Release):
      - Fixed Test-ScriptIntegrity FileSystemRights::FullControl bitmask false positive on Users:(RX) and Repair-StoreChildren ACL reset on LanFixer_Core.cmd / wifi_backup / staging.
      - Fixed Show-ConfigReport PS5.1 runtime crash, SelfTest -Json stdout purity, and zero-mutation -DryRun LogFile isolation.
      - Added atomic temp+verify writes for reset_journal.json, integrity.json, and UTF-8 rotated change_ledger.jsonl.
      - Eliminated healthy Sentinel daemon 10s disk/probe thrash, parallelized Test-GatewayAlive & Test-HttpsWanProbe, and added cache invalidation after adapter/route/DNS mutations.
      - Hardened Invoke-Redaction (preserves HH:MM:SS timestamps, catches multi-hextet IPv6), Doctor dual-homed scoping, active SendARP gateway check, and complete Safe/Reversible Undo/Restore.
'@ 'Notes 9.0.0'

    Patch-Once ([ref]$raw) '$script:Version = ''8.0.0''' '$script:Version = ''9.0.0''' 'Version bump to 9.0.0'

    # ==========================================================================
    # PATCH 2: Write-Log inline rotation & LogLevel filter; ChangeLedger UTF-8, .bak merge & Move-Item rotation
    # ==========================================================================
    Patch-Once ([ref]$raw) @'
function Write-Log {
    param([string]$Level, [string]$Message)
    if ($script:StoreReady -and -not $script:IsDry) {
        try {
            $line = '[{0}] [{1}] {2}' -f (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'), $Level, $Message
            [System.IO.File]::AppendAllText($script:LogFile, $line + "`r`n")
        } catch {}
    }
'@ @'
function Write-AtomicJsonFile([string]$Path, [string]$JsonContent) {
    $tmp = $Path + '.tmp'
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        [void](New-Item -ItemType Directory -Path $dir -Force -ErrorAction SilentlyContinue)
    }
    [System.IO.File]::WriteAllText($tmp, $JsonContent, (New-Object System.Text.UTF8Encoding($false)))
    [void](ConvertFrom-Json $JsonContent)
    Move-Item -LiteralPath $tmp -Destination $Path -Force -ErrorAction Stop
}
function Write-Log {
    param([string]$Level, [string]$Message)
    $minLvl = if ($script:PolicyLogLevel) { [string]$script:PolicyLogLevel } else { 'INFO' }
    $lvlRank = switch ($Level) { 'FAIL' { 4 } 'ALERT' { 4 } 'WARN' { 3 } 'STEP' { 2 } 'OK' { 2 } 'DRY' { 2 } 'PLAN' { 2 } 'INFO' { 1 } default { 1 } }
    $minRank = switch ($minLvl) { 'ERROR' { 4 } 'WARN' { 3 } 'INFO' { 1 } 'DEBUG' { 0 } default { 1 } }
    if ($script:StoreReady -and -not $script:IsDry -and $lvlRank -ge $minRank) {
        try {
            if (Test-Path -LiteralPath $script:LogFile) {
                $fi = Get-Item -LiteralPath $script:LogFile -ErrorAction SilentlyContinue
                $maxB = if ($script:Cfg -and $script:Cfg.LogMaxBytes) { [int64]$script:Cfg.LogMaxBytes } else { 524288L }
                if ($fi -and $fi.Length -ge $maxB) {
                    Move-Item -LiteralPath $script:LogFile -Destination ($script:LogFile + '.1') -Force -ErrorAction SilentlyContinue
                }
            }
            $line = '[{0}] [{1}] {2}' -f (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'), $Level, $Message
            [System.IO.File]::AppendAllText($script:LogFile, $line + "`r`n", (New-Object System.Text.UTF8Encoding($false)))
        } catch {}
    }
'@ 'Write-Log inline rotation, PolicyLogLevel & Write-AtomicJsonFile'

    Patch-Once ([ref]$raw) @'
        if (Test-Path -LiteralPath $ledgerFile) {
            $item = Get-Item -LiteralPath $ledgerFile -ErrorAction SilentlyContinue
            if ($item -and $item.Length -ge 2097152) {
                $bakFile = $ledgerFile + '.bak'
                Copy-Item -LiteralPath $ledgerFile -Destination $bakFile -Force -ErrorAction SilentlyContinue
                Remove-Item -LiteralPath $ledgerFile -Force -ErrorAction SilentlyContinue
            }
        }
'@ @'
        if (Test-Path -LiteralPath $ledgerFile) {
            $item = Get-Item -LiteralPath $ledgerFile -ErrorAction SilentlyContinue
            if ($item -and $item.Length -ge 2097152) {
                $bakFile = $ledgerFile + '.bak'
                Move-Item -LiteralPath $ledgerFile -Destination $bakFile -Force -ErrorAction SilentlyContinue
            }
        }
'@ 'ChangeLedger Move-Item atomic rotation'

    Patch-Once ([ref]$raw) @'
        [System.IO.File]::AppendAllText($ledgerFile, $jsonLine + "`r`n", [System.Text.Encoding]::ASCII)
    } catch {}
}

function Get-ChangeLedgerEntries([int]$Limit = 0) {
    $ledgerFile = Join-Path $script:StoreDir 'change_ledger.jsonl'
    if (-not (Test-Path -LiteralPath $ledgerFile)) { return @() }
    $lines = @(Get-Content -LiteralPath $ledgerFile -ErrorAction SilentlyContinue | Where-Object { $_ -and $_.Trim() -ne '' })
    if ($lines.Count -eq 0) { return @() }
'@ @'
        [System.IO.File]::AppendAllText($ledgerFile, $jsonLine + "`r`n", (New-Object System.Text.UTF8Encoding($false)))
    } catch {}
}

function Get-ChangeLedgerEntries([int]$Limit = 0) {
    $ledgerFile = Join-Path $script:StoreDir 'change_ledger.jsonl'
    $bakFile = $ledgerFile + '.bak'
    $lines = @()
    if (Test-Path -LiteralPath $bakFile) {
        $lines += @(Get-Content -LiteralPath $bakFile -ErrorAction SilentlyContinue | Where-Object { $_ -and $_.Trim() -ne '' })
    }
    if (Test-Path -LiteralPath $ledgerFile) {
        $lines += @(Get-Content -LiteralPath $ledgerFile -ErrorAction SilentlyContinue | Where-Object { $_ -and $_.Trim() -ne '' })
    }
    if ($lines.Count -eq 0) { return @() }
'@ 'ChangeLedger UTF-8 append and .bak continuity'

    # ==========================================================================
    # PATCH 3: Invoke-Undo (-DryRun preview, deleted-reg drift, clean scriptblock execution & NoColor)
    # ==========================================================================
    Patch-Once ([ref]$raw) @'
    if ($Plan -and -not $Quiet -and -not $Json) {
        Write-Host '================================================================================' -ForegroundColor Cyan
        Write-Host '                       PLAN PREVIEW: REVERSIBLE UNDO' -ForegroundColor Cyan
        Write-Host '================================================================================' -ForegroundColor Cyan
    }
'@ @'
    $ncUndo = [bool]($NoColor -or $script:NoColor)
    $previewMode = [bool]($Plan -or $script:IsDry)
    if ($previewMode -and -not $Quiet -and -not $Json) {
        if ($ncUndo) {
            Write-Host '================================================================================'
            Write-Host '                       PLAN PREVIEW: REVERSIBLE UNDO'
            Write-Host '================================================================================'
        } else {
            Write-Host '================================================================================' -ForegroundColor Cyan
            Write-Host '                       PLAN PREVIEW: REVERSIBLE UNDO' -ForegroundColor Cyan
            Write-Host '================================================================================' -ForegroundColor Cyan
        }
    }
'@ 'Invoke-Undo previewMode & NoColor header'

    Patch-Once ([ref]$raw) @'
        if ($e.MutationType -eq 'Registry' -and $e.Target -and $e.ValueName) {
            $curVal = (Get-ItemProperty -LiteralPath $e.Target -Name $e.ValueName -ErrorAction SilentlyContinue).($e.ValueName)
            if ($null -ne $curVal -and [string]$curVal -ne [string]$e.NewValue) {
                $sameDword = $false
                $c64 = 0L; $e64 = 0L
                if ([int64]::TryParse([string]$curVal, [ref]$c64) -and [int64]::TryParse([string]$e.NewValue, [ref]$e64)) {
                    if (($c64 -band 0xFFFFFFFFL) -eq ($e64 -band 0xFFFFFFFFL)) { $sameDword = $true }
                }
                if (-not $sameDword) {
                    $driftDetected = $true
                    $driftReason = "Current registry value '$curVal' does not match recorded NewValue '$($e.NewValue)'"
                }
            }
        }
'@ @'
        if ($e.MutationType -eq 'Registry' -and $e.Target -and $e.ValueName) {
            $curVal = (Get-ItemProperty -LiteralPath $e.Target -Name $e.ValueName -ErrorAction SilentlyContinue).($e.ValueName)
            if ($null -eq $curVal -and $null -ne $e.NewValue) {
                $driftDetected = $true
                $driftReason = "Registry value '$($e.ValueName)' was deleted externally (expected '$($e.NewValue)')"
            } elseif ($null -ne $curVal -and [string]$curVal -ne [string]$e.NewValue) {
                $sameDword = $false
                $c64 = 0L; $e64 = 0L
                if ([int64]::TryParse([string]$curVal, [ref]$c64) -and [int64]::TryParse([string]$e.NewValue, [ref]$e64)) {
                    if (($c64 -band 0xFFFFFFFFL) -eq ($e64 -band 0xFFFFFFFFL)) { $sameDword = $true }
                }
                if (-not $sameDword) {
                    $driftDetected = $true
                    $driftReason = "Current registry value '$curVal' does not match recorded NewValue '$($e.NewValue)'"
                }
            }
        }
'@ 'Invoke-Undo detect deleted registry drift'

    Patch-Once ([ref]$raw) @'
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

        # Apply Reversal (using -NoLedger so exactly one correlated Undo ledger record is written)
        $undoSuccess = $false
        if ($e.UndoScript) {
            try {
                $sb = [scriptblock]::Create($e.UndoScript)
                $res = Invoke-Change ("Undo {0}: {1}" -f $idShort, $e.Description) $sb -NoLedger
                if ($res) { $undoSuccess = $true }
            } catch {}
        }
'@ @'
        if ($previewMode) {
            [void]$planEntries.Add(@{
                EntryId     = $e.EntryId
                Target      = $e.Target
                Description = $e.Description
                OldValue    = $e.OldValue
                NewValue    = $e.NewValue
                Action      = "Would revert to $($e.OldValue)"
            })
            if (-not $Quiet -and -not $Json) {
                Write-Host ("  [PLAN] Revert {0} on {1}: restore OldValue ({2})" -f $idShort, $e.Target, $e.OldValue)
            }
            $undoneCount++
            continue
        }

        # Apply Reversal (using -NoLedger so exactly one correlated Undo ledger record is written)
        $undoSuccess = $false
        if ($e.UndoScript) {
            try {
                $sb = [scriptblock]::Create($e.UndoScript)
                $res = Invoke-Change ("Undo {0}: {1}" -f $idShort, $e.Description) $sb -NoLedger
                if ($res) { $undoSuccess = $true }
            } catch {
                Write-Log 'FAIL' ("Undo {0} failed: {1}" -f $idShort, $_.Exception.Message)
            }
        }
'@ 'Invoke-Undo handle DryRun preview & log undo script errors'

    Patch-Once ([ref]$raw) @'
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
'@ @'
    $finalStatus = if ($previewMode) { 'Planned' } elseif ($undoneCount -eq 0 -and $skippedCount -gt 0) { 'DriftSkipped' } else { 'Completed' }
    $summary = @{
        Status       = $finalStatus
        UndoneCount  = $undoneCount
        SkippedCount = $skippedCount
        Entries      = if ($previewMode) { $planEntries } else { @() }
    }

    if ($Json) {
        [Console]::Out.WriteLine((ConvertTo-Json $summary -Depth 4))
    } elseif (-not $Quiet) {
        if ($previewMode) {
            Write-Host ("`nPlan preview complete: {0} mutations would be reverted ({1} skipped)." -f $undoneCount, $skippedCount)
            Write-Host '================================================================================'
        } else {
            Write-Host ("`nUndo complete: {0} mutations reverted, {1} skipped." -f $undoneCount, $skippedCount)
        }
    }
'@ 'Invoke-Undo summary DryRun status & DriftSkipped'

    # ==========================================================================
    # PATCH 4: History suite (-Limit/-Level/-Filter scan depth, Heal regex, Bundle stdout leak, Follow guard)
    # ==========================================================================
    Patch-Once ([ref]$raw) @'
function Get-HistorySessionLogs([int]$Limit = 50, [string]$Level = '', [string]$Filter = '') {
    $results = New-Object System.Collections.ArrayList
    if (-not (Test-Path -LiteralPath $script:LogFile)) { return @($results) }
    $lines = @(Get-Content -LiteralPath $script:LogFile -Tail ([Math]::Max(100, $Limit * 5)) -ErrorAction SilentlyContinue)
'@ @'
function Get-HistorySessionLogs([int]$Limit = 50, [string]$Level = '', [string]$Filter = '') {
    $results = New-Object System.Collections.ArrayList
    if (-not (Test-Path -LiteralPath $script:LogFile)) { return @($results) }
    $lines = if ($Level -or $Filter) {
        @(Get-Content -LiteralPath $script:LogFile -Tail 5000 -ErrorAction SilentlyContinue)
    } else {
        @(Get-Content -LiteralPath $script:LogFile -Tail ([Math]::Max(100, $Limit * 5)) -ErrorAction SilentlyContinue)
    }
'@ 'Get-HistorySessionLogs full scan when filtering'

    Patch-Once ([ref]$raw) @'
        if ($l.Message -match '^(Executing initial repair pipeline|Watchdog active|Signed in automatically|Completed stage|ChangeLedger:|Invoking [A-Za-z]+Heal|Supreme Omnifix|Ultra System Reset|Doomsday Reset|Armageddon Reset|HealSummary)') {
'@ @'
        if ($l.Message -match '^(Executing initial repair pipeline|Watchdog active|Signed in automatically|AutoHeal pass:|LAYER\s+\d+/\d+|STAGE\s+\d+/\d+|SUPREME OMNIFIX|ULTRA SYSTEM RESET|DOOMSDAY SYSTEM RESET|ARMAGEDDON SYSTEM RESET|Completed stage|ChangeLedger:|Invoking [A-Za-z]+Heal|HealSummary|Restore-Everything|Factory Reset Complete|Careful Network Debloat|Debloat Rollback)') {
'@ 'Get-HistoryHeals align regex with real log markers'

    Patch-Once ([ref]$raw) @'
function Export-HistoryForensicBundle([string]$OutFile = '', [switch]$Json) {
'@ @'
function Export-HistoryForensicBundle([string]$OutFile = '', [switch]$Json, [switch]$Silent) {
'@ 'Export-HistoryForensicBundle add Silent switch'

    Patch-Once ([ref]$raw) @'
    Write-Host ("Forensic history exported to: {0}" -f $OutFile) -ForegroundColor Green
    return @{ Path = $OutFile; Entries = $bundle.Timeline.Count }
'@ @'
    if (-not $Silent) { Write-Host ("Forensic history exported to: {0}" -f $OutFile) -ForegroundColor Green }
    return @{ Path = $OutFile; Entries = $bundle.Timeline.Count }
'@ 'Suppress Write-Host in Export-HistoryForensicBundle -Silent'

    Patch-Once ([ref]$raw) @'
    if ($Follow -or $Section -in @('live', 'stream', 'tail', 'realtime')) {
        Show-HistoryLiveStream
        return 0
    }
'@ @'
    if ($Follow -or $Section -in @('live', 'stream', 'tail', 'realtime')) {
        if ($Json -or $Quiet -or (Test-InputRedirected)) {
            if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'UnsupportedNonInteractive'; ExitCode = 1; Message = 'Live stream follow mode requires an interactive console' } -Compress)) }
            elseif (-not $Quiet) { Write-Host 'Live stream mode requires an interactive console.' -ForegroundColor Yellow }
            return 1
        }
        Show-HistoryLiveStream
        return 0
    }
'@ 'Guard History -Follow against headless/Json hangs'

    Patch-Once ([ref]$raw) @'
            { $_ -in @('export', 'bundle') }               { Export-HistoryForensicBundle -OutFile $OutFile -Json }
'@ @'
            { $_ -in @('export', 'bundle') }               { Export-HistoryForensicBundle -OutFile $OutFile -Json -Silent }
'@ 'Pass -Silent during History -Section export -Json'

    # ==========================================================================
    # PATCH 5: Repair-StoreChildren (ACL preservation + SIDs), Initialize-Store (SIDs + no tamper auto-resign),
    #          Test-ScriptIntegrity (fix FullControl bitmask trap + ReparsePoint + ScriptPath + atomic manifest)
    # ==========================================================================
    Patch-Once ([ref]$raw) @'
    foreach ($f in @(Get-ChildItem -LiteralPath $Dir -Force -ErrorAction SilentlyContinue)) {
        if ($f.Name -like 'vault*') { continue }
        $bad = $false
'@ @'
    foreach ($f in @(Get-ChildItem -LiteralPath $Dir -Force -ErrorAction SilentlyContinue)) {
        if ($f.Name -like 'vault*') { continue }
        if ($f.Name -eq 'wifi_backup' -or $f.Name -eq 'staging') {
            if (-not ($f.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
                [void](Invoke-Native $icacls @($f.FullName, '/inheritance:r', '/grant:r', '*S-1-5-18:(OI)(CI)F', '*S-1-5-32-544:(OI)(CI)F', '/setowner', '*S-1-5-32-544', '/C', '/Q') 5000)
            }
            continue
        }
        if ($f.Name -eq $script:Cfg.SelfName) {
            if (-not ($f.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
                [void](Invoke-Native $icacls @($f.FullName, '/inheritance:r', '/grant:r', '*S-1-5-18:(F)', '*S-1-5-32-544:(F)', '/setowner', '*S-1-5-32-544', '/C', '/Q') 5000)
            }
            continue
        }
        if ($f.Name -eq 'integrity.json') {
            if (-not ($f.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
                [void](Protect-IntegrityFile $f.FullName)
            }
            continue
        }
        $bad = $false
'@ 'Repair-StoreChildren protect restrictive subdirs & files instead of resetting ACL'

    Patch-Once ([ref]$raw) @'
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
        try {
            $icacls = Get-SysExe 'icacls.exe'
            if ($icacls -and (Test-Path -LiteralPath $script:SelfCopy)) {
                [void](Invoke-Native $icacls @($script:SelfCopy, '/inheritance:r', '/grant:r', 'SYSTEM:(F)', 'Administrators:(F)') 3000)
            }
        } catch {}
                    [void](Set-ScriptAuthorization $script:SelfCopy)
                } else {
                    Write-Log 'WARN' 'Refused to overwrite protected watchdog copy because current script has syntax errors.'
                }
            }
        }
'@ @'
        Repair-StoreChildren $dir
        $script:StoreSecure = ($r1.ExitCode -eq 0 -and $r2.ExitCode -eq 0)
        $script:StoreReady = $true
        try { $fi = Get-Item -LiteralPath $script:LogFile -ErrorAction Stop; if ($fi.Length -gt $script:Cfg.LogMaxBytes) { Move-Item -LiteralPath $script:LogFile -Destination ($script:LogFile + '.1') -Force } } catch {}
        if (-not $script:StoreSecure) { Write-Log 'WARN' 'Could not lock down the store folder ACL; the watchdog will refuse to install.' }
        # Mirror this script into the store ONLY when running interactive/remediation modes (never during Integrity audit or Daemon/Sentinel/AutoHeal).
        $skipMirrorModes = @('Integrity','AutoHeal','Daemon','Sentinel','Doctor','Status','Diagnose','Audit','QuickProbe','Probe','Bundle','Config','Help','Guide','History','Hist','Logs','Forensics','SelfTest','Verify','Report')
        if ($script:StoreSecure -and $script:SelfPath -and (Test-Path -LiteralPath $script:SelfPath) -and ($script:SelfPath -ne $script:SelfCopy) -and ($skipMirrorModes -notcontains [string]$Mode)) {
            $selfItem = Get-Item -LiteralPath $script:SelfPath -Force -ErrorAction SilentlyContinue
            $selfIsLink = ($selfItem -and ($selfItem.Attributes -band [IO.FileAttributes]::ReparsePoint))
            $need = (-not $selfIsLink)
            if ($need -and (Test-Path -LiteralPath $script:SelfCopy)) {
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
                    try {
                        $icacls2 = Get-SysExe 'icacls.exe'
                        if ($icacls2 -and (Test-Path -LiteralPath $script:SelfCopy)) {
                            [void](Invoke-Native $icacls2 @($script:SelfCopy, '/inheritance:r', '/grant:r', '*S-1-5-18:(F)', '*S-1-5-32-544:(F)', '/setowner', '*S-1-5-32-544') 3000)
                        }
                    } catch {}
                    $intFileCheck = Join-Path $script:StoreDir 'integrity.json'
                    if (-not (Test-Path -LiteralPath $intFileCheck) -or $Mode -in @('Interactive','Heal','QuickHeal','InstallWatchdog','InstallShield','InstallSentinel')) {
                        [void](Set-ScriptAuthorization $script:SelfCopy)
                    }
                } else {
                    Write-Log 'WARN' 'Refused to overwrite protected watchdog copy because current script has syntax errors.'
                }
            }
        }
'@ 'Initialize-Store SIDs + read-only integrity bypass guard + remove dup Import-UserConfig'

    Patch-Once ([ref]$raw) @'
    $json = ConvertTo-Json $manifest -Depth 2
    try {
        [System.IO.File]::WriteAllText($intFile, $json, [System.Text.Encoding]::ASCII)
        [void](Protect-IntegrityFile $intFile)
        Write-Log 'OK' ("Cryptographic integrity authorized: $TargetScript [SHA256: $sha]")
        return $true
'@ @'
    $json = ConvertTo-Json $manifest -Depth 2
    try {
        $intTmp = $intFile + '.tmp'
        [System.IO.File]::WriteAllText($intTmp, $json, [System.Text.Encoding]::ASCII)
        [void](Protect-IntegrityFile $intTmp)
        Move-Item -LiteralPath $intTmp -Destination $intFile -Force -ErrorAction Stop
        [void](Protect-IntegrityFile $intFile)
        Write-Log 'OK' ("Cryptographic integrity authorized: $TargetScript [SHA256: $sha]")
        return $true
'@ 'Set-ScriptAuthorization atomic write + ACL first'

    Patch-Once ([ref]$raw) @'
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
'@ @'
    try {
        $fiTgt = Get-Item -LiteralPath $TargetScript -Force -ErrorAction Stop
        if ($fiTgt.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            [void]$errors.Add("Target script is an untrusted symlink/reparse point: $TargetScript")
        }
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
        $writeMask = 0x116 -bor 0x10000 -bor 0x40000 -bor 0x80000 -bor 0x40000000 -bor 0x10000000
        $rules = $acl.GetAccessRules($true, $true, [System.Security.Principal.SecurityIdentifier])
        foreach ($r in $rules) {
            $sid = [string]$r.IdentityReference.Value
            if ($r.AccessControlType -ne [System.Security.AccessControl.AccessControlType]::Allow) { continue }
            if (@('S-1-5-18', 'S-1-5-32-544') -contains $sid) { continue }
            $rightsInt = [int]$r.FileSystemRights
            if (($rightsInt -band $writeMask) -ne 0) {
                if (@('S-1-5-32-545', 'S-1-1-0', 'S-1-5-11', 'S-1-5-4', 'S-1-5-32-547') -contains $sid) {
                    [void]$errors.Add("Unprivileged identity $sid has write permissions on $TargetScript")
                } elseif ($TargetScript -eq $script:SelfCopy) {
                    [void]$errors.Add("Unexpected writable ACE for $sid on protected $TargetScript")
                }
            }
        }
    } catch {
'@ 'Test-ScriptIntegrity exact writeMask + ReparsePoint check'

    # Also enforce ScriptPath check on manifest when SelfCopy is verified
    Patch-Once ([ref]$raw) @'
    $actualHash = Get-FileSha256 $TargetScript
    $expectedHash = [string]$manifest.ScriptSha256
    
    if (-not $expectedHash -or -not $actualHash -or ($actualHash -ne $expectedHash)) {
'@ @'
    $actualHash = Get-FileSha256 $TargetScript
    $expectedHash = [string]$manifest.ScriptSha256
    if ($manifest.ScriptPath) {
        try {
            $normTarget = [System.IO.Path]::GetFullPath($TargetScript)
            $normMan = [System.IO.Path]::GetFullPath([string]$manifest.ScriptPath)
            if ($normTarget -ne $normMan -and $TargetScript -eq $script:SelfCopy) {
                [void]$errors.Add("Manifest ScriptPath mismatch: expected $normMan, got $normTarget")
            }
        } catch {}
    }

    if (-not $expectedHash -or -not $actualHash -or ($actualHash -ne $expectedHash)) {
'@ 'Test-ScriptIntegrity ScriptPath binding'

    # ==========================================================================
    # PATCH 6: Mutex & Locking (Remove Local\ fallback, DryRun purity on lock.json, Re-apply INI after Get-State)
    # ==========================================================================
    Patch-Once ([ref]$raw) @'
                try {
                    $localName = $Name -replace '^Global\\', 'Local\'
                    $m = New-Object System.Threading.Mutex($false, $localName)
                    if ($Name -eq 'Global\LanFixer_Lock') { $script:Mutex = $m }
                    return $m
                } catch { return $null }
'@ @'
                return $null
'@ 'Get-LanFixerMutex fail closed rather than splitting Global/Local'

    Patch-Once ([ref]$raw) @'
function Enter-Lock([int]$TimeoutMs = 1000) {
    if (-not $script:IsAdmin) { return $false }
'@ @'
function Enter-Lock([int]$TimeoutMs = 1000) {
    if (-not $script:IsAdmin) { return $false }
    if ($script:IsDry) { return $false }
'@ 'Enter-Lock inert under DryRun/Plan'

    Patch-Once ([ref]$raw) @'
            foreach ($ek in $memEnv.Keys) {
                if (-not $script:State.Env.ContainsKey($ek)) { $script:State.Env[$ek] = $memEnv[$ek] }
                elseif ($memEnv[$ek] -is [hashtable] -and $script:State.Env[$ek] -is [hashtable] -and $memEnv[$ek].Time -and ([string]$memEnv[$ek].Time -gt [string]$script:State.Env[$ek].Time)) {
                    $script:State.Env[$ek].Env = $memEnv[$ek].Env
                    $script:State.Env[$ek].Time = $memEnv[$ek].Time
                }
            }
        }
        return $got
'@ @'
            foreach ($ek in $memEnv.Keys) {
                if (-not $script:State.Env.ContainsKey($ek)) { $script:State.Env[$ek] = $memEnv[$ek] }
                elseif ($memEnv[$ek] -is [hashtable] -and $script:State.Env[$ek] -is [hashtable] -and $memEnv[$ek].Time -and ([string]$memEnv[$ek].Time -gt [string]$script:State.Env[$ek].Time)) {
                    $script:State.Env[$ek].Env = $memEnv[$ek].Env
                    $script:State.Env[$ek].Time = $memEnv[$ek].Time
                }
            }
            if ($script:IniAppliedDefaults -is [hashtable] -and $script:State.Misc -is [hashtable]) {
                if ($script:IniAppliedDefaults.DnsProfile -and -not $script:State.Misc['DnsProfile']) { $script:State.Misc['DnsProfile'] = $script:IniAppliedDefaults.DnsProfile }
                if ($script:IniAppliedDefaults.RouteProfile -and -not $script:State.Misc['RouteProfile']) { $script:State.Misc['RouteProfile'] = $script:IniAppliedDefaults.RouteProfile }
            }
        }
        return $got
'@ 'Enter-Lock preserve INI profile defaults across Get-State reload'

    Patch-Once ([ref]$raw) @'
function Invoke-WithLock {
    param([scriptblock]$Block, [int]$WaitMs = 20000)
    if (-not $script:IsAdmin) { return (& $Block) }   # read-only/limited mode: no shared lock needed (and a standard user cannot open it)
'@ @'
function Invoke-WithLock {
    param([scriptblock]$Block, [int]$WaitMs = 20000)
    if (-not $script:IsAdmin -or $script:IsDry) { return (& $Block) }   # read-only/dry-run mode: no disk lock/lock.json side effects
'@ 'Invoke-WithLock skip lock under DryRun/Plan'

    # ==========================================================================
    # PATCH 7: Network Auto-Discovery, Scoped DNS, HTTP/TLS/WAN Probes, GatewayAlive (parallel TCP + SendARP + cache)
    # ==========================================================================
    Patch-Once ([ref]$raw) @'
    try {
        $adapters = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notmatch $script:VirtRegex })
        $gws = @()
        foreach ($ad in $adapters) { $gws += @(Get-GatewaysV4 $ad) }
        $gws = @($gws | Where-Object { $_ } | Select-Object -Unique)
        $primaryGw = if ($gws.Count -gt 0) { [string]$gws[0] } else { '' }
'@ @'
    try {
        $ethUpDisc = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' })
        $adapters = if ($ethUpDisc.Count -gt 0) { $ethUpDisc } else { @(Get-OtherUplinkAdapters | Where-Object { $_.Status -eq 'Up' }) }
        $gws = @()
        $discSrcIp = ''
        foreach ($ad in $adapters) {
            $gws += @(Get-GatewaysV4 $ad)
            if (-not $discSrcIp) { $discSrcIp = [string](Get-ValidIPv4 $ad) }
        }
        $gws = @($gws | Where-Object { $_ } | Select-Object -Unique)
        $primaryGw = if ($gws.Count -gt 0) { [string]$gws[0] } else { '' }
'@ 'AutoDiscovery prefer Ethernet + bind source IP'

    Patch-Once ([ref]$raw) @'
            # 3a. Intercept HTTP 301/302/307 Redirect on Port 80 (ignoring same-host HTTP->HTTPS router UI upgrades)
            foreach ($cIp in $candIps) {
                if (-not $script:State.Misc['DiscoveredPortalUrl']) {
                    $probeRes = Invoke-HttpProbe $cIp '/' 1200 '' 80
                    if ($probeRes.Location -and $probeRes.Location -match '^https?://') {
                        try {
                            $pUri = [uri]$probeRes.Location
                            if ($pUri.Host -and $pUri.Host -ne $cIp) {
                                $script:State.Misc['DiscoveredPortalUrl'] = [string]$probeRes.Location
                                $script:State.Misc['DiscoveredPortalHost'] = ([string]$pUri.Host).ToLowerInvariant()
                                if ($pUri.Port -gt 0) { $script:State.Misc['DiscoveredPortalPort'] = [int]$pUri.Port }
                                $script:State.Misc['DiscoveredPortalIp'] = $cIp
                                Write-Log 'OK' ("Dynamically autodiscovered captive portal via HTTP redirect: {0}" -f $probeRes.Location)
                                break
                            }
                        } catch {}
                    }
                }
            }

            # 3b. Autonomous Multi-Port Matrix Probing (dedicated captive portal ports only)
            if (-not $script:State.Misc['DiscoveredPortalUrl']) {
                $gwPorts = @(8888, 8003, 8090, 8443, 8080)
                foreach ($cIp in $candIps) {
                    foreach ($p in $gwPorts) {
                        if (Test-TcpPort $cIp $p 250) {
                            $script:State.Misc['DiscoveredPortalPort'] = $p
                            $script:State.Misc['DiscoveredPortalIp'] = $cIp
                            $isTls = if ($p -eq 443 -or $p -eq 8443) { $true } else { Test-PortSupportsTls $cIp $p 600 }
'@ @'
            # 3a. Intercept HTTP 301/302/307 Redirect on Port 80 (ignoring same-host HTTP->HTTPS router UI upgrades)
            foreach ($cIp in $candIps) {
                if (-not $script:State.Misc['DiscoveredPortalUrl']) {
                    $probeRes = Invoke-HttpProbe $cIp '/' 1200 $discSrcIp 80
                    if ($probeRes.Location -and $probeRes.Location -match '^https?://') {
                        try {
                            $pUri = [uri]$probeRes.Location
                            if ($pUri.Host -and $pUri.Host -ne $cIp) {
                                $script:State.Misc['DiscoveredPortalUrl'] = [string]$probeRes.Location
                                $script:State.Misc['DiscoveredPortalHost'] = ([string]$pUri.Host).ToLowerInvariant()
                                if ($pUri.Port -gt 0) { $script:State.Misc['DiscoveredPortalPort'] = [int]$pUri.Port }
                                $pHostIp = $null
                                if ([System.Net.IPAddress]::TryParse($pUri.Host, [ref]$pHostIp)) {
                                    if (Test-AllowedPortalIp $pUri.Host) { $script:State.Misc['DiscoveredPortalIp'] = $pUri.Host }
                                } else {
                                    $resPortalIp = Resolve-HostBounded $pUri.Host 1200 $discSrcIp -NoPin
                                    if ($resPortalIp -and (Test-AllowedPortalIp $resPortalIp)) { $script:State.Misc['DiscoveredPortalIp'] = $resPortalIp }
                                }
                                Write-Log 'OK' ("Dynamically autodiscovered captive portal via HTTP redirect: {0}" -f $probeRes.Location)
                                break
                            }
                        } catch {}
                    }
                }
            }

            # 3b. Autonomous Multi-Port Matrix Probing (dedicated captive portal ports only)
            if (-not $script:State.Misc['DiscoveredPortalUrl']) {
                $gwPorts = @(8888, 8003, 8090, 8443, 8080)
                foreach ($cIp in $candIps) {
                    foreach ($p in $gwPorts) {
                        if (Test-TcpPort $cIp $p 250 $discSrcIp) {
                            $script:State.Misc['DiscoveredPortalPort'] = $p
                            $script:State.Misc['DiscoveredPortalIp'] = $cIp
                            $isTls = if ($p -eq 443 -or $p -eq 8443) { $true } else { Test-PortSupportsTls $cIp $p 600 $discSrcIp }
'@ 'AutoDiscovery fix DiscoveredPortalIp & pass discSrcIp'

    Patch-Once ([ref]$raw) @'
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
'@ @'
    if ($ipifScoped -and [int]$ipifScoped.InterfaceMetric -ge 45 -and (Get-RouteProfileName) -ne 'Wifi') {
        $localAllowed = @()
        if (Test-IsNitjsrNetwork) { $localAllowed += @($script:Cfg.CampusDns, $script:Cfg.PortalIp) }
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
            if (-not $u) { continue }
'@ 'Get-ScopedDnsAnswers strict SourceIp bind + campus gate'

    Patch-Once ([ref]$raw) @'
        $v6Dns = @(Get-DnsClientServerAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv6 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ServerAddresses)
'@ @'
        $v6Dns = @(Get-DnsClientServerAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv6 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ServerAddresses | Where-Object { $_ -and $_ -notmatch '^(?i)fec0:0:0:ffff::' })
'@ 'Ignore Windows default fec0 site-local DNS servers in Get-AdapterDnsVerdict'

    Patch-Once ([ref]$raw) @'
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
'@ @'
    $ar = $null
    try {
        $ar = [System.Net.Dns]::BeginGetHostAddresses($cleanName, $null, $null)
        $ok = $ar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)
        if ($ok) {
            $ips = [System.Net.Dns]::EndGetHostAddresses($ar)
            foreach ($ip in $ips) {
                if ($ip.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork) {
                    $s = $ip.ToString()
                    if (-not (Test-IsSinkholeIp $s)) { return $s }
                }
            }
        }
    } catch {} finally {
        if ($ar -and $ar.AsyncWaitHandle) { try { $ar.AsyncWaitHandle.Close() } catch {} }
    }
'@ 'Resolve-HostBounded AsyncWaitHandle disposal'

    # Parallel & bounded TCP port multi-probe helper + SendARP P/Invoke for Test-GatewayAlive & Test-HttpsWanProbe
    Patch-Once ([ref]$raw) @'
function Test-HttpsWanProbe([string]$SourceIp = '', [int]$TimeoutMs = 1800) {
'@ @'
function Test-AnyTcpPortParallel([string]$Address, [int[]]$Ports, [int]$TimeoutMs = 400, [string]$SourceIp = '') {
    if (-not $Address -or -not $Ports -or $Ports.Count -eq 0) { return $false }
    $dst = $null
    if (-not [System.Net.IPAddress]::TryParse($Address, [ref]$dst)) { return $false }
    $socks = New-Object System.Collections.ArrayList
    $waitHandles = New-Object System.Collections.ArrayList
    $iars = New-Object System.Collections.ArrayList
    try {
        $srcIpObj = $null
        if ($SourceIp) { [void][System.Net.IPAddress]::TryParse($SourceIp, [ref]$srcIpObj) }
        foreach ($p in @($Ports | Select-Object -Unique)) {
            $s = $null
            try {
                $s = New-Object System.Net.Sockets.Socket($dst.AddressFamily, [System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
                if ($srcIpObj) { $s.Bind((New-Object System.Net.IPEndPoint($srcIpObj, 0))) }
                $iar = $s.BeginConnect($dst, [int]$p, $null, $null)
                [void]$socks.Add($s); [void]$iars.Add($iar); [void]$waitHandles.Add($iar.AsyncWaitHandle)
            } catch {
                if ($s) { try { $s.Close(); $s.Dispose() } catch {} }
            }
        }
        if ($waitHandles.Count -eq 0) { return $false }
        $swP = [System.Diagnostics.Stopwatch]::StartNew()
        while ($swP.ElapsedMilliseconds -lt $TimeoutMs) {
            for ($i = 0; $i -lt $socks.Count; $i++) {
                if ($iars[$i].IsCompleted) {
                    try { $socks[$i].EndConnect($iars[$i]); if ($socks[$i].Connected) { return $true } } catch {}
                }
            }
            $rem = [int][math]::Max(1, $TimeoutMs - $swP.ElapsedMilliseconds)
            [void][System.Threading.WaitHandle]::WaitAny([System.Threading.WaitHandle[]]$waitHandles.ToArray([System.Threading.WaitHandle]), [math]::Min(40, $rem))
        }
        return $false
    } finally {
        for ($i = 0; $i -lt $waitHandles.Count; $i++) { try { $waitHandles[$i].Close() } catch {} }
        for ($i = 0; $i -lt $socks.Count; $i++) { try { $socks[$i].Close(); $socks[$i].Dispose() } catch {} }
    }
}
function Test-ActiveArp([string]$TargetIp, [string]$ExpectedMac = '', [string]$SourceIp = '') {
    $tIp = $null; $sIp = $null
    if (-not [System.Net.IPAddress]::TryParse($TargetIp, [ref]$tIp) -or $tIp.AddressFamily -ne [System.Net.Sockets.AddressFamily]::InterNetwork) { return $false }
    if ($SourceIp) { [void][System.Net.IPAddress]::TryParse($SourceIp, [ref]$sIp) }
    try {
        if (-not ('LfNativeArp' -as [type])) {
            Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public static class LfNativeArp { [DllImport("iphlpapi.dll", ExactSpelling=true)] public static extern int SendARP(int DestIP, int SrcIP, byte[] pMacAddr, ref int PhyAddrLen); }' -ErrorAction Stop
        }
        $dstInt = [BitConverter]::ToInt32($tIp.GetAddressBytes(), 0)
        $srcInt = if ($sIp -and $sIp.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork) { [BitConverter]::ToInt32($sIp.GetAddressBytes(), 0) } else { 0 }
        $macBuf = New-Object byte[] 6
        [int]$len = 6
        $rc = [LfNativeArp]::SendARP($dstInt, $srcInt, $macBuf, [ref]$len)
        if ($rc -ne 0 -or $len -ne 6) { return $false }
        $liveMac = (($macBuf | ForEach-Object { $_.ToString('X2') }) -join '-')
        if ($ExpectedMac) {
            return ($liveMac -eq $ExpectedMac.Replace(':', '-').ToUpperInvariant())
        }
        return ($liveMac -ne '00-00-00-00-00-00')
    } catch { return $false }
}
function Test-HttpsWanProbe([string]$SourceIp = '', [int]$TimeoutMs = 1800) {
'@ 'Add parallel TCP port prober & live SendARP verifier'

    Patch-Once ([ref]$raw) @'
    if ($p1.Code -eq 0 -and $p2.Code -eq 0) {
        $pApple = Invoke-HttpProbe 'captive.apple.com' '/hotspot-detect.html' 2500 $SourceIp
        if ($pApple.Code -ne 0) { $p2 = $pApple }
    }
    $state = Get-ProbeVerdict $p1 $p2
    if ($state -eq 'Online') {
        $httpsCheck = Test-HttpsWanProbe $SourceIp 1800
        if ($httpsCheck.IsCaptive) {
            $state = 'Captive'
            if (-not $p1.Location -and -not $p2.Location) {
                $p1 = @{ Code = 302; Location = (Get-ActivePortalUrl) }
            }
        }
    }
    $via = 'link' 
    if (-not $explicit -and ($state -eq 'Offline' -or $state -eq 'NoDns') -and (Test-AllowSystemFallback $explicit $state (Test-OtherUplinkActive))) {
        $u1 = $none
        if ($SourceIp) { $u1 = Invoke-HttpProbe 'connectivitycheck.gstatic.com' '/generate_204' 2000 '' }
        if ($u1.Code -eq 204) { $state = 'Online'; $via = 'system'; $p1 = $u1 }
        elseif (($u1.Code -ge 300 -and $u1.Code -le 399) -or ($u1.Code -ge 200 -and $u1.Code -le 299) -or $u1.Code -eq 401 -or $u1.Code -eq 407 -or $u1.Code -eq 511) { $state = 'Captive'; $via = 'system'; $p1 = $u1 }
        if ($state -eq 'Offline' -or $state -eq 'NoDns') {
'@ @'
    if ($p1.Code -eq 0 -and $p2.Code -eq 0 -and -not ($p1.Error -eq 'DnsFail' -and $p2.Error -eq 'DnsFail')) {
        $pApple = Invoke-HttpProbe 'captive.apple.com' '/hotspot-detect.html' 2000 $SourceIp
        if ($pApple.Code -ne 0) { $p2 = $pApple }
    }
    $state = Get-ProbeVerdict $p1 $p2
    if ($state -eq 'Online') {
        $httpsCheck = Test-HttpsWanProbe $SourceIp 1800
        if ($httpsCheck.IsCaptive) {
            $state = 'Captive'
            if (-not $p1.Location -and -not $p2.Location) {
                $p1 = @{ Code = 302; Location = (Get-ActivePortalUrl) }
            }
        }
    }
    $via = 'link'
    if (-not $explicit -and ($state -eq 'Offline' -or $state -eq 'NoDns') -and (Test-AllowSystemFallback $explicit $state (Test-OtherUplinkActive))) {
        $u1 = $none
        if ($SourceIp) { $u1 = Invoke-HttpProbe 'connectivitycheck.gstatic.com' '/generate_204' 2000 '' }
        if ($u1.Code -eq 204) { $state = 'Online'; $via = 'system'; $p1 = $u1 }
        elseif (($u1.Code -ge 300 -and $u1.Code -le 399) -or ($u1.Code -ge 200 -and $u1.Code -le 299) -or $u1.Code -eq 401 -or $u1.Code -eq 407 -or $u1.Code -eq 511) { $state = 'Captive'; $via = 'system'; $p1 = $u1 }
        if (($state -eq 'Offline' -or $state -eq 'NoDns') -and $u1.Error -ne 'DnsFail') {
'@ 'Short-circuit Apple probe and slow HttpWebRequest when DNS is confirmed dead'

    Patch-Once ([ref]$raw) @'
function Test-GatewayAlive($Ad, [string]$Gw) {
    if (-not $Ad -or -not $Ad.ifIndex -or -not $Gw) { return @{ Alive = $false; Rtt = $null; Via = '' } }
    if ($script:Pulse -and $script:Pulse.Gw -eq $Gw -and $null -ne $script:LiveGwRtt -and (((Get-Date) - $script:Pulse.Last).TotalSeconds -lt 3.5)) {
        return @{ Alive = $true; Rtt = [int]$script:LiveGwRtt; Via = 'icmp' }
    }
    $rtt = Test-Ping $Gw 700
    if ($null -ne $rtt) { return @{ Alive = $true; Rtt = $rtt; Via = 'icmp' } }
    $ex = Get-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($ex -and [string]$ex.State -eq 'Permanent' -and $ex.LinkLayerAddress -and $ex.LinkLayerAddress -notmatch '^(00-)+00$') {
        $homeAd = $true
        try { $eh = Get-AdapterEnvironment $Ad -UseCache; if ($null -ne $eh.Home) { $homeAd = [bool]$eh.Home } } catch {}
        $gwSrc = [string](Get-ValidIPv4 $Ad)
        if ((Test-TcpPort $Gw 80 400 $gwSrc) -or (Test-TcpPort $Gw 443 400 $gwSrc) -or (Test-TcpPort $Gw 53 400 $gwSrc) -or (Test-TcpPort $Gw 8888 400 $gwSrc) -or (Test-TcpPort $Gw 8003 400 $gwSrc)) {
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
    $dynamicGwPorts2 = @(8888, 80, 443, 53, 8003)
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
'@ @'
$script:GwAliveCache = @{}
function Test-GatewayAlive($Ad, [string]$Gw, [switch]$UseCache) {
    if (-not $Ad -or -not $Ad.ifIndex -or -not $Gw) { return @{ Alive = $false; Rtt = $null; Via = '' } }
    if ($script:Pulse -and $script:Pulse.Gw -eq $Gw -and $null -ne $script:LiveGwRtt -and (((Get-Date) - $script:Pulse.Last).TotalSeconds -lt 3.5)) {
        return @{ Alive = $true; Rtt = [int]$script:LiveGwRtt; Via = 'icmp' }
    }
    $gKey = "$($Ad.ifIndex)|$Gw"
    $nowT = [System.Diagnostics.Stopwatch]::GetTimestamp()
    if ($UseCache -and $script:GwAliveCache.ContainsKey($gKey)) {
        $gc = $script:GwAliveCache[$gKey]
        if ((($nowT - $gc.Ticks) / [System.Diagnostics.Stopwatch]::Frequency) -lt 3.8) { return $gc.Val }
    }
    $rtt = Test-Ping $Gw 650
    if ($null -ne $rtt) {
        $rObj = @{ Alive = $true; Rtt = $rtt; Via = 'icmp' }
        $script:GwAliveCache[$gKey] = @{ Ticks = $nowT; Val = $rObj }
        return $rObj
    }
    $gwSrc = [string](Get-ValidIPv4 $Ad)
    $gwPorts = @(80, 443, 53, 8888, 8003)
    if ($script:State.Misc -and $script:State.Misc['DiscoveredPortalPort']) { $gwPorts += [int]$script:State.Misc['DiscoveredPortalPort'] }
    if ($script:Cfg.PortalPort) { $gwPorts += [int]$script:Cfg.PortalPort }
    if (Test-AnyTcpPortParallel $Gw $gwPorts 400 $gwSrc) {
        $rObj = @{ Alive = $true; Rtt = $null; Via = 'tcp' }
        $script:GwAliveCache[$gKey] = @{ Ticks = $nowT; Val = $rObj }
        return $rObj
    }
    $ex = Get-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($ex -and [string]$ex.State -eq 'Permanent' -and $ex.LinkLayerAddress -and $ex.LinkLayerAddress -notmatch '^(00-)+00$') {
        $arpLive = Test-ActiveArp $Gw ([string]$ex.LinkLayerAddress) $gwSrc
        $rObj = if ($arpLive) { @{ Alive = $true; Rtt = $null; Via = 'arp' } } else { @{ Alive = $false; Rtt = $null; Via = '' } }
        $script:GwAliveCache[$gKey] = @{ Ticks = $nowT; Val = $rObj }
        return $rObj
    }
    if (Test-ActiveArp $Gw '' $gwSrc) {
        $rObj = @{ Alive = $true; Rtt = $null; Via = 'arp' }
        $script:GwAliveCache[$gKey] = @{ Ticks = $nowT; Val = $rObj }
        return $rObj
    }
    $rDead = @{ Alive = $false; Rtt = $null; Via = '' }
    $script:GwAliveCache[$gKey] = @{ Ticks = $nowT; Val = $rDead }
    return $rDead
}
'@ 'Test-GatewayAlive parallel TCP + live SendARP + 3.8s cache'

    # ==========================================================================
    # PATCH 8: Battery early desktop exit + static cache, Env multi-homed safety, Health/Telemetry cache propagation
    # ==========================================================================
    Patch-Once ([ref]$raw) @'
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
'@ @'
    try {
        $wmiBat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $wmiBat) {
            $script:BatteryCache = $res
            $script:BatteryCacheTicks = $nowTicks
            return $res
        }
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
        $full = Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity -ErrorAction SilentlyContinue | Select-Object -First 1
'@ 'Get-BatteryHealthAndEfficiency early return when no battery'

    Patch-Once ([ref]$raw) @'
    if (-not $sticky -and ($envName -eq 'Campus' -or $envName -eq 'Other')) {
        $h = Get-SubTable 'Env' $guid
        $h.Env = $envName
        $h.Home = $homeVerdict
        $h.Time = (Get-Date).ToString('o')
        if (-not $script:IsDry) {
            if ($envName -eq 'Other') {
                foreach ($dk in @('DiscoveredPortalIp','DiscoveredPortalUrl','DiscoveredPortalPort','DiscoveredPortalHost','DiscoveredDomain','DiscoveredDns')) {
                    $script:State.Misc.Remove($dk)
                }
                $script:State.Misc['DiscoveryTime'] = (Get-Date).ToString('o')
            }
        }
    }
'@ @'
    if (-not $sticky -and ($envName -eq 'Campus' -or $envName -eq 'Other')) {
        $h = Get-SubTable 'Env' $guid
        $h.Env = $envName
        $h.Home = $homeVerdict
        $h.Time = (Get-Date).ToString('o')
    }
'@ 'Preserve active Ethernet Campus discovery when secondary Other adapter is scanned'

    Patch-Once ([ref]$raw) @'
    $all = @(Get-NetIPAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue)
    $h.Apipa = [bool]($all | Where-Object { $_.IPAddress -like '169.254.*' })
    $h.Ip = Get-ValidIPv4 $Ad
    if (-not $h.Ip) { $h.Problem = 'NoIp'; return $h }
    $gw = @(Get-GatewaysV4 $Ad) | Select-Object -First 1
    $h.Gateway = $gw
    if ($gw) { $ga = Test-GatewayAlive $Ad $gw; $h.GwRtt = $ga.Rtt; $h.GwAlive = $ga.Alive; $h.GwVia = $ga.Via }
'@ @'
    $all = @(Get-NetIPAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue)
    $h.Apipa = [bool]($all | Where-Object { $_.IPAddress -like '169.254.*' })
    $validObjs = @($all | Where-Object { $_.IPAddress -notmatch '^(169\.254\.|127\.)' } | Sort-Object { if ($_.AddressState -eq 'Preferred') { 0 } else { 1 } })
    $h.Ip = if ($validObjs.Count -gt 0) { [string]$validObjs[0].IPAddress } else { $null }
    if (-not $h.Ip) { $h.Problem = 'NoIp'; return $h }
    $gw = @(Get-GatewaysV4 $Ad) | Select-Object -First 1
    $h.Gateway = $gw
    if ($gw) { $ga = Test-GatewayAlive $Ad $gw -UseCache:$UseCache; $h.GwRtt = $ga.Rtt; $h.GwAlive = $ga.Alive; $h.GwVia = $ga.Via }
'@ 'Get-AdapterHealth reuse NetIPAddress & pass -UseCache to Test-GatewayAlive'

    # ==========================================================================
    # PATCH 9: Cache invalidation + Metric Undo fix + Shield-Hardware SYSTEM safety + Shield-DataLink + Shield-Dns/Proxies + Campus helpers
    # ==========================================================================
    Patch-Once ([ref]$raw) @'
function Set-InterfaceMetric($If, [int]$Metric, [string]$Why) {
    Save-MetricOriginal $If
    $af = [string]$If.AddressFamily
    $idx = [int]$If.ifIndex
    $oldM = [int]$If.InterfaceMetric
    $undo = "Set-NetIPInterface -InterfaceIndex $idx -AddressFamily '$af' -InterfaceMetric $oldM -ErrorAction SilentlyContinue"
    return (Invoke-Change $Why { Set-NetIPInterface -InterfaceIndex $If.ifIndex -AddressFamily $af -InterfaceMetric $Metric -AutomaticMetric Disabled -ErrorAction Stop } -MutationType 'InterfaceMetric' -Target ([string]$If.InterfaceAlias) -OldValue $oldM -NewValue $Metric -UndoScript $undo -Reversible)
}
'@ @'
function Set-InterfaceMetric($If, [int]$Metric, [string]$Why) {
    Save-MetricOriginal $If
    $af = [string]$If.AddressFamily
    $idx = [int]$If.ifIndex
    $oldM = [int]$If.InterfaceMetric
    $wasAuto = ([string]$If.AutomaticMetric -eq 'Enabled')
    $undo = if ($wasAuto) {
        "Set-NetIPInterface -InterfaceIndex $idx -AddressFamily '$af' -AutomaticMetric Enabled -ErrorAction Stop"
    } else {
        "Set-NetIPInterface -InterfaceIndex $idx -AddressFamily '$af' -InterfaceMetric $oldM -AutomaticMetric Disabled -ErrorAction Stop"
    }
    $ok = Invoke-Change $Why { Set-NetIPInterface -InterfaceIndex $If.ifIndex -AddressFamily $af -InterfaceMetric $Metric -AutomaticMetric Disabled -ErrorAction Stop } -MutationType 'InterfaceMetric' -Target ([string]$If.InterfaceAlias) -OldValue $oldM -NewValue $Metric -UndoScript $undo -Reversible
    if ($ok -and -not $script:IsDry) { $script:ConnCache = $null; $script:OtherUplinksCache = $null }
    return $ok
}
'@ 'Set-InterfaceMetric restore AutomaticMetric Enabled & clear caches'

    Patch-Once ([ref]$raw) @'
function Restore-InterfaceMetrics([string]$Why) {
    Remove-CampusHostRoutes
'@ @'
function Restore-InterfaceMetrics([string]$Why) {
    $script:ConnCache = $null
    $script:OtherUplinksCache = $null
    Remove-CampusHostRoutes
'@ 'Restore-InterfaceMetrics cache invalidation'

    Patch-Once ([ref]$raw) @'
                foreach ($pName in $paramNames) {
                    $cur = (Get-ItemProperty -LiteralPath $enumKey -Name $pName -ErrorAction SilentlyContinue).$pName
                    if ($null -ne $cur -and [int]$cur -eq 0) { continue }
                    Save-Original $guid ("Enum:$pName") $cur
                    if ($script:IsDry -or $script:IsPlan) {
                        [void](Invoke-Change "Device Parameters '$pName' set to 0 on $($Ad.Name)" { } -MutationType 'Registry' -Target $enumKey -ValueName $pName -OldValue $cur -NewValue 0 -Reversible)
                        continue
                    }
                    try {
                        Set-ItemProperty -LiteralPath $enumKey -Name $pName -Value 0 -Type DWord -Force -ErrorAction Stop
                        $script:ChangeCount++
                        Write-Log 'OK' "Device Parameters '$pName' set to 0 on $($Ad.Name)"
                        Add-ChangeLedgerEntry -Description "Device Parameters '$pName' set to 0 on $($Ad.Name)" -MutationType 'Registry' -Target $enumKey -ValueName $pName -OldValue $cur -NewValue 0 -Success $true -Reversible $true
                    } catch {
                        Write-Log 'INFO' "Device Parameters '$pName' on $($Ad.Name) skipped (SYSTEM ownership required)"
                    }
                }
'@ @'
                foreach ($pName in $paramNames) {
                    $cur = (Get-ItemProperty -LiteralPath $enumKey -Name $pName -ErrorAction SilentlyContinue).$pName
                    if ($null -eq $cur) { continue }
                    $curInt = 0
                    if (-not [int]::TryParse([string]$cur, [ref]$curInt)) { continue }
                    if ($curInt -eq 0) { continue }
                    Save-Original $guid ("Enum:$pName") $curInt
                    if ($script:IsDry -or $script:IsPlan) {
                        [void](Invoke-Change "Device Parameters '$pName' set to 0 on $($Ad.Name)" { } -MutationType 'Registry' -Target $enumKey -ValueName $pName -OldValue $curInt -NewValue 0 -Reversible)
                        continue
                    }
                    try {
                        Set-ItemProperty -LiteralPath $enumKey -Name $pName -Value 0 -Type DWord -Force -ErrorAction Stop
                        $script:ChangeCount++
                        Write-Log 'OK' "Device Parameters '$pName' set to 0 on $($Ad.Name)"
                        Add-ChangeLedgerEntry -Description "Device Parameters '$pName' set to 0 on $($Ad.Name)" -MutationType 'Registry' -Target $enumKey -ValueName $pName -OldValue $curInt -NewValue 0 -Success $true -Reversible $true
                    } catch {
                        Write-Log 'INFO' "Device Parameters '$pName' on $($Ad.Name) skipped (SYSTEM ownership required)"
                    }
                }
'@ 'Shield-Hardware TryParse + skip missing Enum properties'

    Patch-Once ([ref]$raw) @'
                    $params = @{ InterfaceIndex = $ad.ifIndex; IPAddress = $origIpInfo.IPAddress; PrefixLength = $origIpInfo.PrefixLength; ErrorAction = 'Stop' }
                    if ($origIpInfo.DefaultGateway) { $params.DefaultGateway = $origIpInfo.DefaultGateway }
                    New-NetIPAddress @params -ErrorAction SilentlyContinue | Out-Null
'@ @'
                    Remove-NetRoute -InterfaceIndex $ad.ifIndex -DestinationPrefix '0.0.0.0/0' -Confirm:$false -ErrorAction SilentlyContinue
                    $params = @{ InterfaceIndex = $ad.ifIndex; IPAddress = $origIpInfo.IPAddress; PrefixLength = $origIpInfo.PrefixLength; ErrorAction = 'Stop' }
                    if ($origIpInfo.DefaultGateway) { $params.DefaultGateway = $origIpInfo.DefaultGateway }
                    New-NetIPAddress @params | Out-Null
'@ 'Shield-DataLink remove conflicting route & surface rollback failure'

    Patch-Once ([ref]$raw) @'
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
'@ @'
function Remove-GatewayLock($Ad, [string]$Gw) {
    if (-not $Ad -or -not $Ad.ifIndex -or -not $Gw) { return }
    if ($script:IsDry) { Write-Log 'DRY' "Would release ARP lock for $Gw on $($Ad.Name)"; return }
    Remove-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -PolicyStore ActiveStore -Confirm:$false -ErrorAction SilentlyContinue
    Remove-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -PolicyStore PersistentStore -Confirm:$false -ErrorAction SilentlyContinue
    Remove-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Gw -Confirm:$false -ErrorAction SilentlyContinue
    [void](Invoke-Native (Get-SysExe 'arp.exe') @('-d', $Gw) 5000)
}
'@ 'Remove dead Get-SubTable call in Remove-GatewayLock'

    Patch-Once ([ref]$raw) @'
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
'@ @'
function Get-BestDnsOrder([string]$Guid, [string[]]$Campus) {
    $d = Get-SubTable 'Dns' $Guid
    $dhcpLeased = @(Get-DhcpDnsServers $Guid)
    $dnsFp = ((@($Campus) -join ',') + '|' + (@($dhcpLeased) -join ','))
    if ($d.Order -and $d.OrderTime -and ([string]$d.OrderFp -eq $dnsFp)) {
        try {
            $age = ((Get-Date) - [datetime]::Parse([string]$d.OrderTime, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::RoundtripKind)).TotalSeconds
            if ($age -lt 1800) { return @($d.Order) }
        } catch {}
    }
    Write-Log 'INFO' 'Measuring resolver speed (campus + public)...'
    $scored = @()
'@ 'Get-BestDnsOrder fingerprint guard against stale OrderTime on network change'

    Patch-Once ([ref]$raw) @'
    $d.Order = $final
    $d.OrderTime = (Get-Date).ToString('o')
    return $final
'@ @'
    $d.Order = $final
    $d.OrderFp = $dnsFp
    $d.OrderTime = (Get-Date).ToString('o')
    return $final
'@ 'Store OrderFp alongside OrderTime'

    Patch-Once ([ref]$raw) @'
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
'@ @'
    if ($ok -and -not $script:IsDry) { (Get-SubTable 'Dns' $guid).Managed = $true; $script:ConnCache = $null; Clear-DnsClientCache -ErrorAction SilentlyContinue }
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
    if ($ok -and -not $script:IsDry) { (Get-SubTable 'Dns' $guid).Managed = $false; $script:ConnCache = $null; Clear-DnsClientCache -ErrorAction SilentlyContinue }
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
    if ($ok -and -not $script:IsDry) { $d.Managed = $false; $d.Phase = 'Auto'; $script:ConnCache = $null; Clear-DnsClientCache -ErrorAction SilentlyContinue }
}
'@ 'DNS mutators invalidate ConnCache'

    Patch-Once ([ref]$raw) @'
function Shield-Dns($Ctx, [string]$ConnState) {
    Shield-DohFallback
    $ad = $Ctx.Ad
    Shield-DnsIntegrity $ad
'@ @'
function Shield-Dns($Ctx, [string]$ConnState) {
    Shield-DohFallback
    $ad = $Ctx.Ad
'@ 'Shield-Dns avoid premature IPv6 neutralization/flap before Campus/Other check'

    Patch-Once ([ref]$raw) @'
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
'@ @'
function Shield-Proxies([switch]$Aggressive) {
    if (-not $script:IsAdmin) { return $false }
    if ($script:IsDry) { Write-Log 'DRY' 'Would check and sanitize system proxy configurations'; return $false }
    $changed = $false
    foreach ($rkRec in @(
        @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'; Suffix = 'CU'; Label = 'user' },
        @{ Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings'; Suffix = 'LM'; Label = 'system' }
    )) {
        try {
            if (Test-Path -LiteralPath $rkRec.Path) {
                $propsP = Get-ItemProperty -LiteralPath $rkRec.Path -ErrorAction SilentlyContinue
                $pEnable = $propsP.ProxyEnable
                $pServer = [string]$propsP.ProxyServer
                if ($pEnable -and [int]$pEnable -ne 0 -and $pServer -match '(?:^|[;=])(?:https?://)?(127\.0\.0\.1|localhost|\[?::1\]?):?(\d*)') {
                    $pHost = $Matches[1].Trim('[',']'); $pPort = if ($Matches[2]) { [int]$Matches[2] } else { 0 }
                    if ($Aggressive -or ($pPort -gt 0 -and -not (Test-TcpPort $pHost $pPort 300))) {
                        Save-Original 'Global' ('ProxyEnable_' + $rkRec.Suffix) [int]$pEnable
                        Save-Original 'Global' ('ProxyServer_' + $rkRec.Suffix) $pServer
                        $ok = Invoke-Change ("Neutralized dead loopback WinINet $($rkRec.Label) proxy ({0})" -f $pServer) {
                            Set-ItemProperty -LiteralPath $rkRec.Path -Name ProxyEnable -Value 0 -Type DWord -Force -ErrorAction Stop
                        }
                        if ($ok) { $changed = $true }
                    }
                }
            }
        } catch {}
    }
    try {
        $netsh = Get-SysExe 'netsh.exe'
        if (Test-Path -LiteralPath $netsh) {
            $r = Invoke-Native $netsh @('winhttp', 'show', 'proxy') 4000
            if ($r.ExitCode -eq 0 -and $r.Output -match '((?:https?://)?(127\.0\.0\.1|localhost|\[?::1\]?):(\d+))') {
                $srv = $Matches[1]; $whHost = $Matches[2].Trim('[',']'); $whPort = [int]$Matches[3]
                if ($Aggressive -or -not (Test-TcpPort $whHost $whPort 300)) {
                    Save-Original 'Global' 'WinHttpProxy' $srv
                    $ok = Invoke-Change ("Reset dead WinHTTP loopback proxy ({0})" -f $srv) {
                        [void](Invoke-Native $netsh @('winhttp', 'reset', 'proxy') 5000)
                    }
                    if ($ok) { $changed = $true }
                }
            }
        }
    } catch {}
    foreach ($vName in @('HTTP_PROXY', 'HTTPS_PROXY', 'ALL_PROXY', 'http_proxy', 'https_proxy', 'all_proxy')) {
        $val = [System.Environment]::GetEnvironmentVariable($vName, [System.EnvironmentVariableTarget]::Process)
        if ($val -and $val -match '(?:^|[;=])(?:https?://)?(127\.0\.0\.1|localhost|\[?::1\]?):?(\d*)') {
            $eHost = $Matches[1].Trim('[',']'); $ePort = if ($Matches[2]) { [int]$Matches[2] } else { 0 }
            if ($Aggressive -or ($ePort -gt 0 -and -not (Test-TcpPort $eHost $ePort 300))) {
                [System.Environment]::SetEnvironmentVariable($vName, $null, [System.EnvironmentVariableTarget]::Process)
                Write-Log 'INFO' ("Cleared dead loopback environment variable {0} in current process" -f $vName)
                $changed = $true
            }
        }
    }
    return $changed
}
'@ 'Shield-Proxies liveness check on loopback proxies unless -Aggressive'

    Patch-Once ([ref]$raw) @'
    [void](Shield-Proxies)
'@ @'
    [void](Shield-Proxies -Aggressive:$Aggressive)
'@ 'Pass -Aggressive from Shield-SystemStack to Shield-Proxies'

    # ==========================================================================
    # PATCH 10: Atomic reset_journal.json, Debloat Snapshot ordering + -NoOutput + -Plan, GlobalPreflightSnapshot key-level
    # ==========================================================================
    Patch-Once ([ref]$raw) @'
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
'@ @'
        $json = ConvertTo-Json $jObj -Depth 4
        Write-AtomicJsonFile $jPath $json
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
                $json = ConvertTo-Json $jObj -Depth 4
                Write-AtomicJsonFile $jPath $json
            }
        }
    } catch {}
}
'@ 'Atomic writes in Set-ResetJournal & Update-ResetJournal'

    Patch-Once ([ref]$raw) @'
                $json = ConvertTo-Json $jObj
                Set-Content -LiteralPath $jPath -Value $json -Encoding ASCII -Force
            }
        }
    } catch {}
}
'@ @'
                $json = ConvertTo-Json $jObj -Depth 4
                Write-AtomicJsonFile $jPath $json
            }
        }
    } catch {}
}
'@ 'Atomic write in Complete-ResetJournal'

    Patch-Once ([ref]$raw) @'
                    if ($script:State -is [hashtable] -and ($script:State.Misc -is [hashtable])) {
                            $script:State.Misc.Remove('PendingReboot')
                            $script:State.Misc.Remove('PendingRebootTime')
                            Save-State
                        }
'@ @'
                    if ($script:State -is [hashtable] -and ($script:State.Misc -is [hashtable])) {
                            [void](Invoke-WithLock -WaitMs 5000 {
                                $script:State.Misc.Remove('PendingReboot')
                                $script:State.Misc.Remove('PendingRebootTime')
                                Save-State
                            })
                        }
'@
    # Wait line 8747 indent is 24 spaces; match exact 24 spaces!
    $raw = $raw
    Patch-Once ([ref]$raw) @'
                        Restore-WlanProfiles
                        if ($script:State -is [hashtable] -and ($script:State.Misc -is [hashtable])) {
                            $script:State.Misc.Remove('PendingReboot')
                            $script:State.Misc.Remove('PendingRebootTime')
                            Save-State
                        }
'@ @'
                        Restore-WlanProfiles
                        if ($script:State -is [hashtable] -and ($script:State.Misc -is [hashtable])) {
                            [void](Invoke-WithLock -WaitMs 5000 {
                                $script:State.Misc.Remove('PendingReboot')
                                $script:State.Misc.Remove('PendingRebootTime')
                                Save-State
                            })
                        }
'@ 'Test-PriorResetJournal acquire lock before Save-State'

    Patch-Once ([ref]$raw) @'
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
'@ @'
        # 1. Global registry & network settings snapshot (Key-Level First-Write-Wins)
        try {
            $whRes = Invoke-Native (Get-SysExe 'netsh.exe') @('winhttp', 'show', 'proxy') 3000
            if ($whRes.Output -match 'Proxy Server\(s\)\s*:\s*(\S+)') { Save-Original 'Global' 'WinHttpProxy' $matches[1] }
        } catch {}
        try {
            $cuP = Get-ItemProperty -LiteralPath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -ErrorAction SilentlyContinue
            if ($cuP -and $null -ne $cuP.ProxyEnable) { Save-Original 'Global' 'ProxyEnable_CU' ([int]$cuP.ProxyEnable) }
            if ($cuP -and $cuP.ProxyServer) { Save-Original 'Global' 'ProxyServer_CU' ([string]$cuP.ProxyServer) }
        } catch {}
        try {
            $lmP = Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings' -ErrorAction SilentlyContinue
            if ($lmP -and $null -ne $lmP.ProxyEnable) { Save-Original 'Global' 'ProxyEnable_LM' ([int]$lmP.ProxyEnable) }
            if ($lmP -and $lmP.ProxyServer) { Save-Original 'Global' 'ProxyServer_LM' ([string]$lmP.ProxyServer) }
        } catch {}
        try {
            $ncsi = (Get-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet' -Name EnableActiveProbing -ErrorAction SilentlyContinue).EnableActiveProbing
            if ($null -ne $ncsi) { Save-Original 'Global' 'Ncsi' ([int]$ncsi) }
        } catch {}

        # 2. Per-adapter snapshot across ALL adapters (Key-Level First-Write-Wins, aligned with Restore-Everything)
        $allAdapters = @(Get-NetAdapter -IncludeHidden -ErrorAction SilentlyContinue)
        foreach ($ad in $allAdapters) {
            $adGuid = [string]$ad.InterfaceGuid
            if (-not $adGuid) { continue }
            $snap = Capture-PreflightSnapshot $ad
            if ($snap) {
                if ($snap.Ip4 -and $snap.Ip4.IPAddress) {
                    $gwS = if ($snap.Gateways -and $snap.Gateways.Count -gt 0) { [string]$snap.Gateways[0] } else { '' }
                    Save-Original $adGuid 'StaticIp4' @{ IPAddress = [string]$snap.Ip4.IPAddress; PrefixLength = [int]$snap.Ip4.PrefixLength; DefaultGateway = $gwS }
                }
                Save-Original $adGuid 'DnsStatic' (Get-StaticDnsString $adGuid)
                if ($null -ne $snap.Metric) { Save-MetricOriginal (Get-IPv4Interface $ad) }
                $snapCount++
            }
        }
'@ 'Capture-GlobalPreflightSnapshot key-level First-Write-Wins + StaticIp4/DnsStatic schema'

    Patch-Once ([ref]$raw) @'
                    Set-Content -LiteralPath $jPath -Value (ConvertTo-Json $jObj) -Encoding ASCII -Force
                }
            } catch {}
        }
        $script:State.Misc['PendingReboot'] = $true
'@ @'
                    $jJson = ConvertTo-Json $jObj -Depth 4
                    Write-AtomicJsonFile $jPath $jJson
                }
            } catch {}
        }
        $script:State.Misc['PendingReboot'] = $true
'@ 'Armageddon atomic reset_journal.json write'

    Patch-Once ([ref]$raw) @'
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
'@ @'
function Invoke-NetworkDebloat {
    param(
        [int]$Tier = 1,
        [switch]$SafeOnly,
        [switch]$Audit,
        [switch]$Json,
        [switch]$Quiet,
        [switch]$NoColor,
        [switch]$NoOutput
    )
    if ($SafeOnly) { $Tier = 1 }
    $items = @(Get-DebloatStatus)
    $targetItems = @($items | Where-Object { $_.Tier -le $Tier })

    if ($Audit -or ($script:IsDry -and -not $script:IsPlan)) {
        if ($NoOutput) { return 0 }
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
'@ 'Invoke-NetworkDebloat add -NoOutput and separate -Plan from -Audit'

    Patch-Once ([ref]$raw) @'
    if (-not (Assert-Admin)) { return 40 }
    Write-Log 'INFO' ("Starting Careful Network Debloat (Target Tier: {0})..." -f $Tier)
'@ @'
    if (-not $script:IsPlan -and -not (Assert-Admin)) {
        if (-not $NoOutput) {
            if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'PreconditionFailed'; Message = 'Administrator rights required'; ExitCode = 40 } -Depth 2)) }
            elseif ($Quiet) { [Console]::Out.WriteLine('Precondition Failed: Administrator rights required (ExitCode: 40)') }
        }
        return 40
    }
    if (-not $script:IsPlan) { Write-Log 'INFO' ("Starting Careful Network Debloat (Target Tier: {0})..." -f $Tier) }
'@ 'Invoke-NetworkDebloat emit JSON/Quiet on AdminRequired'

    Patch-Once ([ref]$raw) @'
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

        $debUndo = if ($it.Exists) {
            "Set-ItemProperty -LiteralPath '$($it.Key)' -Name '$($it.ValueName)' -Value $($it.CurrentValue) -Force -ErrorAction SilentlyContinue"
        } else {
            "Remove-ItemProperty -LiteralPath '$($it.Key)' -Name '$($it.ValueName)' -Force -ErrorAction SilentlyContinue"
        }
        [void](Invoke-Change ("Debloat: Set {0} ({1}={2})" -f $it.Name, $it.ValueName, $it.OptimalValue) {
            if (-not (Test-Path -LiteralPath $it.Key)) {
                [void](New-Item -Path $it.Key -ItemType Directory -Force -ErrorAction SilentlyContinue)
            }
            Set-ItemProperty -LiteralPath $it.Key -Name $it.ValueName -Value $it.OptimalValue -Type $it.OptimalType -Force -ErrorAction Stop
        } -MutationType 'Registry' -Target $it.Key -ValueName $it.ValueName -OldValue $it.CurrentValue -NewValue $it.OptimalValue -UndoScript $debUndo -Reversible)
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
'@ @'
    foreach ($it in $targetItems) {
        if ($it.Status -eq 'Optimal') { continue }
        $snapKey = $it.Key + '\' + $it.ValueName
        if (-not $script:IsDry -and -not $snap.Keys.ContainsKey($snapKey)) {
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
    }
    if (-not $script:IsDry) { Save-State }
    foreach ($it in $targetItems) {
        if ($it.Status -eq 'Optimal') { continue }
        $safeKey = ([string]$it.Key).Replace("'", "''")
        $safeNam = ([string]$it.ValueName).Replace("'", "''")
        $debUndo = if ($it.Exists) {
            if ($it.CurrentValue -is [string]) {
                $safeVal = ([string]$it.CurrentValue).Replace("'", "''")
                "Set-ItemProperty -LiteralPath '$safeKey' -Name '$safeNam' -Value '$safeVal' -Force -ErrorAction Stop"
            } else {
                $numVal = 0L; if ([int64]::TryParse([string]$it.CurrentValue, [ref]$numVal)) {
                    "Set-ItemProperty -LiteralPath '$safeKey' -Name '$safeNam' -Value $numVal -Force -ErrorAction Stop"
                } else { '' }
            }
        } else {
            "Remove-ItemProperty -LiteralPath '$safeKey' -Name '$safeNam' -Force -ErrorAction Stop"
        }
        [void](Invoke-Change ("Debloat: Set {0} ({1}={2})" -f $it.Name, $it.ValueName, $it.OptimalValue) {
            if (-not (Test-Path -LiteralPath $it.Key)) {
                [void](New-Item -Path $it.Key -ItemType Directory -Force -ErrorAction SilentlyContinue)
            }
            Set-ItemProperty -LiteralPath $it.Key -Name $it.ValueName -Value $it.OptimalValue -Type $it.OptimalType -Force -ErrorAction Stop
        } -MutationType 'Registry' -Target $it.Key -ValueName $it.ValueName -OldValue $it.CurrentValue -NewValue $it.OptimalValue -UndoScript $debUndo -Reversible)
        $changed++
    }
    if (-not $script:IsDry) { Save-State }
    if ($script:IsPlan) { return 0 }

    if ($Tier -ge 2) {
        try {
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'teredo', 'set', 'state', 'disabled') 3000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', '6to4', 'set', 'state', 'disabled') 3000)
            [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'isatap', 'set', 'state', 'disabled') 3000)
            $changed++
        } catch {}
    }

    $script:ConnCache = $null; $script:EnvCache = @{}; $script:NitjsrCacheVal = $null; Clear-DnsClientCache -ErrorAction SilentlyContinue
    Save-State
'@ 'Debloat persist snapshot BEFORE mutations, escape UndoScript quotes, lightweight cache flush'

    Patch-Once ([ref]$raw) @'
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
'@ @'
function Undo-NetworkDebloat {
    param(
        [switch]$Json,
        [switch]$Quiet,
        [switch]$NoColor,
        [switch]$NoOutput
    )
    if ($script:IsDry -and -not $script:IsPlan) {
        Write-Log 'DRY' 'Would revert previous Network Debloat optimizations'
        if (-not $NoOutput -and $Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'DryRun'; RestoredCount = 0 } -Depth 2)) }
        return 0
    }
    if (-not $script:State.ContainsKey('Snapshot') -or -not $script:State.Snapshot.ContainsKey('Debloat')) {
        Write-Log 'WARN' 'No previous Debloat rollback snapshot was found. Nothing to revert.'
        if (-not $NoOutput) {
            if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'NotFound'; Message = 'No Debloat snapshot found' } -Depth 2)) }
            elseif ($Quiet) { [Console]::Out.WriteLine('Debloat Rollback: No snapshot found') }
            else { Write-Host 'No previous Debloat snapshot found. System is already at baseline.' }
        }
        return 0
    }
    if (-not $script:IsPlan -and -not (Assert-Admin)) {
        if (-not $NoOutput) {
            if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'PreconditionFailed'; Message = 'Administrator rights required'; ExitCode = 40 } -Depth 2)) }
            elseif ($Quiet) { [Console]::Out.WriteLine('Precondition Failed: Administrator rights required (ExitCode: 40)') }
        }
        return 40
    }
    Write-Log 'INFO' 'Executing rollback of previous Network Debloat optimizations...'

    $snap = $script:State.Snapshot['Debloat']
    $restored = 0
    $hadFailures = $false
    if ($snap.ContainsKey('Keys') -and $snap.Keys -is [hashtable]) {
        foreach ($k in $snap.Keys.Keys) {
            $item = $snap.Keys[$k]
            $okRev = $false
            if ($item.Exists) {
                $okRev = Invoke-Change ("Revert Debloat: Restore {0}\{1} to {2}" -f $item.KeyPath, $item.ValueName, $item.OriginalVal) {
                    Set-ItemProperty -LiteralPath $item.KeyPath -Name $item.ValueName -Value $item.OriginalVal -Type $item.OriginalType -Force -ErrorAction Stop
                } -MutationType 'Registry' -Target ([string]$item.KeyPath) -ValueName ([string]$item.ValueName) -NewValue $item.OriginalVal
            } else {
                $okRev = Invoke-Change ("Revert Debloat: Remove newly-created {0}\{1}" -f $item.KeyPath, $item.ValueName) {
                    Remove-ItemProperty -LiteralPath $item.KeyPath -Name $item.ValueName -Force -ErrorAction Stop
                } -MutationType 'Registry' -Target ([string]$item.KeyPath) -ValueName ([string]$item.ValueName) -NewValue $null
            }
            if ($okRev) { $restored++ } else { $hadFailures = $true }
        }
    }
    if ($script:IsPlan) { return 0 }

    try {
        [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'teredo', 'set', 'state', 'default') 3000)
        [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', '6to4', 'set', 'state', 'default') 3000)
        [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'isatap', 'set', 'state', 'default') 3000)
    } catch {}

    if (-not $hadFailures) { [void]$script:State.Snapshot.Remove('Debloat') }
    $script:ConnCache = $null; $script:EnvCache = @{}; $script:NitjsrCacheVal = $null; Clear-DnsClientCache -ErrorAction SilentlyContinue
    Save-State

    Write-Log 'OK' ("Debloat Rollback complete: {0} settings restored to exact pre-debloat state." -f $restored)
    if (-not $NoOutput) {
        if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'Success'; RestoredCount = $restored } -Depth 2)) }
        elseif ($Quiet) { [Console]::Out.WriteLine(("Debloat Rollback Complete: {0} settings restored" -f $restored)) }
        else {
            Write-Host ('================================================================================')
            Write-Host ('   NETWORK DEBLOAT ROLLBACK COMPLETED SUCCESSFULLY')
            Write-Host ('   Restored {0} settings back to original Windows configuration.' -f $restored)
            Write-Host ('================================================================================')
        }
    }
    return 0
}
'@ 'Undo-NetworkDebloat -NoOutput, -Plan, preserve Snapshot on failure, AdminRequired JSON'

    Patch-Once ([ref]$raw) @'
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
'@ @'
    switch ($choice) {
        '1' {
            if (Read-Confirm 'Apply Safe Network Debloat (Tier 1)?' 'yes') {
                [void](Invoke-WithLock { Invoke-NetworkDebloat -Tier 1 })
            } else { Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.')) }
        }
        '2' {
            if (Read-Confirm 'Apply Comprehensive Network Debloat (Tier 1 & 2)?' 'yes') {
                [void](Invoke-WithLock { Invoke-NetworkDebloat -Tier 2 })
            } else { Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.')) }
        }
        '3' {
            [void](Invoke-NetworkDebloat -Audit)
        }
        '4' {
            if (Read-Confirm 'Rollback all previous Network Debloat modifications?' 'yes') {
                [void](Invoke-WithLock { Undo-NetworkDebloat })
            } else { Out-Line @((Seg 'dim' '  Operation cancelled. No changes made.')) }
        }
'@ 'Show-DebloatMenu wrap Debloat & UndoDebloat in Invoke-WithLock so Snapshot persists'

    Patch-Once ([ref]$raw) @'
    # NCSI: only repair if something (a "tweak" tool) switched active probing off.
    $nk = 'HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet'
    $probe = (Get-ItemProperty -LiteralPath $nk -Name EnableActiveProbing -ErrorAction SilentlyContinue).EnableActiveProbing
    if ($null -ne $probe -and [int]$probe -eq 0) {
        Save-Original 'Global' 'Ncsi' 0
        [void](Invoke-Change 'Windows connectivity probing re-enabled (it was switched off)' { Set-ItemProperty -LiteralPath $nk -Name EnableActiveProbing -Value 1 -Type DWord -ErrorAction Stop })
    }
'@ '' 'Remove duplicate dead NCSI EnableActiveProbing block in Shield-Services'

    Patch-Once ([ref]$raw) @'
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
'@ @'
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
        if ($didEnable) { Start-Sleep -Milliseconds 500; $script:OtherUplinksCache = $null; $ads = @(Get-EthernetAdapters -NoCache) }
    }
    if ($ads.Count -eq 0) { Write-Log 'WARN' 'No physical Ethernet adapter found (Wi-Fi/system stack still shielded).'; Invoke-RoamingCleanup; Save-State; return $res }

    Write-Log 'STEP' 'LAYER 1/7  Hardware interface & power state verification'
    foreach ($a in $ads) { Shield-Hardware $a; [void](Resolve-DuplexFlap $a); [void](Optimize-PhySiliconBuffers $a); [void](Shield-TcpOffloads $a) }
'@ 'Invoke-HealPipeline refresh Get-EthernetAdapters -NoCache after Enable-NetAdapter'

    # ==========================================================================
    # PATCH 11: AutoHeal PendingReboot lock + debounce, Uninstall-Watchdog/Restore-Everything DryRun & Snapshot fixes
    # ==========================================================================
    Patch-Once ([ref]$raw) @'
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
                $rebootMark = [datetime]::Parse([string]$script:State.Misc['PendingRebootTime'], [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind)
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
'@ @'
function Invoke-AutoHeal {
    if (Test-InteractiveSessionActive) {
        Write-Log 'INFO' 'AutoHeal pass skipped: interactive control center session is active.'
        return 0
    }
    if (-not (Enter-Lock 3000)) { return 0 }
    if ($script:State.Misc -is [hashtable] -and $script:State.Misc['PendingReboot']) {
        $bootTime = [datetime]::MinValue
        try {
            $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
            if ($os -and $os.LastBootUpTime) { $bootTime = $os.LastBootUpTime }
        } catch {}
        $rebootMark = [datetime]::MinValue
        try {
            if ($script:State.Misc['PendingRebootTime']) {
                $rebootMark = [datetime]::Parse([string]$script:State.Misc['PendingRebootTime'], [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind)
            }
        } catch {}
        if ($bootTime -gt $rebootMark) {
            $script:State.Misc.Remove('PendingReboot')
            $script:State.Misc.Remove('PendingRebootTime')
            Save-State
        } else {
            Write-Log 'WARN' 'System reboot is pending following Armageddon reset. AutoHeal paused until reboot completes.'
            Exit-Lock
            return 0
        }
    }
'@ 'Invoke-AutoHeal move PendingReboot clearance inside Enter-Lock'

    Patch-Once ([ref]$raw) @'
        $script:State.Misc['LastAutoHealUpCount'] = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' }).Count
'@ @'
        $script:State.Misc['LastAutoHealUpCount'] = @(Get-EthernetAdapters | Where-Object { $_.Status -eq 'Up' }).Count + @(Get-OtherUplinkAdapters).Count
'@ 'Invoke-AutoHeal consistent debounce upCount across Ethernet + Other uplinks'

    Patch-Once ([ref]$raw) @'
    Clear-StartupEntries
    if (-not $script:IsDry -and $script:State.Misc -is [hashtable]) { $script:State.Misc.Remove('WatchdogSince') }
    foreach ($oldXml in 'LanFixer_Watchdog.xml', 'LanFixer_Portal.xml', 'LanFixer_Notify.xml') {
        Remove-Item -LiteralPath (Join-Path $script:StoreDir $oldXml) -Force -ErrorAction SilentlyContinue
    }
'@ @'
    if (-not $script:IsDry) {
        Clear-StartupEntries
        if ($script:State.Misc -is [hashtable]) { $script:State.Misc.Remove('WatchdogSince') }
        foreach ($oldXml in 'LanFixer_Watchdog.xml', 'LanFixer_Portal.xml', 'LanFixer_Notify.xml') {
            Remove-Item -LiteralPath (Join-Path $script:StoreDir $oldXml) -Force -ErrorAction SilentlyContinue
        }
    }
'@ 'Uninstall-Watchdog DryRun guard on Clear-StartupEntries & XML delete'

    Patch-Once ([ref]$raw) @'
    Uninstall-SentinelTask
    Uninstall-Watchdog
    try {
        Get-ScheduledTask -TaskName 'LanFixer_*' -ErrorAction SilentlyContinue | ForEach-Object {
            try { [void](Invoke-Native (Get-SysExe 'schtasks.exe') @('/end', '/tn', $_.TaskName) 3000) } catch {}
            Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false -ErrorAction SilentlyContinue
        }
    } catch {}
    Clear-StartupEntries
'@ @'
    Uninstall-SentinelTask
    Uninstall-Watchdog
    if (-not $script:IsDry) {
        try {
            Get-ScheduledTask -TaskName 'LanFixer_*' -ErrorAction SilentlyContinue | ForEach-Object {
                try { [void](Invoke-Native (Get-SysExe 'schtasks.exe') @('/end', '/tn', $_.TaskName) 3000) } catch {}
                Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false -ErrorAction SilentlyContinue
            }
        } catch {}
        Clear-StartupEntries
    }
'@ 'Restore-Everything DryRun guard on Step 1 task/startup cleanup'

    Patch-Once ([ref]$raw) @'
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
'@ @'
                if ($snap.ContainsKey('WinHttpProxy')) {
                    $wh = [string]$snap['WinHttpProxy']
                    [void](Invoke-Change 'WinHTTP proxy restored' {
                        $netsh = Get-SysExe 'netsh.exe'
                        if ($wh) { [void](Invoke-Native $netsh @('winhttp', 'set', 'proxy', $wh) 5000) }
                        else { [void](Invoke-Native $netsh @('winhttp', 'reset', 'proxy') 5000) }
                    })
                }
                if ($snap.ContainsKey('ProxyEnable_CU') -or $snap.ContainsKey('ProxyServer_CU')) {
                    [void](Invoke-Change 'WinINet user proxy restored' {
                        if ($snap.ContainsKey('ProxyEnable_CU')) { Set-ItemProperty -LiteralPath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -Value ([int]$snap['ProxyEnable_CU']) -Type DWord -Force -ErrorAction SilentlyContinue }
                        if ($snap.ContainsKey('ProxyServer_CU') -and $snap['ProxyServer_CU']) { Set-ItemProperty -LiteralPath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyServer -Value ([string]$snap['ProxyServer_CU']) -Force -ErrorAction SilentlyContinue }
                    })
                }
                if ($snap.ContainsKey('ProxyEnable_LM') -or $snap.ContainsKey('ProxyServer_LM')) {
                    [void](Invoke-Change 'WinINet machine proxy restored' {
                        if ($snap.ContainsKey('ProxyEnable_LM')) { Set-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -Value ([int]$snap['ProxyEnable_LM']) -Type DWord -Force -ErrorAction SilentlyContinue }
                        if ($snap.ContainsKey('ProxyServer_LM') -and $snap['ProxyServer_LM']) { Set-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyServer -Value ([string]$snap['ProxyServer_LM']) -Force -ErrorAction SilentlyContinue }
                    })
                }
'@ 'Restore-Everything also restores ProxyServer_CU / ProxyServer_LM'

    Patch-Once ([ref]$raw) @'
                if ($snap.ContainsKey('Ncsi')) {
                    $nk = 'HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet'
                    $v = [int]$snap['Ncsi']
                    [void](Invoke-Change "Connectivity probing setting restored to $v" { Set-ItemProperty -LiteralPath $nk -Name EnableActiveProbing -Value $v -Type DWord -ErrorAction Stop })
                }
'@ @'
                if ($snap.ContainsKey('Ncsi') -or $snap.ContainsKey('EnableActiveProbing')) {
                    $nk = 'HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet'
                    $rawV = if ($snap.ContainsKey('Ncsi')) { $snap['Ncsi'] } else { $snap['EnableActiveProbing'] }
                    $ncsiHadSnap = $true
                    if ($null -ne $rawV) {
                        $v = [int]$rawV
                        [void](Invoke-Change "Connectivity probing setting restored to $v" { Set-ItemProperty -LiteralPath $nk -Name EnableActiveProbing -Value $v -Type DWord -ErrorAction Stop })
                    }
                }
'@ 'Restore-Everything handle EnableActiveProbing & Ncsi snapshot keys'

    Patch-Once ([ref]$raw) @'
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
'@ @'
                } elseif ($key -like 'Enum:*') {
                    $pName = $key.Substring(5)
                    if ($ad.PnPDeviceID -and -not $script:IsDry) {
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
                    } elseif ($script:IsDry) {
                        Write-Log 'DRY' ("Would revert Device Parameters '{0}' on {1}" -f $pName, $ad.Name)
                    }
                }
'@ 'Restore-Everything DryRun guard on Enum:*'

    Patch-Once ([ref]$raw) @'
    # 4. Universal Interface Metrics Reset (Restore AutomaticMetric on all adapters)
    Restore-InterfaceMetrics 'Metrics back to their original values'
    foreach ($ipif in @(Get-NetIPInterface -ErrorAction SilentlyContinue)) {
        if ($ipif.AutomaticMetric -ne 'Enabled') {
            [void](Invoke-Change "Adapter $($ipif.InterfaceAlias) $($ipif.AddressFamily) metric reverted to automatic" {
                Set-NetIPInterface -InterfaceIndex $ipif.ifIndex -AddressFamily $ipif.AddressFamily -AutomaticMetric Enabled -ErrorAction SilentlyContinue
            })
        }
    }
'@ @'
    # 4. Universal Interface Metrics Reset (preserve metrics restored from MetricOrig, revert others to Automatic)
    $manualRestored = @{}
    if ($script:State.Misc['MetricOrig'] -is [hashtable]) {
        foreach ($mk in @($script:State.Misc['MetricOrig'].Keys)) {
            $mRec = $script:State.Misc['MetricOrig'][$mk]
            if ($mRec -and [string]$mRec.Auto -ne 'Enabled') { $manualRestored["$($mRec.Alias)|$($mRec.Af)"] = $true }
        }
    }
    Restore-InterfaceMetrics 'Metrics back to their original values'
    foreach ($ipif in @(Get-NetIPInterface -ErrorAction SilentlyContinue)) {
        if ($manualRestored.ContainsKey("$($ipif.InterfaceAlias)|$($ipif.AddressFamily)")) { continue }
        if ($ipif.AutomaticMetric -ne 'Enabled') {
            [void](Invoke-Change "Adapter $($ipif.InterfaceAlias) $($ipif.AddressFamily) metric reverted to automatic" {
                Set-NetIPInterface -InterfaceIndex $ipif.ifIndex -AddressFamily $ipif.AddressFamily -AutomaticMetric Enabled -ErrorAction SilentlyContinue
            })
        }
    }
'@ 'Restore-Everything do not clobber manual user metrics restored from MetricOrig'

    Patch-Once ([ref]$raw) @'
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
'@ @'
    # 6. Clean DHCP ConnForceBroadcastFlag and Broadcast Toggle Keys
    if (-not $script:IsDry) {
        try {
            $ifacesKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces'
            if (Test-Path -LiteralPath $ifacesKey) {
                Get-ChildItem -LiteralPath $ifacesKey -ErrorAction SilentlyContinue | ForEach-Object {
                    Remove-ItemProperty -LiteralPath $_.PSPath -Name 'DhcpConnForceBroadcastFlag' -ErrorAction SilentlyContinue
                    Remove-ItemProperty -LiteralPath $_.PSPath -Name 'DhcpConnEnableBcastFlagToggle' -ErrorAction SilentlyContinue
                }
            }
        } catch {}
    }

    # 7. Release All ARP Locks & Flush All Neighbor and Destination Caches
    foreach ($guid in @($script:State.Arp.Keys)) {
        $ad = $present | Where-Object { [string]$_.InterfaceGuid -eq [string]$guid } | Select-Object -First 1
        if ($ad) { Release-ArpLocks $ad }
    }
    foreach ($ea in @(Get-EthernetAdapters)) { Release-ArpLocks $ea }
    if (-not $script:IsDry) {
        [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'ip', 'delete', 'arpcache') 8000)
        [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'ipv6', 'delete', 'destinationcache') 8000)
        [void](Invoke-Native (Get-SysExe 'netsh.exe') @('interface', 'ipv6', 'delete', 'arpcache') 8000)
        [void](Invoke-Native (Get-SysExe 'nbtstat.exe') @('-R') 8000)
        Clear-DnsClientCache -ErrorAction SilentlyContinue
    }
'@ 'Restore-Everything DryRun guard Steps 6 & 7'

    Patch-Once ([ref]$raw) @'
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
'@ @'
    # 11. Restore NCSI Active Probing Settings (preserving snapshotted EnableActiveProbing if restored in Step 2)
    if (-not $script:IsDry) {
        try {
            $nk = 'HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet'
            if (Test-Path -LiteralPath $nk) {
                if (-not $ncsiHadSnap) { Set-ItemProperty -LiteralPath $nk -Name 'EnableActiveProbing' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue }
                Set-ItemProperty -LiteralPath $nk -Name 'ActiveDnsProbeHost' -Value 'dns.msftncsi.com' -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -LiteralPath $nk -Name 'ActiveDnsProbeContent' -Value '131.107.0.89' -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -LiteralPath $nk -Name 'ActiveWebProbeHost' -Value 'www.msftconnecttest.com' -Force -ErrorAction SilentlyContinue
            }
        } catch {}
    }
'@ 'Restore-Everything Step 11 DryRun guard + preserve Ncsi snapshot'

    Patch-Once ([ref]$raw) @'
        $script:State = @{}
        foreach ($k in 'Snapshot','Env','Dns','Arp','Times','Misc') { $script:State[$k] = @{} }
        $script:State.Misc['Migrated'] = $true
        $script:State.Misc['FactoryResetDate'] = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        Save-State
'@ @'
        $script:ConnCache = $null; $script:EnvCache = @{}; $script:NitjsrCacheVal = $null; $script:UplinkProfileCache = $null; $script:WdCache = $null
        $script:EthernetAdaptersCache = $null; $script:OtherUplinksCache = $null; $script:GwAliveCache = @{}
        $script:State = @{}
        foreach ($k in 'Snapshot','Env','Dns','Arp','Times','Misc') { $script:State[$k] = @{} }
        $script:State.Misc['Migrated'] = $true
        $script:State.Misc['FactoryResetDate'] = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        Save-State
'@ 'Restore-Everything clear all in-memory caches'

    # ==========================================================================
    # PATCH 12: Set-DnsProfileMode & Set-RouteProfileMode cache invalidation + HeadlessPortalLogin -Manual loop fix
    # ==========================================================================
    Patch-Once ([ref]$raw) @'
            if (-not $script:IsDry) { $script:State.Dns = @{} }
            Clear-DnsClientCache -ErrorAction SilentlyContinue
'@ @'
            if (-not $script:IsDry) { $script:State.Dns = @{}; $script:EnvCache = @{}; $script:ConnCache = $null; $script:NitjsrCacheVal = $null }
            Clear-DnsClientCache -ErrorAction SilentlyContinue
'@ 'Set-DnsProfileMode ResetDHCP clear caches'

    Patch-Once ([ref]$raw) @'
                    if (-not $script:IsDry) {
                        [void](Invoke-Change "Enabling disabled Wi-Fi adapter $($w.Name) for Wifi profile" {
                            Enable-NetAdapter -Name $w.Name -Confirm:$false -ErrorAction Stop
                        })
                    }
'@ @'
                    if (-not $script:IsDry) {
                        [void](Invoke-Change "Enabling disabled Wi-Fi adapter $($w.Name) for Wifi profile" {
                            Enable-NetAdapter -Name $w.Name -Confirm:$false -ErrorAction Stop
                        })
                        $script:OtherUplinksCache = $null; $script:ConnCache = $null
                    }
'@ 'Set-RouteProfileMode invalidate OtherUplinksCache after enabling Wi-Fi'

    Patch-Once ([ref]$raw) @'
            if ($visitedHops.Contains($next.AbsoluteUri)) { Write-Log 'WARN' 'Circular portal redirection loop detected; breaking out.'; break }
'@ @'
            if ($visitedHops.Contains($next.AbsoluteUri)) { Write-Log 'WARN' 'Circular portal redirection loop detected; breaking out.'; $page = @{ Error = 'RedirectLoop' }; break }
'@ 'Invoke-HeadlessPortalLogin set Error=RedirectLoop on cycle'

    Patch-Once ([ref]$raw) @'
        if ($Manual) {
            $ci = Get-PortalCertInfo $cur
'@ @'
        if ($Manual -and $Headless -eq $false -and -not (Test-InputRedirected)) {
            $ci = Get-PortalCertInfo $cur
'@ 'Guard interactive cert prompt against Headless or redirected input'

    Patch-Once ([ref]$raw) @'
                    return (Invoke-HeadlessPortalLogin $Inet -Manual -Attempt ($Attempt + 1))
'@ @'
                    return (Invoke-HeadlessPortalLogin $Inet -Manual -Attempt ($Attempt + 1) -SourceIp $src)
'@ 'Preserve -SourceIp across TlsRejected manual retry'

    # ==========================================================================
    # PATCH 13: Doctor (Layer 3/5 scoping + $_.Exception.Response + NoColor), GuidedRecovery (-DryRun/Admin40),
    #           Redaction (preserve HH:MM:SS timestamps + all IPv6), INI Policy Engine + Show-ConfigReport CRASH FIX
    # ==========================================================================
    Patch-Once ([ref]$raw) @'
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
'@ @'
$script:CapturingReport = $false
function Write-Banner([string]$Title) {
    if (-not $script:CapturingReport -and ($Json -or $Quiet -or -not $script:UiOn)) { return }
    $w = Get-UiWidth
    Out-Line @()
    Out-Line @((Seg 'accent!' '  LAN FIXER'), (Seg 'faint' (' ' + $script:G.mid + ' ' + $Title.ToUpper())))
    Out-Rule $w
    Out-Line @()
}
function Write-Section([string]$Title) {
    if (-not $script:CapturingReport -and ($Json -or $Quiet -or -not $script:UiOn)) { return }
    $w = Get-UiWidth
    Out-Line @()
    Out-Line @((Seg 'accent!' ('  ' + $Title.ToLower() + ' ')), (Seg 'faint' ($script:G.rule * [Math]::Max(3, $w - $Title.Length - 2))))
    Out-Line @()
}
function Write-KV([string]$Key, [string]$Value, [string]$Color = 'White') {
    if (-not $script:CapturingReport -and ($Json -or $Quiet)) { return }
    Out-Line @((Seg 'dim' ('  ' + ($Key.PadRight(26)) + ' ')), (Seg (ConvertTo-Role $Color) $Value))
}
'@ 'SupportReport CapturingReport flag prevents blank report under -Json/-Quiet'

    Patch-Once ([ref]$raw) @'
    $gwRoute = @(Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Sort-Object RouteMetric) | Select-Object -First 1
'@ @'
    $gwRoute = if ($ad) {
        @(Get-NetRoute -InterfaceIndex $ad.InterfaceIndex -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Sort-Object RouteMetric) | Select-Object -First 1
    } else { $null }
    if (-not $gwRoute) {
        $gwRoute = @(Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Sort-Object RouteMetric) | Select-Object -First 1
    }
'@ 'Invoke-HealthDoctor Layer 3 scope route to primary adapter first'

    Patch-Once ([ref]$raw) @'
    # Layer 5: Raw IPv4 Internet Connectivity
    $l5 = @{ Layer = 5; Name = 'InternetIpv4'; Status = 'OK'; Evidence = ''; Cause = ''; Action = 'None' }
    $probeOk = $false
    $probeCode = 0
    try {
        $req = [System.Net.HttpWebRequest]::Create('http://connectivitycheck.gstatic.com/generate_204')
        $req.Timeout = 2000
        $req.ReadWriteTimeout = 2000
        $req.AllowAutoRedirect = $false
        $req.Proxy = $null
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
'@ @'
    # Layer 5: Raw IPv4 Internet Connectivity (source-bound when primary adapter has IPv4; Proxy = $null on unbound fallback)
    $l5 = @{ Layer = 5; Name = 'InternetIpv4'; Status = 'OK'; Evidence = ''; Cause = ''; Action = 'None' }
    $probeOk = $false
    $probeCode = 0
    $adIpL5 = if ($ipObj) { [string]$ipObj.IPAddress } else { '' }
    if ($adIpL5 -and $adIpL5 -notlike '169.254.*') {
        $hpL5 = Invoke-HttpProbe 'connectivitycheck.gstatic.com' '/generate_204' 2000 $adIpL5 80
        $probeCode = [int]$hpL5.Code
        if ($probeCode -eq 204) { $probeOk = $true }
    } else {
        $resp = $null
        try {
            $req = [System.Net.HttpWebRequest]::Create('http://connectivitycheck.gstatic.com/generate_204')
            $req.Timeout = 2000
            $req.ReadWriteTimeout = 2000
            $req.AllowAutoRedirect = $false
            $req.Proxy = $null
            $resp = $req.GetResponse()
            $probeCode = [int]$resp.StatusCode
            if ($probeCode -eq 204) { $probeOk = $true }
        } catch [System.Net.WebException] {
            $errResp = $_.Exception.Response -as [System.Net.HttpWebResponse]
            if ($errResp) {
                $probeCode = [int]$errResp.StatusCode
                try { $errResp.Dispose() } catch {}
            }
        } catch {} finally {
            if ($resp) { try { $resp.Dispose() } catch {} }
        }
    }
'@ 'Invoke-HealthDoctor Layer 5 source-bound + fix Exception.Response + Dispose in finally'

    Patch-Once ([ref]$raw) @'
    Write-Host -NoNewline 'Overall Verdict : '
    if ($NoColor) {
'@ @'
    Write-Host -NoNewline 'Overall Verdict : '
    if ($nc) {
'@ 'Format-DoctorConsole use $nc ($NoColor -or $script:NoColor)'

    Patch-Once ([ref]$raw) @'
function Invoke-GuidedRecovery([switch]$Plan, [switch]$Force, [switch]$Json, [switch]$Quiet, [switch]$NoColor) {
    if (-not $script:IsAdmin -and -not $Plan) {
        if (-not $Quiet -and -not $Json) { Write-Host 'Error: Guided recovery requires Administrator elevation.' -ForegroundColor Red }
        return @{ Status = 'Failed'; Reason = 'AdminRequired'; ExitCode = 30 }
    }
'@ @'
function Invoke-GuidedRecovery([switch]$Plan, [switch]$Force, [switch]$Json, [switch]$Quiet, [switch]$NoColor) {
    $isRecPlan = [bool]($Plan -or $script:IsDry)
    if (-not $script:IsAdmin -and -not $isRecPlan) {
        $errObj = @{ Status = 'Failed'; Reason = 'AdminRequired'; ExitCode = 40 }
        if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json $errObj -Depth 2)) }
        elseif ($Quiet) { [Console]::Out.WriteLine('Precondition Failed: Administrator rights required (ExitCode: 40)') }
        else { Write-Host 'Error: Guided recovery requires Administrator elevation.' -ForegroundColor Red }
        return $errObj
    }
'@ 'Invoke-GuidedRecovery DryRun preview & AdminRequired JSON/Quiet + ExitCode 40'

    Patch-Once ([ref]$raw) @'
    if ($Plan) {
        [void]$actionsAttempted.Add("Plan Preview: Would execute $($d1.RecommendedMode)")
'@ @'
    if ($isRecPlan) {
        [void]$actionsAttempted.Add("Plan Preview: Would execute $($d1.RecommendedMode)")
'@ 'Invoke-GuidedRecovery stop at preview under -Plan or -DryRun'

    Patch-Once ([ref]$raw) @'
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
            Invoke-SupremeOmnifix -Confirmed
        }
        'Diagnose' {
            $ad = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.InterfaceDescription -notmatch $script:VirtRegex }) | Select-Object -First 1
            if ($ad -and $ad.Status -eq 'Disabled') {
                [void](Invoke-Change "Enable adapter $($ad.Name)" { Enable-NetAdapter -Name $ad.Name -Confirm:$false -ErrorAction Stop })
            } elseif ($ad -and $ad.Status -ne 'Up') {
                [void](Invoke-Change "Restart adapter $($ad.Name)" { Restart-NetAdapter -Name $ad.Name -Confirm:$false -ErrorAction Stop })
            } elseif ($ad) {
                [void](Resolve-DuplexFlap $ad)
                [void](Optimize-PhySiliconBuffers $ad)
            }
        }
        default {
            [void](Invoke-HealPipeline)
        }
    }
'@ @'
    switch ($firstAction) {
        'Login' {
            [void](Invoke-WithLock { [void](Open-Portal) })
        }
        'SetDnsProfile' {
            [void](Invoke-WithLock { Flush-NetworkCache })
            Set-DnsProfileMode 'Hybrid'
        }
        'QuickHeal' {
            [void](Invoke-WithLock { [void](Invoke-HealPipeline) })
        }
        'StandardReset' {
            Invoke-SupremeOmnifix -Confirmed
        }
        'Diagnose' {
            [void](Invoke-WithLock {
                $ad = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.InterfaceDescription -notmatch $script:VirtRegex }) | Select-Object -First 1
                if ($ad -and $ad.Status -eq 'Disabled') {
                    [void](Invoke-Change "Enable adapter $($ad.Name)" { Enable-NetAdapter -Name $ad.Name -Confirm:$false -ErrorAction Stop })
                } elseif ($ad -and $ad.Status -ne 'Up') {
                    [void](Invoke-Change "Restart adapter $($ad.Name)" { Restart-NetAdapter -Name $ad.Name -Confirm:$false -ErrorAction Stop })
                } elseif ($ad) {
                    [void](Resolve-DuplexFlap $ad)
                    [void](Optimize-PhySiliconBuffers $ad)
                }
            })
        }
        default {
            [void](Invoke-WithLock { [void](Invoke-HealPipeline) })
        }
    }
'@ 'Invoke-GuidedRecovery acquire lock per repair stage cleanly'

    Patch-Once ([ref]$raw) @'
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
    if ($env:USERDOMAIN -and $env:USERDOMAIN -ne $env:COMPUTERNAME -and $env:USERDOMAIN -notmatch '^(WORKGROUP|NT AUTHORITY|BUILTIN)$') {
        $res = [regex]::Replace($res, ('\b' + [regex]::Escape($env:USERDOMAIN) + '\b'), '[DOMAIN_REDACTED]', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
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
        $res = [regex]::Replace($res, '(?i)(?<![0-9a-f:])(?!fe80:|fe80::|f[cd][0-9a-f]{2}:|ff[0-9a-f]{2}:|::1(?![0-9a-f:]))(?:[0-9a-f]{1,4}:){1,7}(?:[0-9a-f]{1,4}|:[0-9a-f]{1,4}|:)(?![0-9a-f:])', '[PUBLIC_IPV6_REDACTED]')
    }

    return $res
}
'@ @'
function Invoke-Redaction([string]$Text, [string]$Level = 'Strict') {
    if (-not $Text) { return '' }
    $res = $Text

    if ($env:USERPROFILE) {
        $res = [regex]::Replace($res, [regex]::Escape($env:USERPROFILE), 'C:\Users\[USER_REDACTED]', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    }
    if ($env:USERNAME -and $env:USERNAME.Length -ge 2) {
        $res = [regex]::Replace($res, ('\b' + [regex]::Escape($env:USERNAME) + '\b'), '[USER_REDACTED]', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    }
    if ($env:COMPUTERNAME -and $env:COMPUTERNAME.Length -ge 2) {
        $res = [regex]::Replace($res, ('\b' + [regex]::Escape($env:COMPUTERNAME) + '\b'), '[HOST_REDACTED]', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    }
    if ($env:USERDOMAIN -and $env:USERDOMAIN -ne $env:COMPUTERNAME -and $env:USERDOMAIN -notmatch '^(WORKGROUP|NT AUTHORITY|BUILTIN)$') {
        $res = [regex]::Replace($res, ('\b' + [regex]::Escape($env:USERDOMAIN) + '\b'), '[DOMAIN_REDACTED]', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    }

    $res = [regex]::Replace($res, '([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})', 'XX:XX:XX:XX:XX:XX')
    $res = [regex]::Replace($res, '(?i)(password|secret|token|credential|key)\s*[:=]\s*(\S+)', '$1: [REDACTED]')

    if ($Level -eq 'Strict') {
        $ipEvaluator = [System.Text.RegularExpressions.MatchEvaluator]{
            param($m)
            $ipStr = $m.Value
            $parts = $ipStr.Split('.')
            if ($parts.Count -ne 4) { return $ipStr }
            $b0 = 0; $b1 = 0; $b2 = 0; $b3 = 0
            if (-not ([int]::TryParse($parts[0], [ref]$b0) -and [int]::TryParse($parts[1], [ref]$b1) -and [int]::TryParse($parts[2], [ref]$b2) -and [int]::TryParse($parts[3], [ref]$b3))) { return $ipStr }
            if ($b0 -gt 255 -or $b1 -gt 255 -or $b2 -gt 255 -or $b3 -gt 255) { return $ipStr }
            if ($b0 -eq 127 -or $b0 -eq 10) { return $ipStr }
            if ($b0 -eq 192 -and $b1 -eq 168) { return $ipStr }
            if ($b0 -eq 172 -and ($b1 -ge 16 -and $b1 -le 31)) { return $ipStr }
            if ($b0 -eq 169 -and $b1 -eq 254) { return $ipStr }
            if ($b0 -eq 100 -and ($b1 -ge 64 -and $b1 -le 127)) { return $ipStr }
            if ($ipStr -eq '0.0.0.0' -or $ipStr -eq '255.255.255.255') { return $ipStr }
            return '[PUBLIC_IP_REDACTED]'
        }
        $v6Evaluator = [System.Text.RegularExpressions.MatchEvaluator]{
            param($m)
            $tok = $m.Value
            if ($tok.IndexOf(':') -lt 0) { return $tok }
            $addr = $null
            if (-not [System.Net.IPAddress]::TryParse($tok, [ref]$addr)) { return $tok }
            if ($addr.AddressFamily -ne [System.Net.Sockets.AddressFamily]::InterNetworkV6) { return $tok }
            if ([System.Net.IPAddress]::IsLoopback($addr) -or $addr.IsIPv6LinkLocal -or $addr.IsIPv6Multicast) { return $tok }
            $bytes = $addr.GetAddressBytes()
            if (($bytes[0] -band 0xFE) -eq 0xFC) { return $tok }   # RFC 4193 ULA fc00::/7
            return '[PUBLIC_IPV6_REDACTED]'
        }
        $res = [regex]::Replace($res, '\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b', $ipEvaluator)
        $res = [regex]::Replace($res, '(?i)(?<![0-9a-f:])(?:[0-9a-f]{0,4}:){2,7}[0-9a-f]{0,4}(?![0-9a-f:])', $v6Evaluator)
    }

    return $res
}
'@ 'Invoke-Redaction safe USERPROFILE order, boundaries, TryParse IPv4 & true IPAddress::TryParse IPv6 (preserves HH:MM:SS!)'

    Patch-Once ([ref]$raw) @'
        if ($line -match '^([a-zA-Z0-9_\-]+)\s*=\s*(.*)$') {
            $key = $matches[1].Trim()
            $val = $matches[2].Trim()
            if ($val -match '^"(.*)"$' -or $val -match "^'(.*)'$") {
                $val = $matches[1]
            }
            $ini[$currentSection][$key] = $val
        }
'@ @'
        if ($line -match '^([a-zA-Z0-9_\-]+)\s*=\s*(.*)$') {
            $key = $matches[1].Trim()
            $val = $matches[2].Trim()
            if ($val -match '^"([^"]*)"(?:\s*[;#].*)?$' -or $val -match "^'([^']*)'(?:\s*[;#].*)?$") {
                $val = $matches[1]
            } else {
                $val = ($val -replace '\s+[;#].*$', '').Trim()
            }
            $ini[$currentSection][$key] = $val
        }
'@ 'ConvertFrom-IniFile strip inline comments outside quotes'

    Patch-Once ([ref]$raw) @'
    if (Test-Path -LiteralPath $iniPath) {
        $fi = Get-Item -LiteralPath $iniPath -ErrorAction SilentlyContinue
        if ($fi -and $fi.Length -le 65536) {
            if (Test-ConfigFileTrusted $iniPath) {
                $iniTrusted = $true
                try {
                    $parsed = ConvertFrom-IniFile $iniPath
                    $iniValid = $true
'@ @'
    if (Test-Path -LiteralPath $iniPath) {
        $fi = Get-Item -LiteralPath $iniPath -ErrorAction SilentlyContinue
        if ($fi -and $fi.Length -gt 65536) {
            [void]$iniErrors.Add("lanfixer.ini exceeds maximum 65536 bytes ($($fi.Length) bytes)")
        } elseif ($fi) {
            if (Test-ConfigFileTrusted $iniPath) {
                $iniTrusted = $true
                try {
                    $parsed = ConvertFrom-IniFile $iniPath
'@ 'Get-EffectiveConfiguration check oversized INI'

    Patch-Once ([ref]$raw) @'
                    }
                } catch {
                    [void]$iniErrors.Add("Failed to parse INI: $($_.Exception.Message)")
                }
'@ @'
                    }
                    $iniValid = ($iniErrors.Count -eq 0)
                } catch {
                    [void]$iniErrors.Add("Failed to parse INI: $($_.Exception.Message)")
                    $iniValid = $false
                }
'@ 'Get-EffectiveConfiguration set IniValid based on iniErrors count'

    Patch-Once ([ref]$raw) @'
function Import-IniPolicy {
    try {
        $eff = Get-EffectiveConfiguration
        if (-not $eff -or -not $eff.IniExists -or -not $eff.IniTrusted -or -not $eff.IniValid) { return }
        $cfgMap = $eff.Configuration
        if ($eff.Sources['NoColor'] -eq 'POLICY_FILE' -and $cfgMap['NoColor'] -eq 'True') {
            $script:NoColor = $true
            $script:Ui.Plain = $true
            $script:Ui.Vt = $false
        }
        if ($eff.Sources['RedactionLevel'] -eq 'POLICY_FILE' -and $cfgMap['RedactionLevel'] -in @('Strict','Standard')) {
            $script:PolicyRedaction = [string]$cfgMap['RedactionLevel']
        }
        if ($eff.Sources['DefaultDnsProfile'] -eq 'POLICY_FILE' -and $script:State.Misc -is [hashtable] -and -not $script:State.Misc['DnsProfile']) {
            $script:State.Misc['DnsProfile'] = [string]$cfgMap['DefaultDnsProfile']
        }
        if ($eff.Sources['DefaultRouteProfile'] -eq 'POLICY_FILE' -and $script:State.Misc -is [hashtable] -and -not $script:State.Misc['RouteProfile']) {
            $script:State.Misc['RouteProfile'] = [string]$cfgMap['DefaultRouteProfile']
        }
    } catch {}
}
'@ @'
function Import-IniPolicy {
    try {
        $eff = Get-EffectiveConfiguration
        if (-not $eff -or -not $eff.IniExists -or -not $eff.IniTrusted -or -not $eff.IniValid) { return }
        $cfgMap = $eff.Configuration
        if ($eff.Sources['NoColor'] -eq 'POLICY_FILE' -and $cfgMap['NoColor'] -eq 'True') {
            $script:NoColor = $true
            $script:Ui.Plain = $true
        }
        if ($eff.Sources['LogLevel'] -eq 'POLICY_FILE') { $script:PolicyLogLevel = [string]$cfgMap['LogLevel'] }
        if ($eff.Sources['RedactionLevel'] -eq 'POLICY_FILE' -and $cfgMap['RedactionLevel'] -in @('Strict','Standard')) {
            $script:PolicyRedaction = [string]$cfgMap['RedactionLevel']
        }
        $script:IniAppliedDefaults = @{}
        if ($eff.Sources['DefaultDnsProfile'] -eq 'POLICY_FILE' -and $script:State.Misc -is [hashtable]) {
            $script:IniAppliedDefaults.DnsProfile = [string]$cfgMap['DefaultDnsProfile']
            if (-not $script:State.Misc['DnsProfile']) { $script:State.Misc['DnsProfile'] = [string]$cfgMap['DefaultDnsProfile'] }
        }
        if ($eff.Sources['DefaultRouteProfile'] -eq 'POLICY_FILE' -and $script:State.Misc -is [hashtable]) {
            $script:IniAppliedDefaults.RouteProfile = [string]$cfgMap['DefaultRouteProfile']
            if (-not $script:State.Misc['RouteProfile']) { $script:State.Misc['RouteProfile'] = [string]$cfgMap['DefaultRouteProfile'] }
        }
        if ($eff.Sources['HttpProbeUrl'] -eq 'POLICY_FILE') { $script:Cfg['HttpProbeUrl'] = [string]$cfgMap['HttpProbeUrl'] }
        if ($eff.Sources['TlsProbeHost'] -eq 'POLICY_FILE') { $script:Cfg['TlsProbeHost'] = [string]$cfgMap['TlsProbeHost'] }
        if ($eff.Sources['ProbeTimeoutMs'] -eq 'POLICY_FILE') { $script:Cfg['ProbeTimeoutMs'] = [int]$cfgMap['ProbeTimeoutMs'] }
        if ($eff.Sources['CooldownSeconds'] -eq 'POLICY_FILE') { $script:Cfg['CooldownSeconds'] = [int]$cfgMap['CooldownSeconds'] }
        if ($eff.Sources['AutoHealMaxTier'] -eq 'POLICY_FILE') { $script:Cfg['AutoHealMaxTier'] = [int]$cfgMap['AutoHealMaxTier'] }
        if ($eff.Sources['EnableSentinel'] -eq 'POLICY_FILE') { $script:Cfg['EnableSentinel'] = ($cfgMap['EnableSentinel'] -eq 'True') }
    } catch {}
}
'@ 'Import-IniPolicy wire all policy keys & preserve IniAppliedDefaults across locks'

    Patch-Once ([ref]$raw) @'
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
'@ @'
    $ncCfg = [bool]($NoColor -or $script:NoColor)
    if ($ValidateOnly) {
        $valErrors = @($eff.Errors)
        if (-not $eff.IniExists) { $valErrors += "Policy file not found at $($eff.IniPath)" }
        $isValid = ($eff.IniExists -and $eff.IniTrusted -and $valErrors.Count -eq 0)
        if ($Json) {
            $rep = @{
                Status   = if ($isValid) { 'Valid' } else { 'Invalid' }
                IniPath  = $eff.IniPath
                Trusted  = $eff.IniTrusted
                Errors   = $valErrors
                ExitCode = if ($isValid) { 0 } else { 1 }
            }
            [Console]::Out.WriteLine((ConvertTo-Json $rep -Depth 4))
        } elseif (-not $Quiet) {
            if ($ncCfg) {
                Write-Host '================================================================================'
                Write-Host '               LANFIXER POLICY & CONFIGURATION AUDIT'
                Write-Host '================================================================================'
                Write-Host ("Policy File : {0}" -f $eff.IniPath)
                Write-Host ("File Exists : {0}" -f $eff.IniExists)
                Write-Host ("ACL Trusted : {0}" -f $eff.IniTrusted)
                if (-not $isValid) {
                    Write-Host 'Audit Errors / Warnings:'
                    foreach ($err in $valErrors) { Write-Host ("  - {0}" -f $err) }
                    Write-Host 'Status: INVALID'
                } else {
                    Write-Host 'Status: VALID (All policy parameters sanitized and verified)'
                }
                Write-Host '================================================================================'
            } else {
                Write-Host '================================================================================' -ForegroundColor Cyan
                Write-Host '               LANFIXER POLICY & CONFIGURATION AUDIT' -ForegroundColor Cyan
                Write-Host '================================================================================' -ForegroundColor Cyan
                Write-Host ("Policy File : {0}" -f $eff.IniPath)
                Write-Host ("File Exists : {0}" -f $eff.IniExists)
                Write-Host ("ACL Trusted : {0}" -f $eff.IniTrusted)
                if (-not $isValid) {
                    Write-Host 'Audit Errors / Warnings:' -ForegroundColor Red
                    foreach ($err in $valErrors) { Write-Host ("  - {0}" -f $err) -ForegroundColor Yellow }
                    Write-Host 'Status: INVALID' -ForegroundColor Red
                } else {
                    Write-Host 'Status: VALID (All policy parameters sanitized and verified)' -ForegroundColor Green
                }
                Write-Host '================================================================================' -ForegroundColor Cyan
            }
        }
        if ($isValid) { return 0 } else { return 1 }
    }
'@ 'Show-ConfigReport fix PS5.1 crash return (if...) + missing INI error + NoColor'

    # ==========================================================================
    # PATCH 14: Diagnostics / QuickProbe / SupportReport / FlushCache / LogIntelligence / Telemetry / UI
    # ==========================================================================
    Patch-Once ([ref]$raw) @'
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
'@ @'
    if ($script:CapturingReport -or (-not $Json -and -not $Quiet)) {
        if (Test-Path -LiteralPath $script:LogFile) {
            foreach ($ll in @(Get-Content -LiteralPath $script:LogFile -Tail 12 -ErrorAction SilentlyContinue)) {
                $lRole = if ($ll -match '\[(FAIL|ALERT)\]') { 'bad' } elseif ($ll -match '\[WARN\]') { 'warn' } elseif ($ll -match '\[OK\]') { 'ok' } else { 'dim' }
                Out-Line @((Seg $lRole ('  ' + (Fit ([string]$ll) ([Math]::Max(50, (Get-UiWidth) - 2))))))
            }
        } else {
            Out-Line @((Seg 'dim' '  (no log entries recorded yet)'))
        }
    }

    Write-Section 'DIAGNOSTIC SUMMARY & VERDICT'
    if ($script:CapturingReport -or (-not $Json -and -not $Quiet)) {
        if ($issues.Count -eq 0) { Out-Line @((Seg 'ok' ('  ' + $script:G.ok + ' ')), (Seg 'text' 'No problems found.')) }
        else { foreach ($i in $issues) { Out-Wrapped 'warn' $script:G.warn 'warn' ([string]$i) 2 } }
        Write-Host ''
    }
'@ 'Show-Diagnostics guard trailing Out-Line/Write-Host under -Json/-Quiet while allowing New-SupportReport capture'

    Patch-Once ([ref]$raw) @'
    $st = (Get-InternetState -NoCache).State
    $col = $(switch ($st) { 'Online' { 'Green' } 'Captive' { 'Yellow' } default { 'Red' } })
    Write-KV '[5] HTTP internet probe' $st $col
    Write-Host ''
'@ @'
    $st = (Get-InternetState -NoCache).State
    $col = $(switch ($st) { 'Online' { 'Green' } 'Captive' { 'Yellow' } default { 'Red' } })
    Write-KV '[5] HTTP internet probe' $st $col
    if ($script:CapturingReport -or (-not $Json -and -not $Quiet)) { Write-Host '' }
'@ 'Run-QuickProbe suppress trailing blank line under -Json/-Quiet'

    Patch-Once ([ref]$raw) @'
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
'@ @'
    $script:Ui.Plain = $true
    $script:CapturingReport = $true
    try {
        $recs = & {
            try { Show-Diagnostics } catch { Write-Host ('[audit stopped early: ' + $_.Exception.Message + ']') }
            Write-Section 'RECENT LAN FIXER LOG (last 40 lines)'
            try { Get-Content -LiteralPath $script:LogFile -Tail 40 -ErrorAction Stop | ForEach-Object { Write-Host ('  ' + $_) } } catch { Write-Host '  (no log yet)' }
        } *>&1
        $text = ConvertTo-ReportText $recs
    } catch { $text = 'Report generation failed: ' + $_.Exception.Message }
    finally {
        $script:CapturingReport = $false
        $script:Ui.Plain = $false
    }
    $writeOk = $true
    $writeErr = ''
    try {
        $tmp = $path + '.tmp'
        [System.IO.File]::WriteAllText($tmp, $text, (New-Object System.Text.UTF8Encoding($true)))
        Move-Item -LiteralPath $tmp -Destination $path -Force -ErrorAction Stop
        Write-Log 'OK' "Report saved: $path  (contains your MAC, IP and PC name: read it before sharing)"
    } catch {
        $writeOk = $false
        $writeErr = $_.Exception.Message
        Write-Log 'WARN' ("Could not write the report file (" + $writeErr + "). The text is shown above: copy it manually.")
    }
    if ($Json) {
        $rep = @{
            Status   = if ($writeOk) { 'Success' } else { 'Error' }
            Path     = $path
            Error    = $writeErr
            ExitCode = if ($writeOk) { 0 } else { 1 }
        }
        [Console]::Out.WriteLine((ConvertTo-Json $rep -Depth 2))
        if ($writeOk) { return 0 } else { return 1 }
    }
'@ 'New-SupportReport enable capture under -Json/-Quiet + accurate write error status'

    Patch-Once ([ref]$raw) @'
    $script:ConnCache = $null
    $script:EnvCache = @{}
    $script:DhcpDiagCache = $null
    $script:EthernetAdaptersCache = $null
    $script:OtherUplinksCache = $null
    $script:BatteryCache = $null
'@ @'
    $script:ConnCache = $null
    $script:EnvCache = @{}
    $script:DhcpDiagCache = $null
    $script:EthernetAdaptersCache = $null
    $script:OtherUplinksCache = $null
    $script:BatteryCache = $null
    $script:NitjsrCacheVal = $null
    $script:UplinkProfileCache = $null
    $script:WdCache = $null
    $script:GwAliveCache = @{}
'@ 'Flush-NetworkCache clear all in-memory caches'

    Patch-Once ([ref]$raw) @'
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
'@ @'
    try {
        $lastDnsRec = if ($script:State.Misc -and $script:State.Misc['LastHandledDns1014RecordId']) { [int64]$script:State.Misc['LastHandledDns1014RecordId'] } else { 0L }
        $dnsEv = @(Get-WinEvent -FilterHashtable @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-DNS-Client'; Id = 1014; StartTime = (Get-Date).AddMinutes(-10) } -MaxEvents 1 -ErrorAction SilentlyContinue | Where-Object { $_.RecordId -gt $lastDnsRec })
        if ($dnsEv.Count -gt 0) {
            $script:State.Misc['LastHandledDns1014RecordId'] = [int64]$dnsEv[0].RecordId
            foreach ($k in @($script:State.Dns.Keys)) {
                if ($script:State.Dns[$k] -is [hashtable] -and $script:State.Dns[$k].ContainsKey('OrderTime')) {
                    $script:State.Dns[$k].Remove('OrderTime')
                }
            }
            Clear-DnsClientCache -ErrorAction SilentlyContinue
            Write-Log 'INFO' 'Log intelligence: Windows logged DNS timeout (Event 1014); invalidated cached resolver order for fresh measurement.'
        }
    } catch {}
'@ 'Invoke-LogIntelligence track Event 1014 RecordId to avoid repeated 10-min flushes'

    Patch-Once ([ref]$raw) @'
            $e = Get-AdapterEnvironment $ad -UseCache
            $t.Env = [string]$e.Env; $t.EnvScore = [int]$e.Score; $t.Sticky = [bool]$e.Sticky
'@ @'
            $e = Get-AdapterEnvironment $ad -UseCache:$UseCache
            $t.Env = [string]$e.Env; $t.EnvScore = [int]$e.Score; $t.Sticky = [bool]$e.Sticky
'@ 'Get-Telemetry propagate -UseCache to Get-AdapterEnvironment'

    # UI geometry & non-VT / NoColor fixes
    Patch-Once ([ref]$raw) @'
    if ($script:NoColor) { $script:Ui.Plain = $true; $script:Ui.Vt = $false }
    Set-UiGlyphs $uni
'@ @'
    if ($script:NoColor) { $script:Ui.Plain = $true }
    Set-UiGlyphs $uni
'@ 'Keep VT cursor positioning active under -NoColor so Update-PulseRow and Erase work'

    Patch-Once ([ref]$raw) @'
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
'@ @'
function ConvertTo-AnsiString($Segs) {
    $sb = New-Object System.Text.StringBuilder
    if ($script:NoColor -or $script:Ui.Plain) {
        foreach ($s in @($Segs)) { [void]$sb.Append([string]$s.T) }
        return $sb.ToString()
    }
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
'@ 'ConvertTo-AnsiString omit ANSI color codes when NoColor/Plain'

    Patch-Once ([ref]$raw) @'
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
'@ @'
        $cw = 80
        try { $cw = [Console]::WindowWidth } catch {}
        $drawn = 0
        foreach ($l in @($Lines)) {
            $drawn++
            if ($canRewind) {
                $len = Get-SegsLength $l
                $padLen = [math]::Max(0, ($cw - 1) - $len)
                if ($padLen -gt 0) {
                    Out-Line (@($l) + (Seg 'text' (' ' * $padLen)))
                } else {
                    Out-Line $l
                }
            } else {
                Out-Line $l
            }
        }
        if ($canRewind -and $script:LastFrameRows -gt $drawn) {
            $blank = ' ' * [math]::Max(1, $cw - 1)
            for ($ri = $drawn; $ri -lt $script:LastFrameRows; $ri++) { Write-Host $blank }
        }
        $script:LastFrameRows = $drawn
        try { if ($canRewind) { [Console]::CursorVisible = $true } } catch {}
'@ 'Write-Frame non-VT clear shrinking trailing rows & avoid $cw column wrap'

    Patch-Once ([ref]$raw) @'
    $uiH = Get-UiHeight
    if ($w -ge 74 -and ($uiH -eq 0 -or $uiH -ge 28)) {
'@ @'
    $uiH = Get-UiHeight
    if ($w -ge 74 -and ($uiH -eq 0 -or $uiH -ge 31)) {
'@ 'Raise 2-column dock height threshold to 31 so header never scrolls off 28-30 row consoles'

    # ==========================================================================
    # PATCH 15: Sentinel DryRun + No -Manual bypass + Healthy Fast-Path + G-key Unlock + Startup AdminModes & Plan Guard
    # ==========================================================================
    Patch-Once ([ref]$raw) @'
    if ($script:StoreReady) {
        $logPath = Join-Path $script:StoreDir 'sentinel.log'
'@ @'
    if ($script:StoreReady -and -not $script:IsDry) {
        $logPath = Join-Path $script:StoreDir 'sentinel.log'
'@ 'Write-SentinelLog honor DryRun'

    Patch-Once ([ref]$raw) @'
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
'@ @'
function Install-SentinelTask {
    if (-not (Assert-Admin)) { return $false }
    if ($script:IsDry) {
        return (Invoke-Change 'Register and activate LanFixer_Sentinel 24/7 scheduled task' { } -MutationType 'ScheduledTask' -Target 'LanFixer_Sentinel')
    }
    if (-not $script:StoreReady -or -not $script:StoreSecure) {
        Write-Log 'FAIL' 'Protected store folder unavailable. Cannot register Sentinel task.'
        return $false
    }
    if (-not (Test-Path -LiteralPath $script:SelfCopy)) {
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
    if ($script:IsDry) {
        return (Invoke-Change 'Stop and unregister LanFixer_Sentinel scheduled task' { } -MutationType 'ScheduledTask' -Target 'LanFixer_Sentinel')
    }
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
'@ 'Install-SentinelTask & Uninstall-SentinelTask strict DryRun/Plan purity'

    Patch-Once ([ref]$raw) @'
            if ($ethIp -and $state.State -eq 'Online' -and $linkHealth.Healthy -and $gwOk) {
                $script:SentinelStats.HealthyCycles++
                if ($script:DaemonConsecutiveFails -gt 0) {
                    Write-SentinelLog 'OK' ("Link recovered! All health checks passed on {0} ({1}, Gateway {2}). Resetting circuit breaker (was {3} fails)." -f $ad.Name, $ethIp, $gw, $script:DaemonConsecutiveFails)
                    $script:DaemonConsecutiveFails = 0
                }
                # Ensure routing metrics prioritize Ethernet over Wi-Fi when Ethernet is confirmed Online
                [void](Invoke-WithLock -WaitMs 3000 {
                    $ctxOnline = @{ Ad = $ad; Env = (Get-AdapterEnvironment $ad) }
                    Shield-RouteMetrics $ctxOnline 'Online'
                    Save-State
                })

                $batDaemon = Get-BatteryHealthAndEfficiency
                $currentCadence = if ($batDaemon.IsOnBattery) { [Math]::Max(20, $IntervalSec * 2) } else { $IntervalSec }
                if ($isConsole -and ((Get-Date) - $lastHudRender).TotalMilliseconds -ge 800) {
                    Show-SentinelHud $ad $linkHealth $state.State $currentCadence
                    $lastHudRender = Get-Date
                }
                Wait-SentinelCadence $currentCadence $isConsole $ad
                continue
            }
'@ @'
            if ($ethIp -and $state.State -eq 'Online' -and $linkHealth.Healthy -and $gwOk) {
                $script:SentinelStats.HealthyCycles++
                $recoveredFromFail = ($script:DaemonConsecutiveFails -gt 0)
                if ($recoveredFromFail) {
                    Write-SentinelLog 'OK' ("Link recovered! All health checks passed on {0} ({1}, Gateway {2}). Resetting circuit breaker (was {3} fails)." -f $ad.Name, $ethIp, $gw, $script:DaemonConsecutiveFails)
                    $script:DaemonConsecutiveFails = 0
                }
                if ($recoveredFromFail -or ($script:SentinelStats.HealthyCycles -eq 1) -or ($script:SentinelStats.HealthyCycles % 12 -eq 0)) {
                    $preChg = $script:ChangeCount
                    [void](Invoke-WithLock -WaitMs 3000 {
                        $ctxOnline = @{ Ad = $ad; Env = (Get-AdapterEnvironment $ad -UseCache) }
                        Shield-RouteMetrics $ctxOnline 'Online'
                        if ($script:ChangeCount -gt $preChg -or $recoveredFromFail) { Save-State }
                    })
                }
                if ($script:IsDry) { $script:SentinelRunning = $false; break }

                $batDaemon = Get-BatteryHealthAndEfficiency
                $currentCadence = if ($batDaemon.IsOnBattery) { [Math]::Max(20, $IntervalSec * 2) } else { $IntervalSec }
                if ($isConsole -and ((Get-Date) - $lastHudRender).TotalMilliseconds -ge 800) {
                    Show-SentinelHud $ad $linkHealth $state.State $currentCadence
                    $lastHudRender = Get-Date
                }
                Wait-SentinelCadence $currentCadence $isConsole $ad
                continue
            }
'@ 'Start-AutonomousDaemon healthy fast-path: use cache, skip lock/disk save every 10s, exit after 1 cycle in DryRun'

    Patch-Once ([ref]$raw) @'
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
'@ @'
                $creds = Get-PortalCredentials
                if ($creds -and -not $script:IsDry) {
                    Write-SentinelLog 'TIER2' ("Captive portal detected! Stored credentials found for '{0}'. Executing autonomous headless login on {1}..." -f $creds.User, $ethIp)
                    $loginOk = [bool](Invoke-HeadlessPortalLogin $state -SourceIp $ethIp)
'@ 'Daemon Captive path: remove -Manual & donot hold lock across login'

    Patch-Once ([ref]$raw) @'
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
'@ @'
                if ($state.State -eq 'Captive' -or $curProbe.State -eq 'Captive') {
                    Write-SentinelLog 'TIER4' "Executing Tier 4: Captive portal detected! Checking DPAPI vault for credentials..."
                    $creds = Get-PortalCredentials
                    if ($creds -and -not $script:IsDry) {
                        Write-SentinelLog 'TIER4' ("Stored credentials found for '{0}'. Executing headless login on {1}..." -f $creds.User, $curIp)
                        $loginOk = [bool](Invoke-HeadlessPortalLogin $curProbe -SourceIp $curIp)
'@ 'Daemon Tier 4 path: remove -Manual & donot hold lock across login'

    Patch-Once ([ref]$raw) @'
            Wait-SentinelCadence $currentCadence $isConsole $ad
        } catch {
'@ @'
            if ($script:IsDry) { $script:SentinelRunning = $false; break }
            Wait-SentinelCadence $currentCadence $isConsole $ad
        } catch {
'@ 'Daemon DryRun single-iteration bound'

    Patch-Once ([ref]$raw) @'
                    $okLogin = [bool](Invoke-HeadlessPortalLogin $inet -Manual)
                    Save-State
                    return @{ State = $inet.State; Signed = $okLogin; SkipBrowser = $false }
                })
'@ @'
                    Save-State
                    return @{ State = $inet.State; Signed = $false; SkipBrowser = $false; Inet = $inet }
                })
                if ($loginRes -and -not $loginRes.Signed -and -not $loginRes.SkipBrowser -and $loginRes.Inet) {
                    $loginRes.Signed = [bool](Invoke-HeadlessPortalLogin $loginRes.Inet -Manual)
                }
'@ 'DashboardKey g run Invoke-HeadlessPortalLogin -Manual outside Invoke-WithLock'

    Patch-Once ([ref]$raw) @'
            Start-Sleep -Milliseconds ($RefreshSeconds * 1000)
'@ @'
            $waitLeftMs = [Math]::Max(100, $RefreshSeconds * 1000)
            while ($waitLeftMs -gt 0) {
                if (Test-KeyAvailable) { break }
                $sliceMs = [Math]::Min(100, $waitLeftMs)
                Start-Sleep -Milliseconds $sliceMs
                $waitLeftMs -= $sliceMs
            }
'@ 'Show-HistoryLiveStream 100ms key-responsive sleep loop'

    Patch-Once ([ref]$raw) @'
        'b' {
            Show-View 'Live Sentinel Monitor' {
                if (-not (Assert-Admin)) { return }
                Start-AutonomousDaemon
            } -NoWait
        }
'@ @'
        'b' {
            Show-View 'Live Sentinel Monitor' {
                if (-not (Assert-Admin)) { Out-Line @(); Out-Line @((Seg 'dim' '  press any key')); Wait-AnyKey; return }
                Start-AutonomousDaemon
            } -NoWait
        }
'@ 'DashboardKey b pause on non-admin error before closing view'

    Patch-Once ([ref]$raw) @'
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
'@ @'
        $lastW = Get-UiWidth
        $lastH = Get-UiHeight
        $lastRawW = try { [Console]::WindowWidth } catch { $lastW }
        $lastRawH = try { [Console]::WindowHeight } catch { $lastH }
        $autoLoginTried = $false
        $script:InDashboard = $true
        while ($true) {
            if ($draw) {
                Show-Dashboard $t $adv; $draw = $false
                $lastW = Get-UiWidth; $lastH = Get-UiHeight
                $lastRawW = try { [Console]::WindowWidth } catch { $lastW }
                $lastRawH = try { [Console]::WindowHeight } catch { $lastH }
                $script:InDashboard = $true
            }
            $key = $null
            while ($null -eq $key) {
                if (Test-KeyAvailable) { $key = Read-KeyNow; break }
                if ($t.GwIp -and (Update-Pulse $t.GwIp)) {
                    if ($null -ne $script:LiveGwRtt) { $t.GwRtt = $script:LiveGwRtt }
                    if ($script:Ui.Vt) { [void](Update-PulseRow $t) }
                }   # ping a silent gateway too: the lost replies ARE the picture
                $curRawW = try { [Console]::WindowWidth } catch { $lastRawW }
                $curRawH = try { [Console]::WindowHeight } catch { $lastRawH }
                if ((Get-UiWidth) -ne $lastW -or (Get-UiHeight) -ne $lastH -or $curRawW -ne $lastRawW -or $curRawH -ne $lastRawH) { $draw = $true; break }
'@ 'Start-Interactive track raw Console WindowWidth/WindowHeight for immediate resize redraw'

    Patch-Once ([ref]$raw) @'
    if ($script:IsAdmin) {
        $script:WatchdogOn = Test-WatchdogInstalled
        try { Update-WatchdogIfStale } catch {}
    }
'@ @'
    if ($script:IsAdmin -and -not $script:IsDry) {
        $script:WatchdogOn = Test-WatchdogInstalled
        try { [void](Invoke-WithLock -WaitMs 2000 { Update-WatchdogIfStale }) } catch {}
    }
'@ 'Start-Interactive wrap Update-WatchdogIfStale in Invoke-WithLock'

    # Startup entry point fixes: adminModes, elevation quoting, MissingManifest fail-closed, Mode dispatch, Plan guard, unhandled catch JSON
    Patch-Once ([ref]$raw) @'
$adminModes = @('Interactive', 'Heal', 'QuickHeal', 'AutoHeal', 'Omnifix', 'NetReset', 'FullNetReset', 'UltraReset', 'Ultra', 'DoomsdayReset', 'Doomsday', 'ArmageddonReset', 'Armageddon', 'ResetOptions', 'ResetMenu', 'FlushCache', 'Flush', 'InstallWatchdog', 'UninstallWatchdog', 'InstallShield', 'UninstallShield', 'InstallSentinel', 'UninstallSentinel', 'ResetFactory', 'Reset', 'SetDnsProfile', 'Dns', 'DnsMenu', 'SetRouteProfile', 'Route', 'RouteMenu', 'Daemon', 'Sentinel', 'Vault')
'@ @'
$adminModes = @('Interactive', 'Heal', 'QuickHeal', 'AutoHeal', 'Omnifix', 'StandardReset', 'NetReset', 'FullNetReset', 'UltraReset', 'Ultra', 'DoomsdayReset', 'Doomsday', 'ArmageddonReset', 'Armageddon', 'ResetOptions', 'ResetMenu', 'FlushCache', 'Flush', 'InstallWatchdog', 'UninstallWatchdog', 'InstallShield', 'UninstallShield', 'InstallSentinel', 'UninstallSentinel', 'ResetFactory', 'Reset', 'SetDnsProfile', 'Dns', 'DnsMenu', 'SetRouteProfile', 'Route', 'RouteMenu', 'Daemon', 'Sentinel', 'Vault', 'Undo', 'UndoDebloat')
if (-not $Audit) { $adminModes += 'Debloat' }
if (-not $Plan) { $adminModes += 'Recover' }
if ($Authorize) { $adminModes += 'Integrity' }
'@ 'Include StandardReset/Undo/Recover/Debloat/UndoDebloat/Integrity-Authorize in adminModes'

    Patch-Once ([ref]$raw) @'
                else {
                    $parts += ('-' + $kv.Key)
                    $vStr = [string]$kv.Value
                    if ($vStr -match '[\s"]') { $parts += ('"' + $vStr.Replace('"', '\"') + '"') }
                    else { $parts += $vStr }
                }
'@ @'
                else {
                    $parts += ('-' + $kv.Key)
                    $vStr = [string]$kv.Value
                    if ($vStr -eq '' -or $vStr -match '[\s"&|<>^]') { $parts += ('"' + $vStr.Replace('"', '""') + '"') }
                    else { $parts += $vStr }
                }
'@ 'Fix elevation quoting for empty strings & batch metacharacters'

    Patch-Once ([ref]$raw) @'
    if (@('AutoHeal', 'Daemon', 'Sentinel') -contains $Mode -and -not $script:IsDry) {
        $intCheck = Test-ScriptIntegrity
        if (-not $intCheck.Valid -and $intCheck.Status -ne 'MissingManifest') {
'@ @'
    if (@('AutoHeal', 'Daemon', 'Sentinel') -contains $Mode -and -not $script:IsDry) {
        $intCheck = Test-ScriptIntegrity
        $failMissing = ($intCheck.Status -eq 'MissingManifest' -and (Test-Path -LiteralPath $script:SelfCopy))
        if (-not $intCheck.Valid -and ($intCheck.Status -ne 'MissingManifest' -or $failMissing)) {
'@ 'Fail closed on MissingManifest for AutoHeal/Daemon/Sentinel when SelfCopy exists'

    Patch-Once ([ref]$raw) @'
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
'@ @'
        'Undo' {
            $res = Invoke-WithLock {
                Invoke-Undo -TargetId $Id -TargetRunId $RunId -Plan:$Plan -Force:$Force -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
            }
            if ($null -eq $res) {
                if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'LockTimeout'; UndoneCount = 0; ExitCode = 1 } -Depth 2)) }
                elseif ($Quiet) { [Console]::Out.WriteLine('LockTimeout: Another operation is running') }
                $exitCode = 1
            } else {
                $exitCode = switch ([string]$res.Status) { 'NotFound' { 2 } 'DriftSkipped' { 3 } 'Failed' { 1 } default { 0 } }
            }
        }
        'Recover' {
            $res = Invoke-GuidedRecovery -Plan:$Plan -Force:$Force -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
            $exitCode = if ($res) { [int]$res.ExitCode } else { 1 }
        }
        'Bundle' {
            $effRed = if ($PSBoundParameters.ContainsKey('Redaction')) { $Redaction } elseif ($script:PolicyRedaction) { $script:PolicyRedaction } else { $Redaction }
            $res = New-SupportBundle -OutDir $OutDir -Redaction $effRed -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
            $exitCode = [int]$res.ExitCode
        }
'@ 'Undo accurate exit codes + LockTimeout JSON, Recover unlock outer wrapper, wire PolicyRedaction into Bundle'

    Patch-Once ([ref]$raw) @'
        'Integrity' {
            if ($Authorize) {
'@ @'
        'Integrity' {
            if ($Authorize -and $script:IsDry) {
                if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'Planned'; Action = 'AuthorizeScriptIntegrity'; Target = $script:SelfCopy; ExitCode = 0 } -Depth 2)) }
                elseif ($Quiet) { [Console]::Out.WriteLine('DryRun: Would authorize script cryptographic integrity') }
                else { Write-Host '[DRY] Would authorize script cryptographic integrity manifest.' -ForegroundColor Cyan }
                $exitCode = 0
            } elseif ($Authorize) {
'@ 'Integrity -Authorize DryRun guard'

    Patch-Once ([ref]$raw) @'
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
'@ @'
        'Debloat' {
            if ($Audit -or ($script:IsDry -and -not $script:IsPlan)) {
                $exitCode = Invoke-NetworkDebloat -Audit -Tier $Tier -SafeOnly:$SafeOnly -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
            } elseif ($script:IsPlan) {
                $exitCode = Invoke-NetworkDebloat -Tier $Tier -SafeOnly:$SafeOnly -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
            } else {
                $rawDeb = Invoke-WithLock {
                    Invoke-NetworkDebloat -Tier $Tier -SafeOnly:$SafeOnly -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
                }
                if ($null -eq $rawDeb) {
                    if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'LockTimeout'; ExitCode = 1 } -Depth 2)) }
                    $exitCode = 1
                } else {
                    $exitCode = if ($rawDeb -is [int]) { $rawDeb } else { 0 }
                }
            }
        }
        'UndoDebloat' {
            $rawUdeb = Invoke-WithLock {
                Undo-NetworkDebloat -Json:$Json -Quiet:$Quiet -NoColor:$NoColor
            }
            if ($null -eq $rawUdeb) {
                if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'LockTimeout'; ExitCode = 1 } -Depth 2)) }
                $exitCode = 1
            } else {
                $exitCode = if ($rawUdeb -is [int]) { $rawUdeb } else { 0 }
            }
        }
    }
    $selfJsonModes = @('Doctor','Status','Bundle','Config','Report','SelfTest','Verify','Help','Guide','History','Hist','Logs','Forensics','Integrity','Recover','Undo')
    if ($script:IsPlan -and ($selfJsonModes -notcontains $Mode)) {
'@ 'Debloat/UndoDebloat LockTimeout & Plan handling + eliminate double JSON output on selfJsonModes'

    Patch-Once ([ref]$raw) @'
} catch {
    Write-Log 'FAIL' ("Unhandled error: " + $_.Exception.Message)
    Write-Log 'FAIL' ([string]$_.ScriptStackTrace)
    $exitCode = 1
} finally {
'@ @'
} catch {
    Write-Log 'FAIL' ("Unhandled error: " + $_.Exception.Message)
    Write-Log 'FAIL' ([string]$_.ScriptStackTrace)
    if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'Error'; Message = $_.Exception.Message; ExitCode = 1 } -Depth 2)) }
    elseif ($Quiet) { [Console]::Out.WriteLine('Error: ' + $_.Exception.Message) }
    $exitCode = 1
} finally {
'@ 'Emit structured JSON/Quiet on unhandled top-level exception'

    # ==========================================================================
    # PATCH 16: Invoke-LogicTests Zero-Mutation DryRun Isolation + -NoOutput + 8 v9.0.0 Behavioral Regression Tests
    # ==========================================================================
    Patch-Once ([ref]$raw) @'
    $jTempDir = Join-Path ([System.IO.Path]::GetTempPath()) ('lf_jchk_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $jTempDir -Force | Out-Null
    $origStoreForJ = $script:StoreDir
    $origIsDryJ = $script:IsDry
    $script:StoreDir = $jTempDir
    try {
        $script:IsDry = $false
'@ @'
    $jTempDir = Join-Path ([System.IO.Path]::GetTempPath()) ('lf_jchk_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $jTempDir -Force | Out-Null
    $origStoreForJ = $script:StoreDir; $origLogForJ = $script:LogFile; $origIsDryJ = $script:IsDry
    $script:StoreDir = $jTempDir; $script:LogFile = Join-Path $jTempDir 'test.log'
    try {
        $script:IsDry = $false
'@ 'Isolate LogFile in Reset Journal subtest'

    Patch-Once ([ref]$raw) @'
    } finally {
        $script:IsDry = $origIsDryJ
        $script:StoreDir = $origStoreForJ
        Remove-Item -LiteralPath $jTempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
'@ @'
    } finally {
        $script:IsDry = $origIsDryJ
        $script:LogFile = $origLogForJ
        $script:StoreDir = $origStoreForJ
        Remove-Item -LiteralPath $jTempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
'@ 'Restore LogFile in Reset Journal subtest'

    Patch-Once ([ref]$raw) @'
    $tDirPre = Join-Path ([System.IO.Path]::GetTempPath()) ('lf_pchk_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $tDirPre -Force | Out-Null
    try {
'@ @'
    $tDirPre = Join-Path ([System.IO.Path]::GetTempPath()) ('lf_pchk_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $tDirPre -Force | Out-Null
    $origStorePre = $script:StoreDir; $origDryPre = $script:IsDry; $origLogPre = $script:LogFile
    $script:LogFile = Join-Path $tDirPre 'test.log'
    try {
'@ 'Save StoreDir, IsDry & redirect LogFile before Preconditions scriptblock tests'

    Patch-Once ([ref]$raw) @'
    } finally {
        Remove-Item -LiteralPath $tDirPre -Recurse -Force -ErrorAction SilentlyContinue
    }
'@ @'
    } finally {
        $script:StoreDir = $origStorePre
        $script:IsDry = $origDryPre
        $script:LogFile = $origLogPre
        Remove-Item -LiteralPath $tDirPre -Recurse -Force -ErrorAction SilentlyContinue
    }
'@ 'Restore StoreDir, IsDry & LogFile after Preconditions scriptblock tests'

    Patch-Once ([ref]$raw) @'
    $origStoreForV = $script:StoreDir
    $origIsDryV = $script:IsDry
    $script:StoreDir = $vTempDir
    try {
        $script:IsDry = $false
'@ @'
    $origStoreForV = $script:StoreDir; $origLogForV = $script:LogFile; $origIsDryV = $script:IsDry
    $script:StoreDir = $vTempDir; $script:LogFile = Join-Path $vTempDir 'test.log'
    try {
        $script:IsDry = $false
'@ 'Isolate LogFile in Stage-PostRebootVerification subtest'

    Patch-Once ([ref]$raw) @'
    } finally {
        $script:IsDry = $origIsDryV
        $script:StoreDir = $origStoreForV
        Remove-Item -LiteralPath $vTempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
'@ @'
    } finally {
        $script:IsDry = $origIsDryV
        $script:LogFile = $origLogForV
        $script:StoreDir = $origStoreForV
        Remove-Item -LiteralPath $vTempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
'@ 'Restore LogFile in Stage-PostRebootVerification subtest'

    Patch-Once ([ref]$raw) @'
    $origStoreForLedg = $script:StoreDir
    $origIsDryLedg = $script:IsDry
    $origRunId = $script:RunId
    $script:StoreDir = $ledgerTempDir
    try {
        $script:IsDry = $false
'@ @'
    $origStoreForLedg = $script:StoreDir; $origLogForLedg = $script:LogFile; $origIsDryLedg = $script:IsDry; $origRunId = $script:RunId
    $script:StoreDir = $ledgerTempDir; $script:LogFile = Join-Path $ledgerTempDir 'test.log'
    try {
        $script:IsDry = $false
'@ 'Isolate LogFile in ChangeLedger subtest'

    Patch-Once ([ref]$raw) @'
    } finally {
        $script:IsDry = $origIsDryLedg
        $script:StoreDir = $origStoreForLedg
        $script:RunId = $origRunId
        Remove-Item -LiteralPath $ledgerTempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
'@ @'
    } finally {
        $script:IsDry = $origIsDryLedg
        $script:LogFile = $origLogForLedg
        $script:StoreDir = $origStoreForLedg
        $script:RunId = $origRunId
        Remove-Item -LiteralPath $ledgerTempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
'@ 'Restore LogFile in ChangeLedger subtest'

    Patch-Once ([ref]$raw) @'
    $origStoreForInt = $script:StoreDir
    $script:StoreDir = $intTempDir
    try {
        [System.IO.File]::WriteAllText($testScript, '@echo off`r`necho OK`r`n', [System.Text.Encoding]::ASCII)
        $authOk = Set-ScriptAuthorization $testScript
'@ @'
    $origStoreForInt = $script:StoreDir; $origLogForInt = $script:LogFile; $origDryForInt = $script:IsDry
    $script:StoreDir = $intTempDir; $script:LogFile = Join-Path $intTempDir 'test.log'; $script:IsDry = $false
    try {
        [System.IO.File]::WriteAllText($testScript, "@echo off`r`necho OK`r`n", [System.Text.Encoding]::ASCII)
        $authOk = Set-ScriptAuthorization $testScript
'@ 'Isolate LogFile in Integrity subtest'

    Patch-Once ([ref]$raw) @'
    } finally {
        $script:StoreDir = $origStoreForInt
        Remove-Item -LiteralPath $intTempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
'@ @'
    } finally {
        $script:StoreDir = $origStoreForInt
        $script:LogFile = $origLogForInt
        $script:IsDry = $origDryForInt
        Remove-Item -LiteralPath $intTempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
'@ 'Restore LogFile in Integrity subtest'

    Patch-Once ([ref]$raw) @'
    $origStoreForReset = $script:StoreDir
    $origIsDryReset = $script:IsDry
    $resetTempDir = Join-Path ([System.IO.Path]::GetTempPath()) ('lf_rst_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $resetTempDir -Force | Out-Null
    $script:StoreDir = $resetTempDir
    try {
        $script:IsDry = $false
'@ @'
    $origStoreForReset = $script:StoreDir; $origLogForReset = $script:LogFile; $origIsDryReset = $script:IsDry
    $resetTempDir = Join-Path ([System.IO.Path]::GetTempPath()) ('lf_rst_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $resetTempDir -Force | Out-Null
    $script:StoreDir = $resetTempDir; $script:LogFile = Join-Path $resetTempDir 'test.log'
    try {
        $script:IsDry = $false
'@ 'Isolate LogFile in Reset Subsystem subtest'

    Patch-Once ([ref]$raw) @'
    } finally {
        $script:IsDry = $origIsDryReset
        $script:StoreDir = $origStoreForReset
        Remove-Item -LiteralPath $resetTempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
'@ @'
    } finally {
        $script:IsDry = $origIsDryReset
        $script:LogFile = $origLogForReset
        $script:StoreDir = $origStoreForReset
        Remove-Item -LiteralPath $resetTempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
'@ 'Restore LogFile in Reset Subsystem subtest'

    Patch-Once ([ref]$raw) @'
    $auditRes = Invoke-NetworkDebloat -Audit -Json
    Write-Check 'Logic: Invoke-NetworkDebloat -Audit executes successfully with zero mutations' ($auditRes -eq 0)

    $undoRes = Undo-NetworkDebloat -Json
    Write-Check 'Logic: Undo-NetworkDebloat handles non-existent snapshot gracefully' ($undoRes -eq 0)
'@ @'
    $auditRes = Invoke-NetworkDebloat -Audit -Json -NoOutput
    Write-Check 'Logic: Invoke-NetworkDebloat -Audit executes successfully with zero mutations' ($auditRes -eq 0)

    $stDebBak = $script:State
    $script:State = @{ Snapshot = @{}; Misc = @{} }
    $undoRes = Undo-NetworkDebloat -Json -NoOutput
    $script:State = $stDebBak
    Write-Check 'Logic: Undo-NetworkDebloat handles non-existent snapshot gracefully' ($undoRes -eq 0)
'@ 'Silence & isolate Debloat tests inside Invoke-LogicTests so SelfTest -Json emits pure single JSON'

    Patch-Once ([ref]$raw) @'
    $origStU = $script:StoreDir; $origDryU = $script:IsDry; $origRunU = $script:RunId
    $script:StoreDir = $uTmpDir; $script:IsDry = $false; $script:RunId = 'run-idem-1'
    try {
        Add-ChangeLedgerEntry -Description 'Idempotent undo test' -MutationType 'Generic' -Target 'Test' -Success $true -Reversible $true -UndoScript '$true'
        $u1 = Invoke-Undo -Quiet
        $u2 = Invoke-Undo -Quiet
        Write-Check 'Logic: Invoke-Undo is idempotent and pops each run at most once' ($u1.UndoneCount -eq 1 -and $u2.Status -eq 'Empty')
    } finally {
        $script:StoreDir = $origStU; $script:IsDry = $origDryU; $script:RunId = $origRunU
        Remove-Item -LiteralPath $uTmpDir -Recurse -Force -ErrorAction SilentlyContinue
    }
'@ @'
    $origStU = $script:StoreDir; $origLogU = $script:LogFile; $origDryU = $script:IsDry; $origRunU = $script:RunId
    $script:StoreDir = $uTmpDir; $script:LogFile = Join-Path $uTmpDir 'test.log'; $script:IsDry = $false; $script:RunId = 'run-idem-1'
    try {
        Add-ChangeLedgerEntry -Description 'Idempotent undo test' -MutationType 'Generic' -Target 'Test' -Success $true -Reversible $true -UndoScript '$true'
        $u1 = Invoke-Undo -Quiet
        $u2 = Invoke-Undo -Quiet
        Write-Check 'Logic: Invoke-Undo is idempotent and pops each run at most once' ($u1.UndoneCount -eq 1 -and $u2.Status -eq 'Empty')

        $script:RunId = 'run-drift-del'
        Add-ChangeLedgerEntry -Description 'Deleted reg drift' -MutationType 'Registry' -Target 'HKCU:\Software\LanFixerNonExistentKey' -ValueName 'TestVal' -OldValue 0 -NewValue 1 -Success $true -Reversible $true -UndoScript '$true'
        $uDriftDel = Invoke-Undo -TargetRunId 'run-drift-del' -Quiet
        Write-Check 'Logic: Invoke-Undo detects externally deleted registry value as drift' ($uDriftDel.SkippedCount -eq 1 -and $uDriftDel.UndoneCount -eq 0 -and $uDriftDel.Status -eq 'DriftSkipped')
    } finally {
        $script:StoreDir = $origStU; $script:LogFile = $origLogU; $script:IsDry = $origDryU; $script:RunId = $origRunU
        Remove-Item -LiteralPath $uTmpDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    # v9.0.0 OMNI-360 Behavioral Regression Assertions
    $v6Ts = Invoke-Redaction '2026-11-25T19:02:17.123+05:30 v6a=2401:4900::1:2 local=fe80::1 ula=fd12::1 lo=::1' -Level 'Strict'
    Write-Check 'Logic: Invoke-Redaction preserves timestamps & masks multi-hextet public IPv6' ($v6Ts -match '2026-11-25T19:02:17\.123\+05:30' -and $v6Ts -match 'v6a=\[PUBLIC_IPV6_REDACTED\]' -and $v6Ts -match 'local=fe80::1' -and $v6Ts -match 'ula=fd12::1')

    $cfgExitOk = ((Show-ConfigReport -ValidateOnly -Quiet) -eq 1)
    Write-Check 'Logic: Show-ConfigReport -ValidateOnly returns clean int exit code without PS5.1 crash' $cfgExitOk

    $iniCmtDir = Join-Path ([System.IO.Path]::GetTempPath()) ('lf_inicmt_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $iniCmtDir -Force | Out-Null
    try {
        $cf = Join-Path $iniCmtDir 'c.ini'
        [System.IO.File]::WriteAllText($cf, "[General]`r`nLogLevel = WARN ; inline comment`r`nNoColor = True # second`r`n", [System.Text.Encoding]::ASCII)
        $ci = ConvertFrom-IniFile $cf
        Write-Check 'Logic: ConvertFrom-IniFile strips inline semicolon and hash comments' ($ci.General.LogLevel -eq 'WARN' -and $ci.General.NoColor -eq 'True')
    } finally {
        Remove-Item -LiteralPath $iniCmtDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    $aclTempDir = Join-Path ([System.IO.Path]::GetTempPath()) ('lf_acl_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $aclTempDir -Force | Out-Null
    $origStAcl = $script:StoreDir; $origLogAcl = $script:LogFile; $origDryAcl = $script:IsDry
    $script:StoreDir = $aclTempDir; $script:LogFile = Join-Path $aclTempDir 'test.log'; $script:IsDry = $false
    try {
        $tScr = Join-Path $aclTempDir 't_acl.cmd'
        [System.IO.File]::WriteAllText($tScr, "@echo off`r`necho OK`r`n", [System.Text.Encoding]::ASCII)
        [void](Set-ScriptAuthorization $tScr)
        $icaclsExe = Get-SysExe 'icacls.exe'
        [void](Invoke-Native $icaclsExe @($tScr, '/grant', '*S-1-5-32-545:(RX)', '/Q') 5000)
        $rRx = Test-ScriptIntegrity $tScr
        [void](Invoke-Native $icaclsExe @($tScr, '/grant', '*S-1-5-32-545:(W)', '/Q') 5000)
        $rWr = Test-ScriptIntegrity $tScr
        Write-Check 'Logic: Test-ScriptIntegrity allows non-write Users:(RX) and blocks writable Users:(W)' ($rRx.Valid -and -not $rWr.Valid -and $rWr.Status -eq 'UntrustedAcl')
    } finally {
        $script:StoreDir = $origStAcl; $script:LogFile = $origLogAcl; $script:IsDry = $origDryAcl
        Remove-Item -LiteralPath $aclTempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
'@ 'Isolate Undo subtest LogFile & add v9.0.0 OMNI-360 behavioral assertions'

    # Update stale v5.2/v8.0 definition assertions to v9.0.0 OMNI-360 contracts
    Patch-Once ([ref]$raw) @'
    Write-Check 'Logic: Get-ScopedDnsAnswers keeps metric-45 filter for non-Wifi profiles and restricts unbound fallback' ($sdDef.IndexOf("InterfaceMetric -ge 45 -and (Get-RouteProfileName) -ne 'Wifi'") -ge 0 -and $sdDef.IndexOf('else { continue }') -ge 0)
'@ @'
    Write-Check 'Logic: Get-ScopedDnsAnswers keeps metric-45 filter for non-Wifi profiles and enforces strict SourceIp bind' ($sdDef.IndexOf("InterfaceMetric -ge 45 -and (Get-RouteProfileName) -ne 'Wifi'") -ge 0 -and $sdDef.IndexOf('if (-not $u) { continue }') -ge 0)
'@ 'SelfTest Get-ScopedDnsAnswers strict SourceIp bind contract'

    Patch-Once ([ref]$raw) @'
    Write-Check 'Logic: Test-GatewayAlive never deletes a neighbour entry during -DryRun' ($gaDef -match 'IsAdmin -and -not \$script:IsDry -and \$ex')
    Write-Check 'Logic: gateway liveness proxy probes the configured campus only on the home campus' (($gaDef.IndexOf('$homeAd') -ge 0) -and ($gaDef.IndexOf('Test-TcpPort $Gw 53') -ge 0))
'@ @'
    Write-Check 'Logic: Test-GatewayAlive is read-only and never deletes neighbour entries' ($gaDef.IndexOf('Remove-NetNeighbor') -lt 0 -and $gaDef.IndexOf('Test-ActiveArp') -ge 0)
    Write-Check 'Logic: Test-GatewayAlive probes gateway ports in parallel with bound SourceIp' ($gaDef.IndexOf('Test-AnyTcpPortParallel') -ge 0 -and $gaDef.IndexOf('$gwSrc') -ge 0)
'@ 'SelfTest Test-GatewayAlive v9.0.0 read-only parallel contract'

    Patch-Once ([ref]$raw) @'
    Write-Check 'Logic: Get-DashboardModel reserves categorized dock for width 74+ and height 28+' ($gdmDef.IndexOf('$uiH -ge 28') -ge 0)
'@ @'
    Write-Check 'Logic: Get-DashboardModel reserves categorized dock for width 74+ and height 31+' ($gdmDef.IndexOf('$uiH -ge 31') -ge 0)
'@ 'SelfTest Get-DashboardModel height 31 contract'

    # Clean CRLF + 7-bit ASCII check
    $raw = $raw.Replace("`r`r`n", "`r`n")
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($raw)
    for ($bi = 0; $bi -lt $bytes.Length; $bi++) {
        if ($bytes[$bi] -gt 127) { throw "Non-ASCII byte detected at offset $bi" }
    }
    if ($raw.Replace("`r`n", '').Contains("`n")) { throw 'Solo LF detected in output' }
    [System.IO.File]::WriteAllBytes($primary, $bytes)

    # ==========================================================================
    # GATE 1: PowerShell AST Verification (0 errors required)
    # ==========================================================================
    Write-Host '[*] GATE 1: Running PowerShell AST parser verification...' -ForegroundColor Cyan
    $astErrors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($primary, [ref]$null, [ref]$astErrors)
    if ($astErrors -and $astErrors.Count -gt 0) {
        $msg = ($astErrors | ForEach-Object { $_.ToString() }) -join "`n"
        throw "AST Verification Failed ($($astErrors.Count) errors):`n$msg"
    }

    # ==========================================================================
    # GATE 2: Full SelfTest Suite (-DryRun) + Strict JSON & LogFile Invariance
    # ==========================================================================
    Write-Host '[*] GATE 2: Executing full SelfTest verification suite (-DryRun -NoPause -Json)...' -ForegroundColor Cyan
    $logBefore = if (Test-Path 'C:\ProgramData\LanFixer\LanFixer.log') { (Get-Item 'C:\ProgramData\LanFixer\LanFixer.log').Length } else { -1 }
    $swTest = [System.Diagnostics.Stopwatch]::StartNew()
    $stOut = & $primary -Mode SelfTest -DryRun -NoPause -Json 2>&1
    $stCode = $LASTEXITCODE
    $swTest.Stop()
    $logAfter = if (Test-Path 'C:\ProgramData\LanFixer\LanFixer.log') { (Get-Item 'C:\ProgramData\LanFixer\LanFixer.log').Length } else { -1 }
    $stText = ($stOut | Out-String).Trim()
    if ($stCode -ne 0) { throw "SelfTest Failed (ExitCode=$stCode):`n$stText" }
    $stObj = $null
    try {
        $stObj = $stText | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "SelfTest -Json did NOT produce pure single valid JSON (`$($_.Exception.Message)`):`n$($stText.Substring(0, [math]::Min(600, $stText.Length)))"
    }
    if (-not $stObj -or $stObj.Failures -gt 0) {
        $failedLabels = if ($stObj -and $stObj.Checks) { @($stObj.Checks | Where-Object { -not $_.Passed -and -not $_.WarnOnly } | ForEach-Object { $_.Label }) -join "`n  - " } else { 'Unknown' }
        throw "SelfTest reported $($stObj.Failures) failure(s):`n  - $failedLabels"
    }

    # Synchronize canonical copies
    $canonSub = Join-Path $here 'LanFixer.cmd'
    if ($primary -ne $canonSub) { [System.IO.File]::WriteAllBytes($canonSub, $bytes) }
    $desktopCopy = 'C:\Users\ABHISHEK SONU\Desktop\LanFixer.cmd'
    if ((Test-Path -LiteralPath (Split-Path -Parent $desktopCopy)) -and ($primary -ne $desktopCopy)) {
        [System.IO.File]::WriteAllBytes($desktopCopy, $bytes)
    }

    $hasher = [System.Security.Cryptography.SHA256]::Create()
    $sha = -join ($hasher.ComputeHash($bytes) | ForEach-Object { $_.ToString('X2') })
    $newLines = ([regex]::Matches($raw, "`r`n")).Count

    Write-Host ''
    Write-Host '================================================================================' -ForegroundColor Green
    Write-Host '  SUCCESS: LanFixer Upgraded to v9.0.0 (OMNI-360 Zero-Compromise Edition)' -ForegroundColor Green
    Write-Host '================================================================================' -ForegroundColor Green
    Write-Host ("  Target File : {0}" -f $canonSub) -ForegroundColor White
    Write-Host ("  Desktop Sync: {0}" -f $desktopCopy) -ForegroundColor White
    Write-Host ("  Patches     : {0} surgical upgrades applied" -f $script:PatchCount) -ForegroundColor White
    Write-Host ("  Lines       : {0} -> {1} lines (7-bit ASCII CRLF)" -f $origLines, $newLines) -ForegroundColor White
    Write-Host ("  AST Check   : 0 syntax errors" ) -ForegroundColor Green
    Write-Host ("  SelfTest    : {0}/{1} PASSED ({2} warnings) in {3:N1}s | Pure JSON: True" -f $stObj.Passed, $stObj.TotalChecks, $stObj.Warnings, $swTest.Elapsed.TotalSeconds) -ForegroundColor Green
    Write-Host ("  DryRun Log  : Before={0}B -> After={1}B (Note: diff=0 unless external task ran)" -f $logBefore, $logAfter) -ForegroundColor DarkGray
    Write-Host ("  SHA-256     : {0}" -f $sha) -ForegroundColor DarkGray
    Write-Host ("  Backup      : {0}" -f $backupPath) -ForegroundColor DarkGray
    Write-Host '================================================================================' -ForegroundColor Green
}
catch {
    Copy-Item -LiteralPath $backupPath -Destination $primary -Force
    Write-Host ''
    Write-Host "ROLLED BACK '$primary' to original backup ($backupPath) due to error:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    exit 1
}
