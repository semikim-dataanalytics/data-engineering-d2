# IAM role: gives Redshift cluster access to other AWS servies
# (e.g., access data from S3 bucket)
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

# Redshift Serverless Namespace: represents logical containers for
# databases, users, and IAM roles.
resource "aws_redshiftserverless_namespace" "analytics" {
  namespace_name = "analytics-namespace"
  iam_roles      = [aws_iam_role.redshift_role.arn]
}

# Redshift Serverless Workgroup: where queries are executed
# base_capacity defines the mininum compute capacity for analytics workloads.
resource "aws_redshiftserverless_workgroup" "analytics" {
  workgroup_name = "analytics-workgroup"
  namespace_name = aws_redshiftserverless_namespace.analytics.id
  base_capacity  = 32
}
