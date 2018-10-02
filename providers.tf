# Configure the VMware vSphere Provider
provider "vsphere" {
  version        = "~> 1.8"
  user           = "${var.vcenter_user}"
  password       = "${var.vcenter_password}"
  vsphere_server = "${var.vcenter_server}"
  allow_unverified_ssl = true
}

# Configure the Rancher2 Provider
provider "rancher2" {
  api_url        = "${var.rancher_url}"
  access_key     = "${var.rancher_access_key}"
  secret_key     = "${var.rancher_secret_key}"
}
