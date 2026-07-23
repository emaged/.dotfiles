if (
    (Get-Command mise -ErrorAction SilentlyContinue) -and
    -not [Environment]::GetEnvironmentVariable('MISE_SHELL')
) {
    (& mise activate pwsh) | Out-String | Invoke-Expression
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& {
        zoxide init powershell --cmd cd | Out-String
    })
}

$completionDirectory = Join-Path $HOME `
    '.local\share\powershell\completions'

foreach ($completion in 'codex.ps1', 'juliaup.ps1') {
    $completionPath = Join-Path $completionDirectory $completion

    if (Test-Path -LiteralPath $completionPath) {
        . $completionPath
    }
}

if (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue) {
    Set-PSReadLineOption -EditMode Vi

    $psReadLineCommand = Get-Command Set-PSReadLineOption

    if ($psReadLineCommand.Parameters.ContainsKey('ViModeChangeHandler')) {
        function OnViModeChange {
            if ($args[0] -eq 'Command') {
                Write-Host -NoNewLine "`e[2 q"
            } else {
                Write-Host -NoNewLine "`e[5 q"
            }
        }

        Set-PSReadLineOption `
            -ViModeIndicator Script `
            -ViModeChangeHandler $Function:OnViModeChange
    }
}

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
