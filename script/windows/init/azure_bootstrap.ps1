#--------------------------------------
# Winrm Setting
#--------------------------------------
Enable-PSRemoting -Force

set-item WSMan:\localhost\MaxTimeoutms -Value 1800000
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value true
Set-Item WSMan:\localhost\Service\Auth\Basic -Value true
Set-Item WSMan:\localhost\Client\Auth\Basic -Value true
Set-Item WSMan:\localhost\Client\TrustedHosts -Value * -Force

