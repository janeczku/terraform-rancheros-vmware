output "cluster-name" {
  value = "${var.cluster_name}"
}

output "cluster-id" {
  value = "${rancher2_cluster.cluster.id}"
}

output "master-nodes" {
  value = "${formatlist("%v", vsphere_virtual_machine.masters.*.default_ip_address)}"
}

output "worker-nodes" {
  value = "${formatlist("%v", vsphere_virtual_machine.workers.*.default_ip_address)}"
}
