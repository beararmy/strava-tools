function Test-Strava-ValidToken {

    $config = Get-Content -Path .\config.json -Raw | ConvertFrom-Json
    $CurrentTokenExpiresAt = $config.Strava.CurrentTokenExpiresAt
    $now = ([int64](([datetime]::UtcNow) - (get-date "1/1/1970")).TotalSeconds)
    
    if ($CurrentTokenExpiresAt -lt $now) {
        Write-Verbose "Token expired. Expired at $CurrentTokenExpiresAt, time is $now"
        return $false
    }
    else {
        $tokenexpiresin = $CurrentTokenExpiresAt - $now
        Write-Verbose "Token Valid. Expires at $CurrentTokenExpiresAt, time is $now"
        return $true
    }
}
#Test-Strava-ValidToken