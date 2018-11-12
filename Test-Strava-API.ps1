function Test-Strava-API {

    $config = Get-Content -Path .\config.json -Raw | ConvertFrom-Json
    $Athlete = $config.Strava.Athlete
    $Bearer = $config.Strava.CurrentAccessToken

    try {
        $responseParams = @{
            Uri     = "https://www.strava.com/api/v3/athletes/$Athlete"
            Headers = @{"Authorization" = "Bearer $Bearer"}
        }
        $response = Invoke-RestMethod @responseParams
        $response = $response.id
        if ($response -eq $Athlete) {
            Write-Verbose "Returned $response, expected $healthy_API_response"
            return $true
        }
    }
    catch {
        Write-Verbose "Returned $response, expected $healthy_API_response"
        return $false
    }
    return
}
#Test-Strava-API