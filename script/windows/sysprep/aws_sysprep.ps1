
param(
  [string] $WINRM_PASS = $env:WINRM_PASS
)


#------------------------------------------------
# 1. EC2 Config
#------------------------------------------------

$OSProdName=(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

#2012R2

if ($OSProdName -match "2012") {
    $EC2SettingsFile1="C:\\Program Files\\Amazon\\Ec2ConfigService\\Settings\\Config.xml"
    $xml1=[xml](get-content $EC2SettingsFile1)
    $xmlElement1=$xml1.get_DocumentElement()
    $xmlElementToModify1=$xmlElement1.Plugins
    foreach ($element1 in $xmlElementToModify1.Plugin) {
      if ($element1.name -eq "Ec2SetPassword") {
          $element1.State="Disabled"
      } elseif ($element1.name -eq "Ec2SetComputerName") {
          $element1.State="Disabled"
      } elseif ($element1.name -eq "Ec2HandleUserData") {
        $element1.State="Enabled"
      }
    }
    $xml1.Save($EC2SettingsFile1)

    $EC2SettingsFile2="C:\\Program Files\\Amazon\\Ec2ConfigService\\Settings\\BundleConfig.xml"
    $xml2=[xml](get-content $EC2SettingsFile2)
    $xmlElement2=$xml2.get_DocumentElement()
    $xmlElementToModify2=$xmlElement2.Plugins
    foreach ($element2 in $xmlElementToModify2.Plugin) {
      if ($element2.Name -eq "AutoSysprep") {
          $element2.Value="No"
      }
    }
    $xml2.Save($EC2SettingsFile2)
}
#2016 & 2019
if ($OSProdName -match "2016" -or $OSProdName -match "2019") {
		& Powershell.exe "C:/ProgramData/Amazon/EC2-Windows/Launch/Scripts/InitializeInstance.ps1 -Schedule"
		if ($LASTEXITCODE -ne "0") {
				Write-Warning "Failed to run InitializeInstance"
		}
		& Powershell.exe "C:/ProgramData/Amazon/EC2-Windows/Launch/Scripts/SysprepInstance.ps1 -NoShutdown"
		if ($LASTEXITCODE -ne "0") {
				Write-Warning "Failed to run Sysprep"
		}
}


#------------------------------------------------
# 2. Change Adminitrator Password
#------------------------------------------------

net user Adminitrator $WINRM_PASS