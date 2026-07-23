Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

if (
    [Environment]::GetEnvironmentVariable('DOTFILES_MISE_READY') -ne '1'
) {
    & (Join-Path $ScriptDir 'mise.ps1')
}

Write-Step 'Installing Node.js via mise...'
& mise use -g node@latest
Assert-NativeCommandSucceeded `
    -Description 'Installing Node.js via mise' `
    -ExitCode $LASTEXITCODE

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
    Assert-NativeCommandSucceeded `
        -Description "Installing npm package $package" `
        -ExitCode $LASTEXITCODE
}

Write-Step 'Generating Codex PowerShell completions...'

$completionDirectory = Join-Path $HOME `
    '.local\share\powershell\completions'
$completionPath = Join-Path $completionDirectory 'codex.ps1'

Ensure-Directory -Path $completionDirectory
$completionTemporaryPath = [IO.Path]::GetTempFileName()

try {
    $completion = & mise exec -- codex completion powershell
    Assert-NativeCommandSucceeded `
        -Description 'Generating Codex PowerShell completions' `
        -ExitCode $LASTEXITCODE

    $completion |
        Set-Content -LiteralPath $completionTemporaryPath -Encoding utf8
    Move-Item `
        -LiteralPath $completionTemporaryPath `
        -Destination $completionPath `
        -Force

    Write-Info 'Codex PowerShell completions generated.'
} finally {
    if (Test-Path -LiteralPath $completionTemporaryPath) {
        Remove-Item -LiteralPath $completionTemporaryPath -Force
    }
}

Write-Info 'Global npm packages installation complete.'
