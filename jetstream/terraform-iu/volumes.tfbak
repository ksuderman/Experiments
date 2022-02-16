
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

resource "null_resource" "mount_volumes" {
  count = var.num_nodes

  connection {
    type     = "ssh"
    user     = "ubuntu"
    host     = openstack_compute_floatingip_v2.floating_ips[count.index].address
    private_key = "${file(var.ssh_key_file)}"
  }

  provisioner "file" {
    source = "files/system-init.sh"
    destination = "/home/ubuntu/system-init.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /home/ubuntu/system-init.sh ${openstack_compute_volume_attach_v2.attached[count.index].device} ${var.mount_point}"
    ]
  }
}
