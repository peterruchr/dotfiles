# Windows PowerShell 7 Bootstrap Script
# Run this once from PowerShell 7 to set up your environment
# Usage: pwsh -File bootstrap.ps1

$ErrorActionPreference = "Stop"
$dotfiles = $PSScriptRoot

Write-Host "Starting Windows PS7 bootstrap..."

# ── Install tools via winget ────────────────────────────────────
Write-Host "`nInstalling tools via winget..."

$tools = @(
    @{ Id = "Microsoft.PowerShell";        Name = "PowerShell 7"  },
    @{ Id = "eza-community.eza";           Name = "eza"           },
    @{ Id = "sharkdp.bat";                 Name = "bat"           },
    @{ Id = "junegunn.fzf";               Name = "fzf"           },
    @{ Id = "ajeetdsouza.zoxide";          Name = "zoxide"        },
    @{ Id = "BurntSushi.ripgrep.MSVC";     Name = "ripgrep"       },
    @{ Id = "Starship.Starship";           Name = "starship"      },
    @{ Id = "SST.opencode";                Name = "opencode"      },
    @{ Id = "Github.cli";                Name = "Github Cli"      }
)

foreach ($tool in $tools) {
    Write-Host "  Installing $($tool.Name)..."
    winget install --id $tool.Id --silent --accept-package-agreements --accept-source-agreements
}

# ── Install PowerShell modules ──────────────────────────────────
Write-Host "`nInstalling PowerShell modules..."

$modules = @("PSReadLine", "PSFzf", "Terminal-Icons")
foreach ($module in $modules) {
    if (Get-Module -ListAvailable -Name $module) {
        Write-Host "  $module already installed, skipping."
    } else {
        Write-Host "  Installing $module..."
        Install-Module $module -Scope CurrentUser -Force -AllowClobber
    }
}

# ── Create symlinks ─────────────────────────────────────────────
Write-Host "`nCreating symlinks..."

# PS7 profile
$profileDir = Split-Path $PROFILE
if (!(Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
New-Item -ItemType SymbolicLink `
    -Path $PROFILE `
    -Target "$dotfiles\powershell\profile.ps1" `
    -Force | Out-Null
Write-Host "  Linked PS7 profile"

# Starship config
$starshipDir = "$HOME\.config"
if (!(Test-Path $starshipDir)) { New-Item -ItemType Directory -Path $starshipDir -Force | Out-Null }
New-Item -ItemType SymbolicLink `
    -Path "$starshipDir\starship.toml" `
    -Target "$PSScriptRoot\..\starship\.config\starship.toml" `
    -Force | Out-Null
Write-Host "  Linked starship.toml"

Write-Host "`nDone! Restart PowerShell 7 to apply your profile."
