# How to Create a Custom CentOS 9 Stream VM on Azure

## Prerequisites
- Access to Azure portal with appropriate permissions.
- Create a Windows 10 Virtual Machine (Standard D4s v5) with Hyper-V installed

## Azure Requirements
Before proceeding, ensure your custom VM meets the following Azure requirements:

- **Disk Format:** Currently, only fixed VHD is supported.
- **Generation:** Azure supports both Gen1 (BIOS boot) and Gen2 (UEFI boot) virtual machines. For this guide, we'll focus on Gen1.
- **Disk Space:** Ensure a minimum of 6GB of disk space.
- **Partitioning:** Use default partitions instead of LVM or RAID configurations.
- **Swap:** Disable swap as Azure does not support a swap partition on the OS disk.
- **Virtual Size:** All VHDs on Azure must have a virtual size aligned to 1 MB.
- **Supported File Systems:** While XFS is now the default file system, ext4 is still supported.

## Step 1: Download CentOS 9 Stream ISO
1. Visit the official CentOS website or a trusted mirror.
2. Download the CentOS 9 Stream ISO image, [Centos 9 Bootable Image](http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-boot.iso)

## Step 2: Create a Virtual Hard Disk (VHD) in Hyper-V
1. Open Hyper-V Manager.
2. Click on "Action" in the menu bar.
3. Select "New" and then "Hard Disk".
4. Follow the wizard to create a new VHD with appropriate size and settings. The following steps illustrate the process:

### Choose VHD Format:
![Choose VHD Format](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/660014ca-fe8d-4d56-af37-d9d5e715e495)

### Choose Disk Type
![Choose Disk Type](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/33a6d145-41a3-42d1-ae77-eb619452cb93)

### Specify Name and Location
![Specify Name and Location](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/d5796fe3-b0fd-4157-9a5c-903d20bc16e7)

### Configure Disk
![Configure Disk](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/d2e346f8-6230-4270-b098-69e8779334c3)

### Summary
![Summary](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/9c8aea0f-bc89-4a8c-a9c8-d7dd2ee3d248)

## Step 3: Create and Configure the Virtual Machine in Hyper-V
1. Click on "Action" in the menu bar.
2. Select "New" and then "Virtual Machine".
3. Follow the wizard to create a new VM.
4. Configure settings such as memory, networking, and processor as shown below:

### Specify Name and Location

![Specify Name and Location](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/7c5de811-37ee-4b85-b373-42220288d932)

### Specify the Generation

![Specify the Generation](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/e2960bb2-e99b-40d6-802a-34b0a6651714)

### Assign Memory

![Assign Memory](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/ac1d23c5-fb78-4c4b-a891-84762ca72d21)

### Configure Networking

![Configure Networking](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/87f250b3-7630-45a8-9523-2338c431a11f)

### Connect Virtual Hard Disk

![Connect Virtual Hard Disk](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/d80795bb-c1ff-4d2c-a63f-1404c26d4109)

### Summary

![Summary](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/9c8aea0f-bc89-4a8c-a9c8-d7dd2ee3d248)

## Step 4: Configure Newly Created Virtual Machine
1. Right-click on the Virtual Machine and select Settings.
![Settings](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/17cc557e-5c15-45ea-b215-3c649c5fb8b4)
  
3. In the Settings menu, mount the CentOS 9 ISO image on the IDE Controller (DVD Drive) as shown below and Click apply.
![Mount ISO](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/79adb283-a2f1-4adc-a0c8-5e293c65e797)

4. Connect to the Virtual Machine by either Double Clicking or Right Clicking and Selecting Connect.
![Connect to VM](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/6376f1bb-e742-4495-be6e-8304603319bb)


## Step 5: Install CentOS on the Virtual Machine
1. Start the Virtual Machine by Clicking Start.
   ![Start VM](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/0d67b9cd-c51a-4103-9698-3a12fdfde581)

