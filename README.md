# Test-ActiveDirectory
Test and auditing Powershell and Pester scripts for Active Directory.

This code builds on the Active Directory Operational Test work of Irwin Strachan [(@IrwinStrachan)](https://twitter.com/IrwinStrachan) which he has detailed here:
https://pshirwin.wordpress.com/2016/04/08/active-directory-operations-test/

## Usage

Before you can verify your Active Directory configuration, you need to create an XML of your current configuration (assuming it is valid and correct) which you then store as your "Gold Configuration".
Execute "Get-ADConfig.ps1" to do this and rename the XML otuput to be ADGoldConfig-<date>.xml.
