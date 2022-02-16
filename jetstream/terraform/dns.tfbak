resource "aws_route53_record" "dns" {
  count = var.num_nodes
  zone_id = var.dns_zone_usegvl
  name    = "${var.instance_name}${count.index + 1}.${var.domain}"
  type    = "A"
  ttl     = "3600"
  records = [openstack_compute_floatingip_v2.floating_ips[count.index].address]
}

resource "aws_route53_record" "dns_wildcard" {
  count = var.num_nodes
  zone_id = var.dns_zone_usegvl
  name    = "*.${var.instance_name}${count.index + 1}.${var.domain}"
  type    = "A"
  ttl     = "3600"
  records = [openstack_compute_floatingip_v2.floating_ips[count.index].address]
}
