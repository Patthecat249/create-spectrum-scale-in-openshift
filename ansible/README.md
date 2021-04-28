# DOKUMENTATION  #

[TOC]

- [General documentation-information](#General-documentation-information)
  * [Requirements](#Requirements)
    + [IP-Address <> DNS-Names <> Description](#IP-Address-<>-DNS-Names-<>-Description)
      + [PXE-TFTP-Server-Config](#PXE-TFTP-Server-Config)
      + [Example of file 01-00-50-56-a6-ff-fd](#Example-of-file-01-00-50-56-a6-ff-fd)
    + [DNSMASQ.conf on DHCP-/DNS-Server](#DNSMASQ.conf-on-DHCP-/DNS-Server)
    + [DNSMASQ.conf on PXE-/TFTP-Server](#DNSMASQ.conf-on-PXE-/TFTP-Server)
- [Installation-Process-Description](#Installation-Process-Description)
  * [Ansible-Control-Node preparation](#Ansible-Control-Node-preparation)
    + [Download and Install helper-tool sshpass](#Download-and-Install-helper-tool-sshpass)
    + [../configs/initial-ssh-setup.sh](#../configs/initial-ssh-setup.sh)
  * [Ansible-Playbook-Documentation](#Ansible-Playbook-Documentation)
    + [00-playbook-ssh-prepare-setup.yml](#00-playbook-ssh-prepare-setup.yml)
    + [01-playbook-install-spectrum-scale.yml](#01-playbook-install-spectrum-scale.yml)
    + [02-playbook-create-spectrum-scale-user.yml](#02-playbook-create-spectrum-scale-user.yml)
  * [Login to Spectrum-Scale GUI](#Login-to-Spectrum-Scale-GUI)
## 

# General documentation-information #

This playbook describes the installation of three IBM Spectrum-Scale-Nodes on virtual machines and makes the installation and configuration easier. The deneral documentation information introduce a little piece of the environment, in which the spectrum-scale-cluster will be deployed.

Author: Patrick Jahn

Date: 06.06.2020

## Requirements

- **Ansible-Control-Node**: ***terraform-master***.home.local
- **Ansible-Managed-Nodes**: ***sps1***.home.local, ***sps2***.home.local, ***sps3***.home.local
- Internet makes everything easier, each SPS-Nodes has internet-access to download some install-packages

- A running NFS server, which provides the CentOS-ISO-File, which are downloaded from official CentOS-Mirrors
  - CentOS-7-x86_64-DVD-1908.iso (http://vault.centos.org/7.7.1908/isos/x86_64/CentOS-7-x86_64-DVD-1908.iso)
  - CentOS 7.7.1908

- Kickstart-Config-Files to automate the OS-installation-process of CentOS 
  - nfs:nas.home.local:/volume1/nfs-iso/kickstart-configs/sps1.cfg

- Three virtual machines (VMware 6.7u2) will be created with a Terraform-script 
  - 8vCPU,
  - 16GB RAM,
  - 120GB root-disk,
  - 200GB NSD-Disk for first filesystem
  - 50GB NSD-Disk for second filesystem

- DNS-Domain "home.local" must be running:
  - sps1.home.local > 10.0.249.241 # Spectrum-Scale-Node#1
  - sps2.home.local > 10.0.249.242 # Spectrum-Scale-Node#2
  - sps3.home.local > 10.0.249.243 # Spectrum-Scale-Node#3

- SPS-Cluster-Name: sps.home.local

- Network-Settings for VMs are provided by DHCP (DNS, IP, Subnet, Gateway, PXE) > DNSMASQ

- Die Installation von CentOS erfolgt über PXE und kickstart-config-file

### IP-Address <> DNS-Names <> Description

```bash
# Subnet
10.0.249.0/24

# Domain
home.local
```



| IP           | DNS-Name              | Description                   |
| ------------ | --------------------- | ----------------------------- |
| 10.0.249.1   | router.home.local     | Default-Gateway               |
| 10.0.249.53  | dns.home.local        | Central DNS-/DHCP-Server      |
| 10.0.249.60  | pxe-server.home.local | Central PXE-/TFTP-Server      |
| 10.0.249.241 | sps1.home.local.      | Spectrum-Scale-Node#1         |
| 10.0.249.242 | sps2.home.local.      | Spectrum-Scale-Node#2         |
| 10.0.249.243 | sps3.home.local.      | Spectrum-Scale-Node#3 - GUI   |
| 10.0.249.200 | esx01.home.local      | VMware ESX-Host-01            |
| 10.0.249.11  | esx02.home.local      | VMware ESX-Host-02            |
| 10.0.249.205 | vcenter.home.local    | Central VMware vCenter-Server |



### PXE-TFTP-Server-Config 

```bash
# tftp-root-folder:
/home/tftproot/rootdir/tftpboot
# pxe-linux-config-file-folder:
/home/tftproot/rootdir/tftpboot/pxelinux.cfg/
```

The following files **must be** in the "**pxe-linux-config-file-folder**"

> The mac-addresses are customized in the Terraform-script

```bash
# File-Names must contain 01-followed-by-mac-address
01-00-50-56-a6-ff-fd
01-00-50-56-a6-ff-fe
01-00-50-56-a6-ff-ff
```



#### Example of file 01-00-50-56-a6-ff-fd
When the vm boots per PXE, it receives an IP-address, subnet-mask and gateway and it also gets an information, where the Preboot-Execution-Server will be found from the DHCP-Server (DNSMASQ). There (on the TFTP-Server) it looks first for his mac-address in the "pxe-linux-config-file-folder" of the TFTP-Server. It finds a file and executes the content.

* loads the centos-vmlinuz-kernel

* appends information to the kernel, where to find the installation-media (on NFS) and the kickstart-config-file

  

Content of PXE-CONFIG-FILE (01-00-50-56-a6-ff-fd) for Spectrum-Scale-Node#1

```bash
DEFAULT menu.c32
PROMPT 0
MENU TITLE Spectrum-Scale-Install-Menu
MENU AUTOBOOT Starting CentOS in # seconds
timeout 18
ONTIMEOUT centOS

LABEL centOS
menu label Add Spectrum-Scale-Node#1 Node
kernel kernels_initrd/centos_7.7.1908/vmlinuz
append ip=dhcp initrd=kernels_initrd/centos_7.7.1908/initrd.img inst.repo=nfs:nas.home.local:/volume1/nfs-iso/downloaded-iso/linux/CentOS-7-x86_64-DVD-1908.iso inst.ks=nfs:nas.home.local:/volume1/nfs-iso/kickstart-configs/sps1.cfg
```



After the Linux-Kernel boots into CentOS-Bootmenu, the installation will run automatically by using the following kickstart-files:

* sps1.cfg
* sps2.cfg
* sps3.cfg

#### Example of file: sps1.cfg

This is the content of the kickstart-file.

> You may need to customize some values!
>
> The "root" password unencrypted is: "Test1234"
>
> hostname=sps1.home.local
>
> ntpservers=router.home.local
>
> nfs --server

```bash
# cat /mnt/iso/kickstart-configs/sps1.cfg
#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use graphical install
graphical
# Use NFS installation media
nfs --server=nas.home.local --dir=/volume1/nfs-iso/downloaded-iso/linux/CentOS-7-x86_64-DVD-1908.iso
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=de-nodeadkeys --xlayouts='de (nodeadkeys)'
# System language
lang de_DE.UTF-8

# Network information
network  --bootproto=dhcp --device=ens192 --ipv6=auto --activate
network  --hostname=sps1.home.local

# Root password
rootpw --iscrypted $6$fT64SdqzocRzC9or$8rlvIqfSUsDzO9WwE8i0MLspyoYZVkIOyot1HyIWwFHyr6z1EIq3jNZ94UUUpa9OitspjylBMciRQEdJrSPiZ/
# System services
services --enabled="chronyd"
# System timezone
timezone Europe/Berlin --isUtc --ntpservers=router.home.local
# System bootloader configuration
bootloader --location=mbr --boot-drive=sda
autopart --type=lvm
# Partition clearing information
clearpart --none --initlabel

%packages
@^minimal
@core
chrony

%end

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end
eula --agreed
reboot
```

### DNSMASQ.conf on DHCP-/DNS-Server

The DNSMASQ-Server runs on a Raspi PI

```bash
pi@pi:~ $ cat /etc/dnsmasq.conf
# Basic DNS-Settings
domain-needed
resolv-file=/etc/myresolv.conf
server=217.237.151.51
server=217.237.149.205
local=/home.local/
interface=eth0
listen-address=10.0.249.53
bind-interfaces
expand-hosts
domain=home.local,10.0.249.0/24,local

#Basic DHCP-Settings
dhcp-range=10.0.249.40,10.0.249.245,255.255.255.0,12h

# Spectrum-Scale-Nodes
# Here, you have to update the mac-addresses, if you change the mac-addresses in the terraform-script
dhcp-host=00:50:56:a6:ff:fd,sps1,10.0.249.241,set:sps
dhcp-host=00:50:56:a6:ff:fe,sps2,10.0.249.242,set:sps
dhcp-host=00:50:56:a6:ff:ff,sps3,10.0.249.243,set:sps

# Static-DNS-Assignment for Spectrum-Scale
# If you change the hostnames in the kickstart.config-files, you have to point DNS to the correct DNS-Names<>IP-Address
address=/sps1.home.local/10.0.249.241
address=/sps2.home.local/10.0.249.242
address=/sps3.home.local/10.0.249.243
address=/sps.home.local/10.0.249.245

# PXE-Configuration
dhcp-boot=tag:sps,pxelinux.0,pxe-server,pxe-server

# General DHCP-Options (Default-Gateway, DNS-Server, Time-Server)
dhcp-option=3,10.0.249.1
dhcp-option=6,10.0.249.53
dhcp-option=42,10.0.249.1
dhcp-option=vendor:MSFT,2,1i

pxe-prompt="Press F8 for menu.", 5
pxe-service=x86PC,"Choose and Install OS per TFTP from PXE-SERVER",pxelinux,pxe-server

log-queries
log-facility=/var/log/dnsmasq.log
log-dhcp
```

### DNSMASQ.conf on PXE-/TFTP-Server

```bash
interface=ens160,lo
enable-tftp
tftp-root=/home/tftproot/rootdir/tftpboot
```



# Installation-Process-Description

```bash
# Login to your Ansible-Control-Node as root
# ssh terraform.home.local
# switch to root-home-directory
cd /root
# create folder "git"
mkdir git
# clone git repository
git clone https://github.com/Patthecat249/spectrum-scale.git
# change into ansible-working-directory to execute scripts
cd git/spectrum-scale/ansible/

# execute the initial-setup-script
./../configs/initial-ssh-setup.sh
# execute the playbook one after another
ansible-playbook 00-playbook-ssh-prepare-setup.yml
ansible-playbook 01-playbook-install-spectrum-scale.yml
ansible-playbook 02-playbook-create-spectrum-scale-user.yml
# Login to Spectrum-Scale GUI
```



## Ansible-Control-Node preparation

The first thing you have to do, is to execute the ***"../configs/initial-ssh-setup.sh"***-script. It creates an SSH-Keypair (***ssh-keygen***) on your Ansible-Control-Node and deploys (***ssh-copy-id***) the SSH-Public-Key to the Managed-Spectrum-Nodes.

### Download and Install helper-tool sshpass

You may have to download and install the helper-tool ***sshpass*** to the Ansible-Control-Node.

### ../configs/initial-ssh-setup.sh

```bash
#!/usr/bin/bash
# Setup for SPS-Node#1
sshpass -f ../configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps1
sshpass -f ../configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps1.home.local
sshpass -f ../configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@10.0.249.241

# Setup for SPS-Node#2
sshpass -f ../configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps2
sshpass -f ../configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps2.home.local
sshpass -f ../configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@10.0.249.242

# Setup for SPS-Node#3
sshpass -f ../configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps3
sshpass -f ../configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps3.home.local
sshpass -f ../configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@10.0.249.243
```





## Ansible-Playbook-Documentation

The following chapters describe the real Installation-Process of Spectrum-Scale.

### 00-playbook-ssh-prepare-setup.yml

```yaml
# Playbook starts here
- name: "Prepare Ansible-Control-Node and Spectrum-Scale-Nodes"
  hosts: spectrumscale #The inventory-file contains a Group of the three sps-nodes
  tasks:
    # If sshpass is not installed, it will do so now
    - name: "Install sshpass"
      yum:
        name: "sshpass"
        state: present
      tags:
      - ssh
    
    # It creates a ssh-keypair on each sps-node
    - name: "Create SSH-KEYPAIR on localhost to use from Ansible-Control-Node"
      openssh_keypair:
        path: "/root/.ssh/id_rsa"
        size: 4096
        type: "rsa"
      tags:
      - ssh
    
    # It distributes each created ssh-key between all sps-nodes. This is important, because the SPS-Installation need this 
    - name: "Distribute SSH-Pub-Keys to Managed-SPS-Nodes"
      raw: "{{ item }}"
      with_items:
        - "sshpass -f ../configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps1"
        - "sshpass -f ../configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps1.home.local"
        - "sshpass -f ../configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@10.0.249.241"
        - "sshpass -f ../configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps2"
        - "sshpass -f ../configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps2.home.local"
        - "sshpass -f ../configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@10.0.249.242"
        - "sshpass -f ../configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps3"
        - "sshpass -f ../configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps3.home.local"
        - "sshpass -f ../configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@10.0.249.243"
```



### 01-playbook-install-spectrum-scale.yml

```yaml
---
### --- BEGIN ANSIBLE-SKRIPT --- ###
- name: Install prerequisites for IBM Spectrum-Scale on CentOS7.7
  hosts: spectrumscale
  gather_facts: false
  vars:
# This is the central command, to install, configure and deploy spectrum scale later
    spectrumscale_cmd: "/usr/lpp/mmfs/5.0.5.0/installer/spectrumscale"
# After you extract the tar-gz-file this command must be executed
    sps_install_filename: "Spectrum_Scale_Standard-5.0.5.0-x86_64-Linux-install"
# This is the SPS-Cluster-Name
    sps_cluster_name: "sps.home.local"
# This is the IP-Adress of the Node which will be the Chef-Setup-Node for Spectrum-Scale. sps1.home.local has the 10.0.249.241
    sps_setup_node_ip: "10.0.249.241"
# IP-Address of a NTP-server
    sps_ntp_ip1: "10.0.249.1"
# IP-Adress of Cluster-Export-Services
    sps_ces_export_ip1: "10.0.249.245"
# FQDNs of the three Spectrum-Scale-VMs
    sps_node1: "sps1.home.local"
    sps_node2: "sps2.home.local"
    sps_node3: "sps3.home.local"
# The Device-Names of the DISK, which will be created in the terraform-script. 
# Disk-Unit-Number=1 will be /dev/sdb"
# Disk-Unit-Number=2 will be /dev/sdc"
    sps_dev1: "/dev/sdb"
    sps_dev2: "/dev/sdc"
# The mount-point, where the filesystems will be mounted
# The folders will be created by this ansible-script, if they does not exist
    sps_mountpoint_fs1: "/ibm/spsopenshift/"
# The Spectrum-Scale-Filesystem-Names
# /dev/sdb > gpfs > /ibm/gpfs/
# /dev/sdc > patrick > /ibm/patrick/
    sps_filesystem_fs1: "spsopenshift"
# The central used SSH-Keypair based on name
# private-key: id_rsa
# public-key: id_rsa.pub
    private_root_key: "/root/.ssh/id_rsa"
# The central working-directory on the sps-nodes
    dir_root: "/opt/sva/spectrumscale/"
# Name of the tar-file. this must be downloaded from IBM (passport advantage)
    sps_tar_filename: "Scale_std_install-5.0.5.0_x86_64.tar.gz"
# The nfs-server and path, where the tar-gz-file is in
    src_nas_mount: "nas.home.local:/volume1/nfs-iso/"
# Mountpoint on sps-node
    dest_nas_mount_path: "/mnt"
  tasks:

### Install Prerequisites for Spectrum-Scale alias GPFS

# Add EPEL-Release-Repo
# - This will be needed to download some prerequisites fro SPS
    - name: "Add EPEL-Release-Repo"
      yum:
        name: epel-release.noarch
        state: present

# The "Bind-Utils" are needed for Spectrum-Scale to check dns with nslookup
    - name: "Installiere bind-utils-9.11.4-16.P2.el7.x86_64"
      yum:
        name: bind-utils-9.11.4-16.P2.el7.x86_64
        state: present

# The "NFS-Utils" are needed to use the nfs-client to download the tar-file from nfs-server
    - name: "Installiere NFS-UTILS"
      yum:
        name: nfs-utils.x86_64
        state: present

# net-tools provide some Basic networking tools
    - name: "Installiere net-tools"
      yum:
        name: net-tools
        state: present

# Spectrum-Scale is looking for ntp-daemon
    - name: "Installiere ntp.x86_64"
      yum:
        name: ntp.x86_64
        state: present

# Spectrum-Scale needs The C Preprocessor
    - name: "Installiere cpp.x86_64"
      yum:
        name: cpp.x86_64
        state: present

# The Various compilers (C, C++, Objective-C, Java, ...) 
    - name: "Installiere gcc.x86_64"
      yum:
        name: gcc.x86_64
        state: present

# C++ support for GCC
    - name: "Installiere gcc-c++.x86_64"
      yum:
        name: gcc-c++.x86_64
        state: present
### Installation of prerequisites is completed


# Checks, if the the working-directory exists
    - name: "Check if folder exists"
      stat:
        path: "{{ dir_root }}"
      register: folder_details

    - name: "DEBUG"
      debug:
        msg: "{{ folder_details }}"

# If working-directory is not present. It will be created. Also folders for the GPFS-mountpoints will be created.
    - name: "Spectrum-Scale-Entpack-Verzeichnis erstellen"
      file:
        recurse: true
        path: "{{ item }}"
        state: "directory"
      with_items:
        - "{{ dir_root }}"
        - "{{ sps_mountpoint_fs1 }}"
        - "{{ sps_filesystem2 }}"
      when:
        - not folder_details.stat.exists
        
# Check, if TAR-Files exists on SPS-Nodes
# if exist, continue without doing anythin
# if not, Mount NFS-Share > download > extract file > unmount nfs-share
    - name: "Check if TAR-File exists on Remote-Machine in dir_rootectory"
      stat:
        path: "{{ dir_root }}{{ sps_tar_filename }}"
      register: tar_details

    - name: "DEBUG"
      debug:
        msg: "{{ tar_details }}"

# Mount the nfs-share, only if file doesn't exist
    - name: "Mounting NFS-Share"
      mount:
        fstype: nfs
        opts: defaults
        state: mounted
        src: "{{ src_nas_mount }}"
        path: "{{ dest_nas_mount_path }}"
        backup: yes
      when:
        - not tar_details.stat.exists

# Wait a Second for mounting nfs)
    - name: "Wait a Second..."
      wait_for:
        timeout: 1

# Copy TAR-File directly from nfs-server to sps-nodes
    - name: "Copy TAR-File from NFS-Server to SPS-Nodes"
      copy:
        src: "{{ dest_nas_mount_path }}/spectrumscale/{{ sps_tar_filename }}"
        dest: "{{ dir_root }}"
        remote_src: yes
      when:
        - not tar_details.stat.exists

# Unmount the nfs-share. Won't needed anymore.
    - name: "Unmounting NFS-Share"
      mount:
        fstype: nfs
        opts: defaults
        state: absent
        src: "{{ src_nas_mount }}"
        path: "{{ dest_nas_mount_path }}"
        backup: yes
      when:
        - not tar_details.stat.exists

# Check, if TAR was downloaded correctly and is present on sps-nodes
    - name: "Check if TAR-File exists on Remote-Machine"
      stat:
        path: "{{ dir_root }}{{ sps_tar_filename }}"
      register: tar_after_copy_details

# Extract the TAR-GZ-File in working-drectory
    - name: "Extract Tar-File"
      unarchive:
        src: "{{ dir_root }}{{ sps_tar_filename }}"
        dest: "{{ dir_root }}"
        remote_src: yes
      when:
        - tar_after_copy_details.stat.exists

# Need some more Dependencies. 
# Spectrum-Scale expects this explicit version of Kernel Devel and Header
    - name: "Copy Kernel Devel from Ansible-Control-Node"
      copy:
        src: "../dependencies/kernel-devel-3.10.0-1062.el7.x86_64.rpm"
        dest: "{{ dir_root }}/kernel-devel-3.10.0-1062.el7.x86_64.rpm"

    - name: "Copy Kernel Header from Ansible-Control-Node"
      copy:
        src: "../dependencies/kernel-headers-3.10.0-1062.el7.x86_64.rpm"
        dest: "{{ dir_root }}/kernel-headers-3.10.0-1062.el7.x86_64.rpm"

    - name: "Install Kernel Devel"
      yum:
        name: "{{ dir_root }}/kernel-devel-3.10.0-1062.el7.x86_64.rpm"
        allow_downgrade: yes
        state: present

    - name: "Install Kernel Header"
      yum:
        name: "{{ dir_root }}/kernel-headers-3.10.0-1062.el7.x86_64.rpm"
        allow_downgrade: yes
        state: present

# EPEL-Release-Repo must be detached, because Spectrum-Scale checks it and will fail with installation, if EPEL-Repo is present
    - name: "Remove EPEL-Release-Repo"
      yum:
        name: epel-release.noarch
        state: absent

# The easiest way to get Spectrum-Scale running is to disable the Firewall
    - name: "Stop and disable firewalld"
      service:
        name: firewalld
        state: stopped
        enabled: false

# Spectrum-Scale will install the base-binaries
# The Installer is executed with echo '1' to accept the license automatically
    - name: "Execute SpectrumScale Install-File"
      raw: "{{ item }}"
      with_items:
#        - "echo '1' | /opt/sva/spectrumscale/Spectrum_Scale_Standard-5.0.5.0-x86_64-Linux-install"
        - "echo '1' | { entpackdir }}{{ sps_install_filename }}"

# The Spectrum-Scale-Setup-Node will be defined. It my case, this is sps1.home.local
# when condition is needed, because this task must only be executed on sps1
    - name: "Setup Spectrum-Scale-Installation-Node"
      raw: "{{ item }}"
      with_items:
        - "{{ spectrumscale_cmd }} setup -s {{ sps_setup_node_ip }} -i {{ private_root_key }}"
      when: "'{{ sps_node1 }}' in inventory_hostname"

# This will configure the Spectrum-Scale-Cluster
# Defines cluster-anem, ports, protocols, nsd, nodes, and so on
    - name: "Configure Spectrum-Scale"
      raw: "{{ item }}"
      with_items:
        - "{{ spectrumscale_cmd }} config gpfs -c {{ sps_cluster_name }}"
        - "{{ spectrumscale_cmd }} config ntp -e on -s {{ sps_ntp_ip1 }}"
        - "{{ spectrumscale_cmd }} config gpfs -e 60000-61000"
        - "{{ spectrumscale_cmd }} callhome disable"
        - "{{ spectrumscale_cmd }} config protocols -f {{ sps_filesystem_fs1 }} -m {{ sps_mountpoint_fs1 }}"
        - "{{ spectrumscale_cmd }} config protocols -f {{ sps_fs2 }} -m {{ sps_filesystem2 }}"
        - "{{ spectrumscale_cmd }} config protocols -e {{ sps_ces_export_ip1 }}"
        - "{{ spectrumscale_cmd }} enable smb nfs"
        - "{{ spectrumscale_cmd }} config protocols -l"
        - "{{ spectrumscale_cmd }} node add {{ sps_node1 }} -amnpq"
        - "{{ spectrumscale_cmd }} node add {{ sps_node2 }} -amnpq"
        - "{{ spectrumscale_cmd }} node add {{ sps_node3 }} -amnpqg"
        - "{{ spectrumscale_cmd }} nsd add -p {{ sps_node1 }} -fs {{ sps_filesystem_fs1 }} {{ sps_dev1 }}"
        - "{{ spectrumscale_cmd }} nsd add -p {{ sps_node2 }} -fs {{ sps_filesystem_fs1 }} {{ sps_dev1 }}"
        - "{{ spectrumscale_cmd }} nsd add -p {{ sps_node3 }} -fs {{ sps_filesystem_fs1 }} {{ sps_dev1 }}"
        - "{{ spectrumscale_cmd }} nsd add -p {{ sps_node1 }} -fs {{ sps_fs2 }} {{ sps_dev2 }}"
        - "{{ spectrumscale_cmd }} nsd add -p {{ sps_node2 }} -fs {{ sps_fs2 }} {{ sps_dev2 }}"
        - "{{ spectrumscale_cmd }} nsd add -p {{ sps_node3 }} -fs {{ sps_fs2 }} {{ sps_dev2 }}"
      when: "'{{ sps_node1 }}' in inventory_hostname"

# Spectrum Scale Install Precheck
# This runs the Install-Prechecker
    - name: "Install Spectrum-Scale --precheck"
      raw: "{{ spectrumscale_cmd }} install --precheck"
      when: "'{{ sps_node1 }}' in inventory_hostname"

# Spectrum Scale Install
# This must be run as a script and not as 'raw'-command, because it needs on longtime.
# Appr. time 30-60 minutes
    - name: "Execute spectrumscale-install-deploy.sh - This needs some time appr.30min"
      script: "spectrumscale-install-deploy.sh"
      when: "'{{ sps_node1 }}' in inventory_hostname"

### --- END ANSIBLE-SKRIPT --- ###
```

The installation and configuration is ***finished***. For GUI-access execute the next playbook. 

### 02-playbook-create-spectrum-scale-user.yml

This Playbook creates two Users in two Groups. The csiadmin should be used by OpenShift.

| User     | Password | Group         |
| -------- | -------- | ------------- |
| patrick  | Test1234 | SecurityAdmin |
| csiadmin | Test1234 | CsiAdmin      |



```yaml
- name: "Playbook - Create Spectrum-Scale-Users"
  hosts: "sps3.home.local"
  gather_facts: false
  tasks:
    - name: "Create User on GUI-Node"
      raw: "{{ item }}"
      with_items:
        - "/usr/lpp/mmfs/gui/cli/mkuser csiadmin -p Test1234 -g CsiAdmin"
        - "/usr/lpp/mmfs/gui/cli/mkuser patrick -p Test1234 -g SecurityAdmin"
```



## Login to Spectrum-Scale GUI

https://sps3.home.local