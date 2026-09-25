Function Test-ActiveDirectory {
    <#
        .SYNOPSIS
            Runs Pester tests to validate whether the Active Directory configuration and health matches
            the previously recorded known-good state of the configuration.

        .DESCRIPTION
            ..

        .PARAMETER ADSnapshotFile
            Optional: The path to a snapshot of Active Directory that you want to validate against the Gold config.
            If not provided, a current config is retrieved at runtime via the Get-ADConfig cmdlet.

        .PARAMETER ADGoldFile
            The path to the 'gold' known-good snapshot of Active Directory that you want to validate against.
            The cmdlet looks for a file named ADGoldConfig-*.xml in the current directory

        .EXAMPLE
            Test-ActiveDirectory

            Compares the current Active Directory configuration against the most recent GoldConfig-*.xml
            file found in the current directory and reports any differences.
    #>
    [CmdletBinding()]
    Param(
        [string]
        $ADSnapshotFile,

        [string]
        $ADGoldFile = (Get-ChildItem (Join-Path $Pwd 'GoldConfig-*.xml') | Select-Object -Last 1).fullname
    )
    $Container = New-PesterContainer -Path (Join-Path $PSScriptRoot '../ActiveDirectory.Checks.ps1') -Data @{
        ADSnapshotFile = $ADSnapshotFile
        ADGoldFile     = $ADGoldFile
    }

    $PesterConfig = New-PesterConfiguration
    $PesterConfig.Run.Container = $Container

    Invoke-Pester -Configuration $PesterConfig
}