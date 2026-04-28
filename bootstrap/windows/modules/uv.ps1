Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

Write-Step 'Installing uv...'
Install-WingetPackage -Id 'astral-sh.uv' -Name 'uv'
Write-Info 'uv installation complete.'
