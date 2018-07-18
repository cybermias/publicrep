$ChocoInstallPath = "$env:SystemDrive\T00LZ\bin"

if (!(Test-Path $ChocoInstallPath)) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

Install-ChocolateyPinnedTaskBarItem $ChocoInstallPath
