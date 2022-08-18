$blade = $(hostname)
$beforeDrain = Get-Content c:\ansible\BeforeDrain_log.txt

# Fucntion
function GetTotalVms {
    Get-ClusterResource | where {($_.ResourceType) -like "Virtual Machine"} | where {($_.OwnerNode) -like $blade} |Select OwnerGroup, OwnerNode, State | Sort-Object OwnerNode -Descending
}

Resume-clusternode -Name "$blade" -Failback Immediate
$vmStatus = $(Get-ClusterResource).state
while ($vmStatus -contains "OfflinePending") {
    Write-Host "Live migration in progress" -ForegroundColor Magenta
    Sleep 10
    $vmStatus = $(Get-ClusterResource).state
}

Write-Host "Fail back to $blade is DONE!" -ForegroundColor Green

GetTotalVms | Out-File c:\ansible\AfterDrain_log.txt
$afterDrain = Get-Content c:\ansible\AfterDrain_log.txt

if ($beforeDrain.Count -eq $afterDrain.Count) {
    Out-File c:\ansible\Failback_Success_Log.txt
} else {
    Out-File c:\ansible\Failback_Error_Log.txt
}