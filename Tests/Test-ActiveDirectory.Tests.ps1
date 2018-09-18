if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major

. "$PSScriptRoot/../ADAudit/Public/Test-ActiveDirectory.ps1"

Describe "Test-ActiveDirectory PS$PSVersion" {
    $PWDLocation = Get-Location
    
    BeforeEach {
        Set-Location $TestDrive
    }
    AfterEach {
        Set-Location $PWDLocation
    }

    It 'Should not throw' {
        { 
            { 
                [pscustomobject]@{ content = 'dummy' } | Export-CliXml "$TestDrive/GoldConfig-dummy.xml"
                Test-ActiveDirectory -ADGoldFile "$TestDrive/GoldConfig-dummy.xml"
            } | Should -Not -Throw
        }
    }
}