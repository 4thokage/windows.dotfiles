param (
    [string]$ComputerName,                        # Optional: New name for the PC
    [switch]$Apps,                     
    [switch]$Debloat,                  
    [switch]$Force,                               # Skip confirmations for automation
    [string]$LogFile = "$env:TEMP\bootstrap.log"  # Logs in AppData TEMP
)

$ScriptFailed = $false

function Log {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $LogFile -Append
    Write-Host $Message
}

# Validate computer name
if ($ComputerName) {
    if ($ComputerName.Length -gt 15 -or $ComputerName -match '[^a-zA-Z0-9\-]') {
        Write-Host "Invalid computer name: Only letters, numbers, and dashes allowed, max 15 characters." -ForegroundColor Red
        Log "Invalid computer name specified: $ComputerName"
        exit 1
    }
}

# Rename Computer
if ($ComputerName) {
    Write-Host "Renaming PC to '$ComputerName'..." -ForegroundColor Yellow
    Log "Renaming PC to '$ComputerName'"
    try {
        Rename-Computer -NewName $ComputerName -Force -ErrorAction Stop
        Write-Host "Computer renamed successfully. A restart may be required." -ForegroundColor Green
        Log "Computer renamed successfully"
    } catch {
        Write-Host "Failed to rename computer: $_" -ForegroundColor Red
        Log "Failed to rename computer: $_"
        $ScriptFailed = $true
    }
}

# Run Windows configuration (placeholder)
if ($Windows) {
    Write-Host "Windows system configuration requested (not implemented)." -ForegroundColor Cyan
    Log "Windows system configuration requested (not implemented)"
}

# Install Apps (placeholder)
if ($Apps) {
    Write-Host "Developer toolbox app installation requested (not implemented)." -ForegroundColor Cyan
    Log "App installation requested (not implemented)"
}

# Run remote debloater
if ($Debloat) {
    Write-Host "Preparing to run remote debloater script..." -ForegroundColor Magenta
    Log "Remote debloater requested"

    if (-not $Force) {
        $confirm = Read-Host "This will execute code from https://debloat.raphi.re/. Continue? (Y/N)"
        if ($confirm -ne 'Y') {
            Write-Host "Remote debloat aborted by user." -ForegroundColor Yellow
            Log "Remote debloat aborted by user"
            if ($ScriptFailed) { exit 1 } else { exit 0 }
        }
    } else {
        Write-Host "Running remote debloater without confirmation (force mode)." -ForegroundColor Magenta
        Log "Running remote debloater (force mode)"
    }

    try {
        # The remote script may also prompt interactively
        # This assumes it supports silent mode; if not, it needs patching
        & ([scriptblock]::Create((irm "https://debloat.raphi.re/"))) -Force:$Force
        Write-Host "Remote debloater executed successfully." -ForegroundColor Green
        Log "Remote debloater executed successfully"
    } catch {
        Write-Host "Failed to fetch or run remote debloater: $_" -ForegroundColor Red
        Log "Failed to run remote debloater: $_"
        $ScriptFailed = $true
    }
}

# Final status and exit
if ($ScriptFailed) {
    Write-Host "Script completed with errors. See log: $LogFile" -ForegroundColor Red
    Log "Script completed with errors"
    exit 1
} else {
    Write-Host "Script completed successfully. See log: $LogFile" -ForegroundColor Green
    Log "Script completed successfully"
    exit 0
}
