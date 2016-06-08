[CmdletBinding()]
Param(
    [string]$ADFile,
    [string]$ADGoldFile = $(Get-ChildItem ("ADGoldConfig-*.xml") | Select name -last 1).name
)

#Try to load the Active Directory configuration files for comparison
Try{
    If ($ADFile) {
        Write-Verbose "Loading the AD Snapshot from: $ADFile"
        $ADSnapshot = Import-Clixml $ADFile
    }
    Else{
        Write-Verbose "No AD Snapshot file specified. Attempting to get config via Get-ADConfig.ps1."
        $ADSnapshot = Invoke-Expression ".\Get-ADConfig.ps1 -ExportToXML:$False"
    }

    Write-Verbose "Loading the AD Gold Config from: $ADGoldFile"
    $ADGoldConfig = Import-Clixml $ADGoldFile
}Catch{
    Write-Error "Could not load the Active Directory 'Gold' configuration or load/generate a current snapshot."
    Exit
}

#Begin testing
Describe 'Active Directory configuration checks' {

    Context 'Verifying Forest Configuration'{
        it "Forest FQDN $($ADGoldConfig.ForestInformation.RootDomain)" {
            $ADGoldConfig.ForestInformation.RootDomain | 
            Should be $ADSnapshot.ForestInformation.RootDomain
        }
        it "ForestMode $($ADGoldConfig.ForestInformation.ForestMode.ToString())"{
            $ADGoldConfig.ForestInformation.ForestMode.ToString() | 
            Should be $ADSnapshot.ForestInformation.ForestMode.ToString()
        }
    }

    Context 'Verifying GlobalCatalogs'{
        $ADGoldConfig.ForestInformation.GlobalCatalogs | 
        ForEach-Object{
            it "Server $($_) is a GlobalCatalog"{
                $ADSnapshot.ForestInformation.GlobalCatalogs.Contains($_) | 
                Should be $true
            }
        }
    }

    Context 'Verifying Domain Configuration'{
        it "Total Domain Controllers $($ADGoldConfig.DomainControllers.Count)" {
            $ADGoldConfig.DomainControllers.Count | 
            Should be $ADSnapshot.DomainControllers.Count
        }

        $ADGoldConfig.DomainControllers.Name | 
        ForEach-Object{
            it "DomainController $($_) exists"{
                $ADSnapshot.DomainControllers.Name.Contains($_) | 
                Should be $true
            }
        }
        it "DNSRoot $($ADGoldConfig.DomainInformation.DNSRoot)"{
            $ADGoldConfig.DomainInformation.DNSRoot | 
            Should be $ADSnapshot.DomainInformation.DNSRoot
        }
        it "NetBIOSName $($ADGoldConfig.DomainInformation.NetBIOSName)"{
            $ADGoldConfig.DomainInformation.NetBIOSName | 
            Should be $ADSnapshot.DomainInformation.NetBIOSName
        }
        it "DomainMode $($ADGoldConfig.DomainInformation.DomainMode.ToString())"{
            $ADGoldConfig.DomainInformation.DomainMode.ToString() | 
            Should be $ADSnapshot.DomainInformation.DomainMode.ToString()
        }
        it "DistinguishedName $($ADGoldConfig.DomainInformation.DistinguishedName)"{
            $ADGoldConfig.DomainInformation.DistinguishedName | 
            Should be $ADSnapshot.DomainInformation.DistinguishedName
        }
        it "Server $($ADGoldConfig.DomainInformation.RIDMaster) is RIDMaster"{
            $ADGoldConfig.DomainInformation.RIDMaster | 
            Should be $ADSnapshot.DomainInformation.RIDMaster
        }
        it "Server $($ADGoldConfig.DomainInformation.PDCEmulator) is PDCEmulator"{
            $ADGoldConfig.DomainInformation.PDCEmulator | 
            Should be $ADSnapshot.DomainInformation.PDCEmulator
        }
        it "Server $($ADGoldConfig.DomainInformation.InfrastructureMaster) is InfrastructureMaster"{
            $ADGoldConfig.DomainInformation.InfrastructureMaster | 
            Should be $ADSnapshot.DomainInformation.InfrastructureMaster
        }
    }

    Context 'Verifying Default Password Policy'{
        it 'ComplexityEnabled'{
            $ADGoldConfig.DefaultPassWordPoLicy.ComplexityEnabled | 
            Should be $ADSnapshot.DefaultPassWordPoLicy.ComplexityEnabled
        }
        it 'Password History count'{
            $ADGoldConfig.DefaultPassWordPoLicy.PasswordHistoryCount | 
            Should be $ADSnapshot.DefaultPassWordPoLicy.PasswordHistoryCount
        }
        it "Lockout Threshold equals $($ADGoldConfig.DefaultPassWordPoLicy.LockoutThreshold)"{
            $ADGoldConfig.DefaultPassWordPoLicy.LockoutThreshold | 
            Should be $ADSnapshot.DefaultPassWordPoLicy.LockoutThreshold
        }
        it "Lockout duration equals $($ADGoldConfig.DefaultPassWordPoLicy.LockoutDuration)"{
            $ADGoldConfig.DefaultPassWordPoLicy.LockoutDuration | 
            Should be $ADSnapshot.DefaultPassWordPoLicy.LockoutDuration.ToString()
        }
        it "Lockout observation window equals $($ADGoldConfig.DefaultPassWordPoLicy.LockoutObservationWindow)"{
            $ADGoldConfig.DefaultPassWordPoLicy.LockoutObservationWindow | 
            Should be $ADSnapshot.DefaultPassWordPoLicy.LockoutObservationWindow.ToString()
        }
        it "Min password age equals $($ADGoldConfig.DefaultPassWordPoLicy.MinPasswordAge)"{
            $ADGoldConfig.DefaultPassWordPoLicy.MinPasswordAge | 
            Should be $ADSnapshot.DefaultPassWordPoLicy.MinPasswordAge.ToString()
        }
        it "Max password age equals $($ADGoldConfig.DefaultPassWordPoLicy.MaxPasswordAge)"{
            $ADGoldConfig.DefaultPassWordPoLicy.MaxPasswordAge | 
            Should be $ADSnapshot.DefaultPassWordPoLicy.MaxPasswordAge.ToString()
        }
    }

    Context 'Verifying Active Directory Sites'{
        $ADGoldConfig.Sites.Name | 
        ForEach-Object{
            it "Site $($_)" {
                $ADSnapshot.Sites.Name.Contains($_) | 
                Should be $true
            } 
        }
    }

    Context 'Verifying Active Directory Sitelinks'{
        $lookupSiteLinks = $ADSnapshot.Sitelinks | Group-Object -AsHashTable -Property Name 
        $ADGoldConfig.Sitelinks | 
        ForEach-Object{
            it "Sitelink $($_.Name)" {
                $_.Name | 
                Should be $($lookupSiteLinks.$($_.Name).Name)
            } 
            it "Sitelink $($_.Name) costs $($_.Cost)" {
                $_.Cost | 
                Should be $lookupSiteLinks.$($_.Name).Cost
            }
            it "Sitelink $($_.Name) replication interval $($_.ReplicationFrequencyInMinutes)" {
                $_.ReplicationFrequencyInMinutes | 
                Should be $lookupSiteLinks.$($_.Name).ReplicationFrequencyInMinutes
            }
        }
    }

    Context 'Verifying Active Directory Subnets'{
        $lookupSubnets = $ADSnapshot.SubNets | Group-Object -AsHashTable -Property Name 
        $ADGoldConfig.Subnets | 
        ForEach-Object{
            it "Subnet $($_.Name)" {
                $_.Name | 
                Should be $lookupSubnets.$($_.Name).Name
            }
            it "Site $($_.Site)" {
                $_.Site | 
                Should be $lookupSubnets.$($_.Name).Site
            }
        } 
    }
}


