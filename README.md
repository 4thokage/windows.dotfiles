# Windows Dotfiles

A collection of PowerShell scripts to automate the setup and customization of a Windows development environment, including common app installation via Scoop and Windows configuration tweaks.

## Prerequisites

- PowerShell 5.1 or higher
- Git (if using Git installation method)
- Administrator privileges to install software and modify system settings

## Installation

### Using Git and the bootstrap script

From PowerShell:
```powershell
git clone https://github.com/4thokage/windows.dotfiles.git
cd windows.dotfiles
. .\bootstrap.ps1 [-Debloat , -Apps, (-Force)] -ComputerName "Cheons"
```
> "-Apps" will install applications with chocolatey (scripts/apps.ps1)

To update your settings, `cd` into your local `windows.dotfiles` repository within PowerShell and then:

```powershell
. .\bootstrap.ps1
```

### Git-free install

> **Note:** You must have your execution policy set to unrestricted (or at least in bypass) for this to work. To set this, run `Set-ExecutionPolicy Unrestricted` from a PowerShell running as Administrator.

To install these dotfiles from PowerShell without Git:

```bash
iex ((new-object net.webclient).DownloadString('https://github.com/4thokage/windows.dotfiles/main/setup/install.ps1'))
```

To update later on, just run that command again.
