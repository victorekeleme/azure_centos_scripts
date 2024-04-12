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

sudo dnf install wget openssh-server -y

sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config_backup

sudo rm -rf /etc/ssh/sshd_config

sudo wget -O ./sshd_config https://raw.githubusercontent.com/victorekeleme/azure_centos_scripts/main/sshd_config

sudo mv ./sshd_config /etc/ssh/sshd_config

sudo rm -rf /etc/ssh/ssh_host_*

sudo ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' -b 2048
sudo ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' -b 256
sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''

# Ensure that the SSH server is installed and configured to start at boot time
sudo systemctl restart sshd
sudo systemctl enable sshd

# Step 3
cat << 'EOF' | sudo tee /etc/default/networking
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
# sudo rm -f /etc/udev/rules.d/70-persistent-net.rules

# Step 7
sudo dnf -y update

sudo systemctl restart NetworkManager

# Step 8
sudo grubby \
    --update-kernel=ALL \
    --remove-args='rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M edd' \
    --args='rootdelay=300 console=ttyS0 earlyprintk=ttyS0 net.ifnames=0'

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
sudo sed -i 's/ResourceDisk.Format=y/ResourceDisk.Format=n/g' /etc/waagent.conf
sudo sed -i 's/ResourceDisk.EnableSwap=y/ResourceDisk.EnableSwap=n/g' /etc/waagent.conf

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


# Clean up
sudo rm -f /var/log/waagent.log
sudo cloud-init clean
sudo waagent -force -deprovision+user
sudo rm -f ~/.bash_history
export HISTSIZE=0
history -c

# Shutdown the system
# systemctl poweroff
