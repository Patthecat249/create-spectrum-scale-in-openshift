# Create "IBM-Spectrum-Scale" on three VMs (CentOS8.3) in DEV-Environment and Deploy "IBM Spectrum Scale CSI Plugin Operator" in OpenShift-Cluster
This installs and configures IBM Spectrum Scale on three virtual machines. The virtual machines will be deployed with terraform. IBM Spectrum Scale will be installed and configured with Ansible.



## How to use

1. #### Login on terraform-host (VM)

   ```bash
   ssh root@terraform.home.local
   mkdir git
   cd git
   git clone https://github.com/Patthecat249/spectrum-scale.git
   # Install Helper-Tool sshpass
   yum install sshpass -y
   # dnf install sshpass -y
   ```

   

2. #### Erstellen der virtuellen Maschinen mit terraform

   ```bash
   cd ~/git/spectrum-scale/ansible/ && ansible-playbook 01-install-spectrum-scale-vms.yaml
   ```

   

3. #### Initiale Ansible-Control-Node-Konfiguration

   ```bash
   cd ~/git/spectrum-scale/ansible && ./initial-ssh-setup.sh
   ```
   

4. #### Ausführen der Ansible-Playbooks

   Die Playbooks führen die Installation und Konfiguration von Spectrum-Scale durch.

   ```bash
   ansible-playbook 02-playbook-ssh-prepare-setup.yml
   ansible-playbook 03-playbook-install-spectrum-scale.yml
   ansible-playbook 04-playbook-create-spectrum-scale-user.yml
   ```
   

5. #### Login on GUI

   ```bash
   https://sps3.home.local
   ```

   