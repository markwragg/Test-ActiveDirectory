# Create a single .psm1 module file containing all functions
# Copy new module and other supporting files (Documentation / Examples) to Staging folder
Task 'CombineFunctionsAndStage' -Depends 'Clean' {
    $lines

    # Create folders
    New-Item -Path $StagingFolder -ItemType 'Directory' -Force | Out-String | Write-Verbose
    New-Item -Path $StagingModulePath -ItemType 'Directory' -Force | Out-String | Write-Verbose

    # Get public and private function files
    $publicFunctions = @( Get-ChildItem -Path "$env:BHModulePath\Public\*.ps1" -Recurse -ErrorAction 'SilentlyContinue' )
    $privateFunctions = @( Get-ChildItem -Path "$env:BHModulePath\Private\*.ps1" -Recurse -ErrorAction 'SilentlyContinue' )

    # Combine functions into a single .psm1 module
    # Explicit UTF-8 (with BOM) read/write here matters: 'Get-Content | Add-Content' uses locale-dependent
    # default encodings and writes no BOM, so non-ASCII characters get silently corrupted, and Windows
    # PowerShell -- which needs a BOM to recognise a script as UTF-8 -- then re-reads the BOM-less combined
    # file as ANSI, corrupting it a second time.
    $combinedModulePath = Join-Path -Path $StagingModulePath -ChildPath "$($env:BHProjectName).psm1"
    $combinedContent = (@($publicFunctions + $privateFunctions) | Get-Content -Raw -Encoding 'UTF8') -join "`r`n"
    [System.IO.File]::WriteAllText($combinedModulePath, $combinedContent, [System.Text.UTF8Encoding]::new($true))

    # Copy other required folders and files if they exist
    $PathsToCopy = @(
        Join-Path -Path $ProjectRoot -ChildPath 'Documentation'
        Join-Path -Path $ProjectRoot -ChildPath 'Examples'
        Join-Path -Path $ProjectRoot -ChildPath 'CHANGELOG.md'
        Join-Path -Path $ProjectRoot -ChildPath 'README.md'
    )

    foreach ($Path in $PathsToCopy) {
        if (Test-Path $Path) {
            Copy-Item -Path $Path -Destination $StagingFolder -Recurse
        }
    }

    # Copy existing manifest
    Copy-Item -Path $env:BHPSModuleManifest -Destination $StagingModulePath -Recurse

    # Copy format (and any type) .ps1xml files referenced by the manifest's
    # FormatsToProcess/TypesToProcess -- these load relative to the module file,
    # so they must sit alongside the combined .psm1/.psd1 in Staging.
    Get-ChildItem -Path "$env:BHModulePath\*.ps1xml" -ErrorAction 'SilentlyContinue' |
        Copy-Item -Destination $StagingModulePath
}
