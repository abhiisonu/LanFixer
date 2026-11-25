#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$candidates = @(@('LanFixer.cmd', 'LanFixer_2.cmd', 'LanFixer-2_2.cmd', 'NetFix.cmd') | Where-Object { Test-Path -LiteralPath $_ })
if ($candidates.Count -eq 0) {
    Write-Error 'No LanFixer.cmd / LanFixer_2.cmd found in the current directory.'
    exit 1
}

$primary = (Resolve-Path -LiteralPath $candidates[0]).Path
foreach ($c in $candidates) {
    $p = (Resolve-Path -LiteralPath $c).Path
    $txt = [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::ASCII)
    if ($txt -match "\`$script:Version\s*=\s*'1[01]\.\d+\.\d+'") { $primary = $p; break }
}

$dir = Split-Path -Parent $primary
$archiveDir = Join-Path $dir 'Archive'
if (-not (Test-Path -LiteralPath $archiveDir)) { [void](New-Item -ItemType Directory -Path $archiveDir -Force) }
$stamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
$backupPath = Join-Path $archiveDir ("{0}_pre_v11_{1}.cmd" -f [System.IO.Path]::GetFileNameWithoutExtension($primary), $stamp)
Copy-Item -LiteralPath $primary -Destination $backupPath -Force

$raw = [System.IO.File]::ReadAllText($primary, [System.Text.Encoding]::ASCII)
$raw = $raw.Replace("`r`r`n", "`r`n").Replace("`r`n", "`n").Replace("`n", "`r`n")

function Replace-FunctionAst {
    param([ref]$TextRef, [string]$FuncName, [string]$NewCode)
    $errs = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($TextRef.Value, [ref]$null, [ref]$errs)
    if ($errs -and $errs.Count -gt 0) {
        throw ("Pre-patch AST error before replacing {0}: {1}" -f $FuncName, $errs[0].ToString())
    }
    $hits = @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq $FuncName }, $true))
    if ($hits.Count -ne 1) {
        throw ("Expected exactly 1 definition of '{0}', found {1}" -f $FuncName, $hits.Count)
    }
    $t = $hits[0]
    $norm = $NewCode.Replace("`r`n", "`n").Replace("`n", "`r`n").TrimEnd()
    $TextRef.Value = $TextRef.Value.Substring(0, $t.Extent.StartOffset) + $norm + $TextRef.Value.Substring($t.Extent.EndOffset)
    Write-Host ("  [AST-UPGRADED] {0}" -f $FuncName) -ForegroundColor Green
}

function Ensure-HelperFunctionAst {
    param([ref]$TextRef, [string]$FuncName, [string]$BeforeFuncName, [string]$Code)
    $errs = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($TextRef.Value, [ref]$null, [ref]$errs)
    if ($errs -and $errs.Count -gt 0) {
        throw ("Pre-patch AST error before ensuring {0}: {1}" -f $FuncName, $errs[0].ToString())
    }
    $norm = $Code.Replace("`r`n", "`n").Replace("`n", "`r`n").TrimEnd()
    $existing = @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq $FuncName }, $true))
    if ($existing.Count -eq 1) {
        $t = $existing[0]
        $TextRef.Value = $TextRef.Value.Substring(0, $t.Extent.StartOffset) + $norm + $TextRef.Value.Substring($t.Extent.EndOffset)
        Write-Host ("  [AST-UPDATED]  {0}" -f $FuncName) -ForegroundColor Green
        return
    }
    $anchor = @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq $BeforeFuncName }, $true))
    if ($anchor.Count -ne 1) {
        throw ("Anchor function '{0}' not found for inserting '{1}'" -f $BeforeFuncName, $FuncName)
    }
    $pos = $anchor[0].Extent.StartOffset
    $TextRef.Value = $TextRef.Value.Substring(0, $pos) + $norm + "`r`n" + $TextRef.Value.Substring($pos)
    Write-Host ("  [AST-ADDED]    {0}" -f $FuncName) -ForegroundColor Cyan
}

function Inject-FunctionEntryHookAst {
    param([ref]$TextRef, [string]$FuncName, [string]$Tag, [string]$HookCode)
    $errs = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($TextRef.Value, [ref]$null, [ref]$errs)
    if ($errs -and $errs.Count -gt 0) { throw ("AST error before hooking {0}" -f $FuncName) }
    $hits = @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq $FuncName }, $true))
    if ($hits.Count -ne 1) {
        Write-Host ("  [SKIP-MISSING] {0} not present in file" -f $FuncName) -ForegroundColor Yellow
        return
    }
    $fn = $hits[0]
    $startMark = "# [$Tag`_START]"
    $endMark   = "# [$Tag`_END]"
    $block = ("`r`n    {0}`r`n{1}`r`n    {2}" -f $startMark, ($HookCode.Replace("`r`n", "`n").Replace("`n", "`r`n").TrimEnd()), $endMark)
    $fnTxt = $fn.Extent.Text
    $sIdx = $fnTxt.IndexOf($startMark, [System.StringComparison]::Ordinal)
    $eIdx = $fnTxt.IndexOf($endMark, [System.StringComparison]::Ordinal)
    if ($sIdx -ge 0 -and $eIdx -gt $sIdx) {
        $absS = $fn.Extent.StartOffset + $sIdx
        $absE = $fn.Extent.StartOffset + $eIdx + $endMark.Length
        $TextRef.Value = $TextRef.Value.Substring(0, $absS) + $block.TrimStart("`r`n") + $TextRef.Value.Substring($absE)
        Write-Host ("  [HOOK-UPDATED] {0} ({1})" -f $FuncName, $Tag) -ForegroundColor Green
    } else {
        $insertPos = if ($fn.Body.ParamBlock) { $fn.Body.ParamBlock.Extent.EndOffset } else { $fn.Body.Extent.StartOffset + 1 }
        $TextRef.Value = $TextRef.Value.Substring(0, $insertPos) + $block + $TextRef.Value.Substring($insertPos)
        Write-Host ("  [HOOK-ADDED]   {0} ({1})" -f $FuncName, $Tag) -ForegroundColor Cyan
    }
}

