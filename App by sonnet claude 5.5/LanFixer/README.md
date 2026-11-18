# LanFixer 8 – silent network guardian (C# / .NET 8 Native AOT)

One native `LanFixer.exe` (no runtime, no NuGet packages, ~1,300 lines) containing:

| Part | What it does |
|---|---|
| **Service** `LanFixer` (SYSTEM, delayed auto-start) | No windows, ever. Reacts instantly to `NetworkChange` events (Wi-Fi/Ethernet/IP change) + adaptive polling (4 s unhealthy, 15 s healthy, 30 s on battery). Detects *Online / Captive portal / No-DNS / Offline / No-link*, auto-logs-in, auto-repairs (capped), logs to `%ProgramData%\LanFixer\lanfixer.log`. |
| **Tray** `LanFixer tray` | Coloured dot (green/amber/red/grey), latency tooltip, balloons on state changes, menu: Repair · Sign in · Rollback · Restore original · Reset stack · Dashboard. Pure Win32 – no WinForms. |
| **Dashboard** `LanFixer` | Live console: state, link, web/gateway/internet latency, loss, trend sparkline, events, keys `R B O L T X Q`. |
| **CLI** | `status` (exit 0/10/20/30) · `repair` · `reset` · `rollback` · `restore` · `login` · `tune [1\|2]` · `audit` · `cred set/show/pin/clear` · `install` · `uninstall` · `selftest` |

## 1. Build
Prereqs (build machine only): .NET 8 SDK + Visual Studio Build Tools with **Desktop development with C++** (Native AOT linker).
```
build.cmd          →  dist\LanFixer.exe   (single standalone native exe)
```
## 2. Install (elevated prompt)
```
dist\LanFixer.exe install          copies to %ProgramFiles%\LanFixer (admin-only write), registers + starts service, tray autostart
dist\LanFixer.exe cred set         username, password, trusted portal host (auto-detected if you are on the portal now)
dist\LanFixer.exe cred pin         only for self-signed portals: approve the certificate fingerprint once
dist\LanFixer.exe uninstall        restores ALL original settings first, removes service/tray/credentials (--keep skips restore, --purge deletes backups)
```
## 3. Safety design
* **Backup before change (write-ahead):** every setting is journaled *before* it is touched (`state.json`, atomic write, validated, `.bak` fallback).
  *Baseline* = first-write-wins original values → **Restore original**. *Runs* = per-operation undo → **Rollback last** (skips values someone else changed since).
* **What is ever changed:** only the 6 tune registry values (same vectors/values as your script), DNS on the active adapter *only if its resolvers all fail and a public one answers* (auto-reverted when you roam or DHCP DNS recovers), Teredo/6to4/ISATAP (tier 2). Repairs 1–3 are otherwise transient (flush, renew, adapter cycle with fail-safe re-enable, also recovered at next service start).
* **Stack reset (level 4)** is manual only: refuses unless a `netsh dump` backup was written, creates a System Restore point, blocks over RDP, needs confirmation, auto-heal is blocked while a reboot is pending.
* **Auto-heal limits:** 3 bad probes in a row, 90 s cooldown, max 3/hour, never levels above 3.
* **Credentials:** DPAPI machine-scope + app entropy, inside a folder ACL'd to SYSTEM/Administrators. Password goes **only** over HTTPS to the trusted host (or its sub-domain); every redirect hop and the form `action` are re-checked; cert must be Windows-valid or pinned; auto-login pauses after 2 rejections so the account is not locked.
* **IPC:** local named pipe, network SIDs denied, whitelist of 9 commands, no parameters.

## 4. Kept / dropped from the 16,700-line script
Kept (core value): probe verdict table, HTTPS-spoof detection, source-bound probes, form parser, trust/pinning guards, DPAPI vault, flush/DNS-rescue/DHCP-adapter ladder, stack reset with backup, careful debloat + undo, change journal + drift-protected undo, reboot-pending debounce, battery-adaptive cadence, adapter fail-safe.
Dropped as bloat or too risky to automate: Doomsday/Armageddon/Ultra resets, NIC-driver power tweaks, ARP locking, NRPT/campus-specific hard-coding (NITJSR), host-route injection, MTU/bufferbloat grading, support-bundle/INI/ledger UIs, 7-lens history viewers, hosts/proxy rewriting.
Known difference: multi-uplink portal routing uses source-address binding but no `/32` host routes.

## 5. Verification
`tests\verify.cmd` (elevated) = `selftest` + real registry tune/rollback diff + restore + status exit code. Then manually:
1. **Drop:** unplug cable / toggle Wi-Fi → tray turns grey ("disconnected"); reconnect → green balloon. No window appears.
2. **Auto-repair:** block DNS (set a bogus static DNS) → within ~30 s event `auto-repair started` → `Repaired at level 2`; `rollback` leaves DNS as before.
3. **Captive:** connect to the portal network with creds saved → amber → "signing in" → green. Wrong password twice → "auto-login PAUSED" on dashboard.
4. **Foreign portal:** join a hotspot with a login page → log says `Refused … password NOT sent`.
5. **Service kill:** `taskkill /f /im LanFixer.exe` on the service PID → SCM restarts it in 5 s.
6. **Uninstall:** `uninstall` → `reg`/`netsh interface ip show dns` identical to before install.
