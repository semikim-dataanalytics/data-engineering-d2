# Security Group for Step Function (not explicitly needed for Data API but good practice if in VPC)
# We will rely on Data API which is public endpoint accessible via IAM.

# IAM Role for Step Functions
resource "aws_iam_role" "step_functions_role" {
  name = "redshift-etl-workflow-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Policy to allow Step Functions to use Redshift Data API
resource "aws_iam_policy" "sfn_redshift_policy" {
  name = "sfn-redshift-data-api-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "redshift-data:ExecuteStatement",
          "redshift-data:GetStatementResult",
          "redshift-data:DescribeStatement",
          "redshift-data:ListStatements"
        ]
        Resource = "*" # Can scope down to specific workgroup ARN
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sfn_redshift_attach" {
  role       = aws_iam_role.step_functions_role.name
  policy_arn = aws_iam_policy.sfn_redshift_policy.arn
}

# State Machine
resource "aws_sfn_state_machine" "etl_workflow" {
  name     = "redshift-etl-workflow"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = jsonencode({
    Comment = "Orchestrate Redshift ETL: Load from S3 -> Staging -> Merge to Final",
    StartAt = "LoadStaging",
    States = {
      LoadStaging = {
        Type = "Task",
        Resource = "arn:aws:states:::aws-sdk:redshiftdata:executeStatement",
        Parameters = {
          ClusterIdentifier = null, 
          WorkgroupName = aws_redshiftserverless_workgroup.analytics.workgroup_name,
          Database = "dev", # Default DB name in Redshift Serverless is often 'dev'
          # We inject the SQL command.
          Sql = "COPY staging_orders FROM 's3://${aws_s3_bucket.landing_zone.bucket}/raw/orders/' IAM_ROLE '${aws_iam_role.redshift_role.arn}' FORMAT AS PARQUET;"
        },
        Next = "MergeData"
      },
      MergeData = {
        Type = "Task",
        Resource = "arn:aws:states:::aws-sdk:redshiftdata:executeStatement",
        Parameters = {
          WorkgroupName = aws_redshiftserverless_workgroup.analytics.workgroup_name,
          Database = "dev", 
           # Simplification for demo: Hardcoding typical Merge logic or reading from file
          Sql = "BEGIN; DELETE FROM orders USING staging_orders s WHERE orders.order_id = s.order_id AND s.op_type = 'D'; MERGE INTO orders t USING staging_orders s ON t.order_id = s.order_id WHEN MATCHED AND s.op_type = 'U' THEN UPDATE SET user_id = s.user_id, total_amount = s.total_amount, updated_at = s.op_timestamp WHEN NOT MATCHED AND s.op_type = 'I' THEN INSERT (order_id, user_id, total_amount, updated_at) VALUES (s.order_id, s.user_id, s.total_amount, s.op_timestamp); END;"
        },
        End = true
      }
    }
  })
}

# Scheduler (EventBridge)
resource "aws_scheduler_schedule" "etl_schedule" {
  name = "redshift-etl-schedule"
  
  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "rate(1 hour)" # Access variable for schedule if needed

  target {
    arn      = aws_sfn_state_machine.etl_workflow.arn
    role_arn = aws_iam_role.step_functions_role.arn # Reusing for simplicity, or create separate invoker role
  }
}

# Allow Scheduler to invoke Step Function
resource "aws_iam_policy" "scheduler_invoke_sfn" {
  name = "scheduler-invoke-sfn"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "states:StartExecution"
      Resource = aws_sfn_state_machine.etl_workflow.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "scheduler_invoke_attach" {
  role       = aws_iam_role.step_functions_role.name 
  policy_arn = aws_iam_policy.scheduler_invoke_sfn.arn
}
