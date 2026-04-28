Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

Write-Step 'Installing Yazi and dependencies...'

$wingetPackages = @(
    @{ Id = '7zip.7zip'; Name = '7-Zip' },
    @{ Id = 'Gyan.FFmpeg'; Name = 'FFmpeg' },
    @{ Id = 'junegunn.fzf'; Name = 'fzf' },
    @{ Id = 'jqlang.jq'; Name = 'jq' },
    @{ Id = 'oschwartz10612.Poppler'; Name = 'Poppler' },
    @{ Id = 'BurntSushi.ripgrep.MSVC'; Name = 'ripgrep' },
    @{ Id = 'sxyazi.yazi'; Name = 'Yazi' },
    @{ Id = 'ajeetdsouza.zoxide'; Name = 'zoxide' }
)

foreach ($package in $wingetPackages) {
    Install-WingetPackage -Id $package.Id -Name $package.Name
}

Ensure-Scoop
Install-ScoopPackage -Package 'resvg'

Write-Info 'Yazi installation complete.'
