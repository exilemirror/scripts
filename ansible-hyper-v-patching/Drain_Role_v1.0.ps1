$blade = $(hostname)

# Fucntion
function GetTotalVms {
    Get-ClusterResource | where {($_.ResourceType) -like "Virtual Machine"} | where {($_.OwnerNode) -like $blade} |Select OwnerGroup, OwnerNode, State | Sort-Object OwnerNode -Descending
}

#Delet existing log files
$logPath = "C:\ansible\*"
if (Test-Path $logPath -Include *_log*.txt) 
{
  Remove-Item C:\ansible\*_log.txt*
}

#Get existing VMs before drain
$beforeDrain = GetTotalVms
$beforeDrain | Out-File c:\ansible\BeforeDrain_log.txt


#Drain node and put to pause state
Suspend-ClusterNode -Name "$blade" -Drain
Do {
    Write-Host (get-clusternode –Name "$blade").DrainStatus -ForegroundColor Magenta    
    Sleep 10
} 
until ((get-clusternode –Name "$blade").DrainStatus -ne "InProgress")
If ((get-clusternode –Name "$blade").DrainStatus -eq "Completed")
{
    #Get no. of VMs on blade and log
    $totalVMS = GetTotalVms
    If ($totalVMS.Count -gt 0) {
        GetTotalVms | Out-File C:\ansible\DrainError_log.txt
    } else {
        $totalVMS.Count | Out-File C:\ansible\DrainSuccess_log.txt
    }
}

