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
$WeatherAPIKey = '146782f9715ff38f82d32b891dae975e' #Only 60 requests per minute and 1 million calls a month (free) tier
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
    Write-Host "Attempting Gelocation lookup using API site - http://ip-api.com/json" -ForegroundColor Cyan
    $GeolocationInfo = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$IPAddress" | Select *
    $Timezone = (Invoke-WebRequest "http://worldtimeapi.org/api/$($GeolocationInfo.timezone)")
    $TimezoneAbbreviation = ((Invoke-WebRequest "http://worldtimeapi.org/api/$($GeolocationInfo.timezone)") | ConvertFrom-Json).abbreviation
    $DateTime =  ($Timezone | ConvertFrom-Json).datetime.Substring(0,16)
    $Longitude = $GeolocationInfo.lon
    $Latitude = $GeolocationInfo.lat
    $Country = $GeolocationInfo.country
    $City = $GeolocationInfo.city
    $State = $GeolocationInfo.regionName
    $Zipcode = $GeolocationInfo.zip
    $Timezone = $GeolocationInfo.timezone
    $ISP = $GeolocationInfo.isp
    $ASOwner = $GeolocationInfo.as
    $BlockOwner = $GeolocationInfo.org
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
        Write-Host "Attempting Geoweather lookup using API site https://api.openweathermap.org/data/2.5/weather?" -ForegroundColor Cyan
        $Geoweather = (Invoke-WebRequest -Method Get "https://api.openweathermap.org/data/2.5/weather?lat=$($GeolocationInfo.lat)&lon=$($GeolocationInfo.lon)&appid=$($WeatherAPIKey)&units=imperial" | ConvertFrom-Json)
        $CurrentTemperature = $Geoweather.main.temp
        $HighToday = $Geoweather.main.temp_max
        $LowToday = $Geoweather.main.temp_min
        $CurrentForecast = ($Geoweather.weather.main) + '/' + ($Geoweather.weather.description)
        $Windspeed = $Geoweather.wind.speed
        $WindDirection = $Geoweather.wind.deg
        }

        catch {
        Write-Host "Could not obtain weather from location using the weather API."
        Write-Host $_

        $CurrentTemperature = 'N/A'
        $HighToday = 'N/A'
        $LowToday = 'N/A'
        $CurrentForecast = 'N/A'
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
            Write-Host "The current temperature (in Fahrenheit) is $CurrentTemperature" -ForegroundColor Yellow
            Write-Host "The high for today (in Fahrenheit) is $HighToday" -ForegroundColor Yellow
            Write-Host "The low for today (in Fahrenheit) is $LowToday" -ForegroundColor Yellow
            Write-Host "The current forecast is $CurrentForecast" -ForegroundColor Yellow
            Write-Host "Wind Speeds are traveling $WindDirection degrees at $Windspeed mph" -ForegroundColor Yellow
            Write-Host "$ISP is the ISP" -ForegroundColor Green
            Write-Host "$ASOwner owns the AS Number" -ForegroundColor Green
            Write-Host "$BlockOwner is the IP Block Owner" -ForegroundColor Green

            if ($OutputtoJson)
            {
            Write-Host "Writing data to JSON file..."
            $JsonFile = ($IPAddress, $TotalHops, $AverageLatency, $Latitude, $Longitude, $City, $State, $Country, $Timezone, $TimezoneAbbreviation, $DateTime, $CurrentTemperature, $HighToday, $LowToday, $Windspeed, $WindDirection, $ISP, $ASOwner, $BlockOwner) | ConvertTo-Json | Out-File -FilePath $OutputtoJson -Force
            }

        }#eof Geoweather finally

    }#eof Geolocation Info finally

}#eof else

}#eof function