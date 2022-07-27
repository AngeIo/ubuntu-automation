# Infrastructure As Code - Ubuntu 22 with Packer and Terraform

This example will make use of Packer and Terraform to setup multiple Ubuntu 22.04 instances on vSphere enrolled with FreeIPA / Red Hat Identity Manager and Certificate Authority from IPA added to Firefox for local websites in HTTPS.

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
