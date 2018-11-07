# Tests against the token expiry time in json config against now()
$config = Get-Content -Path .\config.json -Raw | ConvertFrom-Json
$CurrentTokenExpiresAt = $config.Strava.CurrentTokenExpiresAt
$now = ([int64](([datetime]::UtcNow) - (get-date "1/1/1970")).TotalSeconds)

function Test-ValidToken {
    if ($CurrentTokenExpiresAt -lt $now) {
        #Write-Host "Token has expired"
        return $false
    }
    else {
        # Write-Host "Token has"($CurrentTokenExpiresAt - $now)"seconds left"
        return $true
    }
}
#Test-ValidToken