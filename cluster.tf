# Creates a custom K8s cluster in Rancher
resource "rancher2_cluster" "cluster" {
  name = "${var.cluster_name}"
  description = "Terraform provisioned cluster"
  kind = "rke"
  rke_config {
    network {
      plugin = "canal"
    }
  }
  // TODO: Add vsphere_cloud_provider configuration
}
