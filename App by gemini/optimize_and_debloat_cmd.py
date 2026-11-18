import re, shutil, hashlib, subprocess, sys
from datetime import datetime
from pathlib import Path

targets = [Path(p) for p in ("LanFixer.cmd", "NetFix.cmd", "LanFixer_3.cmd", "LanFixer_2.cmd") if Path(p).exists()]
if not targets:
    print("ERROR: LanFixer.cmd not found in current directory.")
    sys.exit(1)

primary = next((t for t in targets if "$script:Version = '7.0." in t.read_bytes().decode("ascii", errors="ignore")), targets[0])

archive = Path("Archive")
archive.mkdir(exist_ok=True)
ts = datetime.now().strftime("%Y%m%d_%H%M%S")
backup_path = archive / f"{primary.stem}_backup_{ts}.cmd"
shutil.copy2(primary, backup_path)

raw = primary.read_bytes().decode("ascii").replace("\r\r\n", "\r\n").replace("\r\n", "\n").replace("\n", "\r\n")

def patch_once(text: str, old: str, new: str, label: str) -> str:
    old_c = old.replace("\r\n", "\n").replace("\n", "\r\n")
    new_c = new.replace("\r\n", "\n").replace("\n", "\r\n")
    if new_c in text:
        return text
    if old_c not in text:
        raise RuntimeError(f"Patch anchor missing for: {label}")
    if text.count(old_c) != 1:
        raise RuntimeError(f"Patch anchor ambiguous (count={text.count(old_c)}) for: {label}")
    return text.replace(old_c, new_c, 1)

