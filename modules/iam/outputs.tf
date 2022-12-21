output "frontend_role_arn" {
    value = aws_iam_role.frontend.arn
}

output "backend_role_arn" {
    value = aws_iam_role.backend.arn
}

output "data_role_arn" {
    value = aws_iam_role.data.arn
}

output "admin_role_arn" {
    value = aws_iam_role.admin.arn
}