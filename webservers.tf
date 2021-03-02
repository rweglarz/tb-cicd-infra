resource "aws_network_interface" "web1-int" {
  subnet_id         = "${aws_subnet.AZ1-TRUST.id}"
  security_groups   = ["${aws_security_group.sgWideOpen.id}"]
  source_dest_check = false
  private_ips       = ["10.0.2.50"]
}


data "template_file" "configweb1" {
  template = <<EOF
#!/bin/bash
apt-get update -y
apt-get install -y apache2
systemctl start apache2
systemctl enable apache2
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo "Webserver 1" > /var/www/html/index.html
EOF
}

data "template_file" "configweb2" {
  template = <<EOF
#!/bin/bash
apt-get update -y
apt-get install -y apache2
systemctl start apache2
systemctl enable apache2
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo "Webserver 2" > /var/www/html/index.html
EOF
}

resource "aws_instance" "web1" {
  instance_initiated_shutdown_behavior = "stop"
  ami                                  = "${var.UbuntuRegionMap[var.aws_region]}"
  instance_type                        = "t3.micro"
  key_name                             = "${var.ServerKeyName}"
  ebs_optimized 		       = false

  tags = {
    Name = "WEB-AZ1"
  }

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.web1-int.id}"
  }

  user_data = "${data.template_file.configweb1.rendered}"
}

resource "aws_network_interface" "web2-int" {
  subnet_id         = "${aws_subnet.AZ2-TRUST.id}"
  security_groups   = ["${aws_security_group.sgWideOpen.id}"]
  source_dest_check = false
  private_ips       = ["10.0.12.50"]
}

resource "aws_instance" "web2" {
  instance_initiated_shutdown_behavior = "stop"
  ami                                  = "${var.UbuntuRegionMap[var.aws_region]}"
  instance_type                        = "t3.micro"
  ebs_optimized                        = false

  key_name   = "${var.ServerKeyName}"
  monitoring = false

  tags = {
    Name = "WEB-AZ2"
  }

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.web2-int.id}"
  }

  user_data = "${data.template_file.configweb2.rendered}"

}