Describe 'Active Directory health checks' {
    
    Context 'Checking the output of NLTest /Query'{
        $NLTest = NLTest.exe /Query
        
        it "NLTest.exe /Query Result" {
            ($NLTest | out-string).contains("Success") | Should be $true   
        }     
    }    

    Context 'Checking the output of DCDiag for issues on all DCs'{
        $DCDiag = dcdiag.exe -a
        
        it "DCDiag.exe -a Result" {
            ($DCDiag | out-string).contains("failed") | Should be $false   
        }     
    }
    
    Context 'Checking the output of RepAdmin /showrepl for replication issues'{
        (Repadmin.exe /showrepl * /csv | convertfrom-csv) | Sort "Source DSA" | ?{$_."Number of Failures" -ge 0} |
        ForEach-Object{ 
            it "Replication from $($_."Source DSA") to $($_."Destination DSA") has $($_."Number of Failures") failures" {
                $_."Number of Failures" | Should Not BeGreaterThan 0  
            } 
        }     
    }     
    
    Context 'Pinging each Domain Controller'{
        $ADGoldConfig.DomainControllers.Name | Sort |
        ForEach-Object{
            it "Ping result for Domain Controller $($_)"{
                Test-Connection $_ -Quiet | Should be $true
            }
        }
    }

    Context 'Testing local Active Directory TCP ports respond'{
        # AD Ports: https://technet.microsoft.com/en-us/library/dd772723(v=ws.10).aspx
        $Ports = @(53,88,135,139,389,445,464,636,3268,3269,9389)

        $Ports | foreach-object{
            it "Port test for TCP $_" {
                (Test-netconnection -ComputerName $env:COMPUTERNAME -Port $_).TcpTestSucceeded | Should be $true
            }
        }
    
    }

    Context 'Checking local Active Directory Windows services are running'{
        $Services = @("ADWS","BITS","CertPropSvc","CryptSvc","Dfs","DFSR","DNS","Dnscache","eventlog","gpsvc","kdc",`
                      "LanmanServer","LanmanWorkstation","Netlogon","NTDS","NtFrs","RpcEptMapper","RpcSs","SamSs",`
                      "W32Time")

        $Services | foreach-object{
            $Svc = get-service $_
            it "Service: $($Svc.DisplayName)" {
                $Svc.status | Should be "Running"
            }
        }
    }

}