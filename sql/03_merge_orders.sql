-- 1. Handle deletes
DELETE FROM orders
USING staging_orders s
WHERE orders.order_id = s.order_id
  AND s.op_type = 'D';

-- 2. Handle inserts and updates
MERGE INTO orders t
USING staging_orders s
ON t.order_id = s.order_id
WHEN MATCHED AND s.op_type = 'U' THEN
  UPDATE SET
    user_id = s.user_id,
    total_amount = s.total_amount,
    updated_at = s.op_timestamp
WHEN NOT MATCHED AND s.op_type = 'I' THEN
  INSERT (order_id, user_id, total_amount, updated_at)
  VALUES (s.order_id, s.user_id, s.total_amount, s.op_timestamp);
