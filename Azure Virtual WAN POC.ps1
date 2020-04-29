<#
Written with version 3.8.0 of the Azure PowerShell Module 
available from here https://github.com/Azure/azure-powershell/releases/tag/v3.8.0-April2020
Install-Module -Name Az -Repository PSGallery -RequiredVersion 3.8.0 -Force -AllowClobber
Migration instructions Azure.RM to Az - https://azure.microsoft.com/en-au/blog/how-to-migrate-from-azurerm-to-az-in-azure-powershell/
#>

###############################################################################
# Parameters & Variables
###############################################################################

$prefix = "CompanyX"

###############################################################################
# Logon to Azure
###############################################################################

Login-AzAccount | Out-Null

$subscriptions = Get-AzSubscription
$cnt = 1
Write-Host "ID    Subscription Name"
Write-Host "-----------------------"

foreach ($sub in $subscriptions){
    Write-Host "$cnt   $($sub.name)"
    $cnt++
}
$selection = Read-Host -Prompt "Select a subscription to deploy to"
$subSelect = $subscriptions[$selection - 1] # Revert 1-index to 0-index

Select-AzSubscription $subSelect.SubscriptionId

###############################################################################
# Create the POC
###############################################################################