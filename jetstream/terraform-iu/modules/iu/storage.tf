
variable "nodes" {}
variable "volumes" {}

resource "openstack_compute_volume_attach_v2" "attach_volumes" {
  count       = length(var.nodes)
  instance_id = var.nodes[count.index].id
  volume_id   = var.volumes[count.index]
}
