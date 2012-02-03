-- ALTER TABLE sales_paf DROP CONSTRAINT IF EXISTS sales_paf_pkey;
/*
ALTER TABLE sales_paf DROP CONSTRAINT IF EXISTS fkfb0bc2e22f61b826;
ALTER TABLE sales_paf DROP CONSTRAINT IF EXISTS fkfb0bc2e2554fc127;
ALTER TABLE sales_paf DROP CONSTRAINT IF EXISTS fkfb0bc2e2aafb8987;
ALTER TABLE sales_paf DROP CONSTRAINT IF EXISTS fkfb0bc2e2b73c3f74;
*/

-- TRUNCATE TABLE sales_paf;

DO $$
DECLARE
  v_date date;
BEGIN

SELECT ( max(belongs_to)+ INTERVAL '1 day')::date INTO v_date FROM sales_paf_daily;
v_date := COALESCE( v_date, now()::date );

INSERT INTO sales_paf(
  date, belongs_to, start_time, end_time, 
  value, type, sales_type_id, who_id, location_id, 
  department_id, deleted, 
  starttimestamp, endtimestamp, count)
SELECT
  ts.ts::date, ts.ts::date, se.se, se.se + INTERVAL '42 minutes',
  random()*1000+10, t.t, ( l.l+bt.bt ) % 4+1, ( l.l+bt.bt ) % 4+1, ( l.l+bt.bt ) % 3+1, 
  ( l.l+bt.bt*4 ) % 3 + ( l.l+bt.bt ) % 2+1, 'N',
  se.se+ INTERVAL '24 minutes', se.se + INTERVAL '42 minutes', (random()*10+1)::int
FROM unnest(ARRAY['a','f','p']) as t(t) 
CROSS JOIN unnest(ARRAY[1,2,3]) as bt(bt)
CROSS JOIN unnest(ARRAY[1,2,3]) as l(l) 
CROSS JOIN (SELECT v FROM generate_series(1,10) AS r(v) ORDER BY random()) AS r
CROSS JOIN generate_series( v_date, v_date + INTERVAL '3 months', '1 day') AS ts(ts)
CROSS JOIN generate_series( v_date, v_date + INTERVAL '13 minutes', '1 min') AS se(se);

END;$$



