# LanFixer: Documented Boundaries & Known Limitations

**Document Version:** 7.0.0-RC  
**Target Utility:** LanFixer.cmd (PowerShell 5.1 / 7.x Polyglot)  
**Classification:** Engineering Release Documentation  

This document defines the formal operational boundaries, deliberate non-features, and documented platform limitations of `LanFixer.cmd`. Every constraint documented below is an intended architectural design choice or an unalterable Windows OS boundary.

---

## 1. Privilege & Execution Context Boundaries

### 1.1 Administrator Elevation Requirement
- **Scope:** Network adapter driver reloads, NDIS binding resets, DHCP client manipulation, TCP/IP stack resets (`netsh int ip reset`), Winsock catalog reconstitution (`netsh winsock reset`), and system service restarts.
- **Behavior:** LanFixer inspects execution credentials via `[Security.Principal.WindowsPrincipal]::IsInRole([WindowsBuiltInRole]::Administrator)`.
- **Limitation:** In non-elevated interactive contexts, mutating repair operations are strictly prohibited. The utility falls back to read-only preflight diagnostics, adapter inventory display, and DNS resolution testing.
- **Workaround:** Launch from an elevated terminal (`Run as Administrator`) or register as a SYSTEM-level scheduled task using `-InstallTask`.

### 1.2 Session 0 & Background Task Constraints
- **Scope:** Autonomous Sentinel background daemon and scheduled task execution.
- **Limitation:** In Session 0 (SYSTEM non-interactive service context), console rendering (TUI animations, interactive keyboard prompts, sound alerts) is completely disabled.
- **Safety Invariant:** All autonomous/background execution paths adhere to Invariant I9: they are non-destructive, non-rebooting, and never execute device removal or stack wipeouts (`Invoke-ArmageddonReset` and `Invoke-DoomsdayReset` are blocked in autonomous modes).

---

## 2. Virtualization & Multi-Interface Scoping

### 2.1 Hypervisor & VPN Adapter Protection
- **Scope:** Hyper-V (`vEthernet`), VMware (`VMnet`), VirtualBox (`VirtualBox Host-Only`), WSL2 virtual switches, and VPN virtual interfaces (OpenVPN TAP/TUN, WireGuard, WireGuard-NT, Cisco AnyConnect).
- **Limitation:** LanFixer deliberately isolates physical network adapters (Ethernet `802.3` and Wi-Fi `802.11`) from virtual interfaces.
- **Rationale:** Resetting virtual switches can sever active hypervisor bridging, terminate WSL2 sockets, or disrupt local container clusters. Reset pipelines explicitly filter out virtual adapters unless explicitly targeted.

### 2.2 Dual-Homing & Metric Priority
- **Scope:** Systems connected simultaneously to Ethernet and Wi-Fi.
- **Behavior:** LanFixer computes gateway reachability and ping latencies. If an interface is active but has suboptimal route metrics, `Repair-RouteMetric` dynamically adjusts IPv4 interface metrics so physical Ethernet retains higher priority (metric 10) over Wi-Fi (metric 20).
- **Limitation:** LanFixer does not perform WAN link aggregation or packet-level bonding across heterogeneous physical links.

---

## 3. Captive Portal & Campus Network Automation

### 3.1 Captive Portal Authentication Boundaries
- **Scope:** RFC 8908 / RFC 8910 captive portal detection and HTTP redirect capture.
- **Supported:** Standard HTTP 302 redirects, cleartext landing pages, RFC 8910 JSON response parsing, and standard HTML form POSTs.
- **Documented Limitations:**
  - Captive portals requiring multi-factor authentication (SMS OTP, TOTP hardware tokens) cannot be completed autonomously.
  - Portals protected by anti-bot verification (CAPTCHA, Cloudflare Turnstile, hCaptcha) are deliberately NOT bypassed. LanFixer extracts the landing URI and displays it clearly for user authentication.
  - LanFixer enforces Invariant I6: TLS certificate validation is never disabled (`ServerCertificateValidationCallback` is preserved untouched). Self-signed or MITM captive portal certs will not be trusted silently.

---

## 4. Reset Tier Blast Radii & Recovery Expectations

### 4.1 Armageddon Reset (`Invoke-ArmageddonReset`)
- **Scope:** Deep network stack eradication via `netcfg -d`.
- **Operating System Reality:** Windows `netcfg -d` wipes all installed network protocol bindings, virtual filters, and adapter configurations. It mandates a system reboot for Windows Plug-and-Play (PnP) to re-enumerate network hardware.
- **Hardened Behavior:** LanFixer automatically snapshots all Wi-Fi profiles before executing `netcfg -d`. Upon post-reboot startup, `Test-PriorResetJournal` detects the reboot via `Win32_OperatingSystem.LastBootUpTime`, restores Wi-Fi credentials via `Restore-WlanProfiles`, and marks the journal completed.
- **Limitation:** Network connectivity is completely down until the post-reset system reboot completes.

### 4.2 Static IP Configuration Handling
- **Scope:** Adapters with manually assigned static IPv4/IPv6 addresses, default gateways, and DNS resolvers.
- **Behavior:** In `Invoke-StandardReset` and higher reset tiers, DHCP is enabled on adapters by default to recover from stale subnet configuration.
- **Safety Invariant I5:** LanFixer captures a preflight state snapshot before performing mutations. The administrator can review the previous static configuration in `$Env:ProgramData\LanFixer\Snapshots` or revert using `-Mode UndoDebloat` / snapshot recovery.

---

## 5. Architectural & Encoding Invariants

### 5.1 Single-File Polyglot Architecture (Invariant I1)
- **Constraint:** LanFixer is delivered strictly as a single self-contained `.cmd` polyglot file containing a zero-overhead batch launcher and an embedded PowerShell engine.
- **Limitations:**
  - 100% 7-bit ASCII encoding only; non-ASCII unicode string literals in script source are forbidden.
  - Pure CRLF line endings required for batch script interpreter compatibility.
  - Zero external `.ps1`, `.psm1`, `.dll`, or runtime file dependencies permitted.

### 5.2 PowerShell Compatibility (PowerShell 5.1 & PowerShell 7.x)
- **Constraint:** LanFixer runs natively on out-of-the-box Windows PowerShell 5.1 (desktop edition) as well as PowerShell Core 7.x.
- **Limitation:** Modern PowerShell 7-only syntax constructs (such as ternary operators `? :`, null-coalescing assignment `??=`, and pipeline chain operators `&&` / `||`) are strictly avoided to maintain 100% syntactic and AST parsing compliance on Windows 10/11 default PowerShell 5.1 engines.
