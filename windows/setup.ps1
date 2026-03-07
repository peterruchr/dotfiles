# Windows dotfiles bootstrap script
# Run this once from PowerShell 7 as your user (no admin required with Developer Mode enabled)
# If symlinks fail, enable Developer Mode in Windows Settings or run PS7 as Administrator

$dotfiles = "$HOME\dotfiles\windows"

# PowerShell 7 profile
$profileDir = Split-Path $PROFILE
if (!(Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force }
New-Item -ItemType SymbolicLink `
  -Path $PROFILE `
  -Target "$dotfiles\powershell\profile.ps1" `
  -Force

# Starship config
$starshipDir = "$HOME\.config"
if (!(Test-Path $starshipDir)) { New-Item -ItemType Directory -Path $starshipDir -Force }
New-Item -ItemType SymbolicLink `
  -Path "$starshipDir\starship.toml" `
  -Target "$HOME\dotfiles\starship\starship.toml" `
  -Force

Write-Host "Done. Restart PowerShell 7 to apply changes."
