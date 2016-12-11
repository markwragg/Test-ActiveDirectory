[cmdletbinding()]
Param($ExportToXML = $True)

Import-Module ActiveDirectory

#HashTable to save ADReport
$ADSnapshot = @{}

$ADSnapshot.RootDSE = $(Get-ADRootDSE)
$ADSnapshot.ForestInformation = $(Get-ADForest)
$ADSnapshot.DomainInformation = $(Get-ADDomain)
$ADSnapshot.DomainControllers = $(Get-ADDomainController -Filter *)
$ADSnapshot.DomainTrusts = (Get-ADTrust -Filter *)
$ADSnapshot.DefaultPassWordPoLicy = $(Get-ADDefaultDomainPasswordPolicy)
$ADSnapshot.AuthenticationPolicies = $(Get-ADAuthenticationPolicy -LDAPFilter '(name=AuthenticationPolicy*)')
$ADSnapshot.AuthenticationPolicySilos = $(Get-ADAuthenticationPolicySilo -Filter 'Name -like "*AuthenticationPolicySilo*"')
$ADSnapshot.CentralAccessPolicies = $(Get-ADCentralAccessPolicy -Filter *)
$ADSnapshot.CentralAccessRules = $(Get-ADCentralAccessRule -Filter *)
$ADSnapshot.ClaimTransformPolicies = $(Get-ADClaimTransformPolicy -Filter *)
$ADSnapshot.ClaimTypes = $(Get-ADClaimType -Filter *)
$ADSnapshot.DomainAdministrators =$( Get-ADGroup -Identity $('{0}-512' -f (Get-ADDomain).domainSID) | Get-ADGroupMember -Recursive)
$ADSnapshot.OrganizationalUnits = $(Get-ADOrganizationalUnit -Filter *)
$ADSnapshot.OptionalFeatures =  $(Get-ADOptionalFeature -Filter *)
$ADSnapshot.Sites = $(Get-ADReplicationSite -Filter *)
$ADSnapshot.Subnets = $(Get-ADReplicationSubnet -Filter *)
$ADSnapshot.SiteLinks = $(Get-ADReplicationSiteLink -Filter *)
$ADSnapshot.LDAPDNS = $(Resolve-DnsName -Name "_ldap._tcp.$((Get-ADDomain).DNSRoot)" -Type srv)
$ADSnapshot.KerberosDNS = $(Resolve-DnsName -Name "_kerberos._tcp.$((Get-ADDomain).DNSRoot)" -Type srv)

#Export to XML
If ($ExportToXML -eq $True) {
    $ADSnapshot | Export-Clixml "ADReport-$(get-date -format yyyy-MM-dd).xml" -Encoding UTF8
    Return $True
}Else{
    Return $ADSnapshot
}