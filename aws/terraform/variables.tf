variable "cluster_name" {
  description = "Name of the cluster"
  type = string
  default = "ks-cloudcost"
}

variable "instance_types" {
  type = list(string)
  default = ["m5", "m5a"]
#  default = ["m5.8xlarge", "m5a.8xlarge", "m5n.8xlarge", "m6i.8xlarge"]
}

variable "zone" {
  description = "The availability zone for the cluster"
  type        = string
  default     = "us-east-1a"
}

variable "dns_zone" {
  description = "The DNS zone name"
  type = string
  default = "Z01092892MLURSVI2K4L4"
}

variable "disk_size" {
  description = "The default size for EBS volumes"
  type        = string
  default     = "250"
}

variable "key_name" {
  description = "The key pair to use to enable SSH into the instances"
  type        = string
  default     = "aws-cloudcost-benchmark"
}

/*
variable "subnet" {
  description = "The VPC subnet defined in the AWS console."
  type        = string
  default     = "subnet-082222bb425b6e856"
}
*/