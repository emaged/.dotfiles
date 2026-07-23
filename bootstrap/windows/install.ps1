Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ModuleDir = Join-Path $RootDir 'modules'

. (Join-Path $ModuleDir 'common.ps1')

function Run-Module {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    Write-Host ''
    Write-Host "==> $Name"
    & (Join-Path $ModuleDir $Name)
}

Write-Host '==> Ensuring WinGet is available...'
Ensure-Winget

Run-Module 'shell.ps1'
Run-Module 'dev-tools.ps1'
Run-Module 'mise.ps1'
Run-Module 'uv.ps1'
Run-Module 'pipx.ps1'
Run-Module 'cargo_packages.ps1'
Run-Module 'node.ps1'
Run-Module 'julia.ps1'
Run-Module 'neovim.ps1'
Run-Module 'opencode.ps1'
Run-Module 'starship.ps1'
Run-Module 'yazi.ps1'
Run-Module 'firefox.ps1'
Run-Module 'brave.ps1'
Run-Module 'vlc.ps1'
Run-Module 'profile.ps1'

Write-Host ''
Write-Host 'Bootstrap complete.'
