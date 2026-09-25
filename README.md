# Test-ActiveDirectory

[![Build Status](https://dev.azure.com/markwragg/GitHub/_apis/build/status/markwragg.Test-ActiveDirectory?branchName=master)](https://dev.azure.com/markwragg/GitHub/_build/latest?definitionId=13&branchName=master) ![coverage](https://img.shields.io/badge/coverage-80%25-yellow.svg)

This project contains a PowerShell module named ADAudit with cmdlets for retrieving and exporting detailed information about the configuration of an Active Directory forest. The module also contains a set of Pester tests that can be used to validate whether any configuration drift has occurred as well as perform a series of health tests of AD.

The validation of AD configuration drifts works by you initially using `Get-ADConfig | Export-ADConfig -AsGoldConfig` to generate a current "known-good state" snapshot of the configuration of AD. After this you can use `Test-ActiveDirectory`, or run the `ActiveDirectory.Checks.ps1` file directly (via `Invoke-Pester`) to compare the known good state to the current AD state (or a previously retrieved snapshot of the state).

> This code builds on the Active Directory Operational Test work of Irwin Strachan [(@IrwinStrachan)](https://twitter.com/IrwinStrachan) which he has detailed here:
>
> - https://pshirwin.wordpress.com/2016/04/08/active-directory-operations-test/

## Installation

This module is published in the PowerShell Gallery, so can be installed via:

```
Install-Module ADAudit -Scope CurrentUser
```
## Requirements

This module requires the following modules be installed/available:

- ActiveDirectory
- Pester (minimum version 5.0)

## Cmdlets

### `Get-ADConfig`

Execute to retrieve the current AD configuration as a PowerShell object.

### `Export-ADConfig`

Use to export the current AD configuration to an XML file. If you're saving the current known-good state, use `-AsGoldConfig` to have the exported configuration prefixed with `GoldConfig-`.

### `Test-ActiveDirectory` or `ActiveDirectory.Checks.ps1`

Execute to perform the following tests:

**Active Directory configuration checks**
- Various checks of the config between what has been stored previously and what has been captured now to detect configuration drift.

**Active Directory health checks**
- Runs NLTest /Query and checks the output for "Success"
- Runs DCDiag -a and checks the output for "failed"
- Runs RepAdmin /showrepl and checks each replication for the "Number of Failures" count being > 0
- Performs a Ping against each listed DC (per config)
- Tests that common AD ports respond locally: (53,88,135,139,389,445,464,636,3268,3269,9389)
- Checks that common AD services are running: ("ADWS","BITS","CertPropSvc","CryptSvc","Dfs","DFSR","DNS","Dnscache","eventlog","gpsvc","kdc","LanmanServer","LanmanWorkstation","Netlogon","NTDS","NtFrs","RpcEptMapper","RpcSs","SamSs","W32Time")
- Checks the SRV DNS records for _ldap.tcp.domainname and _kerberos.tcp.domainname

Use `-Tag` or `-ExcludeTag` to run a subset of the above, e.g. `Test-ActiveDirectory -ExcludeTag ADHC` to compare configuration only and skip the live health checks (useful on a host that isn't AD-connected, or doesn't have the AD administrative tools installed).
