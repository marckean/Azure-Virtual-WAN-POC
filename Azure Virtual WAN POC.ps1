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
$ResourceGroupName = $prefix + "AzureVirtualWAN_POC"

$vNet1Name = "SpokeVnetWin10"
$vNet1AddressRange = "10.32.32.0/20"
$vNet1Subnet1Name = "One"
$vNet1Subnet2Name = "AzureBastionSubnet"
$vNet1Subnet1Prefix = "10.32.32.0/21"
$vNet1Subnet2Prefix = "10.32.40.0/27"

$vNet2Name = "SpokeVnetPE"
$vNet2AddressRange = "10.32.0.0/20"
$vNet2Subnet1Name = "One"
$vNet2Subnet2Name = "AzureBastionSubnet"
$vNet2Subnet1Prefix = "10.32.0.0/21"
$vNet2Subnet2Prefix = "10.32.8.0/27"

$AzureBastion1Name = $vNet1Name + "Bastion"
$AzureBastion2Name = $vNet2Name + "Bastion"

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
# Choose a location
###############################################################################

$locations = Get-AzLocation
$cnt = 1
Write-Host "ID    Location Name"
Write-Host "-----------------------"

foreach ($loc in $locations){
    Write-Host "$cnt   $($loc.location)"
    $cnt++
}
$selection = Read-Host -Prompt "Select a location to deploy to"
$locSelect = $locations[$selection - 1] # Revert 1-index to 0-index

$region = $locSelect.location

###############################################################################
# Create the POC
###############################################################################

# Resource Group
try {

    # Check for existing client Certificate with private key
    Get-AzResourceGroup -Name $ResourceGroupName -Location $region

}
catch {

    New-AzResourceGroup -Name $ResourceGroupName -Location $region

}

# Virtual Networks
try {

    # Check for existing client Certificate with private key
    Get-AzVirtualNetwork -Name $vNet1Name -ResourceGroupName $ResourceGroupName
    Get-AzVirtualNetwork -Name $vNet2Name -ResourceGroupName $ResourceGroupName

}
catch {
    $vNet1Subnet1 = New-AzVirtualNetworkSubnetConfig -Name $vNet1Subnet1Name -AddressPrefix $vNet1Subnet1Prefix
    $vNet1Subnet2 = New-AzVirtualNetworkSubnetConfig -Name $vNet1Subnet2Name -AddressPrefix $vNet1Subnet2Prefix
    New-AzVirtualNetwork -Name $vNet1Name -ResourceGroupName $ResourceGroupName -Location $region -AddressPrefix $vNet1AddressRange `
    -Subnet @($vNet1Subnet1,$vNet1Subnet2)

    $vNet2Subnet1 = New-AzVirtualNetworkSubnetConfig -Name $vNet2Subnet1Name -AddressPrefix $vNet2Subnet1Prefix
    $vNet2Subnet2 = New-AzVirtualNetworkSubnetConfig -Name $vNet2Subnet2Name -AddressPrefix $vNet2Subnet2Prefix
    New-AzVirtualNetwork -Name $vNet2Name -ResourceGroupName $ResourceGroupName -Location $region -AddressPrefix $vNet2AddressRange `
    -Subnet @($vNet2Subnet1,$vNet2Subnet2)
}

# Azure Bastion
try {

    # Check for existing client Certificate with private key
    Get-AzBastion -Name $AzureBastion1Name -ResourceGroupName $ResourceGroupName
    Get-AzBastion -Name $AzureBastion2Name -ResourceGroupName $ResourceGroupName

}
catch {
    New-AzPublicIpAddress -Name ""
    New-AzBastion -ResourceGroupName $ResourceGroupName -Name $AzureBastion1Name -PublicIpAddress
}