try {
    Write-Host ("Upgrading {0} -> LanFixer v11.0.0 Sovereign Edition..." -f $primary) -ForegroundColor Cyan

    # 1. Version bump (handles 10.0.0, 10.1.0, 10.2.0, or re-run of 11.0.0)
    $raw = [regex]::Replace($raw, "LanFixer 1[01]\.\d+\.\d+ - Autonomous", "LanFixer 11.0.0 - Autonomous", 1)
    $raw = [regex]::Replace($raw, "\`$script:Version\s*=\s*'1[01]\.\d+\.\d+'", "`$script:Version = '11.0.0'", 1)

    # 2. Invoke-Undo: -NoColor purity & accurate DriftSkipped separation
    Replace-FunctionAst ([ref]$raw) 'Invoke-Undo' @'
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
            elseif (-not $Quiet) { Write-Host "Error: Entry ID '$TargetId' not found in change ledger." }
            return @{ Status = 'NotFound'; UndoneCount = 0 }
        }
        if ($TargetRunId) {
            if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'NotFound'; TargetRunId = $TargetRunId; UndoneCount = 0 })) }
            elseif (-not $Quiet) { Write-Host "Error: Run ID '$TargetRunId' not found in change ledger." }
            return @{ Status = 'NotFound'; UndoneCount = 0 }
        }
        if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'Empty'; UndoneCount = 0; Entries = @() })) }
        elseif (-not $Quiet) { Write-Host 'No mutations recorded in change ledger to undo.' }
        return @{ Status = 'Empty'; UndoneCount = 0 }
    }

    $revertedIds = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($ae in $allEntries) {
        if ($ae.MutationType -eq 'Undo' -and $ae.RevertedEntryId) {
            [void]$revertedIds.Add([string]$ae.RevertedEntryId)
        }
    }

    $candidates = @()
    if ($TargetId) {
        $candidates = @($allEntries | Where-Object { $_.EntryId -eq $TargetId -or $_.EntryId -like "$TargetId*" })
        if ($candidates.Count -eq 0) {
            if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'NotFound'; TargetId = $TargetId; UndoneCount = 0 })) }
            elseif (-not $Quiet) { Write-Host "Error: Entry ID '$TargetId' not found in change ledger." }
            return @{ Status = 'NotFound'; UndoneCount = 0 }
        }
    } elseif ($TargetRunId) {
        $candidates = @($allEntries | Where-Object { $_.RunId -eq $TargetRunId })
        if ($candidates.Count -eq 0) {
            if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'NotFound'; TargetRunId = $TargetRunId; UndoneCount = 0 })) }
            elseif (-not $Quiet) { Write-Host "Error: Run ID '$TargetRunId' not found in change ledger." }
            return @{ Status = 'NotFound'; UndoneCount = 0 }
        }
    } else {
        $lastMut = @($allEntries | Where-Object { $_.Success -and $_.Reversible -and $_.RunId -and (-not $revertedIds.Contains([string]$_.EntryId)) }) | Select-Object -Last 1
        if (-not $lastMut) {
            if ($Json) { [Console]::Out.WriteLine((ConvertTo-Json @{ Status = 'Empty'; UndoneCount = 0; SkippedCount = 0; Entries = @() })) }
            elseif (-not $Quiet) { Write-Host 'All recorded reversible mutations have already been undone.' }
            return @{ Status = 'Empty'; UndoneCount = 0; SkippedCount = 0 }
        }
        $chosenRunId = $lastMut.RunId
        $candidates = @($allEntries | Where-Object { $_.RunId -eq $chosenRunId })
    }

    $candidatesList = New-Object System.Collections.ArrayList
    foreach ($item in $candidates) { [void]$candidatesList.Add($item) }
    $candidatesList.Reverse()

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

    $undoneCount = 0
    $skippedCount = 0
    $driftSkippedCount = 0
    $planEntries = New-Object System.Collections.ArrayList

    foreach ($e in $candidatesList) {
        $idShort = if ($e.EntryId -and $e.EntryId.Length -ge 8) { $e.EntryId.Substring(0, 8) } else { [string]$e.EntryId }
        if (-not $Force -and $revertedIds.Contains([string]$e.EntryId)) {
            if (-not $Quiet -and -not $Json) {
                $m = ("  [SKIP] Entry {0} ({1}) was already undone." -f $idShort, $e.Description)
                if ($ncUndo) { Write-Host $m } else { Write-Host $m -ForegroundColor DarkGray }
            }
            $skippedCount++
            continue
        }
        if (-not $e.Reversible -and -not $e.UndoScript) {
            if (-not $Quiet -and -not $Json) {
                $m = ("  [SKIP] Entry {0} ({1}) is marked non-reversible." -f $idShort, $e.Description)
                if ($ncUndo) { Write-Host $m } else { Write-Host $m -ForegroundColor DarkGray }
            }
            $skippedCount++
            continue
        }

        $driftDetected = $false
        $driftReason = ''
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
                $m = ("  [DRIFT REFUSED] Entry {0}: {1} (use -Force to override)" -f $idShort, $driftReason)
                if ($ncUndo) { Write-Host $m } else { Write-Host $m -ForegroundColor Yellow }
            }
            $skippedCount++
            $driftSkippedCount++
            continue
        }

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

        $undoSuccess = $false
        if ($e.UndoScript) {
            try {
                $sb = [scriptblock]::Create($e.UndoScript)
                $res = Invoke-Change ("Undo {0}: {1}" -f $idShort, $e.Description) $sb -NoLedger
                if ($res) { $undoSuccess = $true }
            } catch {
                Write-Log 'FAIL' ("Undo {0} failed: {1}" -f $idShort, $_.Exception.Message)
            }
        } elseif ($e.MutationType -eq 'DnsClientServerAddress' -and $e.Target) {
            $oldAddresses = @($e.OldValue) | Where-Object { $_ }
            if ($oldAddresses.Count -gt 0) {
                $undoSuccess = Invoke-Change ("Restore DNS on {0} to {1}" -f $e.Target, ($oldAddresses -join ', ')) {
                    Set-DnsClientServerAddress -InterfaceAlias $e.Target -ServerAddresses $oldAddresses -ErrorAction Stop
                } -NoLedger
            } else {
                $undoSuccess = Invoke-Change ("Reset DNS on {0} to DHCP" -f $e.Target) {
                    Set-DnsClientServerAddress -InterfaceAlias $e.Target -ResetServerAddresses -ErrorAction Stop
                } -NoLedger
            }
        } elseif ($e.MutationType -eq 'Registry' -and $e.Target -and $e.ValueName) {
            if ($null -ne $e.OldValue) {
                $undoSuccess = Invoke-Change ("Restore registry {0}\{1} to {2}" -f $e.Target, $e.ValueName, $e.OldValue) {
                    Set-ItemProperty -LiteralPath $e.Target -Name $e.ValueName -Value $e.OldValue -ErrorAction Stop
                } -NoLedger
            } else {
                $undoSuccess = Invoke-Change ("Remove registry value {0}\{1}" -f $e.Target, $e.ValueName) {
                    Remove-ItemProperty -LiteralPath $e.Target -Name $e.ValueName -ErrorAction Stop
                } -NoLedger
            }
        }

        if ($undoSuccess) {
            $undoneCount++
            [void]$revertedIds.Add([string]$e.EntryId)
            Add-ChangeLedgerEntry -Description ("Reverted mutation {0}" -f $idShort) -MutationType 'Undo' -Target $e.Target -ValueName ([string]$e.ValueName) -OldValue $e.NewValue -NewValue $e.OldValue -Success $true -Reversible $false -RevertedEntryId ([string]$e.EntryId)
        }
    }

    $finalStatus = if ($previewMode) { 'Planned' } elseif ($undoneCount -eq 0 -and $driftSkippedCount -gt 0) { 'DriftSkipped' } else { 'Completed' }
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

    return $summary
}
'@

    # 3. Get-HistoryErrors & Get-HistoryTimeline: read rotated .bak archives via Get-ChangeLedgerEntries
    Replace-FunctionAst ([ref]$raw) 'Get-HistoryErrors' @'
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
    $ledgerItems = @(Get-ChangeLedgerEntries -Limit ([Math]::Max(100, $Limit * 4)))
    for ($i = $ledgerItems.Count - 1; $i -ge 0; $i--) {
        $item = $ledgerItems[$i]
        if ($item -and $item.Success -eq $false) {
            [void]$errList.Add(@{
                Timestamp = if ($item.TimestampLocal) { $item.TimestampLocal } else { $item.TimestampUtc }
                Severity  = 'Error'
                Category  = 'Mutation'
                Source    = 'change_ledger.jsonl'
                Message   = ("Failed mutation ({0}) on {1}: {2}" -f $item.MutationType, $item.Target, $item.Description)
            })
        }
        if ($errList.Count -ge ($Limit * 2)) { break }
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
'@

    Replace-FunctionAst ([ref]$raw) 'Get-HistoryTimeline' @'
function Get-HistoryTimeline([int]$Limit = 50) {
    $timeline = New-Object System.Collections.ArrayList
    $halfLim = [Math]::Max(1, [int][Math]::Ceiling($Limit / 2.0))
    $ledgerTl = @(Get-ChangeLedgerEntries -Limit $halfLim)
    for ($i = $ledgerTl.Count - 1; $i -ge 0; $i--) {
        $e = $ledgerTl[$i]
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
    }
    $logs = Get-HistorySessionLogs -Limit $halfLim
    foreach ($l in $logs) {
        $cat = if ($l.Level -in @('FAIL', 'WARN')) { '[ERROR]' } elseif ($l.Level -eq 'STEP') { '[STEP]' } else { '[LOG]' }
        [void]$timeline.Add(@{
            Timestamp = $l.Timestamp
            Category  = $cat
            Source    = 'LanFixer'
            Event     = $l.Message
        })
    }
    $win = Get-HistoryWindowsEvents -Limit $halfLim
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
'@

    # 4. Import-UserConfig & Initialize-Store: idempotent config load, accurate DryRun ACL check, always re-sign integrity.json
    Replace-FunctionAst ([ref]$raw) 'Import-UserConfig' @'
function Import-UserConfig {
    if ($script:UserConfigLoaded -eq $true) { return }
    try {
        $path = Join-Path $script:StoreDir 'config.json'
        $script:UserConfigLoaded = $true
        if (-not (Test-Path -LiteralPath $path)) { return }
        $fi = Get-Item -LiteralPath $path -Force
        if ($fi.Length -gt 65536 -or ($fi.Attributes -band [IO.FileAttributes]::ReparsePoint)) { Write-Log 'WARN' 'config.json ignored (too large or a link).'; return }
        if (-not (Test-ConfigFileTrusted $path)) { Write-Log 'WARN' 'config.json ignored: it must be owned by Administrators or SYSTEM and not writable by other accounts.'; return }
        $rawCfg = [System.IO.File]::ReadAllText($path)
        $ov = ConvertTo-CfgOverride ($rawCfg | ConvertFrom-Json -ErrorAction Stop)
        $names = New-Object System.Collections.ArrayList
        foreach ($k in @($ov.Keys)) { $script:Cfg[$k] = $ov[$k]; [void]$names.Add($k) }
        if ($names.Count -gt 0) { Write-Log 'INFO' ('config.json applied: ' + (($names | Sort-Object) -join ', ')) }
    } catch { Write-Log 'WARN' ('config.json ignored: ' + $_.Exception.Message) }
}
'@

    Replace-FunctionAst ([ref]$raw) 'Initialize-Store' @'
function Initialize-Store {
    $dir = $script:StoreDir
    $trusted = @('S-1-5-18', 'S-1-5-32-544', 'S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464')
    try {
        $curSid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
        if ($curSid) { $trusted += $curSid }
    } catch {}
    if ($script:IsDry -or $script:IsPlan) {
        $script:StoreReady = (Test-Path -LiteralPath $dir)
        $script:StoreSecure = if ($script:StoreReady) { Test-StoreAcl $dir } else { $false }
        if ($script:StoreReady) { Import-UserConfig }
        return
    }
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
        $r1 = Invoke-Native $icacls @($dir, '/setowner', '*S-1-5-32-544', '/C', '/Q')
        $r2 = Invoke-Native $icacls @($dir, '/inheritance:r', '/grant:r', '*S-1-5-18:(OI)(CI)F', '/grant:r', '*S-1-5-32-544:(OI)(CI)F', '/grant:r', '*S-1-5-32-545:(OI)(CI)RX', '/C', '/Q')
        Repair-StoreChildren $dir
        Import-UserConfig
        $script:StoreSecure = ($r1.ExitCode -eq 0 -and $r2.ExitCode -eq 0)
        $script:StoreReady = $true
        try { $fi = Get-Item -LiteralPath $script:LogFile -ErrorAction Stop; if ($fi.Length -gt $script:Cfg.LogMaxBytes) { Move-Item -LiteralPath $script:LogFile -Destination ($script:LogFile + '.1') -Force } } catch {}
        if (-not $script:StoreSecure) { Write-Log 'WARN' 'Could not lock down the store folder ACL; the watchdog will refuse to install.' }
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
'@

    # 5. Socket & TLS handle disposal order + home-router safe autodiscovery + zero-copy Invoke-TlsHttp
    Replace-FunctionAst ([ref]$raw) 'Test-PortSupportsTls' @'
function Test-PortSupportsTls([string]$Ip, [int]$Port, [int]$TimeoutMs = 600, [string]$SourceIp = '') {
    $sock = $null; $ssl = $null; $ns = $null; $iar = $null
    try {
        $sock = New-Object System.Net.Sockets.Socket([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
        if ($SourceIp) {
            try { $sock.Bind((New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($SourceIp), 0))) } catch {}
        }
        $iar = $sock.BeginConnect([System.Net.IPAddress]::Parse($Ip), $Port, $null, $null)
        if (-not $iar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)) { return $false }
        $sock.EndConnect($iar)
        $ns = New-Object System.Net.Sockets.NetworkStream($sock, $false)
        $ns.ReadTimeout = $TimeoutMs; $ns.WriteTimeout = $TimeoutMs
        $cb = { param($s, $c, $ch, $e) return $true }
        $ssl = New-Object System.Net.Security.SslStream($ns, $false, $cb)
        $protocols = [System.Security.Authentication.SslProtocols]::Tls12
        try { $protocols = [System.Security.Authentication.SslProtocols]'Tls12, Tls13' } catch {}
        $ssl.AuthenticateAsClient($Ip, $null, $protocols, $false)
        return $true
    } catch {
        return $false
    } finally {
        if ($ssl) { try { $ssl.Dispose() } catch {} }
        elseif ($ns) { try { $ns.Dispose() } catch {} }
        if ($sock) { try { $sock.Close(); $sock.Dispose() } catch {} }
        if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
    }
}
'@

    Replace-FunctionAst ([ref]$raw) 'Invoke-NetworkAutoDiscovery' @'
function Invoke-NetworkAutoDiscovery {
    param([switch]$Force)
    if (-not $Force -and $script:State.Misc -and $script:State.Misc['DiscoveryTime']) {
        try {
            $lastDisc = [DateTime]::Parse([string]$script:State.Misc['DiscoveryTime'])
            if (((Get-Date) - $lastDisc).TotalSeconds -lt 20) { return }
        } catch {}
    }
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

        if (-not $script:State.Misc['DiscoveredPortalUrl'] -and -not $script:IsDry) {
            $candIps = @()
            if ($primaryGw) { $candIps += $primaryGw }
            $allowCfgIp = ($discSrcIp -notlike '192.168.*' -or (Test-IsNitjsrNetwork))
            if ($allowCfgIp -and $script:Cfg.PortalIp -and $candIps -notcontains [string]$script:Cfg.PortalIp) { $candIps += [string]$script:Cfg.PortalIp }

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

            if (-not $script:State.Misc['DiscoveredPortalUrl']) {
                $gwPorts = @(8888, 8003, 8090, 8443, 8080)
                foreach ($cIp in $candIps) {
                    if ($cIp -ne [string]$script:Cfg.PortalIp -and -not (Test-LearnableDhcpServer $cIp)) { continue }
                    foreach ($p in $gwPorts) {
                        if (Test-TcpPort $cIp $p 250 $discSrcIp) {
                            $script:State.Misc['DiscoveredPortalPort'] = $p
                            $script:State.Misc['DiscoveredPortalIp'] = $cIp
                            $isTls = if ($p -eq 443 -or $p -eq 8443) { $true } else { Test-PortSupportsTls $cIp $p 600 $discSrcIp }
                            $proto = if ($isTls) { 'https' } else { 'http' }
                            $portStr = if (($proto -eq 'http' -and $p -eq 80) -or ($proto -eq 'https' -and $p -eq 443)) { '' } else { ":$p" }
                            $script:State.Misc['DiscoveredPortalUrl'] = ($proto + '://' + $cIp + $portStr + '/')
                            $script:State.Misc['DiscoveredPortalHost'] = $cIp
                            Write-Log 'OK' ("Dynamically autodiscovered active {0} portal service on {1}:{2}" -f $proto.ToUpper(), $cIp, $p)
                            break
                        }
                    }
                    if ($script:State.Misc['DiscoveredPortalUrl']) { break }
                }
            }
        }

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
'@

    Replace-FunctionAst ([ref]$raw) 'Test-TcpPort' @'
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
        if ($c) { try { $c.Close(); $c.Dispose() } catch {} }
        if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
    }
}
'@

    Replace-FunctionAst ([ref]$raw) 'Resolve-HostBounded' @'
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
    $ar = $null
    $ok = $false
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
        if ($ok -and $ar -and $ar.AsyncWaitHandle) { try { $ar.AsyncWaitHandle.Close() } catch {} }
    }
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
'@

    Replace-FunctionAst ([ref]$raw) 'Invoke-HttpProbe' @'
function Invoke-HttpProbe([string]$HostName, [string]$Path, [int]$TimeoutMs = 2500, [string]$SourceIp = '', [int]$Port = 80) {
    $r = @{ Code = 0; Body = ''; Location = ''; Error = '' }
    $ip = Resolve-HostBounded $HostName 2200 $SourceIp
    if (-not $ip) { $r.Error = 'DnsFail'; return $r }
    $iar = $null
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
        $buf = New-Object byte[] 4096
        $total = 0
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        while ($total -lt $buf.Length -and $sw.ElapsedMilliseconds -lt $TimeoutMs) {
            $n = 0
            try { $n = $sock.Receive($buf, $total, ($buf.Length - $total), [System.Net.Sockets.SocketFlags]::None) } catch { break }
            if ($n -le 0) { break }
            $total += $n
            $txt = [System.Text.Encoding]::ASCII.GetString($buf, 0, $total)
            $he = $txt.IndexOf("`r`n`r`n"); $sepLen = 4
            if ($he -lt 0) { $he = $txt.IndexOf("`n`n"); $sepLen = 2 }
            if ($he -ge 0) {
                $bodyLen = $total - $he - $sepLen
                if (($txt -notmatch '^HTTP/\d\.\d\s+200') -or (($bodyLen -ge 20) -and (($txt -match 'Microsoft Connect Test|<title>Success</title>') -or ($bodyLen -ge 2048)))) { break }
            }
        }
        if ($total -eq 0) { $r.Error = 'NoResponse'; return $r }
        $p = ConvertFrom-HttpResponse ([System.Text.Encoding]::ASCII.GetString($buf, 0, $total))
        $r.Code = $p.Code; $r.Body = $p.Body; $r.Location = $p.Location
        if ($r.Code -eq 0) { $r.Error = 'BadResponse' }
    } catch { $r.Error = $_.Exception.Message }
    finally {
        if ($sock) { try { $sock.Close(); $sock.Dispose() } catch {} }
        if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
    }
    return $r
}
'@

    Replace-FunctionAst ([ref]$raw) 'Invoke-TlsHttp' @'
