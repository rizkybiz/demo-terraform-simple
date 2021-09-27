# create a "Virtual Private Cloud" to serve
# as a network for our subsequent resources
resource "aws_vpc" "demo_vpc" {
  cidr_block           = var.ip_space
  enable_dns_hostnames = true
  tags = {
    name = "${var.prefix}-demo-vpc"
  }
}

# create a subnet within the VPC for our
# vm instance
resource "aws_subnet" "demo_subnet" {
  vpc_id     = aws_vpc.demo_vpc.id
  cidr_block = var.subnet_prefix
  tags = {
    name = "${var.prefix}-demo-subnet"
  }
}

# create a security group to allow certain types
# of traffic In/Out to our VM
resource "aws_security_group" "demo_security_group" {
  name   = "${var.prefix}-demo-ws-security-group"
  vpc_id = aws_vpc.demo_vpc.id

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
    name = "${var.prefix}-demo-web-server-security-group"
  }
}

# create an internet gateway to allow internet traffic
resource "aws_internet_gateway" "demo_internet_gw" {
  vpc_id = aws_vpc.demo_vpc.id
  tags = {
    name = "${var.prefix}-demo-internet-gateway"
  }
}

# create a route table for the VPC to allow traffic out
# to the open internet
resource "aws_route_table" "demo_route_table" {
  vpc_id = aws_vpc.demo_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_internet_gw.id
  }
  tags = {
    name = "${var.prefix}-demo-reoute-table"
  }
}

# create an elastic IP that will be associated with the
# VM instance we provision
resource "aws_eip" "demo_vm_eip" {
  instance = aws_instance.vm_1.id
  vpc      = true
  depends_on = [
    aws_internet_gateway.demo_internet_gw
  ]
}

# create an elastic IP association to associate the EIP
# with the VM instance
resource "aws_eip_association" "demo_vm_eip_assoc" {
  instance_id   = aws_instance.vm_1.id
  allocation_id = aws_eip.demo_vm_eip.id
}