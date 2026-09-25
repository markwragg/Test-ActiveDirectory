[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Variables assigned here are consumed inside Describe/It script blocks below, which PSScriptAnalyzer does not trace into.'
)]
[CmdletBinding()]
Param(
    #Optional: The path to a snapshot of Active Directory that you want to validate against the Gold config.
    [string]
    $ADSnapshotFile,

    #The path to the 'gold' known-good snapshot of Active Directory that you want to validate against.
    # Parameter help description
    [string]
    $ADGoldFile = (Get-ChildItem (Join-Path $Pwd 'GoldConfig-*.xml') | Select-Object -Last 1).fullname
)
if ($ADGoldFile) {
    Write-Verbose "ADGoldFile     : $ADGoldFile"
}
Else {
    Throw '-ADGoldFile is required and was not found automatically by searching for GoldConfig-*.xml in the current path.'
}

if ($ADSnapshotFile) {
    Write-Verbose "ADSnapShotFile : $ADSnapShotFile"
}

# The AD snapshot/gold config are loaded here, at Discovery time, so that the below can use them to
# determine the It blocks to generate (e.g. one It per DomainController/Site/Sitelink/etc.) and to build
# It names. They're loaded a second time below, in a top-level BeforeAll, because Pester's Discovery/Run
# split means a plain variable set here doesn't survive into the It bodies that run later, during Run.
Try {
    If ($ADSnapshotFile) {
        Write-Verbose "Loading the AD Snapshot from: $ADSnapshotFile"
        $ADSnapshot = Import-Clixml $ADSnapshotFile
    }
    Else {
        Write-Verbose 'No AD Snapshot file specified. Attempting to get config via Get-ADConfig.'
        $ADSnapshot = Get-ADConfig
    }

    Write-Verbose "Loading the AD Gold Config from: $ADGoldFile"
    $ADGoldConfig = Import-Clixml $ADGoldFile
}
Catch {
    Write-Error "Could not load the AD 'Gold' configuration and/or load/generate a current AD snapshot."
    Throw $_
}

BeforeAll {
    Try {
        If ($ADSnapshotFile) {
            $ADSnapshot = Import-Clixml $ADSnapshotFile
        }
        Else {
            $ADSnapshot = Get-ADConfig
        }

        $ADGoldConfig = Import-Clixml $ADGoldFile
    }
    Catch {
        Write-Error "Could not load the AD 'Gold' configuration and/or load/generate a current AD snapshot."
        Throw $_
    }
}

#Begin testing
Describe 'Active Directory Forest Operational Readiness checks' -Tags 'Forest' {

    Context 'Verifying Forest Configuration' {
        it "Forest FQDN $($ADGoldConfig.ForestInformation.RootDomain)" {
            $ADGoldConfig.ForestInformation.RootDomain |
                Should -Be $ADSnapshot.ForestInformation.RootDomain
        }
        it "ForestMode $($ADGoldConfig.ForestInformation.ForestMode.ToString())" {
            $ADGoldConfig.ForestInformation.ForestMode.ToString() |
                Should -Be $ADSnapshot.ForestInformation.ForestMode.ToString()
        }
    }

    Context 'Verifying GlobalCatalogs' {
        It "Server <_> is a GlobalCatalog" -ForEach $ADGoldConfig.ForestInformation.GlobalCatalogs -AllowNullOrEmptyForEach {
            $ADSnapshot.ForestInformation.GlobalCatalogs.Contains($_) |
                Should -Be $true
        }
    }
}

Describe 'Active Directory Domain Operational Readiness checks' -Tags 'Domain' {
    Context 'Verifying Domain Configuration' {
        it "Total Domain Controllers $($ADGoldConfig.DomainControllers.Count)" {
            $ADGoldConfig.DomainControllers.Count |
                Should -Be $ADSnapshot.DomainControllers.Count
        }

        It "DomainController <_> exists" -ForEach $ADGoldConfig.DomainControllers.Name -AllowNullOrEmptyForEach {
            $ADSnapshot.DomainControllers.Name.Contains($_) |
                Should -Be $true
        }

        it "DNSRoot $($ADGoldConfig.DomainInformation.DNSRoot)" {
            $ADGoldConfig.DomainInformation.DNSRoot |
                Should -Be $ADSnapshot.DomainInformation.DNSRoot
        }
        it "NetBIOSName $($ADGoldConfig.DomainInformation.NetBIOSName)" {
            $ADGoldConfig.DomainInformation.NetBIOSName |
                Should -Be $ADSnapshot.DomainInformation.NetBIOSName
        }
        it "DomainMode $($ADGoldConfig.DomainInformation.DomainMode.ToString())" {
            $ADGoldConfig.DomainInformation.DomainMode.ToString() |
                Should -Be $ADSnapshot.DomainInformation.DomainMode.ToString()
        }
        it "DistinguishedName $($ADGoldConfig.DomainInformation.DistinguishedName)" {
            $ADGoldConfig.DomainInformation.DistinguishedName |
                Should -Be $ADSnapshot.DomainInformation.DistinguishedName
        }
        it "Server $($ADGoldConfig.DomainInformation.RIDMaster) is RIDMaster" {
            $ADGoldConfig.DomainInformation.RIDMaster |
                Should -Be $ADSnapshot.DomainInformation.RIDMaster
        }
        it "Server $($ADGoldConfig.DomainInformation.PDCEmulator) is PDCEmulator" {
            $ADGoldConfig.DomainInformation.PDCEmulator |
                Should -Be $ADSnapshot.DomainInformation.PDCEmulator
        }
        it "Server $($ADGoldConfig.DomainInformation.InfrastructureMaster) is InfrastructureMaster" {
            $ADGoldConfig.DomainInformation.InfrastructureMaster |
                Should -Be $ADSnapshot.DomainInformation.InfrastructureMaster
        }
    }
}

