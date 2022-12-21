# TODO: Provision users in all groups
# Every user is a member of the Developers group as well as their own group

# Everything below here should be considered an example and honestly an unoptimized, disorganized one at that
# And might or might not be data objects
resource "aws_iam_user" "fe_dev" {
    name = "fe-dev"
}

resource "aws_iam_user" "backend_dev" {
    name = "backend-dev"
}

resource "aws_iam_user" "data_dev" {
    name = "data-dev"
}

resource "aws_iam_user" "sre_dev" {
    name = "sre-dev"
}

resource "aws_iam_group_membership" "frontend_engineering" {
    name = "frontend-eng-membership"
    users = [
        aws_iam_user.fe_dev.name
    ]
    
    group = aws_iam_group.frontend_engineering.name
}

resource "aws_iam_group_membership" "backend_engineering" {
    name = "backend-eng-membership"
    users = [
        aws_iam_user.backend_dev.name
    ]
    
    group = aws_iam_group.backend_engineering.name
}

resource "aws_iam_group_membership" "data_engineering" {
    name = "data-eng-membership"
    users = [
        aws_iam_user.data_dev.name
    ]
    
    group = aws_iam_group.data_engineering.name
}

resource "aws_iam_group_membership" "sre" {
    name = "sre-membership"
    users = [
        aws_iam_user.sre_dev.name
    ]
    
    group = aws_iam_group.frontend_engineering.name
}

resource "aws_iam_group_membership" "developers" {
    name = "developers-membership"
    users = [
        aws_iam_user.fe_dev.name,
        aws_iam_user.backend_dev.name,
        aws_iam_user.data_dev.name,
        aws_iam_user.sre_dev.name
    ]
    
    group = aws_iam_group.developers.name
}