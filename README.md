# Test-ActiveDirectory
Test and auditing Powershell and Pester scripts for Active Directory.

This code builds on the Active Directory Operational Test work of Irwin Strachan [(@IrwinStrachan)](https://twitter.com/IrwinStrachan) which he has detailed here:
https://pshirwin.wordpress.com/2016/04/08/active-directory-operations-test/

## Files

### Get-ADConfig.ps1
Execute to create an XML file of your current Active Directory configuration.

### ActiveDirectory.tests.ps1
Execute with Pester (invoke-pester) to perform the following tests:

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

## Requires

- Powershell 4+ (probably).
- Pester
- Connectivity to AD and suitable rights

## Pre-requisities

Before you can verify your Active Directory configuration, you need to create an XML of your current configuration (assuming it is valid and correct) which you then store as your "Gold Configuration".
Execute "Get-ADConfig.ps1" to do this and rename the XML otuput to be ADGoldConfig-<date>.xml.

## Usage

1. Run Get-ADConfig.ps1 to get a current snapshot of your AD config.
2. Run Invoke-Pester (or ActiveDirectory.tets.ps1) to compare either a pre-existing snapshot (per step 1) or if one is not found to create a snapshot and then compare it.
