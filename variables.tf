variable "aws_zones" {
  description = "The AZ zones to deploy into"
}

variable "aws_region" {
  description = "The region to deploy into"
  default = "us-east-1"
}

variable "instance_count" {
  description = "Number of instance nodes to provision"
}

variable "vpc_cidr" {
  description = "CIDR range of the the VPC"
}

variable "ami" {
  description = "AMI to use for nodes"
}

variable "instance_type" {
  description = "The instance size to use for nodes.  Will later add support for different sizes for master/compute nodes"
}

variable "key_name" {
  description = "The existing AWS keypair to use for SSH access."
}


