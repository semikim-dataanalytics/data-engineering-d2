# IAM role: gives Redshift cluster access to other AWS servies
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

# Allow Data API Usage (if custom policies needed, but standard role usually works if we use the right principal for the caller)
# Actually, the caller (Step Function) needs permission to call Redshift Data API.
# The Redshift Role needs permission to access S3 (done above) and Glue (for catalog access if using Spectrum/Lake Formation).
resource "aws_iam_role_policy_attachment" "redshift_glue_access" {
  role       = aws_iam_role.redshift_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}


# Redshift Serverless Namespace
resource "aws_redshiftserverless_namespace" "analytics" {
  namespace_name = "analytics-namespace"
  iam_roles      = [aws_iam_role.redshift_role.arn]
}

# Redshift Serverless Workgroup
resource "aws_redshiftserverless_workgroup" "analytics" {
  workgroup_name = "analytics-workgroup"
  namespace_name = aws_redshiftserverless_namespace.analytics.id
  base_capacity  = 32
}
