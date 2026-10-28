# LanFixer

A portable, self-contained network repair utility for Windows. Single script (.cmd) built on native PowerShell—requires no installation, runtime dependencies, or third-party tools.

[**Download LanFixer.cmd**](https://github.com/abhiisonu/LanFixer/releases/download/v5.0.0/LanFixer.cmd)

---

## What It Does

Resolves persistent network drops, DHCP assignment failures, and routing conflicts commonly experienced on campus, hostel, and enterprise networks:

- **DHCP & Lease Recovery**: Fixes APIPA assignments (169.254.x.x) and renews stale network configurations.
- **Multi-Interface Routing**: Eliminates metric collisions between simultaneous Ethernet and Wi-Fi connections.
- **Captive Portal Access**: Fixes DNS lockouts and routing failures before captive portal authentication.
- **ARP Resolution**: Corrects stale gateway MAC entries following switch or subnet changes.

---

## Usage

1. Download [LanFixer.cmd](https://github.com/abhiisonu/LanFixer/releases/download/v5.0.0/LanFixer.cmd).
2. Right-click the file and select **Run as administrator**.
3. Press **1** to run the automated diagnostic and repair pipeline.

---

## Interactive Menu Options

When launched, the console displays current connection telemetry (adapter status, IP configuration, gateway response time). Controls can be triggered with a single keypress:

| Key | Function | Description |
| :---: | :--- | :--- |
| **1** | **Smart 7-Layer Heal** | Executes automated recovery across physical link, DHCP lease, ARP table, DNS resolvers, and route metrics. |
| **2** | **Arm Watchdog Guard** | Installs a lightweight Windows task that automatically runs repairs upon cable connection or system wake. |
| **3** | **DNS Profile Engine** | Toggles between local network DHCP resolvers (for internal services) and public secure DNS (Cloudflare / Google). |
| **4** | **Live Latency Probe** | Measures ping latency, jitter, and packet loss to local gateway and internet endpoints. |
| **5** | **Flush DNS & ARP** | Purges Windows DNS resolver cache, ARP table, and NetBIOS cache to clear stale routes. |
| **6** | **Diagnostics Audit** | Displays detailed hardware status, link speed, duplex mode, and adapter lease information. |
| **7** | **Open Portal Page** | Adds direct route rules to the login host and opens captive portal in default browser. |
| **A** | **Portal Login Vault** | Manages encrypted credentials for headless background authentication. |
| **G** | **Headless Auto-Login** | Authenticates captive portals silently in background using locally encrypted credentials. |
| **M** | **Routing Engine** | Configures interface priority: Automatic (balanced), Ethernet preferred, or Wi-Fi preferred. |
| **T** | **Dry-Run Preview** | Simulates full repair pipeline without making any system or adapter changes. |
| **R** | **Export Report** | Generates detailed system and network diagnostic report file on Desktop. |
| **S** | **Run Self-Test** | Runs comprehensive verification suite testing cmdlets, drivers, crypto, and logic assertions. |
| **X** | **Full Net Reset** | Deep recovery of TCP/IP stack, WFP filters, and network services. Requires typing yes to confirm. |
| **8** | **Disarm Watchdog** | Unregisters background auto-heal scheduled task cleanly. |
| **9** | **Factory Reset** | Reverts all system and adapter changes back to default Windows configurations. |
| **0** | **Decision Guide** | Interactive reference matrix matching network symptoms to 1-touch actions. |
| **Q** | **Quit** | Closes application. |

---

## Command Line Arguments

For automation and scheduled maintenance:

`cmd
LanFixer.cmd -Mode Heal                :: Run repair sequence and exit
LanFixer.cmd -Mode QuickProbe          :: Output network status and latency
LanFixer.cmd -Mode FlushCache          :: Flush DNS and ARP tables
LanFixer.cmd -Mode InstallWatchdog     :: Register background auto-heal task
LanFixer.cmd -Mode UninstallWatchdog   :: Remove background task
LanFixer.cmd -Mode ResetFactory        :: Revert all settings to Windows defaults
LanFixer.cmd -Mode Heal -DryRun        :: Preview actions without modifying state
`

---

## Security

- **Native Execution**: Built entirely on built-in Windows cmdlets and .NET APIs. No external executables, scripts, or DLLs are downloaded or executed.
- **Encrypted Vault**: Credentials saved for portal sign-in are encrypted on disk via Windows Data Protection API (DPAPI, LocalMachine scope). Passwords cannot be exported or decrypted on another device.
- **Safe Rollback**: Network metrics and adapter properties are snapshotted prior to any mutation. Option 9 restores the system to its original configuration.
