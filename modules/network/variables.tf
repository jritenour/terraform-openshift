
variable aws_region {
  type = "string"
  description = "Which AWS region to use"
}

variable aws_zones {
  type = "list"
  description = "Availability zones within region to use"
}


variable vpc_cidr {
  type = "string"
  description = "CIDR IP range of VPC"
}
