# LanFixer

A lightweight, self-healing network stabilizer and captive portal assistant for Windows (10/11). Single-file script (.cmd wrapping pure PowerShell) designed to keep hostel and campus wired connections stable without manual troubleshooting.

---

## What It Does

When connected to campus or hostel Ethernet, Windows often suffers from:
- Stale IP leases (APIPA 169.254.x.x or DHCP dropouts)
- Routing metric conflict between Wi-Fi and Ethernet
- Captive portal login timeouts and DNS lockouts
- ARP spoofing or gateway flapping

**LanFixer** runs an automated 7-layer heal pipeline, balances route metrics, and manages credentials securely so your connection stays alive 24/7.

---

## Quick Start

1. Right-click **LanFixer.cmd** and select **Run as Administrator**.
2. Press **1** on your keyboard to run the **Smart 7-Layer Heal**.
3. That's it. Your link, routes, and DNS are restored.

---

## Interactive Dashboard Keys

| Key | Action | What It Does |
| :---: | :--- | :--- |
| **1** | **Smart 7-Layer Heal** | Complete physical, DHCP, ARP, DNS, and route recovery |
| **2** | **Arm Watchdog Guard** | Background scheduled task auto-repairs on cable plug / wake |
| **3** | **DNS Profile Switcher** | Switch between Campus DHCP and Adaptive Public DNS |
| **4** | **Live Latency & Loss Probe** | Real-time sparkline ping to gateway and internet |
| **5** | **Flush Caches** | Flushes DNS client cache, ARP neighbor table, and NetBIOS |
| **6** | **System Diagnostics** | Comprehensive network adapter and stack inspection |
| **7** | **Open Portal Page** | Launches default browser to campus captive portal |
| **G** | **Headless Auto-Login** | Silent background sign-in using encrypted credentials |
| **M** | **Routing Priority Engine** | Force Ethernet, force Wi-Fi, or use Adaptive balance |
| **X** | **Full Net Reset** | Aggressive emergency recovery (requires confirmation) |
| **9** | **Factory Reset** | Restores all settings back to Windows defaults |
| **Q** | **Quit** | Exits the dashboard |

---

## Security & Privacy

- **Zero Third-Party Dependencies**: Uses built-in Windows cmdlets, kernel APIs, and .NET primitives only.
- **DPAPI Credential Encryption**: Saved portal passwords are encrypted using machine-scope DPAPI (ProtectedData). Never stored in plain text.
- **Safe Rollback**: Every network modification snapshots original values first, allowing full restoration to Windows defaults via [9].
- **Pure ASCII**: Source code contains 0 binary blobs or obfuscated payloads.
