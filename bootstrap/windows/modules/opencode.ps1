Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

if (-not (Test-Command mise)) {
    & (Join-Path $ScriptDir 'mise.ps1')
}

Ensure-MiseTool -Tool 'node'
Ensure-UserNpmPrefix
Write-Step 'Installing OpenCode via npm...'
& mise -C $HOME exec node -- npm list -g --depth=0 opencode-ai *> $null

if ($LASTEXITCODE -eq 0) {
    Write-Info 'opencode-ai already installed'
} else {
    & mise -C $HOME exec node -- npm install -g opencode-ai
    Assert-NativeCommandSucceeded `
        -Description 'Installing OpenCode' `
        -ExitCode $LASTEXITCODE
}

Write-Info 'OpenCode is installed. OpenCode recommends WSL for the best Windows experience, but this keeps the native Windows bootstrap close to your Linux setup.'
