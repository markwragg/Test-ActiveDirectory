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

        .PARAMETER Tag
            Optional: Only run checks with one of these Pester tags (e.g. 'Forest','Domain','Password',
            'Sites','Subnets','Sitelinks','ADHC'). If not specified, all checks are run.

        .PARAMETER ExcludeTag
            Optional: Skip checks with one of these Pester tags. For example, use -ExcludeTag ADHC to skip
            the live health checks (NLTest/DCDiag/RepAdmin/ports/services/DNS) and only compare configuration.

        .EXAMPLE
            Test-ActiveDirectory

            Compares the current Active Directory configuration against the most recent GoldConfig-*.xml
            file found in the current directory and reports any differences.

        .EXAMPLE
            Test-ActiveDirectory -ExcludeTag ADHC

            Compares configuration only, skipping the live health checks (useful when running from a host
            that isn't a domain member/controller, or doesn't have the AD administrative tools installed).
    #>
    [CmdletBinding()]
    Param(
        [string]
        $ADSnapshotFile,

        [string]
        $ADGoldFile = (Get-ChildItem (Join-Path $Pwd 'GoldConfig-*.xml') | Select-Object -Last 1).fullname,

        [string[]]
        $Tag,

        [string[]]
        $ExcludeTag
    )
    $Container = New-PesterContainer -Path (Join-Path $PSScriptRoot '../ActiveDirectory.Checks.ps1') -Data @{
        ADSnapshotFile = $ADSnapshotFile
        ADGoldFile     = $ADGoldFile
    }

    $PesterConfig = New-PesterConfiguration
    $PesterConfig.Run.Container = $Container
    $PesterConfig.Run.PassThru = $true

    # Pester v6 fails a -ForEach that resolves to $null/empty unless the It also carries
    # -AllowNullOrEmptyForEach. ActiveDirectory.Checks.ps1 deliberately doesn't use that switch, so it
    # can also run unmodified on Pester v5 (where the switch doesn't exist). Relaxing the same behaviour
    # here, at the run configuration level, covers Pester v6 instead -- guarded, since this property
    # doesn't exist on Pester v5's configuration object and setting it there would throw.
    if ($PesterConfig.Run.PSObject.Properties.Name -contains 'FailOnNullOrEmptyForEach') {
        $PesterConfig.Run.FailOnNullOrEmptyForEach = $false
    }

    if ($Tag) { $PesterConfig.Filter.Tag = $Tag }
    if ($ExcludeTag) { $PesterConfig.Filter.ExcludeTag = $ExcludeTag }

    Invoke-Pester -Configuration $PesterConfig
}
