function Test-HolidayDayPage {

    $config = Get-Content -Path .\config.json -Raw | ConvertFrom-Json
    $HolidayDayURI = $config.HolidayDay.URI
    
    try {
        $response = Invoke-WebRequest -Uri $HolidayDayURI
        $response = $response.StatusCode
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
#Test-HolidayDayPage