# pos-deploy
# Automated installation

- Clone this repository
- Run as Administrator the powershell cli
- Go to the cloned repository directory and go to script/script_bootstrap folder
- Run the pos-install.ps1
- First run will requre you to restart the machine since you will be enabling the hyper-v
- After restart go again to the cloned repository directory and go to script folder
- (everytime you run the powersheel script)Run this `Set-ExecutionPolicy -ExecutionPolicy Unrestricted` to execute the powershell script 
- Then run the pos-install.ps1 again
- It will ask for the docker credentials, please refer on your password manager
- Wait till the installation is complete
- (everytime after you run the powersheel script)Run this `Set-ExecutionPolicy -ExecutionPolicy Restricted` after execute the powershell script

pos-install.ps1 -> this will install all necessary files on the machine, it must run on windows powershell cli
pos-update.ps1 -> this will update the docker images, it must run on windows powershell cli manually, it can also be schedule daily just follow the steps on this site: https://www.backup4all.com/how-to-create-a-new-task-using-windows-task-scheduler-kb.html
pos-start.ps1 -> this needs to add on the windows startup so the wsl will run automatically
pos-printer-reattach.ps1 -> this will reattach the printer to the wsl and restart the container, need to be run manually.

install_pos.sh -> for installation of pos system on the wsl
update_pos.sh -> updating docker images and pos on the wsl




