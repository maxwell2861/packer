param(
    [string] $PREFIX       = $env:PREFIX
 )
#-------------------------------------------------------------------------------
# Install Package List
#-------------------------------------------------------------------------------

# 1. NOW
# 2. NSMON
# 3. chef-client
# 4. choco package
# 5. PSwindows Update
# 6. etc

#-------------------------------------------------------------------------------
# 1. Install NOW 
#-------------------------------------------------------------------------------
 
Write-Host "#--------------------------------------------------------------" `n
Write-Host "# $PREFIX Now install" `n
Write-Host "#--------------------------------------------------------------" `n

    #Unzip Now     
    $NOW=(Get-Item C:\maxwell\now*.zip).FullName
    $shell = new-object -com shell.application
    $zip = $shell.NameSpace("$NOW")
    foreach($item in $zip.items()){
    $shell.Namespace("c:\maxwell\now").copyhere($item,0x14)
    }
    #edit Prefix
    $ConfigFile = "C:/maxwell/now/NOW.exe.config"
    $ChangeConfig = Get-Content $ConfigFile
    $ChangeConfig | ForEach-Object {$_ -Replace "prefix", $PREFIX}| Set-Content $ConfigFile

    #install Now
    Start-Process 'C:/maxwell/now/nssm.exe' -ArgumentList "install NOW C:/maxwell/now/NOW.exe" -Wait
    Start-Process 'C:/maxwell/now/nssm.exe' -ArgumentList 'set NOW DisplayName "maxwell NOW Agent"' -Wait

    Get-Childitem C:\maxwell\now




    #remove Now.zip
    Remove-Item $NOW -Force 

#-------------------------------------------------------------------------------
# 2. Install NSMON
#-------------------------------------------------------------------------------
    

Write-Host "#--------------------------------------------------------------" `n
Write-Host "# NSMon Install"  `n
Write-Host "#--------------------------------------------------------------" `n

    #Unzip NSmon
    $NSMON=(Get-Item C:\maxwell\NSMon*.zip).FullName
    $shell = new-object -com shell.application
    $zip = $shell.NameSpace("$NSMON")
    foreach($item in $zip.items()){
    $shell.Namespace("c:\maxwell\nsmon").copyhere($item,0x14)
    }
    
    #install NSMON
    Set-Location -Path C:\maxwell\nsmon
    $INSTALL_PROC=(Start-Process nsmon_install.bat  -ArgumentList "-private 10.255.1.10 -public 10.255.1.10 -sftp true" -PassThru)
    Wait-Process -Timeout 60 -Id $INSTALL_PROC.Id -ErrorAction Ignore
    
    Get-ChildItem C:\maxwell\nsmon

    
    #remove Nsmon.zip
    Remove-Item $NSMON -Force 

#-------------------------------------------------------------------------------
# 3. Install Telnet-Client
#-------------------------------------------------------------------------------    
    Install-WindowsFeature Telnet-Client

#-------------------------------------------------------------------------------
# 4. Install chef-client
#-------------------------------------------------------------------------------

Write-Host "#--------------------------------------------------------------" `n
Write-Host "# chef server Config upload" `n
Write-Host "#--------------------------------------------------------------" `n

    #Create Chef Directory
    $CHEF=(Get-Item C:\maxwell\chef*.zip).FullName
    New-Item -Path "C:/" -Name "chef"  -ItemType "directory" |Out-Null

    #Unzip Chef
    $shell = new-object -com shell.application
    $zip = $shell.NameSpace("c:\maxwell\chef.zip")
    foreach($item in $zip.items()){
    $shell.Namespace("c:\chef").copyhere($item,0x14)
    }

    Get-ChildItem c:\chef


    
    #Remove Chef.zip
    Remove-Item $CHEF -Force

#-------------------------------------------------------------------------------
# 5. Install choco package
#-------------------------------------------------------------------------------

# Install choco

Write-Host "#--------------------------------------------------------------" `n
Write-Host "# chocolatey installation complete "  `n
Write-Host "#--------------------------------------------------------------" `n
    
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) |Out-Null
    choco -v

    
   
#-------------------------------------------------------------------------------
# 6. PSWindows Update Module
#-------------------------------------------------------------------------------

Write-Host "#--------------------------------------------------------------" `n
Write-Host "# PSWindows Update Module Install"  `n
Write-Host "#--------------------------------------------------------------" `n

    Invoke-WebRequest -Uri "https://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc/file/41459/43/PSWindowsUpdate.zip" -OutFile "c:\maxwell\PSWindowsUpdate.zip"
    $shell = new-object -com shell.application
    $zip = $shell.NameSpace("c:\maxwell\PSWindowsUpdate.zip")
    foreach($item in $zip.items()){
        $shell.Namespace("C:\Windows\System32\WindowsPowerShell\v1.0\Modules\").copyhere($item,0x14) 
    }
    Remove-Item c:\maxwell\PSWindowsUpdate.zip -Force

