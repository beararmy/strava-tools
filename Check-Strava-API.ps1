#Read and set config options from file
$config = Get-Content -Path .\config.json -Raw | ConvertFrom-Json
$Athlete = $config.Strava.Athlete
$Bearer = $config.Strava.Bearer
function Check-Strava-API {
    try {
        $responseParams = @{
            Uri     = "https://www.strava.com/api/v3/athletes/$Athlete"
            Headers = @{"Authorization" = "Bearer $bearer"}
        }
        $response = Invoke-RestMethod @responseParams
        $response = $response.id
        if ($response -eq $Athlete) {
            return $true;
        }
    }
    catch {
        return $false;
    }
    return
}
#Check-Strava-API