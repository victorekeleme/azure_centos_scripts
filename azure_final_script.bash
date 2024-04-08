


# Ensure that the SSH server is installed and configured to start at boot time

sudo dnf install openssh-server

sudo systemctl start sshd

sudo systemctl enable sshd

# Install the Azure Linux Agent

sudo dnf install -y WALinuxAgent cloud-init cloud-utils-growpart gdisk hyperv-daemons

sudo systemctl enable waagent.service
sudo systemctl enable cloud-init.service

