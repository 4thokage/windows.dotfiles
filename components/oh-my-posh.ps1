if (((Get-Module -ListAvailable Oh-My-Posh -ErrorAction SilentlyContinue) -ne $null)) {
  Import-Module oh-my-posh
  Set-PoshPrompt -Theme honukai
}