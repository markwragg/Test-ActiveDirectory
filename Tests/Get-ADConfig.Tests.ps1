if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major

. "$PSScriptRoot/../ADAudit/Public/Get-ADConfig.ps1"

Describe "Get-ADConfig PS$PSVersion" {

    Function Get-ADDomain {}
    Function Get-ADRootDSE {}
    Function Get-ADForest {}
    Function Get-ADDomainController {}
    Function Get-ADTrust {}
    Function Get-ADDefaultDomainPasswordPolicy {}
    Function Get-ADAuthenticationPolicy {}
    Function Get-ADAuthenticationPolicySilo {}
    Function Get-ADCentralAccessPolicy {}
    Function Get-ADCentralAccessRule {}
    Function Get-ADClaimTransformPolicy {}
    Function Get-ADClaimType {}
    Function Get-ADGroup {}
    Function Get-ADGroupMember {}
    Function Get-ADOrganizationalUnit {}
    Function Get-ADOptionalFeature {}
    Function Get-ADReplicationSite {}
    Function Get-ADReplicationSubnet {}
    Function Get-ADReplicationSiteLink {}
    Function Resolve-DnsName {}
    
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
    Mock Get-ADGroup { 'SomeGroup'}
    Mock Get-ADGroupMember {}
    Mock Get-ADOrganizationalUnit {}
    Mock Get-ADOptionalFeature {}
    Mock Get-ADReplicationSite {}
    Mock Get-ADReplicationSubnet {}
    Mock Get-ADReplicationSiteLink {}
    Mock Resolve-DnsName {}
    
    $ADConfig = Get-ADConfig

    It 'Should return a PSCustomObject' {
        $ADConfig | Should -BeOfType 'PSCustomObject'
    }
    It 'Should call Mocks the expected number of times' {
        Assert-MockCalled -Times 1 -Exactly Get-ADDomain
        Assert-MockCalled -Times 1 -Exactly Get-ADRootDSE
        Assert-MockCalled -Times 1 -Exactly Get-ADForest
        Assert-MockCalled -Times 1 -Exactly Get-ADDomainController
        Assert-MockCalled -Times 1 -Exactly Get-ADTrust
        Assert-MockCalled -Times 1 -Exactly Get-ADDefaultDomainPasswordPolicy
        Assert-MockCalled -Times 1 -Exactly Get-ADAuthenticationPolicy
        Assert-MockCalled -Times 1 -Exactly Get-ADAuthenticationPolicySilo
        Assert-MockCalled -Times 1 -Exactly Get-ADCentralAccessPolicy
        Assert-MockCalled -Times 1 -Exactly Get-ADCentralAccessRule
        Assert-MockCalled -Times 1 -Exactly Get-ADClaimTransformPolicy
        Assert-MockCalled -Times 1 -Exactly Get-ADClaimType
        Assert-MockCalled -Times 1 -Exactly Get-ADGroup
        Assert-MockCalled -Times 1 -Exactly Get-ADGroupMember
        Assert-MockCalled -Times 1 -Exactly Get-ADOrganizationalUnit
        Assert-MockCalled -Times 1 -Exactly Get-ADOptionalFeature
        Assert-MockCalled -Times 1 -Exactly Get-ADReplicationSite
        Assert-MockCalled -Times 1 -Exactly Get-ADReplicationSubnet
        Assert-MockCalled -Times 1 -Exactly Get-ADReplicationSiteLink
        Assert-MockCalled -Times 2 -Exactly Resolve-DnsName
    }
}