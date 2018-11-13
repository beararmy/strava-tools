$config = Get-Content -Path .\config.json -Raw | ConvertFrom-Json
$ClientID = $config.Strava.ClientID
$ClientSecret = $config.Strava.ClientSecret
$KallbackURI = $config.Strava.KallbackURI
$KallbackGetQry = $config.phpCallback.API_GET_QRY
$KallbackAPIKey = $config.phpCallback.API_KEY
$KallbackURI = $KallbackURI+"?KallbackAPIKey="+$KallbackAPIKey

. './Test-Strava-ValidToken.ps1'
$CurrentlyValidToken = (Test-Strava-ValidToken)
#function Get-Strava-OAuth2 {
if ($CurrentlyValidToken -eq $true) {
    Write-Host "Already have a good token, quitting here."
} else {

#OAUTH2.0 First Leg
$process = Start-Process -FilePath "http://www.strava.com/oauth/authorize?client_id=$ClientID&response_type=code&redirect_uri=$KallbackURI&approval_prompt=auto&scope=write" -PassThru

sleep 10 #we're sleeping to allow strava to talk to php page
# add a thing here to retry in case there's no key or key is older than X

#Get results of Second Leg
try {
    $response=(Invoke-WebRequest -Uri "$KallbackURI`&$KallbackGetQry=yesplease")
    $code=$response.Content
} catch {
    return $False
}

#Third Leg
$response = Invoke-RestMethod -method POST -Uri "https://www.strava.com/oauth/token?client_id=$ClientID&client_secret=$ClientSecret&code=$code&grant_type=authorization_code"
$CurrrentRefreshToken=$response.refresh_token
$CurrentAccessToken=$response.access_token
$CurrentTokenExpiresAt=$response.expires_at
#write-host "Third leg complete, I've got $CurrrentRefreshToken and $CurrentAccessToken as my tokens, expiring at $CurrentTokenExpiresAt"

#refresh
$response = Invoke-RestMethod -method POST -Uri "https://www.strava.com/oauth/token?client_id=$ClientID&client_secret=$ClientSecret&grant_type=refresh_token&refresh_token=$CurrentAccessToken"
$CurrrentRefreshToken=$response.refresh_token
$CurrentAccessToken=$response.access_token
$CurrentTokenExpiresAt=$response.expires_at

#Update Config File
$pathToJson = '.\config.json'
$a = Get-Content $pathToJson | ConvertFrom-Json
$a.Strava.'CurrrentRefreshToken' = $CurrrentRefreshToken
$a.Strava.'CurrentAccessToken' = $CurrentAccessToken
$a.Strava.'CurrentTokenExpiresAt' = $CurrentTokenExpiresAt
$a | ConvertTo-Json | set-content $pathToJson
}