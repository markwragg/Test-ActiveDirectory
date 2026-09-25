# Export-ADConfig

## SYNOPSIS
Exports the configuration of an Active Directory forest to an XML file.

## SYNTAX

### Default (Default)
```
Export-ADConfig [[-InputObject] <Object>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### AsGoldConfig
```
Export-ADConfig [[-InputObject] <Object>] [-AsGoldConfig] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### Path
```
Export-ADConfig [[-InputObject] <Object>] [-Path <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
The Export-ADConfig cmdlet retrieves the AD configuration via the Get-ADConfig cmdlet
and then exports it to an XML file.
If the -AsGoldConfig switch is used, the file is
prefixed GoldConfig-, otherwise the prefix is ADConfig-.

## EXAMPLES

### EXAMPLE 1
```
Export-ADConfig
```

Retrieves the current AD configuration and exports it to a file named ADReport-\<date\>.xml.

### EXAMPLE 2
```
Export-ADConfig -AsGoldConfig
```

Retrieves the current AD configuration and exports it to a file named GoldConfig-\<date\>.xml.

### EXAMPLE 3
```
Get-ADConfig | Export-ADConfig -AsGoldConfig
```

Exports a previously retrieved AD configuration to a file named GoldConfig-\<date\>.xml.

## PARAMETERS

### -InputObject
The AD configuration to export.
If not provided Get-ADConfig is executed to retrieve the current
config.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Get-ADConfig)
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Specify the path for the export file.
If not specified, the file is either ADConfig-\<currentdate\>.xml
or GoldConfig-\<currentdate\>.xml depending on whether -AsgoldConfig is specified.

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsGoldConfig
Use to export to a file named GoldConfig-\<currentdate\>.xml.

```yaml
Type: SwitchParameter
Parameter Sets: AsGoldConfig
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

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
