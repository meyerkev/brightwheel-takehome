/*
 * Setup IAM for an environment
 * TODO: Figure out a resource tagging story, then copy all those pre-made AWS policies into this module
 * And make them only apply to things tagged with the Environment: Prod OR Staging OR Dev tag individually
 */

resource "aws_iam_role" "frontend" {
    name = "Frontend${var.environment}"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    AWS = "arn:aws:iam::${var.aws_account_id}:root"
                }
            }
        ]
    })

    managed_policy_arns = [
        "arn:aws:iam::aws:policy/CloudFrontFullAccess"
    ]
}

resource "aws_iam_role" "backend" {
    name = "Backend${var.environment}"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    AWS = "arn:aws:iam::${var.aws_account_id}:root"
                }
            }
        ]
    })

    # EKS is special because they don't give us a full access policy
    # So no managed_policy_arns here
}

# TODO: So I KNOW this won't be enough
# Among other things, I suespect you'd want Fargate and/or EC2 permissions
# 
# If you wanted this to be testable, we'd need 30-45 minutes to turn up the Cluster
# in a 2-hour interview.  I'm not sure that's reasonable.
# I like EKS, but cluster provisioning is a weak spot.
# 
# Which, funnily enough, is also true of Redshift and that is my personal fault. 
# Sorry, but it saved us $400MM of EC2 spend annually.  
resource "aws_iam_role_policy" "eks_admin" {
    name = "EKSAccess${var.environment}"
    role = aws_iam_role.backend.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "eks:*",
                ]
                Effect   = "Allow"
                Resource = "*"
            },
        ]
    })
}


resource "aws_iam_role" "data" {
    name = "Data${var.environment}"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    AWS = "arn:aws:iam::${var.aws_account_id}:root"
                }
            }
        ]
    })

    managed_policy_arns = [
        "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
    ]
}

resource "aws_iam_role" "admin" {
    name = "Admin${var.environment}"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    AWS = "arn:aws:iam::${var.aws_account_id}:root"
                }
            }
        ]
    })

    managed_policy_arns = [
        "arn:aws:iam::aws:policy/AdministratorAccess"
    ]
}