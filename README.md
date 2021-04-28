# Create "IBM-Spectrum-Scale" on three VMs (CentOS8.3) in DEV-Environment and Deploy "IBM Spectrum Scale CSI Plugin Operator" in OpenShift-Cluster
This installs and configures IBM Spectrum Scale on three virtual machines. The virtual machines will be deployed with terraform. IBM Spectrum Scale will be installed and configured with Ansible.



## How to use
1. #### Download Spectrum-Scale-Install-File from IBM Fix Central
    https://www.ibm.com/support/fixcentral/

  **Product Group:** `System Storage`

  **Select from System Storage:** `Storage Software`

  **Select from Storage software:** `Software defined storage`

  **Select from Software defined storage:** `IBM Spectrum Scale`

  **Installed Version:** `5.1.0`

  **Platform:** `Linux 64-bit,x86_64`

  **Download:** `Spectrum_Scale_Standard-5.1.0.3-x86_64-Linux-install`


```bash
copy downloaded-file to ansible-control-node into directory /opt/sva/spectrumscale/
```

2. #### Customize variables in "vars/vars.yaml"
You have to customize all variables you like to in the central vars_file. Especially IP-Adresses, Hostnames, VMware Settings

3. #### Login on terraform-host (VM)

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
   cd ~/git/spectrum-scale/ansible/ && ansible-playbook 01-install-spectrum-scale-vms.yaml
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

   