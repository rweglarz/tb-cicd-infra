output "MGT-IP-FW-1" {
  value = "${aws_eip.FW1-MGT.public_ip}"
}

output "MGT-IP-FW-2" {
  value = "${aws_eip.FW2-MGT.public_ip}"
}

