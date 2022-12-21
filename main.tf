terraform {
    required_version = ">= 1.3.3"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"
        }
    }

    # TODO: For the ease of interiewing, I'm just using a local backend in the repo
    # This is not a good idea for production. 
    # Instead, use an S3 bucket backend with proper workspaces
    # Part of that will be breaking out "The creation of (global) IAM users" and "Using those users in the environment (1 per workspace)"
    # Which will enforce two separate Terraform deployment GH Actions
    backend "local" {
        path = "terraform.tfstate"
    }
}

data "aws_caller_identity" "current" {}

locals {
    aws_account_id = data.aws_caller_identity.current.account_id
}

/*
 * Environment specific IAM roles
 */

module "staging_iam" {
    source = "./modules/iam"
    environment = "Staging"
    aws_account_id = local.aws_account_id
}

module "prod_iam" {
    source = "./modules/iam"
    environment = "Prod"
    aws_account_id = local.aws_account_id
}

module "dev_iam" {
    source = "./modules/iam"
    environment = "Dev"
    aws_account_id = local.aws_account_id
}

resource "aws_iam_group" "developers" {
    name = "Developers"
}

# TODO: It could be possible to parameterize this enough to make it a couple of "for_each" loops
#       Or move this into the IAM modules and do one per workspace if we had separate accounts

# SREs are admins in all environments

resource "aws_iam_group" "SRE" {
    name = "SRE"
}

resource "aws_iam_policy" "admin_role" {
    name = "AdminRoleAssumption"
    path        = "/"
    description = "The SRE Admin role"
    policy = jsonencode(
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "",
                    "Effect": "Allow",
                    "Action": "sts:AssumeRole",
                    "Resource": [
                        module.staging_iam.admin_role_arn,
                        module.prod_iam.admin_role_arn, 
                        module.dev_iam.admin_role_arn
                    ]
                },
            ]
        }
    )
}

resource "aws_iam_group_policy_attachment" "sre_admin_attach" {
  group      = aws_iam_group.frontend_engineering.name
  policy_arn = aws_iam_policy.frontend_role.arn
}

# Frontend has cloudfront access in all environments

resource "aws_iam_group" "frontend_engineering" {
    name = "FrontendEngineering"
}

resource "aws_iam_policy" "frontend_role" {
    name = "FrontendRoleAssumption"
    path        = "/"
    description = "The frontend Engineering role"
    policy = jsonencode(
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "",
                    "Effect": "Allow",
                    "Action": "sts:AssumeRole",
                    "Resource": [
                        module.staging_iam.frontend_role_arn,
                        module.prod_iam.frontend_role_arn,
                        module.dev_iam.frontend_role_arn
                    ]
                },
            ]
        }
    )
}

resource "aws_iam_group_policy_attachment" "frontend_role_attach" {
  group      = aws_iam_group.frontend_engineering.name
  policy_arn = aws_iam_policy.frontend_role.arn
}

# Backend has EKS access in all environments

resource "aws_iam_group" "backend_engineering" {
    name = "BackendEngineering"
}

resource "aws_iam_policy" "backend_role" {
    name = "BackendRoleAssumption"
    path        = "/"
    description = "The backend Engineering role"
    policy = jsonencode(
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "",
                    "Effect": "Allow",
                    "Action": "sts:AssumeRole",
                    "Resource": [
                        module.staging_iam.backend_role_arn,
                        module.prod_iam.backend_role_arn,
                        module.dev_iam.backend_role_arn
                    ]
                },
            ]
        }
    )
}

resource "aws_iam_group_policy_attachment" "backend_role_attach" {
  group      = aws_iam_group.backend_engineering.name
  policy_arn = aws_iam_policy.backend_role.arn
}

# Data has access to the data lake in all environments

resource "aws_iam_group" "data_engineering" {
    name = "DataEngineering"
}

resource "aws_iam_policy" "data_role" {
    name = "DataRoleAssumption"
    path        = "/"
    description = "The data Engineering role"
    policy = jsonencode(
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "",
                    "Effect": "Allow",
                    "Action": "sts:AssumeRole",
                    "Resource": [
                        module.staging_iam.data_role_arn,
                        module.prod_iam.data_role_arn,
                        module.dev_iam.data_role_arn
                    ]
                },
            ]
        }
    )
}

resource "aws_iam_group_policy_attachment" "data_role_attach" {
  group      = aws_iam_group.data_engineering.name
  policy_arn = aws_iam_policy.data_role.arn
}



