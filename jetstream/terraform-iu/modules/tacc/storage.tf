
variable "nodes" {}
variable "namespace" {}
variable "disk_size" {
  type    = number
  default = 200
}

variable "volumes" {}

# resource "openstack_blockstorage_volume_v2" "volume" {
#   count = length(var.nodes)
#   name  = "${var.namespace}-${count.index + 1}"
#   size  = var.disk_size
# }

# resource "openstack_compute_volume_attach_v2" "attach_volumes" {
#   count       = length(var.nodes)
#   instance_id = nodes[count.index].id
#   volume_id   = openstack_blockstorage_volume_v2.volume[count.index].id
# }

resource "openstack_compute_volume_attach_v2" "attach_volumes" {
  count = length(var.nodes)
  instance_id = var.nodes[count.index]
  volume_id = var.volumes[count.index]
}