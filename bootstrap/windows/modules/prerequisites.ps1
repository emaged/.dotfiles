Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')
Install-WingetPackage -Id 'Git.Git' -Name 'Git'
Ensure-Scoop
Ensure-ScoopBucket -Name 'main'
