DROP TABLE IF EXISTS sales_paf_daily CASCADE;
CREATE TABLE sales_paf_daily
(
  id bigserial NOT NULL PRIMARY KEY,
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
-- CREATE INDEX sales_paf_daily_date_idx ON sales_paf_daily (date );

DROP TABLE IF EXISTS sales_paf_daily_log;
CREATE TABLE sales_paf_daily_log
(
  id serial NOT NULL PRIMARY KEY,
  last_id bigint NOT NULL UNIQUE, -- Last sales_paf.id processed
  timestamp timestamp NOT NULL DEFAULT current_timestamp,
  belongs_to date )
WITH (  OIDS=FALSE );


/*
CREATE INDEX sales_paf_daily_date_idx ON sales_paf_daily (date );
CREATE INDEX sales_paf_daily_belongs_to_idx ON sales_paf_daily (belongs_to );
CREATE INDEX sales_paf_daily_dep_id_idx ON sales_paf_daily (department_id );
CREATE INDEX sales_paf_daily_location_id_idx ON sales_paf_daily (location_id );
CREATE INDEX sales_paf_daily_salestype_id_idx ON sales_paf_daily (sales_type_id );
*/

CREATE OR REPLACE FUNCTION sales_paf_daily_partition_name( varchar, date)
RETURNS varchar
AS $$ SELECT 'sales_paf_daily_'||$1||'_'|| to_char($2,'YYYYMM');$$
LANGUAGE SQL;
-- SELECT sales_paf_daily_partition_name( 'a', '2013-03-13');

DO $$
DECLARE
  sql text;
  v_from_date date := '2008-01-01'::date; /* Specify the start date */
  v_to_date date := '2014-12-01'::date; /* Specify the end date */
BEGIN
FOR sql IN
WITH sales_paf_daily_partitions AS (
SELECT 
  sales_paf_daily_partition_name(type_code::varchar,yymm::date) AS partition_name,
  type_code,
  yymm::date,
  (yymm +  INTERVAL '1 MONTH - 1 day')::date AS yymm_end
FROM generate_series(
  v_from_date,
  v_to_date,
  '1 month') AS date_range(yymm)
CROSS JOIN unnest(ARRAY['a','f','p']) AS types(type_code) )
SELECT
'-- DROP TABLE IF EXISTS '||partition_name||';
CREATE TABLE IF NOT EXISTS '||partition_name||' (
  CHECK ( "type"='''||type_code||''' AND belongs_to BETWEEN DATE '''||to_char(yymm,'YYYY-MM-DD')
    ||''' AND DATE '''||to_char(yymm_end,'YYYY-MM-DD')||''' )
) INHERITS (sales_paf_daily);
CREATE INDEX '||partition_name||'_belongs_to_idx ON '||partition_name||' (belongs_to );
CREATE INDEX '||partition_name||'_dep_id_idx ON '||partition_name||' (department_id );
CREATE INDEX '||partition_name||'_location_id_idx ON '||partition_name||' (location_id );
CREATE INDEX '||partition_name||'_salestype_id_idx ON '||partition_name||' (sales_type_id );
' FROM sales_paf_daily_partitions LOOP
  -- RAISE NOTICE '== Executing: %s ...', sql;
  BEGIN
    EXECUTE sql;
  EXCEPTION 
    WHEN duplicate_table OR duplicate_object THEN
    -- do nothing
  END;    
END LOOP;

WITH sales_paf_daily_partitions AS (
SELECT 
  sales_paf_daily_partition_name(type_code::varchar,yymm::date) AS partition_name,
  type_code,
  yymm::date,
  (yymm +  INTERVAL '1 MONTH - 1 day')::date AS yymm_end
FROM generate_series(
  v_from_date,
  v_to_date,
  '1 month') AS date_range(yymm)
CROSS JOIN unnest(ARRAY['a','f','p']) AS types(type_code) )
SELECT string_agg(
'IF ( NEW."type"='''||type_code||''' AND NEW.belongs_to BETWEEN DATE '''||to_char(yymm,'YYYY-MM-DD')
    ||''' AND DATE '''||to_char(yymm_end,'YYYY-MM-DD')||''' ) THEN
  INSERT INTO '||partition_name||' VALUES (NEW.*);', '
ELS') INTO sql FROM sales_paf_daily_partitions;
sql := 'CREATE OR REPLACE FUNCTION sales_paf_daily_insert_trigger()
RETURNS TRIGGER AS $SQL$
BEGIN ' || sql || '
    ELSE
        RAISE EXCEPTION ''Date out of range. Increase number of partitions!'';
    END IF;
    RETURN NULL;
END;
$SQL$
LANGUAGE plpgsql;';
 
RAISE NOTICE '== Executing: % ...', sql;
EXECUTE sql;

END;$$

CREATE TRIGGER sales_paf_daily_insert_trigger
  BEFORE INSERT ON sales_paf_daily
  FOR EACH ROW EXECUTE PROCEDURE sales_paf_daily_insert_trigger();

/*
-- SELECT * FROM sales_paf_daily limit 1;
INSERT INTO  sales_paf_daily
(belongs_to,value,type,sales_type_id,location_id,department_id,count) 
 VALUES
 ('2014-01-27',208743.191503733,'f',3,1,1,2493);

SELECT * FROM sales_paf_daily ORDER BY id DESC LIMIT 10;
SELECT * FROM sales_paf_daily_f_201201 ORDER BY id DESC LIMIT 10;
SELECT * FROM sales_paf_daily_f_201401 ORDER BY id DESC LIMIT 10;

*/