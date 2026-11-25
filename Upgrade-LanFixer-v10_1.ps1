#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$candidates = @(@('LanFixer.cmd', 'LanFixer-2_2.cmd', 'NetFix.cmd') | Where-Object { Test-Path -LiteralPath $_ })
if ($candidates.Count -eq 0) {
    Write-Error 'No LanFixer.cmd / LanFixer-2_2.cmd found in the current directory.'
    exit 1
}

$primary = $null
foreach ($c in $candidates) {
    $probeTxt = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $c).Path, [System.Text.Encoding]::ASCII)
    if ($probeTxt -match "\`$script:Version\s*=\s*'10\.0\.0'") { $primary = (Resolve-Path -LiteralPath $c).Path; break }
}
if (-not $primary) { $primary = (Resolve-Path -LiteralPath $candidates[0]).Path }

$dir = Split-Path -Parent $primary
$archiveDir = Join-Path $dir 'Archive'
if (-not (Test-Path -LiteralPath $archiveDir)) { [void](New-Item -ItemType Directory -Path $archiveDir -Force) }
$stamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
$backupPath = Join-Path $archiveDir ("{0}_v10_0_0_backup_{1}.cmd" -f [System.IO.Path]::GetFileNameWithoutExtension($primary), $stamp)
Copy-Item -LiteralPath $primary -Destination $backupPath -Force

$raw = [System.IO.File]::ReadAllText($primary, [System.Text.Encoding]::ASCII)
$raw = $raw.Replace("`r`r`n", "`r`n").Replace("`r`n", "`n").Replace("`n", "`r`n")

function Patch-Once {
    param([ref]$TextRef, [string]$Old, [string]$New, [string]$Label)
    $oldN = $Old.Replace("`r`n", "`n").Replace("`n", "`r`n")
    $newN = $New.Replace("`r`n", "`n").Replace("`n", "`r`n")
    if ($TextRef.Value.Contains($newN)) {
        Write-Host ("  [SKIP-APPLIED] {0}" -f $Label) -ForegroundColor DarkGray
        return
    }
    $first = $TextRef.Value.IndexOf($oldN, [System.StringComparison]::Ordinal)
    if ($first -lt 0) { throw "Patch anchor missing for: $Label" }
    $second = $TextRef.Value.IndexOf($oldN, $first + $oldN.Length, [System.StringComparison]::Ordinal)
    if ($second -ge 0) { throw "Patch anchor ambiguous (>1 matches) for: $Label" }
    $TextRef.Value = $TextRef.Value.Substring(0, $first) + $newN + $TextRef.Value.Substring($first + $oldN.Length)
    Write-Host ("  [PATCHED]      {0}" -f $Label) -ForegroundColor Green
}

