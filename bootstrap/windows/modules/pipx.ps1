Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

if (-not (Test-Command mise)) {
    & (Join-Path $ScriptDir 'mise.ps1')
}

Write-Step 'Installing Python via mise...'
Ensure-MiseTool -Tool 'python' -Version 'latest'

Write-Step 'Ensuring pipx is installed...'
& mise -C $HOME exec python -- python -m pip install --upgrade pip
Assert-NativeCommandSucceeded `
    -Description 'Upgrading pip' `
    -ExitCode $LASTEXITCODE

& mise -C $HOME exec python -- python -m pip install --user pipx
Assert-NativeCommandSucceeded `
    -Description 'Installing pipx' `
    -ExitCode $LASTEXITCODE

& mise -C $HOME exec python -- python -m pipx ensurepath
Assert-NativeCommandSucceeded `
    -Description 'Adding pipx to PATH' `
    -ExitCode $LASTEXITCODE

Refresh-Path

$packages = @(Read-PackageList -Name 'pipx')

Write-Step 'Installing / upgrading pipx packages...'

$inventory = & mise -C $HOME exec python -- python -m pipx list --json
Assert-NativeCommandSucceeded -Description 'Listing pipx environments' -ExitCode $LASTEXITCODE
$installed = @(($inventory | ConvertFrom-Json).venvs.PSObject.Properties | ForEach-Object { $_.Name })
foreach ($package in $packages) {
    if ($installed -contains $package) {
        & mise -C $HOME exec python -- python -m pipx upgrade $package
    } else {
        & mise -C $HOME exec python -- python -m pipx install $package
    }
    Assert-NativeCommandSucceeded -Description "Installing/upgrading pipx package $package" -ExitCode $LASTEXITCODE
}
Write-Info 'pipx packages installed/upgraded.'
