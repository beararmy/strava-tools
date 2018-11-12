function Test-OpenWeather-API {

    $config = Get-Content -Path .\config.json -Raw | ConvertFrom-Json
    $API_Key = $config.weather.API_Key
    $CityID = $config.weather.Weather_Test_City   

    try {
        $response = (Invoke-RestMethod -Uri ("http://api.openweathermap.org/data/2.5/forecast?id=" + $CityID + "&APPID=" + $api_key + "&units=metric"))
        $response = $response.cod
        if ($response -eq "200") {
            Write-Verbose "Returned $response, expected 200"
            return $true
        }
    }
    catch {
        Write-Verbose "Returned $response, expected 200"
        return $false
    }
    return
}
#Test-OpenWeather-API