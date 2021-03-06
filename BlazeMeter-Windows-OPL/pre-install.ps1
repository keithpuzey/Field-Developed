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
{
 

    $DisplayRes = Get-DisplayResolution
    # This will return the display resolution settings.
    Write-Host "`n Logged in user $env:username is logged in to RDP Session"   -ForegroundColor White -BackgroundColor Black

    if ($DisplayRes -eq "800x600" -or $DisplayRes -eq "1024x768" -or $DisplayRes -eq  "1152x864" -or $DisplayRes -eq  "1280x600" -or $DisplayRes -eq  "1280x720" -or $DisplayRes -eq  "1280x768" -or $DisplayRes -eq  "1280x800" -or $DisplayRes -eq  "1280x960" -or $DisplayRes -eq  "1280x1024" -or $DisplayRes -eq  "1360x768"  -or $DisplayRes -eq  "1366x768" -or $DisplayRes -eq  "1400x1050" -or $DisplayRes -eq  "1440x900" -or $DisplayRes -eq  "1536x864" -or $DisplayRes -eq  "1600x900" -or $DisplayRes -eq  "1680x1050" -or $DisplayRes -eq  "1920x1080" -or $DisplayRes -eq  "1920x1200"  -or $DisplayRes -eq  "1600x1200" -or $DisplayRes -eq  "2048x1152"  -or $DisplayRes -eq  "2560x1080"  -or $DisplayRes -eq  "2560x1440"  -or $DisplayRes -eq  "3440x1440"  -or $DisplayRes -eq  "3840x2160")

         { write-host "`n Display Resolution $DisplayRes OK `n" -ForegroundColor Black -BackgroundColor Green }
    else { write-host "`n Check Display Resolution $DisplayRes `n" ` -ForegroundColor Black -BackgroundColor Yellow }

}




write-host "`n Browser Validation " -ForegroundColor White -BackgroundColor Black

# Check If Chrome is installed
$FileExists = Test-Path $ChromeExe
If ($FileExists -eq $True) {
          Write-Host "`nChrome is installed"  -ForegroundColor Black -BackgroundColor Green }

Else {Write-Host "`n Chrome not installed" -ForegroundColor Black -BackgroundColor Red
}

# Check If Firefox is installed
$FileExists = Test-Path $FirefoxExe
If ($FileExists -eq $True) {
      Write-Host "`n FireFox Installed"   -ForegroundColor Black -BackgroundColor Green
    }
Else {Write-Host "`n FireFox is not installed"  -ForegroundColor Black -BackgroundColor Red
}

write-host "`n Internet Explorer Settings " -ForegroundColor White -BackgroundColor Black

# This will return the IE Zoom Value.

if ((Get-ItemProperty $zoomfactorpath -Name $zoomfactorkey -EA 0).$zoomfactorkey -ne $null) 
{
    $iezoomfactor = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Internet Explorer\Zoom").ZoomFactor
    if ( $iezoomfactor -eq '80000') 
    {
    write-host "`nInternet Explorer Zoom Factor set to 100%`n" -ForegroundColor Black -BackgroundColor Green 
    }
    else {
        write-host "`nInternet Explorer Zoom Factor not set to 100% `n" ` -ForegroundColor Black -BackgroundColor Red 
    }
} else {
    Set-ItemProperty -Path $zoomfactorpath -Name $zoomfactorkey -Value $zoomfactorvalue
    write-host "`nInternet Explorer Zoom Factor set to 100%`n" -ForegroundColor Black -BackgroundColor Green 
}


if ($os -like "Microsoft Windows 10*") {
Write-Host "`nInternet Explorer Enhanced Security not available on this platform $os"   -ForegroundColor Black -BackgroundColor Green }
else
{ 
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
Write-Host "`n" 
}
}

    # Write-Host "IE Protected Mode Configuration"  -ForegroundColor Black -BackgroundColor Green
	
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
		{ write-host "`nIE Zones Protected mode not enabled on all zones " -ForegroundColor Black -BackgroundColor Red 
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
    
 
    else { write-host "`nIE Zones Protected mode configured correctly" -ForegroundColor Black -BackgroundColor Green  }}
	
changeIeProtectedMode


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
