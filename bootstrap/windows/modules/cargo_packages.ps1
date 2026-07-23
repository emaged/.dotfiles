Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

Refresh-Path

if (-not (Test-Command cargo)) {
    throw 'cargo not found after installing Rustup.'
}

if (Test-Command rustup) {
    Write-Step 'Ensuring the stable Rust toolchain is active...'
    & rustup toolchain install stable
    Assert-NativeCommandSucceeded `
        -Description 'Installing the stable Rust toolchain' `
        -ExitCode $LASTEXITCODE

    & rustup default stable
    Assert-NativeCommandSucceeded `
        -Description 'Selecting the stable Rust toolchain' `
        -ExitCode $LASTEXITCODE
}

Write-Step 'Installing cargo packages...'

$installed = & cargo install --list
Assert-NativeCommandSucceeded `
    -Description 'Listing installed Cargo packages' `
    -ExitCode $LASTEXITCODE

$crates = @(
    'ast-grep',
    'cargo-update',
    'du-dust',
    'neovide',
    'selene',
    'trashy'
)

foreach ($crate in $crates) {
    if ($installed -match "(?m)^$([regex]::Escape($crate)) v") {
        Write-Info "$crate already installed"
        continue
    }

    Write-Step "Installing $crate..."
    & cargo install $crate --locked
    if ($LASTEXITCODE -ne 0) {
        throw "cargo install failed for $crate"
    }
}

Write-Info 'Cargo packages installation complete.'
