#!/usr/bin/bash
echo "" > /root/.ssh/known_hosts
# Setup for SPS-Node#1
sshpass -f configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps-patrick1
sshpass -f configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps-patrick1.home.local
sshpass -f configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@10.0.249.161

# Setup for SPS-Node#2
sshpass -f configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps-patrick2
sshpass -f configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps-patrick2.home.local
sshpass -f configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@10.0.249.162

# Setup for SPS-Node#3
sshpass -f configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps-patrick3
sshpass -f configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@sps-patrick3.home.local
sshpass -f configs/rootpassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@10.0.249.163
