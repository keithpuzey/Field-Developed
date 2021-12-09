Clear-Host
#
# Define Environment Variables
#
$ComputerName=$env:COMPUTERNAME
$IEAdminRegistryKey="HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$IEUserRegistryKey ="HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
$zoomfactorpath = "HKCU:\Software\Microsoft\Internet Explorer\Zoom\"
$zoomfactorkey = "ZoomFactor"
$zoomfactorvalue = "80000"
$ChromeExe = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
$FirefoxExe = "C:\Program Files\Mozilla Firefox\firefox.exe"
$PythonExists = Test-Path HKLM:\Software\Wow6432Node\python

[string[]]$authurls = ( 
    "https://bard.blazemeter.com",
    "https://auth.blazemeter.com",
    "https://storage.blazemeter.com",
    "https://storage.googleapis.com"
)

[string[]]$urls = ( 
    "https://a.blazemeter.com",
    "https://gcr.io/verdant-bulwark-278",
    "https://mock.blazemeter.com",
    "https://data.blazemeter.com"
)

write-host "`n Blazemeter Performance  Windows OPL pre-requisite script" -ForegroundColor White -BackgroundColor Black  

write-host "`n Operating System Validation " -ForegroundColor White -BackgroundColor Black  

# Get OS Version / Name

$os = (get-ciminstance Win32_OperatingSystem).caption

if ($os -like "Microsoft Windows Server 2012*" -or $os -like "Microsoft Windows Server 2016*" -or $os -like "Microsoft Windows 10*") {
Write-Host "`n $os is Supported "   -ForegroundColor Black -BackgroundColor Green  }
else
{ 
Write-Host "`n $os is not Supported"   -ForegroundColor Black -BackgroundColor Red
}

$users = (quser) -ireplace '\s{2,}',',' | convertfrom-csv
$sessionname = $users.sessionname

