if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Get-ADConfig PS$PSVersion" {

    BeforeAll {
        . "$PSScriptRoot/../ADAudit/Public/Get-ADConfig.ps1"

        function Get-ADDomain {}
        function Get-ADRootDSE {}
        function Get-ADForest {}
        function Get-ADDomainController {}
        function Get-ADTrust {}
        function Get-ADDefaultDomainPasswordPolicy {}
        function Get-ADAuthenticationPolicy {}
        function Get-ADAuthenticationPolicySilo {}
        function Get-ADCentralAccessPolicy {}
        function Get-ADCentralAccessRule {}
        function Get-ADClaimTransformPolicy {}
        function Get-ADClaimType {}
        function Get-ADGroup {}
        function Get-ADGroupMember {}
        function Get-ADOrganizationalUnit {}
        function Get-ADOptionalFeature {}
        function Get-ADReplicationSite {}
        function Get-ADReplicationSubnet {}
        function Get-ADReplicationSiteLink {}
        function Resolve-DnsName {}

        Mock Get-ADDomain {}
        Mock Get-ADRootDSE {}
        Mock Get-ADForest {}
        Mock Get-ADDomainController {}
        Mock Get-ADTrust {}
        Mock Get-ADDefaultDomainPasswordPolicy {}
        Mock Get-ADAuthenticationPolicy {}
        Mock Get-ADAuthenticationPolicySilo {}
        Mock Get-ADCentralAccessPolicy {}
        Mock Get-ADCentralAccessRule {}
        Mock Get-ADClaimTransformPolicy {}
        Mock Get-ADClaimType {}
        Mock Get-ADGroup { 'SomeGroup' }
        Mock Get-ADGroupMember {}
        Mock Get-ADOrganizationalUnit {}
        Mock Get-ADOptionalFeature {}
        Mock Get-ADReplicationSite {}
        Mock Get-ADReplicationSubnet {}
        Mock Get-ADReplicationSiteLink {}
        Mock Resolve-DnsName {}

        $ADConfig = Get-ADConfig
    }

    It 'Should return a PSCustomObject' {
        $ADConfig | Should -BeOfType 'PSCustomObject'
    }

    It 'Should call Mocks the expected number of times' {
        Should -Invoke Get-ADDomain -Times 1 -Exactly -Scope Describe
        Should -Invoke Get-ADRootDSE -Times 1 -Exactly -Scope Describe
        Should -Invoke Get-ADForest -Times 1 -Exactly -Scope Describe
        Should -Invoke Get-ADDomainController -Times 1 -Exactly -Scope Describe
        Should -Invoke Get-ADTrust -Times 1 -Exactly -Scope Describe
        Should -Invoke Get-ADDefaultDomainPasswordPolicy -Times 1 -Exactly -Scope Describe
        Should -Invoke Get-ADAuthenticationPolicy -Times 1 -Exactly -Scope Describe
        Should -Invoke Get-ADAuthenticationPolicySilo -Times 1 -Exactly -Scope Describe
        Should -Invoke Get-ADCentralAccessPolicy -Times 1 -Exactly -Scope Describe
        Should -Invoke Get-ADCentralAccessRule -Times 1 -Exactly -Scope Describe
        Should -Invoke Get-ADClaimTransformPolicy -Times 1 -Exactly -Scope Describe
        Should -Invoke Get-ADClaimType -Times 1 -Exactly -Scope Describe
        Should -Invoke Get-ADGroup -Times 1 -Exactly -Scope Describe
        Should -Invoke Get-ADGroupMember -Times 1 -Exactly -Scope Describe
        Should -Invoke Get-ADOrganizationalUnit -Times 1 -Exactly -Scope Describe
        Should -Invoke Get-ADOptionalFeature -Times 1 -Exactly -Scope Describe
        Should -Invoke Get-ADReplicationSite -Times 1 -Exactly -Scope Describe
        Should -Invoke Get-ADReplicationSubnet -Times 1 -Exactly -Scope Describe
        Should -Invoke Get-ADReplicationSiteLink -Times 1 -Exactly -Scope Describe
        Should -Invoke Resolve-DnsName -Times 2 -Exactly -Scope Describe
    }
}
