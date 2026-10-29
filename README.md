<div align="center">

```
  ██╗      █████╗ ███╗   ██╗███████╗██╗██╗  ██╗███████╗██████╗ 
  ██║     ██╔══██╗████╗  ██║██╔════╝██║╚██╗██╔╝██╔════╝██╔══██╗
  ██║     ███████║██╔██╗ ██║█████╗  ██║ ╚███╔╝ █████╗  ██████╔╝
  ██║     ██╔══██║██║╚██╗██║██╔══╝  ██║ ██╔██╗ ██╔══╝  ██╔══██╗
  ███████╗██║  ██║██║ ╚████║██║     ██║██╔╝ ██╗███████╗██║  ██║
  ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
```

### The Sovereign Self-Healing Network Engine for Windows

[![Version](https://img.shields.io/badge/version-6.0.0%20Sovereign%20Peak-007acc?style=for-the-badge&labelColor=1e1e1e)](https://github.com/abhiisonu/LanFixer/releases/tag/v6.0.0)
[![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-00a4ef?style=for-the-badge&labelColor=1e1e1e)](https://github.com/abhiisonu/LanFixer)
[![Architecture](https://img.shields.io/badge/runtime-Native%20Polyglot%20%28Zero%20Dependencies%29-2ea44f?style=for-the-badge&labelColor=1e1e1e)](https://github.com/abhiisonu/LanFixer)
[![Security](https://img.shields.io/badge/security-DPAPI%20%7C%20ACL%20Locked-ff6b6b?style=for-the-badge&labelColor=1e1e1e)](https://github.com/abhiisonu/LanFixer)
[![Tests](https://img.shields.io/badge/self--test-166%2B%20Passed%20%280%20Failures%29-brightgreen?style=for-the-badge&labelColor=1e1e1e)](https://github.com/abhiisonu/LanFixer)

<br/>

**A single-file, zero-dependency Windows batch/PowerShell polyglot utility that provides complete autonomous self-healing, dual-homed metric arbitration, hardened captive portal automation, and multi-layer network stack recovery across campus, enterprise, and home networks.**

<br/>

[**Download LanFixer.cmd (v6.0.0)**](https://github.com/abhiisonu/LanFixer/releases/download/v6.0.0/LanFixer.cmd) • [**Quickstart**](#-quickstart-in-3-steps) • [**Interactive Dashboard**](#-the-interactive-control-center) • [**Architecture**](#-deep-system-architecture) • [**CLI Cookbook**](#-cli--automation-cookbook)

</div>

---

## ⚡ The Problem LanFixer Solves

Windows networking handles basic home Wi-Fi adequately, but frequently collapses when subjected to complex campus, hostel, corporate, or dual-homed network environments:

```
                                  [ THE DUAL-HOMED CONFLICT ]
                                               │
               ┌───────────────────────────────┴───────────────────────────────┐
               ▼                                                               ▼
    [ Working Wi-Fi / Hotspot ]                                   [ Unauthenticated Ethernet ]
    Metric: 40 (Demoted by Windows)                              Metric: 10 (Forced Primary by Windows)
    Status: Active Internet                                       Status: Trapped behind Captive Portal
               │                                                               │
               └──────────────────────► 💥 COLLISION ◄────────────────────────┘
                    Result: Windows routes ALL traffic into the unauthenticated
                    Ethernet cable. Active Wi-Fi drops immediately. Zoom calls freeze.
```

### Windows Default vs. LanFixer v6.0.0

| Failure Mode | Default Windows Behavior | LanFixer v6.0.0 Sovereign Engine |
| :--- | :--- | :--- |
| **Dual-Homed Cable Insertion** | Ethernet metric drops below Wi-Fi. Traps all system traffic behind captive portal; kills working internet immediately. | **Arbitrated Metrics:** Ethernet held at metric `50`, Wi-Fi protected at metric `15`. Isolated `/32` captive routes injected to allow login without dropping 1 ms of Wi-Fi traffic. |
| **APIPA Lease Deadlock** | Stuck at `169.254.x.x` indefinitely after switch timeout or router power flicker. | **Escalated DHCP Ladder:** 4-tier progressive recovery (Soft renew → Winsock catalog flush → NDIS driver reset). |
| **Captive Portal Sign-In** | Manual browser popup required on every link change; passwords typed repeatedly in plain browser forms. | **DPAPI Machine Vault:** Silent background headless sign-in over source-bound raw TLS sockets with cert pinning. |
| **Rogue DHCP Phishing** | Any rogue DHCP server advertising a DNS search suffix can intercept portal login forms. | **Rogue-DHCP Vault Guard:** Vault credentials strictly refuse dispatch to unverified DHCP suffixes (`Test-CredentialPortalHost`). |
| **Driver Power Flapping** | Energy Efficient Ethernet (EEE) and USB Selective Suspend cause link drops every few minutes. | **Hardware Power Shield:** Dynamically disables 19 link-flapping driver keywords (`*EEE`, `GreenEthernet`, selective suspend) on active NICs. |
| **Dead Local Proxies** | Crashed VPNs or proxies (Fiddler, Portmaster) leave dead `127.0.0.1:port` entries, bricking CLI and browser. | **Active TCP Socket Probing:** Tests proxy port liveness across HKCU, HKLM, WinHTTP, and environment variables; strips dead proxies instantly. |
| **Path MTU Blackholes** | Campus GRE/IPsec tunnels drop packets > 1420 bytes, causing web pages to hang indefinitely. | **Bounded PMTU Clamping:** Active ICMP discovery guarded by `Find-NetRoute` clamps MSS/MTU (floor 1280) safely. |

---

## 🚀 Quickstart in 3 Steps

No installer. No Node.js. No Python. No external DLLs. Just pure Windows native execution.

```cmd
:: 1. Download LanFixer.cmd to your PC
curl -fSLo "%USERPROFILE%\Desktop\LanFixer.cmd" "https://github.com/abhiisonu/LanFixer/releases/download/v6.0.0/LanFixer.cmd"

:: 2. Launch elevated from command line or right-click -> "Run as administrator"
"%USERPROFILE%\Desktop\LanFixer.cmd"

:: 3. Press [1] for Quick Heal — heals the stack and authenticates in seconds
```

> [!TIP]
> **Zero Footprint:** LanFixer stores its encrypted state in `%ProgramData%\LanFixer` with strict Administrator-only ACLs (`*S-1-5-32-544`). If you ever want to revert everything, pressing `[9]` completely removes all tasks, restores original driver properties, and returns your PC to factory defaults.

---

## 🖥️ The Interactive Control Center

LanFixer runs an ultra-responsive, 79-column pure ASCII terminal UI with mouse text selection (QuickEdit active) and a natural **3,000-line scrollback buffer**:

```
  LAN FIXER   v6.0.0                            ● Admin   ● Guard   ● Vault
  ─────────────────────────────────────────────────────────────────────────────
  [ ● ONLINE ]                                      Ethernet · 1000 Mbps Full
  PC ─── Ethernet ─── Gateway ─── Internet ─── DNS
  ●         ●            ●            ●        ●
  10.1.15.219        10.1.12.1      Online   1.1.1.1 (1.8 ms)
  Gateway Pulse 10.1.12.1  [ 0.8 ms avg · 0% loss ]   ▂▃▂  ▂▃▂  (12/12 replies)

  STATUS    Connected to Ethernet (1000 Mbps Full). Active IPv4: 10.1.15.219.
  ACTION    System stack healthy. No action required.

  REPAIR & CONNECTIVITY                     DIAGNOSTICS & TOOLS
  [1] Quick Heal                            [3] DNS Profile Engine
  [2] Arm Watchdog Guard                    [M] Routing Priority Engine
  [A] Portal Login Vault                    [4] Live Latency Probe
  [7] Open Portal Page                      [5] Flush DNS & ARP Caches
  [G] Headless Auto-Login                   [6] System Diagnostics Audit

  PREVIEW & REPORTS                         SYSTEM & RECOVERY
  [T] Dry-Run Simulation                    [8] Disarm Watchdog
  [R] Export Support Report                 [9] Factory Reset
  [S] Run Self-Test Suite                   [0] Guide
  [X] Full Net Reset                        [Q] Quit
  > _
```

---

## 🎹 Complete Interactive Key Reference

Every key in the dashboard executes a targeted, high-precision engineering module:

### 🛠️ Repair & Connectivity
* **`[1]` Quick Heal:** The premier one-touch automated repair. Sequentially executes the full 7-layer pipeline (hardware link, DHCP renewal, ARP integrity, adaptive DNS, route metrics, firewall profile, and network services). If a captive portal is present and credentials are saved, it **automatically logs in headlessly** without opening a browser!
* **`[2]` Arm Watchdog Guard:** Registers an autonomous background scheduled task running under `NT AUTHORITY\SYSTEM`. Hooked directly into Windows kernel events (`Kernel-Power` sleep resume 107/507, cable connect 10000/10001) for instant sub-second healing.
* **`[A]` Portal Login Vault:** Opens the interactive DPAPI credential manager. Enter your campus/enterprise credentials once; they are encrypted with machine-entropy DPAPI and stored with SYSTEM/Admin-only access. Supports custom SSL certificate fingerprint pinning.
* **`[7]` Open Portal Page:** Bypasses browser hurdles by setting captive routing rules and opening the login page. Includes an automated APIPA guard that renews DHCP first if your lease is stuck.
* **`[G]` Headless Auto-Login:** Forces an immediate manual background login against the detected captive portal using raw TLS sockets.

### 🔬 Diagnostics & Traffic Control
* **`[3]` DNS Profile Engine:** Switch between 5 operational DNS modes:
  1. *Adaptive (Recommended):* Campus DNS while captive, high-speed public DNS when online.
  2. *Campus DHCP:* Forces local resolvers for internal campus intranet and ERP portals.
  3. *Hybrid:* Quad9 (`9.9.9.9`) + Google (`8.8.8.8`) with campus fallback.
  4. *Cloudflare:* Ultra-fast `1.1.1.1` with DNSSEC validation.
  5. *Reset DHCP:* Reverts all adapters back to automatic DHCP DNS.
* **`[M]` Routing Priority Engine:** Choose traffic arbitration policy:
  1. *Adaptive (Default):* Promotes Ethernet when online; protects Wi-Fi when Ethernet is captive.
  2. *Forced Ethernet:* Locks Ethernet at metric 10 regardless of state.
  3. *Forced Wi-Fi:* Locks Wi-Fi as primary uplink while preserving Ethernet captive portal route.
  4. *Windows Default:* Returns metric arbitration to standard Windows automatic logic.
* **`[4]` Live Latency Probe:** Real-time 10-ping burst measuring minimum, average, maximum latency, jitter, and packet loss. **Probes both Ethernet and Wi-Fi gateways side-by-side** in dual-homed setups.
* **`[5]` Flush DNS & ARP Caches:** Clears Windows DNS cache, flushes dynamic IPv4/IPv6 ARP neighbors (while preserving permanent gateway locks), purges NetBIOS tables, and refreshes the Network Location Awareness service.
* **`[6]` System Diagnostics Audit:** Generates an in-depth 8-section technical audit of hardware controllers, link speeds, duplex negotiation, packet errors, lease timestamps, IPv6 blackhole detection, and event log records.

### 🛡️ System, Safety & Rollback
* **`[T]` Dry-Run Simulation:** Executes the entire 7-layer heal pipeline in safe simulation mode (`$script:IsDry = $true`). Outputs exactly what would change without modifying a single byte on your system.
* **`[R]` Export Support Report:** Compiles a complete diagnostic bundle and the last 40 lines of activity logs into a formatted text report saved directly to your Desktop.
* **`[S]` Run Self-Test Suite:** Executes 166+ automated unit and integration assertions validating cmdlets, crypto roundtrips, regex parsers, and system drivers.
* **`[X]` Full Net Reset (Emergency Recovery):** 5-Stage deep stack recovery. Rescans the PnP bus, wipes dead proxies, neutralizes broken WFP interceptors, resets MTU to 1500, flushes all caches, and restarts network services.
* **`[8]` Disarm Watchdog:** Cleanly unregisters the SYSTEM scheduled task and helper tasks.
* **`[9]` Factory Reset Rollback:** Restores all snapshotted original adapter properties, DNS resolvers, and route metrics. Purges the credential vault and leaves your PC in its original pre-LanFixer state.
* **`[0]` Decision Guide:** Interactive reference matrix mapping specific network symptoms to their optimal 1-touch solution.
* **`[Q]` Quit:** Exits cleanly and restores standard console cursor state.

---

## 🏛️ Deep System Architecture

LanFixer's 7-layer recovery pipeline maps directly onto the physical and operating system stack:

```
┌────────────────────────────────────────────────────────────────────────┐
│ Layer 1: Hardware & Power Shield                                       │
│ • Rescans PnP bus • Strips EEE / Green Ethernet • Disables USB Suspend │
├────────────────────────────────────────────────────────────────────────┤
│ Layer 2: Data Link & DHCP Lease Renewal                                │
│ • Resolves APIPA 169.254.x.x • RFC 8910 Option 114 Extraction • DAD   │
├────────────────────────────────────────────────────────────────────────┤
│ Layer 3: Gateway ARP Integrity & Dual-Homed Routing                    │
│ • Dynamic ARP inspection • Metric Arbitrage (Eth: 50/10, Wi-Fi: 15/40)│
├────────────────────────────────────────────────────────────────────────┤
│ Layer 4: Adaptive DNS Configuration                                    │
│ • Parallel resolver speed tests • Split-horizon campus domain rules   │
├────────────────────────────────────────────────────────────────────────┤
│ Layer 5: Captive Portal Routing & Reachability                         │
│ • Dynamic endpoint discovery • Target /32 host routing                 │
├────────────────────────────────────────────────────────────────────────┤
│ Layer 6: Security & Firewall Exposure                                  │
│ • Enforces Public firewall profile on untrusted LANs • NetBIOS filter  │
├────────────────────────────────────────────────────────────────────────┤
│ Layer 7: Windows Stack & Services                                      │
│ • Neutralizes dead loopback proxies • NCSI yellow triangle fix • NDIS  │
└────────────────────────────────────────────────────────────────────────┘
```

### Security & Cryptographic Invariants

1. **DPAPI Machine-Entropy Encryption:** Stored credentials are encrypted via Windows Data Protection API using `DataProtectionScope.LocalMachine` combined with hardware-specific entropy. Plaintext passwords never touch disk or logs.
2. **Strict Store Isolation:** The runtime store at `%ProgramData%\LanFixer` has its ACL verified and normalized on every run: ownership is assigned to `*S-1-5-32-544` (Administrators) with write permissions restricted exclusively to `SYSTEM` and `Administrators`.
3. **Anti-Phishing Rogue DHCP Guard:** When connecting to unknown networks, LanFixer discovers portal domains via HTTP redirects and DHCP options. However, **vault passwords are never transmitted to an unverified domain** handed out by a rogue DHCP server; credentials are only dispatched to configured institutional hosts or pinned certificate fingerprints.
4. **Decompression Bomb Protection:** The built-in Gzip and Zlib/Deflate response decoder enforces a strict 1 MB boundary with loop limits, immunizing the raw socket client against compression bomb payloads.

---

## 💻 CLI & Automation Cookbook

LanFixer can be run completely headlessly in scripts, scheduled tasks, or CI/CD pipelines:

```cmd
:: One-shot silent heal and exit
LanFixer.cmd -Mode Heal

:: Deep emergency reset (clears dead proxies, resets WFP, restores clean metrics)
LanFixer.cmd -Mode Omnifix

:: Run safe dry-run simulation without modifying settings
LanFixer.cmd -Mode Heal -DryRun

:: Output quick latency and network health telemetry to stdout
LanFixer.cmd -Mode QuickProbe

:: Flush all DNS, ARP, and NetBIOS caches
LanFixer.cmd -Mode FlushCache

:: Install the autonomous SYSTEM background watchdog task
LanFixer.cmd -Mode InstallWatchdog

:: Unregister the background watchdog task
LanFixer.cmd -Mode UninstallWatchdog

:: Execute the full 166+ unit and regression test suite
LanFixer.cmd -Mode SelfTest -NoPause

:: Generate and export support report to Desktop
LanFixer.cmd -Mode Report

:: Revert all settings back to original factory values
LanFixer.cmd -Mode ResetFactory
```

---

## 🧪 Verification & Standards Compliance

LanFixer is continuously validated against strict engineering constraints:

* **AST Parsing Clean:** `0` syntax or language parser errors under PowerShell 5.1 and PowerShell 7+.
* **Encoding:** Pure ASCII character set (0 non-ASCII or multi-byte Unicode characters) to prevent cmd.exe codepage corruption across localized Windows editions.
* **Line Endings:** Strict Windows CRLF (`\r\n`) compliance across all files.
* **Zero Dependencies:** Relies solely on native Windows executables (`netsh.exe`, `ipconfig.exe`, `route.exe`, `schtasks.exe`, `powercfg.exe`, `pnputil.exe`) and core .NET Framework 4.5+ assemblies.

---

## 📜 License & Authorship

Designed and engineered by **Abhishek Sonu** ([@abhiisonu](https://github.com/abhiisonu)).  
Licensed under the [MIT License](LICENSE).
