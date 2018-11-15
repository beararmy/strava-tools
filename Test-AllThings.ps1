function Test-AllThings {
    . "./Test-HASS-API.ps1"
    . "./Test-OpenWeather-API.ps1"
    . "./Test-Strava-API.ps1"
    . "./Test-Strava-ValidToken.ps1"
    ########################################################        
    $result = (Test-HASS-API)
    if ($result -eq $true) {
        Write-Host "HASS-API " -NoNewline ; Write-Host -ForegroundColor Green "Success"
    }
    elseif ($result -eq $false) {
        Write-Host "HASS-API " -NoNewline ; Write-Host -ForegroundColor Red "Failed"
    }
    ########################################################
    $result = (Test-OpenWeather-API)
    if ($result -eq $true) {
        Write-Host "OpenWeather-API " -NoNewline ; Write-Host -ForegroundColor Green "Success"
    }
    elseif ($result -eq $false) {
        Write-Host "OpenWeather-API " -NoNewline ; Write-Host -ForegroundColor Red "Failed"
    }
    ########################################################
    while ($val -ne 3 -and $done -ne 1) {
        $val++
        $result = (Test-Strava-ValidToken)
        if ($result -eq $true) {
            Write-Host "Strava-ValidToken " -NoNewline ; Write-Host -ForegroundColor Green "Success"
            $done = 1
        }
        elseif ($result -eq $false) {
            Write-Host "Strava-ValidToken " -NoNewline ; Write-Host -ForegroundColor Red "Failed"
            Write-Host "Strava-ValidToken - Attempting to renew token" -ForegroundColor Blue
            try {
                . "./Get-Strava-ValidToken.ps1"
                Write-Host "Strava-ValidToken - re-checking" -ForegroundColor Blue
            }
            catch {
                Write-Host "Strava-ValidToken " -NoNewline ; Write-Host -ForegroundColor Red "FAILED TO RENEW TOKEN"
                $done = 1
            }
        }
    }
    ########################################################
    $result = (Test-Strava-API)
    if ($result -eq $true) {        
        Write-Host "Strava-API " -NoNewline ; Write-Host -ForegroundColor Green "Success"
    }
    elseif ($result -eq $false) {
        Write-Host "Strava-API " -NoNewline ; Write-Host -ForegroundColor Red "Failed"
        
    }
    ########################################################
    Write-Host ""
} Test-AllThings