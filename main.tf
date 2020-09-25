# AWS Account and Network Infrastructure

resource "aws_vpc" "helloworld" {
	cidr_block		= "10.0.0.0/16"

	tags = {
		Name		= "helloworld"
	}
}

resource "aws_internet_gateway" "helloworld" {
	vpc_id			= aws_vpc.helloworld.id

	tags = {
		Name		= "helloworld"
	}
}

resource "aws_subnet" "helloworld1" {
	vpc_id			= aws_vpc.helloworld.id
	cidr_block		= "10.0.1.0/24"
	map_public_ip_on_launch	= true
	availability_zone	= var.first_az

	depends_on = [ aws_internet_gateway.helloworld ]

	tags = {
		Name		= "helloworld"
	}
}

resource "aws_subnet" "helloworld2" {
	vpc_id			= aws_vpc.helloworld.id
	cidr_block		= "10.0.2.0/24"
	map_public_ip_on_launch = true
	availability_zone	= var.second_az

	depends_on		= [ aws_internet_gateway.helloworld ]

	tags = {
		Name		= "helloworld"
	}
}

resource "aws_route_table" "helloworld" {
	vpc_id			= aws_vpc.helloworld.id

	tags = {
		Name		= "helloworld"
	}
}

resource "aws_route" "helloworldegress" {
	route_table_id          = aws_route_table.helloworld.id
	destination_cidr_block  = "0.0.0.0/0"
	gateway_id		= aws_internet_gateway.helloworld.id
	depends_on              = [ aws_route_table.helloworld ]
}

resource "aws_route_table_association" "helloworld1" {
	subnet_id		= aws_subnet.helloworld1.id
	route_table_id		= aws_route_table.helloworld.id
}

resource "aws_route_table_association" "helloworld2" {
	subnet_id		= aws_subnet.helloworld2.id
	route_table_id		= aws_route_table.helloworld.id
}


resource "aws_security_group" "helloworld" {
	name			= "helloworld"
	description		= "Security group for helloworld terraform deployment."
	vpc_id			= aws_vpc.helloworld.id

	tags = {
		Name = "helloworld"
	}
}

resource "aws_security_group_rule" "helloworldssh" {
	type			= "ingress"
	from_port		= 22
	to_port			= 22
	protocol		= "tcp"
	cidr_blocks		= [ "0.0.0.0/0" ]
	security_group_id	= aws_security_group.helloworld.id
}

resource "aws_security_group_rule" "helloworldhttp" {
	type			= "ingress"
	from_port		= 80 
	to_port			= 80
	protocol		= "tcp"
	cidr_blocks		= [ "0.0.0.0/0" ]
	security_group_id	= aws_security_group.helloworld.id
}

resource "aws_security_group_rule" "helloworldegress" {
	type			= "egress"
	from_port		= 0
	to_port			= 65535
	protocol		= "-1"
	cidr_blocks		= [ "0.0.0.0/0" ]
	security_group_id	= aws_security_group.helloworld.id
}

# AWS Instances & Associated Infrastructure

resource "aws_instance" "helloworldfirst" {
	count			= var.first_az_server_count
	ami			= var.ami_image
	instance_type		= var.ec2_type
	subnet_id		= aws_subnet.helloworld1.id
	vpc_security_group_ids	= [ aws_security_group.helloworld.id ]
	depends_on		= [ aws_internet_gateway.helloworld ]
	key_name		= var.sshkeypair
	user_data		= file("apachesetup.sh")

	tags = {
		Name		= "helloworld"
	}
}

resource "aws_instance" "helloworldsecond" {
	count			= var.second_az_server_count
	ami			= var.ami_image
	instance_type		= var.ec2_type
	subnet_id		= aws_subnet.helloworld2.id
	vpc_security_group_ids	= [ aws_security_group.helloworld.id ]
	depends_on		= [ aws_internet_gateway.helloworld ]
	key_name		= var.sshkeypair
	user_data		= file("apachesetup.sh")

	tags = {
		Name		= "helloworld"
	}
}

# Exposing individual systems for testing purposes.

resource "aws_eip" "helloworldfirst" {
	count				= var.first_az_server_count
	vpc				= true
	instance			= aws_instance.helloworldfirst[count.index].id
	associate_with_private_ip	= aws_instance.helloworldfirst[count.index].private_ip
	depends_on 			= [ aws_internet_gateway.helloworld ]

	tags = {
		Name = "helloworld"
	}
}

#resource "aws_eip" "helloworldsecond" {
#	count				= var.second_az_server_count
#	vpc				= true
#	instance			= aws_instance.helloworldsecond[count.index].id
#	associate_with_private_ip	= aws_instance.helloworldsecond[count.index].private_ip
#	depends_on			= [ aws_internet_gateway.helloworld ]
#
#	tags = {
#		Name			= "helloworld"
#	}
#}

resource "aws_elb" "helloworld" {
	name				= "helloworld"
	security_groups			= [ aws_security_group.helloworld.id ]

	listener {
		instance_port		= 80
		instance_protocol	= "http"
		lb_port			= 80
		lb_protocol		= "http"
	}

	subnets = [ aws_subnet.helloworld1.id , aws_subnet.helloworld2.id ]

	cross_zone_load_balancing	= true
	idle_timeout			= 400
	connection_draining		= true
	connection_draining_timeout	= 400

	tags = {
		Name			= "helloworld"
	}
}

resource "aws_elb_attachment" "helloworld1" {
	count				= var.first_az_server_count
	elb				= aws_elb.helloworld.id
	instance			= aws_instance.helloworldfirst[count.index].id
}

resource "aws_elb_attachment" "helloworld2" {
	count				= var.second_az_server_count
	elb				= aws_elb.helloworld.id
	instance			= aws_instance.helloworldsecond[count.index].id
}
