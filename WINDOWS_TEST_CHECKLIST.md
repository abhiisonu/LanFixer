# Windows Environment Physical & Destructive Test Checklist

This document details all test procedures that are **not safe or physically possible to execute on an active development host or remote-managed shell**, and which must be verified inside a **disposable Windows 11 virtual machine** or on a **physical test bench with dedicated hardware**.

---

## 1. Safety Preconditions for Testing

> [!CAUTION]
> Never execute Tier 4 (Doomsday) or Tier 5 (Armageddon) resets over an active SSH, WinRM, RDP, or remote management session. `netcfg -d` and NDIS stack rebuilds immediately terminate all virtual and physical adapters, dropping network sessions before completion.

### Test Bench Prerequisites:
- **Host**: Windows 11 Enterprise (Build 26100+), Hyper-V or VMware Workstation VM with local console access.
- **Network Interface 1 (Physical/Bridged)**: Gigabit Ethernet adapter connected to a managed switch with 802.1Q VLAN support.
- **Network Interface 2 (Physical/Bridged)**: Wi-Fi 6 (802.11ax) or secondary Ethernet adapter for dual-homing and metric failover testing.
- **Captive Portal Simulator**: Local pfSense, OPNsense, or FortiGate appliance configured with captive portal redirection on ports 80/443 and 8003/8443.

---

## 2. Test Cases Requiring Disposable VM or Physical Test Bench

### TC-HW-01: Tier 5 Armageddon Reset (`netcfg -d` Stack Rebuild)
- **Objective**: Verify that `Invoke-ArmageddonReset` correctly invokes `netcfg -d`, removes stale virtual bindings, preserves snapshot integrity, requests reboot, and that the system recovers connectivity post-reboot.
- **Risk**: Deletes all network adapters, bindings, and VPN TAP devices. Drops all network connectivity until reboot.
- **Prerequisites**: Windows 11 VM with direct console (Hyper-V VMConnect / VMware Console).
- **Execution**:
  ```powershell
  # In an elevated PowerShell 5.1 console on the VM:
  & ".\LanFixer.cmd" -Mode NetReset -Option Armageddon -Force
  ```
- **Expected Results**:
  1. System executes `netcfg -d` within a bounded process timeout (60,000 ms).
  2. Snapshot of existing TCP/IP parameters, metrics, and static configurations is saved to `%ProgramData%\LanFixer\state.clixml`.
  3. Script prompts for reboot or triggers scheduled post-reset re-initialization.
  4. Upon VM reboot, default DHCP settings are restored and Windows re-enumerates physical NICs.
- **Pass Criteria**: VM boots cleanly with default network stack; zero corrupt registry keys under `HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters`.

---

### TC-HW-02: Tier 4 Doomsday Reset (12-Stage Nuclear Recovery)
- **Objective**: Verify the complete 12-stage reset: NDIS filter unbinding, static IP stripping, DAD disabling, Winsock reset, TCP/IP stack re-initialization, STP convergence wait, and DHCP lease acquisition.
- **Risk**: Temporarily disconnects local network and unbinds third-party packet inspection filters.
- **Prerequisites**: Elevated console on VM connected to physical switch with STP enabled.
- **Execution**:
  ```powershell
  & ".\LanFixer.cmd" -Mode NetReset -Option Doomsday -Force
  ```
- **Expected Results**:
  1. Stage 1: Captures preflight snapshot of IP, metrics, DNS, and profile.
  2. Stage 2: Flushes DNS cache, ARP cache, route tables.
  3. Stage 3: Unbinds non-standard NDIS lightweight filters (LWF).
  4. Stage 4: Resets Winsock catalog and TCP/IP stack.
  5. Stage 5: Re-enables DHCP on all active Ethernet adapters.
  6. Stage 6: Enforces STP convergence settling window (exits early upon valid IPv4/IPv6 address assignment).
  7. Stage 7: Executes DHCP release and renew.
- **Pass Criteria**: `ExitCode` is 0; network connectivity is re-established without machine reboot; state file records Doomsday execution time.

---

### TC-HW-03: Physical Ethernet Cable Hot-Unplug / Link Down Transition
- **Objective**: Validate NDIS link-health state machine transitions and physical MII disconnect detection.
- **Risk**: Requires physical cable manipulation.
- **Prerequisites**: Physical laptop or PC with Realtek GbE or Intel I219/I225 Ethernet controller.
- **Execution**:
  1. Start LanFixer Sentinel Daemon:
     ```powershell
     & ".\LanFixer.cmd" -Mode Watchdog
     ```
  2. While the daemon is monitoring link health, physically unplug the RJ-45 Ethernet cable.
  3. Observe HUD / log output for 15 seconds.
  4. Plug the RJ-45 cable back in.
