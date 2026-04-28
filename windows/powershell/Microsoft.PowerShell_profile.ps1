Invoke-Expression (&starship init powershell)
mise activate pwsh | Out-String | Invoke-Expression

# 1. Enable Vi Mode
Set-PSReadLineOption -EditMode Vi

# 2. Define a function to change the cursor shape based on the mode
function OnViModeChange {
    if ($args[0] -eq 'Command') {
        # Set cursor to a steady Block
        Write-Host -NoNewLine "`e[2 q"
    } else {
        # Set cursor to a blinking Line (Bar)
        Write-Host -NoNewLine "`e[5 q"
    }
}

# 3. Tell PSReadLine to use this function when the mode changes
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $Function:OnViModeChange
