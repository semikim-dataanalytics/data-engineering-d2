# Modern Data Warehouse Foundation (Assignment D2)

This project demonstrates the design of a modern, serverless data warehouse architecture on AWS using Infrastructure as Code (Terraform).

The objective is to consolidate data from operational databases into a centralized analytics platform while minimizing operational overhead, avoiding impact on production systems, and enforcing fine-grained data governance.

## Architecture Overview

The platform follows a decoupled, serverless architecture composed of distinct ingestion, storage, processing, and analytics layers.

1.  **Operational Database (Amazon RDS)**: Production systems store transactional data in a PostgreSQL RDS database.
2.  **Data Ingestion (AWS DMS)**: A replication task performs an initial full load and continuous Change Data Capture (CDC) from RDS to Amazon S3.
3.  **Landing Zone (Amazon S3)**: Data is stored in `parquet` format in an S3 bucket.
4.  **Data Catalog (AWS Glue)**: A Glue Crawler automatically discovers schema changes and updates the Glue Data Catalog.
5.  **Orchestration (AWS Step Functions)**: A state machine orchestrates the ETL process:
    *   Triggers Redshift Data API to `COPY` data from S3 to a staging table.
    *   Executes a `MERGE` operation to upsert data into the final `orders` table.
6.  **Analytics (Amazon Redshift Serverless)**: Provides the compute engine for querying the data.
7.  **Governance (AWS Lake Formation)**: Manages fine-grained access control (column-level) for data consumers.

## Deployment Instructions

### Prerequisites
*   Terraform >= 1.3.0
*   AWS CLI configured
*   **Account Requirements**:
    *   Service-linked role for DMS (`dms-vpc-role`).
    *   Active subscription/eligibility for Redshift Serverless.
    *   VPC with valid subnets.

### Steps
1.  Navigate to `iac/` directory:
    ```bash
    cd iac
    ```
2.  Initialize and apply Terraform:
    ```bash
    terraform init
    terraform apply
    ```
3.  **Post-Deployment Setup (One-time)**:
    *   Run the SQL in `sql/01_create_tables.sql` in Redshift Query Editor v2 to create the target tables (`staging_orders`, `orders`).

### Data Flow
1.  **Ingest**: Insert data into the RDS instance. DMS captures this and writes to `s3://<bucket>/raw/orders/`.
2.  **Catalog**: The Glue Crawler (scheduled or triggered) updates the Data Catalog.
3.  **Load**: The EventBridge Scheduler triggers the Step Function.
4.  **Process**:
    *   Step Function calls `copy_staging` (Redshift Data API).
    *   Step Function calls `merge_data` (Redshift Data API).
5.  **Analyze**: Users query the `orders` table in Redshift.

## Permissions Model (Lake Formation)

*   **Admins**: Full access (defined in `lakeformation.tf`).
*   **Analyst Role**:
    *   Database: `DESCRIBE` on `analytics_db`.
    *   Table: `SELECT` on `orders`.
    *   **Column-level security**: Restricted access. Can only select `order_id`, `user_id`, `total_amount` (PII/sensitive columns excluded).

## Directory Structure
*   `iac/`: Terraform configuration files.
    *   `main.tf`, `variables.tf`, `outputs.tf`: Core Terraform config.
    *   `rds.tf`: Source PostgreSQL database.
    *   `dms.tf`, `dms_iam.tf`: Data Migration Service and its IAM roles.
    *   `s3.tf`: S3 Landing Zone (with random suffix).
    *   `crawler.tf`: AWS Glue Crawler.
    *   `redshift.tf`: Redshift Serverless and IAM.
    *   `workflow.tf`: Step Functions and Scheduler.
    *   `lakeformation.tf`: Data governance settings.
*   `sql/`: SQL scripts for table creation and logic reference.
