function Get-StravaActivityDetails {
    param (
        [parameter(Mandatory = $true)]$ActivityID
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

        $responseParams = @{
            Uri     = "https://www.strava.com/api/v3/activities/$ActivityID"
            Headers = @{"Authorization" = "Bearer $bearer"}
        }
        $response = Invoke-RestMethod @responseParams
        return $response
    }
    #Get-StravaActivityDetails