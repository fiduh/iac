provider "aws" {
  region = "us-east-1"
  profile = "oidc"
}


terraform {
  required_version = "1.9.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "brains-backend"
    region = "us-east-1"
    key    = "environments/staging/ec2/terraform.tfstate"
    dynamodb_table = "dynamodb_lock"
    encrypt        = true
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical #more changes here
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "EC2 from gitlab CI"
  }
}
