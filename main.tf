# Wir mögen VIM, fast alle!!!
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Create a VPC
resource "aws_vpc" "vpc-thur" {
  cidr_block = "10.0.0.0/16"

tags = {
    Name = "VPC-THUR"
  }
}

  resource "aws_subnet" "private-subnet01" {
  vpc_id     = aws_vpc.vpc-thur.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "private-subnet01"
  }
}
  resource "aws_subnet" "public-subnet01" {
  vpc_id     = aws_vpc.vpc-thur.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "public-subnet02"
  }
}

resource "aws_internet_gateway" "igw01" {
  vpc_id = aws_vpc.vpc-thur.id

  tags = {
    Name = "IGW01"
  }
}

resource "aws_nat_gateway" "nat-gw01" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.private-subnet01.id
}

resource "aws_route_table" "public-rt01" {
  vpc_id = aws_vpc.vpc-thur.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw01.id
  }

  tags = {
    Name = "Public RT 01"
  }
}

resource "aws_route_table_association" "rt01" {
  subnet_id      = aws_subnet.public-subnet01.id
  route_table_id = aws_route_table.public-rt01.id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc-thur.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.vpc-thur.cidr_block]
  }

ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.vpc-thur.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls_http"
  }
}