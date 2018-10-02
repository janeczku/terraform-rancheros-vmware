# Renders the cloud-config file for master nodes
data "template_file" "masters" {
  template = "${file("${path.module}/files/cloud-config.tpl")}"
  count    = "${length(var.masters_static_ips)}"

  vars {
    authorized_key = "${tls_private_key.provisioning_key.public_key_openssh}"
    hostname = "${local.masters_name_prefix}-${count.index + 1}"
    gateway = "${var.guest_default_gateway}"
    primary_ns = "${var.guest_primary_dns}"
    secondary_ns = "${var.guest_secondary_dns}"
    address = "${var.masters_static_ips[count.index]}"
  }
}

# Renders the cloud-config file for worker nodes
# TODO: Use a single template_file for all nodes
data "template_file" "workers" {
  template = "${file("${path.module}/files/cloud-config.tpl")}"
  count    = "${length(var.workers_static_ips)}"

  vars {
    authorized_key = "${tls_private_key.provisioning_key.public_key_openssh}"
    hostname = "${local.workers_name_prefix}-${count.index + 1}"
    gateway = "${var.guest_default_gateway}"
    primary_ns = "${var.guest_primary_dns}"
    secondary_ns = "${var.guest_secondary_dns}"
    address = "${var.workers_static_ips[count.index]}"
  }
}