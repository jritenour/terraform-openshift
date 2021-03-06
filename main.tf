provider "aws" {
  region = "${var.aws_region}"
}

# Create the VPC

resource "aws_vpc" "os-vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
}

# Attach internet gateway

resource "aws_internet_gateway" "os-gw" {
  vpc_id = "${aws_vpc.os-vpc.id}"
}

# Create openshift subnet
resource "aws_subnet" "os-subnet" {
  count = "${length(var.aws_zones)}"
  vpc_id = "${aws_vpc.os-vpc.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, 8, count.index)}"
  availability_zone = "${var.aws_zones[count.index]}"
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

#Create security group

resource "aws_security_group" "openshift-pub" {
  name        = "openshift-all"
  description = "Master public group for OpenShift"

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  vpc_id = "${aws_vpc.os-vpc.id}"
}


#Create nodes & bootstrap them w/ prereqs

resource "aws_instance" "node" {
  count         = "${var.instance_count}"
  ami           = "${var.ami}"
  subnet_id     = "${element(aws_subnet.os-subnet.*.id, count.index)}" 
  security_groups = [ "${aws_security_group.openshift-pub.id}" ]
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
#  user_data     = "${file("node-prep.sh")}"

  tags = {
    Name  = "os-node-${count.index + 1}"
  }
}

# Create master & kick off install
resource "aws_instance" "master" {
  ami           = "${var.ami}"
  subnet_id     = "${element(aws_subnet.os-subnet.*.id, count.index)}"
  security_groups = [ "${aws_security_group.openshift-pub.id}" ]
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
#  user_data     = "${file("master-prep.sh")}"

  tags = {
    Name  = "os-master"
  }
}
