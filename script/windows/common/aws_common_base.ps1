param(
    [string] $PREFIX    = $env:PREFIX,
    [string] $NKMAN_PASS= $env:NKMAN_PASS
 )

Write-Host "#--------------------------------------------------------------" `n
Write-Host "#"  $PREFIX  AMI Build Start `n
Write-Host "#--------------------------------------------------------------" `n

#-----------------------------------------------------------------------
# 1. Create nkman  / Change cayenne_pass
#-----------------------------------------------------------------------
net user nkman /add /y
net user nkman /passwordchg:no
WMIC USERACCOUNT WHERE "Name='nkman'" SET PasswordExpires=FALSE
net localgroup administrators nkman /add
net user nkman $NKMAN_PASS

Write-Host "#--------------------------------------------------------------" `n
Write-Host "#  Upload Package List"  `n
Write-Host "#--------------------------------------------------------------" `n

Get-ChildItem c:\maxwell -Name *.zip
Get-ChildItem c:\maxwell\script -Name *.ps1

Write-Host "#--------------------------------------------------------------" `n

#-----------------------------------------------------------------------
# 2. Time Server
#-----------------------------------------------------------------------

w32tm /config /manualpeerlist:'169.254.169.123,0x9' /syncfromflags:manual /update
w32tm /dumpreg /subkey:Parameters
net stop w32time
net start w32time
w32tm /resync
w32tm /query /status

#-------------------------------------------------------------------------------
# 3. Micolony Script [OS User API]
#-------------------------------------------------------------------------------

$USERNAME= "nkman" 
$Taskname= "Micolony-OSUser-$PREFIX"   
$Arguments= "-ExecutionPolicy Bypass C:\maxwell\script\micolony_os_user.ps1 '$PREFIX'"
$Timeline= "4am"
$Trigger= New-ScheduledTaskTrigger -At $Timeline -Daily
$Actions= New-ScheduledTaskAction -Execute PowerShell.exe -Argument $Arguments
Register-ScheduledTask -Action $Actions -Trigger $Trigger -TaskName $Taskname -Description $Taskname -User $USERNAME -Password $NKMAN_PASS
Get-ScheduledTask -TaskName $Taskname


#-----------------------------------------------------------------------
# 4. NSOS
#-----------------------------------------------------------------------


Write-Host "#--------------------------------------------------------------" `n
Write-Host "#"  NSOS Script Start `n
Write-Host "#--------------------------------------------------------------" `n


$nsos=(Get-Item C:\maxwell\nsos*.zip).FullName
$shell = new-object -com shell.application
$zip = $shell.NameSpace("$nsos")
    foreach($item in $zip.items()){
    $shell.Namespace("c:\maxwell\nsos").copyhere($item,0x14)
    }
Set-Location c:\maxwell\nsos
Start-Process ./nsos_win.bat -NoNewWindow -PassThru
Remove-Item $nsos -Force


