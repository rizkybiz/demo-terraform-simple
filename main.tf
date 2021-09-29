terraform {

  # setup the AWS provider
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}

# configure the AWS provider
provider "aws" {
  region = var.region
}

# create a security group to allow certain types
# of traffic In/Out to our VM
resource "aws_security_group" "demo_security_group" {
  name = "${var.prefix}-demo-ws-security-group"

  ingress {
    description = "TLS into VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP intp VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH into VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "${var.prefix}-demo-web-server-security-group"
  }
}

# create an EC2 instance to serve as the compute
# for our web server
resource "aws_instance" "vm_1" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.demo_key_pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.demo_security_group.id]

  tags = {
    Name = "${var.prefix}-demo-vm-1"
  }
}

# lets use some "one-timey" "hand-wavey" magic to
# copy over the index.html local file and use shell
# to install some deps
resource "null_resource" "configure-web-server" {
  triggers = {
    build_number = timestamp()
  }

  provisioner "file" {
    source      = "./files/setup.sh"
    destination = "/home/ubuntu/setup.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.priv_key_path)
      host        = aws_instance.vm_1.public_ip
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt -y update",
      "sleep 15",
      "sudo apt -y update",
      "sudo apt -y install apache2",
      "sudo systemctl start apache2",
      "sudo chown -R ubuntu:ubuntu /var/www/html",
      "sudo ls -ll -a",
      "chmod +x setup.sh",
      "PLACEHOLDER=${var.placeholder} WIDTH=${var.width} HEIGHT=${var.height} PREFIX=${var.prefix} ./setup.sh",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.priv_key_path)
      host        = aws_instance.vm_1.public_ip
    }
  }
}