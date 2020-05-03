
### RUN AS ADMINISTRATOR for local machine
#region https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-certificates-point-to-site#clientcert

###############################################################################
# Variables
###############################################################################

$CertStoreRootPath = "CurrentUser" # Use 'CurrentUser' or 'LocalMachine' here
$CNroot = 'P2SRootCert'
$ClientCertStore = "Cert:\$CertStoreRootPath\My"
$RootCertStore = "Cert:\$CertStoreRootPath\Root"
$ClientPFXCertPassword = "Passw0rd"

###############################################################################
# Create a self-signed root certificate - the base64 version of this to be in Azure
###############################################################################

try {

    # Check existing self-signed root certificate
    (Get-ChildItem -Path $RootCertStore | where {$_.Subject -eq "CN=$CNroot"})

}
catch {

    # Ceate this certificate in the Personal certificate store temporarily 
    New-SelfSignedCertificate -Type Custom -KeySpec Signature `
        -Subject "CN=$CNroot" -KeyExportPolicy Exportable `
        -HashAlgorithm sha256 -KeyLength 2048 `
        -CertStoreLocation $ClientCertStore -KeyUsageProperty Sign -KeyUsage CertSign

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
    $PSPath = (Get-ChildItem -Path $ClientCertStore | where {$_.Subject -eq "CN=$CNroot"}).PSPath
    Move-Item -Path $PSPath -Destination $RootCertStore -Force
    $PSPath | Move-Item -Destination $RootCertStore

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
# Clean Up - if you want to clean up everything from above, remove all certificates created from above
###############################################################################

# Delete the Root Certificate
(Get-ChildItem -Path $RootCertStore | where {$_.Subject -eq "CN=$CNroot"}) | Remove-Item -Force -ErrorAction SilentlyContinue
(Get-ChildItem -Path $ClientCertStore | where {$_.Subject -eq "CN=$CNroot"}) | Remove-Item -Force -ErrorAction SilentlyContinue
Get-Item -Path "$ENV:USERPROFILE\Documents\$CNroot.cer" | Remove-Item -Force -ErrorAction SilentlyContinue
