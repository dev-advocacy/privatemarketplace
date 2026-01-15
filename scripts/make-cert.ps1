$certPath = "$PSScriptRoot/../certs/privatemarketplace.pfx"
$crtPath = "$PSScriptRoot/../certs/privatemarketplace.crt"
$keyPath = "$PSScriptRoot/../certs/privatemarketplace.key"

if (-not (Test-Path "$PSScriptRoot/../certs")) { New-Item -ItemType Directory -Path "$PSScriptRoot/../certs" | Out-Null }

# Create self-signed cert
$cert = New-SelfSignedCertificate -DnsName "localhost" -CertStoreLocation "Cert:\LocalMachine\My" -NotAfter (Get-Date).AddYears(5)

# Export cert and private key to PFX
$pfxPassword = ConvertTo-SecureString -String "privatemarketplace" -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath $certPath -Password $pfxPassword

# Export public cert
Export-Certificate -Cert $cert -FilePath $crtPath

# Extract private key and write as PEM (requires OpenSSL installed)
# If openssl isn't on PATH, try to prepend Git for Windows bundle path where openssl often resides
$gitOpenSslPath = 'C:\Program Files\Git\mingw64\bin'
if (-not (Get-Command openssl -ErrorAction SilentlyContinue) -and (Test-Path $gitOpenSslPath)) {
    $env:PATH = "$gitOpenSslPath;$env:PATH"
}

$openssl = Get-Command openssl -ErrorAction SilentlyContinue
if ($openssl) {
  $tempPfx = "$PSScriptRoot/../certs/temp.pfx"
  Copy-Item $certPath $tempPfx -Force
  & openssl pkcs12 -in $tempPfx -nodes -passin pass:privatemarketplace -out "$PSScriptRoot/../certs/temp.pem"
  & openssl pkey -in "$PSScriptRoot/../certs/temp.pem" -out $keyPath
  Remove-Item "$PSScriptRoot/../certs/temp.pfx","$PSScriptRoot/../certs/temp.pem" -ErrorAction SilentlyContinue
} else {
  Write-Host "OpenSSL not found; private key PEM not created. Install OpenSSL to generate .key file for nginx or add it to PATH."
}

Write-Host "Certificate created at: $certPath and $crtPath"
Write-Host "Install $crtPath to Trusted Root Certification Authorities on Windows for VS Code to trust it."