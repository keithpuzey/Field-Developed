Clear-Host
#
# Define Environment Variables
#
$ComputerName=$env:COMPUTERNAME
$IEAdminRegistryKey="HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$IEUserRegistryKey ="HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}”

[string[]]$authurls = ( 
    "https://bard.blazemeter.com",
    "https://auth.blazemeter.com",
    "https://storage.blazemeter.com"
)

[string[]]$urls = ( 
    "https://a.blazemeter.com",
    "https://gcr.io/verdant-bulwark-278",
    "https://mock.blazemeter.com",
    "https://data.blazemeter.com"
)


write-host "`n Blazemeter OPL pre-requisite script" -ForegroundColor White -BackgroundColor Black

write-host "`n Operating System Validation " -ForegroundColor White -BackgroundColor Black

# Get OS Version / Name

$os = (get-ciminstance Win32_OperatingSystem).caption

if ($os -like "Microsoft Windows Server 2012*" -or $os -like "Microsoft Windows Server 2016*" -or $os -like "Microsoft Windows 10*") {
Write-Host "`n $os is Supported "   -ForegroundColor Black -BackgroundColor Green  }
else
{ 
Write-Host "`n $os is not Supported"   -ForegroundColor Black -BackgroundColor Red
}

# This will return the display resolution settings.
$DisplayRes = Get-DisplayResolution
# Compare display resolution with default native windows values and show a warning if the display resolution does not match,  Video recording does not work when the RDP session is not using native windows display settings

if ($DisplayRes -eq "800x600" -or $DisplayRes -eq "1024x768" -or $DisplayRes -eq  "1152x864" -or $DisplayRes -eq  "1280x600" -or $DisplayRes -eq  "1280x720" -or $DisplayRes -eq  "1280x768" -or $DisplayRes -eq  "1280x800" -or $DisplayRes -eq  "1280x960" -or $DisplayRes -eq  "1280x1024" -or $DisplayRes -eq  "1360x768"  -or $DisplayRes -eq  "1366x768" -or $DisplayRes -eq  "1400x1050" -or $DisplayRes -eq  "1440x900" -or $DisplayRes -eq  "1536x864" -or $DisplayRes -eq  "1600x900" -or $DisplayRes -eq  "1680x1050" -or $DisplayRes -eq  "1920x1080" -or $DisplayRes -eq  "1920x1200"  -or $DisplayRes -eq  "1600x1200" -or $DisplayRes -eq  "2048x1152"  -or $DisplayRes -eq  "2560x1080"  -or $DisplayRes -eq  "2560x1440"  -or $DisplayRes -eq  "3440x1440"  -or $DisplayRes -eq  "3840x2160")

{
write-host "`n Display Resolution OK `n" -ForegroundColor Black -BackgroundColor Green
}

