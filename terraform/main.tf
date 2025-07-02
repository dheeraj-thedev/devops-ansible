# Tell Terraform we're using AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
 
# Configure AWS provider
provider "aws" {
  region = var.aws_region
}
 
# Get available zones
data "aws_availability_zones" "available" {
  state = "available"
}
 
# Create a Virtual Private Cloud (like your own private network in AWS)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}
 
# Create Internet Gateway (allows internet access)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}
 
# Create a public subnet (where our servers will live)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}
 
# Create route table (traffic rules)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}
 
# Associate subnet with route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
 
# Create security group (firewall rules)
resource "aws_security_group" "web_servers" {
  name_prefix = "${var.project_name}-web-"
  vpc_id      = aws_vpc.main.id
  # Allow SSH (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow HTTP (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow Jenkins (port 8080)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow Kubernetes API (port 6443)
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}-web-sg"
  }
}
 
# Create Jenkins server
resource "aws_instance" "jenkins" {
  ami                    = var.ami_id
  instance_type          = "t3.medium"
  key_name              = var.key_name
  subnet_id             = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_servers.id]
  tags = {
    Name = "${var.project_name}-jenkins"
    Type = "CI/CD"
  }
}
 
# Create Kubernetes master server
resource "aws_instance" "k8s_master" {
  ami                    = var.ami_id
  instance_type          = "t3.medium"
  key_name              = var.key_name
  subnet_id             = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_servers.id]
  tags = {
    Name = "${var.project_name}-k8s-master"
    Type = "Kubernetes"
  }
}
 
# Create Kubernetes worker servers
resource "aws_instance" "k8s_worker" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = "t3.medium"
  key_name              = var.key_name
  subnet_id             = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_servers.id]
  tags = {
    Name = "${var.project_name}-k8s-worker-${count.index + 1}"
    Type = "Kubernetes"
  }
}