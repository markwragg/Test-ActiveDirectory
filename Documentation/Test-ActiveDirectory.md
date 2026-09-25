# Test-ActiveDirectory

## SYNOPSIS
Runs Pester tests to validate whether the Active Directory configuration and health matches
the previously recorded known-good state of the configuration.

## SYNTAX

```
Test-ActiveDirectory [[-ADSnapshotFile] <String>] [[-ADGoldFile] <String>] [[-Tag] <String[]>]
 [[-ExcludeTag] <String[]>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
..

## EXAMPLES

### EXAMPLE 1
```
Test-ActiveDirectory
```

Compares the current Active Directory configuration against the most recent GoldConfig-*.xml
file found in the current directory and reports any differences.

### EXAMPLE 2
```
Test-ActiveDirectory -ExcludeTag ADHC
```

Compares configuration only, skipping the live health checks (useful when running from a host
that isn't a domain member/controller, or doesn't have the AD administrative tools installed).

## PARAMETERS

### -ADSnapshotFile
Optional: The path to a snapshot of Active Directory that you want to validate against the Gold config.
If not provided, a current config is retrieved at runtime via the Get-ADConfig cmdlet.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ADGoldFile
The path to the 'gold' known-good snapshot of Active Directory that you want to validate against.
The cmdlet looks for a file named ADGoldConfig-*.xml in the current directory

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: (Get-ChildItem (Join-Path $Pwd 'GoldConfig-*.xml') | Select-Object -Last 1).fullname
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tag
Optional: Only run checks with one of these Pester tags (e.g.
'Forest','Domain','Password',
'Sites','Subnets','Sitelinks','ADHC').
If not specified, all checks are run.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeTag
Optional: Skip checks with one of these Pester tags.
For example, use -ExcludeTag ADHC to skip
the live health checks (NLTest/DCDiag/RepAdmin/ports/services/DNS) and only compare configuration.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
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
