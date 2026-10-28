# LanFixer

A self-healing network stabilizer and captive portal assistant for Windows. Single .cmd file wrapping native PowerShell—no installations, no dependencies, no background bloat.

[**Download LanFixer.cmd**](https://github.com/abhiisonu/LanFixer/releases/download/v4.8.0/LanFixer.cmd)

---

## Why Use It

Campus, hostel, and enterprise networks often drop out due to:
- DHCP lease failures or getting stuck on APIPA (169.254.x.x).
- Routing metric conflicts when both Ethernet and Wi-Fi are plugged in.
- Captive portal login timeouts and DNS lockouts.
- Gateway switch flapping or ARP table poisoning.

LanFixer diagnoses the exact hop that failed and applies the fix automatically.

---

## Quick Start

1. Download [LanFixer.cmd](https://github.com/abhiisonu/LanFixer/releases/download/v4.8.0/LanFixer.cmd).
2. Right-click and choose **Run as administrator**.
3. Press **1** on your keyboard to run the heal pipeline.

---

## Dashboard Key Guide

When opened, LanFixer displays a terminal dashboard showing your live adapter state, IP lease, gateway ping, and DNS status. Press any key to run an action:

| Key | Action | What It Does |
| :---: | :--- | :--- |
| **1** | **Smart 7-Layer Heal** | Complete pipeline: resets physical link, requests DHCP lease, clears ARP, sets clean DNS, and repairs route tables. |
| **2** | **Arm Watchdog Guard** | Installs a lightweight Windows Scheduled Task that auto-heals your network on cable plug-in, sleep/wake, or adapter reconnect. |
| **3** | **DNS Profile Switcher** | Toggles between Campus DHCP resolvers (for internal portals/ERP) and Adaptive Public DNS (Cloudflare/Google). |
| **4** | **Live Latency & Loss Probe** | Runs a live latency test to your local gateway and public internet with loss percentage. |
| **5** | **Flush Caches** | Flushes DNS resolver cache, clears stale ARP neighbor tables, and purges NetBIOS cache. |
| **6** | **Full System Diagnostic** | Prints adapter hardware details, DHCP server IP, lease times, and MTU configuration. |
| **7** | **Open Portal Page** | Opens your default web browser directly to the captive login page with route protection. |
| **G** | **Headless Auto-Login** | Automatically logs in to the captive portal in the background using saved credentials without opening a browser. |
| **M** | **Routing Priority Engine** | Sets routing preference: prioritize Ethernet, prioritize Wi-Fi, or balance automatically based on connection quality. |
| **X** | **Full Net Reset** | Deep recovery: clears proxies, resets TCP/IP stack, resets MTU 1500, and restarts network services. *(Requires typing yes to confirm)* |
| **9** | **Factory Reset** | Reverts all settings back to standard Windows defaults and uninstalls any background tasks. |
| **Q** | **Quit** | Exits the dashboard. |

---

## Command Line Usage

For scripting, automation, or task schedulers:

`cmd
LanFixer.cmd -Mode Heal                :: Run 7-layer heal once and exit
LanFixer.cmd -Mode QuickProbe          :: Print link status and gateway latency
LanFixer.cmd -Mode FlushCache          :: Flush DNS and ARP caches silently
LanFixer.cmd -Mode InstallWatchdog     :: Arm background auto-repair task
LanFixer.cmd -Mode UninstallWatchdog   :: Remove background task
LanFixer.cmd -Mode ResetFactory        :: Revert everything back to Windows defaults
LanFixer.cmd -Mode Heal -DryRun        :: Show what would change without modifying anything
`

---

## Security & Architecture

- **Native Only**: Built strictly on built-in Windows cmdlets, kernel APIs, and .NET primitives. Zero external binaries or downloads.
- **Encrypted Credentials**: Saved portal credentials are encrypted via Windows Data Protection API (DPAPI) with LocalMachine scope. Passwords are never stored in plain text.
- **Zero Lock-In**: LanFixer takes snapshots before modifying any setting. Running option **9** puts all drivers, metrics, and services back to their exact original state.
