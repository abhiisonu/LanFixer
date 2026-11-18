# LanFixer Supreme v8.5

**Dual-Core Autonomous Windows Network Guardian & Captive Portal Engine**  
*The unified supreme synthesis of zero-dependency native engineering and battle-tested campus network resilience.*

---

## 1. Architectural Highlights

LanFixer Supreme combines the best engineering from two independent branches:
- **From the Modular Native Architecture (Sonnet 5.5)**:
  - Clean separation of concerns across single-responsibility modules (`Core`, `N`, `Net`, `Portal`, `Doctor`, `Engine`, `Host`, `Ui`, `SelfTest`).
  - Pure Win32 system tray icon (`Shell_NotifyIconW` + standard message loop) with zero runtime dependencies.
  - LocalSystem background Windows Service using Win32 SCM P/Invoke with no reliance on `System.ServiceProcess.dll`.
  - Transactional write-ahead journal (`state.json`) with drift protection and single-run undo.
  - Hardware-bound DPAPI machine credential vault with PBKDF2/AES entropy.
  - Zero-allocation source-generated JSON serialization (`System.Text.Json.SourceGeneration`).

- **From the Battle-Tested Campus Engine (Gemini)**:
  - **pfSense Port 8888 Preservation**: Complete support for captive portal gateways serving on non-standard ports (e.g. `https://10.114.0.5:8888/`) without stripping ports or falling back to closed port 443.
  - **Dual-Verification Egress Probe**: Detects captive portals that silently drop or RST outbound HTTPS SYN packets, preventing false "Online" verdicts.
  - **7-Layer OSI Health Doctor**: Comprehensive diagnosis across physical link, subnet bounds, default gateway, UDP DNS racer, HTTP probe, TLS WAN handshake, and captive portal state.
  - **Route Metric Shield**: Automatic metric arbitration preventing secondary or virtual adapters from usurping default gateway routes.
  - **Subnet Calculus Engine**: Bitwise subnet math computing CIDR prefix, wildcard mask, network address, broadcast address, and host capacities.

---

## 2. Directory Structure

```text
LanFixer-Supreme/
├── LanFixer.csproj           # Standalone .NET 8 project (zero external NuGet packages)
├── app.manifest              # Windows compatibility manifest (PerMonitorV2 DPI, Windows 10/11 GUIDs)
├── build.cmd                 # Offline single-command release compiler
├── tests/
│   └── verify.cmd            # Automated 4-tier verification and regression harness
└── src/
    ├── Program.cs            # CLI router & command dispatcher
    ├── Core.cs               # Write-ahead store, DPAPI vault, process runner, JSON contexts
    ├── N.cs                  # Native Win32 P/Invoke interop (DPAPI, SCM, Power, VSS, VT100)
    ├── Net.cs                # Subnet calculus, UDP DNS racer, PMTUD, dual egress probe
    ├── Portal.cs             # Captive portal engine, TLS raw stream probe, HTML5 form parser
    ├── Doctor.cs             # 7-Layer OSI Health Doctor with ANSI & JSON reporting
    ├── Engine.cs             # 6-Tier recovery hierarchy, route metric shield, debloat engine
    ├── Host.cs               # Event-driven background service, named-pipe IPC server
    ├── Ui.cs                 # Pure Win32 system tray & ANSI sparkline live dashboard
    └── SelfTest.cs           # 50+ unit tests covering protocols, subnet math, and live OS stack
```

---

## 3. CLI Command Reference

