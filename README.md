# LanFixer

> **Automated network stabilizer and captive portal assistant for Windows.**  
> A single self-contained script that diagnoses and repairs connection drops, DHCP failures, route metric conflicts, and captive portal lockouts.

[**Download LanFixer.cmd**](https://github.com/abhiisonu/LanFixer/releases/download/v4.8.0/LanFixer.cmd) &nbsp;&bull;&nbsp; [Releases](https://github.com/abhiisonu/LanFixer/releases) &nbsp;&bull;&nbsp; [Quick Start](#quick-start) &nbsp;&bull;&nbsp; [Dashboard Controls](#dashboard-controls)

---

## Overview

Hostel, university, and enterprise LANs frequently experience connection instabilities that standard Windows troubleshooters fail to resolve:
- **APIPA Stalls (169.254.x.x)**: Windows assigns a fallback self-assigned IP when the DHCP server is slow to respond.
- **Route Fighting**: Connecting both Ethernet and Wi-Fi often leads to metric collisions, starving active connections.
- **Captive Portal Blackholes**: Network firewalls drop traffic before authentication, causing DNS resolution to fail across all adapters.
- **Gateway Flapping**: Stale ARP neighbor tables hold dead MAC addresses after campus switch failovers.

LanFixer identifies which hop failed and restores your link automatically.

---

## Quick Start

1. **Download** [LanFixer.cmd](https://github.com/abhiisonu/LanFixer/releases/download/v4.8.0/LanFixer.cmd).
2. **Right-click** the file and select **Run as administrator**.
3. **Press 1** to run the 7-layer heal pipeline.

No installation, runtime dependencies, or background services required.

---

## Interactive Dashboard

When launched, LanFixer opens a real-time console dashboard displaying adapter status, IP lease state, live gateway ping, and DNS health:

`	ext
  LAN FIXER 4.8.0 . CONTROL CENTER
  ===========================================================================
  STATUS   : Online (Ethernet First)
  ADAPTER  : Realtek PCIe GbE Family Controller (1000 Mbps Full Duplex)
  IPV4     : 10.1.12.84 / 24  |  Gateway: 10.1.12.1  |  DNS: Campus DHCP
  PULSE    : Gateway 1.2 ms [............] 0% loss  |  Internet: OK
  ===========================================================================
`

---

## Dashboard Controls

Every action is accessible via a single keypress:

| Key | Mode | Description |
| :---: | :--- | :--- |
| **1** | **Smart 7-Layer Heal** | Full automated recovery. Resets physical link, renews DHCP lease, reconciles gateway ARP, steers captive portal DNS, and repairs routing tables. |
| **2** | **Arm Watchdog Guard** | Installs a lightweight Windows Scheduled Task that automatically triggers a background heal when you plug in a cable or wake your PC from sleep. |
| **3** | **DNS Profile Switcher** | Toggles between **Campus DHCP** (required for university intranets and student ERP portals) and **Adaptive Public DNS** (Cloudflare 1.1.1.1 & Google 8.8.8.8). |
| **4** | **Latency & Loss Probe** | Runs continuous ICMP and HTTP latency probes against your default gateway and upstream internet to pinpoint jitter and packet loss. |
| **5** | **Flush Caches** | Flushes the Windows DNS client cache, clears the ARP neighbor table, and resets NetBIOS name resolution in one step. |
| **6** | **System Diagnostics** | Inspects adapter link speed, duplex mode, DHCP lease expiry, MTU sizing, and active IP routes. |
| **7** | **Open Portal Page** | Injects /32 host routes to ensure the captive portal IP is reachable, then launches your default browser directly to the login URL. |
| **G** | **Headless Auto-Login** | Authenticates silently in the background using your saved portal credentials. No browser popups required. |
| **M** | **Routing Priority Engine** | Sets multi-homing traffic behavior: **Adaptive** (auto-balance), **Ethernet First** (prefer wired), or **Wi-Fi First** (prefer wireless). |
| **X** | **Full Net Reset** | Aggressive emergency recovery. Rescans the PnP bus, removes dead WFP proxy filters, resets TCP/IP stack to MTU 1500, and restarts DHCP/NLA services. *(Prompts for confirmation)* |
| **9** | **Factory Reset** | Reverts every adapter, metric, and registry entry back to default Windows settings and deletes all scheduled tasks. |
| **Q** | **Quit** | Exits the dashboard without making changes. |

---

## How the 7-Layer Heal Pipeline Works

Pressing **1** executes seven sequential recovery checks:

1. **Hardware & Physical Link**: Verifies adapter operational status, duplex negotiation, and power-saving settings.
2. **Data Link & ARP**: Reconciles gateway MAC address against neighbor table to prevent ARP cache poisoning.
3. **DHCP & IPv4 Lease**: Requests a clean DHCP lease; falls back safely to saved static configurations if present.
4. **Captive Route Steering**: Injects precise /32 persistent routes to portal IPs, preventing captive redirection loops.
5. **DNS & Resolution**: Validates local and external resolution; clears poisoned negative DNS cache records.
6. **Multi-Homed Metric Planning**: Re-evaluates all connected interfaces (Ethernet, Wi-Fi, USB/Bluetooth tethering) to avoid routing blackholes.
7. **Internet Verification**: Performs two-stage HTTP 204 validation to ensure end-to-end connectivity.

---

## Automation & CLI

LanFixer supports non-interactive execution for scripts and deployment:

`cmd
:: Run automated heal and exit
LanFixer.cmd -Mode Heal

:: Check link health and latency
LanFixer.cmd -Mode QuickProbe

:: Flush DNS and ARP caches silently
LanFixer.cmd -Mode FlushCache

:: Arm the background auto-repair watchdog
LanFixer.cmd -Mode InstallWatchdog

:: Remove the watchdog task
LanFixer.cmd -Mode UninstallWatchdog

:: Preview changes without modifying system state
LanFixer.cmd -Mode Heal -DryRun

:: Restore clean Windows factory defaults
LanFixer.cmd -Mode ResetFactory
`

---

## Security & System Integrity

- **Zero External Binaries**: Written strictly in Windows Batch and PowerShell using native OS cmdlets and .NET primitives. No third-party EXEs or DLLs.
- **DPAPI Credential Protection**: Captive portal credentials stored for headless sign-in are encrypted using machine-scoped Windows Data Protection API (System.Security.Cryptography.ProtectedData). They cannot be read in plaintext or exported to another machine.
- **Full Reversibility**: LanFixer takes snapshots of your adapter metrics, DNS servers, and configuration before applying any change. Pressing 9 completely unwinds all modifications.
