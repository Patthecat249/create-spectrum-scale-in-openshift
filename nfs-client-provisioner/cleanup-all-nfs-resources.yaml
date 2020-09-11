# Be carefully with execution
# oc login as kubeadmin
 oc delete deployment nfs-client-provisioner
 oc delete sa nfs-client-provisioner
 oc delete clusterrole nfs-client-provisioner-runner
 oc delete clusterrolebindings.rbac.authorization.k8s.io run-nfs-client-provisioner
 oc delete role leader-locking-nfs-client-provisioner
 oc delete rolebinding leader-locking-nfs-client-provisioner
