@echo off
setlocal
cd /d "%~dp0"

echo ============================================================================
echo   LANFIXER SUPREME v8.5 BUILD SCRIPT
echo ============================================================================

where dotnet >nul 2>&1 || (
    echo [ERROR] .NET 8 SDK is required and was not found in PATH.
    echo Please install the .NET 8 SDK or add dotnet to your system PATH.
    exit /b 1
)

echo [*] Compiling LanFixer Supreme into release binary...
dotnet build LanFixer.csproj -c Release --no-restore -o dist
if errorlevel 1 (
    echo [!] Initial build failed. Attempting restore...
    dotnet restore LanFixer.csproj
    dotnet build LanFixer.csproj -c Release -o dist
    if errorlevel 1 (
        echo [ERROR] Build failed.
        exit /b 1
    )
)

echo.
echo ============================================================================
echo   BUILD SUCCEEDED
echo   Executable : %~dp0dist\LanFixer.exe
echo   Usage      : dist\LanFixer.exe [dash ^| tray ^| doctor ^| status ^| selftest]
echo ============================================================================
endlocal
