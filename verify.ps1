# verify.ps1 - Invariant & SelfTest Verifier for LanFixer
# Mandatory Real Runtime: Windows PowerShell 5.1 (Primary) + pwsh 7 (Secondary)
param(
    [string]$TargetFile = (Join-Path $PSScriptRoot 'LanFixer.cmd')
)

$ErrorActionPreference = 'Stop'
Write-Host ('=' * 80) -ForegroundColor Cyan
Write-Host ('LANFIXER FORMAL VERIFIER (Windows PowerShell 5.1 Runtime)') -ForegroundColor Cyan
Write-Host ('Target: ' + $TargetFile) -ForegroundColor Cyan
Write-Host ('=' * 80) -ForegroundColor Cyan

# Rule R1: Print $PSVersionTable
Write-Host '--- Runtime Environment ($PSVersionTable) ---' -ForegroundColor Magenta
$PSVersionTable.GetEnumerator() | Sort-Object Name | ForEach-Object {
    Write-Host ('  {0,-25} : {1}' -f $_.Key, $_.Value) -ForegroundColor Gray
}
Write-Host ''

if (-not (Test-Path -LiteralPath $TargetFile)) {
    Write-Host ('ERROR: Target file does not exist: ' + $TargetFile) -ForegroundColor Red
    exit 1
}

$rawBytes = [System.IO.File]::ReadAllBytes($TargetFile)
$fail = $false

# Invariant 2: 100% 7-bit ASCII & strict CRLF (no bare LF, no bare CR)
Write-Host '[1/5] Invariant 2: 100% 7-bit ASCII (0-127) and strict CRLF...' -NoNewline
$nonAscii = 0
$bareLf = 0
$bareCr = 0
$len = $rawBytes.Length

for ($i = 0; $i -lt $len; $i++) {
    $b = $rawBytes[$i]
    if ($b -gt 127) { $nonAscii++ }
    if ($b -eq 10) { # LF
        if ($i -eq 0 -or $rawBytes[$i - 1] -ne 13) { $bareLf++ }
    }
    if ($b -eq 13) { # CR
        if ($i -eq ($len - 1) -or $rawBytes[$i + 1] -ne 10) { $bareCr++ }
    }
}

if ($nonAscii -eq 0 -and $bareLf -eq 0 -and $bareCr -eq 0) {
    Write-Host ' PASS' -ForegroundColor Green
} else {
    Write-Host ' FAIL' -ForegroundColor Red
    Write-Host ('  Non-ASCII bytes: ' + $nonAscii) -ForegroundColor Yellow
    Write-Host ('  Bare LF: ' + $bareLf) -ForegroundColor Yellow
    Write-Host ('  Bare CR: ' + $bareCr) -ForegroundColor Yellow
    $fail = $true
}

# Invariant 3: AST Syntax Integrity on Windows PowerShell 5.1
Write-Host '[2/5] Invariant 3a: Windows PowerShell 5.1 AST ParseFile...' -NoNewline
$tokens51 = $null
$parseErrors51 = $null
$ast51 = [System.Management.Automation.Language.Parser]::ParseFile($TargetFile, [ref]$tokens51, [ref]$parseErrors51)

if ($parseErrors51.Count -eq 0) {
    Write-Host (' PASS (0 parse errors, ' + $tokens51.Count + ' tokens)') -ForegroundColor Green
} else {
    Write-Host (' FAIL (' + $parseErrors51.Count + ' parse errors)') -ForegroundColor Red
    foreach ($err in $parseErrors51) {
        Write-Host ('  Line ' + $err.Extent.StartLineNumber + ': ' + $err.Message) -ForegroundColor Yellow
    }
    $fail = $true
}

