DROP TABLE IF EXISTS sales_paf_daily;
CREATE TABLE sales_paf_daily
(
  id bigserial NOT NULL PRIMARY KEY,
  date date NOT NULL,
  belongs_to date NOT NULL,
  value double precision,
  type character varying(1),
  sales_type_id bigint,
  location_id bigint NOT NULL,
  department_id bigint,
  count integer )
WITH (
  OIDS=FALSE
);

CREATE INDEX sales_paf_daily_type_idx ON sales_paf_daily (type);
CREATE INDEX sales_paf_daily_date_idx ON sales_paf_daily (date );

DROP TABLE IF EXISTS sales_paf_daily_log;
CREATE TABLE sales_paf_daily_log
(
  id serial NOT NULL PRIMARY KEY,
  last_id bigint NOT NULL, -- Last sales_paf.id processed
  timestamp timestamp NOT NULL,
  type char(1),
  belongs_to date )
WITH (  OIDS=FALSE );


/*
CREATE INDEX sales_paf_daily_date_idx ON sales_paf_daily (date );
CREATE INDEX sales_paf_daily_belongs_to_idx ON sales_paf_daily (belongs_to );
CREATE INDEX sales_paf_daily_dep_id_idx ON sales_paf_daily (department_id );
CREATE INDEX sales_paf_daily_location_id_idx ON sales_paf_daily (location_id );
CREATE INDEX sales_paf_daily_salestype_id_idx ON sales_paf_daily (sales_type_id );
*/


DO $$
DECLARE
  sql text;
BEGIN
FOR sql IN
WITH sales_paf_daily_partitions AS (
SELECT 
  'sales_paf_daily_'||type_code ||'_'|| to_char(yymm,'YYYYMM') AS partition_name,
  type_code,
  yymm::date,
  (yymm +  INTERVAL '1 MONTH - 1 day')::date AS yymm_end
FROM generate_series(
  '2011-01-01'::date, /* Specify the start date */
  '2014-12-01'::date, /* Specify the end date */
  '1 month') AS date_range(yymm)
CROSS JOIN unnest(ARRAY['a','f','p']) AS types(type_code) )
SELECT
'DROP TABLE IF EXISTS '||partition_name||';
CREATE TABLE IF NOT EXISTS '||partition_name||' (
  CHECK ( "type"='''||type_code||''' AND "date" BETWEEN DATE '''||to_char(yymm,'YYYY-MM-DD')
    ||''' AND DATE '''||to_char(yymm_end,'YYYY-MM-DD')||''' )
) INHERITS (sales_paf_daily);
CREATE INDEX '||partition_name||'_idx ON '||partition_name||' ("date");
CREATE INDEX '||partition_name||'_belongs_to_idx ON '||partition_name||' (belongs_to );
CREATE INDEX '||partition_name||'_dep_id_idx ON '||partition_name||' (department_id );
CREATE INDEX '||partition_name||'_location_id_idx ON '||partition_name||' (location_id );
CREATE INDEX '||partition_name||'_salestype_id_idx ON '||partition_name||' (sales_type_id );
' FROM sales_paf_daily_partitions LOOP
  RAISE NOTICE '== Executing: %s ...', sql;
  EXECUTE sql;
END LOOP;
END;$$

SELECT 
  type, 
  belongs_to, 
  MAX(id) max_id
FROM sales_paf
WHERE 
  (SELECT MAX(last_id) FROM sales_paf_daily_log) IS NULL
  OR id > (SELECT MAX(last_id) FROM sales_paf_daily_log) 
GROUP BY belongs_to, type
ORDER BY belongs_to, 3 DESC
LIMIT 1;
