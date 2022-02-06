terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_instance" "vm" {
  count = length(var.instance_types)
  ami           = data.aws_ami.ubuntu.id
  instance_type = "${var.instance_types[count.index]}.8xlarge"
  key_name      = var.key_name

  root_block_device {
    volume_size = var.disk_size
  }

  tags = {
    Name  = "${var.cluster_name}-${count.index}"
    Owner = "ks"
    Created = "${timestamp()}"
  }
}

