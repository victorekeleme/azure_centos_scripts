#!/bin/bash

# verbosity
set -x

# Check if the script is being run with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Backup the original sudoers file
sudo cp /etc/sudoers /etc/sudoers.bak

# Add NOPASSWD option for wheel group in sudoers file
echo "%wheel ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers >/dev/null

echo "Passwordless sudo access for members of the wheel group has been configured."

# step 3
cat << 'EOF' > /etc/default/networking
NETWORKING=yes
HOSTNAME=localhost.localdomain

EOF

# step 4
cat << 'EOF' > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=dhcp
TYPE=Ethernet
USERCTL=no
PEERDNS=yes
IPV6INIT=no

EOF

# ## migrate to NetworkManager
nmcli conn migrate

# Step 5
sudo ln -s /dev/null /etc/udev/rules.d/75-persistent-net-generator.rules

# Step 7
sudo dnf -y update

# Step 8
sudo grubby \
    --update-kernel=ALL \
    --remove-args='rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M edd' \
    --args='rootdelay=300 console=ttyS0 earlyprintk=ttyS0 net.ifnames=0 edd=off'

# Step 9
sudo grub2-mkconfig -o /boot/grub2/grub.cfg


# Step 11
sudo dnf install -y python-pyasn1 WALinuxAgent
sudo systemctl enable waagent
sudo systemctl start waagent

# Step 12
sudo dnf install -y cloud-init cloud-utils-growpart gdisk hyperv-daemons

# Modify waagent.conf
sudo sed -i 's/Provisioning.Agent=auto/Provisioning.Agent=auto/g' /etc/waagent.conf
sudo sed -i 's/Provisioning.UseCloudInit=n/Provisioning.UseCloudInit=y/g' /etc/waagent.conf
sudo sed -i 's/Provisioning.Enabled=y/Provisioning.Enabled=n/g' /etc/waagent.conf


# Modify cloud.cfg
sudo sed -i '/ - mounts/d' /etc/cloud/cloud.cfg
sudo sed -i '/ - disk_setup/d' /etc/cloud/cloud.cfg
sudo sed -i '/cloud_init_modules/a\\ - mounts' /etc/cloud/cloud.cfg
sudo sed -i '/cloud_init_modules/a\\ - disk_setup' /etc/cloud/cloud.cfg

echo "Allow only Azure datasource, disable fetching network setting via IMDS"
cat << 'EOF' > /etc/cloud/cloud.cfg.d/91-azure_datasource.cfg
datasource_list: [ Azure ]
datasource:
    Azure:
        apply_network_config: False

EOF

if [[ -f /mnt/resource/swapfile ]]; then
echo Removing swapfile - RHEL uses a swapfile by default
swapoff /mnt/resource/swapfile
rm /mnt/resource/swapfile -f
fi

echo "Add console log file"
cat << 'EOF' >> /etc/cloud/cloud.cfg.d/05_logging.cfg
## This tells cloud-init to redirect its stdout and stderr to
## 'tee -a /var/log/cloud-init-output.log' so the user can see output
## there without needing to look on the console.
output: {all: '| tee -a /var/log/cloud-init-output.log'}

EOF

sudo sed -i 's/ResourceDisk.Format=y/ResourceDisk.Format=n/g' /etc/waagent.conf
sudo sed -i 's/ResourceDisk.EnableSwap=y/ResourceDisk.EnableSwap=n/g' /etc/waagent.conf

# Generalizing the Virutal Machine
sudo rm -f /var/log/waagent.log
sudo cloud-init clean
sudo waagent -force -deprovision+user
sudo rm -f ~/.bash_history
export HISTSIZE=0
history -c

# Shutdown the system
systemctl poweroff
