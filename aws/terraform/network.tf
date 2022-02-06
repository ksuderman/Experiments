
# Create a separate VPC for each experiment.
resource "aws_vpc" "cloudcost" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "cloudcost"
    Created = "${timestamp()}"
  }
}

resource "aws_subnet" "cloudcost" {
  vpc_id            = aws_vpc.cloudcost.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = var.zone

  tags = {
    Name = "cloudcost"
    Created = "${timestamp()}"
  }
}

resource "aws_network_interface" "gateway" {
  subnet_id   = aws_subnet.cloudcost.id
  #private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
    Created = "${timestamp()}"
  }
}

# Allocation public floating IP addresses for each instance.
resource "aws_eip" "frontend" {
  count = length(var.instance_types)
  instance = aws_instance.vm[count.index].id
  vpc      = true
}

