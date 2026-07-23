Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

Write-Step 'Installing Julia via juliaup...'
Install-WingetPackage -Id '9NJNWW8PVKMN' -Name 'Julia' -Source 'msstore'

Refresh-Path

if (Test-Command juliaup) {
    & juliaup add release
    Assert-NativeCommandSucceeded `
        -Description 'Installing the Julia release channel' `
        -ExitCode $LASTEXITCODE

    & juliaup default release
    Assert-NativeCommandSucceeded `
        -Description 'Selecting the Julia release channel' `
        -ExitCode $LASTEXITCODE

    Write-Step 'Generating Juliaup PowerShell completions...'

    $completionDirectory = Join-Path $HOME `
        '.local\share\powershell\completions'
    $completionPath = Join-Path $completionDirectory 'juliaup.ps1'

    Ensure-Directory -Path $completionDirectory
    $completionTemporaryPath = [IO.Path]::GetTempFileName()

    try {
        $completion = & juliaup completions power-shell
        Assert-NativeCommandSucceeded `
            -Description 'Generating Juliaup PowerShell completions' `
            -ExitCode $LASTEXITCODE

        $completion |
            Set-Content `
                -LiteralPath $completionTemporaryPath `
                -Encoding utf8
        Move-Item `
            -LiteralPath $completionTemporaryPath `
            -Destination $completionPath `
            -Force

        Write-Info 'Juliaup PowerShell completions generated.'
    } finally {
        if (Test-Path -LiteralPath $completionTemporaryPath) {
            Remove-Item -LiteralPath $completionTemporaryPath -Force
        }
    }

    Write-Info 'Julia installation complete.'
} else {
    Write-Warning 'Julia was handed off to the Microsoft Store. If juliaup is not visible yet, reopen PowerShell after the Store install finishes.'
}
