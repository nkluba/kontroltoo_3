$startTime = Read-Host "Enter start time (MM/dd/yyyy HH:mm:ss)"
$endTime = Read-Host "Enter end time (MM/dd/yyyy HH:mm:ss)"
$resultFilePath = Read-Host "Enter result file path"

$events = Get-WinEvent -FilterHashtable @{
    LogName='System','Windows PowerShell';
    StartTime=$startTime;
    EndTime=$endTime;
	Level = 2,3
}

Write-Host $events

$groupedEvents = $events | Group-Object -Property EventID | Sort-Object Count -Descending

function Format-Event {
    param($event)
    "[ $($event.EventID) ] [ $($event.Message.Split("`n")[0]) ]`n[ $($event.TimeCreated) ] [ $($event.Message.Trim()) ]"
}

$output = foreach ($group in $groupedEvents) {
    $group.Group | Sort-Object TimeCreated -Descending | ForEach-Object { Format-Event $_ }
}

$output | Out-File -FilePath $resultFilePath

Write-Host "Script completed successfully. Results saved to: $resultFilePath"
