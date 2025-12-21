-- Staging table for CDC data
CREATE TABLE IF NOT EXISTS staging_orders (
    order_id       INT,
    user_id        INT,
    total_amount   DOUBLE PRECISION,
    op_type        CHAR(1),        -- I, U, D
    op_timestamp   TIMESTAMP
);

-- Final analytics table
CREATE TABLE IF NOT EXISTS orders (
    order_id       INT PRIMARY KEY,
    user_id        INT,
    total_amount   DOUBLE PRECISION,
    updated_at     TIMESTAMP
);
