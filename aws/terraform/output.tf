/* 
 * Output two files:
 *   1. A ~/.cluster configuration file used by the cluster.sh script.
 *   2. An Anisble inventory file that can be used to run playbooks.
 *
 * This plan assumed the existence of the directories ~/.cluster and
 * ~/.inventories to exist (or Terraform might create them...)
 */
locals {
    key = pathexpand("~/.ssh/${var.key_name}.pem")
    ips = aws_eip.frontend
    nodes = aws_instance.vm
}

resource "local_file" "ipfile" {
    count = length(var.instance_types)
    content = templatefile("./templates/cluster.tpl", { ip=local.ips[count.index].public_ip, key=local.key})
    filename = pathexpand("~/.cluster/aws${var.instance_types[count.index]}")
}

resource "local_file" "inventories" {
    count = length(var.instance_types)
    content = templatefile("./templates/inventory.tpl", { ip=local.ips[count.index].public_ip, key=local.key, name="aws${var.instance_types[count.index]}"})
    filename = pathexpand("~/.inventories/aws${var.instance_types[count.index]}.ini")    #filename = "/tmp/bench${count.index+1}.ini"
}

output "ip_addresses" {
    #count = length(var.instance_types)
    #value = "${count.index}. ${var.cluster_name} ${var.instance_types[count.index]} ${local.ips[count.index].public_ip}"
    value = local.ips
}