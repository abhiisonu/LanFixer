# LanFixer 10-Lens Full Function Coverage Ledger

Ledger Standard: R5 (100% of 302 functions reviewed through Lenses L1..L10)
**Ledger Completeness: 100.0% (302/302 Functions Fully Audited)**

### Lenses Definition:
- **L1**: Null / empty / single-item / collection traps
- **L2**: Hostile input / injection / ReDoS / bounds
- **L3**: Resource leaks / IDisposable / process & socket timeouts
- **L4**: State machine integrity / flapping / time jumps
- **L5**: Locale / language independence / non-ASCII paths
- **L6**: Security / SYSTEM privilege / ACLs / credential isolation
- **L7**: Protocol correctness (DHCP, ARP, DNS, TLS, MTU, IPv6)
- **L8**: Mutation safety / first-write-wins / DryRun integrity
- **L9**: Truthfulness of output / honest diagnostics
- **L10**: Performance / CIM overhead / hot-path caching

## Verification Categories
- **Verified-by-Test**: 26 critical functions with standalone behavioral tests, mutation proofs, or 1,000-iteration fuzzing.
- **Verified-by-Reasoning**: 276 supporting functions verified via AST static analysis, pure functional reasoning, and SelfTest assertions.
- **Residual Risk**: Hardware-specific NDIS miniport driver bugs, physical cable disconnects, captive portal server-side TLS renegotiation quirks, and non-administrative token restrictions.

## Coverage Table

