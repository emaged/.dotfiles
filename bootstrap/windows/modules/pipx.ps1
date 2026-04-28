Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

& (Join-Path $ScriptDir 'mise.ps1')

Write-Step 'Installing Python via mise...'
& mise use -g python@latest

Write-Step 'Ensuring pipx is installed...'
& mise exec -- python -m pip install --upgrade pip
& mise exec -- python -m pip install --user pipx
& mise exec -- python -m pipx ensurepath
Refresh-Path

$packages = @(
    'black',
    'djlint',
    'hererocks',
    'ipython',
    'poetry',
    'pynvim',
    'pytest',
    'ruff'
)

Write-Step 'Installing / upgrading pipx packages...'

foreach ($package in $packages) {
    & mise exec -- python -m pipx upgrade $package
    if ($LASTEXITCODE -ne 0) {
        & mise exec -- python -m pipx install $package
    }
}

Write-Info 'pipx packages installed/upgraded to latest.'
