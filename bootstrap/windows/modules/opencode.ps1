Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

& (Join-Path $ScriptDir 'mise.ps1')

Write-Step 'Installing OpenCode via npm...'
& mise exec -- npm list -g --depth=0 opencode-ai *> $null

if ($LASTEXITCODE -eq 0) {
    Write-Info 'opencode-ai already installed'
} else {
    & mise exec -- npm install -g opencode-ai
}

Write-Info 'OpenCode is installed. OpenCode recommends WSL for the best Windows experience, but this keeps the native Windows bootstrap close to your Linux setup.'
