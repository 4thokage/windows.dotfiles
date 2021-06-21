# Make vim the default editor
Set-Environment "EDITOR" "nvim"
Set-Environment "GIT_EDITOR" $Env:EDITOR

# Complete from history whe you type some text and press Up arrow
Set-PSReadlineKeyHandler -Chord UpArrow -Function HistorySearchBackward
# More sensible tab completion
Set-PSReadlineKeyHandler -Key Tab -Function Complete

$env:PYTHONIOENCODING="utf-8"
$env:POWERSHELL_TELEMETRY_OPTOUT = 'yes';

# Disable the Progress Bar
$ProgressPreference='SilentlyContinue'
# $ErrorActionPreference = "SilentlyContinue"