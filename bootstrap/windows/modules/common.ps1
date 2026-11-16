Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
# Native commands are checked explicitly, including expected nonzero inventory results.
$PSNativeCommandUseErrorActionPreference = $false

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
    $seen = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $paths = foreach ($entry in ("$env:Path;$machinePath;$userPath" -split ';')) {
        if ($entry -and $seen.Add($entry)) { $entry }
    }
    $env:Path = $paths -join ';'
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

    if (($content -split '\r?\n') -contains $Line) {
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
        [string]$Source = 'winget'
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

    $arguments += @('--source', $Source)
    if ($Source -ne 'msstore') { $arguments += '--silent' }

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
    $bucketList = @(& scoop bucket list)
    Assert-NativeCommandSucceeded -Description 'Listing Scoop buckets' -ExitCode $LASTEXITCODE -AllowedExitCodes @(0, 2)
    if ($bucketList | Where-Object { $_.Name -eq $Name }) { return }

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
    $installed = @(& scoop list "^$([regex]::Escape($appName))$")
    Assert-NativeCommandSucceeded -Description 'Listing Scoop applications' -ExitCode $LASTEXITCODE -AllowedExitCodes @(0, 1)
    $matching = @($installed | Where-Object { $_.Name -eq $appName })
    if ($matching | Where-Object { $_.Info -match 'Install failed' }) {
        throw "Scoop has a failed installation of $appName. Repair it before rerunning bootstrap."
    }
    if ($matching.Count -gt 0) {
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


function Read-PackageList {
    param([Parameter(Mandatory = $true)][string]$Name)
    $path = Join-Path (Join-Path $PSScriptRoot '..\packages') "$Name.txt"
    $packages = @(Get-Content -LiteralPath $path | ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and -not $_.StartsWith('#') })
    if ($packages.Count -eq 0 -or ($packages -match '\s')) {
        throw "Empty or invalid package list: $path"
    }
    return $packages
}

function Ensure-MiseTool {
    param([Parameter(Mandatory = $true)][string]$Tool, [string]$Version = 'latest')
    $inventory = & mise -C $HOME ls --current $Tool --json
    Assert-NativeCommandSucceeded -Description "Inspecting mise $Tool" -ExitCode $LASTEXITCODE
    $configured = @($inventory | ConvertFrom-Json)
    if ($configured.Count -gt 0) {
        & mise -C $HOME where $Tool *> $null
        if ($LASTEXITCODE -eq 0) { return }
        & mise -C $HOME install $Tool
    } else {
        & mise -C $HOME use -g "$Tool@$Version"
    }
    Assert-NativeCommandSucceeded -Description "Installing mise $Tool" -ExitCode $LASTEXITCODE
}

function Ensure-UserNpmPrefix {
    $prefix = & mise -C $HOME exec node -- npm prefix -g
    Assert-NativeCommandSucceeded -Description 'Reading npm prefix' -ExitCode $LASTEXITCODE
    $prefix = [IO.Path]::GetFullPath(($prefix | Out-String).Trim())
    $userRoot = [IO.Path]::GetFullPath($HOME).TrimEnd('\') + '\'
    if (-not $prefix.StartsWith($userRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw "npm prefix $prefix is outside your home directory. Select a user-owned npm prefix before continuing."
    }
    $env:Path = "$prefix;$env:Path"
}

function Assert-MsvcBuildTools {
    $programFiles = ${env:ProgramFiles(x86)}
    if (-not $programFiles) { throw 'Windows with Visual Studio C++ Build Tools is required for Cargo builds.' }
    $vswhere = Join-Path $programFiles 'Microsoft Visual Studio\Installer\vswhere.exe'
    $installation = $null
    if (Test-Path -LiteralPath $vswhere) {
        $installation = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
        Assert-NativeCommandSucceeded -Description 'Finding MSVC build tools' -ExitCode $LASTEXITCODE
    }
    $sdkRoot = Join-Path $programFiles 'Windows Kits\10\Lib'
    $sdk = @(Get-ChildItem -Path "$sdkRoot\*\ucrt\x64\ucrt.lib" -ErrorAction SilentlyContinue)
    if (-not $installation -or $sdk.Count -eq 0) {
        throw 'Cargo builds require Visual Studio C++ Build Tools and a Windows SDK. Install the Desktop development with C++ workload, then rerun. See bootstrap/README.md.'
    }
}
