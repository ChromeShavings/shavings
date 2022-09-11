function IPAddress-Lookup{

Param
(

   [Parameter(Mandatory=$true, position=0)]
         [string] $IPAddress,

   [Parameter(Mandatory=$false, position=1)]
         [validatescript({ 
         if (($_ | Test-Path)) {return $true} {throw "File path does not exist. Please include a proper file path to continue." }
         if ($_ -notmatch "\.json$") { throw "The extension is not in .json format. Please include the specified filename with the .json extension." }
         return $true})]
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


    Write-Host "Looking up $IPAddress now. Please wait..." -ForegroundColor Green

    $Traceroute = Test-NetConnection -TraceRoute $($IPAddress) -InformationLevel Detailed
    if (!(Test-Connection $IPAddress -Count 1 -Quiet)) {$PingDestination = "N/A"} else {$PingDestination = (Test-Connection $IPAddress -Count 10)}


    try {#Geolocation Info
    $Geolocation_Info = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$IPAddress" | Select *
    $Timezone = (Invoke-WebRequest "http://worldtimeapi.org/api/$($Geolocation_Info.timezone)")
    $TimezoneAbbreviation = ((Invoke-WebRequest "http://worldtimeapi.org/api/$($Geolocation_Info.timezone)") | ConvertFrom-Json).abbreviation
    $DateTime =  ($Timezone | ConvertFrom-Json).datetime.Substring(0,16)
    $Longitude = $Geolocation_Info.lon
    $Latitude = $Geolocation_Info.lat
    $Country = $Geolocation_Info.country
    $City = $Geolocation_Info.city
    $State = $Geolocation_Info.regionName
    $Zipcode = $Geolocation_Info.zip
    $Timezone = $Geolocation_Info.timezone
    $ISP = $Geolocation_Info.isp
    $ASOwner = $Geolocation_Info.as
    $BlockOwner = $Geolocation_Info.org
    }

    catch {
    $DateTime = 'N/A'
    $Longitude = 'N/A'
    $Latitude = 'N/A'
    $Country = 'N/A'
    $City = 'N/A'
    $State = 'N/A'
    $Zipcode = 'N/A'
    $Timezone = 'N/A'
    $ISP = 'N/A'
    $ASOwner = 'N/A'
    $BlockOwner = 'N/A'
    }

    finally {
    
    
        try {#Geoweather

        $Geoweather = (Invoke-WebRequest -Method Get "https://api.weather.gov/points/$($Latitude),$($Longitude)" -ErrorAction SilentlyContinue | ConvertFrom-Json).properties.forecast
        $WeatherNow = (Invoke-WebRequest -Method Get $GeoWeather | ConvertFrom-Json).properties.periods[0]
        $CurrentTemperature = $WeatherNow.temperature
        $CurrentForecast = $WeatherNow.shortForecast
        $TemperatureUnit = $WeatherNow.temperatureUnit
        $Windspeed = $WeatherNow.windSpeed
        $WindDirection = $WeatherNow.windDirection
        }

        catch {
        Write-Host "Could not obtain weather from location using the weather API."
        Write-Host $_

        $CurrentTemperature = 'N/A'
        $CurrentForecast = 'N/A'
        $TemperatureUnit = 'N/A'
        $Windspeed = 'N/A'
        $WindDirection = 'N/A'
        }


        finally {
    


            if ($($Traceroute.TraceRoute.Count) -ige 30) {$TotalHops = "30/Incomplete"} else {$TotalHops = ($($Traceroute.TraceRoute.Count))}
            if ($PingDestination -like "N/A") {$AverageLatency = "N/A"} else {$AverageLatency = $($PingDestination| Measure-Object -Property ResponseTime -Average | Select -ExpandProperty Average)}

            Write-Host "Below is the Lookup Information for your IP Address: $IPAddress" -ForegroundColor Cyan
            Write-Host "$TotalHops hop(s)" -ForegroundColor Green
            Write-Host "The average latency is $AverageLatency" -ForegroundColor Green
            Write-Host "The latitude of this location is $Latitude" -ForegroundColor Green
            Write-Host "The longitude of this location is $Longitude" -ForegroundColor Green
            Write-Host "$City is the city" -ForegroundColor Green
            Write-Host "$State is the state/region" -ForegroundColor Green
            Write-Host "$Country is the country" -ForegroundColor Green
            Write-Host "$Timezone is the Time Zone" -ForegroundColor Green
            Write-Host "$DateTime $TimezoneAbbreviation is the Date/Time" -ForegroundColor Green
            Write-Host "The temperature is $CurrentTemperature" -ForegroundColor Yellow
            Write-Host "The temperature unit is $TemperatureUnit" -ForegroundColor Yellow
            Write-Host "The current forecast is $CurrentForecast" -ForegroundColor Yellow
            Write-Host "Wind Speeds traveling $WindDirection at $Windspeed" -ForegroundColor Yellow
            Write-Host "$ISP is the ISP" -ForegroundColor Green
            Write-Host "$ASOwner owns the AS Number" -ForegroundColor Green
            Write-Host "$BlockOwner is the IP Block Owner" -ForegroundColor Green

            if ($OutputtoJson)
            {
            Write-Host "Writing data to JSON file..."
            $JsonFile = ($IPAddress, $TotalHops, $AverageLatency, $Latitude, $Longitude, $City, $State, $Country, $Timezone, $TimezoneAbbreviation, $DateTime, $CurrentTemperature, $TemperatureUnit, $Windspeed, $WindDirection, $ISP, $ASOwner, $BlockOwner) | ConvertTo-Json | Out-File -FilePath $OutputtoJson -Force
            }

        }#eof Geoweather finally

    }#eof Geolocation Info finally

}#eof else

}#eof function

      


