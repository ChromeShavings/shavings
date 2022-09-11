# shavings

<h1> IPAddress-Lookup Script </h1>

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
- The city of where the IP is hosted
- The state/region of where the IP is hosted
- The country of where the IP is hosted
- The timezone (in 24 hr format) of the hosted IP
- The temperature (if API info is available) of the location
- The temperature unit (F/C - if API info is available) of the location
- The current forecast (if API info is available) of the location
- The direction and speed of the wind at the location (if API info is available)
- The ISP of this IP
- The owner of the AS Number
- The owner of the IP Block
