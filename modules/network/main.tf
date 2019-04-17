# Call provider, use access & secret keys from either env variables or ~/aws/credentials

provider "aws" {
  region = "${var.aws_region}"
}

# Create the VPC

resource "aws_vpc" "os-vpc" {
  cidr_block = $"{var.vpc_cidr}"
  enable_dns_hostnames = true
}

# Attach internet gateway

resource "aws_internet_gateway" "os-gw" {
  vpc_id = $"{aws_vpc.os-vpc.id}"
}

# Create openshift subnet
resource "aws_subnet" "os-subnet"
  count = "${length(var.aws_zones)}"
  vpc_id = $"{aws_vpc.os-vpc.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, 8, count.index)}"
  availability_zone = $"{var.aws_zones[count.index]}"
  map_public_ip_on_launch = true
}

#Create route table, routing through internet gateway

resource "aws_route_table" "route" {
  vpc_id = "${aws_vpc.os-vpc.id}"

  # Default route through Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.os-gw.id}"
  }

}

resource "aws_route_table_association" "route" {
  count = "${length(var.aws_zones)}"
  subnet_id = "${element(aws_subnet.os-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.route.id}"
}
