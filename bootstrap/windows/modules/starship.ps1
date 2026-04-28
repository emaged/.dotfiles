Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

Write-Step 'Installing starship...'
Install-WingetPackage -Id 'Starship.Starship' -Name 'starship'
Write-Info 'starship installation complete.'
