Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

& (Join-Path $ScriptDir 'mise.ps1')

Write-Step 'Installing Node.js via mise...'
& mise use -g node@latest

$packages = @(
    '@openai/codex',
    '@mermaid-js/mermaid-cli',
    '@github/copilot',
    'browser-sync',
    'eslint',
    'eslint-config-prettier',
    'eslint_d',
    'htmlhint',
    'http-server',
    'live-server',
    'mcp-hub',
    'neovim',
    'prettier'
)

Write-Step 'Installing global npm packages...'

foreach ($package in $packages) {
    & mise exec -- npm list -g --depth=0 $package *> $null
    if ($LASTEXITCODE -eq 0) {
        Write-Info "$package already installed"
        continue
    }

    Write-Step "Installing $package..."
    & mise exec -- npm install -g $package
}

Write-Info 'Global npm packages installation complete.'
