param (
    [string]$ComputerName,             # Optional: New name for the PC
    [switch]$Windows,                  # Optional: Run Windows system configuration
    [switch]$Apps,                     # Optional: Install developer toolbox apps
    [switch]$Debloat                   # Optional: Call a remote debloater script - https://github.com/Raphire/Win11Debloat
)

#$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
#$ProfileDir = Split-Path -Parent $PROFILE
#$ComponentDir = Join-Path $ProfileDir "components"

if ($ComputerName) {
    Write-Host "Renaming PC to '$ComputerName'..." -ForegroundColor Yellow
    try {
        Rename-Computer -NewName $ComputerName -Force -ErrorAction Stop
        Write-Host "Computer renamed successfully. A restart may be required." -ForegroundColor Green
    } catch {
        Write-Host "Failed to rename computer: $_" -ForegroundColor Red
    }
}

if ($Debloat) {
    Write-Host "Fetching and executing remote debloater script..." -ForegroundColor Magenta
    try {
        & ([scriptblock]::Create((irm "https://debloat.raphi.re/")))  # Caution: Trust the source!
    } catch {
        Write-Host "Failed to fetch or run remote debloater: $_" -ForegroundColor Red
    }
}