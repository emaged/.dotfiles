Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

Write-Step 'Installing PowerShell and Windows Terminal...'

Install-WingetPackage -Id 'Microsoft.PowerShell' -Name 'PowerShell'
Install-WingetPackage -Id 'Microsoft.WindowsTerminal' -Name 'Windows Terminal'

Write-Info 'Windows does not support changing the login shell the same way Linux does, so this module installs the shell tooling but does not switch a default shell.'
