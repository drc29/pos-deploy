<#
- BIOS of host machine also needs to be configured to allow hardware virtualization
- Windows 10 Pro or otherwise is needed; Windows 10 Home Edition CANNOT get WSL
- This gist WSLv2, but can use WSLv1 instead. I needed v1 as I run Windows 10 in a VM in Virtualbox.
- WSLv2 has been giving me problems in Virtualbox 6.1, but WSLv1 works properly.
- vbox has issues with the GUI settings when it comes to nested virtualization on certain systems,
  so run the following if needing to give a VM this enabled setting:
  VBoxManage modifyvm <vm-name> --nested-hw-virt on
#>

## IN AN ELEVATED SHELL
## Right-click PowerShell -> Run As Administrator

# Enable Needed Virtualization
Write-Host "Enable Virtualization"
Write-Host "Enabling WSL"
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
Start-Sleep -Seconds 3;
Write-Host "Done WSL"

Write-Host "Enabling Virtual Machine Platform"
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
Start-Sleep -Seconds 3;
Write-Host "DoneVirtual Machine Platform"

Write-Host "Enabling Microsoft-Hyper-V"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
Start-Sleep -Seconds 3;
Write-Host "Done Microsoft-Hyper-V"
Write-Host "Done Enabling Virtualization"


Write-Host "Updating WSL and Setting it to version 2 as default"
wsl --update # Update wsl
Write-Host "Done updating wsl"
Write-Host "Change default version to v2"
wsl --set-default-version 2 # Change to '1' if not able to support 2
Write-Host "Finished setting it to v2"
Start-Sleep -Seconds 5;

<#
- Install Ubunut22.04
- For the next command, when prompted
- Input desired username: pos
- Input alphanumeric password: posadmin
#>

Write-Host "Downloading Ubuntu v24.04"
Invoke-WebRequest -Uri https://cloud-images.ubuntu.com/wsl/releases/24.04/current/ubuntu-noble-wsl-amd64-wsl.rootfs.tar.gz -OutFile $ENV:HOMEDRIVE$ENV:HOMEPATH\Downloads\ubuntu-24.04-wsl.tar.gz -UseBasicParsing
$ubuntu = "$ENV:HOMEDRIVE$ENV:HOMEPATH\Downloads\ubuntu-24.04-wsl.tar.gz"
Write-Host "Finished Downloading Ubuntu-24.04"

Write-Host "Creating POS Directory"
mkdir c:\KyzenPOS
Write-Host "Finished Creating Directory"
wsl.exe --import Ubuntu-KyzenPOS C:\KyzenPOS $ubuntu
Start-Sleep -Seconds 5;
Write-Host "Done install Ubuntu-24.04"

Write-Host "Update distro"
wsl -e apt-get update
Write-Host "Done Updating Distro"


<#
- Update disto
- Install necessary dependencies
- Install docker and docker compose
#>


# Write-Host "installing USBIPD"
Invoke-WebRequest -Uri https://github.com/dorssel/usbipd-win/releases/download/v4.2.0/usbipd-win_4.2.0.msi -OutFile $ENV:HOMEDRIVE$ENV:HOMEPATH\Downloads\usbipd-win_4.2.0.msi  -UseBasicParsing
$usbipd = "$ENV:HOMEDRIVE$ENV:HOMEPATH\Downloads\usbipd-win_4.2.0.msi"
Start-Process msiexec "/i $usbipd /qn";
Write-Host "Done USBIPD"
Start-Sleep -Seconds 3;

# Start WSL Ubuntu
Write-Host "Starting KyzenPos Server"
wsl -d Ubuntu-KyzenPOS --exec dbus-launch true
Write-Host "Done starting KyzenPos Server"

Write-Host "Getting printer busid"
$printerBusId= ( usbipd list | Select-String -Pattern "Receipt"   | % { $_.Line.split(" ") | select -first 1 })
Write-Host "Printer Busid: $printerBusId"
Write-Host "Binding and Attaching printer to WSL"
Write-Host "Binding....."
usbipd bind --busid=$printerBusId
Write-Host "Attaching....."
usbipd attach --wsl --busid=$printerBusId
Write-Host "Done binding and attaching printer to WSL" 

Write-Host "Cloning Deployment repo..."
wsl -e rm -rf /opt/pos-deploy
wsl -e git clone https://github.com/drc29/pos-deploy.git /opt/pos-deploy
Write-Host "Cloning done..."

Write-Host "Running First Deployment..."
wsl -e bash /opt/pos-deploy/script_bootstrap/install.sh
Write-Host "Deployment done..."

Write-Host "Testing printer"
wsl -e docker exec pos-api python printer.py
Write-Host "Deployment done..."



Write-Host "Press any key to continue............"
Write-Host -Object ('The key that was pressed was: {0}' -f [System.Console]::ReadKey().Key.ToString());
