# DOKUMENTATION  #

[TOC]

[General documentation-information](#General-documentation-information)
  [Requirements](#Requirements)
    [IP-Address <> DNS-Names <> Description](#IP-Address-<>-DNS-Names-<>-Description)
    [PXE-TFTP-Server-Config](#PXE-TFTP-Server-Config)
    [Example of file: 01-00-50-56-a6-ff-fd](#Example-of-file:-01-00-50-56-a6-ff-fd)
    

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



#### Example of file: 01-00-50-56-a6-ff-fd
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

This describes the installation-process of spectrum-scale from a high-level-point-of-view. You have to execute the following step-by-step.

* Prepare the Ansible-Control-Node to execute code on the three managed Spectrum-Scales-Nodes. Execute the ***"initial-ssh-setup.sh"*** script.
* Execute the three ansible-playbooks, one after another. Wait for completion of a playbook, to start the next one.
  * 00-playbook-ssh-prepare-setup.yml
  * 01-playbook-install-spectrum-scale.yml
  * 02-playbook-create-spectrum-scale-user.yml

## Ansible-Control-Node preparation

The first thing you have to do, is to execute the ***"initial-ssh-setup.sh"***-script. It creates an SSH-Keypair (***ssh-keygen***) on your Ansible-Control-Node and deploys (***ssh-copy-id***) the SSH-Public-Key to the Managed-Spectrum-Nodes.

### Download and Install helper-tool: sshpass

You may have to download and install the helper-tool ***sshpass*** to the Ansible-Control-Node.

### initial-ssh-setup.sh

```bash
#!/usr/bin/bash
# Setup for SPS-Node#1
sshpass -f rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps1
sshpass -f rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps1.home.local
sshpass -f rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@10.0.249.241

# Setup for SPS-Node#2
sshpass -f rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps2
sshpass -f rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps2.home.local
sshpass -f rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@10.0.249.242

# Setup for SPS-Node#3
sshpass -f rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps3
sshpass -f rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps3.home.local
sshpass -f rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@10.0.249.243
```





## Ansible-Playbook-Documentation

### 00-playbook-ssh-prepare-setup.yml

### 01-playbook-install-spectrum-scale.yml

### 02-playbook-create-spectrum-scale-user.yml

## Login to Spectrum-Scale GUI

```bash
https://sps3.home.local
```

