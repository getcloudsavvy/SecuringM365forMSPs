# CHANGE THESE VALUES
$TenantID = '96cc7f3a-0606-4b5a-b6d7-807e3c8f8198' #The Directory ID from Azure AD
$ClientID = 'aa019bdc-1270-45f5-b78f-b55c2271193a' #The Application ID of the registered app
$ClientSecret = 'Jrw664md_6S4~rgLd.3dnIXVM5GJ_5lqX~' #The secret key of the registered app
# ------------------------------------------------------

# DO NOT CHANGE THESE
$body = @{grant_type="client_credentials";scope="https://graph.microsoft.com/.default";client_id=$ClientID;client_secret=$ClientSecret}
$oauth = Invoke-RestMethod -Method Post -Uri https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token -Body $body
$token = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}
# ------------------------------------------------------

$Date = (Get-Date).AddDays(-1)
$DateFormatted = Get-Date $Date -Format yyyy-MM-dd

$O365Usage_GraphUri = "https://graph.microsoft.com/v1.0/reports/getOffice365ActiveUserDetail(period='D90')"
$O365Usage_Reports = Invoke-RestMethod -Method Get -Uri $O365Usage_GraphUri -Headers $token | ConvertFrom-Csv

$AzureAD_GraphUri = 'https://graph.microsoft.com/v1.0/auditLogs/signIns?$filter=createdDateTime ge ' + $($DateFormatted.ToString())
$AzureAD_Reports = (Invoke-RestMethod -Method Get -Uri $AzureAD_GraphUri -Headers $token).value

foreach ($O365Usage_Report in $O365Usage_Reports) {

    $AzureAD_SignIns = $AzureAD_Reports | where {$_.UserPrincipalName -eq $O365Usage_Report.'User Principal Name'}
    $AzureAD_SignIns
}

$head = @"

<Title>O365 Inactivity Report - Over 90 Days</Title>
    <style>
    body { background-color:#E5E4E2;
          font-family:Monospace;
          font-size:10pt; }
    td, th { border:0px solid black; 
            border-collapse:collapse;
            white-space:pre; }
    th { color:white;
        background-color:black; }
    table, tr, td, th {
         padding: 2px; 
         margin: 0px;
         white-space:pre; }
    tr:nth-child(odd) {background-color: lightgray}
    table { width:95%;margin-left:5px; margin-bottom:20px; }
    h2 {
    font-family:Tahoma;
    color:#6D7B8D;
    }
    .footer 
    { color:green; 
     margin-left:10px; 
     font-family:Tahoma;
     font-size:8pt;
     font-style:italic;
    }
    </style>
"@
 
# $head,$TeamsDeviceReports,$TeamsUserReports,$EmailReports,$MailboxUsage,$O365ActivationsReports,$OneDriveActivityReports,$OneDriveUsageReports,$SharepointUsageReports | out-file "C:\Temp\$($Customer.name).html"
     
    
