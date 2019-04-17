
resource "aws_instance" "node" {
  count         = "${var.instance_count}"
  ami           = "${lookup(var.ami,var.aws_region)}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
  user_data     = "${file("node-prep.sh")}"

  tags = {
    Name  = "os-node-${count.index + 1}"
  }
}

resource "aws_instance" "master" {
  count         = "${var.instance_count}"
  ami           = "${lookup(var.ami,var.aws_region)}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
  user_data     = "${file("master-prep.sh")}"

  tags = {
    Name  = "os-master"
  }
}
