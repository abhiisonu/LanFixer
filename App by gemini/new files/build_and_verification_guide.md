# Forensic Audit of Your `App.zip` & Single-File `.exe` Build Guide

## 1. What Was Found in Your `App.zip` Archive
Inspecting the 78 entries in your `App.zip` revealed why `App/publish/` had **6 separate files** instead of a single `.exe`:
* `App/publish/LanFixer.exe` (`151,552 bytes`) was only the thin `.NET apphost` stub, and your logic was sitting outside it in `LanFixer.dll` (`75,264 bytes`) alongside `System.ServiceProcess.ServiceController.dll` (`149,288 bytes`), `LanFixer.pdb`, `LanFixer.deps.json`, and `LanFixer.runtimeconfig.json`.
* **Root Cause:** Without `<IncludeAllContentForSelfExtract>true</IncludeAllContentForSelfExtract>` and `<DebugType>none</DebugType>` in `LanFixer.csproj`, .NET leaves managed DLLs and debug symbols beside the executable.
* **What Was Upgraded:**
  1. **`LanFixer.csproj`**: Added `<IncludeAllContentForSelfExtract>true</IncludeAllContentForSelfExtract>` and disabled `.pdb` emission so `dotnet publish` packs **100% of your code and all DLLs into one single `LanFixer.exe` file**.
  2. **`Program.cs`**: Upgraded to the complete `v7.0.2` engine with cross-process `Global\LanFixer_Lock` mutex synchronization, source-bound `SocketsHttpHandler.ConnectCallback` (so captive portal logins never leak over Wi-Fi), Layer 3 Subnet Calculus (`/8` to `/32`), Path MTU Discovery (`1500`/`1492`/`1420`), source-scoped RFC 1035 UDP DNS resolution, the full 6-tier risk-ordered recovery menu, and built-in `--install-service` / `--uninstall-service` commands.

---

## 2. Clean Up & Build the Single `LanFixer.exe`

Open a terminal inside your `App` folder and run:

```cmd
del /q optimize_and_debloat_cmd.py build_and_verification_guide.md 2>nul
rmdir /s /q bin obj publish 2>nul
dotnet publish -c Release -o publish
```

After running this command, look inside `App\publish\`—you will see **only one single file: `LanFixer.exe`** (zero `.dll`, `.pdb`, or `.json` files). You can copy that single `LanFixer.exe` anywhere and delete the rest of the project folder if you only want the executable.

---

## 3. Verify & Run

```cmd
publish\LanFixer.exe --selftest
publish\LanFixer.exe
```

* **Interactive Dashboard:** `LanFixer.exe`
* **System Tray Guard:** `LanFixer.exe --tray`
* **Install Silent 24/7 Background Service (Run as Admin):** `LanFixer.exe --install-service`
* **7-Layer Health Doctor:** `LanFixer.exe --doctor`