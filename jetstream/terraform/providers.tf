terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
    #aws = {
    #  source  = "hashicorp/aws"
    #  version = "~> 3.27"
    #}
  }
}

provider "openstack" {}

#provider "aws" {
#  region = "us-east-1"
#}