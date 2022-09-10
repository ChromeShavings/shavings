function IPAddress-Lookup{

Param
(

   [Parameter(Mandatory=$true, position=0)]
         [string] $IPAddress,

   [Parameter(Mandatory=$false, position=1)]
         [string] $OutputtoJson

)

$JsonFile = $Null
$ipv6Pattern = '(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))'
$ipv4Pattern = '^([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(?<!172\.(16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31))(?<!127)(?<!^10)(?<!^0)\.([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(?<!192\.168)(?<!172\.(16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31))\.([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(?<!\.0$)(?<!\.255$)$'

if ($IPAddress -notmatch $ipv4Pattern -and $IPAddress -notmatch $ipv6Pattern)
    {
    Write-Error -Message "IP Address entered is a non-routable address. Please enter in a routable IP address"
    }

else {
Write-Host "Looking up IP Address now. Please wait." -ForegroundColor Green
$Traceroute = Test-NetConnection -TraceRoute $($IPAddress) -InformationLevel Detailed
#$Traceroute


$PingDestination = Test-Connection $IPAddress -Count 10
$Geolocation_Info = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$IPAddress" | Select *
$Timezone = (Invoke-WebRequest "http://worldtimeapi.org/api/$($Geolocation_Info.timezone)")
$TimezoneAbbreviation = ((Invoke-WebRequest "http://worldtimeapi.org/api/$($Geolocation_Info.timezone)") | ConvertFrom-Json).abbreviation
$DateTime =  ($Timezone | ConvertFrom-Json).datetime.Substring(0,16)
$GeoWeather = (((Invoke-WebRequest -Method Get "https://api.weather.gov/points/$($Geolocation_Info.lat),$($Geolocation_Info.lon)"))| ConvertFrom-Json).properties.forecast
$WeatherToday = (Invoke-WebRequest -Method Get $GeoWeather | ConvertFrom-Json).properties.periods[0]

$Country = $Geolocation_Info.country
$City = $Geolocation_Info.city
$State = $Geolocation_Info.regionName
$Zipcode = $Geolocation_Info.zip
$Timezone = $Geolocation_Info.timezone
$CurrentTemperature = $WeatherToday.temperature
$CurrentForecast = $WeatherToday.shortForecast
$TemperatureUnit = $WeatherToday.temperatureUnit
$Windspeed = $WeatherToday.windSpeed
$WindDirection = $WeatherToday.windDirection
$ISP = $Geolocation_Info.isp
$ASOwner = $Geolocation_Info.as
$BlockOwner = $Geolocation_Info.org
$TotalHops = $($Traceroute.TraceRoute.Count)
$AverageLatency = $($PingDestination| Measure-Object -Property ResponseTime -Average | Select -ExpandProperty Average)

Write-Host "Below is the Lookup Information for your IP Address: $IPAddress" -ForegroundColor Cyan
Write-Host "$TotalHops hop(s)" -ForegroundColor Green
Write-Host "The average latency is $AverageLatency" -ForegroundColor Green
Write-Host "$City is the city" -ForegroundColor Green
Write-Host "$State is the state/region" -ForegroundColor Green
Write-Host "$Country is the country" -ForegroundColor Green
Write-Host "$Timezone is the Time Zone" -ForegroundColor Green
Write-Host "$DateTime $TimezoneAbbreviation is the Date/Time" -ForegroundColor Green
Write-Host "The temperature is $CurrentTemperature$TemperatureUnit, and $CurrentForecast" -ForegroundColor Yellow
Write-Host "Wind Speeds traveling $WindDirection at $Windspeed" -ForegroundColor Yellow
Write-Host "$ISP is the ISP" -ForegroundColor Green
Write-Host "$ASOwner owns the AS Number" -ForegroundColor Green
Write-Host "$BlockOwner is the IP Block Owner" -ForegroundColor Green

if ($OutputtoJson)
{
Write-Host "Appending data to Json File and Exporting to desired location" -ForegroundColor Cyan
$JsonFile = ($IPAddress, $TotalHops, $AverageLatency, $City, $State, $Country, $Timezone, $TimezoneAbbreviation, $DateTime, $CurrentTemperature, $TemperatureUnit, $Windspeed, $WindDirection, $ISP, $ASOwner, $BlockOwner) | ConvertTo-Json | Out-File -FilePath $OutputtoJson -Force -Verbose
}

}

}