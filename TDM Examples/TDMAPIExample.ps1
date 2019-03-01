
#*****************************************************************
#
#   Script Name:  TDMAPIExample.ps1
#   Version:  1.0
#   Author:  Keith Puzey 
#   Date:  January 08,  2019
#
#   Description:  Example Powershell script to interact with CA TDM API
#   
#
#*****************************************************************

#  Example -   powershell -file TDMAPIExample.ps1 -username administrator -password marmite -url http://10.130.127.71:8080 -ProjectName "Web Store Application" -Version 22 -Environment QA

# Define Parameters
param(
   [string]$username,
   [string]$url,
   [string]$ProjectName,
   [string]$Version,
   [string]$Environment,
   [string]$password
  )
# URL Definitions - API Documentation - https://docops.ca.com/ca-test-data-manager/4-7/en/reference/rest-api-reference/api-services-reference
# 
 $authurl="${url}/TestDataManager/user/login"
 $projecturl="${url}/TDMProjectService/api/ca/v1/projects"
 $environmenturl="${url}/TDMDataReservationService/api/ca/v1/environments"
 
# Convert username and password (username:password) to Base64
  
 $stringtoencode="${username}:${password}"
 $EncodedText = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$stringtoencode"))
 $Auth="Basic ${EncodedText}"

# Ignore Certificates when using SSL Connection string

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization",$Auth)
$headers.Add("ContentType",'application/json')
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
 [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
 [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
 
# Use Base64 encoded string to generate authorization token

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization",$Auth)
$headers.Add("ContentType",'application/json')
 
 try {
    $response=Invoke-RestMethod -Method 'Post' -Uri $authurl -Headers $headers
}
catch [System.Net.WebException] { 
    Write-Verbose "An exception was caught: $($_.Exception.Message)"
    $_.Exception.Response 
} 

$tokenorig = $response.token
$token="Bearer ${tokenorig}"

# Query TDM for all Projects
 
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization",$token)
$headers.Add("ContentType",'application/json')
 
 try {
    $projectresponse=Invoke-RestMethod -Method 'Get' -Uri $projecturl -Headers $headers
}
catch [System.Net.WebException] { 
    Write-Verbose "An exception was caught: $($_.Exception.Message)"
    $_.Exception.Response 
} 

#  Extract ProjectID for Project name specified on CLI

$projectID=($projectresponse | where {$_.name -eq $ProjectName})
$ProjectID=$projectID.id


# Query TDM to return all versions for the selected project

$versionurl="${url}/TDMProjectService/api/ca/v1/projects/$projectID/versions"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization",$token)
$headers.Add("ContentType",'application/json')
 
 try {
    $versionresponse=Invoke-RestMethod -Method 'Get' -Uri $versionurl -Headers $headers
}
catch [System.Net.WebException] { 
    Write-Verbose "An exception was caught: $($_.Exception.Message)"
    $_.Exception.Response 
} 
#  Extract VersionID for Project / Version name specified on CLI
$versionID=($versionresponse | where {$_.name -eq $Version})
$VersionID=$versionID.id

# Query TDM to return all envitronments for the selected project / version

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization",$token)
$headers.Add("ContentType",'application/json')

$EnvBody = @{"projectId"="$ProjectID";
 "versionId"="$VersionID";
 }
 
 try {
    $environmentresponse=Invoke-RestMethod -Method 'Get' -Uri $environmenturl -Headers $headers -Body $EnvBody
}
catch [System.Net.WebException] { 
    Write-Verbose "An exception was caught: $($_.Exception.Message)"
    $_.Exception.Response 
} 
#  Extract EnvironmentID for Project / Version / Environment name specified on CLI
$environmentid=($environmentresponse.elements | where {$_.name -eq $Environment})
$environmentID=$environmentid.id


$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization",$token)
$headers.Add("ContentType",'application/json')

$EnvBody = @{"projectId"="$ProjectID";
 "versionId"="$VersionID";
}
$environmentdetailurl="${url}/TDMDataReservationService/api/ca/v1/environments/$environmentID" 
 try {
    $environmentdetailresponse=Invoke-RestMethod -Method 'Get' -Uri $environmentdetailurl -Headers $headers -Body $EnvBody
}
catch [System.Net.WebException] { 
    Write-Verbose "An exception was caught: $($_.Exception.Message)"
    $_.Exception.Response 
} 


# Un comment the following section to output responses
# write-host Project Table
# write-output $projectresponse | Sort-Object -Property name| Format-Table 
# write-host Version Table for project ${ProjectName}
# write-output  $versionresponse | Sort-Object -Property name| Format-Table 
# write-host Environment Table ${ProjectName} / Version  $Version
# write-output $environmentresponse.elements | Sort-Object -Property name| Format-Table 

#  Output ID's
"`n"
Write-Host -NoNewline "Project ID for Project name  ${ProjectName} is" $ProjectID
"`n"
Write-Host -NoNewline "Version ID for Version ${Version} is" $VersionID
"`n"
Write-Host -NoNewline "Environment ID for Environment ${Environment} is" $environmentID
"`n"
