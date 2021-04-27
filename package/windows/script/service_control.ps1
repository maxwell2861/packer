$service = $args[0]
$action = $args[1]

###############################################################
#                                          Create by Maxwell  #
#                                         Version (2019-08-07)#
# service_control (start|stop|stop-force|status)              #
#                                                             #
# EXAMPLE) powershell .\service_control.ps1 game1 start       #
#                                                             #
###############################################################

#Start-service Function 
function Start-GameService ($service) {
    
    #Define Variables
    $timespan = New-Object -TypeName System.Timespan -ArgumentList 0,0,60
    $svc = Get-Service -Name $service
      
    if ($svc -eq $null) {Write-Host ([System.Net.Dns]::GetHostName()) : $service Not found }
    if ($svc.Status -eq [ServiceProcess.ServiceControllerStatus]::Running) {Write-Host ([System.Net.Dns]::GetHostName()) : $svc.Name is Already Running }
    $svc |Start-Service
    try {
        $svc.WaitForStatus([ServiceProcess.ServiceControllerStatus]::Running, $timespan)
    }
    catch [ServiceProcess.TimeoutException] {
        Write-Host ([System.Net.Dns]::GetHostName()) : $svc.Name "Start Failed ! Check Server Log" 
    }
    Write-Host ([System.Net.Dns]::GetHostName()) : $svc.Name is $svc.Status 
}


#Stop-Service Function
function Stop-GameService ($service) {
    
    #Define Variables
    $timespan = New-Object -TypeName System.Timespan -ArgumentList 0,0,60
    $svc = Get-Service -Name $service
      
    if ($svc -eq $null) {Write-Host ([System.Net.Dns]::GetHostName()) : $service Not found }
    if ($svc.Status -eq [ServiceProcess.ServiceControllerStatus]::Stopped) {Write-Host ([System.Net.Dns]::GetHostName()) : $svc.Name is Already Stopped }
    $svc |Stop-Service -ErrorAction SilentlyContinue -Force
    try {
        $svc.WaitForStatus([ServiceProcess.ServiceControllerStatus]::Stopped, $timespan)
    }
    catch [ServiceProcess.TimeoutException] {
        Write-Host ([System.Net.Dns]::GetHostName()) : $svc.Name "Stop Failed ! Check Server Log" 
    }
    Write-Host ([System.Net.Dns]::GetHostName()) : $svc.Name is $svc.Status 
}

if ($action -eq "start"){
    #Start Service
    Start-GameService $service
     }

elseif($action -eq "stop"){
    #Stop-service 
    Stop-GameService $service
    }

elseif($action -eq "restart"){
    #Stop & Restart
    Stop-GameService $service
    Start-GameService $service

    }
elseif($action -eq "status"){

        Write-Host "#------------------------------------------------" `n
        Write-Host  DateTime :(Get-Date -Format 'yy-MM-dd  hh:mm:ss')
        Write-Host  Hostname : ([System.Net.Dns]::GetHostName())
        write-host  Service  : $service
        write-host  PID  : (Get-wmiobject win32_service | ?{ $_.name -eq "$service"}).processId
        Write-host  Status   : (Get-Service $service).status  `n
        Write-Host "#------------------------------------------------" `n

}