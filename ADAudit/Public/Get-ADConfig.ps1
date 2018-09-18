Function Get-ADConfig {
    <#
        .SYNOPSIS
            Retrieves the configuration of an Active Directory forest.

        .DESCRIPTION
            The Get-ADConfig cmdlet retrieves various configuration information about Active Directory
            and returns that information as a PowerShell ojbect. It uses cmdlets such as: Get-ADRootDSE,
            Get-ADForest, Get-ADDomain, Get-ADDomainController, Get-ADTrust etc. to gather information.

            The primary purpose of this tool is to gather a single and detailed snapshot of the configuration
            of an Active Directory forest to use to validate the future health of that forest.

        .EXAMPLE
            Get-ADConfig
    #>
    [cmdletbinding()]
    Param()

    $ADDomain = Get-ADDomain

    #HashTable to save ADReport
    [pscustomobject]@{
        RootDSE                   = (Get-ADRootDSE)
        ForestInformation         = (Get-ADForest)
        DomainInformation         = $ADDomain
        DomainControllers         = (Get-ADDomainController -Filter *)
        DomainTrusts              = (Get-ADTrust -Filter *)
        DefaultPassWordPoLicy     = (Get-ADDefaultDomainPasswordPolicy)
        AuthenticationPolicies    = (Get-ADAuthenticationPolicy -LDAPFilter '(name=AuthenticationPolicy*)')
        AuthenticationPolicySilos = (Get-ADAuthenticationPolicySilo -Filter 'Name -like "*AuthenticationPolicySilo*"')
        CentralAccessPolicies     = (Get-ADCentralAccessPolicy -Filter *)
        CentralAccessRules        = (Get-ADCentralAccessRule -Filter *)
        ClaimTransformPolicies    = (Get-ADClaimTransformPolicy -Filter *)
        ClaimTypes                = (Get-ADClaimType -Filter *)
        DomainAdministrators      = (Get-ADGroup -Identity $('{0}-512' -f $ADDomain.domainSID) | Get-ADGroupMember -Recursive)
        OrganizationalUnits       = (Get-ADOrganizationalUnit -Filter *)
        OptionalFeatures          = (Get-ADOptionalFeature -Filter *)
        Sites                     = (Get-ADReplicationSite -Filter *)
        Subnets                   = (Get-ADReplicationSubnet -Filter *)
        SiteLinks                 = (Get-ADReplicationSiteLink -Filter *)
        LDAPDNS                   = (Resolve-DnsName -Name "_ldap._tcp.$($ADDomain.DNSRoot)" -Type srv) | Sort-Object nametarget, name, type
        KerberosDNS               = (Resolve-DnsName -Name "_kerberos._tcp.$($ADDomain.DNSRoot)" -Type srv) | Sort-Object nametarget, name, type
    }
}