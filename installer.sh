#!/bin/bash

# Find the name of the folder the scripts are in
setfont ter-v22b
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo -ne "
-------------------------------------------------------------------------
                    Automated Arch Linux Installer
-------------------------------------------------------------------------
            Scripts are in directory automated-arch-installer
"
    bash scripts/startup.sh
    source $SCRIPT_DIR/setup.conf
    bash scripts/0-preinstall.sh
    arch-chroot /mnt /root/automated-arch-install/scripts/1-setup.sh
    arch-chroot /mnt /usr/bin/runuser -u $USERNAME -- /home/$USERNAME/automated-arch-install/scripts/2-user.sh
    arch-chroot /mnt /root/automated-arch-install/scripts/3-post-setup.sh

echo -ne "
-------------------------------------------------------------------------
                    Automated Arch Linux Installer
-------------------------------------------------------------------------
                Done - Please Eject Install Media and Reboot
"
