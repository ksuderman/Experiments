
resource "openstack_blockstorage_volume_v2" "volume" {
  count = var.num_nodes
  name  = "${var.namespace}-${count.index + 1}"
  size  = var.disk_size
}

resource "openstack_compute_volume_attach_v2" "attached" {
  count       = var.num_nodes
  instance_id = openstack_compute_instance_v2.nodes[count.index].id
  volume_id   = openstack_blockstorage_volume_v2.volume[count.index].id

}