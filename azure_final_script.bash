#!/bin/bash

# verbosity
set -x

# Install network-scripts (if needed)
sudo dnf install -y network-scripts

# Enable network service
sudo systemctl enable network.service

# Ensure that the SSH server is installed and configured to start at boot time
sudo dnf install openssh-server
sudo systemctl start sshd
sudo systemctl enable sshd

# Step 3
cat << 'EOF' | sudo tee /etc/default/networking
NETWORKING=yes
HOSTNAME=localhost.localdomain

EOF

# Step 4
cat << 'EOF' | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=dhcp
TYPE=Ethernet
USERCTL=no
PEERDNS=yes
IPV6INIT=no
NM_CONTROLLED=no

EOF

# Step 5
sudo ln -s /dev/null /etc/udev/rules.d/75-persistent-net-generator.rules
sudo rm -f /etc/udev/rules.d/70-persistent-net.rules

# Step 6 (replaced `chkconfig` with `systemctl` for CentOS 8+)
sudo systemctl enable network

# Step 7
sudo dnf -y update

# Step 8
sudo grubby \
    --update-kernel=ALL \
    --remove-args='rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M' \
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

# Create azure datasource config file
sudo tee /etc/cloud/cloud.cfg.d/91-azure_datasource.cfg <<EOF
datasource_list: [ Azure ]
datasource:
    Azure:
        apply_network_config: False
EOF

# Step 13: Swap configuration
sudo sed -i 's/ResourceDisk.Format=y/ResourceDisk.Format=n/g' /etc/waagent.conf
sudo sed -i 's/ResourceDisk.EnableSwap=y/ResourceDisk.EnableSwap=n/g' /etc/waagent.conf

# Clean up
sudo rm -f /var/log/waagent.log
sudo cloud-init clean
sudo waagent -force -deprovision+user
sudo rm -f ~/.bash_history
sudo export HISTSIZE=0

# Shutdown the system
# systemctl poweroff
