# This script will find inactive users in an Office 365 tenant by searching the Office 365 Audit Log
# This is an updated script. The link to the original script is located at:
# https://github.com/OfficeDev/O365-InvestigationTooling/blob/master/InactiveUsersLast90Days.ps1
#
# Script updated by Brian Cheatham with Get Cloud Savvy as part of the training course:
# Securing Microsoft 365 for MSPs
# Usage: Please update the $UPN variable in the input section to a Global Admin account sign-in.
# This script supports MFA.

# Import AzureAD module
Import-Module AzureAD
# Import Exchange Online Module
Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA + "\Apps\2.0\") -Filter Microsoft.Exchange.Management.ExoPowershellModule.dll -Recurse).FullName | Where-Object { $_ -notmatch "_none_" } | Select-Object -First 1)

# ---- INPUT Section ---- 
$UPN = 'gadmin@domain.com'
$InactiveDays = 90
# ---- INPUT Section ---- 

# This connects to Azure Active Directory & Exchange Online
Connect-AzureAD -AccountId $UPN
$EXOSession = New-ExoPSSession -UserPrincipalName $UPN
Import-PSSession $EXOSession -AllowClobber

$startDate = (Get-Date).AddDays(-$InactiveDays).ToString('MM/dd/yyyy')
$endDate = (Get-Date).ToString('MM/dd/yyyy')

# This creates an object of all Azure AD users with enabled accounts
$allUsers = @()
$allUsers = Get-AzureADUser -Filter "AccountEnabled eq true and UserType eq 'Member'" | Select-Object UserPrincipalName

# This creates an object of specific Office 365 Audit log operations
$loggedOnUsers = @()
$loggedOnUsers = Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate -Operations UserLoggedIn, PasswordLogonInitialAuthUsingPassword, UserLoginFailed -ResultSize 5000

# This loops through the Azure AD users to see if the UPN is found in the Office 365 Audit log
$inactiveUsers = @()
$inactiveUsers = $allUsers.UserPrincipalName | Where-Object {$loggedOnUsers.UserIds -NotContains $_}

# This writes the inactive users output to the screen
Write-Output "The following users have not logged in for the last 90 days:"
Write-Output $inactiveUsers

# Clean up the PowerShell sessions
Remove-PSSession $EXOSession
Disconnect-AzureAD