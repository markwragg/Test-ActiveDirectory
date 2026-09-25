# Get-ADConfig

## SYNOPSIS
Retrieves the configuration of an Active Directory forest.

## SYNTAX

```
Get-ADConfig [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Get-ADConfig cmdlet retrieves various configuration information about Active Directory
and returns that information as a PowerShell ojbect.
It uses cmdlets such as: Get-ADRootDSE,
Get-ADForest, Get-ADDomain, Get-ADDomainController, Get-ADTrust etc.
to gather information.

The primary purpose of this tool is to gather a single and detailed snapshot of the configuration
of an Active Directory forest to use to validate the future health of that forest.

## EXAMPLES

### EXAMPLE 1
```
Get-ADConfig
```

Retrieves the current configuration of Active Directory and returns it as a PowerShell object.

## PARAMETERS

### -ProgressAction
{{Fill ProgressAction Description}}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
