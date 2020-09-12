# Set up NFS-Server with NFS mount
mkdir /nfsshare
chmod 777 /nfsshare
cat << EOF >> /etc/exports
/nfsshare/ *(rw,sync,no_wdelay,root_squash,insecure,fsid=0)
EOF
systemctl restart nfs
