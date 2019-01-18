
#*****************************************************************
#
#   Script Name:  TDMAPIGeneratorExample.ps1
#   Version:  1.0
#   Author:  Keith Puzey 
#   Date:  January 18,  2019
#
#   Description:  Example Powershell script to interact with CA TDM API and initiate a Generator job
#   
#
#*****************************************************************

#  Example -   powershell -file TDMAPIGeneratorExample.ps1 -username administrator -password marmite -url http://10.130.127.71:8080 -ProjectName "Web Store Application" -Version 22 -jsonfile GenBody.json

# Define Parameters
param(
   [string]$username,
   [string]$url,
   [string]$ProjectName,
   [string]$Version,
   [string]$Environment,
   [string]$jsonfile,
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

# Submit Publish Job, Paylod is read from corresponding json file

$headersg = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headersg.Add("Authorization",$token)
$headersg.Add("Content-Type",'application/json')

$GenBody = Get-Content $jsonfile -Raw
 
$Generatorurl="${url}/TDMJobService/api/ca/v1/jobs"
try {
 Invoke-RestMethod -Method 'Post' -Uri $Generatorurl -Headers $headersg -Body $GenBody
}
catch [System.Net.WebException] { 
   Write-Verbose "An exception was caught: $($_.Exception.Message)"
   $_.Exception.Response 
} 
 
 
