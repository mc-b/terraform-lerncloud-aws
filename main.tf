data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# Hole Default VPC
data "aws_vpc" "default" {
  default = true
}

# Hole zugehörige Subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group für alle Instanzen
resource "aws_security_group" "security" {
  name   = var.module
  vpc_id = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    from_port   = 22
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["172.0.0.0/8"]
  }

  ingress {
    from_port   = 22
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["172.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2-Instanzen in gemeinsamer VPC/Subnet
resource "aws_instance" "vm" {
  for_each = var.machines

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = lookup(var.instance_type, coalesce(each.value.memory, var.memory))
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.security.id]
  subnet_id                   = data.aws_subnets.default.ids[0]
  user_data                   = each.value.userdata

  tags = {
    Name        = each.value.hostname
    Description = coalesce(each.value.description, var.description)
  }

  root_block_device {
    volume_size = coalesce(each.value.storage, var.storage)
  }
}
