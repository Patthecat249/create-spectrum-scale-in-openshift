provider "vsphere" {
  vsphere_server = var.vsphere_server
  user = var.vsphere_user
  password = var.vsphere_password
  allow_unverified_ssl = true
}

# --- VARIABLE-DECLARATION

data "vsphere_datacenter" "dc" {
  name = "dc-home"
}

data "vsphere_compute_cluster" "cluster" {
  name = "cluster-home"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name = "rp-home"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name = "openshift_storage"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name = "dpg-home-prod"
  datacenter_id = data.vsphere_datacenter.dc.id
}

variable "ocp-folder" {
  default = "/dc-home/vm/ocp43-patrick"
}

# --- Create VM Spectrum-Scale-Node1 --- #
resource "vsphere_virtual_machine" "sps1" {
  name = var.vm_name_sps1
  folder = var.ocp-folder
  guest_id = var.sps_guest_id_tag
  resource_pool_id = data.vsphere_resource_pool.pool.id
  firmware = "bios"
  datastore_id = data.vsphere_datastore.datastore.id
  num_cpus = 4
  memory = 8192
  wait_for_guest_ip_timeout = 10
  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
    use_static_mac = true
    mac_address = "00:50:56:a6:ff:fd"
  }
  disk {
    label = "rootvolume"
    size  = "120"
    thin_provisioned  = "true"
  }
}
# --- Create VM Spectrum-Scale-Node2 --- #
resource "vsphere_virtual_machine" "sps2" {
  name = var.vm_name_sps2
  folder = var.ocp-folder
  guest_id = var.sps_guest_id_tag
  resource_pool_id = data.vsphere_resource_pool.pool.id
  firmware = "bios"
  datastore_id = data.vsphere_datastore.datastore.id
  num_cpus = 4
  memory = 8192
  wait_for_guest_ip_timeout = 10
  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
   use_static_mac = true
    mac_address = "00:50:56:a6:ff:fe"
  }
 disk {
    label = "rootvolume"
    size  = "120"
    thin_provisioned  = "true"
  }
}
# --- Create VM Spectrum-Scale-Node3 --- #
resource "vsphere_virtual_machine" "sps3" {
  name = var.vm_name_sps3
  folder = var.ocp-folder
  guest_id = var.sps_guest_id_tag
  resource_pool_id = data.vsphere_resource_pool.pool.id
  firmware = "bios"
  datastore_id = data.vsphere_datastore.datastore.id
  num_cpus = 4
  memory = 8192
  wait_for_guest_ip_timeout = 10
  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
    use_static_mac = true
    mac_address = "00:50:56:a6:ff:ff"
  }
  disk {
    label = "rootvolume"
    size  = "120"
    thin_provisioned  = "true"
  }
}
