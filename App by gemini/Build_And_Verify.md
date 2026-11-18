# LanFixer v7.0.2 — C# Standalone Application Guide

## 1. Overview
The C# application in `App by gemini/` is a modern, standalone Windows networking utility featuring:
- **Autonomous Captive Detection**: Eliminates HTTP 204 false-positives by actively probing the captive portal (`https://10.114.0.5:8888/`) for login forms (`passwordfld`/`usernamefld`).
- **6-Tier Risk-Ordered Recovery**: Debloat, Network Defaults, 5-Stage Stack Reset, Deep 10-Stage Rebuild, 12-Stage Adapter Reinstall, and 4-Stage Netcfg Device Wipe.
- **DPAPI Vault & Headless Login**: Hardware/User-bound credential encryption and source-scoped authentication so credentials never leak across secondary Wi-Fi uplinks.
- **System Tray Guard & Background Watchdog**: Event-driven network change listeners (`NetworkChange.NetworkAddressChanged`) with color-coded status tray icons.
- **14 Built-In Unit Tests**: Wire-level RFC 1035 DNS parser, Subnet calculus, HTML5 form parsing, and route metric arbitration.

---

## 2. Quick Run (Pre-Compiled Binary)
The compiled binary is ready in:
📁 `publish\LanFixer.exe`

```cmd
cd "C:\Users\ABHISHEK SONU\Desktop\Lan Fixer\App by gemini"
publish\LanFixer.exe
```

### Command Modes
* **Interactive Console Dashboard**: `publish\LanFixer.exe`
* **System Tray Guard (Taskbar icon)**: `publish\LanFixer.exe --tray`
* **7-Layer Network Health Doctor**: `publish\LanFixer.exe --doctor` (or `--doctor --json`)
* **Store Campus Credentials**: `publish\LanFixer.exe --vault <USERNAME> <PASSWORD>`
* **Execute Headless Sign-In**: `publish\LanFixer.exe --login`
* **Run 14-Check Verification Self-Test**: `publish\LanFixer.exe --selftest`
* **Install 24/7 Silent Background Service (Admin)**: `publish\LanFixer.exe --install-service`

---

## 3. How to Recompile
From `App by gemini`:
```cmd
dotnet publish -c Release -o publish
```
This builds against local .NET SDK assemblies in seconds with 0 warnings and 0 errors.
