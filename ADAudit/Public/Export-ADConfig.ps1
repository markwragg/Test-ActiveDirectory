Function Export-ADConfig {
    <#
        .SYNOPSIS
            Exports the configuration of an Active Directory forest to an XML file.

        .DESCRIPTION
            The Export-ADConfig cmdlet retrieves the AD configuration via the Get-ADConfig cmdlet
            and then exports it to an XML file. If the -AsGoldConfig switch is used, the file is
            prefixed GoldConfig-, otherwise the prefix is ADConfig-.

        .PARAMETER InputObject
            The AD configuration to export. If not provided Get-ADConfig is executed to retrieve the current
            config.

        .PARAMETER Path
            Specify the path for the export file. If not specified, the file is either ADConfig-<currentdate>.xml
            or GoldConfig-<currentdate>.xml depending on whether -AsgoldConfig is specified.

        .PARAMETER AsGoldConfig
            Use to export to a file named GoldConfig-<currentdate>.xml.

        .EXAMPLE
            Export-ADConfig

        .EXAMPLE
            Export-ADConfig - AsGoldConfig

        .EXAMPLE
            Get-ADConfig | Export-ADConfig -AsGoldConfig
    #>
    [cmdletbinding(DefaultParameterSetName='Default')]
    Param(
        [Parameter(ParameterSetName='Path')]
        [Parameter(ParameterSetName='AsGoldConfig')]
        [Parameter(ParameterSetName='Default')]
        [Parameter(Position = 0, ValueFromPipeline)]
        [object]
        $InputObject = (Get-ADConfig),

        [Parameter(ParameterSetName='Path')]
        [string]
        $Path,

        [Parameter(ParameterSetName='AsGoldConfig')]
        [switch]
        $AsGoldConfig
    )
    Begin {
        If ($AsGoldConfig) {
            $ReportPrefix = 'GoldConfig'
        }
        Else {
            $ReportPrefix = 'ADReport'
        }

        if (-not $Path) { $Path = "$ReportPrefix-$(Get-Date -format yyyy-MM-dd).xml" }
    }
    Process {
        $InputObject | Export-Clixml -Path $Path -Encoding UTF8
    }
}