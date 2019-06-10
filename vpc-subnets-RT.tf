# Declare the data source
#data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

# Subnets
resource "aws_subnet" "AZ1-TRUST" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags = {
    Name = "AZ1-TRUST"
  }
}

resource "aws_subnet" "AZ1-UNTRUST" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags = {
    Name = "AZ1-UNTRUST"
  }
}

resource "aws_subnet" "AZ1-MGT" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.0.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags = {
    Name = "AZ1-MGT"
  }
}

resource "aws_subnet" "AZ2-TRUST" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.12.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags = {
    Name = "AZ2-TRUST"
  }
}

resource "aws_subnet" "AZ2-UNTRUST" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.11.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags = {
    Name = "AZ2-UNTRUST"
  }
}

resource "aws_subnet" "AZ2-MGT" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.10.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags = {
    Name = "AZ2-MGT"
  }
}
