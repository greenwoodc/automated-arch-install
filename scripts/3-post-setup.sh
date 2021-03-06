#!/usr/bin/env bash
echo -ne "
-------------------------------------------------------------------------
                    Automated Arch Linux Installer
                        SCRIPTHOME: automated-arch-install
-------------------------------------------------------------------------

Final Setup and Configurations
GRUB EFI Bootloader Install & Check
"
source /root/automated-arch-install/setup.conf
genfstab -U / >> /etc/fstab
if [[ -d "/sys/firmware/efi" ]]; then
    grub-install --efi-directory=/boot ${DISK}
fi
# set kernel parameter for decrypting the drive
if [[ "${FS}" == "luks" ]]; then
sed -i "s%GRUB_CMDLINE_LINUX_DEFAULT=\"%GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=UUID=${encryped_partition_uuid}:ROOT root=/dev/mapper/ROOT %g" /etc/default/grub
fi

echo -e "Installing CyberRe Grub theme..."
THEME_DIR="/boot/grub/themes"
THEME_NAME=CyberRe
echo -e "Creating the theme directory..."
mkdir -p "${THEME_DIR}/${THEME_NAME}"
echo -e "Copying the theme..."
cd ${HOME}/automated-arch-install
cp -a ${THEME_NAME}/* ${THEME_DIR}/${THEME_NAME}
echo -e "Backing up Grub config..."
cp -an /etc/default/grub /etc/default/grub.bak
echo -e "Setting the theme as the default..."
grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sed -i '/GRUB_THEME=/d' /etc/default/grub
echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> /etc/default/grub
echo -e "Updating grub..."
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "All set!"

echo -ne "
-------------------------------------------------------------------------
                    Enabling Login Display Manager
-------------------------------------------------------------------------
"
systemctl enable lightdm.service

echo -ne "
-------------------------------------------------------------------------
                    Setting up LightDM Theme
-------------------------------------------------------------------------
"
cd ~
# If you prefer the last stable release, download from the releases page instead: https://github.com/NoiSek/Aether/releases/latest
echo "Downloading Aether theme"
git clone https://github.com/NoiSek/Aether
echo "Creating directory for themes"
mkdir /usr/share/lightdm-webkit/
mkdir /usr/share/lightdm-webkit/themes
mkdir /usr/share/lightdm-webkit/themes/Aether
echo "Moving theme into directory"
mv --recursive Aether /usr/share/lightdm-webkit/themes/Aether

# Set default lightdm-webkit2-greeter theme to Aether
sed -i 's/^webkit_theme\s*=\s*\(.*\)/webkit_theme = Aether #\1/g' /etc/lightdm/lightdm-webkit2-greeter.conf

# Set default lightdm greeter to lightdm-webkit2-greeter
sed -i 's/^\(#?greeter\)-session\s*=\s*\(.*\)/greeter-session = lightdm-webkit2-greeter #\1/ #\2g' /etc/lightdm/lightdm.conf

echo "Updated lightdm conf files with new greeter"

echo -ne "

-------------------------------------------------------------------------
                Setting configuration for window manager
-------------------------------------------------------------------------
"

echo -ne "
-------------------------------------------------------------------------
                    Enabling Essential Services
-------------------------------------------------------------------------
"
systemctl enable cups.service
ntpd -qg
systemctl enable ntpd.service
systemctl disable dhcpcd.service
systemctl stop dhcpcd.service
systemctl enable NetworkManager.service
systemctl enable bluetooth
echo -ne "
-------------------------------------------------------------------------
                    Cleaning 
-------------------------------------------------------------------------
"
# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
echo "sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers"
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
echo "sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers"

rm -r /root/automated-arch-install
rm -r /home/$USERNAME/automated-arch-install

# Replace in the same state
cd $pwd
