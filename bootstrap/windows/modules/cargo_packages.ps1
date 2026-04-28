Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

Refresh-Path

if (-not (Test-Command cargo)) {
    Write-Warning 'cargo not found. Install Rustup first or open a new shell after the Rustup installation completes.'
    return
}

if (Test-Command rustup) {
    Write-Step 'Ensuring the stable Rust toolchain is active...'
    & rustup toolchain install stable
    & rustup default stable
}

Write-Step 'Installing cargo packages...'

$installed = & cargo install --list
$crates = @(
    'ast-grep',
    'cargo-update',
    'du-dust',
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
