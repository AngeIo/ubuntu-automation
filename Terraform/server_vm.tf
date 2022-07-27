# Basic configuration withour variables

# Define authentification configuration
provider "vsphere" {
  # If you use a domain set your login like this "MyDomain\\MyUser"
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # if you have a self-signed cert
  allow_unverified_ssl = true
}

#### RETRIEVE DATA INFORMATION ON VCENTER ####

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter_name
}

data "vsphere_resource_pool" "pool" {
  # If you haven't resource pool, put "Resources" after cluster name
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve datastore information on vsphere
data "vsphere_datastore" "datastore" {
  count         = var.vsphere_datastore != "" ? 1 : 0
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve network information on vsphere
data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve template information on vsphere
data "vsphere_virtual_machine" "template" {
  name          = var.vmtemp
  datacenter_id = data.vsphere_datacenter.dc.id
}

#### VM CREATION ####

# Set vm parameters
resource "vsphere_virtual_machine" "server-vm" {
  count            = var.instances
  name             = format("${var.vmname}${var.vmnameformat}", count.index + 1)
  num_cpus         = 4
  memory           = 2048
  datastore_id     = data.vsphere_datastore.datastore[0].id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  # Use a predefined vmware template has main disk
  disk {
    label = "server.vmdk"
    size = "30"
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = lower(format("${var.vmname}${var.vmnameformat}", count.index + 1))
        domain    = var.domain
      }

      network_interface {}

      dns_server_list = var.dns_server

    }
  }

  provisioner "remote-exec" {
    script = "scripts/install-server.sh"
    connection {
      host = "${self.default_ip_address}"
      type = "ssh"
      user = var.ssh_username
      password = var.ssh_password
    }
  }

  provisioner "local-exec" {
    when   = destroy
    command = "echo '@Password1234' | kinit admin && ipa host-del '${self.name}' --continue --updatedns"
  }

}
