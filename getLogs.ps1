$startTime = Read-Host "Enter start time (MM/dd/yyyy HH:mm:ss)"
$endTime = Read-Host "Enter end time (MM/dd/yyyy HH:mm:ss)"
$resultFilePath = Read-Host "Enter result file path"

$events = Get-WinEvent -FilterHashtable @{
    LogName='System','Windows PowerShell';
    StartTime=$startTime;
    EndTime=$endTime;
    Level = 2,3
}

$groupedEvents = $events | Group-Object -Property EventID | Sort-Object Count -Descending

function Format-Event {
    param($group)
    $output = "[ $($group.Name) ] [ Title ]`n`n"
    foreach ($event in $group.Group | Sort-Object TimeCreated -Descending) {
        $output += "[ $($event.TimeCreated) ] [ $($event.Message.Trim()) ]`n"
    }
    $output
}

$output = foreach ($group in $groupedEvents) {
    Format-Event $group
}

$output | Out-File -FilePath $resultFilePath
