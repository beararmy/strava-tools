## Run at 1am

$config = Get-Content -Path .\config.json -Raw | ConvertFrom-Json

$Weather_API_Key = $config.weather.API_Key
#$api_key = $Weather_API_Key #Hashed for testing removal

$temp_low_sketchy = $config.weather.temp_low_sketchy
$temp_low_good = $config.weather.temp_low_good
$temp_sweetspot = $config.weather.temp_sweetspot
$temp_sweetspot_range = $config.weather.temp_sweetspot_range
$temp_high_good = $config.weather.temp_high_good
$temp_high_sketchy = $config.weather.temp_high_sketchy
$windspeed_sketchy = $config.weather.windspeed_sketchy
$windspeed_bad = $config.weather.windspeed_bad
$rain_sketchy = $config.weather.rain_sketchy
$rain_bad = $config.weather.rain_bad
$cycling_out_time = $config.weather.cycling_out_time
$cycling_home_time = $config.weather.cycling_home_time
$cycling_out_time = (get-date -UFormat %Y-%m-%d) + " " + $cycling_out_time
$cycling_home_time = (get-date -UFormat %Y-%m-%d) + " " + $cycling_home_time
#$cycling_out_time = "2018-11-12 " + $cycling_out_time      #For Development, comment above out, uncomment these
#$cycling_home_time = "2018-11-12 " + $cycling_home_time    #For Development, comment above out, uncomment these

write-verbose "[SETUP] Using ($cycling_out_time) for outwards and ($cycling_home_time) for homewards"

$locations = @(
    [PSCustomObject]@{Location = "Start" ; CityID = "2657356"; Name = "Amersham"}
    [PSCustomObject]@{Location = "Mid1" ; CityID = "2639381"; Name = "Rickmansworth"}
    [PSCustomObject]@{Location = "Mid2" ; CityID = "2651378"; Name = "Denham"}
    #[PSCustomObject]@{Location = "Mid3" ; CityID = "3333154"; Name = "Hillingdon"}
    [PSCustomObject]@{Location = "Finish" ; CityID = "2647262"; Name = "Hayes"}
)

if ($good -or $sketchy -or $bad) {
    Clear-Variable -Force good
    Clear-Variable -Force sketchy
    Clear-Variable -Force bad
}

#Fault Checking. 
# Are the cities correct?
# Did we get results? (one missing, retry, !then sketchy++;)
# all cod value shows 200
#

###### MainLoop ######
$locations | ForEach-Object {
    $CityID = $_.CityID
    $CityName = $_.Name
    $Location = $_.Location
    write-verbose "[Query] against CityID: $CityID, CityName: $CityName, Location: $Location."
    $response = (Invoke-RestMethod -Uri ("http://api.openweathermap.org/data/2.5/forecast?id=" + $CityID + "&APPID=" + $Weather_API_Key + "&units=metric")).list[1]
    #$response-home = (Invoke-RestMethod -Uri ("http://api.openweathermap.org/data/2.5/forecast?id=" + $CityID + "&APPID=" + $Weather_API_Key + "&units=metric")).list[4]
    #$out = $y
    #$home = $z

    $working_temp = ($response).main.temp_min
    $windspeed = ($response).wind.speed
    $rain_3hrs = ($response).rain."3h"

    write-verbose "[Results] gave me TEMP: $working_temp, WIND; $windspeed and RAIN: $rain_3hrs"
    $rain_3hrs = [math]::Round($rain_3hrs, 2)
    if ($error_reason) { clear-variable -Name "error_reason" }
    write-verbose "[Results] Adjusted gave me TEMP: $working_temp, WIND; $windspeed and RAIN: $rain_3hrs"


    if ($working_temp -gt "$temp_low_good" -AND $working_temp -lt "$temp_high_good") {
        Write-Verbose "[TEMP]: $CityName ($Location) is Good ($working_temp C)"
        $good++
    }
    elseif ($working_temp -gt "$temp_low_sketchy" -AND $working_temp -lt "$temp_high_sketchy") {
        Write-Verbose "[TEMP]: $CityName ($Location) is Sketchy ($working_temp C)"
        $sketchy++
    }
    else {
        Write-Verbose "[TEMP]: $CityName ($Location) is Bad ($working_temp C)"
        $error_reason = "TEMP: Failed because of Low Temperature $working_temp at $Location ($CityName)"
        $bad++
    }

    Write-Verbose "[Progress] Good: $good, Sketchy: $Sketchy, Bad: $bad"

    if ($windspeed -lt "$windspeed_sketchy") {
        Write-Verbose "[WIND]: $CityName ($Location) is Good ($windspeed M/s)"
        $good++
    }
    elseif ($windspeed -gt "$temp_low_sketchy" -AND $windspeed -lt "$windspeed_bad") {
        Write-Verbose "[WIND]: $CityName ($Location) is Sketchy ($windspeed M/s)"
        $sketchy++
    }
    else {
        Write-Verbose "[WIND]: $CityName ($Location) is Bad ($windspeed M/s)"
        $error_reason = "WIND: Failed because Windspeed over $windspeed M/s at $Location ($CityName)"
        $bad++
    }

    Write-Verbose "[Progress] Good: $good, Sketchy: $Sketchy, Bad: $bad"

    if ($rain_3hrs -lt "$rain_sketchy") {
        Write-Verbose "[RAIN]: $CityName ($Location) is Good ($rain_3hrs mm/3hrs)"
        $good++
    }
    elseif ($rain_3hrs -lt "$rain_bad") {
        Write-Verbose "[RAIN]: $CityName ($Location) is Sketchy ($rain_3hrs mm/3hrs)"
        $sketchy++
    }
    else {
        #"RAIN: $Location Is bad ($rain_3hrs M/s)"
        Write-Verbose "[RAIN]: $CityName ($Location) is Bad ($rain_3hrs mm/3hrs)"
        $error_reason = "RAIN: Failed because of rain $rain_3hrs mm/3Hrs $Location ($CityName)"
        $bad++
    }
    Write-Verbose "[Progress] Good: $good, Sketchy: $Sketchy, Bad: $bad"
    write-Verbose ""

} #Foreach

# This section gives a final Y/N
$number_of_locations = (($locations | Measure-Object).Count) * 3
$bad = [math]::Round(($bad / $number_of_locations) * 100, 0)
$sketchy = [math]::Round(( $sketchy / $number_of_locations * 100), 0)
$good = [math]::Round(($good / $number_of_locations * 100), 0)
Write-Verbose "[Summary] Locations: $number_of_locations, Good: $good, Sketchy: $Sketchy, Bad: $bad"

if ($bad) {
    Write-Verbose "Failing because of Bad Weather"
    Write-Verbose "$error_reason"
    return $false
}
else {
    return $true
}
write-verbose "$good`% were good. $sketchy`% were sketchy. $bad`% were bad."