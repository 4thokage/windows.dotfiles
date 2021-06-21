param (
    [string]$computerName,
    [switch]$Windows,
    [switch]$Apps
)

$profileDir = Split-Path -parent $profile
$componentDir = Join-Path $profileDir "components"

if($computerName -ne '') {
    Write-Host "Renaming PC..." -ForegroundColor Yellow
    (Get-WmiObject Win32_ComputerSystem).Rename($computerName) | Out-Null
}

New-Item $profileDir -ItemType Directory -Force -ErrorAction SilentlyContinue
New-Item $componentDir -ItemType Directory -Force -ErrorAction SilentlyContinue

Copy-Item -Path ./*.ps1 -Destination $profileDir -Exclude "bootstrap.ps1"
Copy-Item -Path ./components/** -Destination $componentDir -Include **
Copy-Item -Path ./home/** -Destination $home -Include **

Remove-Variable componentDir
Remove-Variable profileDir

if($PSBoundParameters.ContainsKey("Windows")) {
    Write-Host "Spawning windows system configuration script..." -ForegroundColor Yellow
    Invoke-Expression ". .\scripts\windows.ps1"
}
if($PSBoundParameters.ContainsKey("Apps")) {
    Write-Host "Will install dev toolbox apps..." -ForegroundColor Green
    Invoke-Expression ". .\scripts\apps.ps1"
}
