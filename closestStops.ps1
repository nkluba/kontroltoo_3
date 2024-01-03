Import-Module -Name Microsoft.PowerShell.Utility -Force

function Get-Distance {
    param (
        [double]$lat1, [double]$lon1,
        [double]$lat2, [double]$lon2
    )

    # Earth radius
    $R = 6371
    $dLat = [System.Math]::PI / 180 * ($lat2 - $lat1)
    $dLon = [System.Math]::PI / 180 * ($lon2 - $lon1)

    $a = [System.Math]::Sin($dLat / 2) * [System.Math]::Sin($dLat / 2) + [System.Math]::Cos([System.Math]::PI / 180 * $lat1) * [System.Math]::Cos([System.Math]::PI / 180 * $lat2) * [System.Math]::Sin($dLon / 2) * [System.Math]::Sin($dLon / 2)
    $c = 2 * [System.Math]::Atan2([System.Math]::Sqrt($a), [System.Math]::Sqrt(1 - $a))

    $distance = $R * $c
    return $distance
}

$stops = Import-Csv -Path "stops.txt"

$busStopName = Read-Host "Enter bus stop"
$radius = Read-Host "Enter the radius (in km)"

$filteredStops = $stops | Where-Object { $_.stop_name -eq $busStopName }

if ($filteredStops.Count -eq 0) {
    Write-Host "No bus stops found for the input name '$busStopName'"
}
else {
    if ($filteredStops.Count -gt 1) {
        Write-Host "Multiple bus stops found with '$busStopName' name, choose one:"
$index = 1
$filteredStops | ForEach-Object {
    Write-Host "$index. $($_.stop_name), area: $($_.stop_area), stop location: $($_.stop_lat) $($_.stop_lon)"
    $index++
}

        $choice = Read-Host "Enter the number of the needed bus stop."
        $selectedStop = $filteredStops[$choice - 1]
    }
    else {
        $selectedStop = $filteredStops[0]
    }

    $closestStops = $stops | Where-Object {
        $_.stop_name -ne $selectedStop.stop_name -and
        (Get-Distance $selectedStop.stop_lat $selectedStop.stop_lon $_.stop_lat $_.stop_lon) -le $radius
    } | Sort-Object stop_name, stop_area -Unique

    if ($closestStops.Count -eq 0) {
        Write-Host "No other bus stops found within the radius ($radius km) of '$busStopName'"
    }
    else {
        Write-Host "Closest bus stops within a $radius km radius of '$busStopName':"
        $closestStops | ForEach-Object {
            $distance = [math]::Round((Get-Distance $selectedStop.stop_lat $selectedStop.stop_lon $_.stop_lat $_.stop_lon), 2)
            Write-Host "$($_.stop_name), area: $($_.stop_area), distance: $distance km"
        }
    }
}
