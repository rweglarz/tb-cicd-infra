resource "aws_network_interface" "web1-int" {
  subnet_id         = "${aws_subnet.AZ1-TRUST.id}"
  security_groups   = ["${aws_security_group.sgWideOpen.id}"]
  source_dest_check = false
  private_ips       = ["10.0.2.50"]
}


data "template_file" "config" {
  template = <<EOF
#!/bin/bash
yum update -y
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd mariadb-server
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo "Webserver1" > /var/www/html/phpinfo.php
until $(curl -sSL -k --output /dev/null --silent --head --fail https://jenkins.minimal.net.au:8083); do printf '.' sleep 5 done
curl -sSL -k --header "authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoidGhiZWF1bW9udEBwYWxvYWx0b25ldHdvcmtzLmNvbSIsInJvbGUiOiJhZG1pbiIsImdyb3VwcyI6bnVsbCwicHJvamVjdHMiOm51bGwsInNlc3Npb25UaW1lb3V0U2VjIjo4NjQwMCwiZXhwIjoxNTY2OTg4NTU3LCJpc3MiOiJ0d2lzdGxvY2sifQ.aAUW-AdIUJU3y1g3-Y3s6jW574rmpKfHsG9NXC01v_Q" https://jenkins.minimal.net.au:8083/api/v1/scripts/defender.sh | sudo bash -s -- -c "jenkins.minimal.net.au" -d "none"  --install-host
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

  user_data = "${data.template_file.config.rendered}"
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

  user_data = "${data.template_file.config.rendered}"

}