# Invariant 3b: pwsh 7 AST ParseFile (Secondary Check)
Write-Host '[2/5] Invariant 3b: pwsh 7 AST ParseFile...' -NoNewline
$pwshPath = (Get-Command pwsh.exe -ErrorAction SilentlyContinue)
if ($pwshPath) {
    $pwshPsi = New-Object System.Diagnostics.ProcessStartInfo
    $pwshPsi.FileName = 'pwsh.exe'
    $targetEsc = $TargetFile.Replace("'", "''")
    $pwshPsi.Arguments = "-NoProfile -Command `"`$t=`$null; `$e=`$null; [void][System.Management.Automation.Language.Parser]::ParseFile('$targetEsc', [ref]`$t, [ref]`$e); if (`$e.Count -eq 0) { exit 0 } else { exit `$e.Count }`""
    $pwshPsi.UseShellExecute = $false
    $pwshPsi.CreateNoWindow = $true
    $p7 = [System.Diagnostics.Process]::Start($pwshPsi)
    [void]$p7.WaitForExit(10000)
    if ($p7.ExitCode -eq 0) {
        Write-Host ' PASS (0 errors)' -ForegroundColor Green
    } else {
        Write-Host (' FAIL (ExitCode: ' + $p7.ExitCode + ')') -ForegroundColor Red
        $fail = $true
    }
} else {
    Write-Host ' SKIPPED (pwsh.exe not found)' -ForegroundColor Yellow
}

# Invariant 4: No Duplicate Functions & Count Tracking
Write-Host '[3/5] Invariant 4: Function declarations and uniqueness...' -NoNewline
$functionAsts = $ast51.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)
$funcNames = @{}
$duplicates = @()

foreach ($f in $functionAsts) {
    $name = $f.Name.ToLowerInvariant()
    if ($funcNames.ContainsKey($name)) {
        $duplicates += $f.Name
    } else {
        $funcNames[$name] = $f
    }
}

if ($duplicates.Count -eq 0) {
    Write-Host (' PASS (' + $functionAsts.Count + ' unique functions, 0 duplicates)') -ForegroundColor Green
} else {
    Write-Host (' FAIL (' + $duplicates.Count + ' duplicates found)') -ForegroundColor Red
    foreach ($d in $duplicates) {
        Write-Host ('  Duplicate function: ' + $d) -ForegroundColor Yellow
    }
    $fail = $true
}

# Size & Line Metrics
$text = [System.Text.Encoding]::ASCII.GetString($rawBytes)
$lines = $text -split "`r?`n"
Write-Host ('  File size: ' + $len + ' bytes | Lines: ' + $lines.Count + ' | Functions: ' + $functionAsts.Count) -ForegroundColor Gray

# Startup Time Measurement (S0 requirement)
Write-Host '[4/5] Performance: Measuring cold startup & compilation time (powershell 5.1)...' -NoNewline
$swStart = [System.Diagnostics.Stopwatch]::StartNew()
$psiStartup = New-Object System.Diagnostics.ProcessStartInfo
$psiStartup.FileName = 'powershell.exe'
$psiStartup.Arguments = "-NoProfile -ExecutionPolicy Bypass -Command `"& '$targetEsc' -Mode QuickProbe -DryRun`""
$psiStartup.RedirectStandardOutput = $true
$psiStartup.RedirectStandardError = $true
$psiStartup.UseShellExecute = $false
$psiStartup.CreateNoWindow = $true
$procStart = [System.Diagnostics.Process]::Start($psiStartup)
[void]$procStart.StandardOutput.ReadToEnd()
[void]$procStart.WaitForExit(15000)
$swStart.Stop()
Write-Host (' {0} ms (ExitCode {1})' -f $swStart.ElapsedMilliseconds, $procStart.ExitCode) -ForegroundColor Gray

# Invariant 5 & SelfTest Execution on powershell.exe 5.1
Write-Host '[5/5] Invariant 5: Running SelfTest -DryRun on Windows PowerShell 5.1...'
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = 'powershell.exe'
$pinfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -Command `"& '$targetEsc' -Mode SelfTest -DryRun`""
$pinfo.RedirectStandardOutput = $true
$pinfo.RedirectStandardError = $true
$pinfo.UseShellExecute = $false
$pinfo.CreateNoWindow = $true

$proc = [System.Diagnostics.Process]::Start($pinfo)
$stdout = $proc.StandardOutput.ReadToEnd()
$stderr = $proc.StandardError.ReadToEnd()
[void]$proc.WaitForExit(45000)
$exitCode = $proc.ExitCode

$checksPassed = ([regex]::Matches($stdout, '(?m)^\s*\+\s+')).Count
$checksWarned = ([regex]::Matches($stdout, '(?m)^\s*!\s+')).Count
$checksFailed = ([regex]::Matches($stdout, '(?m)^\s*[xX]\s+')).Count

Write-Host ('  Checks passed: ' + $checksPassed + ' | Warnings: ' + $checksWarned + ' | Failures: ' + $checksFailed) -ForegroundColor Gray
if ($exitCode -eq 0 -and $checksFailed -eq 0) {
    Write-Host '  SelfTest Status: PASS' -ForegroundColor Green
} else {
    Write-Host ('  SelfTest Status: FAIL (ExitCode: ' + $exitCode + ', Failures: ' + $checksFailed + ')') -ForegroundColor Red
    $fail = $true
}

Write-Host ('=' * 80) -ForegroundColor Cyan
if ($fail) {
    Write-Host 'OVERALL VERIFICATION: FAILED' -ForegroundColor Red
    exit 1
} else {
    Write-Host 'OVERALL VERIFICATION: PASSED (ALL INVARIANTS SATISFIED)' -ForegroundColor Green
    exit 0
}
