function Test-HASS-API {

    $config = Get-Content -Path .\config.json -Raw | ConvertFrom-Json
    $Server = $config.hass.Server
    $Port = $config.hass.Port
    $API_Key = $config.hass.API_Key

    $healthy_API_response = $config.hass.healthy_API_response

    try {
        $response = (Invoke-RestMethod -Method GET -Uri "http://$Server`:$Port/api/?api_password=$API_Key")
        $response = $response.message
        if ($response -eq $healthy_API_response) {
            Write-Verbose "Returned $response, expected $healthy_API_response"
            return $true
        }
        else {
            Write-Verbose "Returned $response, expected $healthy_API_response"
            return $false
        }
    }
    catch {
        Write-Verbose "Returned $response, expected $healthy_API_response"
        return $false
    }
    return
}
#Test-HASS-API