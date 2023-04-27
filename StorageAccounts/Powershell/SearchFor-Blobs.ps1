<#
Searches thru the Storage blob container for a specific term and augmenting wildcard

.EXAMPLE
./SearchBlob.ps1 -storageAccountRG "test-rg" -storageAccountName "rubberduck" -containerName "ducks" -Searchterm "xlsx"
#>

[CmdletBinding()]
    param (
        [string]$Searchterm,
        [string]$containerName,
        [string]$storageAccountRG,
        [string]$storageAccountName
    )


$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $storageAccountRG -AccountName $storageAccountName).Value[0]
$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey


Get-AzStorageBlob -Context $ctx -Container $containerName | Where-Object {$_.Name -like "*$searchterm*"}
