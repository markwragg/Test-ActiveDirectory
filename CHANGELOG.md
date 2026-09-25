# Changelog

## [4.0.0] - 2026-09-25
- **[Breaking]** Renamed `ActiveDirectory.tests.ps1` to `ActiveDirectory.Checks.ps1` so it's no longer
  auto-discovered as a unit test by Pester. Update any script/automation that referenced the old filename
  directly.
- Added `-Tag` / `-ExcludeTag` parameters to `Test-ActiveDirectory`, e.g. `-ExcludeTag ADHC` to skip the
  live health checks and compare configuration only.
- Hardened the Active Directory health checks so a missing tool (NLTest/DCDiag/RepAdmin) no longer aborts
  the whole check run.
- Migrated the module's Pester test suite to Pester 6, while keeping `ActiveDirectory.Checks.ps1` itself
  compatible with Pester 5.
- Replaced the AppVeyor/psake build pipeline with a new Azure Pipelines build, which now fails the build
  when tests fail.

## [2.0.10] - 2020-02-25
- Added a CONTRIBUTING guide for the project.

## [2.0.9] - 2019-09-07
- Switched to BuildHelpers for updating the README code coverage badge as part of the build.

## [2.0.8] - 2019-02-14
- Fixed an issue in `Test-ActiveDirectory` ([#4](https://github.com/markwragg/Test-ActiveDirectory/issues/4)).

## [2.0.6] - 2018-09-24
- Documentation updates.

## [2.0.5] - 2018-09-18
- Removed a stray `.DS_Store` file that had been accidentally committed.

## [2.0.4] - 2018-09-18
- Documentation updates.

## [2.0.3] - 2018-09-18
- Major refactor: restructured the project into the `ADAudit` PowerShell module (module
  manifest, `Public` function folder, Pester tests under `Tests\`) with build automation
  via psake, AppVeyor and PSDeploy, replacing the original flat collection of scripts.
- Fixed an issue in the module ([#3](https://github.com/markwragg/Test-ActiveDirectory/issues/3)).
- Added checks for the LDAP and Kerberos SRV DNS records.

## [1.1] - 2016-06-07
- Follow-up fix shortly after the initial release.

## [1.0] - 2016-06-07
- Initial release.
