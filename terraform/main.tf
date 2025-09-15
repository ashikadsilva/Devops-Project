# Defines the AWS provider requirement. Configures Terraform remote state to s3
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

# Use AWS in the region specified by the region variable
provider "aws" {
  region = var.region
}

# Create IAM role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "DemoRoleForEC2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach basic policy to the role
resource "aws_iam_role_policy" "ec2_policy" {
  name = "ec2-basic-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_instance" "server" {
  ami                    = "ami-02d26659fd82cf299"
  instance_type          = "t2.micro"
  key_name              = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.maingroup.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2-profile.name
  
  tags = {
    "Name" = "DeployVM"
  }
  
  depends_on = [aws_iam_instance_profile.ec2-profile]
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_security_group" "maingroup" {
  name = "main-security-group"
  
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "All outbound traffic"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "SSH"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "HTTP"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    }
  ]
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