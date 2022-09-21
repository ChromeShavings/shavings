@ECHO OFF
REM This batch file is used to securely launch the LocateIPAddress.ps1 PowerShell script. 

echo "NOTE: The batch file, Run_LocateIPAddress.bat, must reside within the same directory as the PowerShell script for it to run properly"

echo "Example of how to call these functions/parameters in the script: IPAddress-Lookup -IPAddress 1.1.1.1 -OutputtoJson C:\FolderOfYourChoosing\output.json

Powershell.exe -NoExit -NoLogo -executionpolicy remotesigned -File .\LocateIPAddress.ps1