if ($sessionname -eq "console") 
{

        write-host  $User.SESSIONNAME

        Add-Type -AssemblyName System.Windows.Forms
        $Monitor = [System.Windows.Forms.Screen]::PrimaryScreen

	    $DeviceName = (($Monitor.DeviceName).replace("\", "")).replace(".", "")
	    [string]$Width = $Monitor.WorkingArea.Width
	    [string]$Height = $Monitor.WorkingArea.Height
	
        [string]$displayres = $Width+"x"+$Height

        Write-Host "`n Logged in user $env:username is logged in to Console "   -ForegroundColor White -BackgroundColor Black 

    if ($DisplayRes -eq "800x600" -or $DisplayRes -eq "1024x768" -or $DisplayRes -eq  "1152x864" -or $DisplayRes -eq  "1280x600" -or $DisplayRes -eq  "1280x720" -or $DisplayRes -eq  "1280x768" -or $DisplayRes -eq  "1280x800" -or $DisplayRes -eq  "1280x960" -or $DisplayRes -eq  "1280x1024" -or $DisplayRes -eq  "1360x768"  -or $DisplayRes -eq  "1366x768" -or $DisplayRes -eq  "1400x1050" -or $DisplayRes -eq  "1440x900" -or $DisplayRes -eq  "1536x864" -or $DisplayRes -eq  "1600x900" -or $DisplayRes -eq  "1680x1050" -or $DisplayRes -eq  "1920x1080" -or $DisplayRes -eq  "1920x1200"  -or $DisplayRes -eq  "1600x1200" -or $DisplayRes -eq  "2048x1152"  -or $DisplayRes -eq  "2560x1080"  -or $DisplayRes -eq  "2560x1440"  -or $DisplayRes -eq  "3440x1440"  -or $DisplayRes -eq  "3840x2160")

         { write-host "`n Display Resolution $DisplayRes OK `n" -ForegroundColor Black -BackgroundColor Green }
    
    else { write-host "`n Display Resolution $DisplayRes ?? `n" -ForegroundColor Black -BackgroundColor Red  }
    }


if ($sessionname -ne "console") 


write-host "`nRequired Applications " -ForegroundColor White -BackgroundColor Black

if ($PythonExists -eq $True ) {

	$python = & python -V 2>&1
    Write-Host "`n$python is installed"  -ForegroundColor Black -BackgroundColor Green
    $pipbzt = & python -m pip freeze | findstr boto3 
    # $pipbzt = & python -m pip list | findstr boto3 

    if($pipbzt -eq $null){
    Write-Host " `nPython Blazemeter Packages not installed" -ForegroundColor Black -BackgroundColor Red
           
    }
    Else {
    $botocoreversion = & python -m pip show botocore | findstr Version 2>&1

	$boto3version = & python -m pip show boto3 | findstr Version 2>&1 

	$bzmcommon = & python -m pip show bzm-common-library | findstr Version 2>&1 

 

    if($botocoreversion -like "WARNING"){
    Write-Host "`nboto core not installed" -ForegroundColor Black -BackgroundColor Red
           
    }
    Else {Write-Host "`nBoto Core  $botocoreversion installed " -ForegroundColor Black -BackgroundColor Green }

    if($boto3version -like "WARNING"){
    Write-Host "`nboto3 not installed" -ForegroundColor Black -BackgroundColor Red
           
    }
    Else {Write-Host "`nBoto3 $boto3version installed" -ForegroundColor Black -BackgroundColor Green }
    if($bzmcommon -like "WARNING"){
    Write-Host "`nbzmcommon not installed" -ForegroundColor Black -BackgroundColor Red
           
    }
    Else {Write-Host "`nbzmcommon $bzmcommon installed" -ForegroundColor Black -BackgroundColor Green }
    }
    }
 Else {Write-Host "`nPython is not installed"  -ForegroundColor Black -BackgroundColor Red}

    $MSVSC = Get-WmiObject -Class Win32_Product | sort-object Name | Where-Object { $_.name -like "*Microsoft Visual C++ *Additional Runtime*"}
    if($MSVSC -eq $null){
    Write-Host "`nMicrosoft Visual C++ Additional Runtime is not installed" -ForegroundColor Black -BackgroundColor Red
           
    }
    Else {Write-Host "`nMicrosoft Visual C++ Additional Runtime is installed" -ForegroundColor Black -BackgroundColor Green }


write-host "`nNetwork Connectivity " -ForegroundColor White -BackgroundColor Black

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


foreach($url in $urls)

{

try  { 

    $Response = Invoke-WebRequest -Uri $url -ErrorAction Stop
    # This will only execute if the Invoke-WebRequest is successful.
    $StatusCode = $Response.StatusCode
    

    if ($StatusCode -eq "200") {
write-host "`n$url is up (Return code: $StatusCode ) $line " -ForegroundColor green 
}

else {
write-host "`n$url is down `n" ` -ForegroundColor red
}


}


catch
{
    $StatusCode = $_.Exception.Response.StatusCode.value__
    write-host "`n$url is down `n" ` -ForegroundColor red
}

}


foreach($authurl in $authurls)

{
   try {

      $checkConnection = Invoke-WebRequest -Uri $authurl
      Write-Host $checkConnection
      if ($checkConnection.StatusCode -eq 200) {
         Write-Host "`n$authurl  Connection Verified!" -ForegroundColor Green

      }
      else {
      write-host "`n$authurl  Connection Failed`n" ` -ForegroundColor red
     } 
   }

   catch [System.Net.WebException] {
      $exceptionMessage = $Error[0].Exception
      if ($exceptionMessage -match "503") {
         Write-Host "`n$authurl  Server Unavaiable" -ForegroundColor Red
      }
      elseif ($exceptionMessage -match "404") {
         Write-Host "`n$authurl  Error 404" -ForegroundColor Red
      }
      elseif ($exceptionMessage -match "401") {
         write-host "`n$authurl is up (Return code: 401 ) $line " -ForegroundColor green 
               }
      elseif ($exceptionMessage -match "400") {
      write-host "`n$authurl is up (Return code: 400 ) $line " -ForegroundColor green 
      }
      
   }
}
pause
