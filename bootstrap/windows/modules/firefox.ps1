Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

Write-Step 'Installing Firefox...'
Install-WingetPackage -Id 'Mozilla.Firefox' -Name 'Firefox'
Write-Info 'Firefox installed. This bootstrap does not force the Windows default browser.'
