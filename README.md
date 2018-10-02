# terraform-rancheros-vmware

Terraform code to provision K8s clusters in vSphere with Rancher 2.x.
VMs are created by cloning from a RancherOS template.
A cloud-config template is used to provide nodes with static IP addresses and other configuration.

## Prerequisites

### Install Rancher2 Terraform provider

1. Clone the Rancher2 Terraform provider from https://github.com/rancher/terraform-provider-rancher2.
2. Build the provider binary by running `make bin`
3. Copy the provider binary to a local path, e.g. `cp ./terraform-provider-rancher2 /usr/local/bin/`

### Create RancherOS template in vSphere

1. Download the RancherOS OVA appliance from: -TODO-
2. Import into vSphere ("Deploy OVF template...)
3. Mark the resulting VM as template ("Convert to template")
4. Note the name/path of the template which must be provided to Terraform

You may also use the existing template in the Fremont vCenter: `vm-templates/rancheros-v1.4.0-golden`.

## Usage

1. Copy the `terraform.tfvars.example` to `terraform.tfvars` and adapt to match your environment
2. Specify the static IP configuration for the nodes (`masters_static_ips`, `workers_static_ips`, `guest_default_gateway`)
3. Adapt the cloud-config template (`files/cloud-config.tpl`) to your needs
4. Run `terraform plan`
5. Run `terraform apply`
