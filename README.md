# dotfiles for Windows

A collection of PowerShell files for Windows, including common application installation through `chocolatey`. 

## Installation

### Using Git and the bootstrap script

From PowerShell:
```posh
git clone https://github.com/4thokage/windows.dotfiles.git
```
```
cd windows.dotfiles
```
```
. .\bootstrap.ps1 [-Windows , -Apps] -ComputerName "Cheons"
```

To update your settings, `cd` into your local `windows.dotfiles` repository within PowerShell and then:

```posh
. .\bootstrap.ps1
```


### Git-free install

> **Note:** You must have your execution policy set to unrestricted (or at least in bypass) for this to work. To set this, run `Set-ExecutionPolicy Unrestricted` from a PowerShell running as Administrator.

To install these dotfiles from PowerShell without Git:

```bash
iex ((new-object net.webclient).DownloadString('hhttps://github.com/4thokage/windows.dotfiles/main/setup/install.ps1'))
```

To update later on, just run that command again.

### Add custom commands

If `.\extra.ps1` exists, it will be sourced along with the other files. You can use this to add a few custom commands without the need to fork this entire repository, or to add commands you don't want to commit to a public repository.