try:
    orig_lines = raw.count("\r\n")
    orig_bytes = len(raw)

    # 1. Debloat the 235-line historical changelog wall in .SYNOPSIS/.NOTES down to a concise header
    raw, n_hdr = re.subn(
        r"<#\r\n\.SYNOPSIS[\s\S]*?#>\r\n\r\n\[CmdletBinding\(\)\]",
        """<#\r
.SYNOPSIS\r
    LanFixer 7.0.2 - Network diagnostic, stabilization, and captive portal automation utility for Windows.\r
    Author: Abhishek Sonu (https://github.com/abhiisonu)\r
.DESCRIPTION\r
    Single-file ASCII polyglot. Run normally for interactive dashboard or pass -Mode.\r
    All mutations are snapshotted first (First-Write-Wins) and recorded in change_ledger.jsonl.\r
#>\r
\r
[CmdletBinding()]""",
        raw,
        count=1
    )

    # 2. Bump version to 7.0.2
    raw = raw.replace("$script:Version = '7.0.0'", "$script:Version = '7.0.2'")
    raw = raw.replace("$script:Version = '7.0.1'", "$script:Version = '7.0.2'")

    # 3. Fix Add-ChangeLedgerEntry ValueName & newline regex
    raw = patch_once(
        raw,
        """function Add-ChangeLedgerEntry {
    param(
        [string]$Description,
        [string]$MutationType = 'Generic',
        [string]$Target = '',
        $OldValue = $null,
        $NewValue = $null,
        [bool]$Success = $true,
        [bool]$Reversible = $false,
        [string]$UndoScript = ''
    )""",
        """function Add-ChangeLedgerEntry {
    param(
        [string]$Description,
        [string]$MutationType = 'Generic',
        [string]$Target = '',
        [string]$ValueName = '',
        $OldValue = $null,
        $NewValue = $null,
        [bool]$Success = $true,
        [bool]$Reversible = $false,
        [string]$UndoScript = ''
    )""" if "        [string]$ValueName = ''," not in raw else """function Add-ChangeLedgerEntry {""",
        "Add ValueName to Add-ChangeLedgerEntry"
    )

    if "ValueName      = [string]$ValueName" not in raw:
        raw = patch_once(
            raw,
            """            MutationType   = [string]$MutationType
            Target         = [string]$Target
            OldValue       = $OldValue""",
            """            MutationType   = [string]$MutationType
            Target         = [string]$Target
            ValueName      = [string]$ValueName
            OldValue       = $OldValue""",
            "Store ValueName in ledger entry"
        )

    raw = re.sub(
        r"\(ConvertTo-Json \$entry -Compress\) -replace '\[\s+\]\+', ''",
        r"(ConvertTo-Json $entry -Compress) -replace '[\\r\\n]+', ''",
        raw
    )

    if "        [string]$ValueName = '',\r\n        $OldValue = $null,\r\n        $NewValue = $null,\r\n        [string]$UndoScript = ''" not in raw:
        raw = patch_once(
            raw,
            """function Invoke-Change {
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
    )""",
            """function Invoke-Change {
    param(
        [string]$Description,
        [scriptblock]$Action,
        [switch]$FailOnFalse,
        [string]$MutationType = 'Generic',
        [string]$Target = '',
        [string]$ValueName = '',
        $OldValue = $null,
        $NewValue = $null,
        [string]$UndoScript = '',
        [switch]$Reversible
    )""",
            "Add ValueName to Invoke-Change"
        )
        raw = patch_once(
            raw,
            """        Add-ChangeLedgerEntry -Description $Description -MutationType $MutationType -Target $Target -OldValue $OldValue -NewValue $NewValue -Success $true -Reversible ([bool]($Reversible -or $UndoScript)) -UndoScript $UndoScript
        return $true
    } catch {
        $script:FailCount++
        Write-Log 'FAIL' ("{0} -> {1}" -f $Description, $_.Exception.Message)
        Add-ChangeLedgerEntry -Description $Description -MutationType $MutationType -Target $Target -OldValue $OldValue -NewValue $NewValue -Success $false -Reversible $false""",
            """        Add-ChangeLedgerEntry -Description $Description -MutationType $MutationType -Target $Target -ValueName $ValueName -OldValue $OldValue -NewValue $NewValue -Success $true -Reversible ([bool]($Reversible -or $UndoScript)) -UndoScript $UndoScript
        return $true
    } catch {
        $script:FailCount++
        Write-Log 'FAIL' ("{0} -> {1}" -f $Description, $_.Exception.Message)
        Add-ChangeLedgerEntry -Description $Description -MutationType $MutationType -Target $Target -ValueName $ValueName -OldValue $OldValue -NewValue $NewValue -Success $false -Reversible $false""",
            "Forward ValueName in Invoke-Change"
        )

    # 4. Fix Get-HistoryStateTransitions LinkMonitor.History iteration
    if "$histItems = if ($lm -is [hashtable]" not in raw:
        raw = patch_once(
            raw,
            """function Get-HistoryStateTransitions([int]$Limit = 30) {
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
    }""",
            """function Get-HistoryStateTransitions([int]$Limit = 30) {
    $trans = New-Object System.Collections.ArrayList
    $lm = $script:State.LinkMonitor
    $histItems = if ($lm -is [hashtable] -and $lm.ContainsKey('History')) { @($lm.History) } else { @() }
    foreach ($item in $histItems) {
        if ($item) {
            $tsVal = if ($item.Time) { [string]$item.Time } else { [string]$item.Timestamp }
            $adVal = if ($item.Adapter) { [string]$item.Adapter } else { 'PrimaryAdapter' }
            [void]$trans.Add(@{
                Timestamp = $tsVal
                Type      = 'LinkTransition'
                Adapter   = $adVal
                Status    = [string]$item.Status
                Speed     = [string]$item.Speed
                Details   = ("Link transition on {0}: Status={1} Speed={2}" -f $adVal, $item.Status, $item.Speed)
            })
        }
    }""",
            "Fix Get-HistoryStateTransitions LinkMonitor.History"
        )

    # 5. Fix Invoke-NetworkAutoDiscovery home router false positives
    if "if ($pUri.Host -and $pUri.Host -ne $cIp)" not in raw:
        raw = patch_once(
            raw,
            """            # 3a. Intercept HTTP 301/302/307 Redirect on Port 80 (Gateway & Portal Target)
            foreach ($cIp in $candIps) {
                if (-not $script:State.Misc['DiscoveredPortalUrl']) {
                    $probeRes = Invoke-HttpProbe $cIp '/' 1200 '' 80
                    if ($probeRes.Location -and $probeRes.Location -match '^https?://') {
                        $script:State.Misc['DiscoveredPortalUrl'] = [string]$probeRes.Location
                        try {
                            $pUri = [uri]$probeRes.Location
                            $script:State.Misc['DiscoveredPortalHost'] = ([string]$pUri.Host).ToLowerInvariant()
                            if ($pUri.Port -gt 0) { $script:State.Misc['DiscoveredPortalPort'] = [int]$pUri.Port }
                            $script:State.Misc['DiscoveredPortalIp'] = $cIp
                            Write-Log 'OK' ("Dynamically autodiscovered captive portal via HTTP redirect: {0}" -f $probeRes.Location)
                        } catch {}
                        break
                    }
                }
            }

            # 3b. Autonomous Multi-Port Matrix Probing (8888, 8003, 8090, 8443, 8080, 443, 80)
            if (-not $script:State.Misc['DiscoveredPortalUrl']) {
                $gwPorts = @(8888, 8003, 8090, 8443, 8080, 443, 80)""",
            """            # 3a. Intercept HTTP 301/302/307 Redirect on Port 80 (ignoring same-host HTTP->HTTPS router admin upgrades)
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
                $gwPorts = @(8888, 8003, 8090, 8443, 8080)""",
            "Fix Invoke-NetworkAutoDiscovery home router false positives"
        )

    # 6. Fix Test-IsPortalDemandingAuth & Test-HttpsWanProbe
    if "function Test-IsPortalDemandingAuth([string]$PortalUrl = '', [string]$SourceIp = '')" not in raw:
        raw = patch_once(
            raw,
            """function Test-IsPortalDemandingAuth([string]$PortalUrl = '') {
    if (-not $PortalUrl) { return $false }
    $u = $null
    try { $u = [uri]$PortalUrl } catch { return $false }
    $sock = $null; $ssl = $null
    try {
        $sock = New-Object System.Net.Sockets.Socket([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
        $iar = $sock.BeginConnect([System.Net.IPAddress]::Parse($u.Host), [int]$u.Port, $null, $null)
        if (-not $iar.AsyncWaitHandle.WaitOne(1200, $false)) { return $false }
        $sock.EndConnect($iar)
        $ns = New-Object System.Net.Sockets.NetworkStream($sock, $false)
        $ns.ReadTimeout = 1500; $ns.WriteTimeout = 1500
        $stream = $ns
        if ($u.Scheme -eq 'https') {
            $cb = { param($s, $c, $ch, $e) return $true }
            $ssl = New-Object System.Net.Security.SslStream($ns, $false, $cb)
            $ssl.AuthenticateAsClient($u.Host)
            $stream = $ssl
        }
        $req = "GET $($u.PathAndQuery) HTTP/1.0`r`nHost: $($u.Host)`r`nConnection: close`r`n`r`n"
        $hb = [System.Text.Encoding]::ASCII.GetBytes($req)
        $stream.Write($hb, 0, $hb.Length)
        $stream.Flush()
        $sr = New-Object System.IO.StreamReader($stream)
        $html = $sr.ReadToEnd()
        if ($html -match 'type=["'']password["'']' -or $html -match 'name=["'']auth_pass["'']' -or $html -match 'name=["'']password["'']' -or $html -match 'action=.*portal') {
            return $true
        }
    } catch {
        return $false
    } finally {
        if ($ssl) { try { $ssl.Close() } catch {} }
        if ($sock) { try { $sock.Close() } catch {} }
    }
    return $false
}
function Test-HttpsWanProbe([string]$SourceIp = '', [int]$TimeoutMs = 2000) {
    $res = @{ Ok = $false; IsCaptive = $false; Error = ''; CertSubject = '' }
    $actUrl = Get-ActivePortalUrl
    if ($actUrl -and (Test-IsPortalDemandingAuth $actUrl)) {
        $res.IsCaptive = $true
        $res.Error = 'PortalDemandsAuth'
        return $res
    }
    $req = $null; $resp = $null
    try {
        $req = [System.Net.HttpWebRequest]::Create('https://1.1.1.1/cdn-cgi/trace')
        $req.Timeout = $TimeoutMs
        $req.ReadWriteTimeout = $TimeoutMs
        $req.AllowAutoRedirect = $false
        $req.Proxy = $null
        $req.UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) LanFixer-Probe'
        $req.ServerCertificateValidationCallback = {
            param($sender, $cert, $chain, $sslErrors)
            if ($cert) { $script:LastProbeCertSubject = [string]$cert.Subject }
            return ($sslErrors -eq [System.Net.Security.SslPolicyErrors]::None)
        }
        if ($SourceIp) {
            $ipObj = $null
            if ([System.Net.IPAddress]::TryParse($SourceIp, [ref]$ipObj)) {
                $req.ServicePoint.BindIPEndPointDelegate = {
                    param($servicePoint, $remoteEndPoint)
                    return New-Object System.Net.IPEndPoint($ipObj, 0)
                }
            }
        }
        $resp = $req.GetResponse() -as [System.Net.HttpWebResponse]
        if ($resp -and [int]$resp.StatusCode -eq 200) {
            $res.Ok = $true
        } else {
            $res.IsCaptive = $true
            $res.Error = "Http_$([int]$resp.StatusCode)"
        }
    } catch [System.Net.WebException] {
        $wex = $_.Exception
        $res.Error = $wex.Message
        if ($wex.Status -eq [System.Net.WebExceptionStatus]::TrustFailure) {
            $res.IsCaptive = $true
            $res.CertSubject = [string]$script:LastProbeCertSubject
        } elseif ($wex.Response) {
            $wResp = $wex.Response -as [System.Net.HttpWebResponse]
            if ($wResp) {
                $c = [int]$wResp.StatusCode
                if (($c -ge 300 -and $c -le 399) -or $c -eq 401 -or $c -eq 407 -or $c -eq 511) {
                    $res.IsCaptive = $true
                }
            }
        } elseif ($wex.Status -eq [System.Net.WebExceptionStatus]::Timeout -or $wex.Status -eq [System.Net.WebExceptionStatus]::ConnectFailure) {
            $res.IsCaptive = $true
        }
    } catch {
        $res.Error = $_.Exception.Message
    } finally {
        if ($resp) { try { $resp.Close() } catch {} }
    }
    return $res
}""",
            """function Test-IsPortalDemandingAuth([string]$PortalUrl = '', [string]$SourceIp = '') {
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
    $sock = $null; $ssl = $null; $iar = $null
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
        if ($iar -and $iar.AsyncWaitHandle) { try { $iar.AsyncWaitHandle.Close() } catch {} }
        if ($ssl) { try { $ssl.Dispose() } catch {} }
        if ($sock) { try { $sock.Close(); $sock.Dispose() } catch {} }
    }
    return $false
}
function Test-HttpsWanProbe([string]$SourceIp = '', [int]$TimeoutMs = 1800) {
    $res = @{ Ok = $false; IsCaptive = $false; Error = ''; CertSubject = '' }
    foreach ($wanIp in @('1.1.1.1', '9.9.9.9')) {
        $sock = $null; $ssl = $null; $iar = $null
        try {
            $sock = New-Object System.Net.Sockets.Socket([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
            if ($SourceIp) {
                try { $sock.Bind((New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($SourceIp), 0))) } catch { $res.Error = 'BindFailure'; return $res }
            }
            $iar = $sock.BeginConnect([System.Net.IPAddress]::Parse($wanIp), 443, $null, $null)
            if (-not $iar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)) { $res.Error = 'Timeout'; continue }
            $sock.EndConnect($iar)
            $ns = New-Object System.Net.Sockets.NetworkStream($sock, $false)
            $ns.ReadTimeout = $TimeoutMs; $ns.WriteTimeout = $TimeoutMs
            $cap = @{ Errors = ''; Subject = '' }
            $cb = {
                param($sender, $cert, $chain, $errs)
                $cap.Errors = [string]$errs
                if ($cert) { $cap.Subject = [string]$cert.Subject }
                return ([string]$errs -eq 'None')
            }.GetNewClosure()
            $ssl = New-Object System.Net.Security.SslStream($ns, $false, ([System.Net.Security.RemoteCertificateValidationCallback]$cb))
            $protocols = [System.Security.Authentication.SslProtocols]::Tls12
            try { $protocols = [System.Security.Authentication.SslProtocols]'Tls12, Tls13' } catch {}
            $ssl.AuthenticateAsClient($wanIp, $null, $protocols, $false)
            $res.Ok = $true
            $res.Error = ''
            return $res
        } catch {
            $res.Error = $_.Exception.Message
            if ($cap -and $cap.Errors -and $cap.Errors -ne 'None') {
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
}""",
            "Fix Test-IsPortalDemandingAuth and Test-HttpsWanProbe"
        )

    # 7. Fix Start-AutonomousDaemon CimInstance -> Uri cast error & Get-Telemetry subnet properties
    raw = raw.replace("Ensure-CampusPortalPath $ad", "Ensure-CampusPortalPath")
    raw = raw.replace(
        """                $sub = Get-SubnetInfoFromLease $ad
                if ($sub -and $sub.Prefix) {
                    $t.SubnetPrefix = [int]$sub.Prefix
                    $t.SubnetMask = [string]$sub.Mask
                    $t.SubnetHosts = [int64]$sub.Total
                }""",
        """                $sub = Get-SubnetInfoFromLease $ad
                if ($sub -and $sub.PrefixLength) {
                    $t.SubnetPrefix = [int]$sub.PrefixLength
                    $t.SubnetMask = [string]$sub.SubnetMask
                    $t.SubnetHosts = [int64]$sub.TotalHosts
                }"""
    )

    # 8. Fix Update-LinkQualityMonitor property names & Invoke-GuidedRecovery confirmations
    raw = raw.replace("$st.ReceivedPacketDiscards", "$st.ReceivedDiscardedPackets")
    raw = raw.replace("$st.OutboundPacketDiscards", "$st.OutboundDiscardedPackets")
    raw = raw.replace(
        """    if ($h -match '^[A-Za-z0-9.-]+$' -and -not $script:IsDry) {\r
        $res = Resolve-HostBounded $h 1000\r
        if ($res -and (Test-AllowedPortalIp $res)) { return $true }\r
    }\r
    return $false""",
        "    return $false"
    )

    # 9. Carefully compact consecutive blank lines (>2 blank lines -> 1 blank line)
    raw_clean = re.sub(r"(\r\n){3,}", "\r\n\r\n", raw.replace("\r\r\n", "\r\n").replace("\r\n", "\n").replace("\n", "\r\n"))
    data = raw_clean.encode("ascii")
    assert all(b <= 127 for b in data), "Non-ASCII bytes detected"
    assert b"\n" not in data.replace(b"\r\n", b""), "Solo LF detected"
    new_lines = raw_clean.count("\r\n")
    primary.write_bytes(data)

    # Verify AST via Windows PowerShell
    ast_cmd = [
        "powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command",
        f"$e=$null; [void][System.Management.Automation.Language.Parser]::ParseFile('{primary.resolve()}',[ref]$null,[ref]$e); if($e.Count -gt 0){{ $e | ForEach-Object {{ Write-Error $_.ToString() }}; exit 1 }}"
    ]
    res_ast = subprocess.run(ast_cmd, capture_output=True, text=True)
    if res_ast.returncode != 0:
        raise RuntimeError(f"AST Verification Failed:\n{res_ast.stderr}\n{res_ast.stdout}")

    # Verify SelfTest
    st_cmd = ["cmd.exe", "/c", str(primary.resolve()), "-Mode", "SelfTest", "-DryRun", "-NoPause", "-Quiet"]
    res_st = subprocess.run(st_cmd, capture_output=True, text=True)
    if res_st.returncode != 0 or " 0 failures" not in res_st.stdout:
        raise RuntimeError(f"SelfTest Failed (exit={res_st.returncode}):\n{res_st.stdout}\n{res_st.stderr}")

    for m in ("LanFixer.cmd", "NetFix.cmd"):
        mp = Path(m)
        if mp.exists() or m == "LanFixer.cmd":
            mp.write_bytes(data)

    print(f"SUCCESS: Optimized & Hardened v7.0.2 | Lines: {orig_lines} -> {new_lines} | Bytes: {orig_bytes} -> {len(data)} | AST Errors: 0 | SelfTest: 100% PASSED | SHA256: {hashlib.sha256(data).hexdigest()}")

except Exception as ex:
    shutil.copy2(backup_path, primary)
    print(f"ROLLED BACK to backup ({backup_path.name}) due to error:\n{ex}")
    sys.exit(1)