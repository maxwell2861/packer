

#-----------------------------------------------------------------------
# 0. NSOS
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


#-----------------------------------------------------------------------
# 1. Report
#-----------------------------------------------------------------------


Start-Transcript -Path c:\maxwell\OS_Build_Report.txt

Write-host "#-------------------------------------------------------------" 
Write-Host "#" OS INFO
Write-host "#-------------------------------------------------------------" `n
$OSINFO = (Get-CimInstance Win32_OperatingSystem)

Write-Host "OS Platform       :" $OSINFO.Caption
Write-Host "OS Version        :" $OSINFO.Version
Write-Host "OS InstallDate    :" $OSINFO.InstallDate `n

Write-host "#-------------------------------------------------------------" 
Write-Host "#" Directory List
Write-host "#-------------------------------------------------------------" 
Write-Host `n

Get-ChildItem C:\maxwell


Write-Host `n`n
Write-host "#-------------------------------------------------------------" 
Write-Host "#"NSOS
Write-host "#-------------------------------------------------------------" 

Write-Host "NSOS Script completed !!" 


Write-host "#-------------------------------------------------------------"
Write-Host "#"NSMON Status Check
Write-host "#-------------------------------------------------------------"
Write-Host `n

if ((Get-Process NSMON*).ProcessName -ne $null) {
Write-Host "NSMonService Process :" (Get-Process NSMonService).ProcessName
Write-Host "NSMON Service State  :" (Get-Service NSMon2014Service).Status
}
else
{
Write-Host  "NSMON Not Installed"
}

Write-Host `n
Write-host "#-------------------------------------------------------------"
Write-Host "#"Now Status Check
Write-host "#-------------------------------------------------------------"
Write-Host `n

Write-Host (Get-Content C:\maxwell\now\NOW.exe.config |Select-String -Pattern value)

Write-Host `n
Write-host "#-------------------------------------------------------------"
Write-Host "#"Installed Package List 
Write-host "#-------------------------------------------------------------"
Write-Host `n
Write-host "Chocolatey Version :" (choco -v)
Write-Host "Chef-Version       :" ((Get-WmiObject win32_product|?{$_.Name -match "chef"}).Version)
Write-Host "Azure CLI Version    :" ((Get-WmiObject win32_product|?{$_.Name -match ""}).Version)
Write-Host "PSWindowsUpdate    :" (Get-Module -ListAvailable  -Name PSWindowsUpdate ).Version
Write-Host `n
Write-host "#-------------------------------------------------------------"

Stop-Transcript 


#------------------------------------------------
# 2. Azure Sysprep
#------------------------------------------------

if( Test-Path c:\windows\windows\system32\Sysprep\unattend.xml){ 
    Remove-Item c:\windows\windows\system32\Sysprep\unattend.xml -Force
  }  
 
Start-Process c:\windows\System32\Sysprep\Sysprep.exe -ArgumentList "/oobe /generalize /quiet /quit"

 while($true) { 
  
  $imageState = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10 } 

  else { break } 

}
 