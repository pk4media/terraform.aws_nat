# Allow VPC traffic to go through the NAT
resource "aws_security_group" "nat" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "NAT security group"

  tags {
    Name = "${var.name}"
    Environment = "${var.environment}"
    Service = "nat"
  }

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "template_file" "nat" {
  template = "${file(concat(path.module, "/nat.conf.tpl"))}"

  vars {
    vpc_cidr = "${var.vpc_cidr}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Use the latest ubuntu trusty AMI for the selected region
module "ami" {
  source        = "github.com/terraform-community-modules/tf_aws_ubuntu_ami/ebs"
  instance_type = "${var.instance_type}"
  region        = "${var.region}"
  distribution  = "trusty"
}

# Launch NAT instances
resource "aws_instance" "nat" {
  count         = "${length(split(",", var.public_subnets))}"

  subnet_id     = "${element(split(",", var.subnet_ids), count.index)}"

  ami           = "${module.ami.ami_id}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.ec2_key_name}"

  user_data     = "${template_file.nat.rendered}"

  source_dest_check      = false

  vpc_security_group_ids = [
  "${var.bastion_security_group_id}",
  "${aws_security_group.nat.id}"
  ]

  tags {
    Name = "${var.name}"
    Environment = "${var.environment}"
    Service = "nat"
  }

  connection {
    user         = "${var.user}"
    host         = "${self.private_ip}"
    private_key  = "${var.private_key}"
    bastion_host = "${var.bastion_host}"
    bastion_user = "${var.bastion_user}"
  }

  provisioner "remote-exec" {
    inline = [
    "while sudo pkill -0 cloud-init 2>/dev/null; do sleep 2; done"
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "nat" {
  count  = "${length(split(",", var.public_subnets))}"

  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    #nat_gateway_id = "${element(split(",", var.nat_gateway_ids), count.index)}"
    instance_id = "${element(aws_instance.nat.*.id, count.index)}"
  }

  tags {
    Name        = "${var.name}"
    Environment = "${var.environment}"
    Service     = "nat"
  }

  lifecycle {
    create_before_destroy = true
  }
}
