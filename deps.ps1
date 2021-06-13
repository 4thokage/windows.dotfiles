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
Install-Module -Name Emojis -Scope CurrentUser -Force


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

# system and cli
choco install curl                --limit-output
choco install nuget.commandline   --limit-output
choco install webpi               --limit-output
choco install git.install         --limit-output -params '"/GitAndUnixToolsOnPath /NoShellIntegration"'
choco install nvm.portable        --limit-output
choco install python              --limit-output
choco install ruby                --limit-output
choco install k-litecodecpackfull --limit-output

#fonts
choco install jetbrainsmono       --limit-output

# browsers
choco install Brave               --limit-output; <# pin; evergreen #> choco pin add --name Brave               --limit-output
choco install GoogleChrome.Canary --limit-output; <# pin; evergreen #> choco pin add --name GoogleChrome.Canary --limit-output
choco install Firefox             --limit-output; <# pin; evergreen #> choco pin add --name Firefox             --limit-output
choco install Opera               --limit-output; <# pin; evergreen #> choco pin add --name Opera               --limit-output

# dev tools and frameworks
choco install vscodium                 --limit-output; <# pin; evergreen #> choco pin add --name VSCodium            --limit-output
choco install intellijidea-ultimate    --limit-output; <# pin; evergreen #> choco pin add --name intellij            --limit-output
choco install neovim                   --limit-output
choco install insomnia-rest-api-client --limit-output
choco install keypirinha               --limit-output
choco install Fiddler                  --limit-output
choco install sumatrapdf.portable      --limit-output
choco install sharex                   --limit-output
choco install kdenlive                 --limit-output
choco install autohotkey.portable      --limit-output
choco install treesizefree             --limit-output
choco install winscp.portable          --limit-output

Refresh-Environment

nvm on
$nodeLtsVersion = choco search nodejs-lts --limit-output | ConvertFrom-String -TemplateContent "{Name:package-name}\|{Version:1.11.1}" | Select -ExpandProperty "Version"
nvm install $nodeLtsVersion
nvm use $nodeLtsVersion
Remove-Variable nodeLtsVersion

gem pristine --all --env-shebang

Write-Host "Installing Node Packages..." -ForegroundColor "Yellow"
if (which npm) {
    npm update npm
}