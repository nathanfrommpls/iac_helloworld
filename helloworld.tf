provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

resource "aws_vpc" "helloworld" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "helloworld"
  }
}

resource "aws_internet_gateway" "helloworld" {
  vpc_id = "${aws_vpc.helloworld.id}"

  tags = {
    Name = "helloworld"
  }
}

resource "aws_subnet" "helloworld" {
  vpc_id     = "${aws_vpc.helloworld.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  depends_on = ["aws_internet_gateway.helloworld"]

  tags = {
    Name = "helloworld"
  }
}

resource "aws_route_table" "helloworld" {
  vpc_id = "${aws_vpc.helloworld.id}"

  tags = {
    Name = "helloworld"
  }
}

resource "aws_route" "helloworldegress" {
  route_table_id            = "${aws_route_table.helloworld.id}"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.helloworld.id}"
  depends_on                = ["aws_route_table.helloworld"]
}

resource "aws_route_table_association" "helloworld" {
  subnet_id      = "${aws_subnet.helloworld.id}"
  route_table_id = "${aws_route_table.helloworld.id}"
}


resource "aws_security_group" "helloworld" {
  name        = "helloworld"
  description = "Security group for helloworld terraform deployment."
  vpc_id      = "${aws_vpc.helloworld.id}"

  tags = {
    Name = "helloworld"
  }
}

resource "aws_security_group_rule" "helloworldssh" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = [ "0.0.0.0/0" ]
  security_group_id = "${aws_security_group.helloworld.id}"
}

resource "aws_security_group_rule" "helloworldhttp" {
  type            = "ingress"
  from_port       = 80 
  to_port         = 80
  protocol        = "tcp"
  cidr_blocks     = [ "0.0.0.0/0" ]
  security_group_id = "${aws_security_group.helloworld.id}"
}

resource "aws_security_group_rule" "helloworldegress" {
  type            = "egress"
  from_port       = 0
  to_port         = 65535
  protocol        = "-1"
  cidr_blocks     = [ "0.0.0.0/0" ]
  security_group_id = "${aws_security_group.helloworld.id}"
}

resource "aws_instance" "helloworld" {
  ami           = "ami-026c8acd92718196b" # Ubuntu 18.04 LTS on Nitro
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.helloworld.id}"
  vpc_security_group_ids = [ "${aws_security_group.helloworld.id}" ]
  private_ip = "10.0.1.5"
  depends_on = ["aws_internet_gateway.helloworld"]
  key_name = "redacted"

  tags = {
    Name = "helloworld"
  }
}

resource "aws_eip" "helloworld" {
  vpc = true
  instance = "${aws_instance.helloworld.id}"
  associate_with_private_ip = "10.0.1.5"
  depends_on = ["aws_internet_gateway.helloworld"]

  tags = {
    Name = "helloworld"
  }
}
