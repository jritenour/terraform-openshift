output "subnet_id" {
    description = "ID of the OpenShift subnet"
    value = "${aws_subnet.os-subnet.*.id}"
}

output "vpc_id" {
    description = "VPC ID"
    value = "${aws_vpc.os-vpc.id}"
}
