############################
# DMS Replication Instance
############################
resource "aws_dms_replication_instance" "this" {
  replication_instance_id = "dms-replication-instance"
  replication_instance_class = "dms.t3.micro"
  allocated_storage = 20
  publicly_accessible = true
}

############################
# DMS Source Endpoint (RDS)
############################
resource "aws_dms_endpoint" "source" {
  endpoint_id   = "source-rds-endpoint"
  endpoint_type = "source"
  engine_name   = "postgres"

  username = "example_user"
  password = "example_password"
  server_name = "example-rds.amazonaws.com"
  port = 5432
  database_name = "example_db"
}

############################
# DMS Target Endpoint (S3)
############################
resource "aws_dms_endpoint" "target" {
  endpoint_id   = "target-s3-endpoint"
  endpoint_type = "target"
  engine_name   = "s3"

  s3_settings {
    bucket_name = "example-dms-landing-zone"
    bucket_folder = "raw"
    compression_type = "GZIP"
    data_format = "parquet"
  }
}

############################
# DMS Replication Task
############################
resource "aws_dms_replication_task" "this" {
  replication_task_id = "dms-full-load-cdc-task"
  migration_type = "full-load-and-cdc"

  replication_instance_arn = aws_dms_replication_instance.this.replication_instance_arn
  source_endpoint_arn     = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn     = aws_dms_endpoint.target.endpoint_arn

  table_mappings = jsonencode({
    rules = [{
      rule-type = "selection"
      rule-id   = "1"
      rule-name = "1"
      object-locator = {
        schema-name = "%"
        table-name  = "%"
      }
      rule-action = "include"
    }]
  })
}