Describe 'Active Directory Default Password Policy Operational Readiness checks' -Tags 'Password' {
    Context 'Verifying Default Password Policy' {
        it 'ComplexityEnabled' {
            $ADGoldConfig.DefaultPassWordPoLicy.ComplexityEnabled |
                Should -Be $ADSnapshot.DefaultPassWordPoLicy.ComplexityEnabled
        }
        it 'Password History count' {
            $ADGoldConfig.DefaultPassWordPoLicy.PasswordHistoryCount |
                Should -Be $ADSnapshot.DefaultPassWordPoLicy.PasswordHistoryCount
        }
        it "Lockout Threshold equals $($ADGoldConfig.DefaultPassWordPoLicy.LockoutThreshold)" {
            $ADGoldConfig.DefaultPassWordPoLicy.LockoutThreshold |
                Should -Be $ADSnapshot.DefaultPassWordPoLicy.LockoutThreshold
        }
        it "Lockout duration equals $($ADGoldConfig.DefaultPassWordPoLicy.LockoutDuration)" {
            $ADGoldConfig.DefaultPassWordPoLicy.LockoutDuration |
                Should -Be $ADSnapshot.DefaultPassWordPoLicy.LockoutDuration.ToString()
        }
        it "Lockout observation window equals $($ADGoldConfig.DefaultPassWordPoLicy.LockoutObservationWindow)" {
            $ADGoldConfig.DefaultPassWordPoLicy.LockoutObservationWindow |
                Should -Be $ADSnapshot.DefaultPassWordPoLicy.LockoutObservationWindow.ToString()
        }
        it "Min password age equals $($ADGoldConfig.DefaultPassWordPoLicy.MinPasswordAge)" {
            $ADGoldConfig.DefaultPassWordPoLicy.MinPasswordAge |
                Should -Be $ADSnapshot.DefaultPassWordPoLicy.MinPasswordAge.ToString()
        }
        it "Max password age equals $($ADGoldConfig.DefaultPassWordPoLicy.MaxPasswordAge)" {
            $ADGoldConfig.DefaultPassWordPoLicy.MaxPasswordAge |
                Should -Be $ADSnapshot.DefaultPassWordPoLicy.MaxPasswordAge.ToString()
        }
    }
}

Describe 'Active Directory Sites,subnets & sublinks Operational Readiness' -Tags 'Sites', 'Subnets', 'Sitelinks' {
    Context 'Verifying Active Directory Sites' {
        It "Site <_>" -ForEach $ADGoldConfig.Sites.Name -AllowNullOrEmptyForEach {
            $ADSnapshot.Sites.Name.Contains($_) |
                Should -Be $true
        }
    }

    Context 'Verifying Active Directory Sitelinks' {
        It "Sitelink <_.Name>" -ForEach $ADGoldConfig.Sitelinks -AllowNullOrEmptyForEach {
            $_.Name |
                Should -Be ($ADSnapshot.Sitelinks | Where-Object Name -EQ $_.Name).Name
        }
        It "Sitelink <_.Name> costs <_.Cost>" -ForEach $ADGoldConfig.Sitelinks -AllowNullOrEmptyForEach {
            $_.Cost |
                Should -Be ($ADSnapshot.Sitelinks | Where-Object Name -EQ $_.Name).Cost
        }
        It "Sitelink <_.Name> replication interval <_.ReplicationFrequencyInMinutes>" -ForEach $ADGoldConfig.Sitelinks -AllowNullOrEmptyForEach {
            $_.ReplicationFrequencyInMinutes |
                Should -Be ($ADSnapshot.Sitelinks | Where-Object Name -EQ $_.Name).ReplicationFrequencyInMinutes
        }
    }

    Context 'Verifying Active Directory Subnets' {
        It "Subnet <_.Name>" -ForEach $ADGoldConfig.Subnets -AllowNullOrEmptyForEach {
            $_.Name |
                Should -Be ($ADSnapshot.SubNets | Where-Object Name -EQ $_.Name).Name
        }
        It "Site <_.Site>" -ForEach $ADGoldConfig.Subnets -AllowNullOrEmptyForEach {
            $_.Site |
                Should -Be ($ADSnapshot.SubNets | Where-Object Name -EQ $_.Name).Site
        }
    }
}

