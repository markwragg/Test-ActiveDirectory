if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Test-ActiveDirectory PS$PSVersion" {

    BeforeAll {
        . "$PSScriptRoot/../ADAudit/Public/Test-ActiveDirectory.ps1"

        $PWDLocation = Get-Location

        # A minimally-shaped stand-in for a Get-ADConfig snapshot, just complete enough that
        # ActiveDirectory.Checks.ps1 can build its (Discovery-time) It names and comparisons
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

    It 'Should not throw and should report no differences when comparing a snapshot against a matching gold config' {
        # -ExcludeTag ADHC: those checks run real system/AD tools (NLTest, DCDiag, RepAdmin, service and
        # port probes) which only make sense against a real domain, not a dummy config, and are slow to
        # time out on a non-AD host -- see ActiveDirectory.Checks.ps1's 'Active Directory health checks'
        # Describe block.
        New-DummyADConfig | Export-CliXml "$TestDrive/GoldConfig-dummy.xml"
        New-DummyADConfig | Export-CliXml "$TestDrive/ADSnapshot-dummy.xml"

        {
            $script:Result = Test-ActiveDirectory -ADGoldFile "$TestDrive/GoldConfig-dummy.xml" -ADSnapshotFile "$TestDrive/ADSnapshot-dummy.xml" -ExcludeTag 'ADHC'
        } | Should -Not -Throw

        $script:Result.FailedCount | Should -Be 0
    }

    Context 'Live health checks (-Tag ADHC)' {
        BeforeAll {
            # Stand-ins for the external tools/cmdlets that the 'Active Directory health checks' Describe
            # block in ActiveDirectory.Checks.ps1 calls directly (NLTest.exe/dcdiag.exe/Repadmin.exe aren't
            # wrapped in overridable functions the way the AD module cmdlets are via Get-ADConfig, and
            # Test-Connection/Test-NetConnection/Get-Service are real cmdlets that would otherwise probe this
            # test host). Plain function definitions are used rather than Pester's `Mock`: Test-ActiveDirectory
            # runs ActiveDirectory.Checks.ps1 via its own nested Invoke-Pester call, and Pester 6 deliberately
            # detects and blocks a `Mock`-created shim from an outer scope leaking into that nested run. An
            # ordinary function override isn't a Pester mock, so it's just normal command resolution and
            # crosses that boundary fine.
            function NLTest.exe { 'Connection Status = 0 0x0 NERR_Success' }
            function dcdiag.exe { 'The operation completed successfully.' }
            function Repadmin.exe {
                @'
"Source DSA","Destination DSA","Number of Failures"
"dc1","dc1","0"
'@
            }
            function Test-Connection { param($ComputerName, [switch]$Quiet) $true }
            function Test-NetConnection { param($ComputerName, $Port) [pscustomobject]@{ TcpTestSucceeded = $true } }
            function Get-Service { param($Name) [pscustomobject]@{ Status = 'Running' } }
        }

        It 'Should pass the live health checks when the underlying tools report healthy' {
            New-DummyADConfig | Export-CliXml "$TestDrive/GoldConfig-adhc.xml"
            New-DummyADConfig | Export-CliXml "$TestDrive/ADSnapshot-adhc.xml"

            $script:ADHCResult = Test-ActiveDirectory -ADGoldFile "$TestDrive/GoldConfig-adhc.xml" -ADSnapshotFile "$TestDrive/ADSnapshot-adhc.xml" -Tag 'ADHC'

            $script:ADHCResult.FailedCount | Should -Be 0
            $script:ADHCResult.PassedCount | Should -BeGreaterThan 0
        }
    }

    Context '-Tag parameter' {
        It 'Should only run checks matching the specified -Tag' {
            New-DummyADConfig | Export-CliXml "$TestDrive/GoldConfig-tag.xml"
            New-DummyADConfig | Export-CliXml "$TestDrive/ADSnapshot-tag.xml"

            $script:TagResult = Test-ActiveDirectory -ADGoldFile "$TestDrive/GoldConfig-tag.xml" -ADSnapshotFile "$TestDrive/ADSnapshot-tag.xml" -Tag 'Forest'

            $script:TagResult.FailedCount | Should -Be 0
            # 3 = the 'Forest' Describe block's full test count for the 1-GlobalCatalog dummy config
            # (2 Forest-configuration Its + 1 GlobalCatalogs It) -- confirms -Tag actually filtered down
            # to just that block, rather than the full suite happening to pass with 0 failures anyway.
            $script:TagResult.PassedCount | Should -Be 3
        }
    }

    Context 'Missing -ADGoldFile' {
        It 'Should fail discovery when no -ADGoldFile is specified and none can be found automatically' {
            # A dedicated empty directory, not just $TestDrive, since the 'Should not throw...' test above
            # already leaves a GoldConfig-dummy.xml sitting in $TestDrive that -ADGoldFile's auto-discovery
            # would otherwise pick up.
            $EmptyDir = Join-Path $TestDrive 'no-gold-file'
            New-Item -Path $EmptyDir -ItemType 'Directory' -Force | Out-Null
            Set-Location $EmptyDir

            New-DummyADConfig | Export-CliXml 'ADSnapshot-dummy.xml'

            # ActiveDirectory.Checks.ps1 throws when $ADGoldFile is empty, but that throw happens at Pester
            # Discovery time inside Test-ActiveDirectory's own nested Invoke-Pester call -- Invoke-Pester
            # reports a Discovery failure via the returned result object's FailedContainersCount rather than
            # raising a catchable exception, so Test-ActiveDirectory itself doesn't throw here either.
            $script:NoGoldResult = Test-ActiveDirectory -ADSnapshotFile 'ADSnapshot-dummy.xml'

            $script:NoGoldResult.FailedContainersCount | Should -Be 1
        }
    }

    Context 'Invalid -ADGoldFile' {
        It 'Should fail discovery when the gold config file cannot be loaded' {
            New-DummyADConfig | Export-CliXml "$TestDrive/ADSnapshot-badgold.xml"

            $script:BadGoldResult = Test-ActiveDirectory -ADGoldFile "$TestDrive/does-not-exist.xml" -ADSnapshotFile "$TestDrive/ADSnapshot-badgold.xml"

            $script:BadGoldResult.FailedContainersCount | Should -Be 1
        }
    }

    Context 'No -ADSnapshotFile (live fallback)' {
        BeforeAll {
            # Stands in for the real AD module cmdlets Get-ADConfig itself calls, same as Get-ADConfig.Tests.ps1.
            function Get-ADConfig { New-DummyADConfig }
        }

        It 'Should fall back to a live Get-ADConfig snapshot when -ADSnapshotFile is not specified' {
            New-DummyADConfig | Export-CliXml "$TestDrive/GoldConfig-live.xml"

            $script:LiveResult = Test-ActiveDirectory -ADGoldFile "$TestDrive/GoldConfig-live.xml" -ExcludeTag 'ADHC'

            $script:LiveResult.FailedCount | Should -Be 0
        }
    }
}
