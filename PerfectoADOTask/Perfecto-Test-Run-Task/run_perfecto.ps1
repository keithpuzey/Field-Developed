param()

$apiToken = "$(apiToken)"
$testId = "$(testId)"

Write-Host "Triggering test $testId..."

# Your existing logic here
# Example:
$response = Invoke-RestMethod -Uri "https://api.example.com/tests/$testId/run" `
    -Headers @{ Authorization = "Bearer $apiToken" }

# Poll for completion
do {
    Start-Sleep -Seconds 10
    $status = Invoke-RestMethod -Uri "https://api.example.com/tests/$testId/status"
    Write-Host "Status: $($status.state)"
} while ($status.state -ne "Completed")

if ($status.result -ne "Passed") {
    Write-Error "Test failed"
    exit 1
}