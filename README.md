# LanFixer

A portable, self-contained network repair and stabilization utility for Windows (Windows 10/11, Ethernet & Dual-Homed). Single script (`.cmd`) built entirely on native PowerShell—requires no installation, runtime dependencies, or third-party tools.

[**Download LanFixer.cmd (v6.0.0)**](https://github.com/abhiisonu/LanFixer/releases/download/v6.0.0/LanFixer.cmd)

---

## What It Does

Resolves persistent network drops, DHCP assignment failures, and routing conflicts commonly experienced on campus, hostel, and enterprise networks:

- **DHCP & Lease Recovery**: Fixes APIPA assignments (169.254.x.x), unblocks dead DHCP leases, and safely manages DHCP Option 15 domain transitions.
- **Dual-Homed Routing Coexistence**: Eliminates metric collisions between simultaneous Ethernet and Wi-Fi connections with intelligent priority switching.
- **Captive Portal Engine**: Seamlessly discovers captive login URLs while strictly isolating stored credentials from unverified rogue DHCP suffixes.
- **ARP & Gateway Shielding**: Locks and monitors gateway MAC entries against ARP spoofing, router flapping, and stale switch caches.
- **Bounded Path-MTU Discovery**: Discovers maximum transmission units with fast-fail ICMP probing, preventing silent blackhole drops and socket timeouts.
- **Non-Campus DNS Rescue**: Automatically rescues DNS resolution when off-campus without DNS flapping.

---

## Usage

1. Download [LanFixer.cmd](https://github.com/abhiisonu/LanFixer/releases/download/v6.0.0/LanFixer.cmd).
2. Right-click the file and select **Run as administrator**.
3. Press **1** to run the automated diagnostic and repair pipeline.

---

## Interactive Menu Options

When launched, the console displays live telemetry (adapter status, IP configuration, gateway response time, latency pulse). Controls can be triggered with a single keypress:

| Key | Function | Description |
| :---: | :--- | :--- |
| **1** | **Quick Heal** | Executes automated recovery across physical link, DHCP lease, ARP table, DNS resolvers, and route metrics. |
| **2** | **Arm Watchdog Guard** | Installs a lightweight Windows task that automatically runs repairs upon cable connection, sleep wake, or network disconnect. |
| **3** | **DNS Profile Engine** | Toggles between local network DHCP resolvers (for internal services) and public secure DNS (Cloudflare / Google / Hybrid). |
| **4** | **Live Latency Probe** | Measures ping latency, jitter, and packet loss to local gateway and internet endpoints. |
| **5** | **Flush DNS & ARP** | Purges Windows DNS resolver cache, ARP table, NetBIOS cache, and internal connection cache. |
| **6** | **Diagnostics Audit** | Displays detailed hardware status, link speed, duplex mode, and adapter lease information. |
| **7** | **Open Portal Page** | Adds direct route rules to the login host and opens captive portal in default browser. |
| **A** | **Portal Login Vault** | Manages encrypted credentials for headless background authentication. |
| **G** | **Headless Auto-Login** | Authenticates captive portals silently in background using DPAPI-encrypted credentials. |
| **M** | **Routing Engine** | Configures interface priority: Adaptive (auto-managed), Forced Ethernet, or Forced Wi-Fi. |
| **T** | **Dry-Run Preview** | Simulates full repair pipeline without making any system or adapter changes. |
| **R** | **Export Report** | Generates detailed system and network diagnostic report file on Desktop. |
| **S** | **Run Self-Test** | Runs comprehensive verification suite testing 165+ cmdlets, drivers, crypto, and logic assertions. |
| **X** | **Full Net Reset** | Deep recovery of TCP/IP stack, WFP filters, and network services. Requires typing `yes` to confirm. |
| **8** | **Disarm Watchdog** | Unregisters background auto-heal scheduled task cleanly. |
| **9** | **Factory Reset** | Reverts all system and adapter changes back to default Windows configurations. |
| **0** | **Decision Guide** | Interactive reference matrix matching network symptoms to 1-touch actions. |
| **Q** | **Quit** | Closes application. |

---

## Command Line Arguments

For automation, scheduled maintenance, and CI/CD validation:

```cmd
LanFixer.cmd -Mode Heal                :: Run repair sequence and exit
LanFixer.cmd -Mode QuickProbe          :: Output network status and latency
LanFixer.cmd -Mode FlushCache          :: Flush DNS, ARP, and routing cache
LanFixer.cmd -Mode InstallWatchdog     :: Register background auto-heal task
LanFixer.cmd -Mode UninstallWatchdog   :: Remove background task
LanFixer.cmd -Mode ResetFactory        :: Revert all settings to Windows defaults
LanFixer.cmd -Mode Heal -DryRun        :: Preview actions without modifying state
LanFixer.cmd -Mode SelfTest -NoPause   :: Execute full 165+ assertion regression suite
LanFixer.cmd -Mode Report              :: Generate full network & hardware telemetry report
```

---

## Architecture & Security Invariants

- **Native Execution**: Built 100% on native Windows PowerShell 5.1 cmdlets and .NET Framework APIs. No external executables, scripts, or DLLs are required or downloaded.
- **DPAPI Vault Protection**: Credentials saved for portal sign-in are encrypted on disk via Windows Data Protection API (DPAPI, `LocalMachine` scope) and protected by ACLs granting access solely to `SYSTEM` and `Administrators`.
- **Rogue DHCP Isolation (`Test-CredentialPortalHost`)**: Headless credential dispatch strictly isolates stored credentials to configured, trusted domains and prevents password leakage to untrusted DHCP Option 15 suffixes.
- **Fail-Safe Rollback**: Network metrics, MTU, and adapter properties are snapshotted prior to any mutation. Option 9 (`ResetFactory`) safely restores original settings.
