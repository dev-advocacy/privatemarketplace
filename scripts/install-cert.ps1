<#
.SYNOPSIS
    Installs the privatemarketplace.crt certificate into the Windows certificate store.

.DESCRIPTION
    By default installs the certificate into the CurrentUser\Root store (Trusted Root CA) —
    this does not require elevation. If the script is run as Administrator, it will also
    install the certificate into LocalMachine\Root (machine-wide).

.NOTES
    Run this script from the repository folder or pass an absolute path.
#>

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$certPath = Join-Path $scriptRoot "..\certs\privatemarketplace.crt"
$certPath = Resolve-Path $certPath -ErrorAction SilentlyContinue

if (-not $certPath) {
    Write-Error "The file privatemarketplace.crt was not found in the 'certs' folder. Run scripts/make-cert.ps1 first."
    exit 1
}

$certPath = $certPath.Path

Write-Host "Installing certificate: $certPath"

# Load certificate object to compare thumbprint/subject with existing ones
try {
    $newCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certPath)
    $newThumbprint = $newCert.Thumbprint
    $newSubject = $newCert.Subject
} catch {
    Write-Warning "Failed to load the certificate file for comparison: $_"
    $newCert = $null
    $newThumbprint = $null
    $newSubject = $null
}

function Remove-ExistingCertsFromStore([string]$storeLocationName) {
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store('Root', $storeLocationName)
    try {
        $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
        $removed = 0
        $candidates = @()
        foreach ($c in $store.Certificates) {
            if ($null -ne $newThumbprint -and $c.Thumbprint -eq $newThumbprint) {
                $candidates += $c
            } elseif ($null -ne $newSubject -and $c.Subject -eq $newSubject) {
                $candidates += $c
            } elseif ($c.Subject -like '*CN=localhost*' -and $c.Issuer -eq $c.Subject) {
                # common case: previous self-signed localhost cert
                $candidates += $c
            }
        }

        foreach ($rc in $candidates) {
            try {
                $store.Remove($rc)
                $removed++
            } catch {
                Write-Warning "Failed to remove certificate $($rc.Thumbprint): $_"
            }
        }
        if ($removed -gt 0) { Write-Host "Removed $removed existing cert(s) from $storeLocationName\Root." }
    } finally {
        $store.Close()
    }
}

# Remove existing certs from CurrentUser\Root
Remove-ExistingCertsFromStore 'CurrentUser'


# Install for current user (no elevation required)
try {
    Import-Certificate -FilePath $certPath -CertStoreLocation Cert:\CurrentUser\Root | Out-Null
    Write-Host "Certificate installed in CurrentUser\Root (Trusted Root Certification Authorities)."
} catch {
    Write-Warning "Failed to install into CurrentUser\Root: $_"
}

if (Test-IsAdmin) {
    # If admin, remove existing from LocalMachine as well before import
    Remove-ExistingCertsFromStore 'LocalMachine'
    try {
        Import-Certificate -FilePath $certPath -CertStoreLocation Cert:\LocalMachine\Root | Out-Null
        Write-Host "Certificate also installed in LocalMachine\Root (machine-wide)."
    } catch {
        Write-Warning "Failed to install into LocalMachine\Root: $_"
    }
} else {
    Write-Host "To install machine-wide (for all users), re-run this PowerShell window as Administrator and execute this script."
}

Write-Host "Done. Restart VS Code if needed so it picks up the trusted certificate."