2. Follow the installation wizard as shown below:

   - Select "Install CentOS Stream 9".
   - 
     ![Install CentOS](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/a476c63e-9dab-497b-9285-5cf89901b117)

   - Select Preferred Language and Click Continue.
   - 
     ![Select Language](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/2196054f-cef0-497c-8fa6-6dfc1580a6e9)

   - CentOS Stream Installation Main Menu.
   - 
     ![Installation Menu](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/1bbe2c26-656f-4d30-a03a-d9abd56ad605)

   - Configure the Root password.
   - 
     ![Root Password](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/113757ab-0f51-4164-aa14-2b1220214989)

   - Create a New User (CentOS admin user) and make the user an Administrator.
   - 
     ![Create User](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/56c08f71-01df-41ef-8402-7aad3b9a5e15)

   - Select Software Base environment, in this I selected Minimal Install for quick installation and fewer packages.
   - 
     ![Select Software](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/3333a6ad-cd51-4a4a-ab1c-9b122dacd7a6)

   - Click on Installation Destination => Select Custom and click Done.
   - 
     ![Select Destination](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/c02e3a8e-7efd-4714-b3ae-e454d46767f3)

   - In the Manual Partitioning Page, create the /boot, and / mount points with Standard partition. Note: all /home and / are xfs and /boot is ext4.
   - 
     ![Manual Partitioning](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/ed94c693-7cdb-46f4-b366-66771c0da1ef)

   - Click Done and Accept Changes.
   - 
     ![Accept Changes](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/6c34b3b2-f4c8-469b-bad7-84e899974103)

   - Return to the Main Installation Menu and Click Begin Installation.
   - 
     ![Begin Installation](https://github.com/victorekeleme/azure_centos_scripts/assets/74677661/105b60d8-ebfd-44ea-909f-f150b0946680)

## Step 6: Prepare the Virtual Machine for Generalization 
1. Run the CentOS-Generalize-Script.sh ([Azur Documentation Reference](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-centos))
2. When the Virtual machine powers off, Close the Virtual machine Window
3. Locate the VHD, in "C:\ProgramData\Microsoft\Windows\Virtual Hard Disks"

## Step 7: Uploading VHD to Azure
There are two ways to do this:
1. Using AzCopy
2. Using Azure Storage Explorer (Recommended)

Note: Ensure VHD is uploaded as a **Page Blob**.

![Upload VHD](https://1.bp.blogspot.com/-GwsZqSSGggU/XmK8ZwKylxI/AAAAAAAACP8/9-Id9Igpjf8FeYbretJ2Ad69pAfcY1amwCEwYBhgL/s1600/img-26.jpg)

## Step 8: Creating Virtual machine in Azure From VHD

1. **Create a Managed Disk**: Once the VHD is uploaded, you need to create a Managed Disk from the VHD file. Managed Disks simplify disk management in Azure and are required for creating virtual machines.
   - In the Azure portal, navigate to the "Disks" service.
   - Click on "Create disk" and provide the necessary details, including the name, resource group, and storage type (Premium or Standard).
   - Choose "Blob storage" as the source type and select the VHD file from your storage account.
   - Specify other settings such as disk size and encryption, then click "Review + create" to create the managed disk.

2. **Create Virtual Machine**: Once the managed disk is created, you can use it to create a virtual machine.
   - In the Azure portal, navigate to the "Virtual machines" service.
   - Click on "Create virtual machine" and provide the necessary details, including the name, resource group, region, and availability options.
   - In the "Disks" section of the virtual machine creation wizard, select "Attach existing disks".
   - Choose the managed disk you created from the dropdown menu.
   - Continue configuring other settings such as network, management, and monitoring.
   - Review and create the virtual machine.

3. **Reset SSH Configuration**:
   - Once the VM is stopped, navigate to the "Reset password" blade in the Azure portal.
   - Choose the "Reset SSH public key" option.
   - Follow the prompts to reset the SSH public key.
   **Note:** This action will add your SSH key to the default azureuser user and allow you to SSH into the Virtual machine

4. **Add New SSH Public Key**:
   - After resetting the SSH configuration, navigate to the "SSH keys" blade in the Azure portal.
   - Click on the "Add" button to add a new SSH public key.
   - Paste your new SSH public key into the provided field. Ensure that you have the correct format and that it is a valid SSH public key.
   - Click on the "Save" button to save the changes.

5. **Access the Virtual Machine**: Connect to it using SSH
```
ssh -i ~/.ssh/pathTo/privatekey azureuser@<vm ip address>
```

## Step 9: Creating a CentOS 9 Generalized Image in Azure
1. **Deallocate the Virtual Machine**:
- Stop the VM to deallocate its compute resources.
- In the Azure portal, navigate to the VM you want to capture.
- Click on "Stop" to deallocate the VM.

2. **Capture the Virtual Machine**:
- After deallocating the VM, navigate to the "Images" section in the Azure portal.
- Click on "Add" to create a new image.
- Provide details such as name, resource group, and location for the image.
- Select the deallocated VM as the source for the image.
- Follow the wizard to complete the image creation process.

3. **Create or Select a Shared Image Gallery**:
- If you haven't already created a Shared Image Gallery, you can do so from the Azure portal.
- Navigate to the "Shared Image Galleries" section and click on "Add gallery".
- Provide details such as name, subscription, resource group, and location for the gallery.
- Alternatively, if you already have a Shared Image Gallery, navigate to it in the portal.

4. **Create an Image Definition**:
- Within the Shared Image Gallery, create an "Image definition" for the captured VM image.
- Provide details such as name, resource group, location, and specify the VM image you created in the previous step.

5. **Create an Image Version**:
- After creating the image definition, create an "Image version" for the VM image.
- Specify the version number and any other relevant details.

6. **Review and Publish**:
- Review the details of the image version and publish it to the Shared Image Gallery.
