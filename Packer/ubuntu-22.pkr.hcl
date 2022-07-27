variable "cluster" {
  type    = string
  default = "Cluster-BLT"
}

variable "cpu_number" {
  type    = string
  default = "4"
}

variable "datacenter" {
  type    = string
  default = "Paris"
}

variable "datastore" {
  type    = string
  default = "BLT-iSCSI"
}

variable "disk_size" {
  type    = string
  default = "8024"
}

variable "folder" {
  type    = string
  default = "Templates"
}

variable "http_directory" {
  type    = string
  default = "http"
}

variable "network" {
  type    = string
  default = "VM Network"
}

variable "password" {
  type    = string
  default = "@Password1234"
}

variable "ram_amount" {
  type    = string
  default = "2048"
}

variable "ssh_password" {
  type    = string
  default = "@Password1234"
}

variable "ssh_username" {
  type    = string
  default = "belletable-user"
}

variable "template_name" {
  type    = string
  default = "Template_Ubuntu22_desktop"
}

variable "username" {
  type    = string
  default = "administrator@vsphere.local"
}

variable "vcenter_server" {
  type    = string
  default = "srv-par-vcsa-01.infra.blt"
}

source "vsphere-iso" "linux_ubuntu_server" {
  CPUs                 = "${var.cpu_number}"
  RAM                  = "${var.ram_amount}"
  RAM_reserve_all      = false

  boot_command = [
      "c<wait10>",
      "<wait20>linux /casper/vmlinuz --- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' ",
      "<enter><wait>",
      "initrd /casper/initrd<enter><wait>",
      "boot<enter>"
  ]
  
  boot_order           = "disk,cdrom"
  boot_wait            = "20s"
  cluster              = "${var.cluster}"
  convert_to_template  = "true"
  datacenter           = "${var.datacenter}"
  datastore            = "${var.datastore}"
  disk_controller_type = ["pvscsi"]
  folder               = "${var.folder}"
  guest_os_type        = "ubuntu64Guest"
  http_directory       = "${var.http_directory}"
  insecure_connection  = "true"
  iso_checksum         = "sha256:84aeaf7823c8c61baa0ae862d0a06b03409394800000b3235854a6b38eb4856f"
  iso_urls             = ["https://releases.ubuntu.com/22.04/ubuntu-22.04-live-server-amd64.iso"]
  cd_files = [
        "./${var.http_directory}/meta-data",
        "./${var.http_directory}/user-data"]
  cd_label = "cidata"
  network_adapters {
    network      = "${var.network}"
    network_card = "vmxnet3"
  }
  notes        = "Default SSH User: ${var.ssh_username}\nDefault SSH Pass: ${var.ssh_password}\nBuilt by Packer @ ${legacy_isotime("2006-01-02 03:04")}."
  password     = "${var.password}"
  ssh_password = "${var.ssh_password}"
  ssh_username = "${var.ssh_username}"
  ssh_port = 22
  storage {
    disk_size             = "${var.disk_size}"
    disk_thin_provisioned = true
  }
  username       = "${var.username}"
  vcenter_server = "${var.vcenter_server}"
  vm_name        = "${var.template_name}"
  ip_wait_timeout = "20m"
  ssh_timeout = "45m"
  ssh_handshake_attempts = "100"
  shutdown_command = "echo '${var.ssh_password}' | sudo -S -E shutdown -P now"
  shutdown_timeout = "15m"
}

build {
  sources = ["source.vsphere-iso.linux_ubuntu_server"]

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}'|{{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    scripts         = [
      "scripts/update.sh",
      "scripts/desktop_install.sh",
      "scripts/clean.sh"
    ]
  }

}
