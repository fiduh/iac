# Provider Configuration
provider "aws" {
  region = "us-east-1"
}

# Resource 1: IAM Group
resource "aws_iam_group" "developers" {
  name = "developers"  # Name of the IAM group
  path = "/users/"     # Path for the IAM group in AWS
}

# Resource 2: IAM User
resource "aws_iam_user" "dev1" {
  name          = "dev1"          # Name of the IAM user
  path          = "/users/"       # Path for the IAM user in AWS
  force_destroy = true            # Allow Terraform to delete the user even if it has non-terraform-managed resources like access keys
}

# Resource 3: IAM User Login Profile
resource "aws_iam_user_login_profile" "this" {
  user                    = aws_iam_user.dev1.name  # Associate the login profile with the user created above
  password_reset_required = true                    # Require the user to reset their password upon first login
}

# Resource 4: IAM User Group Membership
resource "aws_iam_user_group_membership" "this" {
  user   = aws_iam_user.dev1.name                  # IAM user to be added to the group
  groups = [aws_iam_group.developers.name]         # Group(s) the user should be a member of
}

# Data Source 1: IAM Policy Document
data "aws_iam_policy_document" "developer_policy" {
  statement {
    effect    = "Allow"                            # Policy effect, in this case allowing actions
    actions   = [                                  # List of actions this policy allows
      "ec2:*",                                     # All actions for EC2 service
      "dynamodb:*"                                 # All actions for DynamoDB service
    ]
    resources = ["*"]                              # Applies the policy to all resources
  }
}

# Resource 5: IAM Group Policy
resource "aws_iam_group_policy" "group_developer_policy" {
  name   = "group_developer_policy"                # Name of the IAM group policy
  group  = aws_iam_group.developers.name           # Attach the policy to the developers group
  policy = data.aws_iam_policy_document.developer_policy.json  # The policy document from the data source
}


################################################################
# Create User and Policy
################################################################
# Resource 1: IAM User
resource "aws_iam_user" "dev2" {
  name = "dev2"  # Name of the IAM user
}

# Resource 2: IAM Access Key
resource "aws_iam_access_key" "dev2" {
  user = aws_iam_user.dev2.name  # Access key for the IAM user "dev2"
}

# Data Source 1: IAM Policy Document
data "aws_iam_policy_document" "dev2" {
  statement {
    effect    = "Allow"          # Policy effect, in this case allowing actions
    actions   = [                # List of actions this policy allows
      "ec2:*"                    # All actions for EC2 service
    ]
    resources = ["*"]            # Applies the policy to all resources
  }
}

# Resource 3: IAM User Policy
resource "aws_iam_user_policy" "dev2_policy" {
  name   = "test"                            # Name of the IAM user policy
  user   = aws_iam_user.dev2.name            # Attach the policy to the IAM user "dev2"
  policy = data.aws_iam_policy_document.dev2.json  # The policy document from the data source
}
