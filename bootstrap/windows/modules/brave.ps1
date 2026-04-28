Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

Write-Step 'Installing Brave...'
Install-WingetPackage -Id 'Brave.Brave' -Name 'Brave'
Write-Info 'Brave installed.'
