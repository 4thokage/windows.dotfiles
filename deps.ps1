# Check to see if we are currently running "as Administrator"
if (!(Verify-Elevated)) {
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   $newProcess.Verb = "runas";
   [System.Diagnostics.Process]::Start($newProcess);

   exit
}


### Update Help for Modules
Write-Host "Updating Help..." -ForegroundColor "Yellow"
Update-Help -Force


### Package Providers
Write-Host "Installing Package Providers..." -ForegroundColor "Yellow"
Get-PackageProvider NuGet -Force | Out-Null


### Install PowerShell Modules
Write-Host "Installing PowerShell Modules..." -ForegroundColor "Yellow"
Install-Module Posh-Git -Scope CurrentUser -Force
Install-Module PSWindowsUpdate -Scope CurrentUser -Force


### Chocolatey
Write-Host "Installing Desktop Utilities..." -ForegroundColor "Yellow"

# system and cli
winget install -e --id Microsoft.webpicmd
winget install -e --id Microsoft.NuGet
winget install -e --id Python.Python

# winget install -e --id RubyInstallerTeam.Ruby
# winget install -e --id Nodist.Nodist

# browsers
winget install -e --id Google.Chrome
winget install -e --id BraveSoftware.BraveBrowser


# dev tools and frameworks
winget install -e --id JetBrains.IntelliJIDEA.Ultimate
winget install -e --id VSCodium.VSCodium
winget install -e --id Telerik.Fiddler
winget install -e --id Insomnia.Insomnia


Refresh-Environment