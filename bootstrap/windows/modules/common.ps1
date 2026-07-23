Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Step {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "==> $Message"
}

function Write-Info {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host $Message
}

function Refresh-Path {
    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machinePath;$userPath"
}

function Test-Command {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Ensure-Directory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Add-LineIfMissing {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Line
    )

    $directory = Split-Path -Parent $Path
    if ($directory) {
        Ensure-Directory -Path $directory
    }

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType File -Path $Path -Force | Out-Null
    }

    $content = Get-Content -LiteralPath $Path -Raw
    if ($null -eq $content) {
        $content = ''
    }

    if ($content -match [regex]::Escape($Line)) {
        return
    }

    if ($content.Length -gt 0 -and -not $content.EndsWith("`n")) {
        Add-Content -LiteralPath $Path -Value ''
    }

    Add-Content -LiteralPath $Path -Value $Line
}

function Get-PowerShellProfilePaths {
    $documents = [Environment]::GetFolderPath(
        [Environment+SpecialFolder]::MyDocuments
    )

    return @(
        (Join-Path $documents 'PowerShell\Profile.ps1')
    )
}

function Assert-NativeCommandSucceeded {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Description,
        [Parameter(Mandatory = $true)]
        [int]$ExitCode,
        [int[]]$AllowedExitCodes = @(0)
    )

    if ($AllowedExitCodes -notcontains $ExitCode) {
        throw "$Description failed with exit code $ExitCode."
    }
}

function Ensure-Winget {
    if (Test-Command winget) {
        return
    }

    Write-Step 'Registering App Installer so winget is available...'
    Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
    Refresh-Path

    if (-not (Test-Command winget)) {
        throw 'winget is unavailable. Install or repair App Installer, then rerun this bootstrap.'
    }
}

function Install-WingetPackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id,
        [string]$Name = $Id,
        [string]$Source = ''
    )

    Ensure-Winget
    Write-Step "Installing $Name via winget..."

    $arguments = @(
        'install',
        '--id', $Id,
        '-e',
        '--accept-package-agreements',
        '--accept-source-agreements',
        '--disable-interactivity'
    )

    if ($Source) {
        $arguments += @('--source', $Source)
    } else {
        $arguments += '--silent'
    }

    & winget @arguments
    Assert-NativeCommandSucceeded `
        -Description "WinGet installation of $Name" `
        -ExitCode $LASTEXITCODE `
        -AllowedExitCodes @(
            0,
            -1978335189, # No applicable update found
            -1978335135, # Package already installed
            -1978334963  # Another version is already installed
        )
    Refresh-Path
}

function Ensure-Scoop {
    if (Test-Command scoop) {
        return
    }

    Write-Step 'Installing Scoop...'
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
    Refresh-Path

    if (-not (Test-Command scoop)) {
        throw 'Scoop installation failed.'
    }
}

function Ensure-ScoopBucket {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    Ensure-Scoop
    $bucketList = & scoop bucket list 2>$null
    if ($bucketList -match "(?m)^$([regex]::Escape($Name))\s") {
        return
    }

    Write-Step "Adding Scoop bucket $Name..."
    & scoop bucket add $Name
    Assert-NativeCommandSucceeded `
        -Description "Adding Scoop bucket $Name" `
        -ExitCode $LASTEXITCODE
}

function Get-ScoopAppName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Package
    )

    if ($Package.Contains('/')) {
        return ($Package.Split('/')[-1])
    }

    return $Package
}

function Install-ScoopPackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Package,
        [string]$Name = $Package
    )

    Ensure-Scoop
    $appName = Get-ScoopAppName -Package $Package
    $installed = & scoop list $appName 2>$null

    if ($LASTEXITCODE -eq 0 -and $installed) {
        Write-Info "$Name already installed"
        return
    }

    Write-Step "Installing $Name via Scoop..."
    & scoop install $Package
    Assert-NativeCommandSucceeded `
        -Description "Scoop installation of $Name" `
        -ExitCode $LASTEXITCODE
    Refresh-Path
}
