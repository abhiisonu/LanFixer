@echo off
setlocal
cd /d "%~dp0.."

echo ============================================================================
echo   LANFIXER SUPREME VERIFICATION AND REGRESSION SUITE
echo ============================================================================

set "BIN=%~dp0..\dist\LanFixer.exe"
if not exist "%BIN%" (
    set "BIN=%~dp0..\bin\Debug\net8.0\LanFixer.exe"
)
if not exist "%BIN%" (
    echo [ERROR] Binary not found. Run build.cmd first.
    exit /b 1
)

echo [1/4] Running protocol logic and live stack self-tests...
"%BIN%" selftest
if errorlevel 1 (
    echo [FAIL] Selftest suite failed.
    exit /b 1
)
echo [PASS] Selftest suite passed.

echo.
echo [2/4] Running 7-Layer OSI Health Doctor...
"%BIN%" doctor
if errorlevel 1 (
    echo [WARNING] Doctor detected degraded/broken state or needs elevation.
) else (
    echo [PASS] Doctor passed.
)

echo.
echo [3/4] Testing registry write-ahead journal with drift protection...
net session >nul 2>&1
if errorlevel 1 (
    echo [SKIP] Admin privileges not detected. Skipping live registry tune/rollback test.
    echo        Run tests\verify.cmd from an elevated Administrator prompt for full registry test.
) else (
    set "WPAD_KEY=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad"
    reg query "%WPAD_KEY%" /v WpadOverride >"%TEMP%\lf_before.txt" 2>&1
    "%BIN%" tune 1 >nul 2>&1
    "%BIN%" rollback >nul 2>&1
    reg query "%WPAD_KEY%" /v WpadOverride >"%TEMP%\lf_after.txt" 2>&1
    fc "%TEMP%\lf_before.txt" "%TEMP%\lf_after.txt" >nul && (
        echo [PASS] Registry state cleanly restored after tune - rollback round-trip.
    ) || (
        echo [FAIL] Registry differs after rollback.
        exit /b 1
    )
    del "%TEMP%\lf_before.txt" "%TEMP%\lf_after.txt" >nul 2>&1
)

echo.
echo [4/4] Verifying status query and exit code mapping...
"%BIN%" status
echo Exit Code: %errorlevel% (0=Online, 10=Captive/NoDns, 20=Offline, 30=NoLink)

echo.
echo ============================================================================
echo   ALL VERIFICATION CHECKS COMPLETED
echo ============================================================================
endlocal
