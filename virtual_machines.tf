# Creates the VM inventory folder
resource "vsphere_folder" "folder" {
  path          = "${var.vsphere_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Creates and provisions VMs for master nodes by cloning a RancherOS template in vSphere
resource "vsphere_virtual_machine" "masters" {
  count            = "${length(var.masters_static_ips)}"
  name             = "${local.masters_name_prefix}-${count.index + 1}"
  resource_pool_id = "${local.pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "${var.vsphere_folder}"

  /*
  annotation =
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  esxi_id          = "${data.vsphere_host.host.id}"
  */

  num_cpus = 1
  memory   = 2048
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"
  enable_disk_uuid = true

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
    linked_clone  = false
  }

  vapp {
    properties {
      "guestinfo.cloud-init.config.data" = "${base64encode("${data.template_file.masters.*.rendered[count.index]}")}"
      "guestinfo.cloud-init.data.encoding" = "base64"
    }
  }

  /* extra_config must be used instead of the above if the RancherOS template is missing vApp configuration
  extra_config {
    "guestinfo.cloud-init.config.data" = "${base64encode("${data.template_file.masters.*.rendered[count.index]}")}"
    "guestinfo.cloud-init.data.encoding" = "base64"
  }
  */

  provisioner "remote-exec" {
    inline = [
      "sudo echo '${var.guest_authorized_ssh_key}' > /home/rancher/.ssh/authorized_keys",
      "sudo ros config set ssh_authorized_keys ['${var.guest_authorized_ssh_key}']",
      "${rancher2_cluster.cluster.cluster_registration_token.0.node_command} --worker",
    ]

    connection {
      type        = "ssh"
      user        = "rancher"
      private_key = "${tls_private_key.provisioning_key.private_key_pem}"
    }
  }
}

# Creates and provisions VMs for worker nodes by cloning a RancherOS template in vSphere
# TODO: Make the parameters for the resource reusable between workers and masters
resource "vsphere_virtual_machine" "workers" {
  count            = "${length(var.workers_static_ips)}"
  name             = "${local.workers_name_prefix}-${count.index + 1}"
  resource_pool_id = "${local.pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus = 2
  memory   = 4096
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
    linked_clone  = false
  }

  vapp {
    properties {
      "guestinfo.cloud-init.config.data" = "${base64encode("${data.template_file.workers.*.rendered[count.index]}")}"
      "guestinfo.cloud-init.data.encoding" = "base64"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo echo '${var.guest_authorized_ssh_key}' > /home/rancher/.ssh/authorized_keys",
      "sudo ros config set ssh_authorized_keys ['${var.guest_authorized_ssh_key}']",
      "${rancher2_cluster.cluster.cluster_registration_token.0.node_command} --worker",
    ]

    connection {
      type        = "ssh"
      user        = "rancher"
      private_key = "${tls_private_key.provisioning_key.private_key_pem}"
    }
  }
}