| Command | Description | Elevated? |
|---|---|:---:|
| `LanFixer.exe` or `dash` | Interactive live ANSI dashboard with sparkline latency history & hotkeys | No |
| `LanFixer.exe tray` | Launch pure Win32 system tray notification icon | No |
| `LanFixer.exe doctor [--json]` | Run 7-layer OSI deep health diagnostic report | No |
| `LanFixer.exe status [--json]` | Query network status (0=Online, 10=Captive/NoDns, 20=Offline, 30=NoLink) | No |
| `LanFixer.exe bench` or `speed` | Multi-target Anycast latency, jitter, loss & UDP DNS benchmark | No |
| `LanFixer.exe mtu` | Path MTU discovery & automatic bottleneck MTU clamping | Yes |
| `LanFixer.exe pnp` | Enforce hardware NDIS power-save shield (disable NIC sleep/drops) | Yes |
| `LanFixer.exe bundle` or `report` | Generate comprehensive sanitized diagnostic bundle JSON | No |
| `LanFixer.exe keepalive` | Send session refresh pulse to prevent portal timeout logouts | No |
| `LanFixer.exe repair` | Run escalating 3-tier repair (Flush -> DNS -> Adapter reset + Route Shield) | Yes |
| `LanFixer.exe reset [--yes]` | Winsock & TCP/IP stack rebuild (creates netsh backup + Restore Point) | Yes |
| `LanFixer.exe rollback` | Undo the last network configuration change (with drift protection) | Yes |
| `LanFixer.exe restore [--yes]` | Revert all parameters to factory baseline Windows settings | Yes |
| `LanFixer.exe login` | Manually trigger immediate captive portal authentication | Yes |
| `LanFixer.exe tune [1\|2]` | Apply network debloat (Tier 1 safe / Tier 2 aggressive) | Yes |
| `LanFixer.exe audit` | Read-only inspection of tuning vectors and current values | No |
| `LanFixer.exe cred set` | Store captive portal credentials in DPAPI vault | Yes |
| `LanFixer.exe cred show` | View stored credential metadata (password masked) | No |
| `LanFixer.exe cred pin` | Inspect and pin portal TLS certificate SHA-256 fingerprint | Yes |
| `LanFixer.exe cred clear` | Erase stored credentials and delete vault | Yes |
| `LanFixer.exe install` | Register and start background Windows Service + tray autostart | Yes |
| `LanFixer.exe uninstall` | Stop and remove Windows Service (`--purge` deletes logs and vault) | Yes |
| `LanFixer.exe selftest [--logic]` | Run comprehensive test suite (protocol logic + live OS stack) | No |

---

## 4. Interactive Console Dashboard Hotkeys

While running `LanFixer.exe dash` (or running with no arguments):
- `[R]` **Repair**: Trigger escalating 3-tier repair with route shield enforcement.
- `[L]` **Login**: Force immediate captive portal authentication.
- `[D]` **Doctor**: Open full 7-Layer OSI health report in-console.
- `[S]` **Speed/Bench**: Run live multi-target Anycast latency & jitter benchmark.
- `[M]` **MTU**: Run Path MTU discovery sweep and optimal clamping.
- `[P]` **PnP Shield**: Enforce hardware NDIS sleep blocker on network adapters.
- `[K]` **Keep-Alive**: Send session keep-alive heartbeat pulse.
- `[E]` **Export Bundle**: Generate sanitized diagnostics bundle JSON for IT support.
- `[T]` **Tune**: Apply Tier 1 safe network debloat.
- `[B]` **Rollback**: Undo last setting change with write-ahead drift protection.
- `[O]` **Restore**: Return all parameters to original Windows defaults.
- `[X]` **Stack Reset**: Rebuild TCP/IP and Winsock stack (requires confirmation).
- `[Q]` **Quit**: Exit dashboard cleanly.

---

## 4. Building and Verifying

### Prerequisites
- .NET 8.0 SDK or later installed.
- Zero external NuGet packages needed (builds 100% offline).

### Build Release Binary
```cmd
build.cmd
```
The output binary will be created at `dist\LanFixer.exe`.

### Run Verification Suite
```cmd
tests\verify.cmd
```
From an elevated command prompt, this executes:
1. Protocol & logic unit tests + live Windows stack probes.
2. 7-layer OSI Health Doctor diagnostic run.
3. Live registry write-ahead journal tune/rollback round-trip test.
4. Granular status exit-code mapping.
