# Minimal Terraform config for testing
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    key = "aws/ec2-deploy/terraform.tfstate"     
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "server" {
  ami                    = "ami-02d26659fd82cf299"
  instance_type          = "t2.micro"
  key_name              = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.maingroup.id]
  # Temporarily removed IAM instance profile
  
  tags = {
    "Name" = "DeployVM"
  }
}

resource "aws_security_group" "maingroup" {
  name = "main-security-group-test"
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
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
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = var.public_key
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.server.public_ip
  sensitive   = false
}