# Check to see if we are currently running "as Administrator"

function Verify-Elevated {
    # Get the ID and security principal of the current user account
    $myIdentity=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myPrincipal=new-object System.Security.Principal.WindowsPrincipal($myIdentity)
    # Check to see if we are currently running "as Administrator"
    return $myPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (!(Verify-Elevated)) {
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   $newProcess.Verb = "runas";
   [System.Diagnostics.Process]::Start($newProcess);

   exit
}

function Check-Command($cmdname) {
  return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# -----------------------------------------------------------------------------
# Update help for Modules
Write-Host "Updating Help..." -ForegroundColor "Yellow"
Update-Help -Force


# -----------------------------------------------------------------------------
# Install Chocolatey and some apps
if (Check-Command -cmdname 'scoop') {
  Write-Host "Scoop is already installed, skip installation."
}
else {
  Write-Host ""
  Write-Host "Installing Scoop..." -ForegroundColor Green
  Write-Host "------------------------------------" -ForegroundColor Green
  Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

Write-Host ""
Write-Host "Installing Applications..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Refresh-Environment

# Default to latest Node.js LTS
nvm on
nvm install lts
nvm use lts


Write-Host "Installing Node Packages..." -ForegroundColor Green
if (Check-Command -cmdname 'npm') {
    npm install -g pnpm
    npm install -g rimraf
    npm install -g serve
    npm update npm
}

# -----------------------------------------------------------------------------
# Install modules
Write-Host "Installing PowerShell Modules..." -ForegroundColor Green
if (!(Get-PackageProvider NuGet -Force -ErrorAction SilentlyContinue)) {
    Install-PackageProvider NuGet -Force
}

if ((Get-PSRepository PSGallery -ErrorAction SilentlyContinue).InstallationPolicy -ne 'Trusted') {
    Set-PSRepository PSGallery -InstallationPolicy Trusted
}
Install-Module -AllowClobber Get-ChildItemColor
#Install-Module Oh-My-Posh -Scope CurrentUser -Force
#Install-Module Posh-Git -Scope CurrentUser -Force
Install-Module PSWindowsUpdate -Scope CurrentUser -Force
#Install-Module -Name Emojis -Scope CurrentUser -Force
Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck

# -----------------------------------------------------------------------------
# Install dotnet sdk
Write-Host "Installing dotnet SDKs for Windows..." -ForegroundColor Green
powershell -NoProfile -ExecutionPolicy unrestricted -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; &([scriptblock]::Create((Invoke-WebRequest -UseBasicParsing 'https://dot.net/v1/dotnet-install.ps1'))) -Channel LTS"

# -----------------------------------------------------------------------------
# Install WSL
Write-Host ""
Write-Host "Installing WSL..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform

# -----------------------------------------------------------------------------
# Restart Windows
Write-Host "------------------------------------" -ForegroundColor Green
Read-Host -Prompt "Apps Setup is done!"