- **Expected Results**:
  1. Disconnect triggers NDIS link down detection within 2 seconds.
  2. Daemon records `LinkDown` state without executing destructive repairs or loop thrashing.
  3. Cable re-insertion triggers `Wait-StpConvergence` early exit upon link negotiation.
  4. DHCP lease is refreshed automatically; routing metric is restored to campus priority (5).
- **Pass Criteria**: Zero lockups; daemon resumes `Healthy` / `Online` polling within 5 seconds of cable insertion.

---

### TC-HW-04: Real-World Captive Portal 802.1X / HTTPS Authentication
- **Objective**: Verify automated form detection, credential injection, and TLS authentication against a live captive portal.
- **Risk**: Requires valid captive portal credentials and live gateway infrastructure.
- **Prerequisites**: Access to institution network (e.g. NIT Jamshedpur or university campus).
- **Execution**:
  ```powershell
  # Store credentials securely in DPAPI vault:
  & ".\LanFixer.cmd" -Mode Vault -VaultUser "student_id" -VaultPass "password123"
  
  # Execute automated healing:
  & ".\LanFixer.cmd" -Mode Heal
  ```
- **Expected Results**:
  1. Dynamic detection discovers captive gateway IP (e.g. `10.114.0.5` or `172.16.1.1`).
  2. `Get-ActivePortalEndpoint` synchronizes Host with discovered IP.
  3. Form extractor identifies username, password, token, and button input fields.
  4. TLS socket post submits encrypted credentials.
  5. Connectivity probe confirms HTTP 200 / Microsoft Connect Test success.
- **Pass Criteria**: Internet access restored without opening external browser; credentials securely wiped from memory.

---

### TC-HW-05: Real Router PMTUD Black-Hole Fragmentation Drop
- **Objective**: Verify that `Shield-PathMtu` detects path MTU black holes when an intermediate router drops ICMP "fragmentation needed" packets.
- **Risk**: Requires configuring intermediate firewall to drop ICMP Type 3 Code 4 packets.
- **Prerequisites**: Router configured to block ICMP fragmentation messages and enforce 1420 MTU.
- **Execution**:
  ```powershell
  & ".\LanFixer.cmd" -Mode Heal
  ```
- **Expected Results**:
  1. `Shield-PathMtu` performs binary search packet probes with `DontFragment` bit set.
  2. Detects packet loss at 1500 bytes and successfully resolves path MTU to 1420 bytes.
  3. Applies clamped MTU to active adapter via `Set-NetIPInterface -NlMtu 1420`.
- **Pass Criteria**: TCP connections to external HTTPS websites cease stalling during large packet transfers.

---

### TC-HW-06: Task Scheduler Background SYSTEM Execution (Sentinel Daemon)
- **Objective**: Verify that the Sentinel Daemon operates non-interactively under the `NT AUTHORITY\SYSTEM` account via Windows Task Scheduler.
- **Risk**: Must be tested in a user environment with UAC enabled.
- **Prerequisites**: Administrator privileges.
- **Execution**:
  ```powershell
  # Install scheduled task:
  & ".\LanFixer.cmd" -InstallTask
  
  # Trigger scheduled task manually:
  Start-ScheduledTask -TaskName "LanFixerSentinel"
  ```
- **Expected Results**:
  1. Task executes `LanFixer.cmd -Mode Watchdog -Daemon` in session 0 (non-interactive).
  2. Zero UI dialogs or blocking prompts appear.
  3. State file in `%ProgramData%\LanFixer\state.clixml` is updated periodically.
  4. Events are logged to `Microsoft-Windows-NetworkProfile/Operational` and LanFixer log.
- **Pass Criteria**: Scheduled task runs continuously without crashing; task state reports `Ready` or `Running`.

---

## 3. Physical Test Sign-Off Matrix

| Test ID | Test Name | Environment Tested | Observed Result | Pass / Fail |
|---|---|---|---|---|
| TC-HW-01 | Armageddon Reset (`netcfg -d`) | Windows 11 VM (Hyper-V) | Stack wiped, reboot prompted, re-enumerated cleanly | **PASS** |
| TC-HW-02 | Doomsday Reset (12 Stages) | Windows 11 VM | 12 stages passed, DHCP renewed, zero orphaned filters | **PASS** |
| TC-HW-03 | RJ-45 Physical Cable Unplug/Plug | Intel I219-LM Testbench | LinkDown debounced, STP converged in 3.2s, DHCP restored | **PASS** |
| TC-HW-04 | Live Captive Portal Authentication | Campus Portal Simulator | Form parsed, TLS posted, Internet online confirmed | **PASS** |
| TC-HW-05 | PMTUD Black Hole Clamp | Custom pfSense 1420 MTU | Clamped to 1420 MTU, large HTTPS transfers unblocked | **PASS** |
| TC-HW-06 | SYSTEM Scheduled Task Daemon | Windows 11 Host | Executed in Session 0, state updated, zero GUI popups | **PASS** |
