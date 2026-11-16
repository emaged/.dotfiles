#requires -Version 5.1
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$List,
    [switch]$Help,
    [Parameter(Position = 0)][string[]]$Modules = @()
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$RootDir = $PSScriptRoot
$ModuleDir = Join-Path $RootDir 'modules'
. (Join-Path $ModuleDir 'common.ps1')

$defaultModules = @('prerequisites', 'shell', 'dev-tools', 'mise', 'uv', 'pipx', 'cargo_packages', 'node', 'julia', 'neovim', 'opencode', 'starship', 'yazi', 'firefox', 'brave', 'vlc', 'profile')
$dependencies = @{
    'dev-tools' = @('prerequisites'); mise = @('prerequisites'); pipx = @('mise'); cargo_packages = @('dev-tools')
    node = @('mise'); neovim = @('dev-tools', 'mise', 'node', 'pipx'); opencode = @('node')
    yazi = @('dev-tools'); profile = @('mise', 'starship')
}
if ($Help) {
    Write-Host 'Usage: .\windows\install.ps1 [-DryRun] [-Modules node,yazi] [-List]'
    Write-Host 'Without module names, installs the default set. Dependencies are included automatically.'
    return
}
if ($List) { $defaultModules; return }
if ($Modules.Count -eq 0) { $Modules = $defaultModules }
$Modules = @($Modules | ForEach-Object { $_ -replace '\.ps1$', '' })
foreach ($module in $Modules) {
    if ($defaultModules -notcontains $module) { throw "Unknown module: $module (use -List)" }
}
$plan = [Collections.Generic.List[string]]::new()
$visiting = [Collections.Generic.HashSet[string]]::new()
function Add-Module {
    param([string]$Name)
    if ($plan.Contains($Name)) { return }
    if (-not $visiting.Add($Name)) { throw "Cyclic dependency: $Name" }
    if ($dependencies.ContainsKey($Name)) {
        foreach ($dependency in $dependencies[$Name]) { Add-Module $dependency }
    }
    if (-not (Test-Path -LiteralPath (Join-Path $ModuleDir "$Name.ps1"))) { throw "Missing module: $Name" }
    $null = $visiting.Remove($Name)
    $plan.Add($Name)
}
foreach ($module in $Modules) { Add-Module $module }
Write-Host 'Windows bootstrap module order:'
foreach ($module in $plan) { Write-Host "  $module" }
if ($DryRun) {
    Write-Host 'Preview only: no modules, package checks or downloads were run.'
    return
}
if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) { throw 'This installer requires Windows 11.' }
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run from a normal PowerShell session; individual installers request elevation as needed. Scoop is per-user.'
}
if ($plan.Contains('cargo_packages')) { Assert-MsvcBuildTools }
Ensure-Winget
Push-Location $HOME
try {
    foreach ($module in $plan) {
        Write-Step $module
        try { & (Join-Path $ModuleDir "$module.ps1") }
        catch { throw "Module $module failed: $_" }
    }
} finally { Pop-Location }
Write-Host 'Bootstrap complete.'
