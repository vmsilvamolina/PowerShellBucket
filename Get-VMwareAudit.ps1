cls
Write-host "Conexión al vcenter" -ForegroundColor DarkGray
$vcServer = Read-Host -Prompt 'vcenter: '
$Cred = Get-Credential -Message 'Ingresar usuario y contraseña'
Connect-VIServer -Server $vcServer -Credential $Cred -InformationAction SilentlyContinue | Out-Null

$VM = Get-VM "Win8-View-1"

$hours = 360
$tasknumber = 999
$eventnumber = 100
$FileName = "C:\Users\Victor\Desktop\VM-device-operations.csv"
 
$report = @()
 
$taskMgr = Get-View TaskManager
$eventMgr = Get-View eventManager

Write-host "Recolección de datos" -ForegroundColor DarkGray
 
$tFilter = New-Object VMware.Vim.TaskFilterSpec
$tFilter.Time = New-Object VMware.Vim.TaskFilterSpecByTime
$tFilter.Time.beginTime = (Get-Date).AddHours(-$hours)
$tFilter.Time.timeType = "startedTime"
 
$tCollector = Get-View ($taskMgr.CreateCollectorForTasks($tFilter))
 
$dummy = $tCollector.RewindCollector
$tasks = $tCollector.ReadNextTasks($tasknumber)
 
while($tasks){
    $tasks | where {$_.Name -eq "ReconfigVM_Task"} | % {
        $task = $_
        $eFilter = New-Object VMware.Vim.EventFilterSpec
        $eFilter.eventChainId = $task.EventChainId
 
        $eCollector = Get-View ($eventMgr.CreateCollectorForEvents($eFilter))
        $events = $eCollector.ReadNextEvents($eventnumber)
        while($events){
            $events | % {
                $event = $_
                switch($event.GetType().Name){
                    "VmReconfiguredEvent" {
                        $event.ConfigSpec.DeviceChange | % {
                            if($_.Device -ne $null){
                                $report += New-Object PSObject -Property @{
                                    VMname = $task.EntityName
                                    Start = $task.StartTime
                                    Finish = $task.CompleteTime
                                    Result = $task.State
                                    User = $task.Reason.UserName
                                    Device = $_.Device.GetType().Name
                                    Operation = $_.Operation
                                }
                            }
                        }
                    }
                    Default {}
                }
            }
            $events = $eCollector.ReadNextEvents($eventnumber)
        }
        $ecollection = $eCollector.ReadNextEvents($eventnumber)
# By default 32 event collectors are allowed. Destroy this event collector.
        $eCollector.DestroyCollector()
    }
    $tasks = $tCollector.ReadNextTasks($tasknumber)
}
 
# By default 32 task collectors are allowed. Destroy this task collector.
$tCollector.DestroyCollector()
 
$Report | Sort-Object -Property Start | Export-Csv $FileName -NoTypeInformation -UseCulture
Write-host ''
Write-host "Archivo generado: $FileName" -ForegroundColor DarkGray