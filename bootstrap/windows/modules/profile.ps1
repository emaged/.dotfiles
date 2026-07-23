Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

$RepoRoot = (Resolve-Path -LiteralPath (
    Join-Path $ScriptDir '..\..\..'
)).Path
$repositoryProfile = Join-Path $RepoRoot `
    'windows\powershell\Microsoft.PowerShell_profile.ps1'

if (-not (Test-Path -LiteralPath $repositoryProfile)) {
    throw "Repository PowerShell profile not found at $repositoryProfile."
}

$escapedProfile = $repositoryProfile.Replace("'", "''")
$sourceLine = ". '$escapedProfile'"

Write-Step 'Configuring the PowerShell profile...'

foreach ($profilePath in Get-PowerShellProfilePaths) {
    Add-LineIfMissing -Path $profilePath -Line $sourceLine
    Write-Info "PowerShell profile configured at $profilePath"
}
