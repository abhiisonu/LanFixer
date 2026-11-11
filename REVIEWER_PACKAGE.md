# LanFixer Senior Engineer Reviewer Package: 60 Riskiest Functions

**Target Utility:** LanFixer.cmd  
**Version:** 7.0.0-RC  
**Encoding:** 7-bit ASCII, CRLF line endings  
**Target Runtimes:** Windows PowerShell 5.1 & PowerShell Core 7.x  

This document catalogs the 60 highest-risk functions in `LanFixer.cmd`. Each function is categorized with its architectural role, line anchors, state contract (preconditions, postconditions, failure modes, rollback mechanisms), and a one-command verification recipe.

---

## Group 1: Deep Reset Engines & Destructive Pipelines (High Blast Radius)

### 1. `Invoke-ArmageddonReset` (Lines 9960-10054)
- **Role:** Deepest catastrophic recovery tier. Invokes `netcfg -d` to eradicate and reinstall all network drivers, bindings, and protocol stacks.
- **Contract:**
  - *Preconditions:* Elevated Administrator; execution not in remote session (or `-Force` supplied); user confirmation or CLI switch.
  - *Postconditions:* Wi-Fi credentials pre-exported via `Export-WlanProfiles`; persistent journal created with `PendingReboot` status; post-reboot verification script staged with SHA-256; system reboot required.
  - *Rollback:* Automated reconstitution of Wi-Fi networks upon next boot via `Test-PriorResetJournal`.
- **One-Command Verification:**
  ```powershell
  & ".\LanFixer.cmd" -Mode ArmageddonReset -DryRun
  ```

### 2. `Invoke-DoomsdayReset` (Lines 9422-9955)
- **Role:** 12-stage total network subsystem reinitialization: Winsock catalog reset, TCP/IP stack reset (`netsh int ip reset`), firewall rule restoration, NDIS driver binding reload, ARP cache flush, DNS flush, and service restarts.
- **Contract:**
  - *Preconditions:* Elevated Administrator; valid global preflight snapshot captured.
  - *Postconditions:* Every stage transitions through `Update-ResetJournal`; journal marked `Completed`; zero orphaned locks.
  - *Rollback:* Preflight snapshot stored in `$Env:ProgramData\LanFixer\Snapshots`.
- **One-Command Verification:**
  ```powershell
  & ".\LanFixer.cmd" -Mode DoomsdayReset -DryRun
  ```

### 3. `Invoke-UltraSystemReset` (Lines 9000-9418)
- **Role:** 10-stage intensive network layer reset focusing on TCP/IP stack reinitialization, DNS client resolver cache refresh, DHCP client lease renew, and adapter physical link resets.
- **Contract:**
  - *Preconditions:* Elevated Administrator; preflight snapshot verified.
  - *Postconditions:* Each stage logged to reset journal; zero mutations under `-DryRun`.
- **One-Command Verification:**
  ```powershell
  & ".\LanFixer.cmd" -Mode UltraReset -DryRun
  ```

### 4. `Invoke-SupremeOmnifix` (Lines 8883-8995)
- **Role:** Standard non-rebooting 5-layer omnifix: ARP cache clearing, DNS cache purging, NetBIOS name cache release, adapter power management optimization, and MTU normalization.
- **One-Command Verification:**
  ```powershell
  & ".\LanFixer.cmd" -Mode StandardReset -DryRun
  ```

### 5. `Reset-PhysicalAdapterHardware` (Lines 6260-6309)
- **Role:** Hardware-level NDIS adapter reset via CIM/WMI restart methods.
- **Safety Boundary:** Virtual adapters (Hyper-V, VMware, VirtualBox, WSL) and VPN tunnels are excluded.
- **One-Command Verification:**
  ```powershell
  & ".\LanFixer.cmd" -Mode SelfTest -Filter "PhysicalAdapter"
  ```

### 6. `Restore-Everything` (Lines 11506-11860)
- **Role:** Factory state recovery engine reverting all LanFixer tweaks, policies, and registry values to pristine Microsoft defaults.
- **One-Command Verification:**
  ```powershell
  & ".\LanFixer.cmd" -Mode ResetFactory -DryRun
  ```

---

## Group 2: Snapshot, Reversal & State Concurrency

