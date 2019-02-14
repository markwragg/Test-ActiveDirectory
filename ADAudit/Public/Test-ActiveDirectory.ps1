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
    #>
    [CmdletBinding()]
    Param(
        [string]
        $ADSnapshotFile,

        [string]
        $ADGoldFile = (Get-ChildItem (Join-Path $Pwd 'GoldConfig-*.xml') | Select-Object -Last 1).fullname
    )
    Write-Host $PSScriptRoot

    & $PSScriptRoot/../ActiveDirectory.tests.ps1 -ADSnapShotFile $ADSnapshotFile -ADGoldFile $ADGoldFile
}