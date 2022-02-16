data "openstack_images_image_v2" "ubuntu20" {
  name = var.image
  most_recent = true
}

resource "openstack_compute_instance_v2" "nodes" {
  count = length(var.flavors)
  name            = "${var.namespace}-${var.flavors[count.index]}"
  #image_name      = var.image
  flavor_name     = "m1.${var.flavors[count.index]}"
  key_pair        = var.key_pair
  security_groups = [openstack_networking_secgroup_v2.fw.id, "default"]
  network {
    name = var.network
  }
  block_device {
    uuid = "${data.openstack_images_image_v2.ubuntu20.id}"
    source_type = "image"
    volume_size = var.disk_size
    boot_index = 0
    destination_type = "volume"
    delete_on_termination = true
  }
}

resource "openstack_compute_floatingip_v2" "floating_ips" {
  pool  = "public"
  count = length(var.flavors)
}

resource "openstack_compute_floatingip_associate_v2" "node_ips" {
  count       = length(var.flavors)
  floating_ip = openstack_compute_floatingip_v2.floating_ips[count.index].address
  instance_id = openstack_compute_instance_v2.nodes[count.index].id
}

