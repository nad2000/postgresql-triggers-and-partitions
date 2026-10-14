-- SELECT update_sales_paf_daily();
-- rollback;
/*
SELECT update_sales_paf_daily();
SELECT * FROM sales_paf_daily_log ORDER BY belongs_to DESC;
*/



SELECT MAX(belongs_to) INOT v_belongs_to FROM sales_paf_daily_log;
FOREACH v_type IN ARRAY ARRAY['a','f','p']
LOOP
  RAISE NOTICE 'type = %', v_type;
END LOOP;
END;
$$

*/

-- DELETE FROM sales_paf_daily_log;
-- INSERT INTO sales_paf_daily_log (last_id,belongs_to) VALUES (0, date '2010-01-01');
/*

DO $$
DECLARE v_type varchar;
BEGIN
FOREACH v_type IN ARRAY ARRAY['a','f','p']
LOOP
  RAISE NOTICE 'type = %', v_type;
END LOOP;
END;
$$

*/

-- SELECT max(belongs_to) FROM sales_paf_daily;