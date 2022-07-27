# Infrastructure As Code - Ubuntu 22 with Packer and Terraform

This example will make use of Packer and Terraform to setup a Ubuntu instance on vSphere with Apache.

# Running

Create the template

```
cd Packer
packer build ubuntu-22.pkr.hcl
```

Setup the virtual machine.

```
cd Terraform
terraform init
terraform apply
```
