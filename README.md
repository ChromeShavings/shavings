# shavings

<h1>IPAddress-Lookup</h1>

<b>NOTE:</b> Please read this before running the script!

<h2>Prerequisties</h2>

1) Run Powershell/Powershell ISE as Administrator

2) Run the following - ```Set-ExecutionPolicy -Bypass```

3) Windows will prompt if you want to run this for all users. Please select which is appropriate for your environment.

4) Run the above script

<h2>Running the script</h2>

1) Run the script as usual

2) The function will be added to your PowerShell library. Example of use: ```IPAddress-Lookup -IPAddress "1.1.1.1"```

3) An optional "OutputtoJson" parameter can also be included when running the script. Example of use: ```IPAddress-Lookup -IPAddress "1.1.1.1" -OutputtoJson "C:\Windows\Temp\JsonFile.json"```

<h2>The output from the script</h2>

The script will output the following:
- IP Address
- Total Number of Hops from the client machine (machine you are on) and the desination IP
- The average latency (in ms)
- The latitude of where the IP is hosted
- The longitude of where the IP is hosted
- The city of where the IP is hosted
- The state/region of where the IP is hosted
- The country of where the IP is hosted
- The timezone (in 24 hr format) of the hosted IP
- The temperature in Fahrenheit (if API info is available) of the location
- The high for the day in Fahrenheit
- The low for the day in Fahrenheit
- The current forecast (if API info is available) of the location
- The direction (in degrees) and speed (in mph) of the wind at the location (if API info is available)
- The ISP of this IP
- The owner of the AS Number
- The owner of the IP Block

<h2>API's Used</h2>

- http://ip-api.com/json (Free API used for geo-location information)

- http://worldtimeapi.org/api (Free API used for time/timezone information)

- https://api.openweathermap.org/data/2.5/weather? (Free API w/signup used for obtaining weather information) -- allows for 60 requests/min & 1 million gets/mo.

<h2>Screenshot Output Examples</h2>
Obtaining information from 8.8.8.8

- Using ```-IPAddress``` only - (https://user-images.githubusercontent.com/113253306/189553663-785529ce-6393-4273-94a7-a35e853aeeb6.png)
- Using ```-IPaddress``` and ```-OutputtoJson``` - (https://user-images.githubusercontent.com/113253306/189553616-5dd30ab0-14d1-407f-8616-5e80803020ea.png)


Weather API is unable to get information based on Longitude and Latitude

- Example 1 - 1.1.1.1 - (https://user-images.githubusercontent.com/113253306/189553579-4500fdcf-7198-42b8-8365-b13c374875ba.png)
- Example 2 - 1.0.0.1 - (https://user-images.githubusercontent.com/113253306/189553246-4b1a6c01-b2e9-4c20-8359-1ae4226ea4e7.png)

Unable to Traceroute or Ping to obtain Latency and/or Approximate Hop Count (Disabled by IP owner)

- Example 1 - (https://user-images.githubusercontent.com/113253306/189553494-f8eb2bf1-4a66-4724-95e9-abc317d749af.png)

Example of JSON output

- Example 1 - (https://user-images.githubusercontent.com/113253306/189572140-08b32010-2b21-4477-babc-b15293f9eddc.png)

