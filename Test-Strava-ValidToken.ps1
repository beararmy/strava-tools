function Test-Strava-ValidToken {

$config = Get-Content -Path .\config.json -Raw | ConvertFrom-Json
$CurrentTokenExpiresAt = $config.Strava.CurrentTokenExpiresAt
$now = ([int64](([datetime]::UtcNow) - (get-date "1/1/1970")).TotalSeconds)
    
    if ($CurrentTokenExpiresAt -lt $now) {
        Write-Verbose "Token has expired"
        return $false
    }
    else {
        $tokenexpiresin = $CurrentTokenExpiresAt - $now
        Write-Verbose "Token has $tokenexpiresin seconds left"
        return $true
    }
}
#Test-Strava-ValidToken