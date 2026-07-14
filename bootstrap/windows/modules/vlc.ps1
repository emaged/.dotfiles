Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

Write-Step 'Installing VLC...'
Install-WingetPackage -Id 'VideoLAN.VLC' -Name 'VLC'
Write-Info 'VLC installed.'
