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

# create an EC2 instance to serve as the compute
# for our web server
resource "aws_instance" "vm_1" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.demo_key_pair.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.demo_subnet.id
  vpc_security_group_ids      = [aws_security_group.demo_security_group.id]

  tags = {
    name = "${var.prefix}-demo-vm-1"
  }
}

# lets use some "one-timey" "hand-wavey" magic to
# copy over the index.html local file and use shell
# to install some deps
resource "null_resource" "configure-web-server" {
  depends_on = [
    aws_eip_association.demo_vm_eip_assoc
  ]
  triggers = {
    build_number = timestamp()
  }

  provisioner "file" {
    source      = "./files"
    destination = "/home/ubuntu"
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
      "chmod +x *.sh",
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