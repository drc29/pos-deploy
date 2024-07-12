Write-Host "Getting printer busid"
$printerBusId= ( usbipd list | Select-String -Pattern "0fe6:811e"   | % { $_.Line.split(" ") | select -first 1 })
Write-Host "Printer Busid: $printerBusId"
Write-Host "Binding and Attaching printer to WSL"
Write-Host "Binding....."
usbipd bind --busid=$printerBusId
Write-Host "Attaching....."
usbipd attach --wsl --busid=$printerBusId
Write-Host "Done binding and attaching printer to WSL" 

Write-Host "Restarting API Container"
wsl -e docker restart pos-api
Write-Host "Done restarting API Container"