else {
write-host "`n Check Display Resolution `n" ` -ForegroundColor Black -BackgroundColor Yellow
}

write-host "`n Browser Validation " -ForegroundColor White -BackgroundColor Black

# Check If Chrome is installed

$WantFile = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
$FileExists = Test-Path $WantFile
If ($FileExists -eq $True) {
          Write-Host "`nChrome is installed"  -ForegroundColor Black -BackgroundColor Green }
Else {Write-Host "`n Chrome not installed" -ForegroundColor Black -BackgroundColor Red
}

# Check If Firefox is installed
$WantFile = "C:\Program Files\Mozilla Firefox\firefox.exe"
$FileExists = Test-Path $WantFile
If ($FileExists -eq $True) {
      Write-Host "`n FireFox Installed"   -ForegroundColor Black -BackgroundColor Green
    }
Else {Write-Host "`n FireFox is not installed"  -ForegroundColor Black -BackgroundColor Red
}

write-host "`n Internet Explorer Settings " -ForegroundColor White -BackgroundColor Black

$IEZoom = (Get-ItemProperty -path 'HKCU:\Software\Microsoft\Internet Explorer\Zoom').ZoomFactor

# This will return the IE Zoom Value and show a warnign if the zoom value is not set to 100%

if ($IEZoom -eq "80000" )

{
write-host "`n Internet Explorer Zoom Factor set to 100%`n" -ForegroundColor Black -BackgroundColor Green
}

else {
write-host "`n Internet Explorer Zoom Factor not set to 100% `n" ` -ForegroundColor Black -BackgroundColor Red
}

# Check if IE Enhanced Security is disabled

if ((Test-Path -Path $IEAdminRegistryKey) -or (Test-Path -Path $IEUserRegistryKey)) {
    $IEAdminRegistryValue=(Get-ItemProperty -Path $IEAdminRegistryKey -Name IsInstalled).IsInstalled
    if ($IEAdminRegistryKey -ne "" ) {
        if ($IEAdminRegistryValue -eq 0 ) {
            Write-Host "`nInternet Explorer Enhanced Security for Admin is Disabled" -ForegroundColor Black -BackgroundColor Green
         } else { 
            Write-Host "`nInternet Explorer Enhanced Security for Admin is Disabled" -ForegroundColor Black -BackgroundColor Red
                        
        }
    $IEUserRegistryValue=(Get-ItemProperty -Path $IEUserRegistryKey -Name IsInstalled).IsInstalled
    if ($IEUserRegistryKey -ne "" ) {
        if ($IEUserRegistryValue -eq 0 ) {
            Write-Host "`nInternet Explorer Enhanced Security for User is Disabled"  -ForegroundColor Black -BackgroundColor Green
        } else { 
            Write-Host  "`nInternet Explorer Enhanced Security for User  is Disabled" -ForegroundColor Black -BackgroundColor Red
                    }
    }
    }
} else {
Write-Host "`nRegistry Key Not Found!" -ForegroundColor Black -BackgroundColor Green
}

# Check IE Zone protected modes are enabled
	
function changeIeProtectedMode{
    # $hives = 0..4|%{"HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\$_"}
    $hives = 0..4|%{"HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\$_"}
    $keyName='2500' # Key Name '2500' corresponds to 'Protected Mode' in IE
    $keys=$hives|%{Get-ItemProperty -Path $_}|select DisplayName, `
                                                    @{name='status';e={
                                                                    if($_.$keyName -eq 0){'enabled'}
                                                                    elseif($_.$keyName -eq 3){'disabled'}
                                                                    else{'n/a'}                                                                                        
                                                                    }}
    if ($keys.status -contains 'disabled')
		{ write-host "IE Zones Protected mode not enabled on all zones " -ForegroundColor Black -BackgroundColor Red 
        write-host "`n$($keys|out-string)" # Key codes 0: Enabled, 3: Disabled 
	}
	
#  Uncomment to enable functionality to update all IE Zones protected mode flag.
    #DisplayName      value
    #-----------      -----
    #Computer         n/a
    #Local intranet   enabled
    #Trusted sites    enabled
    #Internet         enabled
    #Restricted sites enabled
    
	# $userResponse = Read-Host 'Enable IE Protected Mode? (yes/no)'
    # $intent=switch ($userResponse){
    #     'no'{3;break}
    #     'yes'{0;break}
    #      default{-1}
    #    }
 
    #Skipping zone 0 as that is the local machine zone
    # if($intent -gt -1){
    #     $hives[1..4]|%{Set-ItemProperty -Path $_ -Name $keyName -Value $intent}
    #     $keys=$hives|%{Get-ItemProperty -Path $_}|select DisplayName, `
    #                                                     @{name='status';e={
    #                                                                     if($_.$keyName -eq 0){'enabled'}
    #                                                                     elseif($_.$keyName -eq 3){'disabled'}
    #                                                                     else{'n/a'}                                                                                        
    #                                                                     }}
    #     write-host "New Values are:`r`n$($keys.status|out-string)"   
    #     }
    # else{write-host 'No changes have been made'}
    
 
    else { write-host "IE Zones Protected mode configured correctly" -ForegroundColor Black -BackgroundColor Green  }}
	
changeIeProtectedMode


