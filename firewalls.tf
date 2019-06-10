resource "aws_network_interface" "FW1-MGT" {
  subnet_id         = "${aws_subnet.AZ1-MGT.id}"
  security_groups   = ["${aws_security_group.sgWideOpen.id}"]
  source_dest_check = false
  private_ips       = ["10.0.0.10"]
}

resource "aws_network_interface" "FW1-UNTRUST" {
  subnet_id         = "${aws_subnet.AZ1-UNTRUST.id}"
  security_groups   = ["${aws_security_group.sgWideOpen.id}"]
  source_dest_check = false
  private_ips       = ["10.0.1.10"]
}

resource "aws_network_interface" "FW1-TRUST" {
  subnet_id         = "${aws_subnet.AZ1-TRUST.id}"
  security_groups   = ["${aws_security_group.sgWideOpen.id}"]
  source_dest_check = false
  private_ips       = ["10.0.2.10"]
}

resource "aws_network_interface" "FW2-MGT" {
  subnet_id         = "${aws_subnet.AZ2-MGT.id}"
  security_groups   = ["${aws_security_group.sgWideOpen.id}"]
  source_dest_check = false
  private_ips       = ["10.0.10.10"]
}

resource "aws_network_interface" "FW2-UNTRUST" {
  subnet_id         = "${aws_subnet.AZ2-UNTRUST.id}"
  security_groups   = ["${aws_security_group.sgWideOpen.id}"]
  source_dest_check = false
  private_ips       = ["10.0.11.10"]
}

resource "aws_network_interface" "FW2-TRUST" {
  subnet_id         = "${aws_subnet.AZ2-TRUST.id}"
  security_groups   = ["${aws_security_group.sgWideOpen.id}"]
  source_dest_check = false
  private_ips       = ["10.0.12.10"]
}

resource "aws_eip_association" "FW1-UNTRUST-Association" {
  network_interface_id = "${aws_network_interface.FW1-UNTRUST.id}"
  allocation_id        = "${aws_eip.FW1-PUB.id}"
}

resource "aws_eip_association" "FW1-TRUST-Association" {
  network_interface_id = "${aws_network_interface.FW1-MGT.id}"
  allocation_id        = "${aws_eip.FW1-MGT.id}"
}

resource "aws_eip_association" "FW2-UNTRUST-Association" {
  network_interface_id = "${aws_network_interface.FW2-UNTRUST.id}"
  allocation_id        = "${aws_eip.FW2-PUB.id}"
}

resource "aws_eip_association" "FW2-TRUST-Association" {
  network_interface_id = "${aws_network_interface.FW2-MGT.id}"
  allocation_id        = "${aws_eip.FW2-MGT.id}"
}

#Deploys the firewalls

resource "aws_instance" "PA-VM1" {
  tags = {
    Name = "PA-AZ1"
  }

  disable_api_termination = false

  iam_instance_profile                 = "${aws_iam_instance_profile.FirewallBootstrapInstanceProfile2Tier.name}"
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized                        = true
  ami                                  = "${var.PANFWRegionMap[var.aws_region]}"
  instance_type                        = "m4.xlarge"

  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_type           = "gp2"
    delete_on_termination = true
    volume_size           = 60
  }

  key_name   = "${var.ServerKeyName}"
  monitoring = false

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.FW1-MGT.id}"
  }

  network_interface {
    device_index         = 1
    network_interface_id = "${aws_network_interface.FW1-UNTRUST.id}"
  }

  network_interface {
    device_index         = 2
    network_interface_id = "${aws_network_interface.FW1-TRUST.id}"
  }

  user_data = "${base64encode(join("", list("vmseries-bootstrap-aws-s3bucket=", var.MasterS3Bucket)))}"

  lifecycle {
    ignore_changes = ["user_data"]
  }
}

resource "aws_instance" "PA-VM2" {
  tags = {
    Name = "PA-AZ2"
  }

  disable_api_termination = false

  iam_instance_profile                 = "${aws_iam_instance_profile.FirewallBootstrapInstanceProfile2Tier.name}"
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized                        = true
  ami                                  = "${var.PANFWRegionMap[var.aws_region]}"
  instance_type                        = "m4.xlarge"

  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_type           = "gp2"
    delete_on_termination = true
    volume_size           = 60
  }

  key_name   = "${var.ServerKeyName}"
  monitoring = false

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.FW2-MGT.id}"
  }

  network_interface {
    device_index         = 1
    network_interface_id = "${aws_network_interface.FW2-UNTRUST.id}"
  }

  network_interface {
    device_index         = 2
    network_interface_id = "${aws_network_interface.FW2-TRUST.id}"
  }

  user_data = "${base64encode(join("", list("vmseries-bootstrap-aws-s3bucket=", var.MasterS3Bucket)))}"

  lifecycle {
    ignore_changes = ["user_data"]
  }
}
