Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

if (
    [Environment]::GetEnvironmentVariable('DOTFILES_MISE_READY') -ne '1'
) {
    & (Join-Path $ScriptDir 'mise.ps1')
}

Write-Step 'Installing Python via mise...'
& mise use -g python@latest
Assert-NativeCommandSucceeded `
    -Description 'Installing Python via mise' `
    -ExitCode $LASTEXITCODE

Write-Step 'Ensuring pipx is installed...'
& mise exec -- python -m pip install --upgrade pip
Assert-NativeCommandSucceeded `
    -Description 'Upgrading pip' `
    -ExitCode $LASTEXITCODE

& mise exec -- python -m pip install --user pipx
Assert-NativeCommandSucceeded `
    -Description 'Installing pipx' `
    -ExitCode $LASTEXITCODE

& mise exec -- python -m pipx ensurepath
Assert-NativeCommandSucceeded `
    -Description 'Adding pipx to PATH' `
    -ExitCode $LASTEXITCODE

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
        Assert-NativeCommandSucceeded `
            -Description "Installing pipx package $package" `
            -ExitCode $LASTEXITCODE
    }
}

Write-Info 'pipx packages installed/upgraded to latest.'
