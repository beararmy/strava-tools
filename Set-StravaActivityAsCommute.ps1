function Set-StravaActivityAsCommute {
    param (
        [parameter(Mandatory = $true)]$ActivityID,
        [parameter(Mandatory = $true)]$Direction    
    )

    $TokenTest = (Test-Strava-ValidToken)
    . '.\Test-Strava-ValidToken.ps1'
    if ($TokenTest -eq $False) {
        Write-Verbose "Token is invalid."
    }
    elseif ($TokenTest -eq $True) {
        write-verbose "Token is Valid."
    }

    $config = Get-Content -Path .\config.json -Raw | ConvertFrom-Json
    $bearer = $config.strava.CurrentAccessToken

    if ($ActivityID -and $Direction) {
    
        if ($Direction -eq "Workwards") {
            $re_name = $config.Strava.title_workward
        }
        elseif ($Direction -eq "Homewards") {
            $re_name = $config.strava.title_homeward
        }
        $responseParams = @{
            Uri     = "https://www.strava.com/api/v3/activities/$ActivityID`?name=$re_name&commute=1"
            Headers = @{"Authorization" = "Bearer $bearer"}
        }
        $response = Invoke-RestMethod -Method put @responseParams
        Write-Verbose "[WRITE] Updated $ActivityID name to $re_name"
    }
    else {
        Write-Error "AcitivityID and Direction are required"
    }
}
#Set-StravaActivityAsCommute