write-host "`n Required Applications " -ForegroundColor White -BackgroundColor Black

# Check if Python is installed

$registryExists = Test-Path HKLM:\Software\Wow6432Node\python

if ($registryExists -eq $True ) {

	$python = & python -V 2>&1
    Write-Host "$python is installed"  -ForegroundColor Black -BackgroundColor Green
    $pipbzt = & python -m pip freeze

# Check blazemeter python packages are installed 
    if($pipbzt -eq $null){
    Write-Host " Python Blazemeter Packages not installed" -ForegroundColor Black -BackgroundColor Red
           
    }
    Else {
    $botocoreversion = & python -m pip show botocore | findstr Version 2>&1

	$boto3version = & python -m pip show boto3 | findstr Version 2>&1 

	$bzmcommon = & python -m pip show bzm-common-library | findstr Version 2>&1 

    if($botocoreversion -like "WARNING"){
    Write-Host "boto core not installed" -ForegroundColor Black -BackgroundColor Red
           
    }
    Else {Write-Host "Boto Core  $botocoreversion installed " -ForegroundColor Black -BackgroundColor Green }

    if($boto3version -like "WARNING"){
    Write-Host "boto3 not installed" -ForegroundColor Black -BackgroundColor Red
           
    }
    Else {Write-Host "Boto3 $boto3version installed" -ForegroundColor Black -BackgroundColor Green }
    if($bzmcommon -like "WARNING"){
    Write-Host "bzmcommon not installed" -ForegroundColor Black -BackgroundColor Red
           
    }
    Else {Write-Host "bzmcommon $bzmcommon installed" -ForegroundColor Black -BackgroundColor Green }
    }
    }
 Else {Write-Host "Python is not installed"  -ForegroundColor Black -BackgroundColor Red}

    $MSVSC = Get-WmiObject -Class Win32_Product | sort-object Name | Where-Object { $_.name -like "*Microsoft Visual C++ *Additional Runtime*"}
    if($MSVSC -eq $null){
    Write-Host " Microsoft Visual C++ Additional Runtime is not installed" -ForegroundColor Black -BackgroundColor Red
           
    }
    Else {Write-Host " Microsoft Visual C++ Additional Runtime is installed" -ForegroundColor Black -BackgroundColor Green }


write-host "`n Network Connectivity " -ForegroundColor White -BackgroundColor Black

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Check connectivity to the Blazemeter platform

foreach($url in $urls)

{

try  { 

    $Response = Invoke-WebRequest -Uri $url -ErrorAction Stop
    # This will only execute if the Invoke-WebRequest is successful.
    $StatusCode = $Response.StatusCode
    

    if ($StatusCode -eq "200") {
write-host "$url is up (Return code: $StatusCode ) $line " -ForegroundColor green 
}

else {
write-host "$url is down `n" ` -ForegroundColor red
}


}


catch
{
    $StatusCode = $_.Exception.Response.StatusCode.value__
    write-host "`n $url is down `n" ` -ForegroundColor red
}

}


foreach($authurl in $authurls)

{
   try {

      $checkConnection = Invoke-WebRequest -Uri $authurl
      Write-Host $checkConnection
      if ($checkConnection.StatusCode -eq 200) {
         Write-Host "$authurl  Connection Verified!" -ForegroundColor Green

      }
      else {
      write-host "$authurl  Connection Failed`n" ` -ForegroundColor red
     } 
   }

   catch [System.Net.WebException] {
      $exceptionMessage = $Error[0].Exception
      if ($exceptionMessage -match "503") {
         Write-Host "$authurl  Server Unavaiable" -ForegroundColor Red
      }
      elseif ($exceptionMessage -match "404") {
         Write-Host "$authurl  Error 404" -ForegroundColor Red
      }
      elseif ($exceptionMessage -match "401") {
         write-host "$authurl is up (Return code: 401 ) $line " -ForegroundColor green 
               }
      elseif ($exceptionMessage -match "400") {
      write-host "$authurl is up (Return code: 400 ) $line " -ForegroundColor green 
      }
      
   }
}
