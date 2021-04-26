#!/usr/bin/bash
rm -f /root/.ssh/known_hosts
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
