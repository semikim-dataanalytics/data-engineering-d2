# Modern Data Warehouse Foundation (Assignment D2)

This project demonstrates the design of a modern, serverless data warehouse
architecture on AWS using Infrastructure as Code (Terraform).

The objective is to consolidate data from operational databases into a
centralized analytics platform while minimizing operational overhead, avoiding
impact on production systems, and enforcing fine-grained data governance.

---

## Architecture Overview

The platform follows a decoupled, serverless architecture composed of distinct
ingestion, storage, processing, and analytics layers.

Data is replicated from an operational database into an Amazon S3 landing zone
using AWS Database Migration Service (DMS) with Full Load and Change Data Capture
(CDC). Raw data stored in S3 is cataloged and prepared using AWS Glue, then
loaded into Amazon Redshift Serverless for analytical querying.

AWS Lake Formation is used to enforce table- and column-level access control on
datasets registered in the Glue Data Catalog.

---

## End-to-End Data Flow

1. **Operational Database (Amazon RDS)**  
   Production systems store transactional data in an RDS database (e.g.,
   PostgreSQL or MySQL).

2. **Data Ingestion (AWS DMS – Full Load + CDC)**  
   AWS DMS performs an initial full data load and continuously captures changes
   (inserts, updates, deletes) using CDC, minimizing load on the source database.

3. **Landing Zone (Amazon S3)**  
   Replicated data is written to Amazon S3 in a raw format. S3 provides durable,
   cost-effective storage and decouples ingestion from downstream processing.

4. **Data Catalog & Orchestration (AWS Glue)**  
   Glue Crawlers catalog incoming data, and Glue Jobs or Workflows prepare data
   for analytics consumption.

5. **Analytics Layer (Amazon Redshift Serverless)**  
   Processed data is loaded into Redshift Serverless, enabling scalable
   analytics without managing clusters.

6. **Data Governance (AWS Lake Formation)**  
   Fine-grained access control is enforced at the database, table, and column
   levels based on IAM roles.

---

## Repository Structure

```text
DATA-ENGINEERING-D2/
├── iac/                         # Infrastructure as Code (Terraform)
│   ├── main.tf                  # AWS provider and core Terraform configuration
│   ├── variables.tf             # Input variables
│   ├── outputs.tf               # Terraform outputs
│   ├── redshift.tf              # Amazon Redshift Serverless resources
│   ├── dms.tf                   # AWS DMS (RDS → S3, Full Load + CDC)
│   └── lakeformation.tf         # Lake Formation data governance
│
├── sql/                         # SQL templates for CDC processing
│   ├── 01_create_tables.sql     # Staging and analytics table definitions
│   ├── 02_load_staging.sql      # Example S3 → Redshift load
│   └── 03_merge_orders.sql      # MERGE / UPSERT logic for CDC data
│
├── .gitignore                   # Git ignore rules (Terraform artifacts)
└── README.md                    # Project documentation
