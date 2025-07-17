# Make vim the default editor
$env:EDITOR = "nvim"
$env:GIT_EDITOR = $env:EDITOR

# Complete from history when typing some text and press Up arrow
Set-PSReadlineKeyHandler -Chord UpArrow -Function HistorySearchBackward
# More sensible tab completion
Set-PSReadlineKeyHandler -Key Tab -Function Complete

$env:PYTHONIOENCODING="utf-8"
$env:POWERSHELL_TELEMETRY_OPTOUT = 'yes';

# Disable the Progress Bar
$ProgressPreference='SilentlyContinue'