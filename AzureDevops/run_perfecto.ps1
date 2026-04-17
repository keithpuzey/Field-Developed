param([string]$CsvPath)

# 1. Configuration
$cloudName = "demo" 
$perfectoKey = $env:PERFECTO_TOKEN 
$resultDir = "test-results"
if (!(Test-Path $resultDir)) { New-Item -ItemType Directory -Path $resultDir -Force | Out-Null }

$testList = Import-Csv -Path $CsvPath
$headers = @{ "Perfecto-Authorization" = $perfectoKey; "Content-Type" = "application/json" }

foreach ($test in $testList) {
    $testStartTime = Get-Date
    $scriptKey = $test.testKey
    $deviceId = $test.platformName 
    $customJobName = $test.jobName
    
    $maxRetries = 2
    $retryCount = 0
    $testFinalized = $false

    while ($retryCount -le $maxRetries -and -not $testFinalized) {
        Write-Host "--- Attempt $($retryCount + 1): Starting $customJobName on $deviceId ---"

        # 2. Setup Body
        $bodyObject = @{
            testKey = $scriptKey
            params  = @{
                jobName = $customJobName
                DUT     = @{ deviceName = $deviceId }
            }
        }
        $jsonBody = $bodyObject | ConvertTo-Json -Depth 10

        # 3. Start Execution
        try {
            $startUrl = "https://$($cloudName).perfectomobile.com/scriptless/api/executions"
            $response = Invoke-RestMethod -Uri $startUrl -Method POST -Headers $headers -Body $jsonBody
            $exeId = $response.executionId
            $reportUrl = $response.testGridReportUrl
        } catch {
            Write-Host "   ❌ Immediate API Failure: $($_.Exception.Message)"
            break # Exit retry loop if the API itself is down
        }

        # 4. Monitoring Loop
        $status = "Initializing"
        $endCode = ""
        $description = ""

        while ($status -ne "Completed" -and $status -ne "Failed" -and $status -ne "Stopped") {
            Start-Sleep -Seconds 20
            try {
                $statusUrl = "https://$($cloudName).perfectomobile.com/scriptless/api/executions/$($exeId)"
                $statusRes = Invoke-RestMethod -Uri $statusUrl -Method Get -Headers $headers
                $status = $statusRes.status
                $endCode = $statusRes.endCode
                $description = $statusRes.description
                Write-Host "   Status: $status | Result: $endCode"
            } catch {
                Write-Host "   Waiting for status update..."
            }
        }

        # CHECK FOR "DEVICE IN USE" IN THE DESCRIPTION
        if ($description -like "*device is in use*") {
            if ($retryCount -lt $maxRetries) {
                Write-Host "   ⚠️ Device Busy detected. Retrying in 60 seconds..."
                Start-Sleep -Seconds 60
                $retryCount++
            } else {
                Write-Host "   ❌ Device Busy. Max retries reached."
                $testFinalized = $true
            }
        } else {
            # Test finished normally (Success or real failure)
            $testFinalized = $true
        }
    }

    # 5. Generate JUnit XML (for the LAST attempt made)
    $testEndTime = Get-Date
    $durationSeconds = [math]::Round(($testEndTime - $testStartTime).TotalSeconds, 3)
    $xmlFile = "$PWD/$resultDir/$exeId-result.xml"
    $failures = if ($endCode -eq "SUCCESS" -or $endCode -eq "Passed") { "0" } else { "1" }
    
    $safeJobName = [System.Security.SecurityElement]::Escape($customJobName)
    $safeReportUrl = [System.Security.SecurityElement]::Escape($reportUrl)
    $safeDesc = [System.Security.SecurityElement]::Escape($description)

    $xmlContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="PerfectoBatch" tests="1" failures="$failures" time="$durationSeconds">
    <testcase classname="PerfectoScriptless" name="$safeJobName" time="$durationSeconds">
        $(if ($failures -eq "1") { 
            "<failure message='$safeDesc'>Report: $safeReportUrl</failure>" 
        } else {
            "<system-out>Passed. Report: $safeReportUrl</system-out>"
        })
    </testcase>
</testsuite>
"@
    $xmlContent | Out-File -FilePath $xmlFile -Encoding utf8 -Force
    Write-Host "--- Finished: $customJobName ---`n"
}