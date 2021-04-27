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

if ((Get-EventLog -LogName Application -Source NXCERT) -ne $null){
Write-Host `n
Write-Host "NSOS Script completed !!" 
Write-Host `n
}
else
{
Write-Host `n
Write-Host "NSOS Script Failure"
Write-Host `n
}

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

Write-Host "Now Version        :" (Get-Process now).FileVersion
Write-Host "Now Service State  :" (Get-Service NOW).Status
Write-Host "Now Option         :" 
Write-Host (Get-Content C:\maxwell\now\NOW.exe.config |Select-String -Pattern value)

Write-Host `n
Write-host "#-------------------------------------------------------------"
Write-Host "#"Installed Package List 
Write-host "#-------------------------------------------------------------"
Write-Host `n
Write-host "Chocolatey Version :" (choco -v)
Write-Host "Chef-Version       :" ((Get-WmiObject win32_product|?{$_.Name -match "chef"}).Version)
Write-Host "AWS CLI Version    :" ((Get-WmiObject win32_product|?{$_.Name -match "AWS Command"}).Version)
Write-Host "Azure CLI Version    :" ((Get-WmiObject win32_product|?{$_.Name -match ""}).Version)
Write-Host "PSWindowsUpdate    :" (Get-Module -ListAvailable  -Name PSWindowsUpdate ).Version
Write-Host `n
Write-host "#-------------------------------------------------------------"

Stop-Transcript 
