# Lake Formation Settings
resource "aws_lakeformation_data_lake_settings" "this" {
  admins = [
    aws_iam_role.redshift_role.arn
  ]
}


# Example IAM Role representing a data consumer (e.g., analyst).
resource "aws_iam_role" "analyst_role" {
  name = "lf-analyst-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "redshift.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}


# Database-level Permission: Allows the analyst role to discover and describe metadata
# within the specified database.
# Note: These permissions require the database and table to exist in the Glue/Redshift Catalog first.
# For the initial deployment, we comment them out.

# resource "aws_lakeformation_permissions" "analyst_db_access" {
#   principal   = aws_iam_role.analyst_role.arn
#   permissions = ["DESCRIBE"]
#
#   database {
#     name = "analytics_db"
#   }
# }

# resource "aws_lakeformation_permissions" "analyst_table_access" {
#   principal   = aws_iam_role.analyst_role.arn
#   permissions = ["SELECT"]
#
#   table {
#     database_name = "analytics_db"
#     name          = "orders"
#   }
# }

# resource "aws_lakeformation_permissions" "analyst_column_access" {
#   principal   = aws_iam_role.analyst_role.arn
#   permissions = ["SELECT"]
#
#   table_with_columns {
#     database_name = "analytics_db"
#     name          = "orders"
#     column_names  = ["order_id", "user_id", "total_amount"]
#   }
# }
