<# 
.Description
    Gets all failed installation of MDE* Extension Azure Arc Machines in the current Azure subscription
.PARAMETER Path
    -Path <string>
        Add your desired path where file will be outputed to
.EXAMPLE
    .\Get-ArcFailedMDE.ps1 -Path C:\temp\ -Verbose
#>
[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Path = ".\"
)
$date = Get-Date -Format "yyyyMMddHHmm"
$vms = Get-AzConnectedMachine #| select-object -First 10
$collection = @()

foreach($vm in $vms)
{
    Write-Verbose -Message "Processing $($vm.name)"
    $vm.id -match "/resourceGroups/(?<con>.*)/providers/" | Out-Null; $rg = $Matches['con']
    $res = Get-AzConnectedMachineExtension -MachineName $($vm.name) -ResourceGroupName $rg | where{$_.Name -like "MDE.*" -and $_.ProvisioningState -eq "Failed"}
    if(($res)){
        $data = New-Object PSObject
        Write-Verbose -Message "Processing $($vm.name) has $($res.name) as failed extension"
        $data | Add-Member -MemberType NoteProperty -Name "ArcName" -Value $($vm.name)
        $data | Add-Member -MemberType NoteProperty -Name "OSFamily" -Value $($vm.OSName)
        $data | Add-Member -MemberType NoteProperty -Name "OSName" -Value $($vm.OSSku)
        $data | Add-Member -MemberType NoteProperty -Name "ExtensionName" -Value $($res.Name)
        $data | Add-Member -MemberType NoteProperty -Name "StatusMessage" -Value $($res.statusMessage)
        $data | Add-Member -MemberType NoteProperty -Name "Id" -Value $($res.id)
        $collection += $data
   }
}


If((Get-InstalledModule -Name ImportExcel)) {
    Write-Verbose -Message "Exporting result to excelfile"
    $collection | Export-Excel -Path "$path\mdedata-$date.xlsx"
}
else {
    Write-Verbose -Message "Exporting result to CSV file, if excel native format is desired, run Install-Module -Name ImportExcel"
    $collection | Export-Csv -Path "$path\mdedata-$date.csv"
}