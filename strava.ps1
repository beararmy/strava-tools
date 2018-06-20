$config = Get-Content -Path .\config.json -Raw | ConvertFrom-Json

$var_athlete = $config.var_athlete
$var_lastrun = $config.var_lastrun
$var_bearer = $config.var_bearer
$var_writable_bearer = $config.var_writable_bearer

$var_lastrun_unix_ts = (New-TimeSpan -Start (Get-Date -Date "01/01/1970") -End $var_lastrun).TotalSeconds

function Strava-NewSinceLast {
    param ($LastRun)
    $responseParams = @{
        Uri     = "https://www.strava.com/api/v3/athlete/activities?after=$var_lastrun_unix_ts&per_page=100"
        Headers = @{"Authorization" = "Bearer $var_bearer"}
    }
    $response = Invoke-RestMethod @responseParams
    return $response
} #Strava-NewSinceLast

function Strava-Details {
    param ($ActivityID)
    $responseParams = @{
        Uri     = "https://www.strava.com/api/v3/activities/$ActivityID"
        Headers = @{"Authorization" = "Bearer $var_bearer"}
    }
    $response = Invoke-RestMethod @responseParams
    return $response
} #Strava-Details

function Strava-SetAsCommute {
    param ($ActivityID, $Direction)

    if ($ActivityID -and $Direction) {
    
        if ($Direction -eq "Workwards") {
            $re_name = $config.commute_settings.title_workward
        }
        elseif ($Direction -eq "Homewards") {
            $re_name = $config.commute_settings.title_homeward
        }
        $responseParams = @{
            Uri     = "https://www.strava.com/api/v3/activities/$ActivityID`?name=$re_name&commute=1"
            Headers = @{"Authorization" = "Bearer $var_writable_bearer"}
        }
        $response = Invoke-RestMethod -Method put @responseParams
        Write-Verbose "[WRITE] Updated $ActivityID name to $re_name"
    }
    else {
        Write-Error "AcitivityID and Direction are required"
    }
} #Strava-SetAsCommute

function Strava-CheckCommute {
    param ($ActivityID)
    $config = Get-Content -Path .\config.json -Raw | ConvertFrom-Json
    $responseParams = @{
        Uri     = "https://www.strava.com/api/v3/activities/$ActivityID"
        Headers = @{"Authorization" = "Bearer $var_bearer"}
    }
    $response = Invoke-RestMethod @responseParams

    # Set some local variables
    $CommuteChance = 0
    $commute_num_tests = 3 # Number of tests (maybe automate this)
    $commute_distance = $config.locations.distance
    $commute_distance_flex = 250 # metres +-
    $distance = [Int]$response.distance

    $activity_start_time = $response.start_date_local.Substring(11, 8)
    $commute_start_time_out_early = $config.times.workward_earliest_leave
    $commute_start_time_out_late = $config.times.workward_latest_leave
    $commute_start_time_in_early = $config.times.homeward_earliest_leave
    $commute_start_time_in_late = $config.times.homeward_latest_leave

    $commute_start_lat_lng_home = $config.locations.home_lat, $config.locations.home_long
    $commute_start_lat_lng_work = $config.locations.work_lat, $config.locations.work_long

    ## Location based checks
    if (($($response.start_latlng[0]) -eq $commute_start_lat_lng_home[0]) -and $($response.start_latlng[1]) -eq $commute_start_lat_lng_home[1]) {
        Write-Verbose "[LOCATION] Checking location of $($response.start_latlng[0,1]). Expect $commute_start_lat_lng_home for workward, +1 to CommuteChance"
        $Direction = "Workwards"
    }
    elseif (($($response.start_latlng[0]) -eq $commute_start_lat_lng_work[0]) -and $($response.start_latlng[1]) -eq $commute_start_lat_lng_work[1]) {
        Write-Verbose "[LOCATION] Checking location of $($response.start_latlng[0,1]). Expect $commute_start_lat_lng_work for homeward, +1 to CommuteChance"
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
        $CommuteBool = 1
        Write-Verbose "[SUMMARY] Chance of Commute was $CommuteChance, required $($commute_num_tests-1). Commute Success"
    }
    else {
        Write-Verbose "[SUMMARY] Chance of Commute was $CommuteChance, required $($commute_num_tests-1). Commute Failed"
        $CommuteBool = 0 
    }

    return $CommuteBool, $Direction

} #Strava-CheckCommute

# Feed this an activityID and it will guesstimate if it's a commute or not.
#Strava-CheckCommute -ActivityID 1626198717

# Eventually this will enable periodic importing and background running, pulls data since -LastRun
#Strava-NewSinceLast -LastRun $var_lastrun_unix_ts -Bearer $var_bearer | ft

# Generic table of details for an activity
#Strava-Details -ActivityID 1626198717 -Bearer $var_bearer | ft