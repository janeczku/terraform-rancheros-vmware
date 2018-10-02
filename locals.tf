locals {
  masters_name_prefix = "${var.cluster_name}-master"
  workers_name_prefix = "${var.cluster_name}-worker"
  # Horrible trickery to work around limitation of terrafom tenary operator
  # Allows the user to specify either the name of a cluster or an ESXi host
  pool_id = "${var.vsphere_cluster != "" ? join("", data.vsphere_compute_cluster.cluster.*.resource_pool_id) : join("", data.vsphere_host.host.*.resource_pool_id)}"
}
