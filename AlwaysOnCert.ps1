### RUN AS ADMINISTRATOR for local machine

<#
Divya - this is the documented way of creating the VPN connection on the local Win 10 machine,
which I had troubles with it, it creates the VPN connection but then I can't see the connection in Windows,
however you can see it below with PowerShell and you can connect and disconnect from PowerShell
#>

#region From https://docs.microsoft.com/en-us/azure/virtual-wan/howto-always-on-device-tunnel
function devicecert {
    Param(
        [string]$xmlFilePath,
        [string]$ProfileName
    )
        
    $a = Test-Path $xmlFilePath
    echo $a
        
    $ProfileXML = Get-Content $xmlFilePath
        
    echo $XML
        
    $ProfileNameEscaped = $ProfileName -replace ' ', '%20'
        
    $Version = 201606090004
        
    $ProfileXML = $ProfileXML -replace '<', '&lt;'
    $ProfileXML = $ProfileXML -replace '>', '&gt;'
    $ProfileXML = $ProfileXML -replace '"', '&quot;'
        
    $nodeCSPURI = './Vendor/MSFT/VPNv2'
    $namespaceName = "root\cimv2\mdm\dmmap"
    $className = "MDM_VPNv2_01"
        
    $session = New-CimSession
        
    try {
        $newInstance = New-Object Microsoft.Management.Infrastructure.CimInstance $className, $namespaceName
        $property = [Microsoft.Management.Infrastructure.CimProperty]::Create("ParentID", "$nodeCSPURI", 'String', 'Key')
        $newInstance.CimInstanceProperties.Add($property)
        $property = [Microsoft.Management.Infrastructure.CimProperty]::Create("InstanceID", "$ProfileNameEscaped", 'String', 'Key')
        $newInstance.CimInstanceProperties.Add($property)
        $property = [Microsoft.Management.Infrastructure.CimProperty]::Create("ProfileXML", "$ProfileXML", 'String', 'Property')
        $newInstance.CimInstanceProperties.Add($property)
        
        $session.CreateInstance($namespaceName, $newInstance)
        $Message = "Created $ProfileName profile."
        Write-Host "$Message"
    }
    catch [Exception] {
        $Message = "Unable to create $ProfileName profile: $_"
        Write-Host "$Message"
        exit
    }
    $Message = "Complete."
    Write-Host "$Message"
}

$VPN_Name = 'AzureDeviceTunnel2'
devicecert .\VPNProfile.xml $VPN_Name
#endregion



<#
Divya - this is my other way of creating the VPN connection on the local Win 10 machine,
seems to be a whole lot cleaner, and I can see the connection in the Windows networks tray
#>
###############################################################################
# Addition of the VPN connections
###############################################################################
# Alternate method
$VPN_Name = 'AzureDeviceTunnel'
$VPN_ServerName = 'hub0.dg67i3fr1l94yn9nwcrsv5fue.vpn.azure.com'
Add-VpnConnection -AuthenticationMethod MachineCertificate -ServerName $VPN_ServerName `
    -EncryptionLevel Required -Name $VPN_Name -TunnelType Ikev2 -SplitTunneling -AllUserConnection

###############################################################################
# Connection of the VPN connection
###############################################################################
if(Get-VpnConnection -Name $VPN_Name -ErrorAction SilentlyContinue){$vpn = Get-VpnConnection -Name $VPN_Name}
if(Get-VpnConnection -Name $VPN_Name -AllUserConnection -ErrorAction SilentlyContinue){$vpn = Get-VpnConnection -Name $VPN_Name -AllUserConnection}

if($vpn.ConnectionStatus -eq "Disconnected"){
rasdial $VPN_Name;
}

###############################################################################
# Disconnection of the VPN connection
###############################################################################
if(Get-VpnConnection -Name $VPN_Name -ErrorAction SilentlyContinue){$vpn = Get-VpnConnection -Name $VPN_Name}
if(Get-VpnConnection -Name $VPN_Name -AllUserConnection -ErrorAction SilentlyContinue){$vpn = Get-VpnConnection -Name $VPN_Name -AllUserConnection}

if($vpn.ConnectionStatus -eq "Connected"){
  rasdial $VPN_Name /DISCONNECT;
}

###############################################################################
# Removal of the VPN connections
###############################################################################
# Remove Always On VPN
Get-VpnConnection -Name $VPN_Name -ErrorAction SilentlyContinue | Remove-VpnConnection -Force
Get-VpnConnection -Name $VPN_Name -AllUserConnection -ErrorAction SilentlyContinue | Remove-VpnConnection -Force

###############################################################################
# Check routes
###############################################################################
Get-NetRoute -InterfaceAlias $VPN_Name
Get-NetIPAddress -InterfaceAlias $VPN_Name | fl *

Get-VpnConnection | fl *