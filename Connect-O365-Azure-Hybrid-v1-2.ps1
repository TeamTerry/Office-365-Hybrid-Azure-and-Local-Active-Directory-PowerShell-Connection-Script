### Only works on INTERNAL networks connecting to the internal FQDN of an Exchange CAS server.

####################################################################################################################################
###                                                                                                                              ###
###  	Script by Terry Munro -                                                                                                  ###
###     Technical Blog -               http://365admin.com.au                                                                    ###
###     Webpage -                      https://www.linkedin.com/in/terry-munro/                                                  ###
###     GitHub Scripts -               https://github.com/TeamTerry                                                              ###
###                                                                                                                              ###
###     https://github.com/TeamTerry/Office-365-Hybrid-Azure-and-Local-Active-Directory-PowerShell-Connection-Script             ### 
###                                                                                                                              ###
###     Version 1.1 - 16/05/2017                                                                                                 ###
###     Revision -                                                                                                               ###
###               v1.0  14/05/2017     Initial script                                                                            ###
###               v1.1  18/05/2017     Added Support Guides URL and TechNet download link - Removed message from cred pop-up     ### 
###               v1.2  30/05/2017     Added connection to Azure AD Connect (DirSync) Server                                     ###  	
###                                                                                                                              ###
###     Guideance on Remote Azure AD Sync - https://community.spiceworks.com/topic/724324-invoke-command-import-module           ###
###                                                                                                                              ###
###     Please ensure you read and understand the Notes for Usage below                                                          ###
###                                                                                                                              ###
###                                                                                                                              ###
####################################################################################################################################

####  Notes for Usage  ##############################################################################
#                                                                                                   #
#  Ensure you update the six variables in the script section                                        #                                          
#  - $Tenant - Edit this with your Office 365 tenant name                                           #
#  - $LocalExchServer - Edit this with your local Exchange CAS Server name                          #
#  - $LocalCredential - Edit this with your domain name and Exchange - AD adminstrator account      # 
#  - $CloudCred - Enter your Office 365 user name, including the tenant                             #
#  - $AzureADConnect - Enter the FQDN of your Azure AD Connect server                               #
#  - $AzureADCred - Enter the credentials of your Azure AD Connect account (internal admin)         #
#                                                                                                   #
#  Support Guides -                                                                                 #
#   - Pre-Requisites - Configuring your PC                                                          #
#   - - -  http://www.365admin.com.au/2017/05/how-to-configure-your-desktop-pc-for.html             #      
#   - Usage Guide - Editing the connection script                                                   # 
#   - - - http://www.365admin.com.au/2017/05/how-to-connect-to-hybrid-exchange.html                 #
#                                                                                                   #
#####################################################################################################


#####################################################################################################

###                      Edit the six variables below with your details                          ###


$Tenant = "TenantName"

$LocalExchServer = "LocalExchangeCAS-ServerName.internal.domain.com"

$LocalCredential = Get-Credential "domain\administrator"

$CloudCred = Get-credential "admin@tenant.onmicrosoft.com"

$AzureADConnect = "AzureADConnectServer.internal.domain.com"

$AzureADCred = "domain\administrator"


#####################################################################################################




###  SharePoint Online
Import-Module Microsoft.Online.SharePoint.PowerShell
Connect-SPOService -Url "https://$($Tenant)-admin.sharepoint.com" -Credential $CloudCred


###   Active Directory Local
Import-Module ActiveDirectory


###   Exchange Local
$EXLSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$($LocalExchServer)/PowerShell/ -Authentication Kerberos -Credential $LocalCredential
Import-PSSession $EXLSession -AllowClobber -Prefix EXL


###   Exchange Online
$EXOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $CloudCred -Authentication Basic -AllowRedirection
Import-PSSession $EXOSession –AllowClobber -Prefix EXO


### Exchange Online Protection
$EOPSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.protection.outlook.com/powershell-liveid/ -Credential $CloudCred -Authentication Basic -AllowRedirection
Import-PSSession $EOPSession –AllowClobber -Prefix EOP


### Compliance Center
$ccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.compliance.protection.outlook.com/powershell-liveid/" -Credential $CloudCred -Authentication "Basic" -AllowRedirection
Import-PSSession $ccSession –AllowClobber -Prefix CC


### Azure Active Directory Rights Management
Import-Module AADRM
Connect-AadrmService -Credential $CloudCred
    

### Azure Resource Manager
Login-AzureRmAccount -Credential $CloudCred


###   Azure Active Directory v1.0
Import-Module MsOnline
Connect-MsolService -Credential $CloudCred


###  SharePoint Online
Import-Module Microsoft.Online.SharePoint.PowerShell
Connect-SPOService -Url "https://$($Tenant)-admin.sharepoint.com" -Credential $CloudCred


### Skype Online
Import-Module SkypeOnlineConnector
$SkypeSession = New-CsOnlineSession -Credential $CloudCred
Import-PSSession $SkypeSession –AllowClobber


### Azure AD v2.0
Connect-AzureAD -Credential $CloudCred


### Azure AD Connect (DirSync)
$ADConnectSession = New-PSSession -Computername $AzureADConnect -Credential $AzureADCred
Invoke-Command -Session $ADConnectSession {Import-Module ADSync}
Import-PSSession -Session $ADConnectSession -Module ADSync 