Describe 'Active Directory health checks' -Tags 'ADHC' {

    Context 'Checking the output of NLTest /Query' {
        BeforeAll {
            $NLTest = NLTest.exe /Query
        }

        it 'NLTest.exe /Query Result' {
            ($NLTest | Out-String).Contains('Success') | Should -Be $true
        }
    }

    Context 'Checking the output of DCDiag for issues on all DCs' {
        BeforeAll {
            $DCDiag = dcdiag.exe -a
        }

        it 'DCDiag.exe -a Result' {
            ($DCDiag | Out-String).Contains('failed') | Should -Be $false
        }
    }

    Context 'Checking the output of RepAdmin /showrepl for replication issues' {
        It "Replication from <_.'Source DSA'> to <_.'Destination DSA'> has <_.'Number of Failures'> failures" -ForEach (
            (Repadmin.exe /showrepl * /csv | ConvertFrom-Csv) | Sort-Object 'Source DSA' | Where-Object { $_.'Number of Failures' -ge 0 }
        ) -AllowNullOrEmptyForEach {
            $_.'Number of Failures' | Should -Not -BeGreaterThan 0
        }
    }

    Context 'Pinging each Domain Controller' {
        It "Ping result for Domain Controller <_>" -ForEach ($ADGoldConfig.DomainControllers.Name | Sort-Object) -AllowNullOrEmptyForEach {
            Test-Connection $_ -Quiet | Should -Be $true
        }
    }

    Context 'Testing local Active Directory TCP ports respond' {
        # AD Ports: https://technet.microsoft.com/en-us/library/dd772723(v=ws.10).aspx
        It "Port test for TCP <_>" -ForEach @(53, 88, 135, 139, 389, 445, 464, 636, 3268, 3269, 9389) {
            (Test-NetConnection -ComputerName $env:COMPUTERNAME -Port $_).TcpTestSucceeded | Should -Be $true
        }
    }

    Context 'Checking local Active Directory Windows services are running' {
        It "Service: <_>" -ForEach @('ADWS', 'BITS', 'CertPropSvc', 'CryptSvc', 'Dfs', 'DFSR', 'DNS', 'Dnscache', 'eventlog', 'gpsvc', 'kdc',
            'LanmanServer', 'LanmanWorkstation', 'Netlogon', 'NTDS', 'NtFrs', 'RpcEptMapper', 'RpcSs', 'SamSs', 'W32Time') {
            (Get-Service $_).Status | Should -Be 'Running'
        }
    }

    Context 'checking DNS LDAP SRV records' {
        It "LDAP result entry <_.Index>: <_.Entry.Type>" -ForEach @(
            $i = 0
            $ADGoldConfig.LDAPDNS | Sort-Object nametarget, name, type | ForEach-Object {
                [pscustomobject]@{ Index = $i; Entry = $_ }
                $i++
            }
        ) -AllowNullOrEmptyForEach {
            $Snapshot = $ADSnapshot.LDAPDNS[$_.Index]
            $_.Entry.Name | Should -Be $Snapshot.Name
            $_.Entry.NameTarget | Should -Be $Snapshot.NameTarget
            $_.Entry.TTL | Should -Be $Snapshot.TTL
            $_.Entry.Port | Should -Be $Snapshot.Port
            $_.Entry.IPAddress | Should -Be $Snapshot.IPAddress
        }
    }

    Context 'checking DNS Kerberos SRV records' {
        It "Kerberos result entry <_.Index>: <_.Entry.Type>" -ForEach @(
            $i = 0
            $ADGoldConfig.KerberosDNS | Sort-Object nametarget, name, type | ForEach-Object {
                [pscustomobject]@{ Index = $i; Entry = $_ }
                $i++
            }
        ) -AllowNullOrEmptyForEach {
            $Snapshot = $ADSnapshot.KerberosDNS[$_.Index]
            $_.Entry.Name | Should -Be $Snapshot.Name
            $_.Entry.NameTarget | Should -Be $Snapshot.NameTarget
            $_.Entry.TTL | Should -Be $Snapshot.TTL
            $_.Entry.Port | Should -Be $Snapshot.Port
            $_.Entry.IPAddress | Should -Be $Snapshot.IPAddress
        }
    }
}
