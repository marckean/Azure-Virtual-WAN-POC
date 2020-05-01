
### RUN AS ADMINISTRATOR for local machine
#region https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-certificates-point-to-site#clientcert

###############################################################################
# Variables
###############################################################################

$CertStoreRootPath = "CurrentUser"
$CNroot = 'P2SRootCert'
$CNclient = 'P2SChildCert'
$ClientCertStore = "Cert:\$CertStoreRootPath\My"
$RootCertStore = "Cert:\$CertStoreRootPath\Root"
$ClientPFXCertPassword = "Passw0rd"

###############################################################################
# Create a self-signed root certificate - the base64 version of this to be in Azure
###############################################################################

try {

    # Check existing self-signed root certificate
    Get-ChildItem -Path $RootCertStore | where {$_.Subject -eq "CN=$CNroot"}
    Get-ChildItem -Path $ClientCertStore | where {$_.Subject -eq "CN=$CNroot"}

}
catch {

    # Ceate this certificate in the Personal certificate store temporarily 
    $rootcert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
        -Subject "CN=$CNroot" -KeyExportPolicy Exportable `
        -HashAlgorithm sha256 -KeyLength 2048 `
        -CertStoreLocation $ClientCertStore -KeyUsageProperty Sign -KeyUsage CertSign

}

###############################################################################
# Generate a client certificate
###############################################################################

try {

    # Check existing client certificate
    (Get-ChildItem -Path $ClientCertStore | where {$_.Subject -eq "CN=$CNclient"})

}
catch {

    # Generate a client certificate
    New-SelfSignedCertificate -Type Custom -DnsName $CNclient -KeySpec Signature `
        -Subject "CN=$CNclient" -KeyExportPolicy Exportable `
        -HashAlgorithm sha256 -KeyLength 2048 `
        -CertStoreLocation $ClientCertStore `
        -Signer $rootcert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")
    #endregion

}

###############################################################################
# Move the Root certificate to the root certificate store
###############################################################################

try {

    # Check existing Root certificate in the root certificate store
    (Get-ChildItem -Path $RootCertStore | where {$_.Subject -eq "CN=$CNroot"})

}
catch {

    # Move the Root certificate to the root certificate store
    $s = New-PSSession -RunAsAdministrator
    
    Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -command "{0}"' -f (Start-Sleep -Seconds 5))
    Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -command "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    Start-Process powershell.exe -Verb RunAs 
    $PSChildName = (Get-ChildItem -Path $ClientCertStore | where {$_.Subject -eq "CN=$CNroot"}).PSChildName
    $path = '{0}\{1}' -f $ClientCertStore, $PSChildName
    Move-Item -Path $path -Destination $RootCertStore

}

###############################################################################
# Export Root Certificate to Documents Folder
# From here https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-certificates-point-to-site#clientcert
###############################################################################

try {

    # Check for existing self-signed root certificate
    Get-Item -Path "$ENV:USERPROFILE\Documents\$CNroot.cer"

}
catch {

    $RootCertificate = Get-ChildItem -Path $RootCertStore | where {$_.Subject -eq "CN=$CNroot"}
    $base64certificate = @"
-----BEGIN CERTIFICATE-----
$([Convert]::ToBase64String($RootCertificate.Export('Cert'), [System.Base64FormattingOptions]::InsertLineBreaks))
-----END CERTIFICATE-----
"@
    Set-Content -Path "$ENV:USERPROFILE\Documents\$CNroot.cer" -Value $base64certificate

}

###############################################################################
# Export Client Certificate with private key to Documents Folder
# Distribute this to certificate to all clients that need to connect P2S to Azure Virtual WAN
###############################################################################

try {

    # Check for existing client Certificate with private key
    Get-Item -Path "$ENV:USERPROFILE\Documents\$CNclient.pfx"

}
catch {

    $mypwd = ConvertTo-SecureString -String $ClientPFXCertPassword -Force -AsPlainText
    $ClientCertificate = Get-ChildItem -Path $ClientCertStore | where {$_.Subject -eq "CN=$CNclient"}
    $ClientCertificate | Export-PfxCertificate -FilePath "$ENV:USERPROFILE\Documents\$CNclient.pfx" -Password $mypwd

}

###############################################################################
# Azure Stuff, do these other steps in Azure when you setup P2S in the Azure Virtual WAN Hub
# This is a simple copy and paste of two pieces of information | 'PUBLIC CERTIFICATE DATA' and 'ROOT CERTIFICATE NAME'
###############################################################################

# Copy the Root Base64 to clipboard, paste this Base64 to Azure Virtual WAN, as PUBLIC CERTIFICATE DATA when you edit the user VPN configuration
$RootCertificate = Get-ChildItem -Path $RootCertStore | where {$_.Subject -eq "CN=$CNroot"}
$([Convert]::ToBase64String($RootCertificate.Export('Cert'), [System.Base64FormattingOptions]::InsertLineBreaks)) | clip

Write-Host "The ROOT CERTIFICATE NAME, when you edit the user VPN configuration, is $CNroot"

###############################################################################
# Clean Up - if you want to clean up everything from above, remove all certificates created from above
###############################################################################

# Delete the Root Certificate
(Get-ChildItem -Path $RootCertStore | where {$_.Subject -eq "CN=$CNroot"}) | Remove-Item -Force -ErrorAction SilentlyContinue
(Get-ChildItem -Path $ClientCertStore | where {$_.Subject -eq "CN=$CNroot"}) | Remove-Item -Force -ErrorAction SilentlyContinue
Get-Item -Path "$ENV:USERPROFILE\Documents\$CNroot.cer" | Remove-Item -Force -ErrorAction SilentlyContinue

# Delete the Client Certificate
(Get-ChildItem -Path $ClientCertStore | where {$_.Subject -eq "CN=$CNclient"}) | Remove-Item -Force -ErrorAction SilentlyContinue
Get-Item -Path "$ENV:USERPROFILE\Documents\$CNclient.pfx" | Remove-Item -Force -ErrorAction SilentlyContinue