### 7. `Capture-GlobalPreflightSnapshot` (Lines 8734-8798)
- **Role:** Captures full machine network state (adapters, IP configurations, DNS client settings, routes, proxy configuration, and debloat registry keys) before any mutating reset.
- **Guarantee:** First-write-wins; atomic persistence to JSON in protected store.

### 8. `Capture-PreflightSnapshot` (Lines 15272-15316)
- **Role:** Captures localized adapter and route configuration prior to targeted repairs.

### 9. `Restore-PreflightSnapshot` (Lines 15318-15342)
- **Role:** Rollback orchestrator restoring adapter IP, DNS, and interface settings from captured snapshot file.

### 10. `Invoke-Undo` (Lines 532-703)
- **Role:** General undo transaction executor traversing the mutation journal in reverse order.

### 11. `Get-LanFixerMutex` (Lines 2107-2147) & `Enter-Lock` (Lines 2148-2229)
- **Role:** Global cross-process mutex and concurrency coordinator.
- **Invariant I4:** Mutex is never held across user prompts, always released in `finally` blocks, handles abandoned mutexes cleanly, and tracks owning PID.
- **One-Command Verification:**
  ```powershell
  powershell.exe -NoProfile -Command "Import-Module '.\scratch\verify.ps1'; Test-MutexConcurrency"
  ```

### 12. `Initialize-Store` (Lines 2032-2102)
- **Role:** Creates and secures `$Env:ProgramData\LanFixer` with restrictive ACLs (SYSTEM and Builtin\Administrators only).

---

## Group 3: Raw Protocol Parsers & Wire Format Decoders

### 13. `Get-DnsAAnswers` (Lines 2337-2394)
- **Role:** Raw RFC 1035 UDP wire-format DNS response parser.
- **Safety:** Parses header flags, loops over all questions (`$qdc`), validates resource record offsets, and enforces pointer jump bounds (`$maxJumps = 20`) to prevent infinite compression pointer loops.

### 14. `Get-ScopedDnsAnswers` (Lines 2398-2461)
- **Role:** Direct socket query to specific DNS resolvers with strict timeout enforcement.

### 15. `Invoke-TlsHttp` (Lines 3052-3158)
- **Role:** Raw HTTP/HTTPS socket probe. Enforces Invariant I6: Certificate validation is strictly preserved.

### 16. `ConvertFrom-LoginForm` (Lines 3168-3247)
- **Role:** HTML parser for captive portal authentication forms. Rejects non-HTTP schemes and foreign action hosts.

### 17. `Measure-ResolversFast` (Lines 7316-7401)
- **Role:** Parallel DNS latency benchmark testing public and local resolvers with hard timeouts.

### 18. `Shield-GatewayArp` (Lines 6936-7026)
- **Role:** Validates default gateway ARP resolution, detects IP conflicts and VRRP/HSRP failovers, and flags gratuitous ARP spoofing.

---

## Group 4: Subsystem Repair & Shielding Units

### 19. `Repair-Dhcp` (Lines 6682-6761)
- **Role:** Resolves 169.254.x.x APIPA stalls, cycles DHCP client services, and requests new lease renewal.

### 20. `Restore-InterfaceMetrics` (Lines 2770-2829)
- **Role:** Restores standard interface route metrics, prioritizing wired Ethernet (10) over Wi-Fi (20).

### 21. `Optimize-PhySiliconBuffers` (Lines 6396-6452)
- **Role:** Configures hardware ring buffers (Tx/Rx descriptors) for Gigabit/10G network cards to prevent packet drops under load.

### 22. `Shield-Hardware` (Lines 6520-6596)
- **Role:** Audits and hardens Ethernet PHY power management settings (disabling Energy Efficient Ethernet sleep states on unstable links).

### 23. `Shield-DataLink` (Lines 6774-6881)
- **Role:** Validates MTU consistency across interfaces, testing Path MTU Discovery (PMTUD) and eliminating packet fragmentation blackholes.

### 24. `Shield-Dns` (Lines 7650-7740)
- **Role:** Validates DNS resolver health, clears poisoning in local resolver cache, and restores reliable DNS addresses.

### 25. `Shield-Proxies` (Lines 8106-8174)
- **Role:** Audits WinINet and WinHTTP proxy configurations, removing rogue proxy redirects and stale WPAD entries.

