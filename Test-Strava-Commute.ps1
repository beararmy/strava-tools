function Test-Strava-Commute {
    param (
    [parameter(Mandatory = $true)]$ActivityID
    )
    . '.\Test-Strava-ValidToken.ps1'
    $TokenTest = (Test-Strava-ValidToken)
    if ($TokenTest -eq $False) {
        Write-Verbose "Token is invalid."
    }
    elseif ($TokenTest -eq $True) {
        write-verbose "Token is Valid."
    }

    $config = Get-Content -Path .\config.json -Raw | ConvertFrom-Json
    $bearer = $config.strava.CurrentAccessToken

    $responseParams = @{
        Uri     = "https://www.strava.com/api/v3/activities/$ActivityID"
        Headers = @{"Authorization" = "Bearer $bearer"}
    }
    
    $response = Invoke-RestMethod @responseParams

    # Set some local variables
    $CommuteChance = 0
    $commute_num_tests = 3 # Number of tests (maybe automate this)
    $commute_distance = $config.locations.distance
    $commute_distance_flex = $config.Strava.Commute.commute_distance_flex
    $distance = [Int]$response.distance
    $activity_start_time = $response.start_date_local.Substring(11, 8)
    $commute_start_time_out_early = $config.Strava.Commute.workward_earliest_leave
    $commute_start_time_out_late = $config.Strava.Commute.workward_latest_leave
    $commute_start_time_in_early = $config.Strava.Commute.homeward_earliest_leave
    $commute_start_time_in_late = $config.Strava.Commute.homeward_latest_leave
    $commute_start_lat_lng_home = $config.Strava.Commute.home_lat, $config.Strava.Commute.home_long
    $commute_start_lat_lng_work = $config.Strava.Commute.work_lat, $config.Strava.Commute.work_long

    ## Did the Activity start from home or work?
    if (($($response.start_latlng[0]) -eq $commute_start_lat_lng_home[0]) -and $($response.start_latlng[1]) -eq $commute_start_lat_lng_home[1]) {
        Write-Verbose "[LOCATION] Checking location of $($response.start_latlng[0,1]). Expected $commute_start_lat_lng_home for workward, +1 to CommuteChance"
        $Direction = "Workwards"
    }
    elseif (($($response.start_latlng[0]) -eq $commute_start_lat_lng_work[0]) -and $($response.start_latlng[1]) -eq $commute_start_lat_lng_work[1]) {
        Write-Verbose "[LOCATION] Checking location of $($response.start_latlng[0,1]). Expected $commute_start_lat_lng_work for homeward, +1 to CommuteChance"
        $Direction = "Homewards"
    }

    ## Distance based checks
    if ($distance -gt ($commute_distance - $commute_distance_flex)) {
        Write-Verbose "[DISTANCE] $distance > $($commute_distance-$commute_distance_flex), +1 to CommuteChance"
        $CommuteChance = $CommuteChance + 1
    }
    if ($distance -lt ($commute_distance + $commute_distance_flex)) {
        Write-Verbose "[DISTANCE] $distance < $($commute_distance+$commute_distance_flex), +1 to CommuteChance"
        $CommuteChance = $CommuteChance + 1
    }

    ## Time of Day based checks
    if ($activity_start_time -gt $commute_start_time_out_early -and $activity_start_time -lt $commute_start_time_out_late) {
        Write-Verbose "[START TIME] Start of $activity_start_time was between $commute_start_time_out_early and $commute_start_time_out_late, +1 to CommuteChance"
        $CommuteChance = $CommuteChance + 1
    }
    elseif ($activity_start_time -gt $commute_start_time_in_early -and $activity_start_time -lt $commute_start_time_in_late) {
        Write-Verbose "[START TIME] Start of $activity_start_time was between $commute_start_time_in_early and $commute_start_time_in_late, +1 to CommuteChance"
        $CommuteChance = $CommuteChance + 1
    }

    # Do Some maths, was it a commute?
    if ($CommuteChance -ge ($commute_num_tests - 1)) {
        $CommuteBool = $True
        Write-Verbose "[SUMMARY] Chance of Commute was $CommuteChance, required $($commute_num_tests-1). Commute Success"
    }
    else {
        Write-Verbose "[SUMMARY] Chance of Commute was $CommuteChance, required $($commute_num_tests-1). Commute Failed"
        $CommuteBool = $False
    }

    return $CommuteBool, $Direction

}
#Test-Strava-Commute