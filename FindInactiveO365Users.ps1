#Import AzureAD module
Import-Module AzureAD
#Import Exchange Online Module
Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA + "\Apps\2.0\") -Filter Microsoft.Exchange.Management.ExoPowershellModule.dll -Recurse).FullName | Where-Object { $_ -notmatch "_none_" } | Select-Object -First 1)

#Set admin UPN and inactive
$UPN = 'gadmin@domain.com'
$InactiveDays = 90

#This connects to Azure Active Directory & Exchange Online
Connect-AzureAD -AccountId $UPN
$EXOSession = New-ExoPSSession -UserPrincipalName $UPN
Import-PSSession $EXOSession -AllowClobber

$startDate = (Get-Date).AddDays(-$InactiveDays).ToString('MM/dd/yyyy')
$endDate = (Get-Date).ToString('MM/dd/yyyy')

$allUsers = @()
$allUsers = Get-AzureADUser -Filter "AccountEnabled eq true and UserType eq 'Member'" | Select-Object UserPrincipalName

$loggedOnUsers = @()
$loggedOnUsers = Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate -Operations UserLoggedIn, PasswordLogonInitialAuthUsingPassword, UserLoginFailed -ResultSize 5000

$inactiveUsers = @()
$inactiveUsers = $allUsers.UserPrincipalName | Where-Object {$loggedOnUsers.UserIds -NotContains $_}

Write-Output "The following users have not logged in for the last 90 days:"
Write-Output $inactiveUsers

Remove-PSSession $EXOSession
Disconnect-AzureAD