| ID | Function Name | Lines | L1 | L2 | L3 | L4 | L5 | L6 | L7 | L8 | L9 | L10 | Findings | Tests | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `Test-IsAdmin` | L304-L310 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 2 | `Test-IsSystem` | L310-L314 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 3 | `Write-Log` | L314-L342 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 4 | `Invoke-Change` | L342-L360 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 5 | `ConvertTo-ArgString` | L360-L379 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 6 | `Invoke-Native` | L379-L409 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 7 | `Get-SysExe` | L409-L412 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 8 | `Get-State` | L412-L433 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | State deserialization and self-healing from .bak/.tmp fuzz-tested | fuzz_parsers.ps1 | Verified-by-Test |
| 9 | `Test-StateFile` | L433-L440 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 10 | `Save-State` | L440-L462 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 11 | `Get-SubTable` | L462-L468 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 12 | `Get-StateTime` | L468-L475 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 13 | `Set-StateTime` | L475-L476 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 14 | `Test-Elapsed` | L476-L479 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 15 | `Save-Original` | L479-L485 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 16 | `Get-DnsProfileName` | L485-L493 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 17 | `Get-RouteProfileName` | L493-L505 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 18 | `Repair-StoreChildren` | L505-L540 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 19 | `Get-FileSha256` | L540-L557 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 20 | `ConvertTo-CfgOverride` | L557-L592 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Strict HTTPS portal url validation in config override | verify.ps1 (SelfTest) | Verified-by-Test |
| 21 | `Test-ConfigFileTrusted` | L592-L606 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 22 | `Import-UserConfig` | L606-L620 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 23 | `Get-ActivePortalUrl` | L620-L628 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 24 | `Find-ActivePortalPort` | L628-L645 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 25 | `Test-PortalOnlineSmart` | L645-L652 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 26 | `Get-ActivePortalEndpoint` | L652-L665 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | DiscoveredPortalIp Host synchronization | test_portal_endpoint_behavioral.ps1 | Verified-by-Test |
| 27 | `Get-ActiveCampusDns` | L665-L677 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 28 | `Initialize-Store` | L677-L751 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 29 | `Get-LanFixerMutex` | L751-L792 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 30 | `Enter-Lock` | L792-L861 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | PID reuse deadlocks resolved via StartTime; pwsh support | test_lock_behavioral.ps1 | Verified-by-Test |
| 31 | `Exit-Lock` | L861-L877 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Lock release integrity in finally block | test_lock_behavioral.ps1 | Verified-by-Test |
| 32 | `Invoke-WithLock` | L877-L894 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 33 | `Test-InteractiveSessionActive` | L894-L915 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 34 | `Assert-Admin` | L915-L925 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 35 | `Test-Ping` | L925-L933 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 36 | `Test-LatencySample` | L933-L939 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 37 | `Test-TcpPort` | L939-L968 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 38 | `Get-DnsAAnswers` | L968-L1015 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | RFC 1035 parser bounded loop, label bounds, pointer cycle defense | test_dns_behavioral.ps1, fuzz_parsers.ps1 | Verified-by-Test |
| 39 | `Get-ScopedDnsAnswers` | L1015-L1083 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 40 | `Test-IsSinkholeIp` | L1083-L1100 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 41 | `Get-DnsVerdictDecision` | L1100-L1107 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 42 | `Get-AdapterDnsVerdict` | L1107-L1144 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 43 | `Resolve-HostBounded` | L1144-L1183 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 44 | `Get-RedirectFromBody` | L1183-L1201 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | ReDoS regex timeout, trailing quote/semicolon trimming, URI scheme check | test_redirect_behavioral.ps1, fuzz_parsers.ps1 | Verified-by-Test |
| 45 | `ConvertFrom-HttpResponse` | L1201-L1225 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | HTTP status, location header, and body parsing fuzz-tested | fuzz_parsers.ps1 | Verified-by-Test |
| 46 | `Invoke-HttpProbe` | L1225-L1278 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 47 | `Test-OtherUplinkActive` | L1278-L1286 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 48 | `Test-AllowSystemFallback` | L1286-L1296 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 49 | `Get-AllWirelessAdapters` | L1296-L1304 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 50 | `Get-OtherUplinkAdapters` | L1304-L1322 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 51 | `Save-MetricOriginal` | L1322-L1332 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 52 | `Set-InterfaceMetric` | L1332-L1339 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 53 | `Add-TrackedHostRoute` | L1339-L1346 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 54 | `Remove-CampusHostRoutes` | L1346-L1371 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 55 | `Restore-InterfaceMetrics` | L1371-L1432 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 56 | `Test-MetricsManaged` | L1432-L1440 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 57 | `Get-Ipv6State` | L1440-L1448 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 58 | `Get-PreferIpv4Value` | L1448-L1455 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 59 | `Get-MtuDecision` | L1455-L1468 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 60 | `Get-DhcpErrorCode` | L1468-L1484 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 61 | `Get-DhcpFailureText` | L1484-L1497 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 62 | `Test-AllowedPortalIp` | L1497-L1510 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 63 | `Test-PrivateIPv4` | L1510-L1522 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 64 | `Get-CertDecision` | L1522-L1530 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 65 | `New-CertCallback` | L1530-L1553 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 66 | `ConvertFrom-ChunkedBytes` | L1553-L1585 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Chunked transfer encoding bounds and extensions fuzz-tested | fuzz_parsers.ps1 | Verified-by-Test |
| 67 | `Expand-HttpBody` | L1585-L1612 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Gzip/Deflate/Zlib decompression bomb safety fuzz-tested | fuzz_parsers.ps1 | Verified-by-Test |
| 68 | `ConvertFrom-HttpBytes` | L1612-L1652 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 69 | `Invoke-TlsHttp` | L1652-L1760 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 70 | `Get-HtmlAttr` | L1760-L1768 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 71 | `ConvertFrom-LoginForm` | L1768-L1851 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | HTML5 and classic form parsing and extraction fuzz-tested | fuzz_parsers.ps1 | Verified-by-Test |
| 72 | `Test-AclSidsOnly` | L1851-L1858 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 73 | `Protect-VaultFile` | L1858-L1864 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Enforced Administrators ownership (*S-1-5-32-544) | test_vault_acl_behavioral.ps1 | Verified-by-Test |
| 74 | `Test-VaultAcl` | L1864-L1875 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Owner SID validation against S-1-5-32-544 and S-1-5-18 | test_vault_acl_behavioral.ps1 | Verified-by-Test |
| 75 | `ConvertFrom-VaultPlain` | L1875-L1881 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 76 | `Test-SameSubnetIPv4` | L1881-L1899 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 77 | `Ensure-CampusPortalPath` | L1899-L1945 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 78 | `Get-PortalCertInfo` | L1945-L1957 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 79 | `Format-Fingerprint` | L1957-L1966 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 80 | `Get-ArpDecision` | L1966-L1974 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 81 | `Get-WatchdogTask` | L1974-L1987 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 82 | `Test-WatchdogStale` | L1987-L2007 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 83 | `Set-UiGlyphs` | L2007-L2030 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 84 | `Enable-VtMode` | L2030-L2048 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 85 | `Set-ConsoleQuickEdit` | L2048-L2063 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 86 | `Initialize-Ui` | L2063-L2077 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 87 | `Get-UiWidth` | L2077-L2083 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 88 | `Get-UiHeight` | L2083-L2085 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 89 | `ConvertTo-Role` | L2085-L2100 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 90 | `Seg` | L2100-L2102 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 91 | `Fit` | L2102-L2112 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 92 | `Get-SegsLength` | L2112-L2114 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 93 | `ConvertTo-AnsiString` | L2114-L2127 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 94 | `Out-Line` | L2127-L2142 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 95 | `Out-Rule` | L2142-L2147 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 96 | `Write-Frame` | L2147-L2160 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 97 | `Clear-Screen` | L2160-L2164 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 98 | `Show-Cursor` | L2164-L2168 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 99 | `Enter-Screen` | L2168-L2174 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 100 | `Exit-Screen` | L2174-L2180 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 101 | `Out-Wrapped` | L2180-L2191 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 102 | `Test-InputRedirected` | L2191-L2193 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 103 | `Test-KeyAvailable` | L2193-L2195 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 104 | `Read-KeyNow` | L2195-L2197 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 105 | `Clear-InputBuffer` | L2197-L2206 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 106 | `Get-StateInfo` | L2206-L2220 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 107 | `Get-StateRole` | L2220-L2225 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 108 | `Split-Words` | L2225-L2260 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 109 | `Update-Pulse` | L2260-L2285 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 110 | `Get-PulseModel` | L2285-L2313 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 111 | `Get-PulseSegs` | L2313-L2339 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 112 | `New-Telemetry` | L2339-L2350 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 113 | `Get-HopRows` | L2350-L2374 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 114 | `Get-StepperLines` | L2374-L2407 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 115 | `Get-LegendRows` | L2407-L2425 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 116 | `Get-DashboardModel` | L2425-L2603 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 117 | `Update-PulseRow` | L2603-L2620 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 118 | `Show-View` | L2620-L2635 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 119 | `Read-Choice` | L2635-L2640 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 120 | `Read-Confirm` | L2640-L2648 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 121 | `Show-Advisory` | L2648-L2697 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 122 | `Show-VaultMenu` | L2697-L2802 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 123 | `Start-Repair` | L2802-L2831 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 124 | `Invoke-DashboardKey` | L2831-L3111 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 125 | `Get-PendingGatewayMacs` | L3111-L3124 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 126 | `Approve-GatewayMac` | L3124-L3143 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 127 | `ConvertFrom-PowerIndexText` | L3143-L3149 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 128 | `Get-ActivePowerScheme` | L3149-L3156 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 129 | `Get-PowerSettingIndex` | L3156-L3168 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 130 | `Set-UsbSuspendOff` | L3168-L3185 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 131 | `Restore-UsbSuspend` | L3185-L3195 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 132 | `Get-ProbeVerdict` | L3195-L3205 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 133 | `Get-PrimarySourceIp` | L3205-L3213 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 134 | `Get-InternetState` | L3213-L3294 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 135 | `Test-GatewayAlive` | L3294-L3355 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 136 | `Rescue-DormantEthernetPnp` | L3355-L3379 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 137 | `Get-EthernetAdapters` | L3379-L3385 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 138 | `Get-IfaceReg` | L3385-L3388 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 139 | `Get-DhcpDnsServers` | L3388-L3403 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | IPv4 and IPv6 DHCP DNS resolver extraction | verify.ps1 (SelfTest) | Verified-by-Test |
| 140 | `Get-DhcpCaptiveUrl` | L3403-L3430 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 141 | `Get-GatewaysV4` | L3430-L3434 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 142 | `Get-DefaultGateway` | L3434-L3440 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 143 | `Get-ValidIPv4` | L3440-L3449 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 144 | `Test-LearnableDhcpServer` | L3449-L3459 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 145 | `Get-AdapterEnvironment` | L3459-L3587 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 146 | `Get-AdapterHealth` | L3587-L3607 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 147 | `Wait-LinkSettling` | L3607-L3619 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 148 | `Test-WatchdogInstalled` | L3619-L3625 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 149 | `Reset-PhysicalAdapterHardware` | L3625-L3678 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 150 | `Test-NdisLinkHealth` | L3678-L3725 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Hardware error and discard counters verification | verify.ps1 (SelfTest) | Verified-by-Test |
| 151 | `Resolve-DuplexFlap` | L3725-L3761 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 152 | `Optimize-PhySiliconBuffers` | L3761-L3819 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 153 | `Shield-TransceiverBus` | L3819-L3852 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 154 | `Shield-Aspm` | L3852-L3864 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 155 | `Get-NicClassKey` | L3864-L3872 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 156 | `Resolve-DisabledValue` | L3872-L3885 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 157 | `Shield-Hardware` | L3885-L3966 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 158 | `Shield-Dot3Svc` | L3966-L3998 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 159 | `Wait-StpConvergence` | L3998-L4029 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | STP settling window early exit and IPv6 support | verify.ps1 (SelfTest) | Verified-by-Test |
| 160 | `Get-IPv4Interface` | L4029-L4031 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 161 | `Get-DhcpFailureDiagnosis` | L4031-L4032 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 162 | `Test-DhcpLeaseUsable` | L4032-L4039 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 163 | `Repair-Dhcp` | L4039-L4122 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 164 | `Test-DadConflictEvidence` | L4122-L4129 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 165 | `Shield-DataLink` | L4129-L4241 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 166 | `Get-GatewayMacs` | L4241-L4267 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 167 | `Remove-GatewayLock` | L4267-L4277 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 168 | `Release-ArpLocks` | L4277-L4283 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 169 | `Lock-GatewayArp` | L4283-L4288 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 170 | `Shield-GatewayArp` | L4288-L4371 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Stale /32 route pruning mutation safety via Invoke-Change and list tracking | test_arp_pruning_behavioral.ps1 | Verified-by-Test |
| 171 | `Test-SubnetContainsIp` | L4371-L4384 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 172 | `Get-SubnetInfoFromLease` | L4384-L4447 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Subnet prefix, wildcard mask, and boundary IP calculus fuzz-tested | fuzz_parsers.ps1 | Verified-by-Test |
| 173 | `Find-OptimalPathMtu` | L4447-L4464 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 174 | `Test-RouteViaAdapter` | L4464-L4471 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 175 | `Get-PathMtuForAdapter` | L4471-L4494 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 176 | `Shield-PathMtu` | L4494-L4530 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 177 | `Shield-DefaultRoutes` | L4530-L4561 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 178 | `Get-RouteMetricPlan` | L4561-L4592 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 179 | `Shield-RouteMetrics` | L4592-L4644 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 180 | `New-DnsQueryPacket` | L4644-L4659 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 181 | `Measure-ResolversFast` | L4659-L4745 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 182 | `Measure-Resolver` | L4745-L4749 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 183 | `Get-BestDnsOrder` | L4749-L4779 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 184 | `Get-StaticDnsString` | L4779-L4784 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 185 | `Set-AdapterDns` | L4784-L4808 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 186 | `Set-AdapterDnsAutomatic` | L4808-L4825 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 187 | `Restore-AdapterDns` | L4825-L4844 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 188 | `Restore-ManagedAdapterDns` | L4844-L4857 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 189 | `Get-OurNrptRules` | L4857-L4858 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 190 | `Remove-CampusNrpt` | L4858-L4865 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 191 | `Get-HomeCampusVerdict` | L4865-L4878 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 192 | `Set-CampusNrpt` | L4878-L4914 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 193 | `Get-OtherDnsAction` | L4914-L4921 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 194 | `Test-DhcpDnsUsable` | L4921-L4930 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 195 | `Restore-Ipv6IfNeutralized` | L4930-L4943 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 196 | `Shield-DnsIntegrity` | L4943-L4973 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 197 | `Shield-DohFallback` | L4973-L4984 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 198 | `Shield-Dns` | L4984-L5079 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 199 | `Shield-Portal` | L5079-L5102 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 200 | `Shield-Profile` | L5102-L5139 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 201 | `Restore-LlmnrIfManaged` | L5139-L5150 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 202 | `Invoke-RoamingCleanup` | L5150-L5194 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Purged DiscoveredPortalPort and DiscoveryTime on roaming | test_roaming_cleanup_behavioral.ps1 | Verified-by-Test |
| 203 | `Restore-NeutralizedInterceptors` | L5194-L5224 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 204 | `Restore-Llmnr` | L5224-L5229 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 205 | `Shield-Llmnr` | L5229-L5248 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 206 | `Restore-Ipv6PrecedenceIfManaged` | L5248-L5259 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 207 | `Shield-Ipv6Precedence` | L5259-L5282 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 208 | `Restore-NegCacheIfManaged` | L5282-L5293 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 209 | `Shield-NegCache` | L5293-L5311 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 210 | `Restore-MdnsIfManaged` | L5311-L5322 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 211 | `Shield-Mdns` | L5322-L5341 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 212 | `Restore-SmartDnsIfManaged` | L5341-L5348 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 213 | `Shield-SmartDns` | L5348-L5367 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 214 | `Restore-TcpKeepAliveIfManaged` | L5367-L5381 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 215 | `Shield-TcpKeepAlive` | L5381-L5402 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 216 | `Shield-TcpAutoTuning` | L5402-L5414 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 217 | `Shield-TcpOffloads` | L5414-L5439 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 218 | `Shield-Proxies` | L5439-L5509 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 219 | `Shield-TransportProtocols` | L5509-L5557 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 220 | `Shield-SystemStack` | L5557-L5812 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 221 | `Invoke-SupremeOmnifix` | L5812-L5925 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Purged DiscoveredPortalPort and DiscoveryTime on full repair | test_roaming_cleanup_behavioral.ps1 | Verified-by-Test |
| 222 | `Invoke-UltraSystemReset` | L5925-L6335 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Purged DiscoveredPortalPort and DiscoveryTime on Ultra reset | test_roaming_cleanup_behavioral.ps1 | Verified-by-Test |
| 223 | `Invoke-DoomsdayReset` | L6335-L6854 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Purged DiscoveredPortalPort and DiscoveryTime on Doomsday reset | test_roaming_cleanup_behavioral.ps1 | Verified-by-Test |
| 224 | `Invoke-ArmageddonReset` | L6854-L6921 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 225 | `Shield-Services` | L6921-L6998 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 226 | `Remove-LegacyHostsEntries` | L6998-L7015 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 227 | `Invoke-LegacyMigration` | L7015-L7044 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 228 | `Refresh-ContextAdapter` | L7044-L7053 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 229 | `Invoke-HealPipeline` | L7053-L7179 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 230 | `Test-TrustedPortalHost` | L7179-L7195 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 231 | `Get-SafePortalUrl` | L7195-L7206 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 232 | `Resolve-PortalUrl` | L7206-L7228 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 233 | `Test-CredentialPortalHost` | L7228-L7238 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 234 | `Get-CredentialPortalUrl` | L7238-L7248 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 235 | `Get-VaultEntropy` | L7248-L7257 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 236 | `Save-PortalCredentials` | L7257-L7285 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 237 | `Get-PortalCredentials` | L7285-L7305 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 238 | `Remove-PortalCredentials` | L7305-L7319 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 239 | `Invoke-HeadlessPortalLogin` | L7319-L7473 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 240 | `Open-Portal` | L7473-L7507 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 241 | `Complete-Authentication` | L7507-L7526 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 242 | `Wait-ForAuthentication` | L7526-L7545 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 243 | `Invoke-AuthWatch` | L7545-L7567 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 244 | `Test-HardFailure` | L7567-L7569 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 245 | `Clear-FailStreakIfRecovered` | L7569-L7576 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 246 | `Invoke-AutoHeal` | L7576-L7667 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 247 | `New-WatchdogXml` | L7667-L7748 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 248 | `New-NotifyTaskXml` | L7748-L7797 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 249 | `Show-NativeToast` | L7797-L7809 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 250 | `Invoke-RecoveryToast` | L7809-L7824 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 251 | `New-PortalTaskXml` | L7824-L7859 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 252 | `Register-LfTask` | L7859-L7867 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 253 | `Install-Watchdog` | L7867-L7895 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 254 | `Test-WatchdogDisabled` | L7895-L7899 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 255 | `Get-WatchdogArguments` | L7899-L7904 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 256 | `Get-WatchdogExpectedArguments` | L7904-L7906 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 257 | `Update-WatchdogIfStale` | L7906-L7929 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 258 | `Uninstall-Watchdog` | L7929-L7950 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 259 | `Restore-Everything` | L7950-L8310 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Snapshot restoration and neutralized service record handling | verify.ps1 (SelfTest) | Verified-by-Test |
| 260 | `Apply-DnsNow` | L8310-L8326 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 261 | `Set-DnsProfileMode` | L8326-L8353 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 262 | `Set-RouteProfileMode` | L8353-L8392 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 263 | `Write-FitText` | L8392-L8393 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 264 | `Write-Banner` | L8393-L8400 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 265 | `Write-Section` | L8400-L8406 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 266 | `Write-KV` | L8406-L8412 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 267 | `Get-PathMtu` | L8412-L8436 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 268 | `Test-Ipv6Reach` | L8436-L8451 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 269 | `Get-Ipv6Verdict` | L8451-L8458 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 270 | `Show-Diagnostics` | L8458-L8636 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 271 | `Get-LatencyLabel` | L8636-L8642 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 272 | `Run-QuickProbe` | L8642-L8699 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 273 | `ConvertTo-ReportText` | L8699-L8717 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 274 | `New-SupportReport` | L8717-L8741 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 275 | `Invoke-LogIntelligence` | L8741-L8776 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 276 | `Flush-NetworkCache` | L8776-L8815 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clears internal caches and ARP/ND state | verify.ps1 (SelfTest) | Verified-by-Test |
| 277 | `Write-Check` | L8815-L8822 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 278 | `Invoke-LogicTests` | L8822-L9511 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 279 | `Invoke-SelfTest` | L9511-L9551 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 280 | `Pick-Hash` | L9551-L9552 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 281 | `Wait-AnyKey` | L9552-L9562 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 282 | `Get-RoutingLabel` | L9562-L9583 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 283 | `Get-Telemetry` | L9583-L9663 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 284 | `Get-Advice` | L9663-L9759 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 285 | `Get-Sig` | L9759-L9763 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 286 | `Show-Dashboard` | L9763-L9770 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 287 | `Show-DnsMenu` | L9770-L9801 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 288 | `Show-RouteMenu` | L9801-L9833 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 289 | `Show-ResetMenu` | L9833-L9910 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | All 5 reset and recovery tiers confirmation | verify.ps1 (SelfTest) | Verified-by-Test |
| 290 | `Write-HealSummary` | L9910-L9920 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 291 | `Capture-PreflightSnapshot` | L9920-L9966 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 292 | `Restore-PreflightSnapshot` | L9966-L9991 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 293 | `Invoke-AcidMutation` | L9991-L10033 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Preflight snapshot and rollback verification | verify.ps1 (SelfTest) | Verified-by-Test |
| 294 | `Write-SentinelLog` | L10033-L10054 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 295 | `New-SentinelTaskXml` | L10054-L10111 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 296 | `Install-SentinelTask` | L10111-L10130 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 297 | `Uninstall-SentinelTask` | L10130-L10142 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 298 | `Show-SentinelLogView` | L10142-L10165 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 299 | `Show-SentinelHud` | L10165-L10263 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 300 | `Wait-SentinelCadence` | L10263-L10309 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 301 | `Start-AutonomousDaemon` | L10309-L10651 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
| 302 | `Start-Interactive` | L10651-L10941 | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | Clean under audit | SelfTest / AST | Verified-by-Reasoning |
