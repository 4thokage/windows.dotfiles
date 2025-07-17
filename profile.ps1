# Profile for Microsoft.PowerShell

Push-Location -ErrorAction Stop

try {
    # Change to profile directory
    Set-Location -Path (Split-Path -Parent $PROFILE) -ErrorAction Stop

    $scripts = @(
      "functions.ps1",
      "aliases.ps1",
      "exports.ps1"
      )

    foreach ($script in $scripts) {
        if (Test-Path $script) {
            # Dot-source the script safely
            . ".\$script"
        }
    }
}
finally {
    # Return to original directory regardless of errors
    Pop-Location
}