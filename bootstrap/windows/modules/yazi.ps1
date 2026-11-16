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


# Yazi requires file(1); Git for Windows supplies it outside the default PATH.
if (-not $env:YAZI_FILE_ONE) {
    $git = (Get-Command git -ErrorAction Stop).Source
    $gitRoot = Split-Path -Parent (Split-Path -Parent $git)
    $file = Join-Path $gitRoot 'usr\bin\file.exe'
    if (-not (Test-Path -LiteralPath $file)) {
        throw 'Git file.exe was not found. Set YAZI_FILE_ONE to Git\usr\bin\file.exe, then rerun this module.'
    }
    [Environment]::SetEnvironmentVariable('YAZI_FILE_ONE', $file, 'User')
    $env:YAZI_FILE_ONE = $file
}

if (-not (Test-Path -LiteralPath $env:YAZI_FILE_ONE)) {
    throw 'YAZI_FILE_ONE points to a missing file. Correct it before running Yazi.'
}
Write-Info 'Yazi installation complete.'
