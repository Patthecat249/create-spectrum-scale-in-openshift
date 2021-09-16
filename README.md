# This creates an "IBM-Spectrum-Scale-Storage-Cluster" on three VMs (CentOS8.3) as a prerequisite for Spectrum-Scale-CNSA on OpenShift. 
This installs and configures IBM Spectrum Scale on three virtual machines. The virtual machines will be deployed with terraform. IBM Spectrum Scale will be installed and configured with Ansible automatically.



## How to use
1. #### Prerequisite - Download Spectrum-Scale-Install-File from IBM Fix Central
    https://www.ibm.com/support/fixcentral/

  **Product Group:** `System Storage`

  **Select from System Storage:** `Storage Software`

  **Select from Storage software:** `Software defined storage`

  **Select from Software defined storage:** `IBM Spectrum Scale`

  **Installed Version:** `5.1.1`

  **Platform:** `Linux 64-bit,x86_64`

  **Download:** `Spectrum_Scale_Data_Access-5.1.1.3-x86_64-Linux-install`

### Informationen zun den Spectrum-Scale-Editionen: 
https://www.ibm.com/docs/en/spectrum-scale/5.0.5?topic=overview-spectrum-scale-product-editions

```bash
copy spectrum-scale-install-file to ansible-control-node into directory /opt/sva/spectrumscale/
ssh root@installvm
cp /mnt/openshift/downloaded-iso/spectrum-scale/Spectrum_Scale_Data_Access-5.1.1.3-x86_64-Linux-install /opt/sva/spectrumscale/
```

2. #### Prerequisite - Customize variables in "vars/vars.yaml"
You have to customize all variables you like to in the central vars_file. Especially IP-Adresses, Hostnames, VMware Settings

3. #### Login to the installation-Host from where to Install the Spectrum-Scale-Cluster

   ```bash
   ssh root@terraform.home.local
   mkdir git
   cd git
   git clone https://github.com/Patthecat249/spectrum-scale.git
   # Install Helper-Tool sshpass
   yum install sshpass -y
   # dnf install sshpass -y
   ```
   

4. #### All-In-One-Playbook

   Execute nothing but the "All-In-One-Ansible-Playbook" to install a Spectrum-Scale-Cluster with a single command

   ```bash
   cd ~/git/spectrum-scale/ansible/ && ansible-playbook 00-all-in-one.yaml
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

   