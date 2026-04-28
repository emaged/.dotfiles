Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

Write-Step 'Installing Julia via juliaup...'
Install-WingetPackage -Id '9NJNWW8PVKMN' -Name 'Julia' -Source 'msstore'

Refresh-Path

if (Test-Command juliaup) {
    & juliaup add release
    & juliaup default release
    Write-Info 'Julia installation complete.'
} else {
    Write-Warning 'Julia was handed off to the Microsoft Store. If juliaup is not visible yet, reopen PowerShell after the Store install finishes.'
}
