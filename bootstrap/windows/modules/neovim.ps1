Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

& (Join-Path $ScriptDir 'mise.ps1')

Write-Step 'Installing Neovim via mise...'
& mise use -g neovim@nightly

Write-Step 'Installing Neovim Ruby provider...'

Refresh-Path

if (-not (Test-Command gem)) {
    Write-Warning 'Ruby is not available. Rerun dev-tools.ps1 from an elevated shell to install the Chocolatey Ruby package for the Neovim Ruby provider.'
    return
}

& gem list -i neovim *> $null
if ($LASTEXITCODE -eq 0) {
    Write-Info 'neovim Ruby gem already installed.'
} else {
    & gem install neovim
}

Write-Info 'Neovim setup complete.'
