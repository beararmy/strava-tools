function Get-Strava-NewSinceLast {
    param (
        $LastRun    
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
    If (!$lastrun) { $lastrun = $config.strava.lastrun }
    $bearer = $config.strava.CurrentAccessToken
    $lastrun_unix_ts = (New-TimeSpan -Start (Get-Date -Date "01/01/1970") -End $lastrun).TotalSeconds

    $responseParams = @{
        Uri     = "https://www.strava.com/api/v3/athlete/activities?after=$lastrun_unix_ts&per_page=100"
        Headers = @{"Authorization" = "Bearer $bearer"}
    }
    $response = Invoke-RestMethod @responseParams
    return $response
}
#Get-Strava-NewSinceLast | Format-Table -AutoSize