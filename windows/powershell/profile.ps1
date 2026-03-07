Import-Module PSReadLine
Import-Module PSFzf
Import-Module Terminal-Icons

# PSReadLine — autosuggestions + syntax highlighting
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# PSFzf — Ctrl+R history search, Ctrl+T file picker
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' `
                -PSReadlineChordReverseHistory 'Ctrl+r'

# Zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Starship
Invoke-Expression (&starship init powershell)

# Aliases
Set-Alias ls  eza
Set-Alias cat bat
Set-Alias grep rg
function ll { eza -lah --icons @args }
