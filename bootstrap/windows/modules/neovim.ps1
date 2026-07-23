Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

if (
    [Environment]::GetEnvironmentVariable('DOTFILES_MISE_READY') -ne '1'
) {
    & (Join-Path $ScriptDir 'mise.ps1')
}

Write-Step 'Installing Neovim via mise...'
& mise use -g neovim@nightly
Assert-NativeCommandSucceeded `
    -Description 'Installing Neovim via mise' `
    -ExitCode $LASTEXITCODE

Write-Step 'Installing Neovim Ruby provider...'

Refresh-Path

if (-not (Test-Command gem)) {
    Write-Warning 'Ruby is not available. Rerun dev-tools.ps1 to install RubyInstaller with DevKit for the Neovim Ruby provider.'
    return
}

$rubyVersion = (& ruby -e 'print RUBY_VERSION') 2>$null
Assert-NativeCommandSucceeded `
    -Description 'Reading the Ruby version' `
    -ExitCode $LASTEXITCODE

if ($rubyVersion -match '^4\.') {
    throw "Ruby $rubyVersion is active. Use RubyInstaller 3.4 with DevKit for the Neovim Ruby provider; the current Neovim Ruby dependencies fail to build against this Ruby."
}

& gem list -i neovim *> $null
if ($LASTEXITCODE -eq 0) {
    Write-Info 'neovim Ruby gem already installed.'
} else {
    & gem install neovim
    if ($LASTEXITCODE -ne 0) {
        throw 'gem install neovim failed.'
    }
}

Write-Info 'Neovim setup complete.'
