param (
    [string]$ComputerName,                        # Optional: New name for the PC
    [switch]$Apps,
    [switch]$Debloat,
    [switch]$Force,                               # Skip confirmations for automation
    [string]$LogFile = "$env:TEMP\bootstrap.log"  # Logs in AppData TEMP
)

$ScriptFailed = $false
$InformationPreference = 'Continue'

function Log {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $LogFile -Append
    Write-Information $Message
}

#Main setup (powershell profile and home settings)
$profileDir = Split-Path -parent $profile

New-Item $profileDir -ItemType Directory -Force -ErrorAction SilentlyContinue

Copy-Item -Path ./*.ps1 -Destination $profileDir -Exclude "bootstrap.ps1"
Copy-Item -Path ./home/** -Destination $home -Include **

Remove-Variable profileDir

Log "Powershell and home dotfiles synchronized."

# Validate computer name
if ($ComputerName) {
    if ($ComputerName.Length -gt 15 -or $ComputerName -match '[^a-zA-Z0-9\-]') {
        Write-Information "Invalid computer name: Only letters, numbers, and dashes allowed, max 15 characters."
        Log "Invalid computer name specified: $ComputerName"
        exit 1
    }
}

# Rename Computer
if ($ComputerName) {
    Write-Information "Renaming PC to '$ComputerName'..."
    Log "Renaming PC to '$ComputerName'"
    try {
        Rename-Computer -NewName $ComputerName -Force -ErrorAction Stop
        Write-Information "Computer renamed successfully. A restart may be required."
        Log "Computer renamed successfully"
    } catch {
        Write-Information "Failed to rename computer: $_"
        Log "Failed to rename computer: $_"
        $ScriptFailed = $true
    }
}

# Install Apps (placeholder)
if ($Apps) {
    Write-Information "Running developer toolbox app installation script..."
    # Run the apps.ps1 script
    & "./scripts/apps.ps1"
    Log "App installation script executed."
}

# Run remote debloater
if ($Debloat) {
    Write-Information "Preparing to run remote debloater script..."
    Log "Remote debloater requested"

    if (-not $Force) {
        $confirm = Read-Host "This will execute code from https://debloat.raphi.re/. Continue? (Y/N)"
        if ($confirm -ne 'Y') {
            Write-Information "Remote debloat aborted by user."
            Log "Remote debloat aborted by user"
            if ($ScriptFailed) { exit 1 } else { exit 0 }
        }
    } else {
        Write-Information "Running remote debloater without confirmation (force mode)."
        Log "Running remote debloater (force mode)"
    }

    try {
        # The remote script may also prompt interactively
        # This assumes it supports silent mode; if not, it needs patching
        & ([scriptblock]::Create((Invoke-RestMethod "https://debloat.raphi.re/"))) -Force:$Force
        Write-Information "Remote debloater executed successfully."
        Log "Remote debloater executed successfully"
    } catch {
        Write-Information "Failed to fetch or run remote debloater: $_"
        $ScriptFailed = $true
    }
}

# Final status and exit
if ($ScriptFailed) {
    Write-Information "Script completed with errors. See log: $LogFile"
    Log "Script completed with errors"
    exit 1
} else {
    Write-Information "Script completed successfully. See log: $LogFile"
    Log "Script completed successfully"
    exit 0
}
