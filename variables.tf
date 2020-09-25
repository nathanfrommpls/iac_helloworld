variable "sshkeypair" {
	default		= "id_rsa"
}

variable "ami_image" {
	default		= "ami-026c8acd92718196b" # Ubuntu 18.04 LTS on Nitro
}

variable "ec2_type" {
	default		= "t2.micro"
}

variable "myregion" {
	default		= "us-east-1"
}

variable "first_az" {
	default		= "us-east-1a"
}

variable "second_az" {
	default		= "us-east-1b"
}

variable "first_az_server_count" {
	default		= "1"
}

variable "second_az_server_count" {
	default		= "1"
}
