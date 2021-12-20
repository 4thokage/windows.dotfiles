# Check to see if we are currently running "as Administrator"
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
if (Check-Command -cmdname 'choco') {
  Write-Host "Choco is already installed, skip installation."
}
else {
  Write-Host ""
  Write-Host "Installing Chocolatey for Windows..." -ForegroundColor Green
  Write-Host "------------------------------------" -ForegroundColor Green
  Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

}

Write-Host ""
Write-Host "Installing Applications..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Refresh-Environment
choco feature enable -n=allowGlobalConfirmation

## system and cli
# git
if (Check-Command -cmdname 'git') {
  Write-Host "Git is already installed, checking new version..."
  choco update git -y
}
else {
  Write-Host ""
  Write-Host "Installing Git for Windows..." -ForegroundColor Green
  choco install git              --limit-output -params '"/GitAndUnixToolsOnPath /NoShellIntegration /NoAutoCrlf /SChannel /WindowsTerminal"'
}
# nodejs
if (Check-Command -cmdname 'node') {
  Write-Host "NVM is already installed, checking new version..."
  choco update nvm.portable        --limit-output
}
else {
  Write-Host ""
  Write-Host "Installing nvm for nodejs..." -ForegroundColor Green
  choco install nvm.portable        --limit-output
}

# Python & ruby
if (Check-Command -cmdname 'py') {
  choco update python              --limit-output

}
else {
  Write-Host ""
  Write-Host "Installing Python 3..." -ForegroundColor Green
  choco install python        --limit-output
}
if (Check-Command -cmdname 'gem') {
  choco update ruby                --limit-output
}
else {
  Write-Host ""
  Write-Host "Installing Ruby..." -ForegroundColor Green
  choco install ruby          --limit-output
}

choco install curl                --limit-output
choco install k-litecodecpackfull --limit-output
choco install ffmpeg              --limit-output
choco install youtube-dl          --limit-output
choco install jetbrainsmono       --limit-output

choco install microsoft-windows-terminal  --limit-output

# browsers
choco install Firefox             --limit-output; <# pin; evergreen #> choco pin add --name Firefox             --limit-output
choco install Brave               --limit-output; <# pin; evergreen #> choco pin add --name Brave               --limit-output
# choco install GoogleChrome.Canary --limit-output; <# pin; evergreen #> choco pin add --name GoogleChrome.Canary --limit-output
# choco install Opera               --limit-output; <# pin; evergreen #> choco pin add --name Opera               --limit-output

# dev tools and frameworks
choco install vscodium                 --limit-output; <# pin; evergreen #> choco pin add --name VSCodium            --limit-output
choco install intellijidea-ultimate    --limit-output; <# pin; evergreen #> choco pin add --name Intellij            --limit-output
choco install neovim                   --limit-output; <# pin; evergreen #> choco pin add --name nvim                --limit-output
choco install insomnia-rest-api-client --limit-output
choco install keypirinha               --limit-output
choco install Fiddler                  --limit-output
choco install sumatrapdf               --limit-output
choco install sharex                   --limit-output
choco install kdenlive                 --limit-output
choco install autohotkey               --limit-output
choco install treesizefree             --limit-output
choco install google-drive-file-stream --limit-output
choco install winscp                   --limit-output
choco install keepass                  --limit-output
choco install unity                    --limit-output


Refresh-Environment

# Default to latest Node.js LTS
nvm on
$nodeLtsVersion = "16.x"
nvm install $nodeLtsVersion
nvm use $nodeLtsVersion
Remove-Variable nodeLtsVersion

gem pristine --all --env-shebang

Write-Host "Installing Node Packages..." -ForegroundColor Green
if (which npm) {
    npm install -g cross-env
    npm install -g yarn
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
Install-Module Oh-My-Posh -Scope CurrentUser -Force
Install-Module Posh-Git -Scope CurrentUser -Force
Install-Module PSWindowsUpdate -Scope CurrentUser -Force
Install-Module -Name Emojis -Scope CurrentUser -Force
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

# VSCodium sync
codium --install-extension Shan.code-settings-sync

# -----------------------------------------------------------------------------
# Restart Windows
Write-Host "------------------------------------" -ForegroundColor Green
Read-Host -Prompt "Setup is done, restart is needed, press [ENTER] to restart computer."
Restart-Computer
