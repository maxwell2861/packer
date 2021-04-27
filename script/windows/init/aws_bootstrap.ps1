<powershell>

#-----------------------------------------------
# Winrm / Firewall Setting 
#-----------------------------------------------

# Set administrator password
net user Administrator 'P@ssw0rd'
wmic useraccount where "name='Administrator'" set PasswordExpires=FALSE

Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled False

Set-ExecutionPolicy RemoteSigned -Force -ErrorAction SilentlyContinue

Enable-PSRemoting -Force
set-item WSMan:\localhost\MaxTimeoutms -Value 1800000
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value true
Set-Item WSMan:\localhost\Service\Auth\Basic -Value true
Set-Item WSMan:\localhost\Client\Auth\Basic -Value true
Set-Item WSMan:\localhost\Client\TrustedHosts -Value * -Force

#-----------------------------------------------
# Drive Label 
#-----------------------------------------------

$driveC = gwmi win32_volume -Filter "DriveLetter = 'C:'"
$driveC.Label = "OS"
$driveC.put()

</powershell>