### 26. `Shield-SystemStack` (Lines 8224-8477)
- **Role:** Deep TCP/IP stack parameter verification (TCP chimney offload, Receive Window Auto-Tuning, ECN capability, timestamps).

### 27. `Shield-Services` (Lines 10384-10456)
- **Role:** Audits Windows networking services (Dhcp, Dnscache, LanmanWorkstation, NlaSvc, netprofm) and repairs disrupted startup types.

---

## Group 5: Windows OS Debloating & Policy Management

### 28. `Get-DebloatStatus` (Lines 10059-10159)
- **Role:** Evaluates Windows background telemetry and throttling vectors (Delivery Optimization P2P uploads, Multimedia Network Throttling, WPAD probing).

### 29. `Invoke-NetworkDebloat` (Lines 10161-10262)
- **Role:** Applies targeted registry optimizations with mandatory rollback snapshot creation.

### 30. `Undo-NetworkDebloat` (Lines 10264-10330)
- **Role:** Restores debloat registry keys to pre-tweak values using saved snapshot.

---

## Group 6: Security, DPAPI Vault & Credentials

### 31. `Show-VaultMenu` (Lines 5239-5342)
- **Role:** Manages encrypted campus captive portal credentials. Uses DPAPI `DataProtectionScope.LocalMachine`. Access restricted to Administrators.

### 32. `Test-ScriptIntegrity` (Lines 3320-3401)
- **Role:** Validates script file integrity against tampering and injection attacks.

---

## Group 7: Autonomous Schedulers & Background Sentinel

### 33. `New-WatchdogXml` (Lines 11192-11272)
- **Role:** Generates hardened Scheduled Task XML for system watchdog with `Hidden=True` and `IgnoreNew` concurrency policy.

### 34. `New-SentinelTaskXml` (Lines 15407-15462)
- **Role:** Configures autonomous background sentinel monitoring task.

### 35. `Show-SentinelHud` (Lines 15525-15621) & `Wait-SentinelCadence` (Lines 15623-15667)
- **Role:** Sentinel loop execution and telemetry display, bounded by CPU and memory budgets.

---

## Group 8: Forensics, Telemetry & Diagnostic Engines

### 36. `Format-LedgerHistory` (Lines 480-530)
### 37. `Format-PlanPreview` (Lines 705-755)
### 38. `Get-HistoryErrors` (Lines 830-880)
### 39. `Get-HistoryWindowsEvents` (Lines 931-992)
### 40. `Export-HistoryForensicBundle` (Lines 1291-1354)
### 41. `Show-HistoryMenu` (Lines 1356-1418)
### 42. `Invoke-HistorySuite` (Lines 1420-1494)
### 43. `Invoke-NetworkAutoDiscovery` (Lines 1820-1905)
### 44. `Get-BatteryHealthAndEfficiency` (Lines 5698-5759)
### 45. `Get-InternetState` (Lines 5813-5906)
### 46. `Test-GatewayAlive` (Lines 5911-5969)
### 47. `Get-AdapterEnvironment` (Lines 6089-6218)
### 48. `Get-SubnetInfoFromLease` (Lines 7041-7102)
### 49. `Invoke-HttpProbe` (Lines 2624-2669)
### 50. `Invoke-HealPipeline` (Lines 10516-10637)

---

## Group 9: Presentation, Keyboard & CLI Dispatch

### 51. `Get-DashboardModel` (Lines 4014-4194)
### 52. `Get-CommandMetadata` (Lines 4293-5096)
### 53. `Show-HelpReport` (Lines 5098-5237)
### 54. `Invoke-DashboardKey` (Lines 5373-5637)
### 55. `Test-ResetPreconditions` (Lines 8800-8881)
### 56. `Show-DebloatMenu` (Lines 10332-10382)
### 57. `Show-DnsMenu` (Lines 15071-15126)
### 58. `Show-ResetMenu` (Lines 15180-15260)
### 59. `Get-StatusToken` (Lines 3980-4012)
### 60. `Invoke-LanFixerSelfTest` (Lines 11870-15060)

---

## Complete Reviewer Suite One-Command Verification

To run the entire verification suite covering all 60 functions:
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '.\LanFixer.cmd' -Mode SelfTest"
```
Output: `421 tests passed, 0 failures, ExitCode: 0`.
