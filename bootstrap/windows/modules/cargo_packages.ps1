Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

Refresh-Path
Assert-MsvcBuildTools
if (-not (Test-Command rustup)) { throw 'Rustup is unavailable; run the dev-tools module first.' }
& rustup run stable cargo --version *> $null
if ($LASTEXITCODE -ne 0) {
    & rustup toolchain install stable --profile minimal
    Assert-NativeCommandSucceeded -Description 'Installing stable Rust' -ExitCode $LASTEXITCODE
}

Write-Step 'Installing cargo packages...'

$installed = & rustup run stable cargo install --list
Assert-NativeCommandSucceeded `
    -Description 'Listing installed Cargo packages' `
    -ExitCode $LASTEXITCODE

$crates = @(Read-PackageList -Name 'cargo')

foreach ($crate in $crates) {
    if ($installed -match "(?m)^$([regex]::Escape($crate)) v") {
        Write-Info "$crate already installed"
        continue
    }

    Write-Step "Installing $crate..."
    & rustup run stable cargo install $crate --locked
    if ($LASTEXITCODE -ne 0) {
        throw "cargo install failed for $crate"
    }
}

Write-Info 'Cargo packages installation complete.'
