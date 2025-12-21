-- Example COPY command from S3 into staging table
-- (Executed after Glue catalogs the data)

COPY staging_orders
FROM 's3://example-dms-landing-zone/raw/orders/'
IAM_ROLE 'arn:aws:iam::123456789012:role/redshift-serverless-role'
FORMAT AS PARQUET;
