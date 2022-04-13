###
#   Ressourcen
#

# Externe Security Group 

resource "aws_security_group" "security" {
  name        = var.module

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # All other from myip
  ingress {
    from_port   = 22
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }  

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# VMs

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "vm" {
  ami                           = data.aws_ami.ubuntu.id  
  instance_type                 = lookup( var.instance_type, var.mem )
  associate_public_ip_address   = true
  user_data                     = base64encode(data.template_file.userdata.rendered)
  vpc_security_group_ids        = [aws_security_group.security.id]

  tags = {
    Name = var.module
  }
  
  root_block_device {
    volume_size = 32
  }
}

