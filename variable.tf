# AWS Region Configuration
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}

# GitHub OIDC Configuration
variable "github_repo_owner" {
  description = "GitHub repository owner/organization name"
  type        = string
}

variable "github_repo_name" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch name allowed to assume the role"
  type        = string
  default     = "main"
}

# IAM Role and Policy Names
variable "iam_role_name" {
  description = "Name of the IAM role for GitHub Actions"
  type        = string
  default     = "TerraformGitHubRole"
}

variable "iam_policy_name" {
  description = "Name of the inline policy attached to the GitHub Actions role"
  type        = string
  default     = "TerraformPolicy"
}

# Infrastructure Configuration Variables
variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

variable "subnet_cidr_block" {
  description = "CIDR block for subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for resources"
  type        = string
}

variable "assign_public_ip" {
  description = "Assign public IP to instances in subnet"
  type        = bool
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2 instance"
  type        = string
}
