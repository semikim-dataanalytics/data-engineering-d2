resource "aws_iam_role" "redshift_role" {
  name = "redshift-serverless-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "redshift.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "redshift_s3_access" {
  role       = aws_iam_role.redshift_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_redshiftserverless_namespace" "analytics" {
  namespace_name = "analytics-namespace"
  iam_roles      = [aws_iam_role.redshift_role.arn]
}

resource "aws_redshiftserverless_workgroup" "analytics" {
  workgroup_name = "analytics-workgroup"
  namespace_name = aws_redshiftserverless_namespace.analytics.id
  base_capacity  = 32
}
