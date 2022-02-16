
resource "openstack_networking_secgroup_v2" "fw" {
  name = "${var.namespace}-firewall"
  description = "[tf] Security group for ${var.namespace}"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "egress_ip6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = "${openstack_networking_secgroup_v2.fw.id}"
}

resource "openstack_networking_secgroup_rule_v2" "egress_ip4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = "${openstack_networking_secgroup_v2.fw.id}"
}

resource "openstack_networking_secgroup_rule_v2" "ipv4_tcp_public" {
  for_each          = var.public_ports
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = each.value
  port_range_max    = each.value
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.fw.id
}

resource "openstack_networking_secgroup_rule_v2" "ipv6_tcp_public" {
  for_each       = var.public_ports
  direction      = "ingress"
  ethertype      = "IPv6"
  protocol       = "tcp"
  port_range_min = each.value
  port_range_max = each.value
  security_group_id = openstack_networking_secgroup_v2.fw.id
}

resource "openstack_networking_secgroup_rule_v2" "ipv4_tcp_private" {
  for_each          = var.private_ports
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = each.value
  port_range_max    = each.value
  remote_ip_prefix  = "10.0.0.0/24"
  security_group_id = openstack_networking_secgroup_v2.fw.id
}

resource "openstack_networking_secgroup_rule_v2" "ipv4_udp_private" {
  for_each          = var.udp_ports
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = each.value
  port_range_max    = each.value
  remote_ip_prefix  = "10.0.0.0/24"
  security_group_id = openstack_networking_secgroup_v2.fw.id
}

resource "openstack_networking_secgroup_rule_v2" "ipv4_tcp_nodeport" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 32767
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.fw.id
}

resource "openstack_networking_secgroup_rule_v2" "ipv6_tcp_nodeport" {
  direction      = "ingress"
  ethertype      = "IPv6"
  protocol       = "tcp"
  port_range_min = 30000
  port_range_max = 32767
  security_group_id = openstack_networking_secgroup_v2.fw.id
}

resource "openstack_networking_secgroup_rule_v2" "ipv4_udp_nodeport" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 30000
  port_range_max    = 32767
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.fw.id
}

resource "openstack_networking_secgroup_rule_v2" "ipv6_udp_nodeport" {
  direction      = "ingress"
  ethertype      = "IPv6"
  protocol       = "udp"
  port_range_min = 30000
  port_range_max = 32767
  security_group_id = openstack_networking_secgroup_v2.fw.id
}

