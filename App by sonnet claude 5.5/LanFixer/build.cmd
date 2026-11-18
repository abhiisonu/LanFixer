@echo off
rem Needs: .NET 8 SDK + Visual Studio Build Tools "Desktop development with C++" (Native AOT linker)
where dotnet >nul 2>&1 || (echo .NET 8 SDK not found & exit /b 1)
dotnet publish LanFixer.csproj -c Release -r win-x64 -o dist || exit /b 1
echo.& echo Built: %~dp0dist\LanFixer.exe  (single native exe, no runtime needed)
