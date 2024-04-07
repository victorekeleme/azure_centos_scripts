#!/usr/bin/env bash
# This script sets up CentOS Stream 9 to be usable in Azure.
# It, mostly, follows the reference provided but, also, improves the procedure a bit.
#
# Reference: https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-centos#centos-70

# verbosity
set -x

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

EOF

## migrate to NetworkManager
nmcli conn migrate

# step 5
ln -s /dev/null /etc/udev/rules.d/75-persistent-net-generator.rules

# step 6
# dnf config-manager --set-enabled crb
# dnf install epel-release epel-next-release

# cat << 'EOF' > /etc/yum.repos.d/CentOS-Base.repo
# [base]
# name=CentOS-$releasever - appstream packages for $basearch
# baseurl=https://mirror.stream.centos.org/$releasever-stream/AppStream/$basearch/
# enabled=1
# gpgcheck=0

# EOF

# step 7
dnf -y upgrade

# # step 8
grubby \
	--update-kernel=ALL \
	--remove-args='rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M' \
	--args='rootdelay=300 console=ttyS0 earlyprintk=ttyS0 net.ifnames=0'

# step 9 (no need to do this)
# grub2-mkconfig -o /boot/grub2/grub.cfg

sudo grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg

# # step 10
# cat << 'EOF' > /etc/dracut.conf.d/azure.conf
# add_drivers+=" hv_vmbus hv_netvsc hv_storvsc "

# EOF

# dracut -fv

# # step 11
# dnf -y install python-pyasn1 WALinuxAgent
# systemctl enable waagent

# # step 12
# dnf -y install cloud-init cloud-utils-growpart gdisk hyperv-daemons

# ## Configure waagent for cloud-init
# sed -i 's/Provisioning.UseCloudInit=n/Provisioning.UseCloudInit=y/g' /etc/waagent.conf
# sed -i 's/Provisioning.Enabled=y/Provisioning.Enabled=n/g' /etc/waagent.conf


# echo "Adding mounts and disk_setup to init stage"
# sed -i '/ - mounts/d' /etc/cloud/cloud.cfg
# sed -i '/ - disk_setup/d' /etc/cloud/cloud.cfg
# sed -i '/cloud_init_modules/a\\ - mounts' /etc/cloud/cloud.cfg
# sed -i '/cloud_init_modules/a\\ - disk_setup' /etc/cloud/cloud.cfg

# echo "Allow only Azure datasource, disable fetching network setting via IMDS"
# cat << 'EOF' > /etc/cloud/cloud.cfg.d/91-azure_datasource.cfg
# datasource_list: [ Azure ]
# datasource:
#     Azure:
#         apply_network_config: False

# EOF

# if [[ -f /mnt/resource/swapfile ]]; then
# echo Removing swapfile - RHEL uses a swapfile by default
# swapoff /mnt/resource/swapfile
# rm /mnt/resource/swapfile -f
# fi

# echo "Add console log file"
# cat << 'EOF' >> /etc/cloud/cloud.cfg.d/05_logging.cfg
# ## This tells cloud-init to redirect its stdout and stderr to
# ## 'tee -a /var/log/cloud-init-output.log' so the user can see output
# ## there without needing to look on the console.
# output: {all: '| tee -a /var/log/cloud-init-output.log'}

# EOF

# # step 13
# sed -i 's/ResourceDisk.Format=y/ResourceDisk.Format=n/g' /etc/waagent.conf
# sed -i 's/ResourceDisk.EnableSwap=y/ResourceDisk.EnableSwap=n/g' /etc/waagent.conf

# # step 14
# rm -f /var/log/waagent.log
# cloud-init clean
# waagent -force -deprovision+user
# rm -f ~/.bash_history
# export HISTSIZE=0
# systemctl  poweroff
