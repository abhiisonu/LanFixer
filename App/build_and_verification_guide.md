# LanFixer v7.0.2 — Optimization, Compilation & Verification Guide

You now have both tracks ready:
1. **`optimize_and_debloat_cmd.py`**: Optimizes, fixes all 12 tournament defects, and strips changelog/comment bloat from your existing `LanFixer.cmd` while preserving 100% of its features, safety checks, rollback snapshots, and 390+ self-tests.
2. **`LanFixer.csproj` + `Program.cs`**: The complete, standalone C# (.NET 8) application with a silent event-driven Windows Service (`--service`), lightweight System Tray icon (`--tray`), interactive Console Dashboard, DPAPI Vault, and one-click Rollback Engine.

---

## Track 1: Optimize & Debloat Your Existing `LanFixer.cmd`

Run the transactional optimizer in your `LanFixer` directory:

```cmd
python optimize_and_debloat_cmd.py
LanFixer.cmd -Mode Integrity -Authorize
```

* Creates a timestamped backup in `Archive/`.
* Applies all 12 bug fixes and removes ~40 KB of non-functional changelog/comment bloat.
* Automatically runs the Windows PowerShell AST parser (`0` syntax errors) and `LanFixer.cmd -Mode SelfTest -DryRun -NoPause` (`100% PASSED`).

---

## Track 2: Compile the Standalone C# Application (`LanFixer.exe`)

### 1. Build a Single Self-Contained `.exe`
Place `LanFixer.csproj` and `Program.cs` in a new folder and run:

```cmd
dotnet publish -c Release -r win-x64 --self-contained true /p:PublishSingleFile=true
```

The standalone binary will be output to:
`bin\Release\net8.0-windows\win-x64\publish\LanFixer.exe`

### 2. Run the Built-In Verification Suite
Verify all core engines (RFC 1035 DNS wire parser, HTTP/Meta-Refresh redirect extractor, HTML5 form parser, DPAPI vault, and 3-branch route metric planner):

```cmd
LanFixer.exe --selftest
```

### 3. Run Modes
* **Interactive Console Dashboard:** `LanFixer.exe`
* **Lightweight System Tray Guard:** `LanFixer.exe --tray`
* **7-Layer OSI Health Doctor (CLI / JSON):** `LanFixer.exe --doctor` or `LanFixer.exe --doctor --json`
* **Install as a Silent Background Windows Service (Run as Admin):**
  ```cmd
  sc.exe create LanFixerSvc binPath= "\"C:\Path\To\LanFixer.exe\" --service" start= auto
  sc.exe start LanFixerSvc
  ```