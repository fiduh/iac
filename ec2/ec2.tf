# AWS provider configuration
provider "aws" {
  region = "us-east-1"
}

# Data source to dynamically find the most recent Ubuntu AMI (Amazon Machine Image)
data "aws_ami" "ubuntu" {
  most_recent = true # Ensure the most recent AMI is selected
  
  # Filter AMIs by name pattern for Ubuntu 22.04 (Jammy) LTS
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  # Filter for hardware virtualization type "hvm" (Hardware Virtual Machine)
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical's AWS account ID
}

# EC2 instance resource configuration
resource "aws_instance" "this" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.this.name # Attach the IAM instance profile for S3 access

  tags = {
    Name = "testEC2"
  }
}

# IAM instance profile to attach to the EC2 instance
resource "aws_iam_instance_profile" "this" {
  name = "ec2_profile"
  role = aws_iam_role.role.name # Role that the instance profile will use
}

# IAM policy document for assuming a role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service" # Define the principal type as a service
      identifiers = ["ec2.amazonaws.com"] # Specify EC2 as the service allowed to assume the role
    }

    actions = ["sts:AssumeRole"] # Allow the STS action AssumeRole
  }
}

# IAM role that the EC2 instance will assume
resource "aws_iam_role" "role" {
  name               = "ec2_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json # JSON policy document to allow EC2 to assume the role
}

# IAM policy document for S3 access
data "aws_iam_policy_document" "policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = [
      "arn:aws:s3:::*",         # Any S3 Bucket
      "arn:aws:s3:::*/*"        # All objects in any S3 Bucket
    ]
  }
}

# IAM policy resource to manage S3 access
resource "aws_iam_policy" "policy" {
  name        = "s3-policy"
  description = "A test S3 policy"
  policy      = data.aws_iam_policy_document.policy.json # JSON policy document defining the permissions
}

# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}