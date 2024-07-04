
Write-Host "Update to latest images"
wsl -e bash /opt/pos-deploy/script_bootstrap/update.sh
Write-Host "Done restarting API Container"

Write-Host "Press any key to continue............"
Write-Host -Object ('The key that was pressed was: {0}' -f [System.Console]::ReadKey().Key.ToString());