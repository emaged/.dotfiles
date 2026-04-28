Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

function Ensure-Mise {
    if (Test-Command mise) {
        Write-Info 'mise already installed'
        return
    }

    Ensure-Scoop

    try {
        Install-ScoopPackage -Package 'mise' -Name 'mise'
    } catch {
        Write-Warning 'Scoop install for mise failed, falling back to winget.'
        Install-WingetPackage -Id 'jdx.mise' -Name 'mise'
    }

    if (-not (Test-Command mise)) {
        throw 'mise installation failed.'
    }
}

function Enable-MiseForPowerShell {
    $activationLine = '(& mise activate pwsh) | Out-String | Invoke-Expression'

    foreach ($profilePath in Get-PowerShellProfilePaths) {
        Add-LineIfMissing -Path $profilePath -Line $activationLine
    }

    & mise activate pwsh | Out-String | Invoke-Expression
}

Ensure-Mise

Write-Step 'Configuring mise activation for PowerShell...'
Enable-MiseForPowerShell

Write-Info 'mise available for installation...'
