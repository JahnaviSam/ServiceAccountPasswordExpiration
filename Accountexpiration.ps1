$scriptPath = $MyInvocation.MyCommand.Definition
$Script:ScriptPath = Split-Path $scriptPath
$script:CommonPath = "{0}\Common" -f $script:ScriptPath
$script:BinPath = "{0}\bin" -f $script:CommonPath
$script:ToolName = "CloseIcMTickets"

Write-Host "********************************Execution started*********************************"
$date = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"

#region Include IcMUtility and Common functions
. $script:CommonPath\CommonFunctions.ps1
. $script:CommonPath\IcmUtility.ps1


$accounts=get-content $script:CommonPath\Accounts.csv
 

$date= get-date
foreach($user in $accounts)

{


$data = Get-ADUser -filter {Name -eq $user -and Enabled -eq $True -and PasswordNeverExpires -eq $False} –Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed" |Select-Object -Property "Displayname",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}

if(!$data)
{

$data = Get-ADUser $user -server gme  –Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed" |Select-Object -Property "Displayname",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}

}



$accexpiry =  $data.ExpiryDate
write-host $data
$accexpiry1 = ($accexpiry).adddays(-90) 
 
if($accexpiry1 -le $date) 
{
write-host "Account $user will expire on $accexpiry" -foregroundcolor red 
#$to = $i.Emailid 

WRite-Host $user 

$TicketTitle = "Account $user will expire on $accexpiry"

 $a = Create-NewSOCTicket -TicketTitle $TicketTitle -TicketDesc "$user" -Severity 4 -TicketStatus "Active"  -SliceValue "$user"  -TicketId 0  -ObjectName "TEST"  -RoutingId "MDM://AzNet-LTM/" -CorrelationId "LTM://CachingIncidents"
 
}



else
{
write-host "Account not expiring" 
}



}

