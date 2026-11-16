#requires -Version 5.1
# Dependency-free checks: parsing, previews and mocked helpers. No installers run.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$failures = [Collections.Generic.List[string]]::new()
function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { $failures.Add($Message) }
}

foreach ($file in Get-ChildItem (Join-Path $root 'windows') -Filter '*.ps1' -Recurse) {
    $tokens = $null
    $errors = $null
    $null = [Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors)
    foreach ($error in $errors) { $failures.Add("$($file.Name): $error") }
}

# If a preview accidentally reaches a package manager, fail instead of executing it.
function winget { throw 'Preview called winget' }
function scoop { throw 'Preview called scoop' }
function mise { throw 'Preview called mise' }
& (Join-Path $root 'windows/install.ps1') -DryRun -Modules node
& (Join-Path $root 'windows/install.ps1') -Help
$available = @(& (Join-Path $root 'windows/install.ps1') -List)
Assert-True ($available -contains 'node') 'Module listing omitted node'
$rejected = $false
try { & (Join-Path $root 'windows/install.ps1') -DryRun -Modules '../install' }
catch { $rejected = $true }
Assert-True $rejected 'Invalid module selection was accepted'

. (Join-Path $root 'windows/modules/common.ps1')
$script:calls = [Collections.Generic.List[string]]::new()
function scoop {
    $script:calls.Add(($args -join ' '))
    $global:LASTEXITCODE = 0
    if ($args[0] -eq 'bucket' -and $args[1] -eq 'list') {
        [pscustomobject]@{ Name = 'main'; Source = 'test'; Manifests = 1 }
    } elseif ($args[0] -eq 'list') {
        [pscustomobject]@{ Name = 'git'; Version = '1'; Info = '' }
    } elseif ($args[0] -eq 'install') {
        $global:LASTEXITCODE = 9
    } else { throw "Unexpected Scoop mutation: $args" }
}
Ensure-ScoopBucket -Name 'main'
Install-ScoopPackage -Package 'main/git'
Assert-True (-not ($script:calls -match 'bucket add|^install ')) 'Rerun mutated an installed Scoop package/bucket'
$rejected = $false
try { Install-ScoopPackage -Package 'missing' } catch { $rejected = $true }
Assert-True $rejected 'Failed Scoop install was reported as successful'

$oldPath = $env:Path
try {
    $env:Path = 'C:\bootstrap-test-session-path;' + $env:Path
    Refresh-Path
    Assert-True ($env:Path.StartsWith('C:\bootstrap-test-session-path;')) 'Refresh-Path discarded session entries'
} finally { $env:Path = $oldPath }

$script:calls.Clear()
function mise {
    $script:calls.Add(($args -join ' '))
    $global:LASTEXITCODE = 0
    switch ($args[2]) {
        'ls' { '[{"version":"24.0.0","requested_version":"24"}]' }
        'where' { 'C:\test\node' }
        default { throw "Unexpected mise mutation: $args" }
    }
}
Ensure-MiseTool -Tool 'node'
Assert-True (-not ($script:calls -match ' use | install ')) 'Existing mise selection was replaced or upgraded'
Assert-True ((Read-PackageList -Name 'pipx') -contains 'pynvim') 'Python provider missing from package list'

if ($failures.Count -gt 0) { throw ($failures -join "`n") }
Write-Host 'Windows parser, preview and mocked helper checks passed.'
