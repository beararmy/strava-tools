
#Read and set config options from file
$config = Get-Content -Path .\config.json -Raw | ConvertFrom-Json
$Server = $config.hass.Server
$Port = $config.hass.Port
$API_Key = $config.hass.API_Key
$healthy_API_response = $config.hass.healthy_API_response

function Test-HASS-API {
    try {
        $response = (Invoke-RestMethod -Method GET -Uri "http://$Server`:$Port/api/?api_password=$API_Key")
        $response = $response.message
        if ($response -eq $healthy_API_response) {
            return $true;
        }
    }
    catch {
        return $false
    }
    return
}
#Test-HASS-API