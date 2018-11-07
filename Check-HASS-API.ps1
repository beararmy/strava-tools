
#Read and set config options from file
$config = Get-Content -Path .\config.json -Raw | ConvertFrom-Json
$Server = $config.hass.Server
$Port = $config.hass.Port
$API_Key = $config.hass.API_Key
$healthy_API_response = $config.hass.healthy_API_response

function Check-HASS-API {
    try {
        $response = (Invoke-RestMethod -Method GET -Uri "http://$Server`:$Port/api/?api_password=$API_Key")
    }
    catch {
    }
    finally {
        [bool]($response.PSobject.Properties -match $healthy_API_response)
    }
}
#Check-HASS-API