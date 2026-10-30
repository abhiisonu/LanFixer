# LanFixer

<div align="center">

**Autonomous Single-File Network Stabilization & Captive Portal Engine for Windows**

[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6?style=flat-square&logo=windows)](https://github.com/abhiisonu/LanFixer)
[![Architecture](https://img.shields.io/badge/Arch-x64%20%7C%20ARM64%20%7C%20x86-0A84FF?style=flat-square)](https://github.com/abhiisonu/LanFixer)
[![Runtime](https://img.shields.io/badge/Engine-PowerShell%205.1%2B%20%7C%20Batch%20Polyglot-172B4D?style=flat-square)](https://github.com/abhiisonu/LanFixer)
[![Dependencies](https://img.shields.io/badge/Dependencies-0%20External%20Binaries-2ea44f?style=flat-square)](https://github.com/abhiisonu/LanFixer)
[![Encoding](https://img.shields.io/badge/Encoding-100%25%20Pure%20ASCII-586069?style=flat-square)](https://github.com/abhiisonu/LanFixer)
[![Security](https://img.shields.io/badge/Vault-Windows%20DPAPI%20Encrypted-critical?style=flat-square&logo=shield)](https://github.com/abhiisonu/LanFixer)
[![Self-Test](https://img.shields.io/badge/Logic%20Tests-186%20Assertions%20Passing-brightgreen?style=flat-square)](https://github.com/abhiisonu/LanFixer)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)

[Quickstart](#quickstart) &bull;
[The Problem](#the-problem-what-breaks-on-windows) &bull;
[Deep Architecture](#architecture-the-7-layer-stabilization-pipeline) &bull;
[TUI Showcase](#live-console-control-center) &bull;
[CLI Reference](#command-line--headless-automation) &bull;
[Verification](#forensic-verification--self-test-suite)

</div>

---

## Overview

**LanFixer** is a single-file, zero-dependency network repair and resilience utility built exclusively for Windows 10 and 11. Designed as a **deep module**, it exposes a lean, ergonomic interface while encapsulating an industrial-grade, 7-layer network recovery engine behind standard Windows Command Prompt and PowerShell 5.1.

It permanently resolves captive portal lockouts, dual-homed metric collisions (Ethernet killing Wi-Fi), APIPA (`169.254.x.x`) deadlocks, driver power-state flapping on USB adapters, and orphaned proxy anchors without installing third-party runtimes, drivers, or binaries.

```
                           +------------------------+
                           |     LanFixer.cmd       |
                           | (Dual-Polyglot Script) |
                           +-----------+------------+
                                       |
              +------------------------+------------------------+
              |                                                 |
     [Interactive Mode]                                 [Headless Engine]
 79-Col ANSI/ASCII Live TUI                     CLI Automation (-Mode Heal, etc.)
  + Real-Time Latency Sparklines                 + Task Scheduler Watchdog Daemon
  + Interactive DPAPI Vault                      + Non-Destructive State Snapshots
  + 18 One-Touch Operation Keys                  + 186 Pure In-Memory Logic Tests
```

---

## The Problem: What Breaks on Windows?

Windows networking handles standard home routers well, but degrades under enterprise, university, hostel, and multi-adapter environments:

1. **The Dual-Homed Campus Trap**: When you plug in an Ethernet cable at a university or corporate office, Windows assigns the wired adapter a lower route metric (`10` or `25`) than your working Wi-Fi (`35` or `50`). If that Ethernet link requires captive portal authentication, all internet traffic immediately diverts to the dead wired connection. Your Wi-Fi internet drops instantly, and the captive portal cannot even be resolved.
2. **The APIPA Deadlock (`169.254.x.x`)**: If a DHCP server responds slowly during link negotiation or laptop wake from sleep, Windows assigns an Automatic Private IP Address. Once trapped in APIPA, Windows often stops requesting DHCP leases until manually power-cycled.
3. **Hardware Link Flapping**: Modern laptop NICs and USB-C Ethernet dongles aggressively enable Energy Efficient Ethernet (EEE), Green Ethernet, and USB Selective Suspend. Under load or switch negotiation, the link repeatedly flaps down and up every few seconds.
4. **Orphaned Localhost Proxies**: Crashed VPN clients, debugging tools (Fiddler, Charles), or enterprise proxies frequently leave stale proxy entries pointing to dead addresses (`127.0.0.1:8888`) inside WinINet and user environment variables, silently breaking all HTTP/HTTPS traffic.
5. **Rogue DHCP DNS Hijacks**: Public or hostile networks can supply malicious or dead DNS servers via DHCP option 6, causing silent packet blackholing or DNS spoofing.

---

## Architecture: The 7-Layer Stabilization Pipeline

LanFixer executes a deterministic, non-destructive repair pipeline across 7 distinct network layers:

```
+-------------------------------------------------------------------------------+
|                        7-LAYER STABILIZATION PIPELINE                         |
+---+----------------------------+----------------------------------------------+
| 1 | Physical & Link Layer      | NDIS power cycling, disable EEE & Green      |
|   |                            | Ethernet, reset USB selective suspend.       |
+---+----------------------------+----------------------------------------------+
| 2 | DHCP & Lease Recovery      | Clear APIPA deadlocks, release stale leases, |
|   |                            | bounded 45s IEEE 802.1D STP convergence sync.|
+---+----------------------------+----------------------------------------------+
| 3 | Proxy & Stack Liquidation  | Purge orphaned 127.0.0.1 WinINet proxies,    |
|   |                            | flush NetBIOS, ARP cache, and DNS cache.     |
+---+----------------------------+----------------------------------------------+
| 4 | Dual-Homed Metric Shield   | Isolate captive Ethernet (Metric 50) while   |
|   |                            | keeping Wi-Fi primary (Metric 15) until auth.|
+---+----------------------------+----------------------------------------------+
| 5 | Adaptive DNS Profile       | Campus DHCP DNS during login; auto-switches  |
|   |                            | to validated DNS (Cloudflare/Quad9) online.  |
+---+----------------------------+----------------------------------------------+
| 6 | Headless DPAPI Vault       | Probe HTTP 204/302 redirects; auto-post      |
|   |                            | credentials encrypted via Windows DPAPI.     |
+---+----------------------------+----------------------------------------------+
| 7 | Autonomous Watchdog Guard  | Background SYSTEM scheduled task triggered   |
|   |                            | on NDIS connect, wake from sleep, or outage. |
+---+----------------------------+----------------------------------------------+
```

---

## Live Console Control Center

LanFixer features a clean, high-density 79-column TUI console dashboard designed around Hallmark terminal aesthetics. It renders live gateway latency sparklines, real-time packet loss, jitter telemetry, and a one-touch command grid:

```
Link            Address         Gateway         DNS             Internet
1 Gbps          10.1.12.226     10.1.12.1 1ms   9.9.9.9         Reachable

Gateway 10.1.12.1 (1 ms)        _.-~-.__.-~-    1 ms   Loss 0%   Jitter 1 ms
                                                Routing: Ethernet First

REPAIR & CONNECTIVITY                   DIAGNOSTICS & TOOLS
[1] Quick Heal                          [3] DNS Profile Engine
[2] Arm Watchdog Guard                  [M] Routing Priority Engine
[A] Portal Login Vault                  [4] Live Latency Probe
[7] Open Portal Page                    [5] Flush DNS & ARP Caches
[G] Headless Auto-Login                 [6] System Diagnostics Audit

PREVIEW & REPORTS                       SYSTEM & RECOVERY
[T] Dry-Run Simulation                  [8] Disarm Watchdog
[R] Export Support Report               [9] Factory Reset
[S] Run Self-Test Suite                 [0] Guide
[X] Full Net Reset                      [Q] Quit
```

---

## Quickstart

### Option A: Interactive Control Center (Recommended)

1. Download [`LanFixer.cmd`](https://github.com/abhiisonu/LanFixer/releases/latest/download/LanFixer.cmd).
2. Right-click `LanFixer.cmd` and select **Run as administrator** *(if opened normally, it will prompt for elevation automatically)*.
3. Press **`1`** for **Quick Heal** to run the complete diagnostic and repair sequence.

### Option B: Silent 1-Liner PowerShell Launch

```powershell
irm https://raw.githubusercontent.com/abhiisonu/LanFixer/main/LanFixer.cmd -OutFile LanFixer.cmd; Start-Process LanFixer.cmd -Verb RunAs
```

---

## Interactive Controls (Menu Cheat Sheet)

| Key | Operation | Action & Technical Description |
| :---: | :--- | :--- |
| **`1`** | **Quick Heal** | Executes the full 7-layer repair sequence: frees APIPA, fixes metrics, flushes caches, and signs into captive portal if credentials exist in the vault. |
| **`2`** | **Arm Watchdog** | Installs a lightweight scheduled task running under `NT AUTHORITY\SYSTEM` to heal network drops and wake events autonomously. |
| **`3`** | **DNS Profile** | Switches DNS engines: `Adaptive` (Campus before auth, Public after), `DHCP Default`, `Hybrid`, `Cloudflare (1.1.1.1)`, or `Quad9`. |
| **`4`** | **Latency Probe** | Runs real-time ICMP ping, jitter analysis, and packet loss metrics across all active network gateways. |
| **`5`** | **Flush Caches** | Flushes DNS resolver cache, NetBIOS names, ARP tables, and triggers NLA (Network Location Awareness) discovery. |
| **`6`** | **System Audit** | Audits adapter hardware, link speed/duplex, NDIS power management, DHCP lease expiration, IPv6 state, and event logs. |
| **`7`** | **Open Portal** | Pins temporary captive routes, bounds DNS to local gateway, and opens the discovered captive portal endpoint in your default browser. |
| **`A`** | **Portal Vault** | Secure interactive CLI manager to store, update, test, or delete captive portal credentials encrypted with DPAPI. |
| **`G`** | **Auto-Login** | Silent headless captive portal login using hardware-encrypted vault credentials via native .NET WebClient. |
| **`M`** | **Routing Engine** | Toggles multi-adapter priority: `Adaptive` (Smart Metric), `Ethernet First`, `Wi-Fi First`, or `Windows Default`. |
| **`T`** | **Dry-Run Mode** | Simulates all repair stages and logs predicted system mutations without writing changes to the system. |
| **`R`** | **Export Report** | Generates a full markdown diagnostic audit report saved directly to your Desktop. |
| **`S`** | **Self-Test** | Runs the built-in 186-assertion test engine verifying cmdlets, kernel drivers, quoting, and crypto logic. |
| **`X`** | **Full Net Reset** | Deep recovery: re-registers TCP/IP stack, resets Winsock catalog, clears WFP firewall filters, and restarts NDIS adapters. |
| **`8`** | **Disarm Watchdog**| Cleanly unregisters and deletes the background watchdog scheduled task. |
| **`9`** | **Factory Reset** | Reverts all network adapters, metric rules, power policies, and DNS configurations back to original hardware defaults. |
| **`0`** | **Advisory Guide** | Displays interactive symptom-to-solution matrix and troubleshooting guide. |
| **`Q`** | **Quit** | Exits the control center cleanly. |

---

## Command-Line & Headless Automation

LanFixer supports non-interactive execution for system administration, CI/CD runners, Task Scheduler, and enterprise deployment tools (Intune, SCCM, PDQ):

```cmd
:: 1. Run standard repair and exit immediately
LanFixer.cmd -Mode Heal

:: 2. Preview planned mutations without modifying system state
LanFixer.cmd -Mode Heal -DryRun

:: 3. Execute deep kernel and stack reset
LanFixer.cmd -Mode FullNetReset

:: 4. Run real-time gateway latency and jitter probe
LanFixer.cmd -Mode QuickProbe

:: 5. Flush DNS, ARP, and NetBIOS caches
LanFixer.cmd -Mode FlushCache

:: 6. Switch DNS profile to Cloudflare DNS
LanFixer.cmd -Mode SetDnsProfile -DnsProfile Cloudflare

:: 7. Install autonomous background watchdog service
LanFixer.cmd -Mode InstallWatchdog

:: 8. Run offline self-test suite (returns exit code 0 on pass, 1 on fail)
LanFixer.cmd -Mode SelfTest -NoPause

:: 9. Export comprehensive diagnostic report
LanFixer.cmd -Mode Report -NoPause

:: 10. Revert all settings to clean factory defaults
LanFixer.cmd -Mode ResetFactory
```

### CLI Exit Codes

| Exit Code | Meaning |
| :---: | :--- |
| `0` | Success / All operations completed cleanly / All self-tests passed. |
| `1` | Test assertion failure / Operation encountered an unrecoverable error. |
| `2` | Mutex collision (another LanFixer instance is actively executing). |
| `5` | Access denied (process requires Administrator elevation). |

---

## Security & Reliability Engineering

Built according to strict systems programming guidelines:

* **Zero External Binaries**: 100% native Windows script utilizing batch polyglot encapsulation with Windows PowerShell 5.1. Zero dependencies on Python, Node.js, Curl, or third-party EXEs.
* **DPAPI Machine Cryptography**: Portal credentials in the vault are encrypted using the Windows Data Protection API (`System.Security.Cryptography.ProtectedData`) with `DataProtectionScope.LocalMachine` and hardware entropy. Keys are non-exportable and readable exclusively by `SYSTEM` and elevated Administrators.
* **Strict ACL Enforcement**: The persistent storage directory (`%ProgramData%\LanFixer`) is locked with inheritance disabled and granted access only to `SYSTEM` and `Administrators`.
* **Anti-Rogue DHCP Domain Validation**: Credentials stored for a campus portal are strictly pinned to configured target domains or hashes; credentials are never transmitted to unauthorized captive endpoints.
* **Global Mutex Concurrency Guard**: Inter-process synchronization is enforced using a named global Win32 mutex (`Global\LanFixer_SingleInstance_Mutex`). Concurrent runs fail gracefully without race conditions.
* **100% Pure 7-Bit ASCII**: The script contains zero UTF-8 multibyte characters. It will never break, mangle, or crash on non-English Windows editions (CJK, Cyrillic, Turkish, Latin-1 codepages).
* **Non-Destructive Snapshots**: Before modifying adapter metrics, DNS profiles, or power settings, original configurations are snapshotted to `%ProgramData%\LanFixer\state.json`. `Factory Reset` (`9`) guarantees instant restoration.

---

## Forensic Verification & Self-Test Suite

LanFixer includes a built-in diagnostic and logic test harness that can be run on any system without applying changes:

```cmd
LanFixer.cmd -Mode SelfTest -NoPause
```

### Test Coverage Spectrum

```
[+] PowerShell 5.1+ Runtime Environment
[+] Win32 Elevation & Token Privilege Checks
[+] Required Core Cmdlets (Get-NetAdapter, Set-NetIPInterface, Resolve-DnsName, etc.)
[+] System Utility Binaries (schtasks, pnputil, dism, arp, ipconfig)
[+] Kernel Drivers Existence (tcpip.sys, ndis.sys, afd.sys)
[+] Protected Storage File ACL Verification
[+] Bounded DNS Resolution Engine (2500ms timeout clamp)
[+] 186 Pure Logic Assertions:
    - Win32 Command-Line Argument Quoting & Escaping Rules
    - HTTP Status Parsing (200, 204, 302, 503) & Captive Redirection Logic
    - Route Metric Decision Rules (Dual-Homed Conflict Prevention)
    - Jitter & Latency Variance Moving Average Math
    - DPAPI Envelope Serialization & Deserialization
    - Watchdog Task XML Schema Conformance
```

---

## Universal Portability Matrix

LanFixer is engineered to work universally across all Windows environments without device-specific dependencies:

| Category | Supported Configurations |
| :--- | :--- |
| **Operating Systems** | Windows 11 (24H2, 23H2, 22H2, 21H2), Windows 10 (22H2, 21H2, Enterprise LTSC), Windows Server (2022, 2019, 2016) |
| **Hardware Platforms** | Intel Core / Xeon, AMD Ryzen / EPYC, Qualcomm Snapdragon (Windows on ARM64) |
| **OEM Implementations** | Lenovo (ThinkPad / Legion), Dell (XPS / Latitude), HP (EliteBook / Omen), ASUS (ROG / ZenBook), Framework, Microsoft Surface |
| **Network Controllers** | Realtek (RTL8111, RTL8125 2.5GbE, RTL8153 USB), Intel (I219-V, I225-V, I226-V, Wi-Fi 6E AX210/AX211, Wi-Fi 7 BE200), Marvell AQC107, ASIX AX88179 |
| **Docking Stations** | Thunderbolt 3/4 Docks, USB-C Multiport Adapters, USB-A 3.0 to RJ45 dongles |

---

## License & Credits

Distributed under the **MIT License**. See [LICENSE](LICENSE) for details.

Engineered and maintained with mathematical rigor by **[Abhishek Sonu](https://github.com/abhiisonu)**.
Contributions, bug reports, and pull requests are welcome on [GitHub](https://github.com/abhiisonu/LanFixer).
