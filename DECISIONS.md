# Architecture & Release Engineering Decisions Log

**Project:** LanFixer.cmd (Single-file batch+PowerShell network utility)  
**Release Target:** v7.0.0-RC  
**Charter Stage:** Final Hardening & Verification Protocol  

---

### DEC-001: Fine-Grained Journaling for Intensive Reset Pipelines
- **Date:** 2026-11-11
- **Context:** During crash and interruption testing of multi-stage resets (`Invoke-UltraSystemReset` and `Invoke-DoomsdayReset`), failures occurring during intermediate stages (such as stage 4 TCP/IP reset or stage 7 NDIS rebind) left the journal in a generic `InProgress` state without recording the exact sub-stage.
- **Alternatives Considered:**
  1. Record only start and completion timestamps in journal.
  2. Emit log lines without updating the on-disk journal state.
  3. Update on-disk journal before each stage transition (`Update-ResetJournal`).
- **Decision:** Adopt Alternative 3. Every stage now persists its specific stage index and description before execution. If power is lost or the host reboots abruptly, the post-reboot audit identifies the exact failing operation.
- **Vetoes:** SRE / Chaos specialist vetoed Alternative 1 and 2 due to diagnostic opacity under sudden system crash.

---

### DEC-002: Automated Wi-Fi Reconstitution Lifecycle for Post-Reboot Armageddon
- **Date:** 2026-11-11
- **Context:** `Invoke-ArmageddonReset` runs `netcfg -d` which clears the network stack and requires a system reboot. Prior versions exported Wi-Fi profiles prior to reset, but never automatically imported them post-boot, leaving the user with lost wireless networks and a perpetual `PendingReboot` status.
- **Alternatives Considered:**
  1. Prompt user manually via CLI instructions to run `Restore-WlanProfiles`.
  2. Automatically detect reboot in `Test-PriorResetJournal` using `Win32_OperatingSystem.LastBootUpTime`, restore profiles, and transition journal to `Completed`.
  3. Avoid `netcfg -d` entirely and rely solely on `pnputil /restart-device`.
- **Decision:** Adopt Alternative 2. `Test-PriorResetJournal` evaluates OS boot time against reset timestamp. If a reboot occurred, it automatically calls `Restore-WlanProfiles`, cleans staged temporary artifacts, and marks the reset completed.
- **Vetoes:** Driver specialist vetoed Alternative 3 because `pnputil` cannot resolve corrupted NDIS binding hierarchies that `netcfg -d` eradicates.

---

### DEC-003: Invariant Culture Enforcement on All Date and Timestamp Parsing
- **Date:** 2026-11-11
- **Context:** Parsing ISO 8601 strings and boot timestamps using standard `[datetime]::Parse($str)` relied on the current thread culture. On non-English Windows locales (e.g., German `de-DE`, Japanese `ja-JP`), parsing could throw culture-sensitive exceptions.
- **Alternatives Considered:**
  1. Use regex string extraction for year/month/day components.
  2. Enforce `[System.Globalization.CultureInfo]::InvariantCulture` and `[System.Globalization.DateTimeStyles]::RoundtripKind` on all `[datetime]::Parse` calls.
- **Decision:** Adopt Alternative 2. Guarantees 100% deterministic, zero-exception parsing across all localized Windows installations.
- **Vetoes:** None. Unanimous approval.

---

### DEC-004: Neutralization of Flashy Marketing Adjectives to Professional Standards
- **Date:** 2026-11-11
- **Context:** Several headers, export banners, and sentinel log strings retained legacy terms such as "Supreme" (`LANFIXER SUPREME OMNIFIX REPORT`, `Supreme Sentinel Daemon`).
- **Alternatives Considered:**
  1. Retain legacy strings for historical continuity.
  2. Standardize on clean, simple, industry-standard engineering nomenclature.
- **Decision:** Adopt Alternative 2. Replaced all occurrences with clear, professional labels: `LANFIXER SYSTEM HISTORY EXPORT BUNDLE`, `LANFIXER SYSTEM HISTORY & AUDIT`, `Autonomous Sentinel Daemon activated`.
- **Vetoes:** UX / TUI reviewer strongly approved.

---

### DEC-005: Absolute Preservation of Public CLI Modes and Dispatch Bindings (Invariant I7)
- **Date:** 2026-11-11
- **Context:** Verification of Hard Invariant I7 requires that public CLI arguments, exit codes, and mode names never break existing scripts or scheduled tasks.
- **Decision:** Preserve all 54 public CLI modes and aliases (`Omnifix`, `StandardReset`, `UltraReset`, `Ultra`, `DoomsdayReset`, `Doomsday`, `ArmageddonReset`, `Armageddon`, `ResetFactory`, `Reset`, `Debloat`, `UndoDebloat`, `SelfTest`, etc.).
- **Vetoes:** Any rename of public flags without backward compatibility was strictly vetoed.

---

### DEC-006: Retention of WMI Fallback Paths in Legacy Network Queries
- **Date:** 2026-11-11
- **Context:** Evaluated whether legacy WMI (`Get-WmiObject Win32_NetworkAdapterConfiguration`) should be stripped in favor of pure CIM (`Get-CimInstance`).
- **Decision:** Primary queries use `Get-CimInstance` and `Get-NetAdapter`. However, legacy `Get-WmiObject` calls inside exception catch blocks are retained strictly as fallbacks for legacy Windows 10 enterprise builds where the WMI-CIM bridge service may be degraded or disabled.
- **Vetoes:** Security specialist confirmed no credential exposure or privilege escalation in local fallback queries.

---

### DEC-007: Single-File Polyglot Architecture Retention (Invariant I1)
- **Date:** 2026-11-11
- **Context:** Evaluated splitting `LanFixer.cmd` into a multi-file PowerShell module or distributing precompiled helper assemblies.
- **Decision:** Rejected. Retained strict single-file polyglot architecture. Single-file `.cmd` allows immediate emergency triage from USB drives, recovery environments, and WinPE without module installation or internet dependencies.
- **Vetoes:** SRE & Chaos specialist vetoed multi-file distribution.

---

### DEC-008: Preservation of Certificate Validation in Captive Portal Probes (Invariant I6)
- **Date:** 2026-11-11
- **Context:** Certain captive portals intercept HTTPS traffic with self-signed SSL certificates. Evaluated whether to add a bypass switch for `ServerCertificateValidationCallback`.
- **Decision:** Rejected bypass. Security Invariant I6 is non-negotiable: certificate validation must never be disabled globally or locally, preventing credential theft and man-in-the-middle attacks.
- **Vetoes:** Security researcher vetoed any bypass of certificate validation.