function Invoke-TlsHttp {
    param([uri]$Uri, [string]$Method = 'GET', [string]$Body = '', [string]$SourceIp = '', [string]$Pin = '', [hashtable]$Jar, [int]$TimeoutMs = 6000, [int]$MaxBytes = 262144, $Capture = $null, [switch]$HandshakeOnly)
    $r = @{ Code = 0; Headers = @{}; Body = ''; Location = ''; Error = ''; Sha256 = ''; TlsErrors = '' }
    $sock = $null; $ssl = $null; $ns = $null; $iar = $null; $ms = $null
    try {
        $hostName = [string]$Uri.Host
        $ip = ''
        $tmp = $null
        if ([System.Net.IPAddress]::TryParse($hostName, [ref]$tmp)) { $ip = $hostName } else { $ip = Resolve-HostBounded $hostName 2500 $SourceIp }
        if (-not $ip) { $r.Error = 'DnsFail'; return $r }
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
        try { $protocols = [System.Security.Authentication.SslProtocols]'Tls12, Tls13' } catch {}
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
            $curBuf = $ms.GetBuffer()
            $curLen = [int]$ms.Length
            if ($headerEndIdx -lt 0) {
                for ($ci = 0; $ci -lt ($curLen - 3); $ci++) {
                    if ($curBuf[$ci] -eq 13 -and $curBuf[$ci+1] -eq 10 -and $curBuf[$ci+2] -eq 13 -and $curBuf[$ci+3] -eq 10) {
                        $headerEndIdx = $ci + 4; break
                    }
                }
                if ($headerEndIdx -lt 0) {
                    for ($ci = 0; $ci -lt ($curLen - 1); $ci++) {
                        if ($curBuf[$ci] -eq 10 -and $curBuf[$ci+1] -eq 10) {
                            $headerEndIdx = $ci + 2; break
                        }
                    }
                }
                if ($headerEndIdx -gt 0) {
                    $hStr = [System.Text.Encoding]::ASCII.GetString($curBuf, 0, $headerEndIdx)
                    $mCl = [regex]::Match($hStr, '(?i)Content-Length:\s*(\d+)')
                    if ($mCl.Success) { $contentLength = [int]$mCl.Groups[1].Value }
                    elseif ($hStr -match '^HTTP/\d\.\d\s+(30[12378]|204)\b') { $contentLength = 0 }
                    if ($hStr -match '(?i)Transfer-Encoding:\s*chunked') { $isChunked = $true }
                }
            }
            if ($contentLength -ge 0 -and $headerEndIdx -ge 0) {
                if (($curLen - $headerEndIdx) -ge $contentLength) { break }
            } elseif ($isChunked -and $headerEndIdx -ge 0) {
                if ($curLen -ge 5 -and $curBuf[$curLen - 5] -eq 48 -and $curBuf[$curLen - 4] -eq 13 -and $curBuf[$curLen - 3] -eq 10 -and $curBuf[$curLen - 2] -eq 13 -and $curBuf[$curLen - 1] -eq 10 -and (($curLen -eq ($headerEndIdx + 5)) -or ($curLen -ge 7 -and $curBuf[$curLen - 7] -eq 13 -and $curBuf[$curLen - 6] -eq 10))) { break }
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
        elseif ($ns) { try { $ns.Dispose() } catch {} }
        if ($sock) { try { $sock.Close(); $sock.Dispose() } catch {} }
        if ($ms) { try { $ms.Dispose() } catch {} }
        if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
    }
    return $r
}
'@

    # 6. Set-UsbSuspendOff: reversible ledger metadata
    Replace-FunctionAst ([ref]$raw) 'Set-UsbSuspendOff' @'
function Set-UsbSuspendOff {
    $pcfg = Get-SysExe 'powercfg.exe'
    if (-not [System.IO.File]::Exists($pcfg)) { return }
    $scheme = Get-ActivePowerScheme
    if (-not $scheme) { return }
    $ac = Get-PowerSettingIndex $scheme 'ac'
    $dc = Get-PowerSettingIndex $scheme 'dc'
    if ($null -eq $ac -and $null -eq $dc) { return }
    $bat = Get-BatteryHealthAndEfficiency
    if ($bat.IsOnBattery) {
        if ($null -eq $ac -or $ac -eq 0) { return }
    } else {
        if (($null -eq $ac -or $ac -eq 0) -and ($null -eq $dc -or $dc -eq 0)) { return }
    }
    Save-Original 'Global' 'UsbSuspend' @{ Scheme = $scheme; Ac = $ac; Dc = $dc }
    $undoParts = @()
    if ($null -ne $ac) { $undoParts += "powercfg.exe /setacvalueindex $scheme $($script:UsbSub) $($script:UsbSet) $ac" }
    if (-not $bat.IsOnBattery -and $null -ne $dc) { $undoParts += "powercfg.exe /setdcvalueindex $scheme $($script:UsbSub) $($script:UsbSet) $dc" }
    $undoUsb = if ($undoParts.Count -gt 0) { ($undoParts -join '; ') + "; powercfg.exe /s $scheme" } else { '' }
    [void](Invoke-Change 'USB selective suspend configured for low-latency Ethernet on AC power (preserves battery efficiency)' {
        [void](Invoke-Native $pcfg @('/setacvalueindex', $scheme, $script:UsbSub, $script:UsbSet, '0') 5000)
        if (-not $bat.IsOnBattery) {
            [void](Invoke-Native $pcfg @('/setdcvalueindex', $scheme, $script:UsbSub, $script:UsbSet, '0') 5000)
        }
        [void](Invoke-Native $pcfg @('/s', $scheme) 5000)
    } -MutationType 'PowerCfg' -Target 'USB_SelectiveSuspend' -OldValue ("AC=$ac,DC=$dc") -NewValue ($(if ($bat.IsOnBattery) { "AC=0,DC=$dc" } else { 'AC=0,DC=0' })) -UndoScript $undoUsb -Reversible)
}
'@

    # 7. Portal auth check, zero-spin parallel TCP probe, centralized NativeARP, caches, conflict detection, static rescue with rollback, RX stall, WAN TLS probe
    Replace-FunctionAst ([ref]$raw) 'Test-IsPortalDemandingAuth' @'
function Test-IsPortalDemandingAuth([string]$PortalUrl = '', [string]$SourceIp = '') {
    if (-not $PortalUrl) { return $false }
    $u = $null
    try { $u = [uri]$PortalUrl } catch { return $false }
    if (-not $u.IsAbsoluteUri -or -not $u.Host) { return $false }
    $targetIp = ''
    $tmpIp = $null
    if ([System.Net.IPAddress]::TryParse($u.Host, [ref]$tmpIp)) { $targetIp = $u.Host }
    else { $targetIp = Resolve-HostBounded $u.Host 1000 $SourceIp }
    if (-not $targetIp) { return $false }
    $port = if ($u.Port -gt 0) { [int]$u.Port } elseif ($u.Scheme -eq 'https') { 443 } else { 80 }
    $sock = $null; $ssl = $null; $ns = $null; $iar = $null
    try {
        $sock = New-Object System.Net.Sockets.Socket([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
        if ($SourceIp) {
            try { $sock.Bind((New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($SourceIp), 0))) } catch {}
        }
        $iar = $sock.BeginConnect([System.Net.IPAddress]::Parse($targetIp), $port, $null, $null)
        if (-not $iar.AsyncWaitHandle.WaitOne(700, $false)) { return $false }
        $sock.EndConnect($iar)
        $ns = New-Object System.Net.Sockets.NetworkStream($sock, $false)
        $ns.ReadTimeout = 1000; $ns.WriteTimeout = 1000
        $stream = $ns
        if ($u.Scheme -eq 'https') {
            $cb = { param($s, $c, $ch, $e) return $true }
            $ssl = New-Object System.Net.Security.SslStream($ns, $false, $cb)
            $protocols = [System.Security.Authentication.SslProtocols]::Tls12
            try { $protocols = [System.Security.Authentication.SslProtocols]'Tls12, Tls13' } catch {}
            $ssl.AuthenticateAsClient($u.Host, $null, $protocols, $false)
            $stream = $ssl
        }
        $req = "GET $($u.PathAndQuery) HTTP/1.0`r`nHost: $($u.Host)`r`nConnection: close`r`n`r`n"
        $hb = [System.Text.Encoding]::ASCII.GetBytes($req)
        $stream.Write($hb, 0, $hb.Length)
        $stream.Flush()
        $buf = New-Object byte[] 16384
        $tot = 0
        while ($tot -lt $buf.Length) {
            $n = 0
            try { $n = $stream.Read($buf, $tot, ($buf.Length - $tot)) } catch { break }
            if ($n -le 0) { break }
            $tot += $n
        }
        if ($tot -gt 0) {
            $html = [System.Text.Encoding]::UTF8.GetString($buf, 0, $tot)
            if ($html -match 'type=["'']password["'']' -or $html -match 'name=["'']auth_pass["'']' -or $html -match 'name=["'']password["'']' -or $html -match 'action=.*portal') {
                return $true
            }
        }
    } catch {
        return $false
    } finally {
        if ($ssl) { try { $ssl.Dispose() } catch {} }
        elseif ($ns) { try { $ns.Dispose() } catch {} }
        if ($sock) { try { $sock.Close(); $sock.Dispose() } catch {} }
        if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
    }
    return $false
}
'@

    Replace-FunctionAst ([ref]$raw) 'Test-AnyTcpPortParallel' @'
function Test-AnyTcpPortParallel([string]$Address, [int[]]$Ports, [int]$TimeoutMs = 400, [string]$SourceIp = '') {
    if (-not $Address -or -not $Ports -or $Ports.Count -eq 0) { return $false }
    $dst = $null
    if (-not [System.Net.IPAddress]::TryParse($Address, [ref]$dst)) { return $false }
    $socks = New-Object System.Collections.ArrayList
    $waitHandles = New-Object System.Collections.ArrayList
    $iars = New-Object System.Collections.ArrayList
    $active = New-Object System.Collections.ArrayList
    try {
        $srcIpObj = $null
        if ($SourceIp) { [void][System.Net.IPAddress]::TryParse($SourceIp, [ref]$srcIpObj) }
        foreach ($p in @($Ports | Select-Object -Unique)) {
            $s = $null
            try {
                $s = New-Object System.Net.Sockets.Socket($dst.AddressFamily, [System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
                if ($srcIpObj) { $s.Bind((New-Object System.Net.IPEndPoint($srcIpObj, 0))) }
                $iar = $s.BeginConnect($dst, [int]$p, $null, $null)
                [void]$socks.Add($s); [void]$iars.Add($iar); [void]$waitHandles.Add($iar.AsyncWaitHandle); [void]$active.Add($true)
            } catch {
                if ($s) { try { $s.Close(); $s.Dispose() } catch {} }
            }
        }
        if ($waitHandles.Count -eq 0) { return $false }
        $swP = [System.Diagnostics.Stopwatch]::StartNew()
        while ($swP.ElapsedMilliseconds -lt $TimeoutMs) {
            $pendingHandles = New-Object System.Collections.ArrayList
            for ($i = 0; $i -lt $socks.Count; $i++) {
                if (-not $active[$i]) { continue }
                if ($iars[$i].IsCompleted) {
                    $active[$i] = $false
                    try { $socks[$i].EndConnect($iars[$i]); if ($socks[$i].Connected) { return $true } } catch {}
                } else {
                    [void]$pendingHandles.Add($waitHandles[$i])
                }
            }
            if ($pendingHandles.Count -eq 0) { return $false }
            $rem = [int][math]::Max(1, $TimeoutMs - $swP.ElapsedMilliseconds)
            [void][System.Threading.WaitHandle]::WaitAny([System.Threading.WaitHandle[]]$pendingHandles.ToArray([System.Threading.WaitHandle]), [math]::Min(40, $rem))
        }
        return $false
    } finally {
        for ($i = 0; $i -lt $socks.Count; $i++) { try { $socks[$i].Close(); $socks[$i].Dispose() } catch {} }
        for ($i = 0; $i -lt $waitHandles.Count; $i++) { try { $waitHandles[$i].Close() } catch {} }
    }
}
'@

    Ensure-HelperFunctionAst ([ref]$raw) 'Initialize-NativeArp' 'Test-ActiveArp' @'
function Initialize-NativeArp {
    if ('LfNativeArp' -as [type]) { return $true }
    try {
        Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public static class LfNativeArp { [DllImport("iphlpapi.dll", ExactSpelling=true)] public static extern int SendARP(int DestIP, int SrcIP, byte[] pMacAddr, ref int PhyAddrLen); }' -ErrorAction Stop
        return $true
    } catch { return $false }
}
'@

    Replace-FunctionAst ([ref]$raw) 'Test-ActiveArp' @'
function Test-ActiveArp([string]$TargetIp, [string]$ExpectedMac = '', [string]$SourceIp = '') {
    $tIp = $null; $sIp = $null
    if (-not [System.Net.IPAddress]::TryParse($TargetIp, [ref]$tIp) -or $tIp.AddressFamily -ne [System.Net.Sockets.AddressFamily]::InterNetwork) { return $false }
    if ($SourceIp) { [void][System.Net.IPAddress]::TryParse($SourceIp, [ref]$sIp) }
    try {
        if (-not (Initialize-NativeArp)) { return $false }
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
'@

    Replace-FunctionAst ([ref]$raw) 'Flush-InMemoryNetCaches' @'
function Flush-InMemoryNetCaches {
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
    $script:Ip4Cache = @{}
    $script:Gw4Cache = @{}
    $script:HttpsWanOkCache = @{}
}
'@

    Replace-FunctionAst ([ref]$raw) 'Get-IpConflictInfo' @'
function Get-IpConflictInfo($Ad, [string]$Ip) {
    $out = @{ Conflict = $false; PeerMac = ''; Source = ''; RecentEvents = @() }
    if (-not $Ip -or $Ip -match '^(127\.|169\.254\.|0\.0\.0\.0$)') { return $out }
    $addr = $null
    if (-not [System.Net.IPAddress]::TryParse($Ip, [ref]$addr) -or $addr.AddressFamily -ne [System.Net.Sockets.AddressFamily]::InterNetwork) { return $out }
    $selfMac = if ($Ad -and $Ad.MacAddress) { ([string]$Ad.MacAddress).Replace(':', '-').ToUpperInvariant() } else { '' }
    if ($Ad -and $Ad.ifIndex) {
        try {
            $dupObj = Get-NetIPAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -IPAddress $Ip -ErrorAction SilentlyContinue |
                Where-Object { [string]$_.AddressState -eq 'Duplicate' } | Select-Object -First 1
            if ($dupObj) {
                $out.Conflict = $true
                $out.Source = 'DuplicateAddressState'
            }
        } catch {}
    }
    if (-not $out.Conflict -and $Ad -and $Ad.ifIndex) {
        try {
            $nb = Get-NetNeighbor -InterfaceIndex $Ad.ifIndex -IPAddress $Ip -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($nb -and $nb.LinkLayerAddress) {
                $nbMac = ([string]$nb.LinkLayerAddress).Replace(':', '-').ToUpperInvariant()
                if ($nbMac -ne '00-00-00-00-00-00' -and $nbMac -ne 'FF-FF-FF-FF-FF-FF' -and $selfMac -and $nbMac -ne $selfMac) {
                    $out.Conflict = $true
                    $out.PeerMac = $nbMac
                    $out.Source = 'NeighborMacMismatch'
                }
            }
        } catch {}
    }
    if (-not $out.Conflict) {
        try {
            if (Initialize-NativeArp) {
                $dstInt = [BitConverter]::ToInt32($addr.GetAddressBytes(), 0)
                $macBuf = New-Object byte[] 6
                [int]$len = 6
                $rc = [LfNativeArp]::SendARP($dstInt, 0, $macBuf, [ref]$len)
                if ($rc -eq 0 -and $len -eq 6) {
                    $liveMac = (($macBuf | ForEach-Object { $_.ToString('X2') }) -join '-')
                    if ($liveMac -ne '00-00-00-00-00-00' -and $liveMac -ne 'FF-FF-FF-FF-FF-FF' -and (-not $selfMac -or $liveMac -ne $selfMac)) {
                        $out.Conflict = $true
                        $out.PeerMac = $liveMac
                        $out.Source = 'LiveSendARP'
                    }
                }
            }
        } catch {}
    }
    if (-not $out.Conflict) {
        try {
            $ev4199 = @(Get-WinEvent -FilterHashtable @{ LogName = 'System'; ProviderName = 'Tcpip'; Id = 4199; StartTime = (Get-Date).AddMinutes(-15) } -MaxEvents 8 -ErrorAction SilentlyContinue)
            foreach ($ev in $ev4199) {
                $msg = [string]$ev.Message
                if ($msg -match ([regex]::Escape($Ip) + '\b')) {
                    $out.Conflict = $true
                    $out.Source = 'Event4199'
                    if (-not $out.PeerMac -and $msg -match '([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}') {
                        $out.PeerMac = $Matches[0].Replace(':', '-').ToUpperInvariant()
                    }
                    $out.RecentEvents += $Ip
                    break
                }
            }
        } catch {}
    }
    return $out
}
'@

    Replace-FunctionAst ([ref]$raw) 'Invoke-CampusStaticRescue' @'
function Invoke-CampusStaticRescue($Ad, [string]$ConflictedIp = '') {
    if (-not $Ad -or -not $Ad.ifIndex) { return $false }
    $hint = Get-CampusSubnetHint $Ad $ConflictedIp
    if (-not $hint.BaseIp -or -not $hint.Gateway) { return $false }
    $curValidIp = Get-ValidIPv4 $Ad -NoCache
    if ($curValidIp) {
        if (-not (Test-ActiveArp $hint.Gateway '' $curValidIp)) {
            $rtGw = $null; try { $rtGw = Test-Ping $hint.Gateway 350 } catch {}
            if ($null -eq $rtGw) { return $false }
        }
    }
    $freeIp = Find-FreeSubnetIp -BaseIp $hint.BaseIp -PrefixLength $hint.PrefixLength -Gateway $hint.Gateway -ExcludeIps @($ConflictedIp)
    if (-not $freeIp) { return $false }

    $guid = [string]$Ad.InterfaceGuid
    $pfx = [int]$hint.PrefixLength
    $gwS = [string]$hint.Gateway
    $dnsList = @($hint.Dns | Where-Object { $_ } | Select-Object -Unique)
    if ($dnsList.Count -eq 0) { $dnsList = @('1.1.1.1', '9.9.9.9') }

    $undoStatic = "Remove-NetIPAddress -InterfaceIndex $($Ad.ifIndex) -AddressFamily IPv4 -Confirm:`$false -ErrorAction SilentlyContinue; Set-NetIPInterface -InterfaceIndex $($Ad.ifIndex) -AddressFamily IPv4 -Dhcp Enabled -ErrorAction SilentlyContinue; Set-DnsClientServerAddress -InterfaceIndex $($Ad.ifIndex) -ResetServerAddresses -ErrorAction SilentlyContinue"
    $ok = Invoke-Change ("Campus conflict/DHCP static rescue on $($Ad.Name): $freeIp/$pfx GW $gwS") {
        Remove-NetIPAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
        Remove-NetRoute -InterfaceIndex $Ad.ifIndex -DestinationPrefix '0.0.0.0/0' -Confirm:$false -ErrorAction SilentlyContinue
        Set-NetIPInterface -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -Dhcp Disabled -ErrorAction Stop
        New-NetIPAddress -InterfaceIndex $Ad.ifIndex -IPAddress $freeIp -PrefixLength $pfx -DefaultGateway $gwS -AddressFamily IPv4 -ErrorAction Stop | Out-Null
        Set-DnsClientServerAddress -InterfaceIndex $Ad.ifIndex -ServerAddresses $dnsList -ErrorAction SilentlyContinue
    } -MutationType 'StaticIpRescue' -Target $Ad.Name -OldValue $ConflictedIp -NewValue "$freeIp/$pfx" -UndoScript $undoStatic -Reversible

    if ($ok -and -not $script:IsDry) {
        Start-Sleep -Milliseconds 600
        Flush-InMemoryNetCaches
        $ga = Test-GatewayAlive $Ad $gwS
        if ($ga.Alive) {
            if ($guid) { Save-Original $guid 'StaticRescueIp' "$freeIp/$pfx" }
            Write-Log 'OK' ("Campus static rescue verified on {0}: {1}/{2} -> gateway {3} alive ({4})." -f $Ad.Name, $freeIp, $pfx, $gwS, $ga.Via)
            return $true
        }
        Write-Log 'WARN' ("Static rescue {0}/{1} could not reach gateway {2} (possible switch DAI/IP Source Guard); rolling back to DHCP." -f $freeIp, $pfx, $gwS)
        try {
            Remove-NetIPAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
            Remove-NetRoute -InterfaceIndex $Ad.ifIndex -DestinationPrefix '0.0.0.0/0' -Confirm:$false -ErrorAction SilentlyContinue
            Set-NetIPInterface -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -Dhcp Enabled -ErrorAction SilentlyContinue
            Set-DnsClientServerAddress -InterfaceIndex $Ad.ifIndex -ResetServerAddresses -ErrorAction SilentlyContinue
        } catch {}
        Flush-InMemoryNetCaches
        return $false
    }
    return [bool]$ok
}
'@

    Replace-FunctionAst ([ref]$raw) 'Test-AdapterRxStall' @'
function Test-AdapterRxStall($Ad, [string]$Gateway = '') {
    if (-not $Ad -or $Ad.Status -ne 'Up' -or $script:IsDry) { return $false }
    try {
        if ($Gateway -and (Test-GatewayAlive $Ad $Gateway).Alive) { return $false }
        $s1 = Get-NetAdapterStatistics -Name $Ad.Name -ErrorAction Stop
        if (-not $s1) { return $false }
        $rx1 = [int64]$s1.ReceivedUnicastPackets + [int64]$s1.ReceivedNonUnicastPackets
        $tx1 = [int64]$s1.SentUnicastPackets
        $srcIp = [string](Get-ValidIPv4 $Ad -NoCache)
        $tgt = if ($Gateway) { $Gateway } else { [string]$script:Cfg.PortalIp }
        if ($tgt) {
            [void](Test-AnyTcpPortParallel $tgt @(80, 443, 53, 8888, 8003) 450 $srcIp)
            [void](Test-Ping $tgt 250)
        }
        $s2 = Get-NetAdapterStatistics -Name $Ad.Name -ErrorAction Stop
        $rx2 = [int64]$s2.ReceivedUnicastPackets + [int64]$s2.ReceivedNonUnicastPackets
        $tx2 = [int64]$s2.SentUnicastPackets
        $dTx = $tx2 - $tx1
        $dRx = $rx2 - $rx1
        if ($dTx -ge 4 -and $dRx -le 0) {
            Write-Log 'WARN' ("Silent RX hardware stall confirmed on {0} (TX delta=+{1}, RX delta={2}, gateway unreachable)." -f $Ad.Name, $dTx, $dRx)
            return $true
        }
    } catch {}
    return $false
}
'@

    Replace-FunctionAst ([ref]$raw) 'Test-HttpsWanProbe' @'
function Test-HttpsWanProbe([string]$SourceIp = '', [int]$TimeoutMs = 1200) {
    $res = @{ Ok = $false; IsCaptive = $false; Error = ''; CertSubject = '' }
    if ($script:HttpsWanOkCache -isnot [hashtable]) { $script:HttpsWanOkCache = @{} }
    $cacheKey = if ($SourceIp) { $SourceIp } else { 'ANY' }
    $nowT = [System.Diagnostics.Stopwatch]::GetTimestamp()
    if ($script:HttpsWanOkCache.ContainsKey($cacheKey)) {
        if ((($nowT - $script:HttpsWanOkCache[$cacheKey]) / [System.Diagnostics.Stopwatch]::Frequency) -lt 15.0) {
            $res.Ok = $true
            return $res
        }
    }
    $budgetSw = [System.Diagnostics.Stopwatch]::StartNew()
    $targets = @(
        @{ Ip = '1.1.1.1'; Sni = '1.1.1.1' },
        @{ Ip = ''; Sni = 'connectivitycheck.gstatic.com' },
        @{ Ip = '9.9.9.9'; Sni = '9.9.9.9' }
    )
    foreach ($tg in $targets) {
        $remBudget = [int](2400 - $budgetSw.ElapsedMilliseconds)
        if ($remBudget -lt 300) { break }
        $stepTo = [math]::Min($TimeoutMs, $remBudget)
        $dstIp = [string]$tg.Ip
        if (-not $dstIp) { $dstIp = Resolve-HostBounded ([string]$tg.Sni) ([math]::Min(900, $stepTo)) $SourceIp }
        if (-not $dstIp) { continue }
        $sock = $null; $ssl = $null; $ns = $null; $iar = $null
        $cap = @{ Errors = ''; Subject = '' }
        try {
            $sock = New-Object System.Net.Sockets.Socket([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
            if ($SourceIp) {
                try { $sock.Bind((New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($SourceIp), 0))) } catch { $res.Error = 'BindFailure'; return $res }
            }
            $iar = $sock.BeginConnect([System.Net.IPAddress]::Parse($dstIp), 443, $null, $null)
            if (-not $iar.AsyncWaitHandle.WaitOne($stepTo, $false)) { $res.Error = 'Timeout'; continue }
            $sock.EndConnect($iar)
            $ns = New-Object System.Net.Sockets.NetworkStream($sock, $false)
            $ns.ReadTimeout = $stepTo; $ns.WriteTimeout = $stepTo
            $cb = {
                param($sender, $cert, $chain, $errs)
                $cap.Errors = [string]$errs
                if ($cert) { $cap.Subject = [string]$cert.Subject }
                return ([string]$errs -eq 'None')
            }.GetNewClosure()
            $ssl = New-Object System.Net.Security.SslStream($ns, $false, ([System.Net.Security.RemoteCertificateValidationCallback]$cb))
            $protocols = [System.Security.Authentication.SslProtocols]::Tls12
            try { $protocols = [System.Security.Authentication.SslProtocols]'Tls12, Tls13' } catch {}
            $ssl.AuthenticateAsClient([string]$tg.Sni, $null, $protocols, $false)
            $res.Ok = $true
            $res.Error = ''
            $script:HttpsWanOkCache[$cacheKey] = [System.Diagnostics.Stopwatch]::GetTimestamp()
            return $res
        } catch {
            $res.Error = $_.Exception.Message
            if ($cap.Errors -and $cap.Errors -ne 'None') {
                $res.IsCaptive = $true
                $res.CertSubject = [string]$cap.Subject
                return $res
            }
        } finally {
            if ($ssl) { try { $ssl.Dispose() } catch {} }
            elseif ($ns) { try { $ns.Dispose() } catch {} }
            if ($sock) { try { $sock.Close(); $sock.Dispose() } catch {} }
            if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
        }
    }
    $actUrl = Get-ActivePortalUrl
    $checkPortal = ($actUrl -and (($SourceIp -notlike '192.168.*') -or (Test-IsNitjsrNetwork) -or [bool]$script:State.Misc['DiscoveredPortalUrl']))
    if ($checkPortal -and (Test-IsPortalDemandingAuth $actUrl $SourceIp)) {
        $res.IsCaptive = $true
        $res.Error = 'PortalDemandsAuth'
    }
    return $res
}
'@

    # 8. Get-GatewaysV4, Get-ValidIPv4 (-NoCache), Get-AdapterEnvironment (Other cleanup), Get-AdapterHealth (Duplicate filter + LastCampusLease persistence), Reset-PhysicalAdapterHardware (full cache flush)
    Replace-FunctionAst ([ref]$raw) 'Get-GatewaysV4' @'
function Get-GatewaysV4($Ad = $null, [switch]$NoCache) {
    if ($script:Gw4Cache -isnot [hashtable]) { $script:Gw4Cache = @{} }
    $nowT = [System.Diagnostics.Stopwatch]::GetTimestamp()
    $freq = [System.Diagnostics.Stopwatch]::Frequency
    if (-not $PSBoundParameters.ContainsKey('Ad')) {
        if (-not $NoCache -and $script:Gw4Cache.ContainsKey('ALL') -and (($nowT - $script:Gw4Cache['ALL'].Ticks) / $freq) -lt 1.5) {
            return $script:Gw4Cache['ALL'].Val
        }
        $allGws = @()
        foreach ($a in (@(Get-EthernetAdapters) + @(Get-OtherUplinkAdapters) | Where-Object { $_ -and $_.Status -eq 'Up' })) {
            $allGws += @(Get-GatewaysV4 $a -NoCache:$NoCache)
        }
        $u = @($allGws | Where-Object { $_ } | Select-Object -Unique)
        $script:Gw4Cache['ALL'] = @{ Ticks = $nowT; Val = $u }
        return $u
    }
    if (-not $Ad -or -not $Ad.ifIndex) { return @() }
    $k = [string]$Ad.ifIndex
    if (-not $NoCache -and $script:Gw4Cache.ContainsKey($k) -and (($nowT - $script:Gw4Cache[$k].Ticks) / $freq) -lt 1.5) {
        return $script:Gw4Cache[$k].Val
    }
    $res = @(Get-NetRoute -InterfaceIndex $Ad.ifIndex -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue |
        Where-Object { $_.NextHop -and $_.NextHop -ne '0.0.0.0' } | ForEach-Object { [string]$_.NextHop } | Select-Object -Unique)
    $script:Gw4Cache[$k] = @{ Ticks = $nowT; Val = $res }
    return $res
}
'@

    Replace-FunctionAst ([ref]$raw) 'Get-ValidIPv4' @'
function Get-ValidIPv4($Ad, [switch]$NoCache) {
    if (-not $Ad -or -not $Ad.ifIndex) { return $null }
    if ($script:Ip4Cache -isnot [hashtable]) { $script:Ip4Cache = @{} }
    $nowT = [System.Diagnostics.Stopwatch]::GetTimestamp()
    $k = [string]$Ad.ifIndex
    if (-not $NoCache -and $script:Ip4Cache.ContainsKey($k) -and (($nowT - $script:Ip4Cache[$k].Ticks) / [System.Diagnostics.Stopwatch]::Frequency) -lt 1.5) {
        return $script:Ip4Cache[$k].Val
    }
    $x = Get-NetIPAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue |
         Where-Object { $_.IPAddress -notlike '169.254.*' -and $_.AddressState -eq 'Preferred' } | Select-Object -First 1
    $val = if ($x) { [string]$x.IPAddress } else { $null }
    $script:Ip4Cache[$k] = @{ Ticks = $nowT; Val = $val }
    return $val
}
'@

    Replace-FunctionAst ([ref]$raw) 'Get-AdapterEnvironment' @'
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
        $discP = if ($script:State.Misc -and $script:State.Misc['DiscoveredPortalIp']) { [string]$script:State.Misc['DiscoveredPortalIp'] } else { '' }
        $targetPortalIp = if ($discP) { $discP } else { [string]$cfg.PortalIp }
        if ($targetPortalIp -and ($ip -notlike '192.168.*' -or $discP -or ($cfg.PortalIp -like '192.168.*'))) {
            $detectedPort = Find-ActivePortalPort $targetPortalIp ([int]$cfg.PortalPort)
            if (Test-TcpPort $targetPortalIp $detectedPort 700) { $score += 2; if ($targetPortalIp -eq $cfg.PortalIp) { $portalHit = $true }; [void]$ev.Add(("portal {0}:{1} open" -f $targetPortalIp, $detectedPort)) }
            if ($null -ne (Test-Ping $targetPortalIp 700)) { $score += 1; if ($targetPortalIp -eq $cfg.PortalIp) { $portalHit = $true }; [void]$ev.Add("portal firewall answers ping") }
            if ($cfg.CampusDns -and $null -ne (Test-Ping $cfg.CampusDns 700)) { $score += 1; [void]$ev.Add("campus DNS answers ping") }
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
        $script:State.Misc['LearnedDhcp'] = $dhcpSrv
    }
    if (-not $sticky -and ($envName -eq 'Campus' -or $envName -eq 'Other')) {
        $h = Get-SubTable 'Env' $guid
        $h.Env = $envName
        $h.Home = $homeVerdict
        $h.Time = (Get-Date).ToString('o')
        if (-not $script:IsDry -and $envName -eq 'Other') {
            foreach ($dk in @('DiscoveredPortalIp','DiscoveredPortalUrl','DiscoveredPortalPort','DiscoveredPortalHost','DiscoveredDomain','DiscoveredDns')) {
                $script:State.Misc.Remove($dk)
            }
            $script:State.Misc['DiscoveryTime'] = (Get-Date).ToString('o')
        }
    }
    $info = @{ Env = $envName; Score = $score; Evidence = @($ev); Sticky = $sticky; Ip = $ip; Gateways = $gws; Home = $homeVerdict }
    $script:EnvCache[$guid] = @{ Time = (Get-Date); Info = $info }
    return $info
}
'@

    Replace-FunctionAst ([ref]$raw) 'Get-AdapterHealth' @'
function Get-AdapterHealth($Ad, [switch]$UseCache) {
    if (-not $Ad -or -not $Ad.Name) { return @{ Name = ''; Up = $false; Ip = $null; Apipa = $false; Gateway = $null; GwRtt = $null; GwAlive = $false; GwVia = ''; Conn = 'Offline'; Problem = 'NoAdapter' } }
    $h = @{ Name = $Ad.Name; Up = ($Ad.Status -eq 'Up'); Ip = $null; Apipa = $false; Gateway = $null; GwRtt = $null; GwAlive = $false; GwVia = ''; Conn = 'Offline'; Problem = 'NoLink' }
    if (-not $h.Up) { return $h }
    $all = @(Get-NetIPAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue)
    $h.Apipa = [bool]($all | Where-Object { $_.IPAddress -like '169.254.*' })
    $validObjs = @($all | Where-Object { $_.IPAddress -notmatch '^(169\.254\.|127\.)' -and $_.AddressState -notin @('Duplicate','Invalid') } | Sort-Object { if ($_.AddressState -eq 'Preferred') { 0 } else { 1 } })
    $h.Ip = if ($validObjs.Count -gt 0) { [string]$validObjs[0].IPAddress } else { $null }
    if (-not $h.Ip) { $h.Problem = 'NoIp'; return $h }
    $gw = @(Get-GatewaysV4 $Ad) | Select-Object -First 1
    $h.Gateway = $gw
    if ($gw) { $ga = Test-GatewayAlive $Ad $gw -UseCache:$UseCache; $h.GwRtt = $ga.Rtt; $h.GwAlive = $ga.Alive; $h.GwVia = $ga.Via }
    $h.Conn = if ($UseCache) { (Get-InternetState -SourceIp $h.Ip).State } else { (Get-InternetState -NoCache -SourceIp $h.Ip).State }
    switch ($h.Conn) {
        'Online'  { $h.Problem = 'Healthy' }
        'Captive' { $h.Problem = 'Captive' }
        'NoDns'   { $h.Problem = 'NoDns' }
        default   { if (-not $h.GwAlive) { $h.Problem = 'GwUnreachable' } else { $h.Problem = 'Offline' } }
    }
    if (-not $script:IsDry -and $h.Ip -and $h.Gateway -and ($h.GwAlive -or $h.Conn -in @('Online','Captive')) -and $script:State -is [hashtable] -and $script:State.Misc -is [hashtable]) {
        try {
            $envChk = Get-AdapterEnvironment $Ad -UseCache
            if ($envChk -and $envChk.Env -eq 'Campus') {
                $ipMeta = $validObjs[0]
                $pfxSave = if ($ipMeta -and $ipMeta.PrefixLength) { [int]$ipMeta.PrefixLength } else { 22 }
                $dnsSave = @(Get-DhcpDnsServers ([string]$Ad.InterfaceGuid))
                $script:State.Misc['LastCampusLease'] = @{
                    Ip           = [string]$h.Ip
                    PrefixLength = $pfxSave
                    Gateway      = [string]$h.Gateway
                    Dns          = $dnsSave
                    Time         = (Get-Date).ToString('o')
                }
            }
        } catch {}
    }
    return $h
}
'@

    Replace-FunctionAst ([ref]$raw) 'Reset-PhysicalAdapterHardware' @'
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
    Flush-InMemoryNetCaches
    return $restarted
}
'@

    # 9. Add Sovereign Layer-2/4 Helpers (Win11 Global+Per-NIC Broadcast Flag, 24H2 APIPA Ghost Exorcist, STP RX Gate, NCSI+DoH Fallback)
    $anchorL2 = if ($raw -match 'function Shield-DataLink\b') { 'Shield-DataLink' } else { 'Shield-Dot3Svc' }

    Ensure-HelperFunctionAst ([ref]$raw) 'Wait-SwitchPortForwarding' $anchorL2 @'
function Wait-SwitchPortForwarding($Ad, [int]$MaxWaitSec = 12) {
    if (-not $Ad -or $Ad.Status -ne 'Up' -or $script:IsDry) { return $true }
    try {
        $s0 = Get-NetAdapterStatistics -Name $Ad.Name -ErrorAction SilentlyContinue
        if (-not $s0) { return $true }
        $rx0 = [int64]$s0.ReceivedUnicastPackets + [int64]$s0.ReceivedNonUnicastPackets
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        while ($sw.Elapsed.TotalSeconds -lt $MaxWaitSec) {
            Start-Sleep -Milliseconds 350
            $sNow = Get-NetAdapterStatistics -Name $Ad.Name -ErrorAction SilentlyContinue
            if ($sNow) {
                $rxNow = [int64]$sNow.ReceivedUnicastPackets + [int64]$sNow.ReceivedNonUnicastPackets
                if (($rxNow - $rx0) -ge 1) {
                    Write-Log 'INFO' ("Switch port forwarding active on {0} (+{1} RX frames in {2:N1}s)." -f $Ad.Name, ($rxNow - $rx0), $sw.Elapsed.TotalSeconds)
                    return $true
                }
            }
        }
        Write-Log 'INFO' ("Switch port RX frame wait reached {0}s on {1} (STP delay or quiet VLAN); proceeding with broadcast DHCP." -f $MaxWaitSec, $Ad.Name)
    } catch {}
    return $false
}
'@

    Ensure-HelperFunctionAst ([ref]$raw) 'Exorcise-ApipaGhost' $anchorL2 @'
function Exorcise-ApipaGhost($Ad) {
    if (-not $script:IsAdmin -or $script:IsDry -or $script:IsPlan -or -not $Ad -or -not $Ad.ifIndex) { return $false }
    try {
        $allV4 = @(Get-NetIPAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue)
        $apipaList = @($allV4 | Where-Object { $_.IPAddress -like '169.254.*' })
        if ($apipaList.Count -eq 0) { return $false }
        $hasValid = @($allV4 | Where-Object { $_.IPAddress -notmatch '^(169\.254\.|127\.)' -and $_.AddressState -eq 'Preferred' }).Count -gt 0
        $ifObj = Get-NetIPInterface -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($hasValid -or ($ifObj -and [string]$ifObj.Dhcp -eq 'Enabled')) {
            foreach ($ap in $apipaList) {
                Remove-NetIPAddress -InterfaceIndex $Ad.ifIndex -IPAddress $ap.IPAddress -Confirm:$false -ErrorAction SilentlyContinue
            }
            Write-Log 'OK' ("Purged sticky Windows 11 APIPA ghost address ({0}) on {1}." -f (($apipaList.IPAddress) -join ', '), $Ad.Name)
            Flush-InMemoryNetCaches
            return $true
        }
    } catch {}
    return $false
}
'@

    Ensure-HelperFunctionAst ([ref]$raw) 'Ensure-NcsiAndDohHealthy' $anchorL2 @'
function Ensure-NcsiAndDohHealthy {
    if (-not $script:IsAdmin -or $script:IsDry -or $script:IsPlan) { return }
    try {
        $ncsiKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet'
        if (Test-Path -LiteralPath $ncsiKey) {
            $curProbe = (Get-ItemProperty -LiteralPath $ncsiKey -Name 'EnableActiveProbing' -ErrorAction SilentlyContinue).EnableActiveProbing
            if ($null -ne $curProbe -and [int]$curProbe -eq 0) {
                Save-Original 'Global' 'NcsiActiveProbing' 0
                [void](Invoke-Change 'Restored Windows NCSI EnableActiveProbing=1 to clear false offline indicators' {
                    Set-ItemProperty -LiteralPath $ncsiKey -Name 'EnableActiveProbing' -Value 1 -Type DWord -Force -ErrorAction Stop
                } -MutationType 'Registry' -Target $ncsiKey -ValueName 'EnableActiveProbing' -OldValue 0 -NewValue 1 -Reversible)
            }
        }
        if (Get-Command Get-DnsClientDohServerAddress -ErrorAction SilentlyContinue) {
            $dohList = @(Get-DnsClientDohServerAddress -ErrorAction SilentlyContinue | Where-Object { $_.ServerAddress -in @('1.1.1.1','1.0.0.1','8.8.8.8','8.8.4.4','9.9.9.9') -and -not $_.AllowFallbackToUdp })
            foreach ($d in $dohList) {
                Set-DnsClientDohServerAddress -ServerAddress $d.ServerAddress -AllowFallbackToUdp $true -ErrorAction SilentlyContinue
            }
        }
    } catch {}
}
'@

    Ensure-HelperFunctionAst ([ref]$raw) 'Ensure-DhcpSovereignReady' $anchorL2 @'
function Ensure-DhcpSovereignReady($Ad) {
    if (-not $script:IsAdmin -or $script:IsDry -or $script:IsPlan -or -not $Ad) { return }
    try {
        # 1. Windows 11 Global Broadcast Flag (fixes ISC/campus relays dropping unicast DHCP-OFFER on Ethernet & Wi-Fi)
        $globKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Dhcp\Parameters\DhcpGlobalForceBroadcastFlag\0'
        $needGlob = $false
        if (-not (Test-Path -LiteralPath $globKey)) { $needGlob = $true }
        else {
            $p9  = (Get-ItemProperty -LiteralPath $globKey -Name '9' -ErrorAction SilentlyContinue).'9'
            $p14 = (Get-ItemProperty -LiteralPath $globKey -Name '14' -ErrorAction SilentlyContinue).'14'
            if ([int]$p9 -ne 1 -or [int]$p14 -ne 1) { $needGlob = $true }
        }
        if ($needGlob) {
            Save-Original 'Global' 'DhcpGlobalBroadcast' (Test-Path -LiteralPath $globKey)
            $undoGlob = "Remove-Item -LiteralPath '$globKey' -Force -ErrorAction SilentlyContinue"
            [void](Invoke-Change 'Enabled Windows 11 global DHCP broadcast flag (Ethernet/Wi-Fi RFC 2131 compatibility)' {
                if (-not (Test-Path -LiteralPath $globKey)) { [void](New-Item -Path $globKey -Force -ErrorAction Stop) }
                Set-ItemProperty -LiteralPath $globKey -Name '9' -Value 1 -Type DWord -Force -ErrorAction Stop
                Set-ItemProperty -LiteralPath $globKey -Name '14' -Value 1 -Type DWord -Force -ErrorAction Stop
            } -MutationType 'Registry' -Target $globKey -ValueName '9' -OldValue 0 -NewValue 1 -UndoScript $undoGlob -Reversible)
        }
        # 2. Per-Interface Broadcast Flag
        $guid = [string]$Ad.InterfaceGuid
        if ($guid) {
            $ifPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"
            if (Test-Path -LiteralPath $ifPath) {
                $curBf = (Get-ItemProperty -LiteralPath $ifPath -Name 'DhcpConnForceBroadcastFlag' -ErrorAction SilentlyContinue).DhcpConnForceBroadcastFlag
                if ($null -eq $curBf -or [int]$curBf -ne 1) {
                    Save-Original $guid 'DhcpBroadcastFlag' $curBf
                    [void](Invoke-Change ("Enforced DhcpConnForceBroadcastFlag=1 on {0}" -f $Ad.Name) {
                        Set-ItemProperty -LiteralPath $ifPath -Name 'DhcpConnForceBroadcastFlag' -Value 1 -Type DWord -Force -ErrorAction Stop
                    } -MutationType 'Registry' -Target $ifPath -ValueName 'DhcpConnForceBroadcastFlag' -OldValue $curBf -NewValue 1 -Reversible)
                }
            }
        }
        # 3. Guarantee Windows Firewall allows inbound UDP 68 DHCP Offer/ACK
        $fwRule = Get-NetFirewallRule -Name 'CoreNet-DHCP-In' -ErrorAction SilentlyContinue
        if ($fwRule -and [string]$fwRule.Enabled -ne 'True') {
            [void](Invoke-Change 'Re-enabled Windows Firewall inbound DHCP rule (CoreNet-DHCP-In)' {
                Enable-NetFirewallRule -Name 'CoreNet-DHCP-In' -ErrorAction Stop
            } -MutationType 'FirewallRule' -Target 'CoreNet-DHCP-In' -OldValue 'False' -NewValue 'True' -UndoScript "Disable-NetFirewallRule -Name 'CoreNet-DHCP-In' -ErrorAction SilentlyContinue" -Reversible)
        }
    } catch {}
}
'@

    # 10. Wire AST hooks into Repair-Dhcp and Shield-DataLink (works cleanly across full file including bottom half)
    Inject-FunctionEntryHookAst ([ref]$raw) 'Repair-Dhcp' 'V11_DHCP_PREFLIGHT' @'
    if ($Ad) {
        Ensure-DhcpSovereignReady $Ad
        [void](Exorcise-ApipaGhost $Ad)
        [void](Wait-SwitchPortForwarding $Ad 12)
    }
'@

    Inject-FunctionEntryHookAst ([ref]$raw) 'Shield-DataLink' 'V11_L2_SOVEREIGN' @'
    $sdAd = if ($Ctx -is [hashtable] -and $Ctx.Ad) { $Ctx.Ad } else { $Ctx }
    $sdEnv = if ($Ctx -is [hashtable] -and $Ctx.Env) { $Ctx.Env } else { $null }
    if ($sdAd -and $sdAd.Status -eq 'Up' -and $script:IsAdmin -and -not $script:IsDry -and -not $script:IsPlan) {
        Ensure-NcsiAndDohHealthy
        [void](Exorcise-IcsHijack $sdAd)
        [void](Exorcise-ApipaGhost $sdAd)
        if ($sdEnv -and $sdEnv.Env -eq 'Campus') { Ensure-DhcpSovereignReady $sdAd }
        $curLiveIp = Get-ValidIPv4 $sdAd -NoCache
        if ($curLiveIp) {
            $cInfo = Get-IpConflictInfo $sdAd $curLiveIp
            if ($cInfo.Conflict) {
                Write-Log 'WARN' ("Active IP conflict on {0} ({1} claimed by {2} via {3}); evicting lease and rescuing..." -f $sdAd.Name, $curLiveIp, $cInfo.PeerMac, $cInfo.Source)
                [void](Invoke-Native (Get-SysExe 'ipconfig.exe') @('/release', [string]$sdAd.Name) 6000)
                Flush-InMemoryNetCaches
                if ($sdEnv -and $sdEnv.Env -eq 'Campus') {
                    if (Invoke-CampusStaticRescue $sdAd $curLiveIp) {
                        if ($Ctx -is [hashtable]) { $Ctx.Repaired = $true }
                        return $true
                    }
                }
            }
        }
    }
'@

    # 11. Patch Repair-Dhcp polling calls to bypass 1.5s IP cache (Get-ValidIPv4 $Ad -> -NoCache)
    $errsTmp = $null
    $astTmp = [System.Management.Automation.Language.Parser]::ParseInput($raw, [ref]$null, [ref]$errsTmp)
    $rdHits = @($astTmp.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Repair-Dhcp' }, $true))
    if ($rdHits.Count -eq 1) {
        $rdTxt = $rdHits[0].Extent.Text
        $rdNew = [regex]::Replace($rdTxt, 'Get-ValidIPv4\s+\$Ad(?!\s+-NoCache)\b', 'Get-ValidIPv4 $Ad -NoCache')
        if ($rdNew -ne $rdTxt) {
            $raw = $raw.Substring(0, $rdHits[0].Extent.StartOffset) + $rdNew + $raw.Substring($rdHits[0].Extent.EndOffset)
            Write-Host '  [AST-PATCHED]  Repair-Dhcp polling loops now enforce Get-ValidIPv4 -NoCache' -ForegroundColor Green
        }
    }

    # 12. Enforce strict 7-bit ASCII & single CRLF
    $rawClean = $raw.Replace("`r`r`n", "`r`n").Replace("`r`n", "`n").Replace("`n", "`r`n")
    for ($bi = 0; $bi -lt $rawClean.Length; $bi++) {
        if ([int]$rawClean[$bi] -gt 127) {
            throw ("Non-ASCII character detected at index {0} (code {1})" -f $bi, [int]$rawClean[$bi])
        }
    }
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($rawClean)
    [System.IO.File]::WriteAllBytes($primary, $bytes)

    # 13. Gate 1: Zero-error PowerShell AST Parse
    $parseErrs = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($primary, [ref]$null, [ref]$parseErrs)
    if ($parseErrs -and $parseErrs.Count -gt 0) {
        throw ("AST Parse Failed ($($parseErrs.Count) errors):`n" + (($parseErrs | ForEach-Object { $_.ToString() }) -join "`n"))
    }
    Write-Host '  [VERIFY-OK]    PowerShell AST Compiler: 0 errors' -ForegroundColor Green

    # 14. Gate 2: Full Behavioral SelfTest (-DryRun -NoPause -Json)
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'cmd.exe'
    $psi.Arguments = ('/c "{0}" -Mode SelfTest -DryRun -NoPause -Json' -f $primary)
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true
    $proc = [System.Diagnostics.Process]::Start($psi)
    $stdout = $proc.StandardOutput.ReadToEnd()
    $stderr = $proc.StandardError.ReadToEnd()
    $proc.WaitForExit()
    $jsonObj = $null
    try { $jsonObj = $stdout | ConvertFrom-Json } catch {}
    if ($proc.ExitCode -ne 0 -or (-not $jsonObj) -or ($jsonObj.Failures -ne 0)) {
        throw ("SelfTest Failed (exit={0}, failures={1}):`n{2}`n{3}" -f $proc.ExitCode, $(if ($jsonObj) { $jsonObj.Failures } else { 'null' }), $stdout, $stderr)
    }
    Write-Host ("  [VERIFY-OK]    SelfTest Suite: 100% PASSED ({0}/{0} checks, Exit 0)" -f $jsonObj.TotalChecks) -ForegroundColor Green

    # 15. Sync mirrors & print cryptographic summary
    $mirrorCandidates = @(
        (Join-Path $dir 'NetFix.cmd'),
        'C:\Users\ABHISHEK SONU\Desktop\LanFixer.cmd'
    )
    foreach ($mp in $mirrorCandidates) {
        if ((Test-Path -LiteralPath $mp) -and ($mp -ne $primary)) {
            [System.IO.File]::WriteAllBytes($mp, $bytes)
        }
    }
    $sha256Obj = [System.Security.Cryptography.SHA256]::Create()
    $sha = [System.BitConverter]::ToString($sha256Obj.ComputeHash($bytes)).Replace('-', '')
    $sha256Obj.Dispose()
    $lineCount = ($rawClean -split "`r`n").Count
    Write-Host ("`nSUCCESS: Upgraded to LanFixer v11.0.0 Sovereign | Lines: {0} | Bytes: {1} | SHA256: {2}" -f $lineCount, $bytes.Length, $sha) -ForegroundColor Green
} catch {
    Copy-Item -LiteralPath $backupPath -Destination $primary -Force
    Write-Host ("`nROLLED BACK to backup ({0}) due to error:`n{1}" -f (Split-Path -Leaf $backupPath), $_.Exception.Message) -ForegroundColor Red
    exit 1
}
