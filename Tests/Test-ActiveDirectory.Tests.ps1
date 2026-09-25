if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Test-ActiveDirectory PS$PSVersion" {

    BeforeAll {
        . "$PSScriptRoot/../ADAudit/Public/Test-ActiveDirectory.ps1"

        $PWDLocation = Get-Location

        # A minimally-shaped stand-in for a Get-ADConfig snapshot, just complete enough that
        # ActiveDirectory.tests.ps1 can build its (Discovery-time) It names and comparisons
        # without dereferencing missing properties.
        function New-DummyADConfig {
            [pscustomobject]@{
                ForestInformation = [pscustomobject]@{
                    RootDomain     = 'contoso.com'
                    ForestMode     = 'Windows2016Forest'
                    GlobalCatalogs = @('dc1.contoso.com')
                }
                DomainControllers = @([pscustomobject]@{ Name = 'dc1' })
                DomainInformation = [pscustomobject]@{
                    DNSRoot              = 'contoso.com'
                    NetBIOSName          = 'CONTOSO'
                    DomainMode           = 'Windows2016Domain'
                    DistinguishedName    = 'DC=contoso,DC=com'
                    RIDMaster            = 'dc1.contoso.com'
                    PDCEmulator          = 'dc1.contoso.com'
                    InfrastructureMaster = 'dc1.contoso.com'
                }
                DefaultPassWordPoLicy = [pscustomobject]@{
                    ComplexityEnabled         = $true
                    PasswordHistoryCount      = 24
                    LockoutThreshold          = 5
                    LockoutDuration           = (New-TimeSpan -Minutes 30)
                    LockoutObservationWindow  = (New-TimeSpan -Minutes 30)
                    MinPasswordAge            = (New-TimeSpan -Days 1)
                    MaxPasswordAge            = (New-TimeSpan -Days 90)
                }
                Sites       = @([pscustomobject]@{ Name = 'Default-First-Site-Name' })
                Sitelinks   = @([pscustomobject]@{ Name = 'DEFAULTIPSITELINK'; Cost = 100; ReplicationFrequencyInMinutes = 180 })
                Subnets     = @([pscustomobject]@{ Name = '10.0.0.0/24'; Site = 'Default-First-Site-Name' })
                LDAPDNS     = @([pscustomobject]@{ Name = '_ldap._tcp.dc._msdcs.contoso.com'; NameTarget = 'dc1.contoso.com'; Type = 'SRV'; TTL = 600; Port = 389; IPAddress = '10.0.0.1' })
                KerberosDNS = @([pscustomobject]@{ Name = '_kerberos._tcp.dc._msdcs.contoso.com'; NameTarget = 'dc1.contoso.com'; Type = 'SRV'; TTL = 600; Port = 88; IPAddress = '10.0.0.1' })
            }
        }
    }

    BeforeEach {
        Set-Location $TestDrive
    }
    AfterEach {
        Set-Location $PWDLocation
    }

    It 'Should not throw' {
        {
            New-DummyADConfig | Export-CliXml "$TestDrive/GoldConfig-dummy.xml"
            New-DummyADConfig | Export-CliXml "$TestDrive/ADSnapshot-dummy.xml"
            Test-ActiveDirectory -ADGoldFile "$TestDrive/GoldConfig-dummy.xml" -ADSnapshotFile "$TestDrive/ADSnapshot-dummy.xml"
        } | Should -Not -Throw
    }
}
