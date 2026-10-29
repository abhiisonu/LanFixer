# LanFixer

LanFixer is a single-file network stabilization and repair utility for Windows 10 and 11. It resolves common Ethernet and dual-homed (Ethernet + Wi-Fi) networking failures on campus, hostel, enterprise, and home networks.

It has zero third-party dependencies, requires no installation, and runs directly in standard Windows Command Prompt and PowerShell.

---

## Quickstart

1. Download [`LanFixer.cmd`](https://github.com/abhiisonu/LanFixer/releases/latest/download/LanFixer.cmd).
2. Right-click the file and choose **Run as administrator**.
3. Press `1` for **Quick Heal** to diagnose and repair the connection.

---

## What It Does

- **Dual-Homed Metric Management:** Prevents an unauthenticated Ethernet cable from dropping working Wi-Fi internet. Wi-Fi remains primary while captive portal routes are safely isolated through Ethernet.
- **DHCP & Lease Recovery:** Escalates past APIPA (`169.254.x.x`) deadlocks through progressive release, Winsock reset, and NDIS power cycling.
- **Captive Portal Automation:** Automatically discovers login endpoints via HTTP redirects and DHCP options. Supports automated headless sign-in using Windows DPAPI machine-level credential encryption.
- **Hardware & Power Stability:** Disables driver features (Energy Efficient Ethernet, USB selective suspend) that cause Ethernet link flapping on laptops and USB dongles.
- **Dead Proxy Liquidation:** Scans for dead `127.0.0.1:port` proxies left behind by crashed tools (VPNs, Fiddler, etc.) and removes them from registry and environment variables.
- **Background Watchdog:** Optional lightweight scheduled task that heals the connection automatically on link connect or wake from sleep.
- **Non-Destructive Rollback:** Snapshots original settings before making changes. Factory reset (`9`) restores everything back to your original configuration.

---

## Interactive Controls

Running `LanFixer.cmd` opens a live console dashboard with real-time gateway latency:

| Key | Action | Description |
| :---: | :--- | :--- |
| `1` | **Quick Heal** | Runs the 7-layer repair pipeline and automatically signs into captive portals if credentials are saved. |
| `2` | **Arm Watchdog** | Installs an autonomous background task running under SYSTEM for automatic healing. |
| `3` | **DNS Profile** | Switch between Adaptive (Campus before login, Public after), Campus DHCP, Hybrid, Cloudflare, or reset to DHCP. |
| `4` | **Latency Probe** | Tests ping, jitter, and packet loss to both Ethernet and Wi-Fi gateways. |
| `5` | **Flush Caches** | Flushes DNS cache, ARP entries, NetBIOS, and refreshes network location services. |
| `6` | **Diagnostics** | Full audit of adapter hardware, speed/duplex, lease times, IPv6, and event logs. |
| `7` | **Open Portal** | Renews DHCP if needed, sets captive route rules, and opens the login page in your browser. |
| `A` | **Vault** | Interactive manager for saved portal credentials (encrypted with DPAPI). |
| `G` | **Auto-Login** | Silent background captive portal authentication using saved credentials. |
| `M` | **Routing Priority** | Configures traffic priority: Adaptive, Forced Ethernet, Forced Wi-Fi, or Windows Default. |
| `T` | **Dry Run** | Simulates the repair pipeline without applying any changes. |
| `R` | **Export Report** | Saves a full diagnostics and activity report to your Desktop. |
| `S` | **Self-Test** | Runs the internal 166+ test suite verifying cmdlets, logic, and crypto. |
| `X` | **Full Net Reset** | Deep recovery of TCP/IP stack, WFP filters, proxies, and network services. |
| `8` | **Disarm Watchdog** | Removes the background scheduled task. |
| `9` | **Factory Reset** | Reverts all system and adapter modifications back to original settings. |
| `0` | **Guide** | Displays problem-to-action troubleshooting matrix. |
| `Q` | **Quit** | Exits the dashboard. |

---

## Command-Line Usage

LanFixer can be run non-interactively in scripts, batch files, or Task Scheduler:

```cmd
:: Run repair and exit
LanFixer.cmd -Mode Heal

:: Preview repairs without making changes
LanFixer.cmd -Mode Heal -DryRun

:: Deep network reset
LanFixer.cmd -Mode Omnifix

:: Run latency and connectivity probe
LanFixer.cmd -Mode QuickProbe

:: Flush all network caches
LanFixer.cmd -Mode FlushCache

:: Register or remove background watchdog task
LanFixer.cmd -Mode InstallWatchdog
LanFixer.cmd -Mode UninstallWatchdog

:: Run internal verification suite
LanFixer.cmd -Mode SelfTest -NoPause

:: Generate diagnostic report
LanFixer.cmd -Mode Report

:: Restore factory settings
LanFixer.cmd -Mode ResetFactory
```

---

## Security & Architecture

- **Zero Dependencies:** Written purely in native Windows batch and PowerShell 5.1. Requires no extra runtimes, Python, Node.js, or external DLLs.
- **DPAPI Vault:** Stored portal credentials are encrypted on disk via Windows Data Protection API (`LocalMachine` scope) with hardware entropy. Access is restricted to `SYSTEM` and `Administrators`.
- **Rogue DHCP Protection:** Stored passwords are never sent to unverified domains handed out by DHCP servers; credentials are only sent to configured campus hosts or pinned certificates.
- **Pure ASCII / CRLF:** Strictly ASCII encoded with Windows CRLF line endings to prevent codepage issues across localized Windows installs.

---

## License

MIT License. Designed and maintained by [Abhishek Sonu](https://github.com/abhiisonu).
