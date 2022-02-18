# This creates an "IBM-Spectrum-Scale-Storage-Cluster" on three VMs (RHEL8.5) as a prerequisite for Spectrum-Scale-CNSA on OpenShift. 
This installs and configures an IBM Spectrum Scale Cluster on three VMware vSphere virtual machines. The virtual machines will be deployed with terraform. IBM Spectrum Scale will be installed and configured with Ansible automatically. The goal is to create a one-click-installer.

## Environment

- VMware vSphere 6.7.x
- Install-VM with Internet Access
  - Ansible 2.9
  - Terraform (https://releases.hashicorp.com/terraform/1.1.6/terraform_1.1.6_windows_amd64.zip)
- Running DNS & DHCP

## How to use
1. #### Prerequisite - Download Spectrum-Scale-Install-File from IBM Fix Central
    https://www.ibm.com/support/fixcentral/

  **Product Group:** `System Storage`

  **Select from System Storage:** `Storage Software`

  **Select from Storage software:** `Software defined storage`

  **Select from Software defined storage:** `IBM Spectrum Scale`

  **Installed Version:** `5.1.2`

  **Platform:** `Linux 64-bit,x86_64`

  **Download:** `Spectrum_Scale_Data_Access-5.1.2.2-x86_64-Linux-install`

### Install-VM vorbereiten: 
https://www.ibm.com/docs/en/spectrum-scale/5.0.5?topic=overview-spectrum-scale-product-editions

```bash
# copy spectrum-scale-install-file to ansible-control-node into directory /opt/sva/spectrumscale/
# SSH into Install-VM
ssh root@installvm

# Create directory
mkdir -p /opt/sva/spectrumscale

# Install NFS-Tools
dnf install nfs-utils
mount -t nfs nas.home.local:/volume1/nfs-iso /mnt

# Terraform installieren
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform

# Copy Scale-File from NFS-Server to Install-VM
cp /mnt/openshift/downloaded-iso/spectrum-scale/Spectrum_Scale_Data_Access-5.1.2.2-x86_64-Linux-install /opt/sva/spectrumscale/
```

2. #### Prerequisite - Customize variables in "vars/vars.yaml"
  You have to customize all variables you like to in the central vars_file. Especially IP-Adresses, Hostnames, VMware Settings

  

3. #### Login to the installation-Host from where to Install the Spectrum-Scale-Cluster

   ```bash
   ssh root@install-vm
   mkdir git
   cd git
   git clone https://github.com/Patthecat249/spectrum-scale.git
   # Install Helper-Tool sshpass
   dnf install sshpass -y
   # dnf install sshpass -y
   ```
   
4. #### All-In-One-Playbook

   Execute nothing but the "All-In-One-Ansible-Playbook" to install a Spectrum-Scale-Cluster with a single command

   ```bash
   cd ~/git/spectrum-scale/ansible/ && ansible-playbook 00-all-in-one.yaml -e "subscription_user=<username> subscription_pass=<password>"
   ```



# Alternate Installation

2. #### Create the virtual machines

   ```bash
   cd ~/git/spectrum-scale/ansible/playbooks/ && ansible-playbook 01-install-spectrum-scale-vms.yaml
   ```

   

3. #### Prepare the Ansible-Control-Node and Ansible-Managed-Nodes with SSH-Keys

   ```bash
   cd ~/git/spectrum-scale/ansible && ./../configs/initial-ssh-setup.sh
   ```

4. #### Execute Ansible-Playbooks

   Die Playbooks führen die Installation und Konfiguration von Spectrum-Scale durch.

   ```bash
   cd ~/git/spectrum-scale/ansible && ansible-playbook 02-playbook-ssh-prepare-setup.yml
   cd ~/git/spectrum-scale/ansible && ansible-playbook 03-playbook-install-spectrum-scale.yml
   cd ~/git/spectrum-scale/ansible && ansible-playbook 04-playbook-create-spectrum-scale-user.yml
   ```

5. #### Login on GUI

   ```bash
   https://sps3.home.local
   ```

   