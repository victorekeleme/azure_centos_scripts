#!/bin/bash

# verbosity
set -x

# Note: CentOS 8 Stream and newer no longer include network.service
sudo dnf install network-scripts
sudo systemctl enable network.service

# step 1 and two are irrelevant

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
NM_CONTROLLED=no

EOF


# step 5: Modify udev rules to avoid generating static rules for the Ethernet interfaces
sudo ln -s /dev/null /etc/udev/rules.d/75-persistent-net-generator.rules
sudo rm -f /etc/udev/rules.d/70-persistent-net.rules

# step #
sudo chkconfig network on

# step 7: Centos 9 stream has all packages already
sudo dnf -y update

# step 8
grubby \
    --update-kernel=ALL \
    --remove-args='rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M' \
    --args='rootdelay=300 console=ttyS0 earlyprintk=ttyS0 net.ifnames=0'

# step 9: /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# If uploading an UEFI enabled VM (we don't need this)
# sudo grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg

# step 10 : skipped

# step 11: Install the Azure Linux Agent and dependencies for Azure VM Extensions

sudo dnf install -y python-pyasn1 WALinuxAgent
sudo systemctl enable waagent
sudo chkconfig waagent on
sudo systemctl start waagent

# step 12: Install cloud-init to handle the provisioning
sudo dnf install -y cloud-init cloud-utils-growpart gdisk hyperv-daemons

sudo sed -i 's/Provisioning.Agent=auto/Provisioning.Agent=auto/g' /etc/waagent.conf
sudo sed -i 's/ResourceDisk.Format=y/ResourceDisk.Format=n/g' /etc/waagent.conf
sudo sed -i 's/ResourceDisk.EnableSwap=y/ResourceDisk.EnableSwap=n/g' /etc/waagent.conf

sudo echo "Adding mounts and disk_setup to init stage"
sudo sed -i '/ - mounts/d' /etc/cloud/cloud.cfg
sudo sed -i '/ - disk_setup/d' /etc/cloud/cloud.cfg
sudo sed -i '/cloud_init_modules/a\\ - mounts' /etc/cloud/cloud.cfg
sudo sed -i '/cloud_init_modules/a\\ - disk_setup' /etc/cloud/cloud.cfg

sudo echo "Allow only Azure datasource, disable fetching network setting via IMDS"

sudo cat > /etc/cloud/cloud.cfg.d/91-azure_datasource.cfg <<EOF
datasource_list: [ Azure ]
datasource:
    Azure:
        apply_network_config: False
EOF

if [[ -f /mnt/swapfile ]]; then
    echo Removing swapfile - RHEL uses a swapfile by default
    swapoff /mnt/swapfile
    rm /mnt/swapfile -f
fi

echo "Add console log file"
cat >> /etc/cloud/cloud.cfg.d/05_logging.cfg <<EOF

# This tells cloud-init to redirect its stdout and stderr to
# 'tee -a /var/log/cloud-init-output.log' so the user can see output
# there without needing to look on the console.
output: {all: '| tee -a /var/log/cloud-init-output.log'}
EOF

# step 13: Swap configuration
sudo sed -i 's/ResourceDisk.Format=y/ResourceDisk.Format=n/g' /etc/waagent.conf
sudo sed -i 's/ResourceDisk.EnableSwap=y/ResourceDisk.EnableSwap=n/g' /etc/waagent.conf


sudo rm -f /var/log/waagent.log
sudo cloud-init clean
sudo waagent -force -deprovision+user
sudo rm -f ~/.bash_history
sudo export HISTSIZE=0

#systemctl  poweroff
