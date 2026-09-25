if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Export-ADConfig PS$PSVersion" {

    BeforeAll {
        . "$PSScriptRoot/../ADAudit/Public/Export-ADConfig.ps1"

        function Get-ADConfig {}

        Mock Get-ADConfig {
            [pscustomobject]@{ content = 'dummycontent' }
        }

        $PWDLocation = Get-Location
    }

    BeforeEach {
        Set-Location $TestDrive
    }
    AfterEach {
        Set-Location $PWDLocation
    }

    Context 'Default behaviour' {
        It 'Should export an ADAudit config file by default' {
            Export-ADConfig

            Should -Invoke Get-ADConfig -Times 1 -Exactly
            "$TestDrive/ADReport-$(Get-Date -format yyyy-MM-dd).xml" | Should -Exist
        }
    }

    Context 'Gold config' {
        It 'Should export a Gold config file when using -AsGoldConfig' {
            Export-ADConfig -AsGoldConfig

            Should -Invoke Get-ADConfig -Times 1 -Exactly
            "$TestDrive/GoldConfig-$(Get-Date -format yyyy-MM-dd).xml" | Should -Exist
        }
    }

    Context 'Path specified' {
        It 'Should export a -Path specified config file' {
            Export-ADConfig -Path 'SomeTestConfig.xml'

            Should -Invoke Get-ADConfig -Times 1 -Exactly
            "$TestDrive/SomeTestConfig.xml" | Should -Exist
        }
    }
}
