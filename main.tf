resource "aws_vpc" "vnet" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "vpc_terraform"
  }

}
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vnet.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.assign_public_ip
  tags = {
    Name = "Public_subnet"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vnet.id
  tags = {
    Name = "internet_gateway"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vnet.id
  tags = {
    Name = "route_table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vnet.id
  name   = "security_group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "security_group"
  }
}
resource "aws_instance" "ec2_instance" {
  ami             = var.ami_id
  instance_type   = "t3.micro"
  subnet_id       = aws_subnet.subnet.id
  security_groups = [aws_security_group.sg.name]
  tags = {
    Name = "ec2_instance"
  }
}