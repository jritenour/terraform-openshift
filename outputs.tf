output "node_ips" {
  value = ["${aws_instance.node.*.public_ip}"]
}

output "master_ips" {
  value = ["${aws_instance.master.*.public_ip}"]
}
