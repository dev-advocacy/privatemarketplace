param(
  [string]$OutDir = "..\artifacts"
)
if (-not (Get-Command vsce -ErrorAction SilentlyContinue)) {
  Write-Host "vsce not found globally - will use npx vsce if available." -ForegroundColor Yellow
  $useNpx = $true
} else {
  $useNpx = $false
}
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }
Push-Location -Path $PSScriptRoot
if ($useNpx) {
  npx vsce package -o (Join-Path $OutDir "gillesg-test.vsix")
} else {
  vsce package -o (Join-Path $OutDir "gillesg-test.vsix")
}
Pop-Location
