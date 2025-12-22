# DMS Replication Instance
resource "aws_dms_replication_instance" "this" {
  replication_instance_id    = "dms-replication-instance"
  replication_instance_class = "dms.t3.micro"
  allocated_storage          = 20
  publicly_accessible        = true
  vpc_security_group_ids     = [aws_security_group.rds_sg.id] # Allow access to RDS
}

# Source Endpoint (RDS)
resource "aws_dms_endpoint" "source" {
  endpoint_id   = "source-rds-endpoint"
  endpoint_type = "source"
  engine_name   = "postgres"

  username      = aws_db_instance.source.username
  password      = aws_db_instance.source.password
  server_name   = aws_db_instance.source.address
  port          = aws_db_instance.source.port
  database_name = aws_db_instance.source.db_name
}

# Target Endpoint (S3)
resource "aws_dms_endpoint" "target" {
  endpoint_id   = "target-s3-endpoint"
  endpoint_type = "target"
  engine_name   = "s3"

  s3_settings {
    bucket_name      = aws_s3_bucket.landing_zone.bucket
    bucket_folder    = "raw"
    compression_type = "GZIP"
    data_format      = "parquet"
    service_access_role_arn = aws_iam_role.dms_s3_role.arn # DMS needs a role to write to S3
  }
}


# DMS Replication Task
resource "aws_dms_replication_task" "this" {
  replication_task_id      = "dms-full-load-cdc-task"
  migration_type           = "full-load-and-cdc"
  replication_instance_arn = aws_dms_replication_instance.this.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.target.endpoint_arn

  table_mappings = jsonencode({
    rules = [{
      rule-type = "selection"
      rule-id   = "1"
      rule-name = "1"
      object-locator = {
        schema-name = "public"
        table-name  = "%"
      }
      rule-action = "include"
    }]
  })
}
