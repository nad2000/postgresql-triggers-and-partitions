CREATE OR REPLACE FUNCTION update_sales_paf_daily() RETURNS void AS $$
DECLARE 
  v_from_id bigint;
  v_to_id bigint;
  v_last_id bigint;
  v_belongs_to date;
  v_partition_name varchar;
  v_type varchar;
BEGIN

SELECT MAX(last_id) INTO v_last_id FROM sales_paf_daily_log;
IF v_last_id IS NOT NULL THEN
  SELECT MIN(id) INTO v_from_id FROM sales_paf WHERE id > v_last_id;
ELSE
  SELECT MIN(id) INTO v_from_id FROM sales_paf;
END IF;

IF v_from_id IS NULL THEN
  RETURN;
END IF;

SELECT belongs_to INTO v_belongs_to FROM sales_paf WHERE id = v_from_id;
SELECT MAX(id) INTO v_to_id FROM sales_paf WHERE belongs_to = v_belongs_to AND id>v_last_id;

FOREACH v_type IN ARRAY ARRAY['a','f','p'] LOOP

SELECT sales_paf_daily_partition_name(v_type,v_belongs_to) INTO v_partition_name;
-- v_partition_name := sales_paf_daily_partition_name(v_type,v_belongs_to);

EXECUTE 'WITH daily AS (
SELECT 
  belongs_to, type, sales_type_id, location_id, department_id,
  SUM(value) AS value, SUM(count) AS count
FROM sales_paf
WHERE
  id BETWEEN '||v_from_id||' AND '||v_to_id||'
  AND belongs_to= DATE '''||to_char(v_belongs_to,'YYYY-MM-DD')||'''
  AND type='''||v_type||'''
GROUP BY belongs_to, type, sales_type_id, location_id, department_id),
with_previous AS (SELECT d.*, p.value AS previous_value, p.count AS previous_count 
FROM daily AS d LEFT JOIN sales_paf_daily AS p
ON p.belongs_to=d.belongs_to AND p.type=d.type AND p.sales_type_id=d.sales_type_id
  AND p.location_id=d.location_id AND p.department_id=d.department_id),
ins AS (
INSERT INTO '||v_partition_name||'
 (belongs_to, type, sales_type_id, location_id, department_id,value,count)
 SELECT belongs_to, type, sales_type_id, location_id, department_id,value,count
 FROM with_previous WHERE previous_count IS NULL AND previous_value IS NULL
 RETURNING * )
UPDATE '||v_partition_name||' AS d
SET
  value = d.value+p.value,
  count = d.count+p.count
FROM with_previous AS p
WHERE 
  ( p.previous_count IS NOT NULL OR p.previous_value IS NOT NULL)
  AND p.belongs_to=d.belongs_to AND p.type=d.type AND p.sales_type_id=d.sales_type_id
  AND p.location_id=d.location_id AND p.department_id=d.department_id;';

END LOOP;

INSERT INTO sales_paf_daily_log (last_id,belongs_to) VALUES (v_to_id, v_belongs_to);

END;
$$ LANGUAGE plpgsql;

/*
-- First run:
DO $$
DECLARE
  v_belongs_to date;
BEGIN
LOOP
  SELECT MAX(belongs_to) INTO v_belongs_to FROM sales_paf_daily_log;
  PERFORM update_sales_paf_daily();
  IF v_belongs_to = (SELECT MAX(belongs_to) FROM sales_paf_daily_log) THEN
    EXIT;
  END IF;
END LOOP;
END;$$
*/

