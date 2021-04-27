param(
    [string] $PREFIX       = $env:PREFIX
     )


Write-Host "#--------------------------------------------------------------" `n
Write-Host "#"  $PREFIX  AMI Build Start `n
Write-Host "#--------------------------------------------------------------" `n

#-----------------------------------------------
# Firewall Off
#-----------------------------------------------
# Set administrator password
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled False

#-----------------------------------------------
# 1. Drive Label 
#-----------------------------------------------

$driveC = gwmi win32_volume -Filter "DriveLetter = 'C:'"
$driveC.Label = "OS"
$driveC.put()

Write-Host "#--------------------------------------------------------------" `n
Write-Host "#  Upload Package List"  `n
Write-Host "#--------------------------------------------------------------" `n

Get-ChildItem c:\maxwell -Name *.zip
Get-ChildItem c:\maxwell\script -Name *.ps1

#remove aws log
Remove-Item -Path C:\maxwell\script\aws_nxlog.ps1 -Force

#-------------------------------------------------------------------------------
# 2. Micolony Script [OS User API]
#-------------------------------------------------------------------------------

Write-Host "#--------------------------------------------------------------" `n
Write-Host "#  OS User List -> Micolony Taskscheduler"  `n
Write-Host "#--------------------------------------------------------------" `n


$Taskname= "Micolony-OSUser-$PREFIX"   
$Arguments= "-ExecutionPolicy Bypass C:\maxwell\script\micolony_os_user.ps1 '$PREFIX'"
$Timeline= "5am"
$Trigger= New-ScheduledTaskTrigger -At $Timeline -Daily
$Actions= New-ScheduledTaskAction -Execute PowerShell.exe -Argument $Arguments
Register-ScheduledTask -Action $Actions -Trigger $Trigger -TaskName $Taskname -Description $Taskname -User "System"
Get-ScheduledTask -TaskName $Taskname