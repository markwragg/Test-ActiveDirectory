Task 'Commit' -Depends 'Init' {
    $lines

    Set-Location $ProjectRoot
    $Module = $env:BHProjectName

    git --version
    git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"
    git config --global user.name "github-actions[bot]"
    git checkout $env:GITHUB_REF_NAME

    git add Documentation/*.md
    git add README.md
    git add CHANGELOG.md

    # Commit back the manifest with the version bumped by the Deploy task -- without this, the source
    # ADAudit.psd1 in the repo stays on the old version while CHANGELOG.md moves on, and the next build's
    # 'Has matching changelog and manifest versions' Pester test (Tests/Common/Manifest.Tests.ps1) fails.
    git add $env:BHPSModuleManifest

    git commit -m "[skip ci] GitHub Actions Build $env:GITHUB_RUN_NUMBER"
    git push origin HEAD:$env:GITHUB_REF_NAME
}