try {
    Write-Host ("Targeting: {0}" -f $primary) -ForegroundColor Cyan

    # 1. Version bump 10.0.0 -> 10.1.0
    Patch-Once ([ref]$raw) "LanFixer 10.0.0 - Autonomous" "LanFixer 10.1.0 - Autonomous" "Synopsis version 10.1.0"
    Patch-Once ([ref]$raw) "`$script:Version = '10.0.0'" "`$script:Version = '10.1.0'" "Script version 10.1.0"

    # 2. Fix Defect #11a: Invoke-Undo -NoColor purity and separate DriftSkipped tracking
    Patch-Once ([ref]$raw) @'
    $undoneCount = 0
    $skippedCount = 0
    $planEntries = New-Object System.Collections.ArrayList

    foreach ($e in $candidatesList) {
        $idShort = if ($e.EntryId -and $e.EntryId.Length -ge 8) { $e.EntryId.Substring(0, 8) } else { [string]$e.EntryId }
        if (-not $Force -and $revertedIds.Contains([string]$e.EntryId)) {
            if (-not $Quiet -and -not $Json) {
                Write-Host ("  [SKIP] Entry {0} ({1}) was already undone." -f $idShort, $e.Description) -ForegroundColor DarkGray
            }
            $skippedCount++
            continue
        }
        if (-not $e.Reversible -and -not $e.UndoScript) {
            if (-not $Quiet -and -not $Json) {
                Write-Host ("  [SKIP] Entry {0} ({1}) is marked non-reversible." -f $idShort, $e.Description) -ForegroundColor DarkGray
            }
            $skippedCount++
            continue
        }
'@ @'
    $undoneCount = 0
    $skippedCount = 0
    $driftSkippedCount = 0
    $planEntries = New-Object System.Collections.ArrayList

    foreach ($e in $candidatesList) {
        $idShort = if ($e.EntryId -and $e.EntryId.Length -ge 8) { $e.EntryId.Substring(0, 8) } else { [string]$e.EntryId }
        if (-not $Force -and $revertedIds.Contains([string]$e.EntryId)) {
            if (-not $Quiet -and -not $Json) {
                $msgSkip = ("  [SKIP] Entry {0} ({1}) was already undone." -f $idShort, $e.Description)
                if ($ncUndo) { Write-Host $msgSkip } else { Write-Host $msgSkip -ForegroundColor DarkGray }
            }
            $skippedCount++
            continue
        }
        if (-not $e.Reversible -and -not $e.UndoScript) {
            if (-not $Quiet -and -not $Json) {
                $msgNr = ("  [SKIP] Entry {0} ({1}) is marked non-reversible." -f $idShort, $e.Description)
                if ($ncUndo) { Write-Host $msgNr } else { Write-Host $msgNr -ForegroundColor DarkGray }
            }
            $skippedCount++
            continue
        }
'@ "Invoke-Undo -NoColor & driftSkippedCount init"

    Patch-Once ([ref]$raw) @'
        if ($driftDetected -and -not $Force) {
            if (-not $Quiet -and -not $Json) {
                Write-Host ("  [DRIFT REFUSED] Entry {0}: {1} (use -Force to override)" -f $idShort, $driftReason) -ForegroundColor Yellow
            }
            $skippedCount++
            continue
        }
'@ @'
        if ($driftDetected -and -not $Force) {
            if (-not $Quiet -and -not $Json) {
                $msgDr = ("  [DRIFT REFUSED] Entry {0}: {1} (use -Force to override)" -f $idShort, $driftReason)
                if ($ncUndo) { Write-Host $msgDr } else { Write-Host $msgDr -ForegroundColor Yellow }
            }
            $skippedCount++
            $driftSkippedCount++
            continue
        }
'@ "Invoke-Undo driftSkippedCount increment & -NoColor"

    Patch-Once ([ref]$raw) @'
    $finalStatus = if ($previewMode) { 'Planned' } elseif ($undoneCount -eq 0 -and $skippedCount -gt 0) { 'DriftSkipped' } else { 'Completed' }
'@ @'
    $finalStatus = if ($previewMode) { 'Planned' } elseif ($undoneCount -eq 0 -and $driftSkippedCount -gt 0) { 'DriftSkipped' } else { 'Completed' }
'@ "Invoke-Undo accurate DriftSkipped verdict"

    # 3. Fix Defect #12a: Route Get-HistoryErrors & Get-HistoryTimeline through Get-ChangeLedgerEntries (reads .bak)
    Patch-Once ([ref]$raw) @'
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
'@ @'
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
'@ "Get-HistoryErrors uses Get-ChangeLedgerEntries (.bak aware)"

    Patch-Once ([ref]$raw) @'
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
            if ($timeline.Count -ge $halfLim) { break }
        }
    }
'@ @'
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
'@ "Get-HistoryTimeline uses Get-ChangeLedgerEntries (.bak aware)"

    # 4. Fix Defect #5: Import-UserConfig guard, Test-StoreAcl on DryRun, remove dead code, fix integrity.json desync
    Patch-Once ([ref]$raw) @'
function Import-UserConfig {
    try {
        $path = Join-Path $script:StoreDir 'config.json'
'@ @'
$script:UserConfigLoaded = $false
function Import-UserConfig {
    if ($script:UserConfigLoaded) { return }
    try {
        $path = Join-Path $script:StoreDir 'config.json'
        $script:UserConfigLoaded = $true
'@ "Idempotent Import-UserConfig guard"

    Patch-Once ([ref]$raw) @'
    if ($script:IsDry) { $script:StoreReady = (Test-Path -LiteralPath $dir); $script:StoreSecure = $script:StoreReady; return }
'@ @'
    if ($script:IsDry -or $script:IsPlan) {
        $script:StoreReady = (Test-Path -LiteralPath $dir)
        $script:StoreSecure = if ($script:StoreReady) { Test-StoreAcl $dir } else { $false }
        if ($script:StoreReady) { Import-UserConfig }
        return
    }
'@ "Initialize-Store uses Test-StoreAcl & Import-UserConfig on DryRun/Plan"

    Patch-Once ([ref]$raw) @'
        if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force -ErrorAction Stop | Out-Null }
        if ($script:IsDry -or $script:IsPlan) {
            $script:StoreReady = Test-Path -LiteralPath $dir
            $script:StoreSecure = Test-StoreAcl
            return
        }
        $icacls = Get-SysExe 'icacls.exe'
        # SIDs, not names, so this works on any Windows language.
        $r1 = Invoke-Native $icacls @($dir, '/setowner', '*S-1-5-32-544', '/C', '/Q')
        $r2 = Invoke-Native $icacls @($dir, '/inheritance:r', '/grant:r', '*S-1-5-18:(OI)(CI)F', '/grant:r', '*S-1-5-32-544:(OI)(CI)F', '/grant:r', '*S-1-5-32-545:(OI)(CI)RX', '/C', '/Q')
        Repair-StoreChildren $dir
        $script:StoreSecure = ($r1.ExitCode -eq 0 -and $r2.ExitCode -eq 0)
'@ @'
        if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force -ErrorAction Stop | Out-Null }
        $icacls = Get-SysExe 'icacls.exe'
        # SIDs, not names, so this works on any Windows language.
        $r1 = Invoke-Native $icacls @($dir, '/setowner', '*S-1-5-32-544', '/C', '/Q')
        $r2 = Invoke-Native $icacls @($dir, '/inheritance:r', '/grant:r', '*S-1-5-18:(OI)(CI)F', '/grant:r', '*S-1-5-32-544:(OI)(CI)F', '/grant:r', '*S-1-5-32-545:(OI)(CI)RX', '/C', '/Q')
        Repair-StoreChildren $dir
        Import-UserConfig
        $script:StoreSecure = ($r1.ExitCode -eq 0 -and $r2.ExitCode -eq 0)
'@ "Initialize-Store removes dead branch & calls Import-UserConfig"

    Patch-Once ([ref]$raw) @'
                    $intFileCheck = Join-Path $script:StoreDir 'integrity.json'
                    if (-not (Test-Path -LiteralPath $intFileCheck) -or $Mode -in @('Interactive','Heal','QuickHeal','InstallWatchdog','InstallShield','InstallSentinel')) {
                        [void](Set-ScriptAuthorization $script:SelfCopy)
                    }
'@ @'
                    [void](Set-ScriptAuthorization $script:SelfCopy)
'@ "Initialize-Store always re-signs integrity.json after mirroring SelfCopy"

    # 5. Fix Defect #6a & #9: Test-PortSupportsTls handle disposal order & Invoke-NetworkAutoDiscovery home router guard
    Patch-Once ([ref]$raw) @'
    } finally {
        if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
        if ($ssl) { try { $ssl.Dispose() } catch {} }
        if ($sock) { try { $sock.Close(); $sock.Dispose() } catch {} }
    }
}
function Invoke-NetworkAutoDiscovery {
'@ @'
    } finally {
        if ($ssl) { try { $ssl.Dispose() } catch {} }
        if ($sock) { try { $sock.Close(); $sock.Dispose() } catch {} }
        if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
    }
}
function Invoke-NetworkAutoDiscovery {
'@ "Test-PortSupportsTls dispose socket before AsyncWaitHandle"

    Patch-Once ([ref]$raw) @'
        # 3. Dynamic Captive Portal Autodiscovery: RFC HTTP 3xx Redirect & Multi-Port Matrix
        if (-not $script:State.Misc['DiscoveredPortalUrl'] -and -not $script:IsDry) {
            $candIps = @()
            if ($primaryGw) { $candIps += $primaryGw }
            if ($script:Cfg.PortalIp -and $candIps -notcontains [string]$script:Cfg.PortalIp) { $candIps += [string]$script:Cfg.PortalIp }
'@ @'
        # 3. Dynamic Captive Portal Autodiscovery: RFC HTTP 3xx Redirect & Multi-Port Matrix
        if (-not $script:State.Misc['DiscoveredPortalUrl'] -and -not $script:IsDry) {
            $candIps = @()
            if ($primaryGw) { $candIps += $primaryGw }
            $allowCfgIp = ($discSrcIp -notlike '192.168.*' -or (Test-IsNitjsrNetwork))
            if ($allowCfgIp -and $script:Cfg.PortalIp -and $candIps -notcontains [string]$script:Cfg.PortalIp) { $candIps += [string]$script:Cfg.PortalIp }
'@ "Invoke-NetworkAutoDiscovery skip 10.114.0.5 probe on 192.168.* home LANs"

    Patch-Once ([ref]$raw) @'
            # 3b. Autonomous Multi-Port Matrix Probing (dedicated captive portal ports only)
            if (-not $script:State.Misc['DiscoveredPortalUrl']) {
                $gwPorts = @(8888, 8003, 8090, 8443, 8080)
                foreach ($cIp in $candIps) {
                    foreach ($p in $gwPorts) {
'@ @'
            # 3b. Autonomous Multi-Port Matrix Probing (dedicated captive portal ports; skips common home routers to avoid admin UI false positives)
            if (-not $script:State.Misc['DiscoveredPortalUrl']) {
                $gwPorts = @(8888, 8003, 8090, 8443, 8080)
                foreach ($cIp in $candIps) {
                    if ($cIp -ne [string]$script:Cfg.PortalIp -and -not (Test-LearnableDhcpServer $cIp)) { continue }
                    foreach ($p in $gwPorts) {
'@ "Invoke-NetworkAutoDiscovery skip blind port scan on consumer home routers"

    # 6. Fix Defect #6b: Test-TcpPort, Resolve-HostBounded, Invoke-HttpProbe, Invoke-TlsHttp handle disposal & zero-copy
    Patch-Once ([ref]$raw) @'
    finally {
        if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
        if ($c) { try { $c.Close(); $c.Dispose() } catch {} }
    }
}
'@ @'
    finally {
        if ($c) { try { $c.Close(); $c.Dispose() } catch {} }
        if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
    }
}
'@ "Test-TcpPort dispose TcpClient before AsyncWaitHandle"

    Patch-Once ([ref]$raw) @'
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
'@ @'
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
'@ "Resolve-HostBounded never close in-flight DNS AsyncWaitHandle on timeout"

    Patch-Once ([ref]$raw) @'
    $sock = New-Object System.Net.Sockets.Socket([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
    try {
        if ($SourceIp) {
            try { $sock.Bind((New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($SourceIp), 0))) } catch { $r.Error = 'BindFailure'; return $r }
        }
        $iar = $sock.BeginConnect([System.Net.IPAddress]::Parse($ip), $Port, $null, $null)
'@ @'
    $iar = $null
    $sock = New-Object System.Net.Sockets.Socket([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
    try {
        if ($SourceIp) {
            try { $sock.Bind((New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($SourceIp), 0))) } catch { $r.Error = 'BindFailure'; return $r }
        }
        $iar = $sock.BeginConnect([System.Net.IPAddress]::Parse($ip), $Port, $null, $null)
'@ 'Invoke-HttpProbe initialize $iar'

    Patch-Once ([ref]$raw) @'
    } catch { $r.Error = $_.Exception.Message }
    finally {
        if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
        if ($sock) { try { $sock.Close(); $sock.Dispose() } catch {} }
    }
    return $r
}
'@ @'
    } catch { $r.Error = $_.Exception.Message }
    finally {
        if ($sock) { try { $sock.Close(); $sock.Dispose() } catch {} }
        if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
    }
    return $r
}
'@ "Invoke-HttpProbe dispose socket before AsyncWaitHandle"

    Patch-Once ([ref]$raw) @'
    $sock = $null; $ssl = $null
    try {
        $hostName = [string]$Uri.Host
'@ @'
    $sock = $null; $ssl = $null; $ns = $null; $iar = $null; $ms = $null
    try {
        $hostName = [string]$Uri.Host
'@ "Invoke-TlsHttp initialize handles"

    Patch-Once ([ref]$raw) @'
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
'@ @'
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
'@ "Invoke-TlsHttp zero-copy GetBuffer() instead of O(N^2) ToArray()"

    Patch-Once ([ref]$raw) @'
    } catch { $r.Error = 'Error' }
    finally {
        if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
        if ($ms) { try { $ms.Dispose() } catch {} }
        if ($ssl) { try { $ssl.Dispose() } catch {} }
        if ($sock) { try { $sock.Close(); $sock.Dispose() } catch {} }
    }
'@ @'
    } catch { $r.Error = 'Error' }
    finally {
        if ($ssl) { try { $ssl.Dispose() } catch {} }
        elseif ($ns) { try { $ns.Dispose() } catch {} }
        if ($sock) { try { $sock.Close(); $sock.Dispose() } catch {} }
        if ($ms) { try { $ms.Dispose() } catch {} }
        if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
    }
'@ "Invoke-TlsHttp dispose socket/stream before AsyncWaitHandle"

    # 7. Fix Defect #11b: Set-UsbSuspendOff reversible ledger metadata
    Patch-Once ([ref]$raw) @'
    Save-Original 'Global' 'UsbSuspend' @{ Scheme = $scheme; Ac = $ac; Dc = $dc }
    [void](Invoke-Change 'USB selective suspend configured for low-latency Ethernet on AC power (preserves battery efficiency)' {
        [void](Invoke-Native $pcfg @('/setacvalueindex', $scheme, $script:UsbSub, $script:UsbSet, '0') 5000)
        if (-not $bat.IsOnBattery) {
            [void](Invoke-Native $pcfg @('/setdcvalueindex', $scheme, $script:UsbSub, $script:UsbSet, '0') 5000)
        }
        [void](Invoke-Native $pcfg @('/s', $scheme) 5000)
    })
'@ @'
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
'@ "Set-UsbSuspendOff reversible ledger metadata"

    # 8. Fix Defects #1, #2, #6c, #7, #10, #12b: Test-IsPortalDemandingAuth, Test-AnyTcpPortParallel, Initialize-NativeArp, Flush-InMemoryNetCaches, Get-IpConflictInfo, Invoke-CampusStaticRescue, Test-AdapterRxStall, Test-HttpsWanProbe
    Patch-Once ([ref]$raw) @'
    } finally {
        if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
        if ($ssl) { try { $ssl.Dispose() } catch {} }
        if ($sock) { try { $sock.Close(); $sock.Dispose() } catch {} }
    }
    return $false
}
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
}
'@ @'
    } finally {
        if ($ssl) { try { $ssl.Dispose() } catch {} }
        if ($sock) { try { $sock.Close(); $sock.Dispose() } catch {} }
        if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
    }
    return $false
}
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
function Initialize-NativeArp {
    if ('LfNativeArp' -as [type]) { return $true }
    try {
        Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public static class LfNativeArp { [DllImport("iphlpapi.dll", ExactSpelling=true)] public static extern int SendARP(int DestIP, int SrcIP, byte[] pMacAddr, ref int PhyAddrLen); }' -ErrorAction Stop
        return $true
    } catch { return $false }
}
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

$script:HttpsWanOkCache = @{}
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
'@ "Fix Test-AnyTcpPortParallel spin, centralize Initialize-NativeArp, add HttpsWanOkCache"

    Patch-Once ([ref]$raw) @'
    try {
        if (-not ('LfNativeArp' -as [type])) {
            Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public static class LfNativeArp { [DllImport("iphlpapi.dll", ExactSpelling=true)] public static extern int SendARP(int DestIP, int SrcIP, byte[] pMacAddr, ref int PhyAddrLen); }' -ErrorAction Stop
        }
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
    } catch {}
'@ @'
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
'@ "Enhance Get-IpConflictInfo with neighbor MAC mismatch & shared Initialize-NativeArp"

    Patch-Once ([ref]$raw) @'
function Invoke-CampusStaticRescue($Ad, [string]$ConflictedIp = '') {
    if (-not $Ad -or -not $Ad.ifIndex) { return $false }
    $hint = Get-CampusSubnetHint $Ad $ConflictedIp
    if (-not $hint.BaseIp -or -not $hint.Gateway) { return $false }
    if (-not (Test-ActiveArp $hint.Gateway '' '')) {
        $rtGw = $null; try { $rtGw = Test-Ping $hint.Gateway 350 } catch {}
        if ($null -eq $rtGw) { return $false }
    }
    $freeIp = Find-FreeSubnetIp -BaseIp $hint.BaseIp -PrefixLength $hint.PrefixLength -Gateway $hint.Gateway -ExcludeIps @($ConflictedIp)
    if (-not $freeIp) { return $false }

    $guid = [string]$Ad.InterfaceGuid
    $pfx = [int]$hint.PrefixLength
    $gwS = [string]$hint.Gateway
    $dnsList = @($hint.Dns | Where-Object { $_ } | Select-Object -Unique)
    if ($dnsList.Count -eq 0) { $dnsList = @('1.1.1.1', '9.9.9.9') }

    $undoStatic = "Set-NetIPInterface -InterfaceIndex $($Ad.ifIndex) -AddressFamily IPv4 -Dhcp Enabled -ErrorAction SilentlyContinue; Set-DnsClientServerAddress -InterfaceIndex $($Ad.ifIndex) -ResetServerAddresses -ErrorAction SilentlyContinue"
    $ok = Invoke-Change ("Campus conflict/DHCP static rescue on $($Ad.Name): $freeIp/$pfx GW $gwS") {
        Remove-NetIPAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
        Remove-NetRoute -InterfaceIndex $Ad.ifIndex -DestinationPrefix '0.0.0.0/0' -Confirm:$false -ErrorAction SilentlyContinue
        Set-NetIPInterface -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -Dhcp Disabled -ErrorAction Stop
        New-NetIPAddress -InterfaceIndex $Ad.ifIndex -IPAddress $freeIp -PrefixLength $pfx -DefaultGateway $gwS -AddressFamily IPv4 -ErrorAction Stop | Out-Null
        Set-DnsClientServerAddress -InterfaceIndex $Ad.ifIndex -ServerAddresses $dnsList -ErrorAction SilentlyContinue
    } -MutationType 'StaticIpRescue' -Target $Ad.Name -OldValue $ConflictedIp -NewValue "$freeIp/$pfx" -UndoScript $undoStatic -Reversible

    if ($ok -and -not $script:IsDry) {
        if ($guid) { Save-Original $guid 'StaticRescueIp' "$freeIp/$pfx" }
        Flush-InMemoryNetCaches
        $ga = Test-GatewayAlive $Ad $gwS
        if ($ga.Alive) {
            Write-Log 'OK' ("Campus static rescue active on {0}: {1}/{2} -> gateway {3} alive ({4})." -f $Ad.Name, $freeIp, $pfx, $gwS, $ga.Via)
        }
    }
    return [bool]$ok
}

function Test-AdapterRxStall($Ad, [string]$Gateway = '') {
    if (-not $Ad -or $Ad.Status -ne 'Up' -or $script:IsDry) { return $false }
    try {
        $s1 = Get-NetAdapterStatistics -Name $Ad.Name -ErrorAction Stop
        if (-not $s1) { return $false }
        $rx1 = [int64]$s1.ReceivedUnicastPackets + [int64]$s1.ReceivedNonUnicastPackets
        $tx1 = [int64]$s1.SentUnicastPackets
        $srcIp = [string](Get-ValidIPv4 $Ad)
        $tgt = if ($Gateway) { $Gateway } else { [string]$script:Cfg.PortalIp }
        if ($tgt) {
            [void](Test-ActiveArp $tgt '' $srcIp)
            [void](Test-Ping $tgt 350)
            [void](Test-ActiveArp $tgt '' $srcIp)
        }
        $s2 = Get-NetAdapterStatistics -Name $Ad.Name -ErrorAction Stop
        $rx2 = [int64]$s2.ReceivedUnicastPackets + [int64]$s2.ReceivedNonUnicastPackets
        $tx2 = [int64]$s2.SentUnicastPackets
        $dTx = $tx2 - $tx1
        $dRx = $rx2 - $rx1
        if ($dTx -ge 2 -and $dRx -le 0) {
            Write-Log 'WARN' ("Silent RX hardware stall suspected on {0} (TX delta=+{1}, RX delta={2})." -f $Ad.Name, $dTx, $dRx)
            return $true
        }
    } catch {}
    return $false
}
function Test-HttpsWanProbe([string]$SourceIp = '', [int]$TimeoutMs = 1800) {
    $res = @{ Ok = $false; IsCaptive = $false; Error = ''; CertSubject = '' }
    $targets = @(
        @{ Ip = '1.1.1.1'; Sni = '1.1.1.1' },
        @{ Ip = '9.9.9.9'; Sni = '9.9.9.9' },
        @{ Ip = ''; Sni = 'connectivitycheck.gstatic.com' },
        @{ Ip = ''; Sni = 'www.microsoft.com' }
    )
    foreach ($tg in $targets) {
        $dstIp = [string]$tg.Ip
        if (-not $dstIp) { $dstIp = Resolve-HostBounded ([string]$tg.Sni) 1000 $SourceIp }
        if (-not $dstIp) { continue }
        $sock = $null; $ssl = $null; $iar = $null
        $cap = @{ Errors = ''; Subject = '' }
        try {
            $sock = New-Object System.Net.Sockets.Socket([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
            if ($SourceIp) {
                try { $sock.Bind((New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($SourceIp), 0))) } catch { $res.Error = 'BindFailure'; return $res }
            }
            $iar = $sock.BeginConnect([System.Net.IPAddress]::Parse($dstIp), 443, $null, $null)
            if (-not $iar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)) { $res.Error = 'Timeout'; continue }
            $sock.EndConnect($iar)
            $ns = New-Object System.Net.Sockets.NetworkStream($sock, $false)
            $ns.ReadTimeout = $TimeoutMs; $ns.WriteTimeout = $TimeoutMs
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
            return $res
        } catch {
            $res.Error = $_.Exception.Message
            if ($cap.Errors -and $cap.Errors -ne 'None') {
                $res.IsCaptive = $true
                $res.CertSubject = [string]$cap.Subject
                return $res
            }
        } finally {
            if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
            if ($ssl) { try { $ssl.Dispose() } catch {} }
            if ($sock) { try { $sock.Close(); $sock.Dispose() } catch {} }
        }
    }
    $actUrl = Get-ActivePortalUrl
    if ($actUrl -and (Test-IsPortalDemandingAuth $actUrl $SourceIp)) {
        $res.IsCaptive = $true
        $res.Error = 'PortalDemandsAuth'
    }
    return $res
}
'@ @'
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
function Test-HttpsWanProbe([string]$SourceIp = '', [int]$TimeoutMs = 1200) {
    $res = @{ Ok = $false; IsCaptive = $false; Error = ''; CertSubject = '' }
    $cacheKey = if ($SourceIp) { $SourceIp } else { 'ANY' }
    $nowT = [System.Diagnostics.Stopwatch]::GetTimestamp()
    if ($script:HttpsWanOkCache -is [hashtable] -and $script:HttpsWanOkCache.ContainsKey($cacheKey)) {
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
'@ "Fix Invoke-CampusStaticRescue auto-rollback, Test-AdapterRxStall, and Test-HttpsWanProbe caching/budget"

    # 9. Fix Defects #3, #4, #8: Get-GatewaysV4/Get-ValidIPv4 -NoCache, Get-AdapterEnvironment Other cleanup, Get-AdapterHealth Duplicate filter, Reset-PhysicalAdapterHardware full cache flush
    Patch-Once ([ref]$raw) @'
function Get-GatewaysV4($Ad = $null) {
    $nowT = [System.Diagnostics.Stopwatch]::GetTimestamp()
    $freq = [System.Diagnostics.Stopwatch]::Frequency
    if ($PSBoundParameters.Count -eq 0) {
        if ($script:Gw4Cache.ContainsKey('ALL') -and (($nowT - $script:Gw4Cache['ALL'].Ticks) / $freq) -lt 1.5) {
            return $script:Gw4Cache['ALL'].Val
        }
        $allGws = @()
        foreach ($a in (@(Get-EthernetAdapters) + @(Get-OtherUplinkAdapters) | Where-Object { $_ -and $_.Status -eq 'Up' })) {
            $allGws += @(Get-GatewaysV4 $a)
        }
        $u = @($allGws | Where-Object { $_ } | Select-Object -Unique)
        $script:Gw4Cache['ALL'] = @{ Ticks = $nowT; Val = $u }
        return $u
    }
    if (-not $Ad -or -not $Ad.ifIndex) { return @() }
    $k = [string]$Ad.ifIndex
    if ($script:Gw4Cache.ContainsKey($k) -and (($nowT - $script:Gw4Cache[$k].Ticks) / $freq) -lt 1.5) {
        return $script:Gw4Cache[$k].Val
    }
    $res = @(Get-NetRoute -InterfaceIndex $Ad.ifIndex -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue |
        Where-Object { $_.NextHop -and $_.NextHop -ne '0.0.0.0' } | ForEach-Object { [string]$_.NextHop } | Select-Object -Unique)
    $script:Gw4Cache[$k] = @{ Ticks = $nowT; Val = $res }
    return $res
}
function Get-DefaultGateway($Ad) {
    if (-not $Ad) { return $null }
    $gws = @(Get-GatewaysV4 $Ad)
    if ($gws.Count -gt 0) { return [string]$gws[0] }
    return $null
}
function Get-ValidIPv4($Ad) {
    if (-not $Ad -or -not $Ad.ifIndex) { return $null }
    $nowT = [System.Diagnostics.Stopwatch]::GetTimestamp()
    $k = [string]$Ad.ifIndex
    if ($script:Ip4Cache.ContainsKey($k) -and (($nowT - $script:Ip4Cache[$k].Ticks) / [System.Diagnostics.Stopwatch]::Frequency) -lt 1.5) {
        return $script:Ip4Cache[$k].Val
    }
    $x = Get-NetIPAddress -InterfaceIndex $Ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue |
         Where-Object { $_.IPAddress -notlike '169.254.*' -and $_.AddressState -eq 'Preferred' } | Select-Object -First 1
    $val = if ($x) { [string]$x.IPAddress } else { $null }
    $script:Ip4Cache[$k] = @{ Ticks = $nowT; Val = $val }
    return $val
}
'@ @'
function Get-GatewaysV4($Ad = $null, [switch]$NoCache) {
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
function Get-DefaultGateway($Ad) {
    if (-not $Ad) { return $null }
    $gws = @(Get-GatewaysV4 $Ad)
    if ($gws.Count -gt 0) { return [string]$gws[0] }
    return $null
}
function Get-ValidIPv4($Ad, [switch]$NoCache) {
    if (-not $Ad -or -not $Ad.ifIndex) { return $null }
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
'@ "Add -NoCache to Get-GatewaysV4 & Get-ValidIPv4"

    Patch-Once ([ref]$raw) @'
    if (-not $sticky -and ($envName -eq 'Campus' -or $envName -eq 'Other')) {
        $h = Get-SubTable 'Env' $guid
        $h.Env = $envName
        $h.Home = $homeVerdict
        $h.Time = (Get-Date).ToString('o')
    }
'@ @'
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
'@ "Restore Discovered* cleanup on Other networks in Get-AdapterEnvironment"

    Patch-Once ([ref]$raw) @'
    $validObjs = @($all | Where-Object { $_.IPAddress -notmatch '^(169\.254\.|127\.)' } | Sort-Object { if ($_.AddressState -eq 'Preferred') { 0 } else { 1 } })
'@ @'
    $validObjs = @($all | Where-Object { $_.IPAddress -notmatch '^(169\.254\.|127\.)' -and $_.AddressState -notin @('Duplicate','Invalid') } | Sort-Object { if ($_.AddressState -eq 'Preferred') { 0 } else { 1 } })
'@ "Exclude Duplicate/Invalid IPv4 addresses in Get-AdapterHealth"

    Patch-Once ([ref]$raw) @'
    $script:EthernetAdaptersCache = $null
    $script:OtherUplinksCache = $null
    return $restarted
}
'@ @'
    Flush-InMemoryNetCaches
    return $restarted
}
'@ "Flush all in-memory net caches in Reset-PhysicalAdapterHardware"

    # 10. Bottom-half forensic inspection & automatic hardening (for lines beyond chat truncation)
    Write-Host "`n--- Running Full-File Bottom-Half Forensic Audit ---" -ForegroundColor Cyan
    if ($raw -match 'function Restore-Everything') {
        if ($raw -notmatch 'PcieAspm') { Write-Host '  [AUDIT-WARN] PcieAspm snapshot missing in Restore-Everything' -ForegroundColor Yellow }
        else { Write-Host '  [AUDIT-OK]   PcieAspm referenced across file' -ForegroundColor Green }
        if ($raw -match 'StaticRescueIp' -and ($raw -split 'function Restore-Everything')[1] -notmatch 'StaticRescueIp') {
            Write-Host '  [AUDIT-WARN] StaticRescueIp snapshot not explicitly cleared in Restore-Everything (safe: Restore-Everything already resets DHCP via snapshot/netsh)' -ForegroundColor Yellow
        }
    }
    if ($raw -match 'if \(Get-ValidIPv4 \$Ad\) \{ Write-Log ''OK'' ''Lease acquired after link reset\.'' ; return \$true \}' -or $raw -match "if \(Get-ValidIPv4 \`$Ad\) \{ Write-Log 'OK' 'Lease acquired after link reset\.'; return \`$true \}") {
        $raw = $raw.Replace("if (Get-ValidIPv4 `$Ad) { Write-Log 'OK' 'Lease acquired after link reset.'; return `$true }", "if (Get-ValidIPv4 `$Ad -NoCache) { Write-Log 'OK' 'Lease acquired after link reset.'; return `$true }")
        $raw = $raw.Replace("if (Get-ValidIPv4 `$Ad) { Write-Log 'OK' 'Lease acquired after release/renew.'; return `$true }", "if (Get-ValidIPv4 `$Ad -NoCache) { Write-Log 'OK' 'Lease acquired after release/renew.'; return `$true }")
        Write-Host '  [PATCHED]      Repair-Dhcp Step 2/3 polling loops now force Get-ValidIPv4 -NoCache' -ForegroundColor Green
    }

    # 11. Pure 7-bit ASCII & single-CRLF enforcement
    $rawClean = $raw.Replace("`r`r`n", "`r`n").Replace("`r`n", "`n").Replace("`n", "`r`n")
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($rawClean)
    for ($bi = 0; $bi -lt $rawClean.Length; $bi++) {
        if ([int]$rawClean[$bi] -gt 127) { throw ("Non-ASCII character detected at index {0} (code {1})" -f $bi, [int]$rawClean[$bi]) }
    }
    [System.IO.File]::WriteAllBytes($primary, $bytes)

    # 12. Grounded Verification Gate 1: PowerShell AST Compiler (0 errors required)
    $parseErrs = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($primary, [ref]$null, [ref]$parseErrs)
    if ($parseErrs -and $parseErrs.Count -gt 0) {
        $errMsg = ($parseErrs | ForEach-Object { $_.ToString() }) -join "`n"
        throw "AST Parse Failed ($($parseErrs.Count) errors):`n$errMsg"
    }
    Write-Host '  [VERIFY-OK]    PowerShell AST Parse: 0 errors' -ForegroundColor Green

    # 13. Grounded Verification Gate 2: Live SelfTest (-DryRun -NoPause -Json)
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

    # 14. Sync mirrors & compute final SHA-256
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
    Write-Host ("`nSUCCESS: Upgraded to LanFixer v10.1.0 | Lines: {0} | Bytes: {1} | SHA256: {2}" -f $lineCount, $bytes.Length, $sha) -ForegroundColor Green
} catch {
    Copy-Item -LiteralPath $backupPath -Destination $primary -Force
    Write-Host ("`nROLLED BACK to backup ({0}) due to error:`n{1}" -f (Split-Path -Leaf $backupPath), $_.Exception.Message) -ForegroundColor Red
    exit 1
}
