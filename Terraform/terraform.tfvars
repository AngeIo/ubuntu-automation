# vsphere related params
vsphere_user = "administrator@vsphere.local"
vsphere_password = "@Password1234"
vsphere_server = "srv-par-vcsa-01.infra.blt"
vsphere_datacenter_name = "Paris"
vsphere_resource_pool = "Cluster-BLT/Resources" # If you haven't resource pool, put "Resources" after cluster name
vsphere_datastore = "BLT-iSCSI"
vsphere_network = "VM Network"

# VM Setup
vmtemp = "Template_Ubuntu22_desktop"
instances = 2
vmname = "SRV-PAR-UBU-"
vmnameformat = "%02d"
dns_server = ["192.168.100.1", "192.168.100.2"]
domain = "infra.blt"

ssh_username = "belletable-user"
ssh_password = "@Password1234"
