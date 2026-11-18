@echo off
rem Run from an ELEVATED prompt after build.cmd. Proves tests + rollback on the real registry.
net session >nul 2>&1 || (echo Run as Administrator & exit /b 1)
set X=%~dp0..\dist\LanFixer.exe
set K=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad
echo [1] built-in self test (logic + live)& "%X%" selftest || (echo FAIL & exit /b 1)
echo [2] tune/rollback round-trip on a real value
reg query "%K%" /v WpadOverride >"%TEMP%\lf_before.txt" 2>&1
"%X%" tune 1 & reg query "%K%" /v WpadOverride
"%X%" rollback
reg query "%K%" /v WpadOverride >"%TEMP%\lf_after.txt" 2>&1
fc "%TEMP%\lf_before.txt" "%TEMP%\lf_after.txt" >nul && (echo PASS: registry identical after rollback) || (echo FAIL: registry differs & exit /b 1)
echo [3] restore-original path& "%X%" tune 1 >nul & "%X%" restore --yes
echo [4] status / exit codes& "%X%" status & echo exit=%errorlevel% (0 online, 10 captive/no-dns, 20 offline, 30 no link)
echo ALL SCRIPTED CHECKS DONE. Now run the manual checks in README.md section 5.
