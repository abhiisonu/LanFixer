# LanFixer

A lightweight, single-file Windows network repair utility and captive portal automation tool.

[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6?style=flat-square&logo=windows)](https://github.com/abhiisonu/LanFixer)
[![Release](https://img.shields.io/badge/Release-v7.0.0-blue?style=flat-square)](https://github.com/abhiisonu/LanFixer/releases/latest)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=flat-square&logo=powershell)](https://github.com/abhiisonu/LanFixer)

---

LanFixer solves common Windows network connectivity issues on campus, office, and home Ethernet connections. It automates captive portal login, resolves dual-homed route conflicts (where Ethernet blocks working Wi-Fi), fixes APIPA (`169.254.x.x`) DHCP deadlocks, prevents USB NIC power-flapping, and clears stale proxy configurations--all without third-party runtimes or external dependencies.

```text
  LAN FIXER  v7.0.0                                [Admin] [Guard] [Vault]
  ------------------------------------------------------------------------
  Ethernet   1 Gbps (Primary) - 10.1.12.226         Online
  Gateway    10.1.12.1 (1 ms)     Loss: 0%          Jitter: 1 ms
  Uplink     Wi-Fi (Standby) - Campus-Secure

  REPAIR & REMEDIATION                    DIAGNOSTICS & AUDIT
  [1] Quick Heal (Recommended)            [3] DNS Configuration
  [2] Install Watchdog Service            [M] Routing & Metric Priority
  [A] Portal Credentials Vault            [4] Network Quality & MTU Probe
  [7] Captive Portal Check                [5] Flush Network Caches
  [G] Auto-Login to Portal                [6] System Diagnostics Audit

  PREVIEW & LOGS                          RECOVERY & SYSTEM
  [T] Dry Run (Preview Only)              [8] Remove Watchdog Service
  [R] Export Diagnostic Report            [B] Sentinel Live Monitor
  [H] History & Change Ledger             [X] Recovery & Reset Tiers
  [0] User Guide                          [Q] Exit
```

---

## The Problems It Solves

* **Ethernet Priority Hijacking on Captive Portals**: When plugging into a campus or enterprise LAN that requires web authentication, Windows immediately assigns the wired adapter a lower route metric (`10`) than your working Wi-Fi (`35`). All internet traffic diverts to the unauthenticated Ethernet connection, immediately breaking your internet. LanFixer dynamically isolates unauthenticated Ethernet (metric `50`) until web login succeeds, keeping Wi-Fi active as the primary uplink.
* **APIPA (`169.254.x.x`) DHCP Deadlocks**: When DHCP servers respond slowly or after waking a laptop from sleep, Windows frequently assigns an Automatic Private IP Address and stops requesting DHCP leases. LanFixer frees the APIPA deadlock, cycles the interface safely, and forces clean DHCP negotiation without requiring a reboot.
* **USB-C & Laptop NIC Link Flapping**: Modern laptop adapters and USB Ethernet dongles aggressively enable Energy Efficient Ethernet (EEE) and USB Selective Suspend. Under sustained traffic or switch renegotiation, the link repeatedly flaps up and down. LanFixer tunes adapter power parameters to stabilize link state while respecting battery operation.
* **Stale Localhost Proxies**: Crashed VPN clients, debugging proxies (Fiddler, Charles), or enterprise software frequently leave dead proxy entries (`127.0.0.1:8888`) stuck in WinINet or system environment variables, breaking all web traffic. LanFixer detects and purges orphaned localhost proxies.
* **Captive Portal Auto-Login**: Securely stores campus or hotel credentials using the Windows Data Protection API (DPAPI). When an HTTP 204 or 302 captive redirect is detected, LanFixer automatically authenticates in the background.

---

## Quickstart

### Method 1: Download & Run (Recommended)

1. Download [`LanFixer.cmd`](https://github.com/abhiisonu/LanFixer/releases/latest/download/LanFixer.cmd).
2. Right-click `LanFixer.cmd` and select **Run as administrator** *(if launched normally, it prompts for elevation automatically)*.
3. Press **`1`** for **Quick Heal** to run the complete diagnostic and repair sequence.

### Method 2: One-Liner (PowerShell)

```powershell
irm https://raw.githubusercontent.com/abhiisonu/LanFixer/main/LanFixer.cmd -OutFile LanFixer.cmd; Start-Process LanFixer.cmd -Verb RunAs
```

---

## Key Features

* **Zero Dependencies**: Pure batch polyglot embedding Windows PowerShell 5.1. Zero external binaries, Python, or Node.js required. Runs out-of-the-box on clean Windows 10 and 11 installations.
* **DPAPI Credential Encryption**: Captive portal logins are encrypted at rest using the Windows Data Protection API (`System.Security.Cryptography.ProtectedData`) with machine-specific entropy. Plaintext credentials never touch disk.
* **Non-Destructive & Reversible**: Every system configuration change (DNS, metrics, adapter power settings) is snapshotted before modification. Any change can be inspected via the Change Ledger (`-Mode History`) or reversed (`-Mode Undo`).
* **Silent Background Watchdog**: Optionally installs as a lightweight Windows Scheduled Task running under `SYSTEM` with window popups suppressed (`Hidden=True`). Automatically heals connection drops and sleep-resume events.
* **Battery-Conscious Telemetry**: Queries hardware battery state via WMI. Avoids disabling power-saving USB states on DC power and adapts watchdog polling intervals to preserve laptop battery life.
* **Diagnostic & Quality Tooling**: Built-in multi-size Path MTU discovery (1500/1492/1420), RFC bufferbloat grading (A+ to F), TCP handshake latency testing, and a 6-stage network cache flush (DNS, ARP, NetBIOS, NLA, sockets).

---

## Interactive Shortcuts

| Key | Action | Description |
| :---: | :--- | :--- |
| **`1`** | **Quick Heal** | Executes the full repair pipeline: clears APIPA, fixes route metrics, flushes caches, and signs into the captive portal if credentials exist. |
| **`2`** | **Install Watchdog** | Registers a silent background scheduled task to automatically heal network drops and wake-from-sleep events. |
| **`3`** | **DNS Configuration** | Switches DNS resolvers with live latency benchmarks (`Campus DHCP`, `Cloudflare 1.1.1.1`, `Quad9`, `Google`, or `Reset to DHCP`). |
| **`4`** | **Quality & MTU Probe** | Tests Path MTU, bufferbloat grading, TCP handshake latency, and hardware battery health telemetry. |
| **`5`** | **Flush Caches** | 6-stage flush: DNS client cache, ARP neighbors, NetBIOS name cache, NLA service, socket tables, and WFP filter state. |
| **`6`** | **System Audit** | Audits adapter hardware, link speed/duplex, NDIS power management, DHCP lease duration, and IPv6 state. |
| **`7`** | **Captive Portal Check** | Detects HTTP 204/302 captive redirects and opens the discovered login page in your default browser. |
| **`A`** | **Portal Vault** | Secure interactive manager to store, update, test, or delete encrypted captive portal credentials. |
| **`G`** | **Auto-Login** | Headless captive portal login using hardware-encrypted vault credentials. |
| **`M`** | **Routing & Metrics** | Inspects live default routes (`0.0.0.0/0`) and configures adapter metric priority (`Ethernet Priority`, `Wi-Fi Priority`, or `Adaptive`). |
| **`T`** | **Dry Run** | Simulates all repair stages and logs predicted mutations without changing system state. |
| **`R`** | **Export Report** | Generates a structured Markdown diagnostic audit report saved directly to your Desktop. |
| **`H`** | **History & Forensics** | Inspects the persistent change ledger and provides reverse-chronological undo for prior actions. |
| **`B`** | **Sentinel Monitor** | Continuous real-time monitor with live latency sparklines and battery-adaptive polling cadence. |
| **`X`** | **Recovery & System** | Risk-stratified network reset tiers from non-destructive debloat to complete stack rebuild (`netcfg -d`). |
| **`8`** | **Remove Watchdog** | Unregisters and removes the background watchdog scheduled task and cleans startup hooks. |
| **`0`** | **User Guide** | Displays symptom-to-solution matrix and operational guide. |
| **`Q`** | **Exit** | Exits the utility cleanly. |

---

## Headless CLI Automation

LanFixer supports non-interactive execution for system administrators, scripts, and deployment tools (Intune, SCCM, Task Scheduler):

```cmd
:: Run comprehensive 7-layer health check
LanFixer.cmd -Mode Doctor
LanFixer.cmd -Mode Doctor -Json

:: Execute automated repair silently
LanFixer.cmd -Mode QuickHeal

:: Preview planned changes without applying them
LanFixer.cmd -Mode QuickHeal -DryRun

:: Inspect persistent change history and undo actions
LanFixer.cmd -Mode History -Limit 20
LanFixer.cmd -Mode Undo -Id <ChangeId>

:: Export redacted diagnostic support bundle (ZIP)
LanFixer.cmd -Mode Bundle -OutDir C:\Logs -Redaction Strict

:: Command help and metadata reference
LanFixer.cmd -Mode Help
LanFixer.cmd -Mode Help -Id Doctor
```

### Exit Codes

| Code | Meaning |
| :---: | :--- |
| `0` | Success: Operation completed without errors, or system is healthy. |
| `1` | Error: General operation failure or unhandled exception. |
| `10` | Degraded: Network connection is partially degraded (e.g. high packet loss or DNS latency). |
| `20` | Broken: Network connection is offline or link is down. |
| `40` | Elevation Required: Administrative privileges are needed for this operation. |

---

## Technical Architecture

LanFixer is built as a self-contained polyglot script:

1. **Batch Bootloader**: The first 8 lines are interpreted by `cmd.exe`. They configure the process environment, locate the script path (`LANFIXER_SELF`), and pass control directly to Windows PowerShell 5.1 with `-ExecutionPolicy Bypass`.
2. **Execution Engine**: The remainder of the file is parsed directly by PowerShell's AST parser as a script block. It interacts with Windows networking exclusively through native CIM/WMI classes (`MSFT_NetAdapter`, `MSFT_NetIPAddress`, `Win32_NetworkAdapterConfiguration`), native cmdlets (`NetTCPIP`, `DnsClient`), and Win32 APIs via compiled C# type definitions.
3. **Atomic State & Snapshots**: Operational state and pre-mutation baselines are persisted in `%ProgramData%\LanFixer\state.clixml` using atomic write patterns (`.tmp` write, deserialization test, atomic rename) with automatic `.bak` recovery.
4. **Zero-Popup Task Architecture**: Background Watchdog and Sentinel tasks are registered with `<Hidden>true</Hidden>` and `<Priority>7</Priority>` via `schtasks.exe`, preventing console window flashes during user logon or network reconnection.

---

## System Requirements

* **Operating System**: Windows 10 (version 1809 or higher) or Windows 11
* **Architecture**: x64, ARM64, or x86
* **Runtime**: Windows PowerShell 5.1 (installed by default on all modern Windows versions)
* **Privileges**: Administrator rights (required for modifying network adapter properties, routing tables, and scheduled tasks)

---

## Author & License

Engineered and maintained by **[Abhishek Sonu](https://github.com/abhiisonu)**.

Released under the MIT License.
