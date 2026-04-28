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

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
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
    return @(
        (Join-Path $HOME 'Documents\WindowsPowerShell\profile.ps1'),
        (Join-Path $HOME 'Documents\PowerShell\Profile.ps1')
    )
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
        [string]$Source = '',
        [string]$Override = ''
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
    } elseif (-not $Override) {
        $arguments += '--silent'
    }

    if ($Override) {
        $arguments += @('--override', $Override)
    }

    & winget @arguments
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
    Refresh-Path
}

function Ensure-Chocolatey {
    if (Test-Command choco) {
        return $true
    }

    if (-not (Test-IsAdmin)) {
        Write-Warning 'Skipping Chocolatey because this session is not elevated.'
        return $false
    }

    Write-Step 'Installing Chocolatey...'
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Refresh-Path

    if (-not (Test-Command choco)) {
        throw 'Chocolatey installation failed.'
    }

    return $true
}

function Install-ChocoPackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Package,
        [string]$Name = $Package
    )

    if (-not (Ensure-Chocolatey)) {
        return
    }

    Write-Step "Installing $Name via Chocolatey..."
    & choco install $Package -y --no-progress
    Refresh-Path
}
