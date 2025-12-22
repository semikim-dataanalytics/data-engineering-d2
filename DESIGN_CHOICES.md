# Design Choices & Trade-offs

## 1. Serverless Compute (Redshift Serverless)
**Choice**: Use Redshift Serverless instead of Provisioned Clusters.
**Reasoning**:
*   **Operational Overhead**: Removes the need to manage cluster maintenance, scaling, and pause/resume schedules.
*   **Cost Efficiency**: Ideal for sporadic workloads or development environments where the cluster isn't running 24/7. Auto-scaling handles bursts.

## 2. Decoupled Storage (S3 Landing Zone)
**Choice**: Stage data in S3 (Data Lake approach) before loading to Redshift.
**Reasoning**:
*   **Duralibity & Replayability**: If the warehouse needs to be rebuilt or a different tool needs access, the raw data is safely in S3.
*   **Cost**: S3 is cheaper than holding terabytes of raw historical data in Redshift storage.

## 3. Orchestration (Step Functions vs. Glue Workflows)
**Choice**: AWS Step Functions.
**Reasoning**:
*   **Redshift Data API Integration**: Step Functions has native integration with Redshift Data API, allowing mostly "wait-free" async execution (using `.sync` pattern) without managing JDBC connections in a Lambda or Glue script.
*   **Visibility**: Provides a visual graph of the workflow execution and failures.
*   **Cost**: Standard Step Functions are cheap for low-frequency batch jobs.

## 4. Ingestion (AWS DMS)
**Choice**: AWS DMS for CDC.
**Reasoning**:
*   **Real-time** capture of changes from the source DB without modifying the application code (unlike a dual-write approach).
*   **Reliability**: Managed service that handles replication logs and buffering.

## 5. Security (Lake Formation)
**Choice**: Lake Formation for permissions.
**Reasoning**:
*   **Granularity**: Provides centralized column-level access control, which is harder to manage with just IAM and database users alone.
*   **Scalability**: Policies can be applied to tags (LF-Tags) rather than just individual resources.
