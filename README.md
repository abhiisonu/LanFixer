# LanFixer — Omni-360 Sovereign Edition

A high-performance, single-file Windows network stabilization engine, hardware buffer optimizer, and captive portal automation utility.

[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011%20(24H2)-0078D6?style=flat-square&logo=windows)](https://github.com/abhiisonu/LanFixer)
[![Release](https://img.shields.io/badge/Release-v11.0.0-blue?style=flat-square)](https://github.com/abhiisonu/LanFixer/releases/latest)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207%2B-5391FE?style=flat-square&logo=powershell)](https://github.com/abhiisonu/LanFixer)
[![Integrity](https://img.shields.io/badge/Integrity-SHA256%20Sealed-brightgreen?style=flat-square)](https://github.com/abhiisonu/LanFixer)

---

LanFixer solves chronic Windows network connectivity failures across enterprise, campus, and home environments. It operates as a zero-dependency **polyglot CLI / TUI system utility**, curing dual-homed route conflicts (where wired Ethernet steals internet from working Wi-Fi), eradicating Windows 11 APIPA (`169.254.x.x`) DHCP deadlocks, enforcing RFC 2131 broadcast flags for ISC/Kea relays, eliminating USB-GbE sleep and ring buffer stalls, and automating DPAPI-encrypted captive portal authentication.

```text
  LAN FIXER  v11.0.0                                 * Admin  * Guard  o Vault
  ----------------------------------------------------------------------------
                    Online                                 Ethernet . 1 Gbps
  *====================*====================*====================*====================*
  Link                 Address              Gateway              DNS                  Internet
  1 Gbps               10.1.13.67/22        10.1.12.1 56ms       172.16.1.2           Reachable

  Gateway   ^"#^-x~~^~^^.--~~~,__.,,,---_,#____.   11 ms   Loss 0%   Jitter 11 ms

  Adapter  Realtek USB GbE . MTU 1500       Network  Campus . Score 5
  Lease    10.1.13.67/22 (1022 hosts)       DNS      Adaptive . 172.16.1.2, 1.1.1.1
  Gateway  10.1.12.1 (56 ms)                Routing  Ethernet First
```

---

## What LanFixer Solves

* **Windows 11 DHCP Unicast Drop**: Windows 11 sends `DHCP-DISCOVER` with Broadcast Flag `0` (unicast). Campus switches, enterprise ISC-Kea relays, and managed subnets silently drop unicast replies, stranding the machine on an APIPA lease. LanFixer enforces **both** global (`DhcpGlobalForceBroadcastFlag\0`) and per-interface broadcast flags (`DhcpConnForceBroadcastFlag = 1`), re-enables Windows Firewall UDP 68 (`CoreNet-DHCP-In`), and guarantees lease acquisition.
* **Windows 11 24H2 Dual-IP APIPA Ghosting**: On large subnets (500+ nodes), Windows 11 24H2 frequently retains a ghost `169.254.x.x` address alongside valid DHCP leases. LanFixer's `Exorcise-ApipaGhost` engine purges orphaned APIPA bindings instantly.
* **Ethernet Priority Hijacking on Captive Portals**: When plugging into an unauthenticated Ethernet port, Windows assigns it a low metric (`10`), superseding working Wi-Fi (`35`) and killing internet access. LanFixer dynamically demotes unauthenticated Ethernet (metric `50`) until web authentication completes, maintaining seamless Wi-Fi fallback.
* **Switch STP Listening/Learning Timeouts**: Managed switches take 15–45s to transition Spanning Tree Protocol (STP) ports from `Listening`/`Learning` to `Forwarding`. `ipconfig /renew` fails during this quiet window. LanFixer gates renewal on real incoming RX packet reception (`Wait-SwitchPortForwarding`).
* **Silent USB Ethernet (GbE) RX Stalls**: Realtek and ASIX USB dongles aggressively enter USB selective suspend and suffer ring buffer stalls while NDIS link remains "Up". LanFixer detects asymmetric TX/RX stalls and cycles transceivers cleanly without rebooting.
* **IP Conflicts & DAI Blackholing**: Detects IP collisions using live Win32 `SendARP`, neighbor MAC mismatch detection, and Kernel Event `4199`. In campus environments, claims a verified ARP-free IP and **automatically rolls back to DHCP** if the gateway fails to answer.

---

## Quickstart

### Option 1: Direct Download (Recommended)

1. Download [`LanFixer.cmd`](https://github.com/abhiisonu/LanFixer/releases/latest/download/LanFixer.cmd).
2. Right-click `LanFixer.cmd` and select **Run as administrator** *(or run from standard terminal; elevation prompts automatically)*.
3. Press **`1`** for **Quick Heal** to run the complete 7-layer stabilization pipeline.

### Option 2: PowerShell One-Liner

```powershell
irm https://raw.githubusercontent.com/abhiisonu/LanFixer/main/LanFixer.cmd -OutFile LanFixer.cmd; Start-Process LanFixer.cmd -Verb RunAs
```

---

## Interactive Control Center & Modes

LanFixer includes an adaptive, responsive TUI dashboard with live 350ms gateway latency sparklines, instant live startup telemetry, and 54 dedicated operational modes:

| Key / Mode | Function | Purpose |
| :---: | :--- | :--- |
| **`1`** / `QuickHeal` | **Quick Heal** | Complete 7-layer autonomous diagnostic, stack resuscitation, and route prioritization. |
| **`2`** / `InstallWatchdog` | **Watchdog Service** | Registers a zero-popup hidden background task that auto-heals connections on link flapping. |
| **`3`** / `SetDnsProfile` | **DNS Profiles** | Switches between `Adaptive`, `Cloudflare (1.1.1.1)`, `Quad9 (9.9.9.9)`, or `Reset to DHCP`. |
| **`4`** / `Probe` | **Quality & MTU Probe** | Path MTU discovery, bufferbloat testing, handshake jitter, and battery health telemetry. |
| **`5`** / `FlushCache` | **Flush Caches** | Comprehensive cache purge: DNS, ARP neighbor table, NetBIOS, NLA, and socket tables. |
| **`6`** / `Diagnose` | **Diagnostics Audit** | Deep hardware audit: link speed/duplex, NDIS offloads, EEE Green Ethernet, and IPv6 health. |
| **`7`** / `LaunchPortal` | **Captive Portal Check** | Detects HTTP 204/302 redirects and opens authenticated endpoints in default browser. |
| **`A`** / `Vault` | **Credential Vault** | Hardware-backed DPAPI credential manager to store, test, or delete encrypted portal logins. |
| **`G`** / `Login` | **Auto-Login** | Headless automated portal login using hardware-encrypted vault credentials. |
| **`M`** / `SetRouteProfile` | **Route Metrics** | Configures adapter metric routing (`Adaptive`, `Ethernet Priority`, `Wi-Fi Priority`). |
| **`T`** / `DryRun` | **Dry Run Preview** | Simulates all repair stages and logs predicted mutations with zero system modifications. |
| **`R`** / `Report` | **Export Report** | Generates a Markdown diagnostic audit report directly on your Desktop. |
| **`H`** / `History` | **Change History** | Inspects persistent JSONL change ledger with reverse-chronological multi-step undo. |
| **`B`** / `Sentinel` | **Live Sentinel** | Real-time continuous link monitor with battery-adaptive polling cadence. |
| **`X`** / `ResetOptions` | **Reset Tiers** | Risk-stratified network resets (`Omnifix`, `Ultra`, `Doomsday`, `Armageddon`). |
| **`8`** / `UninstallWatchdog`| **Remove Watchdog** | Completely unregisters the scheduled watchdog task and cleans persistent hooks. |
| **`0`** / `Guide` | **User Guide** | Built-in interactive symptom-to-solution matrix and operational guide. |
| **`Q`** | **Exit** | Exits the dashboard cleanly. |

---

## Headless CLI Automation

For automated scripts, CI/CD, Intune, and enterprise deployments, LanFixer provides pure JSON and quiet automation flags:

```cmd
:: Run 7-layer doctor health check (pure single-object JSON output)
LanFixer.cmd -Mode Doctor -Json

:: Execute automated repair silently
LanFixer.cmd -Mode QuickHeal -Quiet

:: Simulate changes with zero mutations
LanFixer.cmd -Mode QuickHeal -DryRun -Json

:: Query persistent change history and undo specific mutation
LanFixer.cmd -Mode History -Limit 10 -Json
LanFixer.cmd -Mode Undo -Id <EntryId> -Json

:: Reversible multi-action rollback to original factory baseline
LanFixer.cmd -Mode ResetFactory -Json

:: Export redacted diagnostic support bundle (ZIP)
LanFixer.cmd -Mode Bundle -OutDir C:\Logs -Redaction Strict
```

### Exit Codes

| Code | Status | Description |
| :---: | :--- | :--- |
| `0` | **Healthy / Success** | Operation completed cleanly, or all 7 network layers are operational. |
| `1` | **Error** | General execution failure or invalid parameter. |
| `10` | **Degraded** | Connection partially operational (e.g. gateway alive, but DNS/WAN degraded). |
| `20` | **Broken** | Complete loss of network reachability or physical link down. |
| `40` | **Elevation Required**| Administrator privileges required for this operation. |

---

## Security & Architecture

1. **Pure Polyglot Format**: The single `.cmd` file is a 7-bit ASCII CRLF polyglot interpreted by `cmd.exe` in lines 1–8 and compiled directly into PowerShell AST without temporary `.ps1` files.
2. **Cryptographic Sealing**: The core runtime executable (`%ProgramData%\LanFixer\LanFixer_Core.cmd`) is ACL-locked (`Administrators:F`, `SYSTEM:F`, `Users:RX`) and cryptographically sealed with a SHA-256 integrity manifest (`integrity.json`).
3. **Idempotent Undo & Audit Trail**: Every system change is recorded in `%ProgramData%\LanFixer\change_ledger.jsonl` with pre-mutation baseline values, reversible scriptblocks, and drift detection before applying rollback.
4. **DPAPI Encryption**: Captive portal passwords never touch plaintext disk storage. They are encrypted at rest via `System.Security.Cryptography.ProtectedData` using `CurrentUser` scope.

---

## System Requirements

* **Operating System**: Windows 10 (1809+) or Windows 11 (21H2, 22H2, 23H2, 24H2)
* **Architecture**: x64, ARM64, x86
* **Runtime**: Windows PowerShell 5.1 (native built-in) or PowerShell 7+
* **Dependencies**: Zero external dependencies, DLLs, or internet installers required.

---

## Author & License

Engineered and maintained by **[Abhishek Sonu](https://github.com/abhiisonu)**.

Licensed under the **MIT License**.
