--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: scheduler; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE scheduler WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


ALTER DATABASE scheduler OWNER TO postgres;

\connect scheduler

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: att_agg_totals; Type: TYPE; Schema: public; Owner: ressystems
--

CREATE TYPE att_agg_totals AS (
	att_shifts bigint,
	att_hours bigint,
	att_cost numeric
);


ALTER TYPE public.att_agg_totals OWNER TO ressystems;

--
-- Name: att_shift_hours_cost; Type: TYPE; Schema: public; Owner: ressystems
--

CREATE TYPE att_shift_hours_cost AS (
	att_shifts bigint,
	att_hours numeric,
	att_cost numeric
);


ALTER TYPE public.att_shift_hours_cost OWNER TO ressystems;

--
-- Name: att_sum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE att_sum AS (
	at_duration bigint,
	at_cost numeric,
	at_ot_duration bigint,
	at_ot_cost numeric,
	at_db_ot_duration bigint,
	at_db_ot_cost numeric
);


ALTER TYPE public.att_sum OWNER TO postgres;

--
-- Name: forecast_tb_totals; Type: TYPE; Schema: public; Owner: ressystems
--

CREATE TYPE forecast_tb_totals AS (
	ftb_shifts bigint,
	ftb_hours double precision
);


ALTER TYPE public.forecast_tb_totals OWNER TO ressystems;

--
-- Name: numberof_dd_ww_mm_yy; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE numberof_dd_ww_mm_yy AS (
	days bigint,
	weeks double precision,
	months double precision,
	years double precision
);


ALTER TYPE public.numberof_dd_ww_mm_yy OWNER TO postgres;

--
-- Name: path_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE path_type AS (
	dep_path text,
	dep_hi_name text,
	dep_level text
);


ALTER TYPE public.path_type OWNER TO postgres;

--
-- Name: sch_agg_totals; Type: TYPE; Schema: public; Owner: ressystems
--

CREATE TYPE sch_agg_totals AS (
	sch_shifts bigint,
	sch_hours double precision,
	sch_sales_cost double precision
);


ALTER TYPE public.sch_agg_totals OWNER TO ressystems;

--
-- Name: sch_shift_hours_cost; Type: TYPE; Schema: public; Owner: ressystems
--

CREATE TYPE sch_shift_hours_cost AS (
	sch_shifts bigint,
	sch_hours numeric,
	sch_cost numeric
);


ALTER TYPE public.sch_shift_hours_cost OWNER TO ressystems;

--
-- Name: sch_sum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE sch_sum AS (
	sch_duration double precision,
	sch_cost double precision
);


ALTER TYPE public.sch_sum OWNER TO postgres;

--
-- Name: aliasordescription(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION aliasordescription(alias_ text, description text) RETURNS text
    LANGUAGE plpgsql
    AS $$
   BEGIN 
       IF alias_ IS NOT NULL AND length(alias_) > 0 THEN 
           RETURN alias_;
       END IF;
       RETURN description;
   END;
  $$;


ALTER FUNCTION public.aliasordescription(alias_ text, description text) OWNER TO postgres;

--
-- Name: armor(bytea); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION armor(bytea) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_armor';


ALTER FUNCTION public.armor(bytea) OWNER TO ressystems;

--
-- Name: att_emp_totals(bigint, date, date); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION att_emp_totals(bigint, date, date) RETURNS att_sum
    LANGUAGE sql
    AS $_$
    SELECT sum(ti.regular_duration), sum(ti.regular_cost), sum(ti.ot_duration), sum(ti.ot_cost), sum(ti.double_ot_duration), sum(ti.double_ot_cost)
         FROM attendance_block as ti
         WHERE ti.employee_id = $1
         AND ti.start_date >= $2 AND ti.start_date <= $3
         AND ti.deleted='N';
$_$;


ALTER FUNCTION public.att_emp_totals(bigint, date, date) OWNER TO ressystems;

--
-- Name: att_emp_totals_bydep(bigint, date, date, bigint); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION att_emp_totals_bydep(bigint, date, date, bigint) RETURNS att_sum
    LANGUAGE sql
    AS $_$
    SELECT sum(ti.regular_duration), sum(ti.regular_cost), sum(ti.ot_duration), sum(ti.ot_cost), sum(ti.double_ot_duration), sum(ti.double_ot_cost)
         FROM attendance_block as ti
         WHERE ti.employee_id = $1
         AND ti.department_id = $4
         AND ti.start_date >= $2 AND ti.start_date <= $3
         AND ti.deleted='N';
$_$;


ALTER FUNCTION public.att_emp_totals_bydep(bigint, date, date, bigint) OWNER TO ressystems;

--
-- Name: att_emppos_totals(bigint, bigint, bigint, date, date); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION att_emppos_totals(bigint, bigint, bigint, date, date) RETURNS att_sum
    LANGUAGE sql
    AS $_$
    SELECT sum(ti.regular_duration), sum(ti.regular_cost), sum(ti.ot_duration), sum(ti.ot_cost), sum(ti.double_ot_duration), sum(ti.double_ot_cost)
         FROM attendance_block as ti
         WHERE ti.location_id = $1
         AND ti.employee_id = $2
         AND ti.position_id = $3
         AND ti.start_date >= $4 AND ti.start_date <= $5
         AND ti.deleted='N';
$_$;


ALTER FUNCTION public.att_emppos_totals(bigint, bigint, bigint, date, date) OWNER TO ressystems;

--
-- Name: att_emppos_totals_bydep(bigint, bigint, bigint, date, date, bigint); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION att_emppos_totals_bydep(bigint, bigint, bigint, date, date, bigint) RETURNS att_sum
    LANGUAGE sql
    AS $_$
    SELECT sum(ti.regular_duration), sum(ti.regular_cost), sum(ti.ot_duration), sum(ti.ot_cost), sum(ti.double_ot_duration), sum(ti.double_ot_cost)
         FROM attendance_block as ti
         WHERE ti.location_id = $1
         AND ti.department_id = $6
         AND ti.employee_id = $2
         AND ti.position_id = $3
         AND ti.start_date >= $4 AND ti.start_date <= $5
         AND ti.deleted='N';
$_$;


ALTER FUNCTION public.att_emppos_totals_bydep(bigint, bigint, bigint, date, date, bigint) OWNER TO ressystems;

--
-- Name: att_shift_hours_cost_function(bigint, date, date, bigint, bigint, bigint[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION att_shift_hours_cost_function(bigint, date, date, bigint, bigint, dep bigint[]) RETURNS att_shift_hours_cost
    LANGUAGE plpgsql
    AS $_$
   DECLARE ret att_shift_hours_cost;
   DECLARE total att_shift_hours_cost;
   DECLARE array_len int;
   BEGIN
      total.att_shifts :=0;
      total.att_hours :=0;
      total.att_cost :=0;
      ret.att_shifts :=0;
      ret.att_hours :=0;
      ret.att_cost :=0;
      IF dep IS NOT NULL THEN         
         array_len := array_upper(DEP, 1);
         FOR i IN 1 .. array_len
         LOOP
            SELECT count(id)
            ,sum( EXTRACT(EPOCH FROM ( (LEAST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES', to_timestamp(end_date || ' ' || end_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp - 
            GREATEST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES', to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp) / 60 ) ) )  AS p_minutes
            
            ,sum( total_cost * ( 
            (
            EXTRACT(EPOCH FROM ( (LEAST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES', to_timestamp(end_date || ' ' || end_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp - 
            GREATEST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES', to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp) / 60 ) ) /
            EXTRACT(EPOCH FROM ( (to_timestamp(end_date || ' ' || end_time, 'YYYY-mm-DD HH24:MI:SS')::timestamp - 
            to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS')::timestamp) / 60 ) )
            )
            )) AS period_expense INTO ret
            
            FROM attendance_block as ti
            WHERE ti.location_id = $1
            AND ti.department_id IN (DEP[i])
            AND ti.deleted = 'N'
            AND ti.allocated_date between $2 AND $3
            AND 
            (to_timestamp(end_date || ' ' || ti.end_time, 'YYYY-mm-DD HH24:MI:SS') >= to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES' 
            AND to_timestamp(start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS') < to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES'
            )
            AND end_date IS NOT NULL
            AND ((start_time < end_time and end_date = allocated_date) or (start_time = end_time and start_date != end_date) or (end_time < start_time and allocated_date < end_date));
            IF ret.att_shifts IS NOT NULL THEN
               total.att_shifts := total.att_shifts + ret.att_shifts;
            END IF;
            IF ret.att_hours IS NOT NULL THEN
               total.att_hours := total.att_hours + ret.att_hours;
            END IF;
            IF ret.att_cost IS NOT NULL THEN
               total.att_cost := total.att_cost + ret.att_cost;
            END IF;
         END LOOP;
         --------------------------------------------------------------------------------
         --------------------------------------------------------------------------------
         FOR j IN 1 .. array_len
         LOOP
            SELECT count(ti.id)
	    ,CAST(sum( EXTRACT(EPOCH FROM ( (LEAST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES', current_timestamp)::timestamp - 
            GREATEST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES', to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp) / 60 ) ) )  AS bigint) AS p_minutes
	    --(below is dynamically calculated interval of ) [ cost * duration ]
            ,sum( CASE 
            WHEN em_po.payrate is not null and em_po.payscale = 0 THEN
            ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*em_po.payrate)/3600) * ( 
            (
            EXTRACT(EPOCH FROM ( (LEAST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES', current_timestamp)::timestamp - 
            GREATEST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES', to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp) / 60 ) ) /
            EXTRACT(EPOCH FROM ( (current_timestamp::timestamp - 
            to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS')::timestamp) / 60 ) )
            ))
            WHEN em_po.payrate is not null and em_po.payscale != 0 THEN
	    ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*em_po.hourlyrate)/3600) * ( 
            (
            EXTRACT(EPOCH FROM ( (LEAST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES', current_timestamp)::timestamp - 
            GREATEST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES', to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp) / 60 ) ) /
            EXTRACT(EPOCH FROM ( (current_timestamp::timestamp - 
            to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS')::timestamp) / 60 ) )
            ))
            WHEN em_po.payrate is null AND pos.payrate is not null and pos.payscale = 0 THEN
	    ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*pos.payrate)/3600) * ( 
            (
            EXTRACT(EPOCH FROM ( (LEAST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES', current_timestamp)::timestamp - 
            GREATEST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES', to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp) / 60 ) ) /
            EXTRACT(EPOCH FROM ( (current_timestamp::timestamp - 
            to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS')::timestamp) / 60 ) )
            ))
            WHEN em_po.payrate is null AND pos.payrate is not null and pos.payscale != 0 THEN
	    ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*pos.hourlyrate)/3600) * ( 
            (
            EXTRACT(EPOCH FROM ( (LEAST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES', current_timestamp)::timestamp - 
            GREATEST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES', to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp) / 60 ) ) /
            EXTRACT(EPOCH FROM ( (current_timestamp::timestamp - 
            to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS')::timestamp) / 60 ) )
            ))
            ELSE 0
            END ) AS period_expense INTO ret
            FROM attendance_block as ti, employee_position as em_po, position as pos
            WHERE ti.location_id = $1
            AND ti.department_id IN (DEP[j])
            AND ti.deleted = 'N'
            AND ti.allocated_date between $2 AND $3
            AND 
            (current_timestamp >= to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES' 
            AND to_timestamp(start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS') < to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES'
            )
            AND end_date IS NULL
            AND ((start_time < current_time and current_date = allocated_date) or (start_time = current_time and start_date != current_date) or (current_time < start_time and allocated_date < current_date))
	    and ti.position_id = pos.id
            and ti.position_id = em_po.position_id
            and ti.employee_id = em_po.employee_id
            and em_po.deleted='N';
            IF ret.att_shifts IS NOT NULL THEN
               total.att_shifts := total.att_shifts + ret.att_shifts;
            END IF;
            IF ret.att_hours IS NOT NULL THEN
               total.att_hours := total.att_hours + ret.att_hours;
            END IF;
            IF ret.att_cost IS NOT NULL THEN
               total.att_cost := total.att_cost + ret.att_cost;
            END IF;
         END LOOP;
         --------------------------------------------------------------------------------
         --------------------------------------------------------------------------------
         RETURN total;
      ELSE
         SELECT count(id)
         ,sum( EXTRACT(EPOCH FROM ( (LEAST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES', to_timestamp(end_date || ' ' || end_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp - 
         GREATEST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES', to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp) / 60 ) ) )  AS p_minutes
         
         ,sum( total_cost * ( 
         (
         EXTRACT(EPOCH FROM ( (LEAST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES', to_timestamp(end_date || ' ' || end_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp - 
         GREATEST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES', to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp) / 60 ) ) /
         EXTRACT(EPOCH FROM ( (to_timestamp(end_date || ' ' || end_time, 'YYYY-mm-DD HH24:MI:SS')::timestamp - 
         to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS')::timestamp) / 60 ) )
         )
         )) AS period_expense INTO ret
         
         FROM attendance_block as ti
         WHERE ti.location_id = $1
         AND ti.deleted = 'N'
         AND ti.allocated_date between $2 AND $3
         AND 
         (to_timestamp(end_date || ' ' || ti.end_time, 'YYYY-mm-DD HH24:MI:SS') >= to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES' 
         AND to_timestamp(start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS') < to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES'
         )
         AND end_date IS NOT NULL
         AND ((start_time < end_time and end_date = allocated_date) or (start_time = end_time and start_date != end_date) or (end_time < start_time and allocated_date < end_date));
         IF ret.att_shifts IS NOT NULL THEN
            total.att_shifts := total.att_shifts + ret.att_shifts;
         END IF;
         IF ret.att_hours IS NOT NULL THEN
            total.att_hours := total.att_hours + ret.att_hours;
         END IF;
         IF ret.att_cost IS NOT NULL THEN
            total.att_cost := total.att_cost + ret.att_cost;
         END IF;
	 --------------------------------------------------------------------------------
         --------------------------------------------------------------------------------
	 SELECT count(ti.id)
	 ,CAST(sum( EXTRACT(EPOCH FROM ( (LEAST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES', current_timestamp)::timestamp - 
         GREATEST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES', to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp) / 60 ) ) )  AS bigint) AS p_minutes
	 --(below is dynamically calculated interval of ) [ cost * duration ]
         ,sum( CASE 
         WHEN em_po.payrate is not null and em_po.payscale = 0 THEN
         ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*em_po.payrate)/3600) * ( 
         (
         EXTRACT(EPOCH FROM ( (LEAST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES', current_timestamp)::timestamp - 
         GREATEST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES', to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp) / 60 ) ) /
         EXTRACT(EPOCH FROM ( (current_timestamp::timestamp - 
         to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS')::timestamp) / 60 ) )
         ))
         WHEN em_po.payrate is not null and em_po.payscale != 0 THEN
	 ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*em_po.hourlyrate)/3600) * ( 
         (
         EXTRACT(EPOCH FROM ( (LEAST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES', current_timestamp)::timestamp - 
         GREATEST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES', to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp) / 60 ) ) /
         EXTRACT(EPOCH FROM ( (current_timestamp::timestamp - 
         to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS')::timestamp) / 60 ) )
         ))
         WHEN em_po.payrate is null AND pos.payrate is not null and pos.payscale = 0 THEN
	 ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*pos.payrate)/3600) * ( 
         (
         EXTRACT(EPOCH FROM ( (LEAST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES', current_timestamp)::timestamp - 
         GREATEST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES', to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp) / 60 ) ) /
         EXTRACT(EPOCH FROM ( (current_timestamp::timestamp - 
         to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS')::timestamp) / 60 ) )
         ))
         WHEN em_po.payrate is null AND pos.payrate is not null and pos.payscale != 0 THEN
	 ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*pos.hourlyrate)/3600) * ( 
         (
         EXTRACT(EPOCH FROM ( (LEAST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES', current_timestamp)::timestamp - 
         GREATEST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES', to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp) / 60 ) ) /
         EXTRACT(EPOCH FROM ( (current_timestamp::timestamp - 
         to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS')::timestamp) / 60 ) )
         ))
         ELSE 0
         END ) AS period_expense INTO ret
         FROM attendance_block as ti, employee_position as em_po, position as pos
         WHERE ti.location_id = $1
         AND ti.deleted = 'N'
         AND ti.allocated_date between $2 AND $3
         AND 
         (current_timestamp >= to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES' 
         AND to_timestamp(start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS') < to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES'
         )
         AND end_date IS NULL
         AND ((start_time < current_time and current_date = allocated_date) or (start_time = current_time and start_date != current_date) or (current_time < start_time and allocated_date < current_date))
	 and ti.position_id = pos.id
         and ti.position_id = em_po.position_id
         and ti.employee_id = em_po.employee_id
         and em_po.deleted='N';
         IF ret.att_shifts IS NOT NULL THEN
            total.att_shifts := total.att_shifts + ret.att_shifts;
         END IF;
         IF ret.att_hours IS NOT NULL THEN
            total.att_hours := total.att_hours + ret.att_hours;
         END IF;
         IF ret.att_cost IS NOT NULL THEN
            total.att_cost := total.att_cost + ret.att_cost;
         END IF;
	 --------------------------------------------------------------------------------
         --------------------------------------------------------------------------------
         RETURN total;
      END IF;
   END;
$_$;


ALTER FUNCTION public.att_shift_hours_cost_function(bigint, date, date, bigint, bigint, dep bigint[]) OWNER TO postgres;

--
-- Name: attendance_agg(bigint, date, bigint[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION attendance_agg(bigint, date, dep bigint[]) RETURNS att_agg_totals
    LANGUAGE plpgsql
    AS $_$
    DECLARE ret att_agg_totals;
    DECLARE total att_agg_totals;
    DECLARE array_len int;
    BEGIN 
        total.att_shifts :=0;
        total.att_hours :=0;
        total.att_cost :=0;
        ret.att_shifts :=0;
        ret.att_hours :=0;
        ret.att_cost :=0;
        IF dep IS NOT NULL THEN
            array_len := array_upper(DEP, 1);
            FOR i IN 1 .. array_len
            LOOP
                SELECT count(ti.id) as shifts, sum(ti.total_duration) as hours, sum(total_cost) as cost INTO ret 
                FROM attendance_block as ti
                WHERE ti.location_id = $1
                AND ti.department_id IN (DEP[i])
                AND ti.deleted = 'N'
                AND ti.allocated_date between $2 AND $2
                AND ti.end_date is not null;
                IF ret.att_shifts IS NOT NULL THEN
                    total.att_shifts := total.att_shifts + ret.att_shifts;
                END IF;
                IF ret.att_hours IS NOT NULL THEN
                    total.att_hours := total.att_hours + ret.att_hours;
                END IF;
                IF ret.att_cost IS NOT NULL THEN
                   total.att_cost := total.att_cost + ret.att_cost;
                END IF;
            END LOOP;
            --------------------------------------------------------------------------------
            --------------------------------------------------------------------------------
	    FOR j IN 1 .. array_len
            LOOP
                select count(ti.id)  as shifts
                ,CAST(sum( (EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))/60) ) AS bigint) as hours
                ,sum( CASE 
                WHEN em_po.payrate is not null and em_po.payscale = 0 THEN
                ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*em_po.payrate)/3600)
                WHEN em_po.payrate is not null and em_po.payscale != 0 THEN
                ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*em_po.hourlyrate)/3600)
                WHEN em_po.payrate is null AND pos.payrate is not null and pos.payscale = 0 THEN
                ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*pos.payrate)/3600)
                WHEN em_po.payrate is null AND pos.payrate is not null and pos.payscale != 0 THEN
                ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*pos.hourlyrate)/3600)
                ELSE 0
                END ) as cost INTO ret
                from attendance_block as ti, employee_position as em_po, position as pos
                where ti.location_id = $1
                AND ti.department_id IN (DEP[j])
                and ti.deleted='N'
                and ti.allocated_date between $2 and $2
                and ti.end_date is null
                and ti.position_id = pos.id
                and ti.position_id = em_po.position_id
                and ti.employee_id = em_po.employee_id
                and em_po.deleted='N';
                IF ret.att_shifts IS NOT NULL THEN
                   total.att_shifts := total.att_shifts + ret.att_shifts;
                END IF;
                IF ret.att_hours IS NOT NULL THEN
                   total.att_hours := total.att_hours + ret.att_hours;
                END IF;
                IF ret.att_cost IS NOT NULL THEN
                   total.att_cost := total.att_cost + ret.att_cost;
                END IF;
            END LOOP;
            --------------------------------------------------------------------------------
            --------------------------------------------------------------------------------
            RETURN total;
        ELSE
            SELECT count(ti.id) as shifts, sum(ti.total_duration) as hours, sum(total_cost) as cost INTO ret 
            FROM attendance_block as ti
            WHERE ti.location_id = $1
            AND ti.deleted = 'N'
            AND ti.allocated_date between $2 AND $2
            AND ti.end_date is not null;
            IF ret.att_shifts IS NOT NULL THEN
               total.att_shifts := total.att_shifts + ret.att_shifts;
            END IF;
            IF ret.att_hours IS NOT NULL THEN
               total.att_hours := total.att_hours + ret.att_hours;
            END IF;
            IF ret.att_cost IS NOT NULL THEN
               total.att_cost := total.att_cost + ret.att_cost;
            END IF;
	    --------------------------------------------------------------------------------
            --------------------------------------------------------------------------------
            select count(ti.id)  as shifts
            ,CAST(sum( (EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))/60) ) AS bigint) as hours
            ,sum( CASE 
            WHEN em_po.payrate is not null and em_po.payscale = 0 THEN
            ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*em_po.payrate)/3600)
            WHEN em_po.payrate is not null and em_po.payscale != 0 THEN
            ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*em_po.hourlyrate)/3600)
            WHEN em_po.payrate is null AND pos.payrate is not null and pos.payscale = 0 THEN
            ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*pos.payrate)/3600)
            WHEN em_po.payrate is null AND pos.payrate is not null and pos.payscale != 0 THEN
            ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*pos.hourlyrate)/3600)
            ELSE 0
            END ) as cost INTO ret
            from attendance_block as ti, employee_position as em_po, position as pos
            where ti.location_id = $1
            and ti.deleted='N'
            and ti.allocated_date between $2 and $2
            and ti.end_date is null
            and ti.position_id = pos.id
            and ti.position_id = em_po.position_id
            and ti.employee_id = em_po.employee_id
            and em_po.deleted='N';
            IF ret.att_shifts IS NOT NULL THEN
               total.att_shifts := total.att_shifts + ret.att_shifts;
            END IF;
            IF ret.att_hours IS NOT NULL THEN
               total.att_hours := total.att_hours + ret.att_hours;
            END IF;
            IF ret.att_cost IS NOT NULL THEN
               total.att_cost := total.att_cost + ret.att_cost;
            END IF;
            --------------------------------------------------------------------------------
            --------------------------------------------------------------------------------
            RETURN total;
        END IF;
    END;
$_$;


ALTER FUNCTION public.attendance_agg(bigint, date, dep bigint[]) OWNER TO postgres;

--
-- Name: attendance_agg_by_pos(bigint, date, bigint[], bigint, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION attendance_agg_by_pos(bigint, date, dep bigint[], bigint, date) RETURNS att_agg_totals
    LANGUAGE plpgsql
    AS $_$
    DECLARE ret att_agg_totals;
    DECLARE total att_agg_totals;
    DECLARE array_len int;
    BEGIN 
        total.att_shifts :=0;
        total.att_hours :=0;
        total.att_cost :=0;
        ret.att_shifts :=0;
        ret.att_hours :=0;
        ret.att_cost :=0;
        IF dep IS NOT NULL THEN
            array_len := array_upper(DEP, 1);
            FOR i IN 1 .. array_len
            LOOP
                SELECT count(ti.id) as shifts, sum(ti.total_duration) as hours, sum(total_cost) as cost INTO ret 
                FROM attendance_block as ti
                WHERE ti.location_id = $1
                AND ti.department_id IN (DEP[i])
                AND ti.position_id = $4
                AND ti.deleted = 'N'
                AND ti.allocated_date between $2 AND $5
                AND ti.end_date is not null;
                IF ret.att_shifts IS NOT NULL THEN
                    total.att_shifts := total.att_shifts + ret.att_shifts;
                END IF;
                IF ret.att_hours IS NOT NULL THEN
                    total.att_hours := total.att_hours + ret.att_hours;
                END IF;
                IF ret.att_cost IS NOT NULL THEN
                   total.att_cost := total.att_cost + ret.att_cost;
                END IF;
            END LOOP;
            --------------------------------------------------------------------------------
            --------------------------------------------------------------------------------
	    FOR j IN 1 .. array_len
            LOOP
                select count(ti.id)  as shifts
                ,CAST(sum( (EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))/60) ) AS bigint) as hours
                ,sum( CASE 
                WHEN em_po.payrate is not null and em_po.payscale = 0 THEN
                ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*em_po.payrate)/3600)
                WHEN em_po.payrate is not null and em_po.payscale != 0 THEN
                ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*em_po.hourlyrate)/3600)
                WHEN em_po.payrate is null AND pos.payrate is not null and pos.payscale = 0 THEN
                ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*pos.payrate)/3600)
                WHEN em_po.payrate is null AND pos.payrate is not null and pos.payscale != 0 THEN
                ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*pos.hourlyrate)/3600)
                ELSE 0
                END ) as cost INTO ret
                from attendance_block as ti, employee_position as em_po, position as pos
                where ti.location_id = $1
                AND ti.department_id IN (DEP[j])
                AND ti.position_id = $4
                and ti.deleted='N'
                and ti.allocated_date between $2 and $5
                and ti.end_date is null
                and ti.position_id = pos.id
                and ti.position_id = em_po.position_id
                and ti.employee_id = em_po.employee_id
                and em_po.deleted='N';
                IF ret.att_shifts IS NOT NULL THEN
                   total.att_shifts := total.att_shifts + ret.att_shifts;
                END IF;
                IF ret.att_hours IS NOT NULL THEN
                   total.att_hours := total.att_hours + ret.att_hours;
                END IF;
                IF ret.att_cost IS NOT NULL THEN
                   total.att_cost := total.att_cost + ret.att_cost;
                END IF;
            END LOOP;
            --------------------------------------------------------------------------------
            --------------------------------------------------------------------------------
            RETURN total;
        ELSE
            SELECT count(ti.id) as shifts, sum(ti.total_duration) as hours, sum(total_cost) as cost INTO ret 
            FROM attendance_block as ti
            WHERE ti.location_id = $1
            AND ti.position_id = $4
            AND ti.deleted = 'N'
            AND ti.allocated_date between $2 AND $5
            AND ti.end_date is not null;
            IF ret.att_shifts IS NOT NULL THEN
               total.att_shifts := total.att_shifts + ret.att_shifts;
            END IF;
            IF ret.att_hours IS NOT NULL THEN
               total.att_hours := total.att_hours + ret.att_hours;
            END IF;
            IF ret.att_cost IS NOT NULL THEN
               total.att_cost := total.att_cost + ret.att_cost;
            END IF;
	    --------------------------------------------------------------------------------
            --------------------------------------------------------------------------------
            select count(ti.id)  as shifts
            ,CAST(sum( (EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))/60) ) AS bigint) as hours
            ,sum( CASE 
            WHEN em_po.payrate is not null and em_po.payscale = 0 THEN
            ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*em_po.payrate)/3600)
            WHEN em_po.payrate is not null and em_po.payscale != 0 THEN
            ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*em_po.hourlyrate)/3600)
            WHEN em_po.payrate is null AND pos.payrate is not null and pos.payscale = 0 THEN
            ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*pos.payrate)/3600)
            WHEN em_po.payrate is null AND pos.payrate is not null and pos.payscale != 0 THEN
            ((EXTRACT(epoch FROM current_timestamp - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))*pos.hourlyrate)/3600)
            ELSE 0
            END ) as cost INTO ret
            from attendance_block as ti, employee_position as em_po, position as pos
            where ti.location_id = $1
            AND ti.position_id = $4
            and ti.deleted='N'
            and ti.allocated_date between $2 and $5
            and ti.end_date is null
            and ti.position_id = pos.id
            and ti.position_id = em_po.position_id
            and ti.employee_id = em_po.employee_id
            and em_po.deleted='N';
            IF ret.att_shifts IS NOT NULL THEN
               total.att_shifts := total.att_shifts + ret.att_shifts;
            END IF;
            IF ret.att_hours IS NOT NULL THEN
               total.att_hours := total.att_hours + ret.att_hours;
            END IF;
            IF ret.att_cost IS NOT NULL THEN
               total.att_cost := total.att_cost + ret.att_cost;
            END IF;
            --------------------------------------------------------------------------------
            --------------------------------------------------------------------------------
            RETURN total;
        END IF;
    END;
$_$;


ALTER FUNCTION public.attendance_agg_by_pos(bigint, date, dep bigint[], bigint, date) OWNER TO postgres;

--
-- Name: bytea2text(bytea); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION bytea2text(bytea) RETURNS text
    LANGUAGE plpgsql
    AS $_$
begin
 return $1;
end;
$_$;


ALTER FUNCTION public.bytea2text(bytea) OWNER TO ressystems;

--
-- Name: crypt(text, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION crypt(text, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_crypt';


ALTER FUNCTION public.crypt(text, text) OWNER TO ressystems;

--
-- Name: dateintervals(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dateintervals(enddate date, begindate date) RETURNS numberof_dd_ww_mm_yy
    LANGUAGE plpgsql
    AS $$
   DECLARE ret numberOf_dd_ww_mm_yy;
   BEGIN
      SELECT
      ((date(endDate)-date(beginDate))::bigint+1) as days
      , round( ( ((date(endDate)-date(beginDate))::numeric+1) / 7), 4) as weeks
      , round( ( ((date(endDate)-date(beginDate))::numeric+1) / 30), 4) as months
      , round( ( ((date(endDate)-date(beginDate))::numeric+1) / 365), 4) as years
      INTO ret;
      RETURN ret;
   END;
$$;


ALTER FUNCTION public.dateintervals(enddate date, begindate date) OWNER TO postgres;

--
-- Name: dearmor(text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION dearmor(text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_dearmor';


ALTER FUNCTION public.dearmor(text) OWNER TO ressystems;

--
-- Name: decrypt(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION decrypt(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_decrypt';


ALTER FUNCTION public.decrypt(bytea, bytea, text) OWNER TO ressystems;

--
-- Name: decrypt_iv(bytea, bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION decrypt_iv(bytea, bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_decrypt_iv';


ALTER FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) OWNER TO ressystems;

--
-- Name: dep_level(bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dep_level(cor_id bigint, dep_id bigint) RETURNS text
    LANGUAGE sql
    AS $_$
  WITH RECURSIVE query AS
        (
        --SELECT  dep, 1 AS level, dep.id as dep_parent, dep.id as dep_root, ' ' || dep.name || '@' || id || '_' AS breadcrumb
	SELECT  dep, 1 AS level, dep.id as dep_parent, dep.id as dep_root, ' ' || dep.name || '@' || id || '_' AS breadcrumb
        FROM    department as dep
        WHERE   dep.corporation_id=$1
        AND     dep.department_parent_id is null
        AND     dep.deleted='N'
        UNION ALL
        SELECT  dep_hierarchy, query.level + 1 AS level, dep_hierarchy.id as dep_parent, query.dep_root as dep_root, breadcrumb || id || '_'
        FROM    query
        JOIN    department dep_hierarchy
        ON      (dep_hierarchy.department_parent_id = (query.dep).id and dep_hierarchy.corporation_id=$1 and dep_hierarchy.deleted='N')
        )
SELECT  --breadcrumb::VARCHAR AS path,
        --REPEAT('  ', level) || (query.dep).name as dep_hi_name,
        --(query.dep).name,
        --(query.dep).id as dep_id,
        --(query.dep).department_parent_id,
        level || '' as level
        --dep_parent,
        --dep_root,
        --(query.dep).deleted
FROM    query
where (query.dep).id=$2
$_$;


ALTER FUNCTION public.dep_level(cor_id bigint, dep_id bigint) OWNER TO postgres;

--
-- Name: dep_path_info(bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dep_path_info(cor_id bigint, dep_id bigint) RETURNS path_type
    LANGUAGE sql
    AS $_$
  WITH RECURSIVE query AS
        (
        SELECT  dep, 1 AS level, dep.id as dep_parent, dep.id as dep_root, ' ' || dep.name || '@' || id || '_' AS breadcrumb
        FROM    department as dep
        WHERE   dep.corporation_id=$1
	AND     dep.department_parent_id is null
	AND     dep.deleted='N'
        UNION ALL
        SELECT  dep_hierarchy, query.level + 1 AS level, dep_hierarchy.id as dep_parent, query.dep_root as dep_root, breadcrumb || id || '_'
        FROM    query	
        JOIN    department dep_hierarchy
        ON      (dep_hierarchy.department_parent_id = (query.dep).id and dep_hierarchy.corporation_id=$1 and dep_hierarchy.deleted='N')
        )
SELECT  breadcrumb::VARCHAR AS path,
        REPEAT('  ', level) || (query.dep).name as dep_hi_name,
        --(query.dep).name,
	--(query.dep).id as dep_id,
        --(query.dep).department_parent_id,
        level || '' as level
	--dep_parent,
	--dep_root,
	--(query.dep).deleted
FROM    query
where (query.dep).id=$2
$_$;


ALTER FUNCTION public.dep_path_info(cor_id bigint, dep_id bigint) OWNER TO postgres;

--
-- Name: dep_root_info(bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dep_root_info(cor_id bigint, dep_id bigint) RETURNS integer
    LANGUAGE sql
    AS $_$
WITH RECURSIVE query AS
        (
        SELECT  dep, 1 AS level, dep.id as dep_parent, dep.id as dep_root, ' ' || dep.name || '@' || id || '_' AS breadcrumb
        FROM    department as dep
        WHERE   dep.corporation_id=$1
	AND     dep.department_parent_id is null
	AND     dep.deleted='N'
        UNION ALL
        SELECT  dep_hierarchy, query.level + 1 AS level, dep_hierarchy.id as dep_parent, query.dep_root as dep_root, breadcrumb || id || '_'
        FROM    query	
        JOIN    department dep_hierarchy
        ON      (dep_hierarchy.department_parent_id = (query.dep).id and dep_hierarchy.corporation_id=$1 and dep_hierarchy.deleted='N')
        )
SELECT  --breadcrumb::VARCHAR AS path,
        --REPEAT('  ', level) || (query.dep).name as dep_hi_name,
        --(query.dep).name,
	--(query.dep).id as dep_id,
        --(query.dep).department_parent_id,
        --level || '' as level,
	--dep_parent,
	dep_root
	--(query.dep).deleted
FROM    query
where (query.dep).id=$2
$_$;


ALTER FUNCTION public.dep_root_info(cor_id bigint, dep_id bigint) OWNER TO postgres;

--
-- Name: digest(text, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION digest(text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_digest';


ALTER FUNCTION public.digest(text, text) OWNER TO ressystems;

--
-- Name: digest(bytea, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION digest(bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_digest';


ALTER FUNCTION public.digest(bytea, text) OWNER TO ressystems;

--
-- Name: encrypt(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION encrypt(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_encrypt';


ALTER FUNCTION public.encrypt(bytea, bytea, text) OWNER TO ressystems;

--
-- Name: encrypt_iv(bytea, bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION encrypt_iv(bytea, bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_encrypt_iv';


ALTER FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) OWNER TO ressystems;

--
-- Name: forecast_tb_agg_by_pos(bigint, date, bigint[], bigint); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION forecast_tb_agg_by_pos(bigint, date, dep bigint[], bigint) RETURNS forecast_tb_totals
    LANGUAGE plpgsql
    AS $_$
    DECLARE ret forecast_tb_totals;
    DECLARE total forecast_tb_totals;
    DECLARE array_len int;
    BEGIN
        IF dep IS NOT NULL THEN
            total.ftb_shifts :=0;
            total.ftb_hours :=0;
            array_len := array_upper(DEP, 1);
            FOR i IN 1 .. array_len
            LOOP
                SELECT count(ft.id) as shifts
	            , sum(EXTRACT(epoch FROM to_timestamp(ft.end_date || ' ' || ft.end_time, 'YYYY-mm-DD HH24:MI:SS') - to_timestamp(ft.start_date || ' ' || ft.start_time, 'YYYY-mm-DD HH24:MI:SS')))
                    INTO ret
                FROM forecast_timeblock as ft
                WHERE ft.location_id = $1
                AND ft.department_id IN (DEP[i])
                AND ft.position_id = $4
                AND ft.start_date between $2 AND $2 ;
                IF ret.ftb_shifts IS NOT NULL THEN
                    total.ftb_shifts := total.ftb_shifts + ret.ftb_shifts;
                END IF;
                IF ret.ftb_hours IS NOT NULL THEN
                    total.ftb_hours := total.ftb_hours + ret.ftb_hours;
                END IF;
            END LOOP;
            RETURN total;
        ELSE
            SELECT count(ft.id) as shifts
	        , sum(EXTRACT(epoch FROM to_timestamp(ft.end_date || ' ' || ft.end_time, 'YYYY-mm-DD HH24:MI:SS') - to_timestamp(ft.start_date || ' ' || ft.start_time, 'YYYY-mm-DD HH24:MI:SS')))
                INTO ret
            FROM forecast_timeblock as ft
            WHERE ft.location_id = $1
            AND ft.position_id = $4
            AND ft.start_date between $2 AND $2 ;
            RETURN ret;
        END IF;
    END;
$_$;


ALTER FUNCTION public.forecast_tb_agg_by_pos(bigint, date, dep bigint[], bigint) OWNER TO ressystems;

--
-- Name: gen_random_bytes(integer); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION gen_random_bytes(integer) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pg_random_bytes';


ALTER FUNCTION public.gen_random_bytes(integer) OWNER TO ressystems;

--
-- Name: gen_salt(text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION gen_salt(text) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pg_gen_salt';


ALTER FUNCTION public.gen_salt(text) OWNER TO ressystems;

--
-- Name: gen_salt(text, integer); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION gen_salt(text, integer) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pg_gen_salt_rounds';


ALTER FUNCTION public.gen_salt(text, integer) OWNER TO ressystems;

--
-- Name: get_emp_pos_id(bigint, bigint, date, time without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_emp_pos_id(bigint, bigint, date, time without time zone) RETURNS bigint
    LANGUAGE plpgsql
    AS $_$
    DECLARE emp_pos_id bigint;
    DECLARE attendancedate timestamp;
    BEGIN 
       attendancedate:=to_timestamp($3 || ' ' || $4, 'YYYY-mm-DD HH24:MI:SS');
       --give me the emp_pos that not deleted and has been created before attendance
       --min is just to make sure to get one
       select min(employee_position.id) INTO emp_pos_id 
       from employee_position
       where employee_position.employee_id=$1
       and employee_position.position_id=$2
       and employee_position.deleted = 'N' and employee_position.starttimestamp <= attendancedate;
       IF emp_pos_id IS NOT NULL THEN
          RETURN emp_pos_id;
       END IF;

       --since first case above could not give you one
       --then look the ones that has been (in the past)deleted according to attendance.start_date and start_time
       --min is just to make sure to get one
       select min(employee_position.id) INTO emp_pos_id 
       from employee_position
       where employee_position.employee_id=$1
       and employee_position.position_id=$2
       and employee_position.deleted = 'Y' 
       and attendancedate BETWEEN employee_position.starttimestamp and employee_position.endtimestamp;
       IF emp_pos_id IS NOT NULL THEN
          RETURN emp_pos_id;
       END IF;
       
       --first two cases did not give you one
       --it could be that you lost emp_pos and attendance happened when there was not any non-deleted emp_pos
       --this should give you the last emp_pos before you lost emp_pos
       --min is just to make sure to get one and the last one
       select min(employee_position.id) INTO emp_pos_id 
       from employee_position
       where employee_position.employee_id=$1
       and employee_position.position_id=$2
       and employee_position.deleted = 'Y' 
       and attendancedate > employee_position.endtimestamp;
       IF emp_pos_id IS NOT NULL THEN
          RETURN emp_pos_id;
       END IF;

       --since first three cases could not give you one
       --just look for the one that is not deleted without no date requirements
       --min is just to make sure to get one
       select min(employee_position.id) INTO emp_pos_id 
       from employee_position
       where employee_position.employee_id=$1
       and employee_position.position_id=$2
       and employee_position.deleted = 'N'; 
       IF emp_pos_id IS NOT NULL THEN
          RETURN emp_pos_id;
       END IF;
       RETURN emp_pos_id;
    END;
$_$;


ALTER FUNCTION public.get_emp_pos_id(bigint, bigint, date, time without time zone) OWNER TO postgres;

--
-- Name: hmac(text, text, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION hmac(text, text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_hmac';


ALTER FUNCTION public.hmac(text, text, text) OWNER TO ressystems;

--
-- Name: hmac(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION hmac(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_hmac';


ALTER FUNCTION public.hmac(bytea, bytea, text) OWNER TO ressystems;

--
-- Name: makeename(text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION makeename(firstname text, lastname text, nameorder integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
   BEGIN 
       IF nameOrder IS NOT NULL AND nameOrder = 1 THEN 
           RETURN firstName || ' ' || lastName;
       ELSE
           RETURN lastName || ', ' || firstName;
       END IF;
   END;
  $$;


ALTER FUNCTION public.makeename(firstname text, lastname text, nameorder integer) OWNER TO postgres;

--
-- Name: paf_shift_total_regular(bigint, date, date, bigint, bigint, text, text, bigint[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION paf_shift_total_regular(bigint, date, date, bigint, bigint, text, text, dep bigint[]) RETURNS double precision
    LANGUAGE plpgsql
    AS $_$
   DECLARE ret DOUBLE PRECISION;
   DECLARE total DOUBLE PRECISION;
   DECLARE array_len int;
   DECLARE sales_level text;
   BEGIN
      IF dep IS NOT NULL THEN
         total :=0;
         array_len := array_upper(DEP, 1);
         FOR i IN 1 .. array_len
         LOOP
            SELECT INTO sales_level sales_type.level from sales_type,department
            WHERE department.id IN (DEP[i])
            AND sales_type.corporation_id = department.corporation_id
            AND sales_type.description = $6
            AND department.deleted='N'
            AND sales_type.deleted='N';
            --first part of the IF is for sales from departments, ELSE part gives you the sales from non-departments
            --since sales_type has level of location (L). [AND sp.department_id IS NULL] makes sure to exclude departments sales
            IF sales_level IS NOT NULL AND sales_level = 'D' THEN
                SELECT sum(value) INTO ret
                FROM sales_paf as sp, sales_type as st, department
                WHERE sp.location_id = $1
                AND sp.department_id = department.id
                AND department.id IN  (DEP[i])
                AND department.deleted = 'N'
                AND sp.sales_type_id = st.id
                AND st.description = $6
                AND sp.type = $7
                AND sp.belongs_to between $2 AND $3
                AND sp.deleted='N'
                AND to_timestamp(date || ' ' || sp.start_time, 'YYYY-mm-DD HH24:MI:SS') >= to_timestamp(belongs_to||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES'
                AND to_timestamp(date || ' ' || sp.start_time, 'YYYY-mm-DD HH24:MI:SS') < to_timestamp(belongs_to||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES'
                AND belongs_to IS NOT NULL;
            ELSE
                SELECT sum(value) INTO ret
                FROM sales_paf as sp, sales_type as st
                WHERE sp.location_id = $1
                AND sp.sales_type_id = st.id
                AND st.description = $6
                AND sp.type = $7
                AND sp.belongs_to between $2 AND $3
                AND sp.department_id IS NULL
                AND sp.deleted='N'
                AND to_timestamp(date || ' ' || sp.start_time, 'YYYY-mm-DD HH24:MI:SS') >= to_timestamp(belongs_to||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES'
                AND to_timestamp(date || ' ' || sp.start_time, 'YYYY-mm-DD HH24:MI:SS') < to_timestamp(belongs_to||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES'
                AND belongs_to IS NOT NULL;
            END IF;
            IF ret IS NOT NULL THEN
               total := total + ret;
            END IF;
         END LOOP;
         RETURN total;
      ELSE
         SELECT sum(value) INTO ret
         FROM sales_paf as sp, sales_type as st
         WHERE sp.location_id = $1
         AND sp.sales_type_id = st.id
         AND st.description = $6
         AND sp.type = $7
         AND sp.belongs_to between $2 AND $3
         AND sp.deleted='N'
         AND to_timestamp(date || ' ' || sp.start_time, 'YYYY-mm-DD HH24:MI:SS') >= to_timestamp(belongs_to||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES'
         AND to_timestamp(date || ' ' || sp.start_time, 'YYYY-mm-DD HH24:MI:SS') < to_timestamp(belongs_to||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES'
         AND belongs_to IS NOT NULL;
      RETURN ret;
      END IF;
   END;
$_$;


ALTER FUNCTION public.paf_shift_total_regular(bigint, date, date, bigint, bigint, text, text, dep bigint[]) OWNER TO postgres;

--
-- Name: paf_shift_total_reportsto_text(bigint, date, date, bigint, bigint, text, text, bigint[], text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION paf_shift_total_reportsto_text(bigint, date, date, bigint, bigint, text, text, dep bigint[], ltname text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
   DECLARE ret DOUBLE PRECISION;
   DECLARE totalText text;
   DECLARE array_len int;
   DECLARE sales_len int;
   DECLARE myDepIds bigint[];
   DECLARE salesIds bigint[];
   DECLARE tname text;
   BEGIN
      IF dep IS NOT NULL THEN
         array_len := array_upper(DEP, 1);
	 -----------------------------------------------------
         tname:=tname||'_shift_total_text_';
         FOR k IN 1 .. array_len
         LOOP
             tname:=ltname || DEP[k];
         END LOOP;            
         EXECUTE 'CREATE TEMPORARY TABLE  ' || tname || '  (dep_id bigint )';
         FOR i IN 1 .. array_len
         LOOP
             select array(select id from department where deleted='N' and department_parent_id=DEP[i] order by department_parent_id) into salesIds;
             sales_len := array_upper(salesIds, 1);
             IF sales_len IS NOT NULL THEN
                 FOR k IN 1 .. sales_len
                 LOOP
                    EXECUTE 'INSERT INTO ' || tname || ' values ('|| salesIds[k] || ')';
                 END LOOP;
             END IF;
         END LOOP;
         EXECUTE 'select array(select distinct(dep_id) from ' || tname || ' where dep_id is not null)' into myDepIds;
         -----------------------------------------------------
         array_len := array_upper(myDepIds, 1);
	 IF array_len IS NOT NULL THEN
            totalText := '';
            FOR i IN 1 .. array_len
            LOOP
               SELECT sum(value) INTO ret
               FROM sales_paf as sp, sales_type as st, department
               WHERE sp.location_id = $1
               AND sp.department_id = department.id
               AND department.id IN (myDepIds[i])
	       AND department.deleted = 'N'
               AND sp.sales_type_id = st.id
               AND st.description = $6
               AND sp.type = $7
               AND sp.belongs_to between $2 AND $3
               AND sp.deleted='N'
               AND to_timestamp(date || ' ' || sp.start_time, 'YYYY-mm-DD HH24:MI:SS') >= to_timestamp(belongs_to||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES'
	       AND to_timestamp(date || ' ' || sp.start_time, 'YYYY-mm-DD HH24:MI:SS') < to_timestamp(belongs_to||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES'
               AND belongs_to IS NOT NULL;
               IF ret IS NOT NULL THEN
                  totalText := totalText || myDepIds[i] || '_' || ret || ',';
               END IF;
            END LOOP;
         END IF;
         EXECUTE 'DROP TABLE ' || tname;
         RETURN totalText;
      ELSE
         totalText := '';
         --you have to have departments for rollup
         RETURN totalText;
      END IF;
   END;
$_$;


ALTER FUNCTION public.paf_shift_total_reportsto_text(bigint, date, date, bigint, bigint, text, text, dep bigint[], ltname text) OWNER TO postgres;

--
-- Name: paf_shift_total_rollup(bigint, date, date, bigint, bigint, text, text, bigint[], text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION paf_shift_total_rollup(bigint, date, date, bigint, bigint, text, text, dep bigint[], ltname text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
   DECLARE ret DOUBLE PRECISION;
   DECLARE totalText text;
   DECLARE array_len int;
   DECLARE sales_len int;
   DECLARE myDepIds bigint[];
   DECLARE salesIds bigint[];
   DECLARE tname text;
   BEGIN
      IF dep IS NOT NULL THEN
         array_len := array_upper(DEP, 1);
         -----------------------------------------------------
         tname:=ltname||'_shift_total_';
         FOR k IN 1 .. array_len
         LOOP
             tname:=tname || DEP[k];
         END LOOP;            
         EXECUTE 'CREATE TEMPORARY TABLE  ' || tname || '  (dep_id bigint )';
         FOR i IN 1 .. array_len
         LOOP
             select array(select department_roll_up.sales_department_id FROM department_roll_up WHERE deleted='N' AND department_roll_up.department_id=DEP[i]) into salesIds;
             sales_len := array_upper(salesIds, 1);
             IF sales_len IS NOT NULL THEN
                 FOR k IN 1 .. sales_len
                 LOOP
                    EXECUTE 'INSERT INTO ' || tname || ' values ('|| salesIds[k] || ')';
                 END LOOP;
             END IF;
         END LOOP;
         EXECUTE 'select array(select distinct(dep_id) from ' || tname || ' where dep_id is not null)' into myDepIds;
         -----------------------------------------------------
         array_len := array_upper(myDepIds, 1);
	 IF array_len IS NOT NULL THEN
            totalText := '';
            FOR i IN 1 .. array_len
            LOOP
               SELECT sum(sp.value) INTO ret
               FROM sales_paf as sp, sales_type as st, department
               WHERE sp.location_id = $1
               AND sp.department_id = department.id
               AND department.id IN (myDepIds[i])
	       AND department.deleted = 'N'
               AND sp.sales_type_id = st.id
               AND st.description = $6
               AND sp.type = $7
               AND sp.belongs_to between $2 AND $3
               AND sp.deleted='N'
               AND to_timestamp(date || ' ' || sp.start_time, 'YYYY-mm-DD HH24:MI:SS') >= to_timestamp(belongs_to||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES'
	       AND to_timestamp(date || ' ' || sp.start_time, 'YYYY-mm-DD HH24:MI:SS') < to_timestamp(belongs_to||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES'
               AND belongs_to IS NOT NULL;
               IF ret IS NOT NULL THEN
                  totalText := totalText || myDepIds[i] || '_' || ret || ',';
               END IF;
            END LOOP;
         END IF;
         EXECUTE 'DROP TABLE ' || tname;
         RETURN totalText;
      ELSE
         totalText := '';
         --you have to have departments for rollup
         RETURN totalText;
      END IF;
   END;
$_$;


ALTER FUNCTION public.paf_shift_total_rollup(bigint, date, date, bigint, bigint, text, text, dep bigint[], ltname text) OWNER TO ressystems;

--
-- Name: paf_total_regular(bigint, text, text, date, bigint[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION paf_total_regular(bigint, text, text, date, dep bigint[]) RETURNS double precision
    LANGUAGE plpgsql
    AS $_$
    DECLARE ret DOUBLE PRECISION;
    DECLARE total DOUBLE PRECISION;
    DECLARE array_len int;
    DECLARE sales_level text;
    BEGIN 
        IF dep IS NOT NULL THEN
            total :=0;
            array_len := array_upper(DEP, 1);
            FOR i IN 1 .. array_len
            LOOP
                SELECT INTO sales_level sales_type.level from sales_type,department
                WHERE department.id IN (DEP[i])
                AND sales_type.corporation_id = department.corporation_id
                AND sales_type.description = $2
                AND department.deleted='N'
                AND sales_type.deleted='N';
                --first part of the IF is for sales from departments, ELSE part gives you the sales from non-departments
                --since sales_type has level of location (L). [AND sp.department_id IS NULL] makes sure to exclude departments sales
                IF sales_level IS NOT NULL AND sales_level = 'D' THEN
                    SELECT INTO ret sum(sp.value)
                    FROM sales_paf as sp, sales_type as st, department
                    WHERE sp.location_id = $1
                    AND sp.department_id = department.id
                    AND department.id IN (DEP[i])
                    AND department.deleted='N'
                    AND sp.sales_type_id = st.id
                    AND st.description = $2
                    AND sp.type = $3
                    AND sp.belongs_to between $4 AND $4
                    AND sp.deleted='N';                    
                ELSE
                    SELECT INTO ret sum(sp.value)
                    FROM sales_paf as sp, sales_type as st
                    WHERE sp.location_id = $1
                    AND sp.sales_type_id = st.id
                    AND st.description = $2
                    AND sp.type = $3
                    AND sp.belongs_to between $4 AND $4
                    AND sp.department_id IS NULL
                    AND sp.deleted='N';
                END IF;
                ----------------------------------------------------------------
                IF ret IS NOT NULL THEN
                    total := total + ret;
                END IF;
            END LOOP;
            RETURN total;
        ELSE
            SELECT INTO ret sum(sp.value)
            FROM sales_paf as sp, sales_type as st
            WHERE sp.location_id = $1
            AND sp.sales_type_id = st.id
            AND st.description = $2
            AND sp.type = $3
            AND sp.belongs_to between $4 AND $4
            AND sp.deleted='N';
            RETURN ret;
        END IF;
    END;
$_$;


ALTER FUNCTION public.paf_total_regular(bigint, text, text, date, dep bigint[]) OWNER TO postgres;

--
-- Name: paf_total_reportsto_text(bigint, text, text, date, bigint[], text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION paf_total_reportsto_text(bigint, text, text, date, dep bigint[], tname text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
    DECLARE ret DOUBLE PRECISION;
    DECLARE total DOUBLE PRECISION;
    DECLARE array_len int;
    DECLARE totalText text;
    DECLARE sales_len int;
    DECLARE myDepIds bigint[];
    DECLARE salesIds bigint[];
    BEGIN 
        IF dep IS NOT NULL THEN
            total :=0;
            totalText := '';
            array_len := array_upper(DEP, 1);
            -----------------------------------------------------
            tname:=tname||'_';
	    FOR k IN 1 .. array_len
            LOOP
                tname:=tname || DEP[k];
            END LOOP;            
            EXECUTE 'CREATE TEMPORARY TABLE  ' || tname || '  (dep_id bigint )';
	    FOR i IN 1 .. array_len
            LOOP
                select array(select id from department where deleted='N' and department_parent_id=DEP[i] order by department_parent_id) into salesIds;
                sales_len := array_upper(salesIds, 1);
                IF sales_len IS NOT NULL THEN
                    FOR k IN 1 .. sales_len
                    LOOP
                       EXECUTE 'INSERT INTO ' || tname || ' values ('|| salesIds[k] || ')';
                    END LOOP;
                END IF;
            END LOOP;
            EXECUTE 'select array(select distinct(dep_id) from ' || tname || ' where dep_id is not null)' into myDepIds;
            -----------------------------------------------------
            array_len := array_upper(myDepIds, 1);
            IF array_len IS NOT NULL THEN
               FOR i IN 1 .. array_len
               LOOP
                   SELECT INTO ret sum(sp.value)
                   FROM sales_paf as sp, sales_type as st, department
                   WHERE sp.location_id = $1
                   AND sp.department_id = department.id
                   AND department.id IN (myDepIds[i])
                   AND department.deleted='N'
                   --AND department.available_for_scheduling = 'Y'
                   AND sp.sales_type_id = st.id
                   AND st.description = $2
                   AND sp.type = $3
                   AND sp.belongs_to between $4 AND $4
                   AND sp.deleted='N';
                   IF ret IS NOT NULL THEN
                       total := total + ret;
                       totalText := totalText || myDepIds[i] || '_' || ret || ',';
                   END IF;
               END LOOP;
            END IF;
            EXECUTE 'DROP TABLE ' || tname;
            RETURN totalText;
        ELSE
            ret :=0;
            totalText := '';
            --you have to have departments for reportsto
            RETURN totalText;
        END IF;
    END;
$_$;


ALTER FUNCTION public.paf_total_reportsto_text(bigint, text, text, date, dep bigint[], tname text) OWNER TO postgres;

--
-- Name: paf_total_rollup(bigint, text, text, date, bigint[], text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION paf_total_rollup(bigint, text, text, date, dep bigint[], tname text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
    DECLARE ret DOUBLE PRECISION;
    DECLARE totalText text;
    DECLARE array_len int;
    DECLARE sales_len int;
    DECLARE myDepIds bigint[];
    DECLARE salesIds bigint[];
    DECLARE t_name text;
    BEGIN 
        IF dep IS NOT NULL THEN
            array_len := array_upper(DEP, 1);
            -----------------------------------------------------
            t_name:=tname||'_';
	    FOR k IN 1 .. array_len
            LOOP
                t_name:=t_name || DEP[k];
            END LOOP;            
            EXECUTE 'CREATE TEMPORARY TABLE  ' || t_name || '  (dep_id bigint )';
	    FOR i IN 1 .. array_len
            LOOP
                select array(select department_roll_up.sales_department_id FROM department_roll_up WHERE deleted='N' AND department_roll_up.department_id=DEP[i]) into salesIds;
                sales_len := array_upper(salesIds, 1);
                IF sales_len IS NOT NULL THEN
                    FOR k IN 1 .. sales_len
                    LOOP
                       EXECUTE 'INSERT INTO ' || t_name || ' values ('|| salesIds[k] || ')';
                    END LOOP;
                END IF;
            END LOOP;
            EXECUTE 'select array(select distinct(dep_id) from ' || t_name || ' where dep_id is not null)' into myDepIds;
            -----------------------------------------------------
            array_len := array_upper(myDepIds, 1);
            IF array_len IS NOT NULL THEN
               totalText := '';
               FOR i IN 1 .. array_len
               LOOP
                   SELECT INTO ret sum(sp.value)
                   FROM sales_paf as sp, sales_type as st, department
                   WHERE sp.location_id = $1
                   AND sp.department_id = department.id
                   AND department.id IN (myDepIds[i])
                   AND department.deleted='N'
                   AND sp.sales_type_id = st.id
                   AND st.description = $2
                   AND sp.type = $3
                   AND sp.belongs_to between $4 AND $4
                   AND sp.deleted='N';
                   IF ret IS NOT NULL THEN
                       totalText := totalText || myDepIds[i] || '_' || ret || ',';
                   END IF;
               END LOOP;
            END IF;
            EXECUTE 'DROP TABLE ' || t_name;
            RETURN totalText;
        ELSE
            totalText := '';
            --you have to have departments for rollup
            RETURN totalText;
        END IF;
    END;
$_$;


ALTER FUNCTION public.paf_total_rollup(bigint, text, text, date, dep bigint[], tname text) OWNER TO postgres;

--
-- Name: pgp_key_id(bytea); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION pgp_key_id(bytea) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_key_id_w';


ALTER FUNCTION public.pgp_key_id(bytea) OWNER TO ressystems;

--
-- Name: pgp_pub_decrypt(bytea, bytea); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION pgp_pub_decrypt(bytea, bytea) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text';


ALTER FUNCTION public.pgp_pub_decrypt(bytea, bytea) OWNER TO ressystems;

--
-- Name: pgp_pub_decrypt(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION pgp_pub_decrypt(bytea, bytea, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text';


ALTER FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) OWNER TO ressystems;

--
-- Name: pgp_pub_decrypt(bytea, bytea, text, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION pgp_pub_decrypt(bytea, bytea, text, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text';


ALTER FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) OWNER TO ressystems;

--
-- Name: pgp_pub_decrypt_bytea(bytea, bytea); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION pgp_pub_decrypt_bytea(bytea, bytea) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea';


ALTER FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) OWNER TO ressystems;

--
-- Name: pgp_pub_decrypt_bytea(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea';


ALTER FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) OWNER TO ressystems;

--
-- Name: pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea';


ALTER FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) OWNER TO ressystems;

--
-- Name: pgp_pub_encrypt(text, bytea); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION pgp_pub_encrypt(text, bytea) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_text';


ALTER FUNCTION public.pgp_pub_encrypt(text, bytea) OWNER TO ressystems;

--
-- Name: pgp_pub_encrypt(text, bytea, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION pgp_pub_encrypt(text, bytea, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_text';


ALTER FUNCTION public.pgp_pub_encrypt(text, bytea, text) OWNER TO ressystems;

--
-- Name: pgp_pub_encrypt_bytea(bytea, bytea); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION pgp_pub_encrypt_bytea(bytea, bytea) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_bytea';


ALTER FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) OWNER TO ressystems;

--
-- Name: pgp_pub_encrypt_bytea(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_bytea';


ALTER FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) OWNER TO ressystems;

--
-- Name: pgp_sym_decrypt(bytea, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION pgp_sym_decrypt(bytea, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_text';


ALTER FUNCTION public.pgp_sym_decrypt(bytea, text) OWNER TO ressystems;

--
-- Name: pgp_sym_decrypt(bytea, text, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION pgp_sym_decrypt(bytea, text, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_text';


ALTER FUNCTION public.pgp_sym_decrypt(bytea, text, text) OWNER TO ressystems;

--
-- Name: pgp_sym_decrypt_bytea(bytea, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION pgp_sym_decrypt_bytea(bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_bytea';


ALTER FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) OWNER TO ressystems;

--
-- Name: pgp_sym_decrypt_bytea(bytea, text, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION pgp_sym_decrypt_bytea(bytea, text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_bytea';


ALTER FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) OWNER TO ressystems;

--
-- Name: pgp_sym_encrypt(text, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION pgp_sym_encrypt(text, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_text';


ALTER FUNCTION public.pgp_sym_encrypt(text, text) OWNER TO ressystems;

--
-- Name: pgp_sym_encrypt(text, text, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION pgp_sym_encrypt(text, text, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_text';


ALTER FUNCTION public.pgp_sym_encrypt(text, text, text) OWNER TO ressystems;

--
-- Name: pgp_sym_encrypt_bytea(bytea, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION pgp_sym_encrypt_bytea(bytea, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_bytea';


ALTER FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) OWNER TO ressystems;

--
-- Name: pgp_sym_encrypt_bytea(bytea, text, text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION pgp_sym_encrypt_bytea(bytea, text, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_bytea';


ALTER FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) OWNER TO ressystems;

--
-- Name: sales_threshold_byspecs(bigint, text, bigint[], date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sales_threshold_byspecs(loc_id bigint, stype text, dep bigint[], sdate date, edate date) RETURNS double precision
    LANGUAGE plpgsql
    AS $_$
   DECLARE total double precision;
   DECLARE counter int;
   DECLARE d_t double precision;
   DECLARE d_c int;
   DECLARE numOfDays int;
   DECLARE array_len int;
   BEGIN
      counter:=0;
      total:=0;
      numOfDays := ( (date( $5 )+1) - date( $4 ) );
      --this loop actually needed for the sales by minute interval, the others did not need
      --here we are getting all desired_ratios and averaging at the end
      FOR j IN 1 .. numOfDays
      LOOP       
         d_t:=0;
         d_c:=0;
         --if we have department look for sales_dep_threshold for those dates
         IF dep IS NOT NULL THEN         
            array_len := array_upper(DEP, 1);
            FOR i IN 1 .. array_len
            LOOP
               --
               SELECT count(sdt.id), sum(sdt.desired_ratio) INTO d_c, d_t
               FROM sales_type as st, sales_type_location as stl, department_location as dl
               , sales_dep_threshold as sdt
               WHERE stl.location_id in ( $1 )
               AND stl.sales_type_id = st.id
               AND st.description = $2
               AND stl.location_id = dl.location_id
               AND dl.department_id in ( DEP[i] )
               AND sdt.dep_loc_id = dl.id
               AND sdt.sales_type_loc_id = stl.id
               AND sdt.start_date <= (date( $4 )-1)+j AND sdt.end_date >= (date( $4 )-1)+j
               AND st.deleted='N'
               AND stl.deleted='N'
               AND dl.deleted='N'
               AND sdt.deleted='N';
               --
               IF d_c IS NOT NULL THEN
                  counter := counter + d_c;
               END IF;
               IF d_t IS NOT NULL THEN
                  total := total + d_t;
               END IF;
            END LOOP;
         END IF;
         --if we do not have department or do not have sales_dep_threshold for those dates by department
         --look for default (sales_type_location)
         IF dep IS NULL OR d_c IS NULL OR d_c = 0 THEN
            SELECT count(stl.id), sum(stl.desired_ratio) INTO d_c, d_t
            FROM sales_type as st, sales_type_location as stl
            WHERE stl.location_id in ( $1 )
            AND stl.sales_type_id = st.id
            AND st.description = $2
            AND st.deleted='N'
            AND stl.deleted='N';
            --
            IF d_c IS NOT NULL THEN
               counter := counter + d_c;
            END IF;
            IF d_t IS NOT NULL THEN
               total := total + d_t;
            END IF;
         END IF;
      END LOOP;
      --if we have some value, return the average just in case
      IF counter > 0 THEN
         RETURN total / counter;
      ELSE
         RETURN 0;
      END IF;
   END;
$_$;


ALTER FUNCTION public.sales_threshold_byspecs(loc_id bigint, stype text, dep bigint[], sdate date, edate date) OWNER TO postgres;

--
-- Name: sch_emp_totals(bigint, date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sch_emp_totals(bigint, date, date, date) RETURNS sch_sum
    LANGUAGE sql
    AS $_$
    SELECT sum(EXTRACT(epoch FROM to_timestamp(ti.end_date || ' ' || ti.end_time, 'YYYY-mm-DD HH24:MI:SS') - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS')))
, sum(ti.cost)
FROM timeblock as ti, schedule as sc
WHERE sc.id = ti.schedule_id
AND ti.employee_id = $1
AND sc.deleted = 'N'
AND ti.deleted = 'N'
AND ti.deleted_flag = 'N'
AND ti.start_date >= $2 AND ti.start_date <= $3
AND ti.start_date >= $4
$_$;


ALTER FUNCTION public.sch_emp_totals(bigint, date, date, date) OWNER TO postgres;

--
-- Name: sch_emp_totals_bydep(bigint, date, date, date, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sch_emp_totals_bydep(bigint, date, date, date, bigint) RETURNS sch_sum
    LANGUAGE sql
    AS $_$
    SELECT sum(EXTRACT(epoch FROM to_timestamp(ti.end_date || ' ' || ti.end_time, 'YYYY-mm-DD HH24:MI:SS') - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS')))
	, sum(ti.cost)
	FROM timeblock as ti, schedule as sc
	WHERE sc.id = ti.schedule_id
        AND sc.department_id = $5
	AND ti.employee_id = $1
	AND sc.deleted = 'N'
	AND ti.deleted = 'N'
	AND ti.deleted_flag = 'N'
	AND ti.start_date >= $2 AND ti.start_date <= $3
	AND ti.start_date >= $4
$_$;


ALTER FUNCTION public.sch_emp_totals_bydep(bigint, date, date, date, bigint) OWNER TO postgres;

--
-- Name: sch_emppos_totals(bigint, bigint, bigint, date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sch_emppos_totals(bigint, bigint, bigint, date, date, date) RETURNS sch_sum
    LANGUAGE sql
    AS $_$
    SELECT sum(EXTRACT(epoch FROM to_timestamp(ti.end_date || ' ' || ti.end_time, 'YYYY-mm-DD HH24:MI:SS') - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS')))
, sum(ti.cost)
FROM timeblock as ti, schedule as sc
WHERE sc.id = ti.schedule_id
AND ti.location_id = $1
AND ti.employee_id = $2
AND ti.position_id = $3
AND sc.deleted = 'N'
AND ti.deleted = 'N'
AND ti.deleted_flag = 'N'
AND ti.start_date >= $4 AND ti.start_date <= $5
AND ti.start_date >= $6
$_$;


ALTER FUNCTION public.sch_emppos_totals(bigint, bigint, bigint, date, date, date) OWNER TO postgres;

--
-- Name: sch_emppos_totals_bydep(bigint, bigint, bigint, date, date, date, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sch_emppos_totals_bydep(bigint, bigint, bigint, date, date, date, bigint) RETURNS sch_sum
    LANGUAGE sql
    AS $_$
    SELECT sum(EXTRACT(epoch FROM to_timestamp(ti.end_date || ' ' || ti.end_time, 'YYYY-mm-DD HH24:MI:SS') - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS')))
	, sum(ti.cost)
	FROM timeblock as ti, schedule as sc
	WHERE sc.id = ti.schedule_id
        AND sc.department_id = $7
	AND ti.location_id = $1
	AND ti.employee_id = $2
	AND ti.position_id = $3
	AND sc.deleted = 'N'
	AND ti.deleted = 'N'
	AND ti.deleted_flag = 'N'
	AND ti.start_date >= $4 AND ti.start_date <= $5
	AND ti.start_date >= $6
$_$;


ALTER FUNCTION public.sch_emppos_totals_bydep(bigint, bigint, bigint, date, date, date, bigint) OWNER TO postgres;

--
-- Name: sch_shift_hours_cost_function(bigint, date, date, bigint, bigint, bigint[]); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION sch_shift_hours_cost_function(bigint, date, date, bigint, bigint, dep bigint[]) RETURNS sch_shift_hours_cost
    LANGUAGE plpgsql
    AS $_$
   DECLARE ret sch_shift_hours_cost;
   DECLARE total sch_shift_hours_cost;
   DECLARE array_len int;
   BEGIN
      IF dep IS NOT NULL THEN
         total.sch_shifts :=0;
         total.sch_hours :=0;
         total.sch_cost :=0;
         array_len := array_upper(DEP, 1);
         FOR i IN 1 .. array_len
         LOOP
            SELECT count(ti.id)
            ,sum( EXTRACT(EPOCH FROM ( (LEAST(to_timestamp(ti.start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES', to_timestamp(ti.end_date || ' ' || ti.end_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp - 
            GREATEST(to_timestamp(ti.start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES', to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp) / 60 ) ) )  AS p_minutes
            
            ,sum( cost * ( 
            (
            EXTRACT(EPOCH FROM ( (LEAST(to_timestamp(ti.start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES', to_timestamp(ti.end_date || ' ' || ti.end_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp - 
            GREATEST(to_timestamp(ti.start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES', to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp) / 60 ) ) /
            EXTRACT(EPOCH FROM ( (to_timestamp(ti.end_date || ' ' || ti.end_time, 'YYYY-mm-DD HH24:MI:SS')::timestamp - 
            to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS')::timestamp) / 60 ) )
            ) 
            ) ) AS period_expense INTO ret
            
            FROM timeblock as ti, schedule as sc
            WHERE ti.location_id = $1
            AND sc.id = ti.schedule_id
            AND sc.department_id IN (DEP[i])
            AND ti.deleted = 'N'
            AND ti.deleted_flag = 'N'
            AND sc.deleted = 'N'
            AND ti.start_date between $2 AND $3
            AND 
            (to_timestamp(ti.end_date || ' ' || ti.end_time, 'YYYY-mm-DD HH24:MI:SS') >= to_timestamp(ti.start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES' 
            AND to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS') < to_timestamp(ti.start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES'
            )
            AND ti.end_date IS NOT NULL
            --AND (ti.start_date = ti.end_date and ti.start_time != ti.end_time);
            AND ((ti.start_time < ti.end_time and ti.end_date = ti.start_date) or (ti.start_time = ti.end_time and ti.start_date != ti.end_date) or (ti.end_time < ti.start_time and ti.start_date < ti.end_date));
            IF ret.sch_shifts IS NOT NULL THEN
               total.sch_shifts := total.sch_shifts + ret.sch_shifts;
            END IF;
            IF ret.sch_hours IS NOT NULL THEN
               total.sch_hours := total.sch_hours + ret.sch_hours;
            END IF;
            IF ret.sch_cost IS NOT NULL THEN
               total.sch_cost := total.sch_cost + ret.sch_cost;
            END IF;
         END LOOP;
         RETURN total;
      ELSE
         SELECT count(id)
         ,sum( EXTRACT(EPOCH FROM ( (LEAST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES', to_timestamp(end_date || ' ' || end_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp - 
         GREATEST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES', to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp) / 60 ) ) )  AS p_minutes
         
         ,sum( cost * ( 
         (
         EXTRACT(EPOCH FROM ( (LEAST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES', to_timestamp(end_date || ' ' || end_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp - 
         GREATEST(to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES', to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS'))::timestamp) / 60 ) ) /
         EXTRACT(EPOCH FROM ( (to_timestamp(end_date || ' ' || end_time, 'YYYY-mm-DD HH24:MI:SS')::timestamp - 
         to_timestamp(start_date || ' ' || start_time, 'YYYY-mm-DD HH24:MI:SS')::timestamp) / 60 ) )
         ) 
         ) ) AS period_expense INTO ret
         
         FROM timeblock as ti
         WHERE ti.location_id = $1
         AND ti.deleted = 'N'
         AND ti.deleted_flag = 'N'
         AND ti.start_date between $2 AND $3
         AND 
         (to_timestamp(end_date || ' ' || ti.end_time, 'YYYY-mm-DD HH24:MI:SS') >= to_timestamp(start_date||'', 'YYYY-mm-DD') + $4 * INTERVAL '1 MINUTES' 
         AND to_timestamp(start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS') < to_timestamp(start_date||'', 'YYYY-mm-DD') + $5 * INTERVAL '1 MINUTES'
         )
         AND end_date IS NOT NULL
         --AND (start_date = end_date and start_time != end_time);
         AND ((ti.start_time < ti.end_time and ti.end_date = ti.start_date) or (ti.start_time = ti.end_time and ti.start_date != ti.end_date) or (ti.end_time < ti.start_time and ti.start_date < ti.end_date));
      RETURN ret;
      END IF;
   END;
$_$;


ALTER FUNCTION public.sch_shift_hours_cost_function(bigint, date, date, bigint, bigint, dep bigint[]) OWNER TO ressystems;

--
-- Name: schedule_agg(bigint, date, bigint[]); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION schedule_agg(bigint, date, dep bigint[]) RETURNS sch_agg_totals
    LANGUAGE plpgsql
    AS $_$
    DECLARE ret sch_agg_totals;
	DECLARE total sch_agg_totals;
    DECLARE array_len int;
    BEGIN 
        IF dep IS NOT NULL THEN
            total.sch_shifts :=0;
            total.sch_hours :=0;
            total.sch_sales_cost :=0;
            array_len := array_upper(DEP, 1);
            FOR i IN 1 .. array_len
            LOOP
                SELECT count(ti.id) as shifts
	            , sum(EXTRACT(epoch FROM to_timestamp(ti.end_date || ' ' || ti.end_time, 'YYYY-mm-DD HH24:MI:SS') - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS')))
                , sum(cost) as cost INTO ret
                FROM timeblock as ti, schedule as sc
                WHERE ti.location_id = $1
                AND sc.id = ti.schedule_id
                AND sc.department_id IN (DEP[i])
                AND ti.deleted = 'N'
                AND ti.deleted_flag = 'N'
                AND sc.deleted = 'N'
                AND ti.start_date between $2 AND $2 ;
                IF ret.sch_shifts IS NOT NULL THEN
                    total.sch_shifts := total.sch_shifts + ret.sch_shifts;
                END IF;
                IF ret.sch_hours IS NOT NULL THEN
                    total.sch_hours := total.sch_hours + ret.sch_hours;
                END IF;
                IF ret.sch_sales_cost IS NOT NULL THEN
                   total.sch_sales_cost := total.sch_sales_cost + ret.sch_sales_cost;
                END IF;
            END LOOP;
            RETURN total;
        ELSE
            SELECT count(ti.id) as shifts
	        , sum(EXTRACT(epoch FROM to_timestamp(ti.end_date || ' ' || ti.end_time, 'YYYY-mm-DD HH24:MI:SS') - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS')))
            , sum(cost) as cost INTO ret
            FROM timeblock as ti
            WHERE ti.location_id = $1
            AND ti.deleted = 'N'
            AND ti.deleted_flag = 'N'
            AND ti.start_date between $2 AND $2 ;
            RETURN ret;
        END IF;
    END;
$_$;


ALTER FUNCTION public.schedule_agg(bigint, date, dep bigint[]) OWNER TO ressystems;

--
-- Name: schedule_agg_by_pos(bigint, date, bigint[], bigint, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION schedule_agg_by_pos(bigint, date, dep bigint[], bigint, date) RETURNS sch_agg_totals
    LANGUAGE plpgsql
    AS $_$
    DECLARE ret sch_agg_totals;
    DECLARE total sch_agg_totals;
    DECLARE array_len int;
    BEGIN 
        IF dep IS NOT NULL THEN
            total.sch_shifts :=0;
            total.sch_hours :=0;
            total.sch_sales_cost :=0;
            array_len := array_upper(DEP, 1);
            FOR i IN 1 .. array_len
            LOOP
                SELECT count(ti.id) as shifts
	            , sum(EXTRACT(epoch FROM to_timestamp(ti.end_date || ' ' || ti.end_time, 'YYYY-mm-DD HH24:MI:SS') - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS')))
                , sum(cost) as cost INTO ret
                FROM timeblock as ti, schedule as sc
                WHERE ti.location_id = $1
                AND sc.id = ti.schedule_id
                AND sc.department_id IN (DEP[i])
                AND ti.deleted = 'N'
                AND ti.deleted_flag = 'N'
                AND sc.deleted = 'N'
                AND ti.position_id = $4
                AND ti.start_date between $2 AND $5 ;
                IF ret.sch_shifts IS NOT NULL THEN
                    total.sch_shifts := total.sch_shifts + ret.sch_shifts;
                END IF;
                IF ret.sch_hours IS NOT NULL THEN
                    total.sch_hours := total.sch_hours + ret.sch_hours;
                END IF;
                IF ret.sch_sales_cost IS NOT NULL THEN
                   total.sch_sales_cost := total.sch_sales_cost + ret.sch_sales_cost;
                END IF;
            END LOOP;
            RETURN total;
        ELSE
            SELECT count(ti.id) as shifts
	        , sum(EXTRACT(epoch FROM to_timestamp(ti.end_date || ' ' || ti.end_time, 'YYYY-mm-DD HH24:MI:SS') - to_timestamp(ti.start_date || ' ' || ti.start_time, 'YYYY-mm-DD HH24:MI:SS')))
            , sum(cost) as cost INTO ret
            FROM timeblock as ti
            WHERE ti.location_id = $1
            AND ti.deleted = 'N'
            AND ti.deleted_flag = 'N'
            AND ti.position_id = $4
            AND ti.start_date between $2 AND $5 ;
            RETURN ret;
        END IF;
    END;
$_$;


ALTER FUNCTION public.schedule_agg_by_pos(bigint, date, dep bigint[], bigint, date) OWNER TO postgres;

--
-- Name: text2bytea(text); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION text2bytea(text) RETURNS bytea
    LANGUAGE plpgsql
    AS $_$
DECLARE
  b bytea;
BEGIN
  EXECUTE 'SELECT  ' || quote_literal($1) || '::bytea' INTO b;
  RETURN b;
END
$_$;


ALTER FUNCTION public.text2bytea(text) OWNER TO ressystems;

--
-- Name: update233(); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION update233() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from empman LOOP
        update employee set corporate_user='Y' where id = tmprow.empid;
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.update233() OWNER TO ressystems;

--
-- Name: update235(); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION update235() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from usrrole LOOP
        insert into user_role ("user_id","role_id") values(tmprow.uid,7);
        insert into user_role ("user_id","role_id") values(tmprow.uid,9);
        insert into user_role ("user_id","role_id") values(tmprow.uid,11);
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.update235() OWNER TO ressystems;

--
-- Name: update241(); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION update241() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from emp_pt LOOP
    insert into employee_preference_type (id, employee_id,preference_type_id,parent_id, deleted, starttimestamp, endtimestamp)
    values (tmprow.hibernateval,  tmprow.e_id, tmprow.pt_id, null, 'N', tmprow.nowval, null);
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.update241() OWNER TO ressystems;

--
-- Name: update_default_categories(); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION update_default_categories() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from managerlogtable LOOP
    -- Selects each "TimeForge" category row
    insert into manager_log_category (id, description, defaultcategoryid, corporation_id, parent_manager_log_category_id, parent_id, deleted, starttimestamp, endtimestamp) values (tmprow.hibernateval, 'Audit Log', 2, tmprow.corporation_id, tmprow.id, null, 'N', tmprow.nowval, null);
    insert into manager_log_category (id, description, defaultcategoryid, corporation_id, parent_manager_log_category_id, parent_id, deleted, starttimestamp, endtimestamp) values (tmprow.hibernateval2, 'Attendance', 3, tmprow.corporation_id, tmprow.hibernateval, null, 'N', tmprow.nowval, null);
    insert into manager_log_category (id, description, defaultcategoryid, corporation_id, parent_manager_log_category_id, parent_id, deleted, starttimestamp, endtimestamp) values (tmprow.hibernateval3, 'Schedules', 4, tmprow.corporation_id, tmprow.hibernateval, null, 'N', tmprow.nowval, null);
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.update_default_categories() OWNER TO ressystems;

--
-- Name: update_default_categories134(); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION update_default_categories134() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from managerlogtable LOOP
    -- Selects each "TimeForge" category row
    insert into manager_log_category (id, description, defaultcategoryid, corporation_id, parent_manager_log_category_id, parent_id, deleted, starttimestamp, endtimestamp) values (tmprow.hibernateval, 'PTO', 8, tmprow.corporation_id, tmprow.id, null, 'N', tmprow.nowval, null);
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.update_default_categories134() OWNER TO ressystems;

--
-- Name: update_default_categories2(); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION update_default_categories2() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from managerlogtable LOOP
    -- Selects each "TimeForge" category row
    insert into manager_log_category (id, description, defaultcategoryid, corporation_id, parent_manager_log_category_id, parent_id, deleted, starttimestamp, endtimestamp) values (tmprow.hibernateval, 'Weather', 5, tmprow.corporation_id, tmprow.id, null, 'N', tmprow.nowval, null);
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.update_default_categories2() OWNER TO ressystems;

--
-- Name: update_default_categories228(); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION update_default_categories228() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from managerlogtable LOOP
    -- Selects each "TimeForge" category row
    insert into manager_log_category (id, description, defaultcategoryid, corporation_id, parent_manager_log_category_id, parent_id, deleted, starttimestamp, endtimestamp,logtype)
    values (tmprow.hibernateval, 'Short Staffing', 10, tmprow.corporation_id, tmprow.id, null, 'N', tmprow.nowval, null,3);
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.update_default_categories228() OWNER TO ressystems;

--
-- Name: update_default_categories3(); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION update_default_categories3() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from managerlogtable LOOP
    -- Selects each "TimeForge" category row
    insert into manager_log_category (id, description, defaultcategoryid, corporation_id, parent_manager_log_category_id, parent_id, deleted, starttimestamp, endtimestamp) values (tmprow.hibernateval, 'Employees', 6, tmprow.corporation_id, tmprow.id, null, 'N', tmprow.nowval, null);
    insert into manager_log_category (id, description, defaultcategoryid, corporation_id, parent_manager_log_category_id, parent_id, deleted, starttimestamp, endtimestamp) values (tmprow.hibernateval2, 'Certifications', 7, tmprow.corporation_id, tmprow.hibernateval, null, 'N', tmprow.nowval, null);
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.update_default_categories3() OWNER TO ressystems;

--
-- Name: update_default_categories4(); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION update_default_categories4() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from managerlogtable LOOP
    -- Selects each "TimeForge" category row
    insert into manager_log_category (id, description, defaultcategoryid, corporation_id, parent_manager_log_category_id, parent_id, deleted, starttimestamp, endtimestamp, logtype, tfmanaged) values (nextval ('manager_log_category_id_seq'), 'Sales Volume', 11, tmprow.corporation_id, null, null, 'N', tmprow.nowval, null, 1, 1);
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.update_default_categories4() OWNER TO ressystems;

--
-- Name: update_default_categories5(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION update_default_categories5() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from managerlogtable LOOP
    -- Selects each "TimeForge" category row
    insert into manager_log_category (id, description, defaultcategoryid, corporation_id, parent_manager_log_category_id, parent_id, deleted, starttimestamp, endtimestamp, logtype, tfmanaged) values (nextval ('manager_log_category_id_seq'), 'Holiday', 12, tmprow.corporation_id, null, null, 'N', tmprow.nowval, null, 1, 1);
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.update_default_categories5() OWNER TO postgres;

--
-- Name: update_emp_sett43(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION update_emp_sett43() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from newee LOOP

insert into employee_setting (employee_id, flag_id, value, deleted, starttimestamp) values (tmprow.eid, 43, 'weekly', 'N', now());
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.update_emp_sett43() OWNER TO postgres;

--
-- Name: update_free_trials(); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION update_free_trials() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from price_table LOOP
    update price_object set free_trial_end_date = tmprow.datecol where id = tmprow.price_id;
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.update_free_trials() OWNER TO ressystems;

--
-- Name: update_old_price_objects(); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION update_old_price_objects() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from price_table LOOP
    IF tmprow.payment_plan IS NULL THEN
        update price_object set 
            max_employees = null,
            multiple_locations = 'Y',
            autoscheduler = 'Y',
            reports = '1,2,6,7,8,9,10,11,12,13,14,15,16,17,18,20,21,22,23,25,26,27,28,29,30,31,32',
            email_messages = 'Y',
            sms_messages = 'Y',
            messaging = 'Y',
            manager_log = 'Y',
            shift_swaps = 'Y',
            departments = 'Y',
            age_rules = 'Y',
            break_rules = 'Y',
            preference_types = 'Y',
            templates = 'Y',
            attendance = 'Y',
            payroll_export = 'Y',
            biometrics = 'Y',
            integration = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 1 THEN
        update price_object set 
            max_employees = 15,
            multiple_locations = 'N',
            autoscheduler = 'N',
            reports = '1,10,11,20,21,32',
            email_messages = 'N',
            sms_messages = 'N',
            messaging = 'Y',
            manager_log = 'Y',
            shift_swaps = 'Y',
            departments = 'Y',
            age_rules = 'Y',
            break_rules = 'Y',
            preference_types = 'Y',
            templates = 'Y',
            attendance = 'N',
            payroll_export = 'Y',
            biometrics = 'Y',
            integration = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 2 THEN
        update price_object set 
            max_employees = 30,
            multiple_locations = 'N',
            autoscheduler = 'N',
            reports = '1,7,8,10,11,16,17,20,21,26,27,28,29,32',
            email_messages = 'Y',
            sms_messages = 'N',
            messaging = 'Y',
            manager_log = 'Y',
            shift_swaps = 'Y',
            departments = 'Y',
            age_rules = 'Y',
            break_rules = 'Y',
            preference_types = 'Y',
            templates = 'Y',
            attendance = 'Y',
            payroll_export = 'Y',
            biometrics = 'Y',
            integration = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 3 THEN
        update price_object set 
            max_employees = 60,
            multiple_locations = 'Y',
            autoscheduler = 'Y',
            reports = '1,2,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,28,29,32',
            email_messages = 'Y',
            sms_messages = 'Y',
            messaging = 'Y',
            manager_log = 'Y',
            shift_swaps = 'Y',
            departments = 'Y',
            age_rules = 'Y',
            break_rules = 'Y',
            preference_types = 'Y',
            templates = 'Y',
            attendance = 'Y',
            payroll_export = 'Y',
            biometrics = 'Y',
            integration = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 4 THEN
        update price_object set 
            max_employees = null,
            multiple_locations = 'Y',
            autoscheduler = 'Y',
            reports = '1,2,6,7,8,9,10,11,12,13,14,15,16,17,18,20,21,22,23,25,26,27,28,29,32',
            email_messages = 'Y',
            sms_messages = 'Y',
            messaging = 'Y',
            manager_log = 'Y',
            shift_swaps = 'Y',
            departments = 'Y',
            age_rules = 'Y',
            break_rules = 'Y',
            preference_types = 'Y',
            templates = 'Y',
            attendance = 'Y',
            payroll_export = 'Y',
            biometrics = 'Y',
            integration = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 5 THEN
        update price_object set 
            max_employees = null,
            multiple_locations = 'Y',
            autoscheduler = 'N',
            reports = '1,7,8,10,11,15,16,17,20,21,22,23,26,27,28,29,30,31,32',
            email_messages = 'Y',
            sms_messages = 'N',
            messaging = 'Y',
            manager_log = 'Y',
            shift_swaps = 'Y',
            departments = 'Y',
            age_rules = 'Y',
            break_rules = 'Y',
            preference_types = 'Y',
            templates = 'Y',
            attendance = 'N',
            payroll_export = 'Y',
            biometrics = 'Y',
            integration = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 6 THEN
        update price_object set 
            max_employees = null,
            multiple_locations = 'Y',
            autoscheduler = 'Y',
            reports = '1,2,6,7,8,9,10,11,12,13,14,15,16,17,18,20,21,22,23,25,26,27,28,29,30,31,32',
            email_messages = 'Y',
            sms_messages = 'Y',
            messaging = 'Y',
            manager_log = 'Y',
            shift_swaps = 'Y',
            departments = 'Y',
            age_rules = 'Y',
            break_rules = 'Y',
            preference_types = 'Y',
            templates = 'Y',
            attendance = 'Y',
            payroll_export = 'Y',
            biometrics = 'Y',
            integration = 'Y'
        where id = tmprow.price_id;
    END IF;
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.update_old_price_objects() OWNER TO ressystems;

--
-- Name: update_prices_110(); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION update_prices_110() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from price_table LOOP
    IF tmprow.payment_plan IS NULL THEN
        update price_object set 
            sales_paf = 'Y',
            sales_paf_analysis = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 0 THEN
        update price_object set
            sales_paf = 'Y',
            sales_paf_analysis = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 1 THEN
        update price_object set 
            sales_paf = 'Y',
            sales_paf_analysis = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 2 THEN
        update price_object set 
            sales_paf = 'Y',
            sales_paf_analysis = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 3 THEN
        update price_object set 
            sales_paf = 'Y',
            sales_paf_analysis = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 4 THEN
        update price_object set 
            sales_paf = 'Y',
            sales_paf_analysis = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 5 THEN
        update price_object set 
            sales_paf = 'Y',
            sales_paf_analysis = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 6 THEN
        update price_object set 
            sales_paf = 'Y',
            sales_paf_analysis = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 7 THEN
        update price_object set 
            sales_paf = 'Y',
            sales_paf_analysis = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 8 THEN
        update price_object set 
            sales_paf = 'Y',
            sales_paf_analysis = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 9 THEN
        update price_object set 
            sales_paf = 'Y',
            sales_paf_analysis = 'N'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 10 THEN
        update price_object set 
            sales_paf = 'N',
            sales_paf_analysis = 'N'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 11 THEN
        update price_object set 
            sales_paf = 'Y',
            sales_paf_analysis = 'N'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 12 THEN
        update price_object set 
            sales_paf = 'N',
            sales_paf_analysis = 'N'
        where id = tmprow.price_id;
    END IF;
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.update_prices_110() OWNER TO ressystems;

--
-- Name: update_prices_130(); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION update_prices_130() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from price_table LOOP
    IF tmprow.payment_plan = 20 THEN
        update price_object set 
            reports =reports|| ',55,56'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 21 THEN
        update price_object set
            reports =reports|| ',55,56'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 22 THEN
        update price_object set
            reports =reports|| ',55'
        where id = tmprow.price_id;
    END IF;

END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.update_prices_130() OWNER TO ressystems;

--
-- Name: update_prices_certs(); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION update_prices_certs() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from price_table LOOP
    IF tmprow.payment_plan IS NULL THEN
        update price_object set 

            certifications = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 0 THEN
        update price_object set

            certifications = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 1 THEN
        update price_object set 

            certifications = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 2 THEN
        update price_object set 

            certifications = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 3 THEN
        update price_object set 

            certifications = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 4 THEN
        update price_object set 

            certifications = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 5 THEN
        update price_object set 

            certifications = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 6 THEN
        update price_object set 

            certifications = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 7 THEN
        update price_object set 

            certifications = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 8 THEN
        update price_object set 

            certifications = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 9 THEN
        update price_object set 

            certifications = 'N'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 10 THEN
        update price_object set 

            certifications = 'N'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 11 THEN
        update price_object set 

            certifications = 'N'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 12 THEN
        update price_object set 

            certifications = 'N'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 13 THEN
        update price_object set
            certifications = 'N'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 14 THEN
        update price_object set
            certifications = 'N'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 15 THEN
        update price_object set
            certifications = 'N'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 16 THEN
        update price_object set
            certifications = 'N'
        where id = tmprow.price_id;
    END IF;
     IF tmprow.payment_plan = 17 THEN
        update price_object set
            certifications = 'N'
        where id = tmprow.price_id;
    END IF;
     IF tmprow.payment_plan = 18 THEN
        update price_object set
            certifications = 'N'
        where id = tmprow.price_id;
    END IF;
     IF tmprow.payment_plan = 19 THEN
        update price_object set
            certifications = 'N'
        where id = tmprow.price_id;
    END IF;
     IF tmprow.payment_plan = 20 THEN
        update price_object set
            certifications = 'Y'
        where id = tmprow.price_id;
    END IF;
     IF tmprow.payment_plan = 21 THEN
        update price_object set
            certifications = 'Y'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 22 THEN
        update price_object set
            certifications = 'N'
        where id = tmprow.price_id;
    END IF;
    IF tmprow.payment_plan = 23 THEN
        update price_object set
            certifications = 'N'
        where id = tmprow.price_id;
    END IF;
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.update_prices_certs() OWNER TO ressystems;

--
-- Name: updatenewreports(); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION updatenewreports() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
DECLARE
    myvar VARCHAR(100);
BEGIN
FOR tmprow IN select id,reports from price_object LOOP

      myvar='';
    IF tmprow.reports like '%15%'  THEN
        myvar=myvar||',50';
    END IF;

    IF tmprow.reports like '%21%'  THEN
        myvar=myvar||',51';
    END IF;

    IF tmprow.reports like '%23%'  THEN
        myvar=myvar||',52';
    END IF;

    IF tmprow.reports like '%39%'  THEN
        myvar=myvar||',53';
    END IF;

    IF tmprow.reports like '%40%'  THEN
        myvar=myvar||',54';
    END IF;
    IF length(myvar)>0THEN
    update price_object set
            reports =tmprow.reports|| myvar
        where id = tmprow.id;
    END IF;
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.updatenewreports() OWNER TO ressystems;

--
-- Name: updatesecurityroles(); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION updatesecurityroles() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from u_r LOOP
    insert into user_role (role_id,user_id) values (tmprow.rid,  tmprow.uid);
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.updatesecurityroles() OWNER TO ressystems;

--
-- Name: updatesecurityroles2(); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION updatesecurityroles2() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from u_r2 LOOP
    insert into user_role (role_id,user_id) values (95,  tmprow.uid);
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.updatesecurityroles2() OWNER TO ressystems;

--
-- Name: updatesecurityrolesx322(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION updatesecurityrolesx322() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from urx322 LOOP
    insert into user_role (role_id,user_id) values (97,  tmprow.uid);
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.updatesecurityrolesx322() OWNER TO postgres;

--
-- Name: updatesecurityrolesx330(); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION updatesecurityrolesx330() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from urx330 LOOP
    insert into user_role (role_id,user_id) values (99,  tmprow.uid);
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.updatesecurityrolesx330() OWNER TO ressystems;

--
-- Name: updatesecurityrolesx335(); Type: FUNCTION; Schema: public; Owner: ressystems
--

CREATE FUNCTION updatesecurityrolesx335() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tmprow RECORD;
BEGIN
FOR tmprow IN select * from urx335 LOOP
    insert into user_role (role_id,user_id) values (103,  tmprow.uid);
END LOOP;
RETURN 0;
END;
$$;


ALTER FUNCTION public.updatesecurityrolesx335() OWNER TO ressystems;

SET search_path = pg_catalog;

--
-- Name: CAST (text AS bytea); Type: CAST; Schema: pg_catalog; Owner: 
--

CREATE CAST (text AS bytea) WITH FUNCTION public.text2bytea(text);


SET search_path = public, pg_catalog;

--
-- Name: app_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE app_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.app_user_id_seq OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = true;

--
-- Name: app_user; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE app_user (
    id bigint DEFAULT nextval('app_user_id_seq'::regclass) NOT NULL,
    version integer NOT NULL,
    username character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    address character varying(150),
    city character varying(50) NOT NULL,
    state character varying(100),
    country character varying(255),
    zip character varying(15) NOT NULL,
    email character varying(255),
    phone_number character varying(255),
    website character varying(255),
    account_enabled character(1),
    account_expired character(1) NOT NULL,
    account_locked character(1) NOT NULL,
    credentials_expired character(1) NOT NULL,
    cpquestion character varying(255),
    cpanswer character varying(255),
    isemployee character(1),
    sms character varying(255),
    notify_email character(1),
    notify_sms character(1),
    smscarrier character varying(255),
    smsnotifyminutes integer,
    notify_number integer,
    notify_time integer,
    datecreated timestamp without time zone NOT NULL,
    emailenabled character varying(1),
    corporation_id bigint NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    vid character varying(255),
    middle_name character varying(50) DEFAULT ''::character varying,
    nomoreemail timestamp without time zone,
    receive_request_notification character(1) DEFAULT 'Y'::bpchar,
    receive_shift_swap_notification character(1) DEFAULT 'Y'::bpchar,
    nickname character varying(50),
    marital_status character varying(1),
    gender character varying(1),
    phone character varying(45),
    home_phone character varying(45),
    drivers_license_number character varying(40),
    linked_in_page character varying(255),
    facebook_page character varying(255),
    military_service character(1) DEFAULT 'N'::bpchar,
    ethnicity character(1) DEFAULT 'N'::bpchar,
    smoker character(1) DEFAULT 'N'::bpchar,
    emergency_contact_name character varying(100),
    emergency_contact_phone character varying(45)
);


ALTER TABLE public.app_user OWNER TO ressystems;

--
-- Name: applicant_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE applicant_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.applicant_id_seq OWNER TO postgres;

SET default_with_oids = false;

--
-- Name: applicant; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE applicant (
    id bigint DEFAULT nextval('applicant_id_seq'::regclass) NOT NULL,
    datecreated timestamp without time zone NOT NULL,
    birth_date timestamp without time zone,
    ssn text,
    ssn_suffix character varying(255),
    applicant_source character varying(255),
    applicant_source_description character varying(255),
    eligible_future_job character(1),
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    location_id bigint,
    position_id bigint,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    middle_name character varying(50),
    email character varying(255),
    address character varying(150),
    city character varying(50) NOT NULL,
    state character varying(100),
    country character varying(255),
    zip character varying(15) NOT NULL,
    marital_status character varying(1),
    gender character varying(1),
    phone character varying(45),
    sms character varying(255),
    drivers_license_number character varying(40),
    military_service character(1),
    ethnicity character(1),
    current_position_tracking_step_id bigint,
    external_applicant_id bigint,
    external_type character varying(5)
);


ALTER TABLE public.applicant OWNER TO postgres;

--
-- Name: applicant_document_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE applicant_document_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.applicant_document_id_seq OWNER TO ressystems;

--
-- Name: applicant_document; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE applicant_document (
    id bigint DEFAULT nextval('applicant_document_id_seq'::regclass) NOT NULL,
    eligible_future_job character(1),
    applicant_id bigint NOT NULL,
    document_id bigint NOT NULL,
    certification_id bigint NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.applicant_document OWNER TO ressystems;

--
-- Name: applicant_historical_step_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE applicant_historical_step_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.applicant_historical_step_id_seq OWNER TO postgres;

--
-- Name: applicant_historical_step; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE applicant_historical_step (
    id bigint DEFAULT nextval('applicant_historical_step_id_seq'::regclass) NOT NULL,
    applicant_id bigint NOT NULL,
    position_tracking_step_id bigint NOT NULL,
    datecreated timestamp without time zone NOT NULL,
    notes character varying(255),
    date_scheduled date,
    date_completed date,
    passed character(1),
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.applicant_historical_step OWNER TO postgres;

--
-- Name: attendance_block_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE attendance_block_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.attendance_block_id_seq OWNER TO postgres;

--
-- Name: attendance_block; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE attendance_block (
    id bigint DEFAULT nextval('attendance_block_id_seq'::regclass) NOT NULL,
    start_date date,
    end_date date,
    start_time time without time zone,
    end_time time without time zone,
    employee_id bigint,
    position_id bigint,
    location_id bigint,
    timeblock_id bigint,
    approving_manager bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone,
    cost double precision,
    tip numeric(15,2),
    mileage double precision,
    start_mileage numeric(15,2),
    end_mileage numeric(15,2),
    creator_id bigint,
    memo text,
    final_approval_datetime timestamp without time zone,
    final_approving_manager bigint,
    allocated_date date,
    correlated_timeblock_id bigint,
    department_id bigint,
    active_attendance_break_id bigint,
    total_duration integer,
    total_cost numeric(15,2),
    total_no_break_duration integer,
    total_no_break_cost numeric(15,2),
    regular_duration integer,
    regular_cost numeric(15,2),
    ot_duration integer,
    ot_cost numeric(15,2),
    double_ot_duration integer,
    double_ot_cost numeric(15,2),
    paid_break_duration integer,
    paid_break_cost numeric(15,2),
    unpaid_break_duration integer,
    unpaid_break_cost numeric(15,2),
    required_break_duration integer,
    required_break_cost numeric(15,2),
    optional_break_duration integer,
    optional_break_cost numeric(15,2),
    regular_rate numeric(15,2),
    ot_rate numeric(15,2),
    double_ot_rate numeric(15,2),
    employee_acknowledge_date timestamp without time zone,
    employee_added character(1) DEFAULT 'N'::bpchar,
    autoin character(1) DEFAULT 'N'::bpchar,
    autoout character(1) DEFAULT 'N'::bpchar,
    double_punch character(1) DEFAULT 'N'::bpchar,
    event_id bigint,
    ipaddress character(50),
    inpunchid character varying(255),
    outpunchid character varying(255)
);


ALTER TABLE public.attendance_block OWNER TO postgres;

--
-- Name: attendance_break_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE attendance_break_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.attendance_break_id_seq OWNER TO postgres;

--
-- Name: attendance_break; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE attendance_break (
    id bigint DEFAULT nextval('attendance_break_id_seq'::regclass) NOT NULL,
    start_date date,
    end_date date,
    start_time time without time zone,
    end_time time without time zone,
    paid character(1),
    optional character(1),
    cost double precision,
    duration_in_minutes integer,
    waived character(1),
    waivedreason character varying(255),
    automaticbreakin character(1),
    automaticbreakout character(1),
    attendance_block_id bigint NOT NULL,
    break_time_id bigint,
    user_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.attendance_break OWNER TO postgres;

--
-- Name: blackout_preference_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE blackout_preference_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blackout_preference_id_seq OWNER TO postgres;

--
-- Name: blackout_preference; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE blackout_preference (
    id bigint DEFAULT nextval('blackout_preference_id_seq'::regclass) NOT NULL,
    start_date date,
    location_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    max_requests integer
);


ALTER TABLE public.blackout_preference OWNER TO ressystems;

--
-- Name: blocked_daily_ip_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE blocked_daily_ip_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blocked_daily_ip_id_seq OWNER TO postgres;

--
-- Name: blocked_daily_ip; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE blocked_daily_ip (
    id bigint DEFAULT nextval('blocked_daily_ip_id_seq'::regclass) NOT NULL,
    ip character varying(255),
    date date,
    counter integer
);


ALTER TABLE public.blocked_daily_ip OWNER TO postgres;

--
-- Name: break_rule; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE break_rule (
    id integer NOT NULL,
    location_id bigint,
    name character varying(255),
    paid character(1),
    optional character(1),
    minutes_per_break_set bigint,
    length_in_minutes bigint,
    number_of_breaks bigint,
    position_id bigint,
    minor_id bigint,
    minimum_minutes bigint,
    maximum_minutes bigint,
    per_enum bigint,
    round_enum bigint,
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    deleted character(1),
    parent_id bigint,
    offset_type character varying(50) DEFAULT 'Not Overlapping'::character varying NOT NULL,
    offset_value integer
);


ALTER TABLE public.break_rule OWNER TO ressystems;

--
-- Name: break_rule_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE break_rule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.break_rule_id_seq OWNER TO ressystems;

--
-- Name: break_rule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ressystems
--

ALTER SEQUENCE break_rule_id_seq OWNED BY break_rule.id;


--
-- Name: break_time_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE break_time_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.break_time_id_seq OWNER TO postgres;

--
-- Name: break_time; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE break_time (
    id bigint DEFAULT nextval('break_time_id_seq'::regclass) NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    length_in_minutes integer,
    name character varying(255),
    paid character(1),
    optional character(1),
    timeblock_id bigint,
    location_id bigint NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    start_date date,
    end_date date,
    attendanceblock_id bigint,
    break_rule_id bigint
);


ALTER TABLE public.break_time OWNER TO ressystems;

--
-- Name: break_time_snap_shot_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE break_time_snap_shot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.break_time_snap_shot_id_seq OWNER TO postgres;

--
-- Name: break_time_snap_shot; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE break_time_snap_shot (
    id bigint DEFAULT nextval('break_time_snap_shot_id_seq'::regclass) NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    length_in_minutes integer,
    name character varying(255),
    paid character(1),
    optional character(1),
    timeblock_snap_shot_id bigint NOT NULL,
    location_id bigint NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    start_date date,
    end_date date
);


ALTER TABLE public.break_time_snap_shot OWNER TO ressystems;

--
-- Name: certification_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE certification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.certification_id_seq OWNER TO postgres;

--
-- Name: certification; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE certification (
    id bigint DEFAULT nextval('certification_id_seq'::regclass) NOT NULL,
    description character varying(255) NOT NULL,
    record_score character varying(255),
    record_type character varying(1) NOT NULL,
    required_to_be_scheduled character(1),
    corporation_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    type character varying(3) DEFAULT 'CER'::character varying,
    employee_visible character(1) DEFAULT 'N'::bpchar,
    identifier character varying(3),
    employee_upload character(1) DEFAULT 'N'::bpchar,
    employee_change character(1) DEFAULT 'N'::bpchar
);


ALTER TABLE public.certification OWNER TO ressystems;

--
-- Name: commision_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE commision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.commision_id_seq OWNER TO postgres;

--
-- Name: commision; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE commision (
    id bigint DEFAULT nextval('commision_id_seq'::regclass) NOT NULL,
    reseller_id bigint NOT NULL,
    plan_id integer,
    begin_number integer,
    end_number integer,
    base_value numeric(15,2),
    per_employee_value numeric(15,2),
    overall_value numeric(15,2),
    is_percentage character(1),
    is_volume character(1),
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.commision OWNER TO ressystems;

--
-- Name: corporation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE corporation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.corporation_id_seq OWNER TO postgres;

SET default_with_oids = true;

--
-- Name: corporation; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE corporation (
    id bigint DEFAULT nextval('corporation_id_seq'::regclass) NOT NULL,
    name character varying(255),
    address character varying(150),
    city character varying(50) NOT NULL,
    state character varying(100),
    country character varying(255),
    zip character varying(15) NOT NULL,
    datecreated timestamp without time zone NOT NULL,
    creator_id bigint,
    updated character(1),
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    phone_area_code character varying(3),
    phone_number character varying(15),
    fax_area_code character varying(3),
    fax_number character varying(15),
    payment_plan bigint,
    keyword character varying(255),
    landing_page character varying(255),
    paysimple_customer_number character varying(255),
    first_payment_date timestamp without time zone,
    price_id bigint,
    timezone double precision,
    active character(1) NOT NULL,
    rcvpostcard character(1),
    reseller_id bigint,
    finished_setup_wizard character(1) DEFAULT 'Y'::bpchar,
    paymentprofilenum character varying(255),
    payroll_start_date date,
    payroll_frequency character varying(5),
    default_sales_type bigint,
    billingcycle bigint DEFAULT 1,
    key character varying(255)
);


ALTER TABLE public.corporation OWNER TO ressystems;

SET default_with_oids = false;

--
-- Name: country; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE country (
    code character(2) NOT NULL,
    name character varying(80) NOT NULL,
    dialcode bigint NOT NULL
);


ALTER TABLE public.country OWNER TO ressystems;

--
-- Name: country_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE country_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.country_id_seq OWNER TO postgres;

--
-- Name: date_etl_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE date_etl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.date_etl_id_seq OWNER TO postgres;

--
-- Name: date_etl; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE date_etl (
    id bigint DEFAULT nextval('date_etl_id_seq'::regclass) NOT NULL,
    local_date timestamp without time zone NOT NULL,
    day_of_week integer NOT NULL,
    day_of_month integer NOT NULL,
    day_of_year integer NOT NULL,
    week_of_year integer NOT NULL,
    month_of_year integer NOT NULL,
    quarter_of_year integer NOT NULL,
    year integer NOT NULL,
    deleted character(1),
    parent_id bigint,
    starttimestamp timestamp without time zone DEFAULT now() NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.date_etl OWNER TO ressystems;

--
-- Name: department; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE department (
    id integer NOT NULL,
    name character varying(255),
    corporation_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone,
    department_parent_id bigint,
    available_for_scheduling character(1) DEFAULT 'Y'::bpchar,
    do_not_show_paf character(1),
    sales_type_id bigint
);


ALTER TABLE public.department OWNER TO ressystems;

--
-- Name: department_employee_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE department_employee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.department_employee_id_seq OWNER TO postgres;

--
-- Name: department_employee; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE department_employee (
    id bigint DEFAULT nextval('department_employee_id_seq'::regclass) NOT NULL,
    employee_id bigint,
    department_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.department_employee OWNER TO ressystems;

--
-- Name: department_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE department_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.department_id_seq OWNER TO ressystems;

--
-- Name: department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ressystems
--

ALTER SEQUENCE department_id_seq OWNED BY department.id;


--
-- Name: department_location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE department_location_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.department_location_id_seq OWNER TO postgres;

--
-- Name: department_location; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE department_location (
    id bigint DEFAULT nextval('department_location_id_seq'::regclass) NOT NULL,
    payroll_id character varying(255),
    department_id bigint,
    location_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    monday_open_time time without time zone,
    monday_close_time time without time zone,
    tuesday_open_time time without time zone,
    tuesday_close_time time without time zone,
    wednesday_open_time time without time zone,
    wednesday_close_time time without time zone,
    thursday_open_time time without time zone,
    thursday_close_time time without time zone,
    friday_open_time time without time zone,
    friday_close_time time without time zone,
    saturday_open_time time without time zone,
    saturday_close_time time without time zone,
    sunday_open_time time without time zone,
    sunday_close_time time without time zone,
    auto_clock_out time without time zone,
    auto_position_switching character(1) DEFAULT 'N'::bpchar,
    auto_employee_clock_in character(1) DEFAULT 'N'::bpchar,
    auto_employee_clock_out character(1) DEFAULT 'N'::bpchar,
    allow_early_clock_in character(1) DEFAULT 'Y'::bpchar,
    allow_late_clock_out character(1) DEFAULT 'Y'::bpchar,
    clock_in_advance character(1) DEFAULT 'N'::bpchar,
    clock_out_late character(1) DEFAULT 'N'::bpchar,
    early_clock_in_flex integer DEFAULT 0,
    late_clock_out_flex integer DEFAULT 0,
    pos_id character varying(255),
    can_import_actuals character(1) DEFAULT 'N'::bpchar,
    allocatedpercentage double precision
);


ALTER TABLE public.department_location OWNER TO ressystems;

--
-- Name: department_position_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE department_position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.department_position_id_seq OWNER TO postgres;

--
-- Name: department_position; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE department_position (
    id bigint DEFAULT nextval('department_position_id_seq'::regclass) NOT NULL,
    department_id bigint NOT NULL,
    position_code_id bigint NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.department_position OWNER TO ressystems;

--
-- Name: department_roll_up_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE department_roll_up_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.department_roll_up_id_seq OWNER TO postgres;

--
-- Name: department_roll_up; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE department_roll_up (
    id bigint DEFAULT nextval('department_roll_up_id_seq'::regclass) NOT NULL,
    department_id bigint NOT NULL,
    sales_department_id bigint NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.department_roll_up OWNER TO postgres;

--
-- Name: document_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE document_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.document_id_seq OWNER TO postgres;

--
-- Name: document; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE document (
    id bigint DEFAULT nextval('document_id_seq'::regclass) NOT NULL,
    path text,
    type character varying(255),
    size bigint,
    name character varying(255),
    external_id character varying(255),
    product_code character varying(255),
    uploaded_date timestamp without time zone,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    temp_doc character(1) DEFAULT 'N'::bpchar
);


ALTER TABLE public.document OWNER TO postgres;

--
-- Name: employee_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE employee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_id_seq OWNER TO postgres;

SET default_with_oids = true;

--
-- Name: employee; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE employee (
    id bigint DEFAULT nextval('employee_id_seq'::regclass) NOT NULL,
    min_hours numeric(15,2),
    max_hours numeric(15,2),
    min_pay integer,
    max_pay integer,
    datecreated timestamp without time zone NOT NULL,
    user_id bigint NOT NULL,
    notice_timeframe integer,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    hire_date timestamp without time zone,
    max_shifts bigint,
    min_shifts bigint,
    active_attendance_block bigint,
    termination_date date,
    internal_number character varying(100),
    current_location bigint,
    max_shifts_per_week integer,
    min_shifts_per_week integer,
    birth_date date,
    max_hours_per_day numeric(15,2),
    min_hours_per_day numeric(15,2),
    overtime character varying(255) DEFAULT ''::character varying,
    ssn text,
    ssn_suffix character varying(255),
    payroll_id character varying(255),
    home_location_id bigint,
    home_department_id bigint,
    internal_password character varying(255),
    small_pic_id bigint,
    medium_pic_id bigint,
    large_pic_id bigint,
    corporate_user character(1) DEFAULT 'N'::bpchar,
    finger1 bytea,
    finger2 bytea,
    finger3 bytea,
    finger4 bytea,
    zkpin character varying(10),
    copy_schedule character(1) DEFAULT 'N'::bpchar,
    admin_user character(1) DEFAULT 'N'::bpchar
);
ALTER TABLE ONLY employee ALTER COLUMN user_id SET STATISTICS 1000;


ALTER TABLE public.employee OWNER TO ressystems;

--
-- Name: employee_accrual_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE employee_accrual_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_accrual_id_seq OWNER TO postgres;

SET default_with_oids = false;

--
-- Name: employee_accrual; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE employee_accrual (
    id bigint DEFAULT nextval('employee_accrual_id_seq'::regclass) NOT NULL,
    begin_date timestamp without time zone,
    end_date timestamp without time zone,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    employee_id bigint,
    earned_hours numeric(15,4),
    used_hours numeric(15,4),
    total_hours numeric(15,4),
    pto_accrual_id bigint,
    location_id bigint
);


ALTER TABLE public.employee_accrual OWNER TO ressystems;

--
-- Name: employee_certification_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE employee_certification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_certification_id_seq OWNER TO postgres;

--
-- Name: employee_certification; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE employee_certification (
    id bigint DEFAULT nextval('employee_certification_id_seq'::regclass) NOT NULL,
    test_date date NOT NULL,
    expiration_date date,
    renewal_date date,
    score character varying(255),
    employee_id bigint,
    certification_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    memo character varying(255),
    document_id bigint
);


ALTER TABLE public.employee_certification OWNER TO ressystems;

--
-- Name: employee_position_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE employee_position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_position_id_seq OWNER TO postgres;

SET default_with_oids = true;

--
-- Name: employee_position; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE employee_position (
    id bigint DEFAULT nextval('employee_position_id_seq'::regclass) NOT NULL,
    employee_id bigint NOT NULL,
    position_id bigint NOT NULL,
    payrate numeric(15,2),
    payscale integer,
    same_position_payment character(1),
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    skill_level integer,
    hourlyrate numeric(15,2),
    do_not_export character(1) DEFAULT 'N'::bpchar,
    fixed_rate_export numeric(15,2),
    fixed_hours_export numeric(15,2)
);


ALTER TABLE public.employee_position OWNER TO ressystems;

--
-- Name: employee_preference_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE employee_preference_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_preference_type_id_seq OWNER TO postgres;

SET default_with_oids = false;

--
-- Name: employee_preference_type; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE employee_preference_type (
    id bigint DEFAULT nextval('employee_preference_type_id_seq'::regclass) NOT NULL,
    employee_id bigint,
    preference_type_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.employee_preference_type OWNER TO ressystems;

--
-- Name: employee_sensoralert_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE employee_sensoralert_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_sensoralert_id_seq OWNER TO postgres;

--
-- Name: employee_sensoralert; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE employee_sensoralert (
    id bigint DEFAULT nextval('employee_sensoralert_id_seq'::regclass) NOT NULL,
    employee_id bigint,
    sensor_id bigint,
    severity bigint,
    sms character(1),
    email character(1)
);


ALTER TABLE public.employee_sensoralert OWNER TO ressystems;

--
-- Name: employee_setting_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE employee_setting_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_setting_id_seq OWNER TO postgres;

--
-- Name: employee_setting; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE employee_setting (
    id bigint DEFAULT nextval('employee_setting_id_seq'::regclass) NOT NULL,
    employee_id bigint NOT NULL,
    flag_id bigint NOT NULL,
    value text NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.employee_setting OWNER TO ressystems;

--
-- Name: event_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.event_id_seq OWNER TO postgres;

--
-- Name: event; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE event (
    id bigint DEFAULT nextval('event_id_seq'::regclass) NOT NULL,
    name character varying(100) NOT NULL,
    note text,
    start_date date NOT NULL,
    end_date date,
    start_time time without time zone,
    end_time time without time zone,
    duration integer,
    size integer,
    externallink character varying(300),
    active character(1),
    location_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.event OWNER TO postgres;

--
-- Name: event_certification; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE event_certification (
    id bigint NOT NULL,
    event_id bigint NOT NULL,
    certification_id bigint NOT NULL,
    date_created timestamp without time zone NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.event_certification OWNER TO postgres;

--
-- Name: event_department; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE event_department (
    id bigint NOT NULL,
    event_id bigint NOT NULL,
    department_id bigint NOT NULL,
    date_created timestamp without time zone NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.event_department OWNER TO postgres;

--
-- Name: eventcertification_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE eventcertification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.eventcertification_id_seq OWNER TO postgres;

--
-- Name: eventdepartment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE eventdepartment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.eventdepartment_id_seq OWNER TO postgres;

--
-- Name: fingerprint; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE fingerprint (
    personid bigint DEFAULT (0)::bigint NOT NULL,
    fingerprintid bigint DEFAULT (0)::bigint NOT NULL,
    fingertype bigint,
    resolution bigint DEFAULT (0)::bigint NOT NULL,
    fingerfeature bytea
);


ALTER TABLE public.fingerprint OWNER TO ressystems;

--
-- Name: fingerprint_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE fingerprint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fingerprint_id_seq OWNER TO postgres;

--
-- Name: flag_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE flag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.flag_id_seq OWNER TO postgres;

SET default_with_oids = true;

--
-- Name: flag; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE flag (
    id bigint DEFAULT nextval('flag_id_seq'::regclass) NOT NULL,
    description character varying(255) NOT NULL,
    key character varying(255),
    default_value character varying(255)
);


ALTER TABLE public.flag OWNER TO ressystems;

--
-- Name: forecast_timeblock_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE forecast_timeblock_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.forecast_timeblock_id_seq OWNER TO postgres;

SET default_with_oids = false;

--
-- Name: forecast_timeblock; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE forecast_timeblock (
    id bigint DEFAULT nextval('forecast_timeblock_id_seq'::regclass) NOT NULL,
    start_date date NOT NULL,
    end_date date,
    start_time time without time zone,
    end_time time without time zone,
    position_id bigint NOT NULL,
    employee_id bigint,
    department_id bigint,
    location_id bigint NOT NULL
);


ALTER TABLE public.forecast_timeblock OWNER TO ressystems;

--
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hibernate_sequence OWNER TO ressystems;

--
-- Name: hierarchy; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE hierarchy (
    id integer NOT NULL,
    description character varying(255),
    corporation_id bigint,
    parent_hierarchy_id bigint,
    responsible_user_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.hierarchy OWNER TO ressystems;

--
-- Name: hierarchy_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE hierarchy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hierarchy_id_seq OWNER TO ressystems;

--
-- Name: hierarchy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ressystems
--

ALTER SEQUENCE hierarchy_id_seq OWNED BY hierarchy.id;


--
-- Name: invoice_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE invoice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.invoice_id_seq OWNER TO postgres;

--
-- Name: invoice; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE invoice (
    id bigint DEFAULT nextval('invoice_id_seq'::regclass) NOT NULL,
    corporation_id bigint,
    date timestamp without time zone,
    invoice_total double precision,
    per_employee_rate double precision,
    base_rate double precision,
    per_location_rate double precision,
    message_text_sent text,
    paid character(1),
    paid_date timestamp without time zone,
    pay_message text,
    amt_paid double precision
);


ALTER TABLE public.invoice OWNER TO ressystems;

--
-- Name: location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE location_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.location_id_seq OWNER TO postgres;

SET default_with_oids = true;

--
-- Name: location; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE location (
    id bigint DEFAULT nextval('location_id_seq'::regclass) NOT NULL,
    name character varying(255),
    address character varying(150),
    city character varying(50) NOT NULL,
    state character varying(100),
    country character varying(255),
    zip character varying(15) NOT NULL,
    datecreated timestamp without time zone NOT NULL,
    corporation_id bigint,
    creator_id bigint NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    phone_area_code character varying(3),
    phone_number character varying(15),
    fax_number character varying(15),
    fax_area_code character varying(3),
    timezone double precision,
    monday_open_time time without time zone,
    monday_close_time time without time zone,
    tuesday_open_time time without time zone,
    tuesday_close_time time without time zone,
    wednesday_open_time time without time zone,
    wednesday_close_time time without time zone,
    thursday_open_time time without time zone,
    thursday_close_time time without time zone,
    friday_open_time time without time zone,
    friday_close_time time without time zone,
    saturday_open_time time without time zone,
    saturday_close_time time without time zone,
    sunday_open_time time without time zone,
    sunday_close_time time without time zone,
    number_of_schedules bigint,
    dst character(1) DEFAULT 'N'::bpchar,
    last_forecast_datetime timestamp without time zone DEFAULT now(),
    last_schedule_forecast_datetime timestamp without time zone DEFAULT now(),
    discount double precision,
    syncing_emp_or_att timestamp without time zone,
    key character varying(255)
);


ALTER TABLE public.location OWNER TO ressystems;

--
-- Name: location_flag_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE location_flag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.location_flag_id_seq OWNER TO postgres;

--
-- Name: location_flag; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE location_flag (
    id bigint DEFAULT nextval('location_flag_id_seq'::regclass) NOT NULL,
    location_id bigint NOT NULL,
    flag_id bigint NOT NULL,
    value text NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.location_flag OWNER TO ressystems;

SET default_with_oids = false;

--
-- Name: location_hierarchy; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE location_hierarchy (
    id integer NOT NULL,
    location_id bigint NOT NULL,
    hierarchy_id bigint NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.location_hierarchy OWNER TO ressystems;

--
-- Name: location_hierarchy_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE location_hierarchy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.location_hierarchy_id_seq OWNER TO ressystems;

--
-- Name: location_hierarchy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ressystems
--

ALTER SEQUENCE location_hierarchy_id_seq OWNED BY location_hierarchy.id;


--
-- Name: logtag_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE logtag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.logtag_id_seq OWNER TO postgres;

--
-- Name: logtag; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE logtag (
    id bigint DEFAULT nextval('logtag_id_seq'::regclass) NOT NULL,
    description character varying(255) NOT NULL,
    corporation_id bigint,
    logtype integer
);


ALTER TABLE public.logtag OWNER TO postgres;

--
-- Name: manager_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE manager_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.manager_log_id_seq OWNER TO postgres;

--
-- Name: manager_log; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE manager_log (
    id bigint DEFAULT nextval('manager_log_id_seq'::regclass) NOT NULL,
    note text,
    date_created timestamp without time zone NOT NULL,
    log_date date NOT NULL,
    log_time time without time zone,
    manager_log_category_id bigint,
    creator_id bigint,
    location_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone,
    numericvalue double precision,
    note_deleted character(1) DEFAULT 'N'::bpchar,
    document_id bigint,
    employee_id bigint,
    important character(1) DEFAULT 'N'::bpchar
);


ALTER TABLE public.manager_log OWNER TO ressystems;

--
-- Name: manager_log_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE manager_log_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.manager_log_category_id_seq OWNER TO postgres;

--
-- Name: manager_log_category; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE manager_log_category (
    id bigint DEFAULT nextval('manager_log_category_id_seq'::regclass) NOT NULL,
    description character varying(255) NOT NULL,
    defaultcategoryid bigint,
    corporation_id bigint,
    parent_manager_log_category_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone,
    logtype integer NOT NULL,
    tfmanaged integer
);


ALTER TABLE public.manager_log_category OWNER TO ressystems;

--
-- Name: managerlog_comment; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE managerlog_comment (
    id bigint NOT NULL,
    comment text,
    datetime timestamp without time zone NOT NULL,
    managerlog_id bigint NOT NULL,
    creator_id bigint NOT NULL,
    note_deleted character(1) DEFAULT 'N'::bpchar,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.managerlog_comment OWNER TO ressystems;

--
-- Name: managerlog_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE managerlog_comment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.managerlog_comment_id_seq OWNER TO ressystems;

--
-- Name: managerlog_logtag_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE managerlog_logtag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.managerlog_logtag_id_seq OWNER TO postgres;

--
-- Name: managerlog_logtag; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE managerlog_logtag (
    id bigint DEFAULT nextval('managerlog_logtag_id_seq'::regclass) NOT NULL,
    managerlog_id bigint,
    logtag_id bigint
);


ALTER TABLE public.managerlog_logtag OWNER TO postgres;

--
-- Name: message_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE message_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.message_log_id_seq OWNER TO postgres;

SET default_with_oids = true;

--
-- Name: message_log; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE message_log (
    id bigint DEFAULT nextval('message_log_id_seq'::regclass) NOT NULL,
    timeblock_id bigint,
    employee_id bigint,
    sent_time time without time zone,
    sent_date date,
    type integer,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    location_id bigint
);


ALTER TABLE public.message_log OWNER TO ressystems;

SET default_with_oids = false;

--
-- Name: minor; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE minor (
    id integer NOT NULL,
    min_hours_per_week bigint,
    max_hours_per_week bigint,
    min_shifts_per_week bigint,
    max_shifts_per_week bigint,
    min_shifts_per_day bigint,
    max_shifts_per_day bigint,
    min_age bigint,
    max_age bigint,
    location_id bigint,
    parent_id bigint,
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone,
    deleted character(1)
);


ALTER TABLE public.minor OWNER TO ressystems;

--
-- Name: minor_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE minor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.minor_id_seq OWNER TO ressystems;

--
-- Name: minor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ressystems
--

ALTER SEQUENCE minor_id_seq OWNED BY minor.id;


--
-- Name: minor_preference; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE minor_preference (
    id integer NOT NULL,
    minor_id bigint,
    preference_id bigint,
    parent_id bigint,
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone,
    deleted character(1)
);


ALTER TABLE public.minor_preference OWNER TO ressystems;

--
-- Name: minor_preference_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE minor_preference_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.minor_preference_id_seq OWNER TO ressystems;

--
-- Name: minor_preference_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ressystems
--

ALTER SEQUENCE minor_preference_id_seq OWNED BY minor_preference.id;


--
-- Name: multi_level_pay_rate_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE multi_level_pay_rate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.multi_level_pay_rate_id_seq OWNER TO postgres;

--
-- Name: multi_level_pay_rate; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE multi_level_pay_rate (
    id bigint DEFAULT nextval('multi_level_pay_rate_id_seq'::regclass) NOT NULL,
    starttime time without time zone NOT NULL,
    endtime time without time zone NOT NULL,
    hourlyrate numeric(15,2) NOT NULL,
    position_id bigint,
    location_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.multi_level_pay_rate OWNER TO ressystems;

--
-- Name: oompa_attendance2_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE oompa_attendance2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oompa_attendance2_id_seq OWNER TO postgres;

--
-- Name: oompa_attendance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE oompa_attendance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oompa_attendance_id_seq OWNER TO postgres;

--
-- Name: payment_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE payment_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.payment_log_id_seq OWNER TO postgres;

--
-- Name: payment_log; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE payment_log (
    id bigint DEFAULT nextval('payment_log_id_seq'::regclass) NOT NULL,
    corporation_id bigint,
    changed_date date,
    changed_time time without time zone,
    message character varying(255),
    finished character(1),
    paysimple_customer_number character varying(255),
    payment double precision,
    parent_id bigint,
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone,
    deleted character(1),
    credit_card_type character varying(255),
    credit_card_name character varying(255),
    credit_card_zip character varying(255),
    credit_card_address character varying(255),
    credit_card_number character varying(255),
    first_payment_date date
);


ALTER TABLE public.payment_log OWNER TO ressystems;

--
-- Name: person; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE person (
    personid bigint DEFAULT (0)::bigint NOT NULL,
    registrationno character varying(100),
    typeid bigint,
    registereddate timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    status bigint
);


ALTER TABLE public.person OWNER TO ressystems;

--
-- Name: person_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.person_id_seq OWNER TO postgres;

--
-- Name: pglink_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pglink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pglink_id_seq OWNER TO postgres;

SET default_with_oids = true;

--
-- Name: pglink; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE pglink (
    id bigint DEFAULT nextval('pglink_id_seq'::regclass) NOT NULL,
    positiongroup_id bigint NOT NULL,
    position_id bigint NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.pglink OWNER TO ressystems;

--
-- Name: position_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.position_id_seq OWNER TO postgres;

--
-- Name: position; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE "position" (
    id bigint DEFAULT nextval('position_id_seq'::regclass) NOT NULL,
    payrate numeric(15,2) NOT NULL,
    payscale integer NOT NULL,
    fluid character(1),
    location_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    position_code_id bigint,
    color character varying(10),
    overtime character varying(255) DEFAULT ''::character varying,
    hourlyrate numeric(15,2),
    payroll_id character varying(255),
    alias character varying(255) DEFAULT ''::character varying,
    posted character(1) DEFAULT 'N'::bpchar,
    questionnarie_id bigint
);


ALTER TABLE public."position" OWNER TO ressystems;

--
-- Name: position_certification_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE position_certification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.position_certification_id_seq OWNER TO postgres;

SET default_with_oids = false;

--
-- Name: position_certification; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE position_certification (
    id bigint DEFAULT nextval('position_certification_id_seq'::regclass) NOT NULL,
    position_code_id bigint NOT NULL,
    certification_id bigint NOT NULL,
    required_to_be_scheduled character(1),
    required_to_clock_in character(1),
    renewal_period_in_days integer,
    expiration_period_in_days integer,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    document_id bigint
);


ALTER TABLE public.position_certification OWNER TO postgres;

--
-- Name: position_code_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE position_code_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.position_code_id_seq OWNER TO postgres;

--
-- Name: position_code; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE position_code (
    id bigint DEFAULT nextval('position_code_id_seq'::regclass) NOT NULL,
    description character varying(255),
    corporation_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone,
    sales_type_id bigint
);


ALTER TABLE public.position_code OWNER TO ressystems;

--
-- Name: position_filter_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE position_filter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.position_filter_id_seq OWNER TO postgres;

--
-- Name: position_filter; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE position_filter (
    id bigint DEFAULT nextval('position_filter_id_seq'::regclass) NOT NULL,
    name character varying(255) NOT NULL,
    selected_values text,
    corporation_id bigint,
    department_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.position_filter OWNER TO postgres;

--
-- Name: position_tracking_step_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE position_tracking_step_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.position_tracking_step_id_seq OWNER TO postgres;

--
-- Name: position_tracking_step; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE position_tracking_step (
    id bigint DEFAULT nextval('position_tracking_step_id_seq'::regclass) NOT NULL,
    position_id bigint NOT NULL,
    step integer,
    step_description character varying(255),
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.position_tracking_step OWNER TO postgres;

--
-- Name: positiongroup_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE positiongroup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.positiongroup_id_seq OWNER TO postgres;

SET default_with_oids = true;

--
-- Name: positiongroup; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE positiongroup (
    id bigint DEFAULT nextval('positiongroup_id_seq'::regclass) NOT NULL,
    name character varying(255) NOT NULL,
    location_id bigint NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.positiongroup OWNER TO ressystems;

--
-- Name: preference_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE preference_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.preference_id_seq OWNER TO postgres;

--
-- Name: preference; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE preference (
    id bigint DEFAULT nextval('preference_id_seq'::regclass) NOT NULL,
    memo character varying(255),
    starttime time without time zone,
    endtime time without time zone,
    startdate timestamp without time zone,
    enddate timestamp without time zone,
    recursion integer,
    weight integer,
    preference integer,
    employee_id bigint,
    position_id bigint,
    creator_id bigint NOT NULL,
    location_id bigint,
    monthly_repeat_by integer,
    monthly integer,
    monthly_week integer,
    monday character(1),
    tuesday character(1),
    wednesday character(1),
    thursday character(1),
    friday character(1),
    saturday character(1),
    sunday character(1),
    timeblock_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    date_created timestamp without time zone,
    approval_status character varying(255),
    frequency bigint,
    managers_comment text,
    preference_type_description text,
    paid character varying(1),
    preference_type_id bigint,
    hours_allocated numeric(15,2),
    last_etl_datetime timestamp without time zone DEFAULT now()
);
ALTER TABLE ONLY preference ALTER COLUMN location_id SET STATISTICS 1000;


ALTER TABLE public.preference OWNER TO ressystems;

--
-- Name: preference_conflict_etl_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE preference_conflict_etl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.preference_conflict_etl_id_seq OWNER TO postgres;

SET default_with_oids = false;

--
-- Name: preference_conflict_etl; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE preference_conflict_etl (
    id bigint DEFAULT nextval('preference_conflict_etl_id_seq'::regclass) NOT NULL,
    preference_id bigint,
    conflict_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    parent_id bigint
);


ALTER TABLE public.preference_conflict_etl OWNER TO ressystems;

--
-- Name: preference_date_etl_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE preference_date_etl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.preference_date_etl_id_seq OWNER TO postgres;

--
-- Name: preference_date_etl; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE preference_date_etl (
    preference_id bigint,
    date_etl_id bigint,
    id bigint DEFAULT nextval('preference_date_etl_id_seq'::regclass) NOT NULL,
    deleted character(1),
    parent_id bigint,
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    corporation_id bigint
);


ALTER TABLE public.preference_date_etl OWNER TO ressystems;

--
-- Name: preference_type; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE preference_type (
    id integer NOT NULL,
    description character varying(255),
    corporation_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    is_pto_accrual character(1) DEFAULT 'N'::bpchar
);


ALTER TABLE public.preference_type OWNER TO ressystems;

--
-- Name: preference_type_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE preference_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.preference_type_id_seq OWNER TO ressystems;

--
-- Name: preference_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ressystems
--

ALTER SEQUENCE preference_type_id_seq OWNED BY preference_type.id;


--
-- Name: preference_type_location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE preference_type_location_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.preference_type_location_id_seq OWNER TO postgres;

--
-- Name: preference_type_location; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE preference_type_location (
    id bigint DEFAULT nextval('preference_type_location_id_seq'::regclass) NOT NULL,
    payroll_id character varying(255),
    preference_type_id bigint,
    location_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.preference_type_location OWNER TO postgres;

--
-- Name: price_object_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE price_object_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.price_object_id_seq OWNER TO postgres;

--
-- Name: price_object; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE price_object (
    id bigint DEFAULT nextval('price_object_id_seq'::regclass) NOT NULL,
    per_employee_price double precision,
    per_location_price double precision,
    price_type bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone,
    free_trial_schedules bigint,
    free_trial_end_date timestamp without time zone,
    max_employees bigint,
    multiple_locations character(1),
    autoscheduler character(1),
    reports text,
    email_messages character(1),
    sms_messages character(1),
    messaging character(1),
    manager_log character(1),
    shift_swaps character(1),
    departments character(1),
    age_rules character(1),
    break_rules character(1),
    preference_types character(1),
    templates character(1),
    attendance character(1),
    payroll_export character(1),
    biometrics character(1),
    integration character(1),
    scheduling character(1) DEFAULT 'Y'::bpchar,
    preferences character(1) DEFAULT 'Y'::bpchar,
    positions character(1) DEFAULT 'Y'::bpchar,
    upgrade_paths character varying(255) DEFAULT '7,8,9,10'::character varying,
    features_sort_order text DEFAULT 'autoscheduler,emailMessages,smsMessages,messaging,shiftSwaps,templates,departments,attendanceTracking,biometrics,payrollExport,integration,managerLog'::text,
    constant_price double precision DEFAULT 0.0,
    sales_paf character(1),
    sales_paf_analysis character(1),
    certifications character(1),
    temperature character(1),
    schedule_forecasting character(1),
    pto character(1) DEFAULT 'N'::bpchar,
    non_payment_notices character(1) DEFAULT 'N'::bpchar,
    shift_ranking character(1) DEFAULT 'N'::bpchar,
    cancelled character(1),
    document_max_size_in_mb double precision,
    applicant_tracking character(1) DEFAULT 'N'::bpchar,
    dashboard character(1) DEFAULT 'N'::bpchar,
    bycheck character(1) DEFAULT 'N'::bpchar,
    badcredit integer,
    event_tracking character(1) DEFAULT 'N'::bpchar
);


ALTER TABLE public.price_object OWNER TO ressystems;

--
-- Name: pto_accrual_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pto_accrual_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pto_accrual_id_seq OWNER TO postgres;

--
-- Name: pto_accrual; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE pto_accrual (
    id bigint DEFAULT nextval('pto_accrual_id_seq'::regclass) NOT NULL,
    period integer NOT NULL,
    hours_accrued numeric(15,4),
    max_hours_accrued numeric(15,4),
    reset_every_year character(1),
    begin_month integer,
    begin_day integer,
    begin_accruing timestamp without time zone,
    preference_type_id bigint,
    position_code_id bigint,
    employee_id bigint,
    corporation_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.pto_accrual OWNER TO ressystems;

--
-- Name: qrtz_blob_triggers; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE qrtz_blob_triggers (
    trigger_name character varying(80) NOT NULL,
    trigger_group character varying(80) NOT NULL,
    blob_data bytea
);


ALTER TABLE public.qrtz_blob_triggers OWNER TO ressystems;

--
-- Name: qrtz_blob_triggers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE qrtz_blob_triggers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qrtz_blob_triggers_id_seq OWNER TO postgres;

--
-- Name: qrtz_calendars; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE qrtz_calendars (
    calendar_name character varying(80) NOT NULL,
    calendar bytea NOT NULL
);


ALTER TABLE public.qrtz_calendars OWNER TO ressystems;

--
-- Name: qrtz_calendars_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE qrtz_calendars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qrtz_calendars_id_seq OWNER TO postgres;

--
-- Name: qrtz_cron_triggers; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE qrtz_cron_triggers (
    trigger_name character varying(80) NOT NULL,
    trigger_group character varying(80) NOT NULL,
    cron_expression character varying(80) NOT NULL,
    time_zone_id character varying(80)
);


ALTER TABLE public.qrtz_cron_triggers OWNER TO ressystems;

--
-- Name: qrtz_cron_triggers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE qrtz_cron_triggers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qrtz_cron_triggers_id_seq OWNER TO postgres;

--
-- Name: qrtz_fired_triggers; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE qrtz_fired_triggers (
    entry_id character varying(95) NOT NULL,
    trigger_name character varying(80) NOT NULL,
    trigger_group character varying(80) NOT NULL,
    is_volatile boolean NOT NULL,
    instance_name character varying(80) NOT NULL,
    fired_time bigint NOT NULL,
    priority integer NOT NULL,
    state character varying(16) NOT NULL,
    job_name character varying(80),
    job_group character varying(80),
    is_stateful boolean,
    requests_recovery boolean
);


ALTER TABLE public.qrtz_fired_triggers OWNER TO ressystems;

--
-- Name: qrtz_fired_triggers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE qrtz_fired_triggers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qrtz_fired_triggers_id_seq OWNER TO postgres;

--
-- Name: qrtz_job_details; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE qrtz_job_details (
    job_name character varying(80) NOT NULL,
    job_group character varying(80) NOT NULL,
    description character varying(120),
    job_class_name character varying(128) NOT NULL,
    is_durable boolean NOT NULL,
    is_volatile boolean NOT NULL,
    is_stateful boolean NOT NULL,
    requests_recovery boolean NOT NULL,
    job_data bytea
);


ALTER TABLE public.qrtz_job_details OWNER TO ressystems;

--
-- Name: qrtz_job_details_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE qrtz_job_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qrtz_job_details_id_seq OWNER TO postgres;

--
-- Name: qrtz_job_listeners; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE qrtz_job_listeners (
    job_name character varying(80) NOT NULL,
    job_group character varying(80) NOT NULL,
    job_listener character varying(80) NOT NULL
);


ALTER TABLE public.qrtz_job_listeners OWNER TO ressystems;

--
-- Name: qrtz_job_listeners_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE qrtz_job_listeners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qrtz_job_listeners_id_seq OWNER TO postgres;

--
-- Name: qrtz_locks; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE qrtz_locks (
    lock_name character varying(40) NOT NULL
);


ALTER TABLE public.qrtz_locks OWNER TO ressystems;

--
-- Name: qrtz_locks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE qrtz_locks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qrtz_locks_id_seq OWNER TO postgres;

--
-- Name: qrtz_paused_trigger_grps; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE qrtz_paused_trigger_grps (
    trigger_group character varying(80) NOT NULL
);


ALTER TABLE public.qrtz_paused_trigger_grps OWNER TO ressystems;

--
-- Name: qrtz_paused_trigger_grps_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE qrtz_paused_trigger_grps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qrtz_paused_trigger_grps_id_seq OWNER TO postgres;

--
-- Name: qrtz_scheduler_state; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE qrtz_scheduler_state (
    instance_name character varying(80) NOT NULL,
    last_checkin_time bigint NOT NULL,
    checkin_interval bigint NOT NULL
);


ALTER TABLE public.qrtz_scheduler_state OWNER TO ressystems;

--
-- Name: qrtz_scheduler_state_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE qrtz_scheduler_state_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qrtz_scheduler_state_id_seq OWNER TO postgres;

--
-- Name: qrtz_simple_triggers; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE qrtz_simple_triggers (
    trigger_name character varying(80) NOT NULL,
    trigger_group character varying(80) NOT NULL,
    repeat_count bigint NOT NULL,
    repeat_interval bigint NOT NULL,
    times_triggered bigint NOT NULL
);


ALTER TABLE public.qrtz_simple_triggers OWNER TO ressystems;

--
-- Name: qrtz_simple_triggers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE qrtz_simple_triggers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qrtz_simple_triggers_id_seq OWNER TO postgres;

--
-- Name: qrtz_trigger_listeners; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE qrtz_trigger_listeners (
    trigger_name character varying(80) NOT NULL,
    trigger_group character varying(80) NOT NULL,
    trigger_listener character varying(80) NOT NULL
);


ALTER TABLE public.qrtz_trigger_listeners OWNER TO ressystems;

--
-- Name: qrtz_trigger_listeners_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE qrtz_trigger_listeners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qrtz_trigger_listeners_id_seq OWNER TO postgres;

--
-- Name: qrtz_triggers; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE qrtz_triggers (
    trigger_name character varying(80) NOT NULL,
    trigger_group character varying(80) NOT NULL,
    job_name character varying(80) NOT NULL,
    job_group character varying(80) NOT NULL,
    is_volatile boolean NOT NULL,
    description character varying(120),
    next_fire_time bigint,
    prev_fire_time bigint,
    priority integer,
    trigger_state character varying(16) NOT NULL,
    trigger_type character varying(8) NOT NULL,
    start_time bigint NOT NULL,
    end_time bigint,
    calendar_name character varying(80),
    misfire_instr smallint,
    job_data bytea
);


ALTER TABLE public.qrtz_triggers OWNER TO ressystems;

--
-- Name: qrtz_triggers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE qrtz_triggers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qrtz_triggers_id_seq OWNER TO postgres;

--
-- Name: questionnarie_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE questionnarie_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.questionnarie_id_seq OWNER TO ressystems;

--
-- Name: questionnarie; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE questionnarie (
    id bigint DEFAULT nextval('questionnarie_id_seq'::regclass) NOT NULL,
    name character varying(255),
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.questionnarie OWNER TO ressystems;

--
-- Name: questionnarie_answer_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE questionnarie_answer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.questionnarie_answer_id_seq OWNER TO ressystems;

--
-- Name: questionnarie_answer; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE questionnarie_answer (
    id bigint DEFAULT nextval('questionnarie_answer_id_seq'::regclass) NOT NULL,
    applicant_id bigint NOT NULL,
    questionnarie_question_id bigint NOT NULL,
    answer character varying(255),
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.questionnarie_answer OWNER TO ressystems;

--
-- Name: questionnarie_question_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE questionnarie_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.questionnarie_question_id_seq OWNER TO ressystems;

--
-- Name: questionnarie_question; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE questionnarie_question (
    id bigint DEFAULT nextval('questionnarie_question_id_seq'::regclass) NOT NULL,
    questionnarie_id bigint NOT NULL,
    question character varying(255),
    required character(1),
    type character varying(255),
    orderr integer,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.questionnarie_question OWNER TO ressystems;

--
-- Name: questionnarie_question_options_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE questionnarie_question_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.questionnarie_question_options_id_seq OWNER TO ressystems;

--
-- Name: questionnarie_question_options; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE questionnarie_question_options (
    id bigint DEFAULT nextval('questionnarie_question_options_id_seq'::regclass) NOT NULL,
    questionnarie_question_id bigint NOT NULL,
    option character varying(255),
    orderr integer,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.questionnarie_question_options OWNER TO ressystems;

--
-- Name: referral_log; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE referral_log (
    id integer NOT NULL,
    sender_id bigint,
    sent_time time without time zone,
    sent_date date,
    sent_to_email_address character varying(255),
    deleted character(1),
    parent_id bigint,
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.referral_log OWNER TO ressystems;

--
-- Name: referral_log_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE referral_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.referral_log_id_seq OWNER TO ressystems;

--
-- Name: referral_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ressystems
--

ALTER SEQUENCE referral_log_id_seq OWNED BY referral_log.id;


--
-- Name: replacement; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE replacement (
    id integer NOT NULL,
    reason character varying(255),
    employee_assigned bigint,
    replacement bigint,
    schedule_id bigint,
    date_created timestamp without time zone,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    start_time time without time zone,
    end_time time without time zone,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.replacement OWNER TO ressystems;

--
-- Name: replacement_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE replacement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.replacement_id_seq OWNER TO ressystems;

--
-- Name: replacement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ressystems
--

ALTER SEQUENCE replacement_id_seq OWNED BY replacement.id;


--
-- Name: report_schedule; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE report_schedule (
    id bigint NOT NULL,
    rep_time time without time zone NOT NULL,
    rep_frequency character varying(50) NOT NULL,
    rep_daterange character varying(100) NOT NULL,
    rep_days character varying(100),
    rep_options character varying(300),
    rep_id integer,
    location_id bigint,
    corporation_id bigint,
    user_id bigint NOT NULL,
    date_created timestamp without time zone NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    recipients character varying(300)
);


ALTER TABLE public.report_schedule OWNER TO postgres;

--
-- Name: report_schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE report_schedule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.report_schedule_id_seq OWNER TO postgres;

--
-- Name: reseller_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE reseller_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reseller_id_seq OWNER TO postgres;

--
-- Name: reseller; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE reseller (
    id bigint DEFAULT nextval('reseller_id_seq'::regclass) NOT NULL,
    user_id bigint NOT NULL,
    reseller_code character varying(255) NOT NULL,
    can_switch_user character(1),
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    discount_percentage numeric(15,2),
    trial_length integer,
    master_reseller_id bigint,
    volumeofclients_or_gross character varying(1) DEFAULT 'V'::character varying,
    percentage_or_flagrate character varying(1) DEFAULT 'P'::character varying,
    support_phone_number character varying(255),
    support_email character varying(255),
    logo_path character varying(255),
    do_not_bill_customers character(1) DEFAULT 'N'::bpchar
);


ALTER TABLE public.reseller OWNER TO ressystems;

--
-- Name: role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.role_id_seq OWNER TO postgres;

SET default_with_oids = true;

--
-- Name: role; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE role (
    id bigint DEFAULT nextval('role_id_seq'::regclass) NOT NULL,
    name character varying(100),
    description character varying(100)
);


ALTER TABLE public.role OWNER TO ressystems;

SET default_with_oids = false;

--
-- Name: roles_ant; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE roles_ant (
    user_id bigint,
    role_id bigint
);


ALTER TABLE public.roles_ant OWNER TO postgres;

--
-- Name: sales_dep_threshold; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sales_dep_threshold (
    id bigint NOT NULL,
    desired_ratio double precision,
    start_date date,
    end_date date,
    dep_loc_id bigint,
    sales_type_loc_id bigint,
    location_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    position_id bigint,
    minvalue integer,
    maxvalue integer
);


ALTER TABLE public.sales_dep_threshold OWNER TO postgres;

--
-- Name: sales_dep_threshold_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sales_dep_threshold_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sales_dep_threshold_id_seq OWNER TO postgres;

--
-- Name: sales_paf_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sales_paf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sales_paf_id_seq OWNER TO postgres;

--
-- Name: sales_paf; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE sales_paf (
    id bigint DEFAULT nextval('sales_paf_id_seq'::regclass) NOT NULL,
    date date NOT NULL,
    belongs_to date NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    value double precision,
    type character varying(1),
    sales_type_id bigint,
    who_id bigint,
    location_id bigint NOT NULL,
    department_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    count integer,
    parent_id bigint,
    modified_by_ws character(1)
);


ALTER TABLE public.sales_paf OWNER TO ressystems;

--
-- Name: sales_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sales_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sales_type_id_seq OWNER TO postgres;

--
-- Name: sales_type; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE sales_type (
    id bigint DEFAULT nextval('sales_type_id_seq'::regclass) NOT NULL,
    description character varying(255) NOT NULL,
    type character varying(1) NOT NULL,
    level character varying(1) NOT NULL,
    comparison_to character varying(1),
    desired_ratio double precision,
    corporation_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.sales_type OWNER TO ressystems;

--
-- Name: sales_type_location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sales_type_location_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sales_type_location_id_seq OWNER TO postgres;

--
-- Name: sales_type_location; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE sales_type_location (
    id bigint DEFAULT nextval('sales_type_location_id_seq'::regclass) NOT NULL,
    comparison_to character varying(1),
    desired_ratio double precision,
    sales_type_id bigint,
    location_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    directcomparison character(1) DEFAULT 'N'::bpchar,
    showsalesvalue character varying(1),
    calculationtype integer
);


ALTER TABLE public.sales_type_location OWNER TO ressystems;

--
-- Name: schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE schedule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.schedule_id_seq OWNER TO postgres;

SET default_with_oids = true;

--
-- Name: schedule; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE schedule (
    id bigint DEFAULT nextval('schedule_id_seq'::regclass) NOT NULL,
    description character varying(255) NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    location_id bigint NOT NULL,
    published character(1),
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    department_id bigint,
    sales_type_id bigint,
    sales_type2_id bigint,
    sales_type3_id bigint,
    sales_type4_id bigint,
    sales_type5_id bigint
);


ALTER TABLE public.schedule OWNER TO ressystems;

--
-- Name: schedule_message_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE schedule_message_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.schedule_message_id_seq OWNER TO postgres;

SET default_with_oids = false;

--
-- Name: schedule_message; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE schedule_message (
    id bigint DEFAULT nextval('schedule_message_id_seq'::regclass) NOT NULL,
    note text,
    date_created timestamp without time zone NOT NULL,
    creator_id bigint NOT NULL,
    schedule_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone,
    type integer,
    location_id bigint
);


ALTER TABLE public.schedule_message OWNER TO ressystems;

--
-- Name: schedule_snap_shot_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE schedule_snap_shot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.schedule_snap_shot_id_seq OWNER TO postgres;

--
-- Name: schedule_snap_shot; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE schedule_snap_shot (
    id bigint DEFAULT nextval('schedule_snap_shot_id_seq'::regclass) NOT NULL,
    num_of_shifts integer,
    cost numeric(15,2),
    hours double precision,
    date_created timestamp without time zone NOT NULL,
    schedule_id bigint NOT NULL,
    location_id bigint NOT NULL,
    description character varying(255) NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    department_id bigint,
    sales_type_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.schedule_snap_shot OWNER TO ressystems;

--
-- Name: schema_version; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE schema_version
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.schema_version OWNER TO ressystems;

--
-- Name: security_template_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE security_template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.security_template_id_seq OWNER TO postgres;

--
-- Name: security_template; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE security_template (
    id bigint DEFAULT nextval('security_template_id_seq'::regclass) NOT NULL,
    corporation_id bigint,
    description character varying(255) NOT NULL,
    applies_to bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.security_template OWNER TO ressystems;

--
-- Name: security_template_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE security_template_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.security_template_rules_id_seq OWNER TO postgres;

--
-- Name: security_template_rules; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE security_template_rules (
    id bigint DEFAULT nextval('security_template_rules_id_seq'::regclass) NOT NULL,
    security_template_id bigint,
    role_id bigint,
    parameters character varying(255),
    access integer,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.security_template_rules OWNER TO ressystems;

--
-- Name: sensor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sensor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sensor_id_seq OWNER TO postgres;

--
-- Name: sensor; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE sensor (
    id bigint DEFAULT nextval('sensor_id_seq'::regclass) NOT NULL,
    description character varying(255),
    node_id bigint,
    sensor_type character varying(255),
    sensor_profile_id bigint,
    frequencyinminutes bigint,
    nodeindex bigint
);


ALTER TABLE public.sensor OWNER TO ressystems;

--
-- Name: sensor_profile_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sensor_profile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sensor_profile_id_seq OWNER TO postgres;

--
-- Name: sensor_profile; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE sensor_profile (
    id bigint DEFAULT nextval('sensor_profile_id_seq'::regclass) NOT NULL,
    description character varying(255),
    sensor_type character varying(255),
    corporation_id bigint
);


ALTER TABLE public.sensor_profile OWNER TO ressystems;

--
-- Name: sensorprofilerange_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sensorprofilerange_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sensorprofilerange_id_seq OWNER TO postgres;

--
-- Name: sensorprofilerange; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE sensorprofilerange (
    id bigint DEFAULT nextval('sensorprofilerange_id_seq'::regclass) NOT NULL,
    sensor_profile_id bigint,
    severity character varying(255),
    high_value bigint,
    low_value bigint,
    duration_minutes bigint,
    open character(1)
);


ALTER TABLE public.sensorprofilerange OWNER TO ressystems;

--
-- Name: setting_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE setting_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.setting_id_seq OWNER TO postgres;

--
-- Name: setting; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE setting (
    id bigint DEFAULT nextval('setting_id_seq'::regclass) NOT NULL,
    description character varying(255) NOT NULL,
    key character varying(255),
    default_value character varying(255)
);


ALTER TABLE public.setting OWNER TO ressystems;

--
-- Name: shift_builder_rule_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE shift_builder_rule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shift_builder_rule_id_seq OWNER TO postgres;

--
-- Name: shift_builder_rule; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE shift_builder_rule (
    id bigint DEFAULT nextval('shift_builder_rule_id_seq'::regclass) NOT NULL,
    type character varying(5) NOT NULL,
    location_id bigint,
    position_id bigint,
    sales numeric(15,2),
    number_of_employees integer,
    min_number_of_employees integer,
    max_number_of_employees integer,
    rounding numeric(15,2),
    min_hours numeric(15,2),
    max_hours numeric(15,2),
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.shift_builder_rule OWNER TO postgres;

--
-- Name: shift_include_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE shift_include_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shift_include_id_seq OWNER TO postgres;

--
-- Name: shift_include; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE shift_include (
    id bigint DEFAULT nextval('shift_include_id_seq'::regclass) NOT NULL,
    timeblock_id bigint,
    employee_id bigint,
    include character(1),
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.shift_include OWNER TO ressystems;

--
-- Name: shift_request_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE shift_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shift_request_id_seq OWNER TO postgres;

--
-- Name: shift_request; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE shift_request (
    id bigint DEFAULT nextval('shift_request_id_seq'::regclass) NOT NULL,
    timeblock_id bigint NOT NULL,
    requesting_employee_id bigint NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.shift_request OWNER TO ressystems;

--
-- Name: shift_swap_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE shift_swap_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shift_swap_id_seq OWNER TO postgres;

--
-- Name: shift_swap; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE shift_swap (
    id bigint DEFAULT nextval('shift_swap_id_seq'::regclass) NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone,
    givendatetime timestamp without time zone,
    givenmessage character varying(255),
    ispickedup character(1),
    given_employee_id bigint,
    timeblock_id bigint,
    pickedup character(1),
    location_id bigint,
    desired_employee bigint
);


ALTER TABLE public.shift_swap OWNER TO ressystems;

--
-- Name: shift_swap_attempt_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE shift_swap_attempt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shift_swap_attempt_id_seq OWNER TO postgres;

--
-- Name: shift_swap_attempt; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE shift_swap_attempt (
    id bigint DEFAULT nextval('shift_swap_attempt_id_seq'::regclass) NOT NULL,
    pickdatetime date,
    managerdatetime date,
    managerapprovalmessage character varying(255),
    managerapproval character varying(255),
    shift_swap_id bigint,
    pickup_employee_id bigint,
    manager_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone,
    parent_id bigint
);


ALTER TABLE public.shift_swap_attempt OWNER TO ressystems;

--
-- Name: shift_time_group; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE shift_time_group (
    id integer NOT NULL,
    group_description text,
    start_time time without time zone,
    end_time time without time zone,
    location_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone,
    department_id bigint
);


ALTER TABLE public.shift_time_group OWNER TO ressystems;

--
-- Name: shift_time_group_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE shift_time_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shift_time_group_id_seq OWNER TO ressystems;

--
-- Name: shift_time_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ressystems
--

ALTER SEQUENCE shift_time_group_id_seq OWNED BY shift_time_group.id;


--
-- Name: station_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE station_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.station_id_seq OWNER TO postgres;

--
-- Name: station; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE station (
    id bigint DEFAULT nextval('station_id_seq'::regclass) NOT NULL,
    description character varying(255) NOT NULL,
    position_id bigint,
    location_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.station OWNER TO ressystems;

--
-- Name: t_8767_2_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE t_8767_2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_8767_2_id_seq OWNER TO postgres;

--
-- Name: t_8767_3_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE t_8767_3_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_8767_3_id_seq OWNER TO postgres;

--
-- Name: t_8767_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE t_8767_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_8767_id_seq OWNER TO postgres;

--
-- Name: telink_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE telink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.telink_id_seq OWNER TO postgres;

SET default_with_oids = true;

--
-- Name: telink; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE telink (
    id bigint DEFAULT nextval('telink_id_seq'::regclass) NOT NULL,
    starttime time without time zone NOT NULL,
    endtime time without time zone NOT NULL,
    datecreated timestamp without time zone NOT NULL,
    extra character(1),
    template_id bigint NOT NULL,
    employee_id bigint NOT NULL,
    position_id bigint NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    description character varying(255),
    station_id bigint
);


ALTER TABLE public.telink OWNER TO ressystems;

--
-- Name: temperature_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE temperature_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.temperature_data_id_seq OWNER TO postgres;

SET default_with_oids = false;

--
-- Name: temperature_data; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE temperature_data (
    id bigint DEFAULT nextval('temperature_data_id_seq'::regclass) NOT NULL,
    sensor_id bigint,
    data_type character varying(255),
    data double precision,
    datetime timestamp without time zone
);


ALTER TABLE public.temperature_data OWNER TO ressystems;

--
-- Name: temperature_event_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE temperature_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.temperature_event_id_seq OWNER TO postgres;

--
-- Name: temperature_event; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE temperature_event (
    id bigint DEFAULT nextval('temperature_event_id_seq'::regclass) NOT NULL,
    employee_id bigint,
    sensor_id bigint,
    severity character(255),
    datetime timestamp without time zone,
    event_type bigint,
    deleted character(1),
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone,
    parent_id bigint
);


ALTER TABLE public.temperature_event OWNER TO ressystems;

--
-- Name: temperature_node_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE temperature_node_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.temperature_node_id_seq OWNER TO postgres;

--
-- Name: temperature_node; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE temperature_node (
    id bigint DEFAULT nextval('temperature_node_id_seq'::regclass) NOT NULL,
    description character varying(255),
    gateway bigint,
    node_index bigint,
    location_id bigint
);


ALTER TABLE public.temperature_node OWNER TO ressystems;

--
-- Name: template_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.template_id_seq OWNER TO postgres;

SET default_with_oids = true;

--
-- Name: template; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE template (
    id bigint DEFAULT nextval('template_id_seq'::regclass) NOT NULL,
    name character varying(255) NOT NULL,
    location_id bigint,
    creator_id bigint NOT NULL,
    date_created timestamp without time zone NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    department_id bigint,
    day_of_week integer
);


ALTER TABLE public.template OWNER TO ressystems;

SET default_with_oids = false;

--
-- Name: template_group; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE template_group (
    id integer NOT NULL,
    description character varying(255),
    location_id bigint,
    monday_template_id bigint,
    tuesday_template_id bigint,
    wednesday_template_id bigint,
    thursday_template_id bigint,
    friday_template_id bigint,
    saturday_template_id bigint,
    sunday_template_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone,
    department_id bigint,
    normal_week character(1) DEFAULT 'N'::bpchar
);


ALTER TABLE public.template_group OWNER TO ressystems;

--
-- Name: template_group_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE template_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.template_group_id_seq OWNER TO ressystems;

--
-- Name: template_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ressystems
--

ALTER SEQUENCE template_group_id_seq OWNED BY template_group.id;


--
-- Name: test125; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE test125 (
    id integer,
    dep_id integer,
    loc_id integer,
    corp_id bigint,
    pos_id integer,
    dep_name character varying(255),
    pos_name character varying(255),
    sales_name character varying(255),
    tod_date character varying(255),
    wtd_date character varying(255),
    tod_th_pr double precision,
    tod_th_ac double precision,
    wtd_th_pr double precision,
    wtd_th_ac double precision,
    dep_level integer,
    loc_name character varying(255),
    l_comp character varying(255),
    tod_sales_pr double precision,
    tod_sales_ac double precision,
    wtd_sales_pr double precision,
    wtd_sales_ac double precision,
    tod_sch double precision,
    tod_att double precision,
    wtd_sch double precision,
    wtd_att double precision,
    dflag character varying(255)
);


ALTER TABLE public.test125 OWNER TO postgres;

--
-- Name: test125_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE test125_id_seq
    START WITH 101
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.test125_id_seq OWNER TO postgres;

--
-- Name: testing; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE testing (
);


ALTER TABLE public.testing OWNER TO ressystems;

--
-- Name: tests; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE tests (
    group_description text,
    start_time time without time zone,
    end_time time without time zone,
    location_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone,
    department_id bigint
);


ALTER TABLE public.tests OWNER TO postgres;

--
-- Name: textmessage; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE textmessage (
    id integer NOT NULL,
    message text,
    date_created timestamp without time zone,
    who_id bigint,
    location_id bigint,
    deleted character(1),
    parent_id bigint,
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone,
    document_id bigint
);


ALTER TABLE public.textmessage OWNER TO ressystems;

--
-- Name: textmessage_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE textmessage_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.textmessage_id_seq OWNER TO ressystems;

--
-- Name: textmessage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ressystems
--

ALTER SEQUENCE textmessage_id_seq OWNED BY textmessage.id;


--
-- Name: tfmessage; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE tfmessage (
    id integer NOT NULL,
    message text,
    type character varying(255),
    date_created timestamp without time zone,
    to_user_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.tfmessage OWNER TO ressystems;

--
-- Name: tfmessage_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE tfmessage_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tfmessage_id_seq OWNER TO ressystems;

--
-- Name: tfmessage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ressystems
--

ALTER SEQUENCE tfmessage_id_seq OWNED BY tfmessage.id;


--
-- Name: tfmessage_user; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE tfmessage_user (
    id integer NOT NULL,
    who_id bigint,
    tf_message_id bigint,
    date_created timestamp without time zone,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.tfmessage_user OWNER TO ressystems;

--
-- Name: tfmessage_user_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE tfmessage_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tfmessage_user_id_seq OWNER TO ressystems;

--
-- Name: tfmessage_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ressystems
--

ALTER SEQUENCE tfmessage_user_id_seq OWNED BY tfmessage_user.id;


--
-- Name: timeblock_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE timeblock_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.timeblock_id_seq OWNER TO postgres;

SET default_with_oids = true;

--
-- Name: timeblock; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE timeblock (
    id bigint DEFAULT nextval('timeblock_id_seq'::regclass) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    memo character varying(255),
    extra character(1),
    notified character(1),
    creator_id bigint,
    publisher_id bigint,
    preference_id bigint,
    schedule_id bigint,
    employee_id bigint,
    position_id bigint NOT NULL,
    location_id bigint NOT NULL,
    tplink_id bigint,
    date_created timestamp without time zone NOT NULL,
    date_published timestamp without time zone,
    block_type character varying(1) NOT NULL,
    deleted_flag character(1),
    last_published character(1),
    cost double precision,
    publishedid bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    autoscheduled character(1),
    skill_level bigint,
    description character varying(255),
    station_id bigint,
    good_shift character(1),
    confirmed character(1) DEFAULT 'N'::bpchar,
    shift_type integer DEFAULT 1
);


ALTER TABLE public.timeblock OWNER TO ressystems;

--
-- Name: timeblockevent_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE timeblockevent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.timeblockevent_id_seq OWNER TO postgres;

SET default_with_oids = false;

--
-- Name: timeblock_event; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE timeblock_event (
    id bigint DEFAULT nextval('timeblockevent_id_seq'::regclass) NOT NULL,
    timeblock_id bigint NOT NULL,
    event_id bigint NOT NULL,
    start_time time without time zone,
    end_time time without time zone,
    note text,
    date_created timestamp without time zone NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.timeblock_event OWNER TO postgres;

--
-- Name: timeblock_skillset; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE timeblock_skillset (
    id bigint NOT NULL,
    timeblock_id bigint NOT NULL,
    skillset_id bigint NOT NULL,
    position_id bigint NOT NULL,
    date_created timestamp without time zone NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.timeblock_skillset OWNER TO postgres;

--
-- Name: timeblock_snap_shot_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE timeblock_snap_shot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.timeblock_snap_shot_id_seq OWNER TO postgres;

--
-- Name: timeblock_snap_shot; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE timeblock_snap_shot (
    id bigint DEFAULT nextval('timeblock_snap_shot_id_seq'::regclass) NOT NULL,
    schedule_snap_shot_id bigint NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    memo character varying(255),
    extra character(1),
    schedule_id bigint,
    employee_id bigint,
    position_id bigint NOT NULL,
    location_id bigint NOT NULL,
    station_id bigint,
    block_type character varying(1) NOT NULL,
    cost double precision,
    autoscheduled character(1),
    description character varying(255),
    skill_level integer,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.timeblock_snap_shot OWNER TO ressystems;

--
-- Name: timeblockskillset_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE timeblockskillset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.timeblockskillset_id_seq OWNER TO postgres;

--
-- Name: timezone; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE timezone (
    id integer NOT NULL,
    country character(2),
    postal_code character varying(255),
    timezone_offset double precision,
    dst character(1) DEFAULT 'N'::bpchar
);


ALTER TABLE public.timezone OWNER TO ressystems;

--
-- Name: timezone_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE timezone_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.timezone_id_seq OWNER TO ressystems;

--
-- Name: timezone_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ressystems
--

ALTER SEQUENCE timezone_id_seq OWNED BY timezone.id;


--
-- Name: tomcat_sessions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE tomcat_sessions (
    id character varying(100) NOT NULL,
    valid character(1) NOT NULL,
    maxinactive integer,
    lastaccess bigint,
    data bytea,
    app bytea
);


ALTER TABLE public.tomcat_sessions OWNER TO postgres;

--
-- Name: tplink_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE tplink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tplink_id_seq OWNER TO postgres;

SET default_with_oids = true;

--
-- Name: tplink; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE tplink (
    id bigint DEFAULT nextval('tplink_id_seq'::regclass) NOT NULL,
    starttime time without time zone NOT NULL,
    endtime time without time zone NOT NULL,
    required integer NOT NULL,
    extras integer,
    datecreated timestamp without time zone NOT NULL,
    template_id bigint NOT NULL,
    position_id bigint NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone,
    skill_level bigint,
    description character varying(255),
    station_id bigint,
    shift_type integer DEFAULT 1
);


ALTER TABLE public.tplink OWNER TO ressystems;

SET default_with_oids = false;

--
-- Name: tplink_skillset; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE tplink_skillset (
    id bigint NOT NULL,
    tplink_id bigint NOT NULL,
    skillset_id bigint,
    date_created timestamp without time zone NOT NULL,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.tplink_skillset OWNER TO postgres;

--
-- Name: tplinkskillset_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE tplinkskillset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tplinkskillset_id_seq OWNER TO postgres;

--
-- Name: u_r; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE u_r (
    rid bigint,
    uid bigint
);


ALTER TABLE public.u_r OWNER TO ressystems;

--
-- Name: u_r2; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE u_r2 (
    uid bigint
);


ALTER TABLE public.u_r2 OWNER TO ressystems;

--
-- Name: urx322; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE urx322 (
    uid bigint
);


ALTER TABLE public.urx322 OWNER TO postgres;

--
-- Name: urx330; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE urx330 (
    uid bigint
);


ALTER TABLE public.urx330 OWNER TO ressystems;

--
-- Name: urx335; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE urx335 (
    uid bigint
);


ALTER TABLE public.urx335 OWNER TO ressystems;

--
-- Name: user_location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE user_location_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_location_id_seq OWNER TO postgres;

SET default_with_oids = true;

--
-- Name: user_location; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE user_location (
    location_id bigint NOT NULL,
    user_id bigint NOT NULL,
    deleted character(1),
    id bigint DEFAULT nextval('user_location_id_seq'::regclass) NOT NULL,
    parent_id bigint,
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone,
    termination_date timestamp without time zone,
    hire_date timestamp without time zone,
    eligibleforrehire character(1) DEFAULT 'Y'::bpchar,
    ineligiblereason character varying(255),
    first_name character varying(50),
    last_name character varying(50),
    middle_name character varying(50),
    birth_date timestamp without time zone,
    drivers_license_number character varying(40),
    sms character varying(255),
    overtime character varying(255),
    email character varying(255),
    internal_number character varying(255),
    internal_password character varying(255),
    payroll_id character varying(255),
    ssn text,
    ssn_suffix character varying(255),
    min_hours double precision,
    max_hours double precision,
    min_hours_per_day double precision,
    max_hours_per_day double precision,
    max_shifts integer,
    min_shifts integer,
    max_shifts_per_week integer,
    min_shifts_per_week integer,
    finger1 bytea,
    finger2 bytea,
    finger3 bytea,
    finger4 bytea,
    zkpin character varying(10)
);


ALTER TABLE public.user_location OWNER TO ressystems;

--
-- Name: user_role; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE user_role (
    user_id bigint NOT NULL,
    role_id bigint NOT NULL
);


ALTER TABLE public.user_role OWNER TO ressystems;

--
-- Name: user_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE user_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_role_id_seq OWNER TO postgres;

--
-- Name: user_security_template_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE user_security_template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_security_template_id_seq OWNER TO postgres;

SET default_with_oids = false;

--
-- Name: user_security_template; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE user_security_template (
    id bigint DEFAULT nextval('user_security_template_id_seq'::regclass) NOT NULL,
    user_id bigint,
    security_template_id bigint,
    parent_id bigint,
    deleted character(1),
    starttimestamp timestamp without time zone NOT NULL,
    endtimestamp timestamp without time zone
);


ALTER TABLE public.user_security_template OWNER TO ressystems;

--
-- Name: user_textmessage; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE user_textmessage (
    id integer NOT NULL,
    sentemail character(1),
    viewedmessage character(1),
    sentemaildate timestamp without time zone,
    viewedmessagedate timestamp without time zone,
    user_id bigint,
    textmessage_id bigint,
    deleted character(1),
    parent_id bigint,
    starttimestamp timestamp without time zone,
    endtimestamp timestamp without time zone,
    sentsms character(1) DEFAULT 'N'::bpchar,
    sentsmsdate timestamp without time zone,
    message_deleted character(1) DEFAULT 'N'::bpchar,
    alert_type integer
);


ALTER TABLE public.user_textmessage OWNER TO ressystems;

--
-- Name: user_textmessage_id_seq; Type: SEQUENCE; Schema: public; Owner: ressystems
--

CREATE SEQUENCE user_textmessage_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_textmessage_id_seq OWNER TO ressystems;

--
-- Name: user_textmessage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ressystems
--

ALTER SEQUENCE user_textmessage_id_seq OWNED BY user_textmessage.id;


--
-- Name: weather_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE weather_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.weather_id_seq OWNER TO postgres;

--
-- Name: weather; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE weather (
    id bigint DEFAULT nextval('weather_id_seq'::regclass) NOT NULL,
    zip_code character varying(255),
    city_country character varying(255)
);


ALTER TABLE public.weather OWNER TO ressystems;

--
-- Name: weather_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE weather_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.weather_data_id_seq OWNER TO postgres;

--
-- Name: weather_data; Type: TABLE; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE TABLE weather_data (
    id bigint DEFAULT nextval('weather_data_id_seq'::regclass) NOT NULL,
    temperature character varying(255),
    high character varying(255),
    low character varying(255),
    precipitation character varying(255),
    date date NOT NULL,
    dayname character varying(255),
    weather_id bigint NOT NULL
);


ALTER TABLE public.weather_data OWNER TO ressystems;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ressystems
--

ALTER TABLE break_rule ALTER COLUMN id SET DEFAULT nextval('break_rule_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ressystems
--

ALTER TABLE department ALTER COLUMN id SET DEFAULT nextval('department_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ressystems
--

ALTER TABLE hierarchy ALTER COLUMN id SET DEFAULT nextval('hierarchy_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ressystems
--

ALTER TABLE location_hierarchy ALTER COLUMN id SET DEFAULT nextval('location_hierarchy_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ressystems
--

ALTER TABLE minor ALTER COLUMN id SET DEFAULT nextval('minor_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ressystems
--

ALTER TABLE minor_preference ALTER COLUMN id SET DEFAULT nextval('minor_preference_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ressystems
--

ALTER TABLE preference_type ALTER COLUMN id SET DEFAULT nextval('preference_type_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ressystems
--

ALTER TABLE referral_log ALTER COLUMN id SET DEFAULT nextval('referral_log_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ressystems
--

ALTER TABLE replacement ALTER COLUMN id SET DEFAULT nextval('replacement_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ressystems
--

ALTER TABLE shift_time_group ALTER COLUMN id SET DEFAULT nextval('shift_time_group_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ressystems
--

ALTER TABLE template_group ALTER COLUMN id SET DEFAULT nextval('template_group_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ressystems
--

ALTER TABLE textmessage ALTER COLUMN id SET DEFAULT nextval('textmessage_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ressystems
--

ALTER TABLE tfmessage ALTER COLUMN id SET DEFAULT nextval('tfmessage_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ressystems
--

ALTER TABLE tfmessage_user ALTER COLUMN id SET DEFAULT nextval('tfmessage_user_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ressystems
--

ALTER TABLE timezone ALTER COLUMN id SET DEFAULT nextval('timezone_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ressystems
--

ALTER TABLE user_textmessage ALTER COLUMN id SET DEFAULT nextval('user_textmessage_id_seq'::regclass);


--
-- Name: app_user_email_key; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY app_user
    ADD CONSTRAINT app_user_email_key UNIQUE (email);


--
-- Name: app_user_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- Name: app_user_username_key; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY app_user
    ADD CONSTRAINT app_user_username_key UNIQUE (username);


--
-- Name: applicant_document_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY applicant_document
    ADD CONSTRAINT applicant_document_pkey PRIMARY KEY (id);


--
-- Name: applicant_historical_step_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY applicant_historical_step
    ADD CONSTRAINT applicant_historical_step_pkey PRIMARY KEY (id);


--
-- Name: applicant_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY applicant
    ADD CONSTRAINT applicant_pkey PRIMARY KEY (id);


--
-- Name: attendance_block_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY attendance_block
    ADD CONSTRAINT attendance_block_pkey PRIMARY KEY (id);


--
-- Name: attendance_break_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY attendance_break
    ADD CONSTRAINT attendance_break_pkey PRIMARY KEY (id);


--
-- Name: blackout_preference_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY blackout_preference
    ADD CONSTRAINT blackout_preference_pkey PRIMARY KEY (id);


--
-- Name: blocked_daily_ip_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY blocked_daily_ip
    ADD CONSTRAINT blocked_daily_ip_pkey PRIMARY KEY (id);


--
-- Name: break_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY break_rule
    ADD CONSTRAINT break_rule_pkey PRIMARY KEY (id);


--
-- Name: break_time_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY break_time
    ADD CONSTRAINT break_time_pkey PRIMARY KEY (id);


--
-- Name: break_time_snap_shot_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY break_time_snap_shot
    ADD CONSTRAINT break_time_snap_shot_pkey PRIMARY KEY (id);


--
-- Name: certification_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY certification
    ADD CONSTRAINT certification_pkey PRIMARY KEY (id);


--
-- Name: commision_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY commision
    ADD CONSTRAINT commision_pkey PRIMARY KEY (id);


--
-- Name: corporation_key_key; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY corporation
    ADD CONSTRAINT corporation_key_key UNIQUE (key);


--
-- Name: corporation_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY corporation
    ADD CONSTRAINT corporation_pkey PRIMARY KEY (id);


--
-- Name: country_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY country
    ADD CONSTRAINT country_pkey PRIMARY KEY (code);


--
-- Name: date_etl_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY date_etl
    ADD CONSTRAINT date_etl_pkey PRIMARY KEY (id);


--
-- Name: department_employee_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY department_employee
    ADD CONSTRAINT department_employee_pkey PRIMARY KEY (id);


--
-- Name: department_location_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY department_location
    ADD CONSTRAINT department_location_pkey PRIMARY KEY (id);


--
-- Name: department_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY department
    ADD CONSTRAINT department_pkey PRIMARY KEY (id);


--
-- Name: department_position_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY department_position
    ADD CONSTRAINT department_position_pkey PRIMARY KEY (id);


--
-- Name: department_roll_up_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY department_roll_up
    ADD CONSTRAINT department_roll_up_pkey PRIMARY KEY (id);


--
-- Name: document_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY document
    ADD CONSTRAINT document_pkey PRIMARY KEY (id);


--
-- Name: employee_accrual_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY employee_accrual
    ADD CONSTRAINT employee_accrual_pkey PRIMARY KEY (id);


--
-- Name: employee_certification_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY employee_certification
    ADD CONSTRAINT employee_certification_pkey PRIMARY KEY (id);


--
-- Name: employee_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (id);


--
-- Name: employee_position_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY employee_position
    ADD CONSTRAINT employee_position_pkey PRIMARY KEY (id);


--
-- Name: employee_preference_type_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY employee_preference_type
    ADD CONSTRAINT employee_preference_type_pkey PRIMARY KEY (id);


--
-- Name: employee_sensoralert_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY employee_sensoralert
    ADD CONSTRAINT employee_sensoralert_pkey PRIMARY KEY (id);


--
-- Name: employee_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY employee_setting
    ADD CONSTRAINT employee_setting_pkey PRIMARY KEY (id);


--
-- Name: event_certification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY event_certification
    ADD CONSTRAINT event_certification_pkey PRIMARY KEY (id);


--
-- Name: event_department_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY event_department
    ADD CONSTRAINT event_department_pkey PRIMARY KEY (id);


--
-- Name: event_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);


--
-- Name: flag_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY flag
    ADD CONSTRAINT flag_pkey PRIMARY KEY (id);


--
-- Name: forecast_timeblock_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY forecast_timeblock
    ADD CONSTRAINT forecast_timeblock_pkey PRIMARY KEY (id);


--
-- Name: hierarchy_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY hierarchy
    ADD CONSTRAINT hierarchy_pkey PRIMARY KEY (id);


--
-- Name: invoice_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY invoice
    ADD CONSTRAINT invoice_pkey PRIMARY KEY (id);


--
-- Name: location_flag_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY location_flag
    ADD CONSTRAINT location_flag_pkey PRIMARY KEY (id);


--
-- Name: location_hierarchy_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY location_hierarchy
    ADD CONSTRAINT location_hierarchy_pkey PRIMARY KEY (id);


--
-- Name: location_key_key; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY location
    ADD CONSTRAINT location_key_key UNIQUE (key);


--
-- Name: location_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY location
    ADD CONSTRAINT location_pkey PRIMARY KEY (id);


--
-- Name: logtag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY logtag
    ADD CONSTRAINT logtag_pkey PRIMARY KEY (id);


--
-- Name: manager_log_category_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY manager_log_category
    ADD CONSTRAINT manager_log_category_pkey PRIMARY KEY (id);


--
-- Name: manager_log_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY manager_log
    ADD CONSTRAINT manager_log_pkey PRIMARY KEY (id);


--
-- Name: managerlog_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY managerlog_comment
    ADD CONSTRAINT managerlog_comment_pkey PRIMARY KEY (id);


--
-- Name: managerlog_logtag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY managerlog_logtag
    ADD CONSTRAINT managerlog_logtag_pkey PRIMARY KEY (id);


--
-- Name: message_log_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY message_log
    ADD CONSTRAINT message_log_pkey PRIMARY KEY (id);


--
-- Name: minor_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY minor
    ADD CONSTRAINT minor_pkey PRIMARY KEY (id);


--
-- Name: minor_preference_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY minor_preference
    ADD CONSTRAINT minor_preference_pkey PRIMARY KEY (id);


--
-- Name: multi_level_pay_rate_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY multi_level_pay_rate
    ADD CONSTRAINT multi_level_pay_rate_pkey PRIMARY KEY (id);


--
-- Name: payment_log_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY payment_log
    ADD CONSTRAINT payment_log_pkey PRIMARY KEY (id);


--
-- Name: pglink_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY pglink
    ADD CONSTRAINT pglink_pkey PRIMARY KEY (id);


--
-- Name: position_certification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY position_certification
    ADD CONSTRAINT position_certification_pkey PRIMARY KEY (id);


--
-- Name: position_code_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY position_code
    ADD CONSTRAINT position_code_pkey PRIMARY KEY (id);


--
-- Name: position_filter_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY position_filter
    ADD CONSTRAINT position_filter_pkey PRIMARY KEY (id);


--
-- Name: position_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY "position"
    ADD CONSTRAINT position_pkey PRIMARY KEY (id);


--
-- Name: position_tracking_step_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY position_tracking_step
    ADD CONSTRAINT position_tracking_step_pkey PRIMARY KEY (id);


--
-- Name: positiongroup_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY positiongroup
    ADD CONSTRAINT positiongroup_pkey PRIMARY KEY (id);


--
-- Name: preference_conflict_etl_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY preference_conflict_etl
    ADD CONSTRAINT preference_conflict_etl_pkey PRIMARY KEY (id);


--
-- Name: preference_date_etl_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY preference_date_etl
    ADD CONSTRAINT preference_date_etl_pkey PRIMARY KEY (id);


--
-- Name: preference_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY preference
    ADD CONSTRAINT preference_pkey PRIMARY KEY (id);


--
-- Name: preference_type_location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY preference_type_location
    ADD CONSTRAINT preference_type_location_pkey PRIMARY KEY (id);


--
-- Name: preference_type_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY preference_type
    ADD CONSTRAINT preference_type_pkey PRIMARY KEY (id);


--
-- Name: price_object_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY price_object
    ADD CONSTRAINT price_object_pkey PRIMARY KEY (id);


--
-- Name: pto_accrual_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY pto_accrual
    ADD CONSTRAINT pto_accrual_pkey PRIMARY KEY (id);


--
-- Name: qrtz_blob_triggers_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY qrtz_blob_triggers
    ADD CONSTRAINT qrtz_blob_triggers_pkey PRIMARY KEY (trigger_name, trigger_group);


--
-- Name: qrtz_calendars_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY qrtz_calendars
    ADD CONSTRAINT qrtz_calendars_pkey PRIMARY KEY (calendar_name);


--
-- Name: qrtz_cron_triggers_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY qrtz_cron_triggers
    ADD CONSTRAINT qrtz_cron_triggers_pkey PRIMARY KEY (trigger_name, trigger_group);


--
-- Name: qrtz_fired_triggers_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY qrtz_fired_triggers
    ADD CONSTRAINT qrtz_fired_triggers_pkey PRIMARY KEY (entry_id);


--
-- Name: qrtz_job_details_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY qrtz_job_details
    ADD CONSTRAINT qrtz_job_details_pkey PRIMARY KEY (job_name, job_group);


--
-- Name: qrtz_job_listeners_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY qrtz_job_listeners
    ADD CONSTRAINT qrtz_job_listeners_pkey PRIMARY KEY (job_name, job_group, job_listener);


--
-- Name: qrtz_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY qrtz_locks
    ADD CONSTRAINT qrtz_locks_pkey PRIMARY KEY (lock_name);


--
-- Name: qrtz_paused_trigger_grps_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY qrtz_paused_trigger_grps
    ADD CONSTRAINT qrtz_paused_trigger_grps_pkey PRIMARY KEY (trigger_group);


--
-- Name: qrtz_scheduler_state_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY qrtz_scheduler_state
    ADD CONSTRAINT qrtz_scheduler_state_pkey PRIMARY KEY (instance_name);


--
-- Name: qrtz_simple_triggers_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY qrtz_simple_triggers
    ADD CONSTRAINT qrtz_simple_triggers_pkey PRIMARY KEY (trigger_name, trigger_group);


--
-- Name: qrtz_trigger_listeners_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY qrtz_trigger_listeners
    ADD CONSTRAINT qrtz_trigger_listeners_pkey PRIMARY KEY (trigger_name, trigger_group, trigger_listener);


--
-- Name: qrtz_triggers_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY qrtz_triggers
    ADD CONSTRAINT qrtz_triggers_pkey PRIMARY KEY (trigger_name, trigger_group);


--
-- Name: questionnarie_answer_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY questionnarie_answer
    ADD CONSTRAINT questionnarie_answer_pkey PRIMARY KEY (id);


--
-- Name: questionnarie_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY questionnarie
    ADD CONSTRAINT questionnarie_pkey PRIMARY KEY (id);


--
-- Name: questionnarie_question_options_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY questionnarie_question_options
    ADD CONSTRAINT questionnarie_question_options_pkey PRIMARY KEY (id);


--
-- Name: questionnarie_question_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY questionnarie_question
    ADD CONSTRAINT questionnarie_question_pkey PRIMARY KEY (id);


--
-- Name: referral_log_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY referral_log
    ADD CONSTRAINT referral_log_pkey PRIMARY KEY (id);


--
-- Name: replacement_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY replacement
    ADD CONSTRAINT replacement_pkey PRIMARY KEY (id);


--
-- Name: report_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY report_schedule
    ADD CONSTRAINT report_schedule_pkey PRIMARY KEY (id);


--
-- Name: reseller_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY reseller
    ADD CONSTRAINT reseller_pkey PRIMARY KEY (id);


--
-- Name: role_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- Name: sales_dep_threshold_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sales_dep_threshold
    ADD CONSTRAINT sales_dep_threshold_pkey PRIMARY KEY (id);


--
-- Name: sales_paf_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY sales_paf
    ADD CONSTRAINT sales_paf_pkey PRIMARY KEY (id);


--
-- Name: sales_type_location_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY sales_type_location
    ADD CONSTRAINT sales_type_location_pkey PRIMARY KEY (id);


--
-- Name: sales_type_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY sales_type
    ADD CONSTRAINT sales_type_pkey PRIMARY KEY (id);


--
-- Name: schedule_message_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY schedule_message
    ADD CONSTRAINT schedule_message_pkey PRIMARY KEY (id);


--
-- Name: schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY schedule
    ADD CONSTRAINT schedule_pkey PRIMARY KEY (id);


--
-- Name: schedule_snap_shot_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY schedule_snap_shot
    ADD CONSTRAINT schedule_snap_shot_pkey PRIMARY KEY (id);


--
-- Name: security_template_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY security_template
    ADD CONSTRAINT security_template_pkey PRIMARY KEY (id);


--
-- Name: security_template_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY security_template_rules
    ADD CONSTRAINT security_template_rules_pkey PRIMARY KEY (id);


--
-- Name: sensor_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY sensor
    ADD CONSTRAINT sensor_pkey PRIMARY KEY (id);


--
-- Name: sensor_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY sensor_profile
    ADD CONSTRAINT sensor_profile_pkey PRIMARY KEY (id);


--
-- Name: sensorprofilerange_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY sensorprofilerange
    ADD CONSTRAINT sensorprofilerange_pkey PRIMARY KEY (id);


--
-- Name: setting_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY setting
    ADD CONSTRAINT setting_pkey PRIMARY KEY (id);


--
-- Name: shift_builder_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY shift_builder_rule
    ADD CONSTRAINT shift_builder_rule_pkey PRIMARY KEY (id);


--
-- Name: shift_include_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY shift_include
    ADD CONSTRAINT shift_include_pkey PRIMARY KEY (id);


--
-- Name: shift_request_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY shift_request
    ADD CONSTRAINT shift_request_pkey PRIMARY KEY (id);


--
-- Name: shift_swap_attempt_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY shift_swap_attempt
    ADD CONSTRAINT shift_swap_attempt_pkey PRIMARY KEY (id);


--
-- Name: shift_swap_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY shift_swap
    ADD CONSTRAINT shift_swap_pkey PRIMARY KEY (id);


--
-- Name: shift_time_group_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY shift_time_group
    ADD CONSTRAINT shift_time_group_pkey PRIMARY KEY (id);


--
-- Name: station_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY station
    ADD CONSTRAINT station_pkey PRIMARY KEY (id);


--
-- Name: telink_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY telink
    ADD CONSTRAINT telink_pkey PRIMARY KEY (id);


--
-- Name: temperature_data_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY temperature_data
    ADD CONSTRAINT temperature_data_pkey PRIMARY KEY (id);


--
-- Name: temperature_event_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY temperature_event
    ADD CONSTRAINT temperature_event_pkey PRIMARY KEY (id);


--
-- Name: temperature_node_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY temperature_node
    ADD CONSTRAINT temperature_node_pkey PRIMARY KEY (id);


--
-- Name: template_group_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY template_group
    ADD CONSTRAINT template_group_pkey PRIMARY KEY (id);


--
-- Name: template_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY template
    ADD CONSTRAINT template_pkey PRIMARY KEY (id);


--
-- Name: textmessage_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY textmessage
    ADD CONSTRAINT textmessage_pkey PRIMARY KEY (id);


--
-- Name: tfmessage_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY tfmessage
    ADD CONSTRAINT tfmessage_pkey PRIMARY KEY (id);


--
-- Name: tfmessage_user_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY tfmessage_user
    ADD CONSTRAINT tfmessage_user_pkey PRIMARY KEY (id);


--
-- Name: timeblock_event_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY timeblock_event
    ADD CONSTRAINT timeblock_event_pkey PRIMARY KEY (id);


--
-- Name: timeblock_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY timeblock
    ADD CONSTRAINT timeblock_pkey PRIMARY KEY (id);


--
-- Name: timeblock_skillset_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY timeblock_skillset
    ADD CONSTRAINT timeblock_skillset_pkey PRIMARY KEY (id);


--
-- Name: timeblock_snap_shot_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY timeblock_snap_shot
    ADD CONSTRAINT timeblock_snap_shot_pkey PRIMARY KEY (id);


--
-- Name: tplink_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY tplink
    ADD CONSTRAINT tplink_pkey PRIMARY KEY (id);


--
-- Name: tplink_skillset_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tplink_skillset
    ADD CONSTRAINT tplink_skillset_pkey PRIMARY KEY (id);


--
-- Name: user_location_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY user_location
    ADD CONSTRAINT user_location_pkey PRIMARY KEY (id);


--
-- Name: user_role_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY user_role
    ADD CONSTRAINT user_role_pkey PRIMARY KEY (user_id, role_id);


--
-- Name: user_security_template_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY user_security_template
    ADD CONSTRAINT user_security_template_pkey PRIMARY KEY (id);


--
-- Name: user_textmessage_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY user_textmessage
    ADD CONSTRAINT user_textmessage_pkey PRIMARY KEY (id);


--
-- Name: weather_data_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY weather_data
    ADD CONSTRAINT weather_data_pkey PRIMARY KEY (id);


--
-- Name: weather_pkey; Type: CONSTRAINT; Schema: public; Owner: ressystems; Tablespace: 
--

ALTER TABLE ONLY weather
    ADD CONSTRAINT weather_pkey PRIMARY KEY (id);


--
-- Name: app_user_corp; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX app_user_corp ON app_user USING btree (corporation_id);


--
-- Name: app_user_del; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX app_user_del ON app_user USING btree (deleted);


--
-- Name: app_user_lower_username_key; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX app_user_lower_username_key ON app_user USING btree (lower((username)::text));


--
-- Name: att_break_att_block; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX att_break_att_block ON attendance_break USING btree (attendance_block_id);


--
-- Name: bk_attendance_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX bk_attendance_id ON break_time USING btree (attendanceblock_id);


--
-- Name: bk_time_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX bk_time_id ON break_time USING btree (timeblock_id);


--
-- Name: corporation_creator; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX corporation_creator ON corporation USING btree (creator_id);


--
-- Name: corporation_del; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX corporation_del ON corporation USING btree (deleted);


--
-- Name: dep_employee_did; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX dep_employee_did ON department_employee USING btree (department_id);


--
-- Name: dep_employee_eid; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX dep_employee_eid ON department_employee USING btree (employee_id);


--
-- Name: e_attendanceb_idx; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX e_attendanceb_idx ON employee USING btree (active_attendance_block);


--
-- Name: emp_del; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX emp_del ON employee USING btree (deleted);


--
-- Name: emp_pos_del; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX emp_pos_del ON employee_position USING btree (deleted);


--
-- Name: emp_pos_employee_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX emp_pos_employee_id ON employee_position USING btree (employee_id);


--
-- Name: emp_pos_position_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX emp_pos_position_id ON employee_position USING btree (position_id);


--
-- Name: emp_set_del; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX emp_set_del ON employee_setting USING btree (deleted);


--
-- Name: emp_set_emp; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX emp_set_emp ON employee_setting USING btree (employee_id);


--
-- Name: emp_set_flag; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX emp_set_flag ON employee_setting USING btree (flag_id);


--
-- Name: emp_user_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX emp_user_id ON employee USING btree (user_id);


--
-- Name: forecast_timeblock_location_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX forecast_timeblock_location_id ON forecast_timeblock USING btree (location_id);


--
-- Name: forecast_timeblock_position_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX forecast_timeblock_position_id ON forecast_timeblock USING btree (position_id);


--
-- Name: ft_start_idx; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX ft_start_idx ON forecast_timeblock USING btree (start_date);


--
-- Name: i_attendance_allocated; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_attendance_allocated ON attendance_block USING btree (allocated_date);


--
-- Name: i_attendance_block_emp_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_attendance_block_emp_id_idx ON attendance_block USING btree (employee_id);


--
-- Name: i_attendance_block_pos_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_attendance_block_pos_id_idx ON attendance_block USING btree (position_id);


--
-- Name: i_attendance_block_start_date_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_attendance_block_start_date_idx ON attendance_block USING btree (start_date);


--
-- Name: i_attendance_deleted_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_attendance_deleted_idx ON attendance_block USING btree (deleted);


--
-- Name: i_attendance_location_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_attendance_location_idx ON attendance_block USING btree (location_id);


--
-- Name: i_bk_location_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX i_bk_location_id ON break_time USING btree (location_id);


--
-- Name: i_conf_idx; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX i_conf_idx ON preference_conflict_etl USING btree (conflict_id);


--
-- Name: i_corp_petl; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX i_corp_petl ON preference_date_etl USING btree (corporation_id) WHERE (deleted = 'N'::bpchar);


--
-- Name: i_date_local_date; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX i_date_local_date ON date_etl USING btree (local_date);


--
-- Name: i_date_petl; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX i_date_petl ON preference_date_etl USING btree (date_etl_id) WHERE (deleted = 'N'::bpchar);


--
-- Name: i_date_year; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX i_date_year ON date_etl USING btree (year);


--
-- Name: i_emp_payroll_lower; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX i_emp_payroll_lower ON employee USING btree (lower((payroll_id)::text));


--
-- Name: i_employee_ssn_suffix; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX i_employee_ssn_suffix ON employee USING btree (ssn_suffix);


--
-- Name: i_employee_termdate; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX i_employee_termdate ON employee USING btree (termination_date);


--
-- Name: i_pref_idx; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX i_pref_idx ON preference_conflict_etl USING btree (preference_id);


--
-- Name: i_pref_petl; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX i_pref_petl ON preference_date_etl USING btree (preference_id) WHERE (deleted = 'N'::bpchar);


--
-- Name: i_sales_paf_date; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX i_sales_paf_date ON sales_paf USING btree (date);


--
-- Name: idx_notify_sms; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX idx_notify_sms ON app_user USING btree (notify_sms);


--
-- Name: idx_shift_swap; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX idx_shift_swap ON shift_swap USING btree (timeblock_id);


--
-- Name: loc_corporation_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX loc_corporation_id ON location USING btree (corporation_id);


--
-- Name: loc_creator_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX loc_creator_id ON location USING btree (creator_id);


--
-- Name: loc_del; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX loc_del ON location USING btree (deleted);


--
-- Name: location_flag_del; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX location_flag_del ON location_flag USING btree (deleted);


--
-- Name: location_flag_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX location_flag_id ON location_flag USING btree (flag_id);


--
-- Name: location_loc_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX location_loc_id ON location_flag USING btree (location_id);


--
-- Name: pid_preference_conflict_etl; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pid_preference_conflict_etl ON preference_conflict_etl USING btree (parent_id);


--
-- Name: pid_preference_date_etl; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pid_preference_date_etl ON preference_date_etl USING btree (parent_id);


--
-- Name: pos_del; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pos_del ON "position" USING btree (deleted);


--
-- Name: pos_location_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pos_location_id ON "position" USING btree (location_id);


--
-- Name: pos_pos_code_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pos_pos_code_id ON "position" USING btree (position_code_id);


--
-- Name: position_corp_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX position_corp_id ON position_code USING btree (corporation_id);


--
-- Name: position_del; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX position_del ON position_code USING btree (deleted);


--
-- Name: position_desc; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX position_desc ON position_code USING btree (description);


--
-- Name: pref_all; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pref_all ON preference USING btree (id) WHERE ((deleted = 'N'::bpchar) AND ((approval_status)::text <> 'Denied'::text));


--
-- Name: pref_approvalstatus; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pref_approvalstatus ON preference USING btree (approval_status);


--
-- Name: pref_create; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pref_create ON preference USING btree (creator_id);


--
-- Name: pref_datecreated; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pref_datecreated ON preference USING btree (date_created);


--
-- Name: pref_del; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pref_del ON preference USING btree (deleted);


--
-- Name: pref_employee_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pref_employee_id ON preference USING btree (employee_id);


--
-- Name: pref_enddate; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pref_enddate ON preference USING btree (enddate);


--
-- Name: pref_freq; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pref_freq ON preference USING btree (frequency);


--
-- Name: pref_fri; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pref_fri ON preference USING btree (friday);


--
-- Name: pref_mon; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pref_mon ON preference USING btree (monday);


--
-- Name: pref_sat; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pref_sat ON preference USING btree (saturday);


--
-- Name: pref_startdate; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pref_startdate ON preference USING btree (startdate);


--
-- Name: pref_sun; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pref_sun ON preference USING btree (sunday);


--
-- Name: pref_thur; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pref_thur ON preference USING btree (thursday);


--
-- Name: pref_tue; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pref_tue ON preference USING btree (tuesday);


--
-- Name: pref_wed; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pref_wed ON preference USING btree (wednesday);


--
-- Name: pref_weight; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX pref_weight ON preference USING btree (weight);


--
-- Name: role_name; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX role_name ON role USING btree (name);


--
-- Name: sales_belongs_to; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX sales_belongs_to ON sales_paf USING btree (belongs_to);


--
-- Name: sales_dep_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX sales_dep_id ON sales_paf USING btree (department_id);


--
-- Name: sales_paf_location_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX sales_paf_location_id ON sales_paf USING btree (location_id);


--
-- Name: sales_paf_salestype_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX sales_paf_salestype_id ON sales_paf USING btree (sales_type_id);


--
-- Name: sales_paf_type; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX sales_paf_type ON sales_paf USING btree (type);


--
-- Name: sales_type_del; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX sales_type_del ON sales_type USING btree (deleted);


--
-- Name: sales_type_desc; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX sales_type_desc ON sales_type USING btree (description);


--
-- Name: sales_type_location_location_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX sales_type_location_location_id ON sales_type_location USING btree (location_id);


--
-- Name: sales_type_location_sales_type_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX sales_type_location_sales_type_id ON sales_type_location USING btree (sales_type_id);


--
-- Name: sch_pub; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX sch_pub ON timeblock USING btree (publishedid);


--
-- Name: schedule_del; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX schedule_del ON schedule USING btree (deleted);


--
-- Name: schedule_loc; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX schedule_loc ON schedule USING btree (location_id);


--
-- Name: schedule_sales_type; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX schedule_sales_type ON schedule USING btree (sales_type_id);


--
-- Name: shift_swap_attempt_approval; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX shift_swap_attempt_approval ON shift_swap_attempt USING btree (managerapproval);


--
-- Name: shift_swap_attempt_del; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX shift_swap_attempt_del ON shift_swap_attempt USING btree (deleted);


--
-- Name: shift_swap_attempt_swap_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX shift_swap_attempt_swap_id ON shift_swap_attempt USING btree (shift_swap_id);


--
-- Name: shift_swap_del; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX shift_swap_del ON shift_swap USING btree (deleted);


--
-- Name: shift_swap_loc; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX shift_swap_loc ON shift_swap USING btree (location_id);


--
-- Name: tcat_session_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX tcat_session_idx ON tomcat_sessions USING btree (id);


--
-- Name: te_emp_id_idx; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX te_emp_id_idx ON telink USING btree (employee_id);


--
-- Name: template_loc_id_idx; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX template_loc_id_idx ON template USING btree (location_id);


--
-- Name: text_datecreated_idx; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX text_datecreated_idx ON textmessage USING btree (date_created);


--
-- Name: textmessage_location_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX textmessage_location_id ON textmessage USING btree (location_id);


--
-- Name: textmessage_who; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX textmessage_who ON textmessage USING btree (who_id);


--
-- Name: timeblock_date_published; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX timeblock_date_published ON timeblock USING btree (date_published);


--
-- Name: timeblock_deleted; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX timeblock_deleted ON timeblock USING btree (deleted);


--
-- Name: timeblock_deletedflag; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX timeblock_deletedflag ON timeblock USING btree (deleted_flag);


--
-- Name: timeblock_employee_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX timeblock_employee_id ON timeblock USING btree (employee_id);


--
-- Name: timeblock_end_date; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX timeblock_end_date ON timeblock USING btree (end_date);


--
-- Name: timeblock_location; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX timeblock_location ON timeblock USING btree (location_id);


--
-- Name: timeblock_position; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX timeblock_position ON timeblock USING btree (position_id);


--
-- Name: timeblock_schedule; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX timeblock_schedule ON timeblock USING btree (schedule_id);


--
-- Name: timeblock_start_date; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX timeblock_start_date ON timeblock USING btree (start_date);


--
-- Name: timeblock_starttime; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX timeblock_starttime ON timeblock USING btree (start_time);


--
-- Name: user_corporation_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX user_corporation_id ON app_user USING btree (corporation_id);


--
-- Name: user_loc_del; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX user_loc_del ON user_location USING btree (deleted);


--
-- Name: user_loc_loc_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX user_loc_loc_id ON user_location USING btree (location_id) WHERE (deleted = 'N'::bpchar);


--
-- Name: user_loc_term_date; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX user_loc_term_date ON user_location USING btree (termination_date);


--
-- Name: user_loc_user_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX user_loc_user_id ON user_location USING btree (user_id) WHERE (deleted = 'N'::bpchar);


--
-- Name: user_role_user_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX user_role_user_id ON user_role USING btree (user_id);


--
-- Name: user_textmessage_textmsg_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX user_textmessage_textmsg_id ON user_textmessage USING btree (textmessage_id);


--
-- Name: user_textmessage_user_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX user_textmessage_user_id ON user_textmessage USING btree (user_id);


--
-- Name: user_textmessage_viewed; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX user_textmessage_viewed ON user_textmessage USING btree (viewedmessage);


--
-- Name: weather_data_weather_id; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX weather_data_weather_id ON weather_data USING btree (weather_id);


--
-- Name: weather_zip_idx; Type: INDEX; Schema: public; Owner: ressystems; Tablespace: 
--

CREATE INDEX weather_zip_idx ON weather USING btree (zip_code);


--
-- Name: ajdfklsjdkfdddljsadklfdj; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY location_flag
    ADD CONSTRAINT ajdfklsjdkfdddljsadklfdj FOREIGN KEY (parent_id) REFERENCES location_flag(id);


--
-- Name: ajdfklsjdkfljsadklfdj; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY location_flag
    ADD CONSTRAINT ajdfklsjdkfljsadklfdj FOREIGN KEY (flag_id) REFERENCES flag(id);


--
-- Name: ajdfklsjdkfljsadklfj; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY location_flag
    ADD CONSTRAINT ajdfklsjdkfljsadklfj FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: applicant_current_position_tracking_step_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY applicant
    ADD CONSTRAINT applicant_current_position_tracking_step_id_fkey FOREIGN KEY (current_position_tracking_step_id) REFERENCES position_tracking_step(id);


--
-- Name: applicant_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY applicant
    ADD CONSTRAINT applicant_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: applicant_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY applicant
    ADD CONSTRAINT applicant_position_id_fkey FOREIGN KEY (position_id) REFERENCES "position"(id);


--
-- Name: attendance_block_active_attendance_break_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attendance_block
    ADD CONSTRAINT attendance_block_active_attendance_break_id_fkey FOREIGN KEY (active_attendance_break_id) REFERENCES attendance_break(id);


--
-- Name: attendance_block_approving_manager_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attendance_block
    ADD CONSTRAINT attendance_block_approving_manager_fkey FOREIGN KEY (approving_manager) REFERENCES app_user(id);


--
-- Name: attendance_block_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attendance_block
    ADD CONSTRAINT attendance_block_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES app_user(id);


--
-- Name: attendance_block_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attendance_block
    ADD CONSTRAINT attendance_block_department_id_fkey FOREIGN KEY (department_id) REFERENCES department(id);


--
-- Name: attendance_block_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attendance_block
    ADD CONSTRAINT attendance_block_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES employee(id);


--
-- Name: attendance_block_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attendance_block
    ADD CONSTRAINT attendance_block_event_id_fkey FOREIGN KEY (event_id) REFERENCES event(id);


--
-- Name: attendance_block_final_approving_manager_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attendance_block
    ADD CONSTRAINT attendance_block_final_approving_manager_fkey FOREIGN KEY (final_approving_manager) REFERENCES app_user(id);


--
-- Name: attendance_block_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attendance_block
    ADD CONSTRAINT attendance_block_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: attendance_block_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attendance_block
    ADD CONSTRAINT attendance_block_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES attendance_block(id);


--
-- Name: attendance_block_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attendance_block
    ADD CONSTRAINT attendance_block_position_id_fkey FOREIGN KEY (position_id) REFERENCES "position"(id);


--
-- Name: attendance_block_timeblock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attendance_block
    ADD CONSTRAINT attendance_block_timeblock_id_fkey FOREIGN KEY (timeblock_id) REFERENCES timeblock(id);


--
-- Name: break_rule_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY break_rule
    ADD CONSTRAINT break_rule_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: break_rule_minor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY break_rule
    ADD CONSTRAINT break_rule_minor_id_fkey FOREIGN KEY (minor_id) REFERENCES minor(id);


--
-- Name: break_rule_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY break_rule
    ADD CONSTRAINT break_rule_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES break_rule(id);


--
-- Name: break_rule_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY break_rule
    ADD CONSTRAINT break_rule_position_id_fkey FOREIGN KEY (position_id) REFERENCES "position"(id);


--
-- Name: break_time_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY break_time
    ADD CONSTRAINT break_time_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: break_time_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY break_time
    ADD CONSTRAINT break_time_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES break_time(id);


--
-- Name: break_time_timeblock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY break_time
    ADD CONSTRAINT break_time_timeblock_id_fkey FOREIGN KEY (timeblock_id) REFERENCES timeblock(id);


--
-- Name: corporation_default_sales_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY corporation
    ADD CONSTRAINT corporation_default_sales_type_fkey FOREIGN KEY (default_sales_type) REFERENCES sales_type(id);


--
-- Name: corporation_price_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY corporation
    ADD CONSTRAINT corporation_price_id_fkey FOREIGN KEY (price_id) REFERENCES price_object(id);


--
-- Name: corporation_reseller_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY corporation
    ADD CONSTRAINT corporation_reseller_id_fkey FOREIGN KEY (reseller_id) REFERENCES reseller(id);


--
-- Name: date_etl_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY date_etl
    ADD CONSTRAINT date_etl_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES date_etl(id);


--
-- Name: department_corporation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY department
    ADD CONSTRAINT department_corporation_id_fkey FOREIGN KEY (corporation_id) REFERENCES corporation(id);


--
-- Name: department_department_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY department
    ADD CONSTRAINT department_department_parent_id_fkey FOREIGN KEY (department_parent_id) REFERENCES department(id);


--
-- Name: department_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY department
    ADD CONSTRAINT department_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES department(id);


--
-- Name: department_sales_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY department
    ADD CONSTRAINT department_sales_type_id_fkey FOREIGN KEY (sales_type_id) REFERENCES sales_type(id);


--
-- Name: document_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY document
    ADD CONSTRAINT document_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES document(id);


--
-- Name: employee_accrual_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee_accrual
    ADD CONSTRAINT employee_accrual_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES employee(id);


--
-- Name: employee_accrual_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee_accrual
    ADD CONSTRAINT employee_accrual_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: employee_accrual_pto_accrual_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee_accrual
    ADD CONSTRAINT employee_accrual_pto_accrual_id_fkey FOREIGN KEY (pto_accrual_id) REFERENCES pto_accrual(id);


--
-- Name: employee_active_attendance_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee
    ADD CONSTRAINT employee_active_attendance_block_fkey FOREIGN KEY (active_attendance_block) REFERENCES attendance_block(id);


--
-- Name: employee_certification_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee_certification
    ADD CONSTRAINT employee_certification_document_id_fkey FOREIGN KEY (document_id) REFERENCES document(id);


--
-- Name: employee_current_location_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee
    ADD CONSTRAINT employee_current_location_fkey FOREIGN KEY (current_location) REFERENCES location(id);


--
-- Name: employee_home_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee
    ADD CONSTRAINT employee_home_department_id_fkey FOREIGN KEY (home_department_id) REFERENCES department(id);


--
-- Name: employee_home_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee
    ADD CONSTRAINT employee_home_location_id_fkey FOREIGN KEY (home_location_id) REFERENCES location(id);


--
-- Name: employee_large_pic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee
    ADD CONSTRAINT employee_large_pic_id_fkey FOREIGN KEY (large_pic_id) REFERENCES document(id);


--
-- Name: employee_medium_pic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee
    ADD CONSTRAINT employee_medium_pic_id_fkey FOREIGN KEY (medium_pic_id) REFERENCES document(id);


--
-- Name: employee_sensoralert_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee_sensoralert
    ADD CONSTRAINT employee_sensoralert_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES employee(id);


--
-- Name: employee_sensoralert_sensor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee_sensoralert
    ADD CONSTRAINT employee_sensoralert_sensor_id_fkey FOREIGN KEY (sensor_id) REFERENCES sensor(id);


--
-- Name: employee_small_pic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee
    ADD CONSTRAINT employee_small_pic_id_fkey FOREIGN KEY (small_pic_id) REFERENCES document(id);


--
-- Name: fk11690c296b501bd9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attendance_break
    ADD CONSTRAINT fk11690c296b501bd9 FOREIGN KEY (parent_id) REFERENCES attendance_break(id);


--
-- Name: fk11690c29ce50f6ac; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attendance_break
    ADD CONSTRAINT fk11690c29ce50f6ac FOREIGN KEY (break_time_id) REFERENCES break_time(id);


--
-- Name: fk11690c29d32da13a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attendance_break
    ADD CONSTRAINT fk11690c29d32da13a FOREIGN KEY (attendance_block_id) REFERENCES attendance_block(id);


--
-- Name: fk11690c29dd790847; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attendance_break
    ADD CONSTRAINT fk11690c29dd790847 FOREIGN KEY (user_id) REFERENCES app_user(id);


--
-- Name: fk143bf46a384e4467; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY user_role
    ADD CONSTRAINT fk143bf46a384e4467 FOREIGN KEY (role_id) REFERENCES role(id);


--
-- Name: fk143bf46add790847; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY user_role
    ADD CONSTRAINT fk143bf46add790847 FOREIGN KEY (user_id) REFERENCES app_user(id);


--
-- Name: fk195d40b169d73bad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tplink_skillset
    ADD CONSTRAINT fk195d40b169d73bad FOREIGN KEY (skillset_id) REFERENCES certification(id);


--
-- Name: fk195d40b1f22d8ea7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tplink_skillset
    ADD CONSTRAINT fk195d40b1f22d8ea7 FOREIGN KEY (parent_id) REFERENCES tplink_skillset(id);


--
-- Name: fk195d40b1f786e127; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tplink_skillset
    ADD CONSTRAINT fk195d40b1f786e127 FOREIGN KEY (tplink_id) REFERENCES tplink(id);


--
-- Name: fk1e8d34e893f41bb8; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY questionnarie_answer
    ADD CONSTRAINT fk1e8d34e893f41bb8 FOREIGN KEY (questionnarie_question_id) REFERENCES questionnarie_question(id);


--
-- Name: fk1e8d34e89e295dfa; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY questionnarie_answer
    ADD CONSTRAINT fk1e8d34e89e295dfa FOREIGN KEY (parent_id) REFERENCES questionnarie_answer(id);


--
-- Name: fk1e8d34e8ba3fc82d; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY questionnarie_answer
    ADD CONSTRAINT fk1e8d34e8ba3fc82d FOREIGN KEY (applicant_id) REFERENCES applicant(id);


--
-- Name: fk25629e038750c46; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY timeblock
    ADD CONSTRAINT fk25629e038750c46 FOREIGN KEY (creator_id) REFERENCES app_user(id);


--
-- Name: fk25629e03d21a507; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY timeblock
    ADD CONSTRAINT fk25629e03d21a507 FOREIGN KEY (position_id) REFERENCES "position"(id);


--
-- Name: fk25629e0777cd876; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY timeblock
    ADD CONSTRAINT fk25629e0777cd876 FOREIGN KEY (publisher_id) REFERENCES app_user(id);


--
-- Name: fk25629e07b3fb843; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY timeblock
    ADD CONSTRAINT fk25629e07b3fb843 FOREIGN KEY (parent_id) REFERENCES timeblock(id);


--
-- Name: fk25629e0965efae7; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY timeblock
    ADD CONSTRAINT fk25629e0965efae7 FOREIGN KEY (employee_id) REFERENCES employee(id);


--
-- Name: fk25629e0aafb8987; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY timeblock
    ADD CONSTRAINT fk25629e0aafb8987 FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: fk25629e0cdcf6887; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY timeblock
    ADD CONSTRAINT fk25629e0cdcf6887 FOREIGN KEY (preference_id) REFERENCES preference(id);


--
-- Name: fk25629e0f786e127; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY timeblock
    ADD CONSTRAINT fk25629e0f786e127 FOREIGN KEY (tplink_id) REFERENCES tplink(id);


--
-- Name: fk25629e0f9a50647; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY timeblock
    ADD CONSTRAINT fk25629e0f9a50647 FOREIGN KEY (schedule_id) REFERENCES schedule(id);


--
-- Name: fk2c1f3eb020cd4347; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY timeblock_snap_shot
    ADD CONSTRAINT fk2c1f3eb020cd4347 FOREIGN KEY (parent_id) REFERENCES timeblock_snap_shot(id);


--
-- Name: fk2c1f3eb026c113ad; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY timeblock_snap_shot
    ADD CONSTRAINT fk2c1f3eb026c113ad FOREIGN KEY (station_id) REFERENCES station(id);


--
-- Name: fk2c1f3eb02ab9da3b; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY timeblock_snap_shot
    ADD CONSTRAINT fk2c1f3eb02ab9da3b FOREIGN KEY (schedule_snap_shot_id) REFERENCES schedule_snap_shot(id);


--
-- Name: fk2c1f3eb03d21a507; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY timeblock_snap_shot
    ADD CONSTRAINT fk2c1f3eb03d21a507 FOREIGN KEY (position_id) REFERENCES "position"(id);


--
-- Name: fk2c1f3eb0965efae7; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY timeblock_snap_shot
    ADD CONSTRAINT fk2c1f3eb0965efae7 FOREIGN KEY (employee_id) REFERENCES employee(id);


--
-- Name: fk2c1f3eb0aafb8987; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY timeblock_snap_shot
    ADD CONSTRAINT fk2c1f3eb0aafb8987 FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: fk2c1f3eb0f9a50647; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY timeblock_snap_shot
    ADD CONSTRAINT fk2c1f3eb0f9a50647 FOREIGN KEY (schedule_id) REFERENCES schedule(id);


--
-- Name: fk2c929929aafb8987; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY "position"
    ADD CONSTRAINT fk2c929929aafb8987 FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: fk2c929929c0b979e6; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY "position"
    ADD CONSTRAINT fk2c929929c0b979e6 FOREIGN KEY (parent_id) REFERENCES "position"(id);


--
-- Name: fk31dc4e91e34f2af; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee_certification
    ADD CONSTRAINT fk31dc4e91e34f2af FOREIGN KEY (parent_id) REFERENCES employee_certification(id);


--
-- Name: fk31dc4e969d73bad; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee_certification
    ADD CONSTRAINT fk31dc4e969d73bad FOREIGN KEY (certification_id) REFERENCES certification(id);


--
-- Name: fk31dc4e9965efae7; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee_certification
    ADD CONSTRAINT fk31dc4e9965efae7 FOREIGN KEY (employee_id) REFERENCES employee(id);


--
-- Name: fk3832c9bd3d21a507; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY shift_builder_rule
    ADD CONSTRAINT fk3832c9bd3d21a507 FOREIGN KEY (position_id) REFERENCES "position"(id);


--
-- Name: fk3832c9bdaafb8987; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY shift_builder_rule
    ADD CONSTRAINT fk3832c9bdaafb8987 FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: fk3832c9bdae850f12; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY shift_builder_rule
    ADD CONSTRAINT fk3832c9bdae850f12 FOREIGN KEY (parent_id) REFERENCES shift_builder_rule(id);


--
-- Name: fk383fae994b6a41ad; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY security_template
    ADD CONSTRAINT fk383fae994b6a41ad FOREIGN KEY (corporation_id) REFERENCES corporation(id);


--
-- Name: fk383fae99c43f0b97; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY security_template
    ADD CONSTRAINT fk383fae99c43f0b97 FOREIGN KEY (parent_id) REFERENCES security_template(id);


--
-- Name: fk3aaa177b355adbb7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY timeblock_event
    ADD CONSTRAINT fk3aaa177b355adbb7 FOREIGN KEY (parent_id) REFERENCES timeblock_event(id);


--
-- Name: fk3aaa177be8cd834d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY timeblock_event
    ADD CONSTRAINT fk3aaa177be8cd834d FOREIGN KEY (timeblock_id) REFERENCES timeblock(id);


--
-- Name: fk3aaa177bf138d2ad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY timeblock_event
    ADD CONSTRAINT fk3aaa177bf138d2ad FOREIGN KEY (event_id) REFERENCES event(id);


--
-- Name: fk3e39bed6aafb8987; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY positiongroup
    ADD CONSTRAINT fk3e39bed6aafb8987 FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: fk3e39bed6e1122bd9; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY positiongroup
    ADD CONSTRAINT fk3e39bed6e1122bd9 FOREIGN KEY (parent_id) REFERENCES positiongroup(id);


--
-- Name: fk459c57294b6a41ad; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY app_user
    ADD CONSTRAINT fk459c57294b6a41ad FOREIGN KEY (corporation_id) REFERENCES corporation(id);


--
-- Name: fk459c572961a4cb08; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY app_user
    ADD CONSTRAINT fk459c572961a4cb08 FOREIGN KEY (parent_id) REFERENCES app_user(id);


--
-- Name: fk46e3a7f03d21a507; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY timeblock_skillset
    ADD CONSTRAINT fk46e3a7f03d21a507 FOREIGN KEY (position_id) REFERENCES "position"(id);


--
-- Name: fk46e3a7f08f947dd4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY timeblock_skillset
    ADD CONSTRAINT fk46e3a7f08f947dd4 FOREIGN KEY (parent_id) REFERENCES timeblock_skillset(id);


--
-- Name: fk46e3a7f0bca9dc96; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY timeblock_skillset
    ADD CONSTRAINT fk46e3a7f0bca9dc96 FOREIGN KEY (skillset_id) REFERENCES certification(id);


--
-- Name: fk46e3a7f0e8cd834d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY timeblock_skillset
    ADD CONSTRAINT fk46e3a7f0e8cd834d FOREIGN KEY (timeblock_id) REFERENCES timeblock(id);


--
-- Name: fk46f04725398eb48; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY user_security_template
    ADD CONSTRAINT fk46f04725398eb48 FOREIGN KEY (security_template_id) REFERENCES security_template(id);


--
-- Name: fk46f04725dd790847; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY user_security_template
    ADD CONSTRAINT fk46f04725dd790847 FOREIGN KEY (user_id) REFERENCES app_user(id);


--
-- Name: fk46f04725f57a0702; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY user_security_template
    ADD CONSTRAINT fk46f04725f57a0702 FOREIGN KEY (parent_id) REFERENCES user_security_template(id);


--
-- Name: fk4722e6aedb49c76b; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee
    ADD CONSTRAINT fk4722e6aedb49c76b FOREIGN KEY (parent_id) REFERENCES employee(id);


--
-- Name: fk4722e6aedd790847; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee
    ADD CONSTRAINT fk4722e6aedd790847 FOREIGN KEY (user_id) REFERENCES app_user(id);


--
-- Name: fk4a4f0dbf1eecac05; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee_setting
    ADD CONSTRAINT fk4a4f0dbf1eecac05 FOREIGN KEY (parent_id) REFERENCES employee_setting(id);


--
-- Name: fk4a4f0dbf965efae7; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee_setting
    ADD CONSTRAINT fk4a4f0dbf965efae7 FOREIGN KEY (employee_id) REFERENCES employee(id);


--
-- Name: fk4a4f0dbfe5a0d791; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee_setting
    ADD CONSTRAINT fk4a4f0dbfe5a0d791 FOREIGN KEY (flag_id) REFERENCES setting(id);


--
-- Name: fk5aa68c2baafb8987; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY blackout_preference
    ADD CONSTRAINT fk5aa68c2baafb8987 FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: fk5aa68c2be67641a7; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY blackout_preference
    ADD CONSTRAINT fk5aa68c2be67641a7 FOREIGN KEY (parent_id) REFERENCES blackout_preference(id);


--
-- Name: fk5c6729a5c0bc29d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY event
    ADD CONSTRAINT fk5c6729a5c0bc29d FOREIGN KEY (parent_id) REFERENCES event(id);


--
-- Name: fk5c6729aaafb8987; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY event
    ADD CONSTRAINT fk5c6729aaafb8987 FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: fk6566245b16fad9c1; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY pto_accrual
    ADD CONSTRAINT fk6566245b16fad9c1 FOREIGN KEY (parent_id) REFERENCES pto_accrual(id);


--
-- Name: fk6566245b42aed7ba; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY pto_accrual
    ADD CONSTRAINT fk6566245b42aed7ba FOREIGN KEY (position_code_id) REFERENCES position_code(id);


--
-- Name: fk6566245b4b6a41ad; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY pto_accrual
    ADD CONSTRAINT fk6566245b4b6a41ad FOREIGN KEY (corporation_id) REFERENCES corporation(id);


--
-- Name: fk6566245b55fcddbe; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY pto_accrual
    ADD CONSTRAINT fk6566245b55fcddbe FOREIGN KEY (preference_type_id) REFERENCES preference_type(id);


--
-- Name: fk6566245b965efae7; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY pto_accrual
    ADD CONSTRAINT fk6566245b965efae7 FOREIGN KEY (employee_id) REFERENCES employee(id);


--
-- Name: fk666ec68d4b6a41ad; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY sales_type
    ADD CONSTRAINT fk666ec68d4b6a41ad FOREIGN KEY (corporation_id) REFERENCES corporation(id);


--
-- Name: fk666ec68d75b364e9; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY sales_type
    ADD CONSTRAINT fk666ec68d75b364e9 FOREIGN KEY (parent_id) REFERENCES sales_type(id);


--
-- Name: fk714f9fb538750c46; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY location
    ADD CONSTRAINT fk714f9fb538750c46 FOREIGN KEY (creator_id) REFERENCES app_user(id);


--
-- Name: fk714f9fb54b6a41ad; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY location
    ADD CONSTRAINT fk714f9fb54b6a41ad FOREIGN KEY (corporation_id) REFERENCES corporation(id);


--
-- Name: fk714f9fb55768072; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY location
    ADD CONSTRAINT fk714f9fb55768072 FOREIGN KEY (parent_id) REFERENCES location(id);


--
-- Name: fk7452f9a9aafb8987; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY user_location
    ADD CONSTRAINT fk7452f9a9aafb8987 FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: fk7452f9a9dd790847; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY user_location
    ADD CONSTRAINT fk7452f9a9dd790847 FOREIGN KEY (user_id) REFERENCES app_user(id);


--
-- Name: fk74d6432d4b6a41ad; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY invoice
    ADD CONSTRAINT fk74d6432d4b6a41ad FOREIGN KEY (corporation_id) REFERENCES corporation(id);


--
-- Name: fk774b237642aed7ba; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY department_position
    ADD CONSTRAINT fk774b237642aed7ba FOREIGN KEY (position_code_id) REFERENCES position_code(id);


--
-- Name: fk774b2376554fc127; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY department_position
    ADD CONSTRAINT fk774b2376554fc127 FOREIGN KEY (department_id) REFERENCES department(id);


--
-- Name: fk774b2376d4a56b18; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY department_position
    ADD CONSTRAINT fk774b2376d4a56b18 FOREIGN KEY (parent_id) REFERENCES department_position(id);


--
-- Name: fk77883f4e4b6a41ad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY position_filter
    ADD CONSTRAINT fk77883f4e4b6a41ad FOREIGN KEY (corporation_id) REFERENCES corporation(id);


--
-- Name: fk77883f4e554fc127; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY position_filter
    ADD CONSTRAINT fk77883f4e554fc127 FOREIGN KEY (department_id) REFERENCES department(id);


--
-- Name: fk77883f4ec8f588fe; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY position_filter
    ADD CONSTRAINT fk77883f4ec8f588fe FOREIGN KEY (parent_id) REFERENCES position_filter(id);


--
-- Name: fk80bcf09c3d21a507; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY forecast_timeblock
    ADD CONSTRAINT fk80bcf09c3d21a507 FOREIGN KEY (position_id) REFERENCES "position"(id);


--
-- Name: fk80bcf09c554fc127; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY forecast_timeblock
    ADD CONSTRAINT fk80bcf09c554fc127 FOREIGN KEY (department_id) REFERENCES department(id);


--
-- Name: fk80bcf09c965efae7; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY forecast_timeblock
    ADD CONSTRAINT fk80bcf09c965efae7 FOREIGN KEY (employee_id) REFERENCES employee(id);


--
-- Name: fk80bcf09caafb8987; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY forecast_timeblock
    ADD CONSTRAINT fk80bcf09caafb8987 FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: fk836d1f02fe199d85; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY applicant
    ADD CONSTRAINT fk836d1f02fe199d85 FOREIGN KEY (parent_id) REFERENCES applicant(id);


--
-- Name: fk84496ea72f61b826; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY schedule_snap_shot
    ADD CONSTRAINT fk84496ea72f61b826 FOREIGN KEY (sales_type_id) REFERENCES sales_type(id);


--
-- Name: fk84496ea748bb5d58; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY schedule_snap_shot
    ADD CONSTRAINT fk84496ea748bb5d58 FOREIGN KEY (parent_id) REFERENCES schedule_snap_shot(id);


--
-- Name: fk84496ea7554fc127; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY schedule_snap_shot
    ADD CONSTRAINT fk84496ea7554fc127 FOREIGN KEY (department_id) REFERENCES department(id);


--
-- Name: fk84496ea7aafb8987; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY schedule_snap_shot
    ADD CONSTRAINT fk84496ea7aafb8987 FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: fk84496ea7f9a50647; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY schedule_snap_shot
    ADD CONSTRAINT fk84496ea7f9a50647 FOREIGN KEY (schedule_id) REFERENCES schedule(id);


--
-- Name: fk84a4eabe3d21a507; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY position_tracking_step
    ADD CONSTRAINT fk84a4eabe3d21a507 FOREIGN KEY (position_id) REFERENCES "position"(id);


--
-- Name: fk84a4eabe4e974329; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY position_tracking_step
    ADD CONSTRAINT fk84a4eabe4e974329 FOREIGN KEY (parent_id) REFERENCES position_tracking_step(id);


--
-- Name: fk885c8e9074e311cd; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY questionnarie_question
    ADD CONSTRAINT fk885c8e9074e311cd FOREIGN KEY (questionnarie_id) REFERENCES questionnarie(id);


--
-- Name: fk885c8e908467335e; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY questionnarie_question
    ADD CONSTRAINT fk885c8e908467335e FOREIGN KEY (parent_id) REFERENCES questionnarie_question(id);


--
-- Name: fk8dc4e51e62628364; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee_accrual
    ADD CONSTRAINT fk8dc4e51e62628364 FOREIGN KEY (parent_id) REFERENCES employee_accrual(id);


--
-- Name: fk8f7843d1384e4467; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY security_template_rules
    ADD CONSTRAINT fk8f7843d1384e4467 FOREIGN KEY (role_id) REFERENCES role(id);


--
-- Name: fk8f7843d1398eb48; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY security_template_rules
    ADD CONSTRAINT fk8f7843d1398eb48 FOREIGN KEY (security_template_id) REFERENCES security_template(id);


--
-- Name: fk8f7843d1e6055340; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY security_template_rules
    ADD CONSTRAINT fk8f7843d1e6055340 FOREIGN KEY (parent_id) REFERENCES security_template_rules(id);


--
-- Name: fk91db70fb554fc127; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY department_employee
    ADD CONSTRAINT fk91db70fb554fc127 FOREIGN KEY (department_id) REFERENCES department(id);


--
-- Name: fk91db70fb965efae7; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY department_employee
    ADD CONSTRAINT fk91db70fb965efae7 FOREIGN KEY (employee_id) REFERENCES employee(id);


--
-- Name: fk91db70fbef35b89d; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY department_employee
    ADD CONSTRAINT fk91db70fbef35b89d FOREIGN KEY (parent_id) REFERENCES department_employee(id);


--
-- Name: fka2b3db0554fc127; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY department_roll_up
    ADD CONSTRAINT fka2b3db0554fc127 FOREIGN KEY (department_id) REFERENCES department(id);


--
-- Name: fka2b3db069351734; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY department_roll_up
    ADD CONSTRAINT fka2b3db069351734 FOREIGN KEY (sales_department_id) REFERENCES department(id);


--
-- Name: fka2b3db0fd6deda7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY department_roll_up
    ADD CONSTRAINT fka2b3db0fd6deda7 FOREIGN KEY (parent_id) REFERENCES department_roll_up(id);


--
-- Name: fka71e5b1221cad995; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY commision
    ADD CONSTRAINT fka71e5b1221cad995 FOREIGN KEY (parent_id) REFERENCES commision(id);


--
-- Name: fka71e5b1258719467; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY commision
    ADD CONSTRAINT fka71e5b1258719467 FOREIGN KEY (reseller_id) REFERENCES reseller(id);


--
-- Name: fka832bef62d5f100; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY questionnarie_question_options
    ADD CONSTRAINT fka832bef62d5f100 FOREIGN KEY (parent_id) REFERENCES questionnarie_question_options(id);


--
-- Name: fka832bef93f41bb8; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY questionnarie_question_options
    ADD CONSTRAINT fka832bef93f41bb8 FOREIGN KEY (questionnarie_question_id) REFERENCES questionnarie_question(id);


--
-- Name: fka8fcbcdb38750c46; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY preference
    ADD CONSTRAINT fka8fcbcdb38750c46 FOREIGN KEY (creator_id) REFERENCES app_user(id);


--
-- Name: fka8fcbcdb3d21a507; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY preference
    ADD CONSTRAINT fka8fcbcdb3d21a507 FOREIGN KEY (position_id) REFERENCES "position"(id);


--
-- Name: fka8fcbcdb965efae7; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY preference
    ADD CONSTRAINT fka8fcbcdb965efae7 FOREIGN KEY (employee_id) REFERENCES employee(id);


--
-- Name: fka8fcbcdbaafb8987; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY preference
    ADD CONSTRAINT fka8fcbcdbaafb8987 FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: fka8fcbcdbdd75658; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY preference
    ADD CONSTRAINT fka8fcbcdbdd75658 FOREIGN KEY (parent_id) REFERENCES preference(id);


--
-- Name: fkaa7a0942af7b52e8; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY report_schedule
    ADD CONSTRAINT fkaa7a0942af7b52e8 FOREIGN KEY (parent_id) REFERENCES report_schedule(id);


--
-- Name: fkaa7a0942dd790847; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY report_schedule
    ADD CONSTRAINT fkaa7a0942dd790847 FOREIGN KEY (user_id) REFERENCES app_user(id);


--
-- Name: fkb12fa00838750c46; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY corporation
    ADD CONSTRAINT fkb12fa00838750c46 FOREIGN KEY (creator_id) REFERENCES app_user(id);


--
-- Name: fkb12fa008719f7dcb; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY corporation
    ADD CONSTRAINT fkb12fa008719f7dcb FOREIGN KEY (parent_id) REFERENCES corporation(id);


--
-- Name: fkb13acc7a38750c46; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY template
    ADD CONSTRAINT fkb13acc7a38750c46 FOREIGN KEY (creator_id) REFERENCES app_user(id);


--
-- Name: fkb13acc7a4561ad37; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY template
    ADD CONSTRAINT fkb13acc7a4561ad37 FOREIGN KEY (parent_id) REFERENCES template(id);


--
-- Name: fkb13acc7aaafb8987; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY template
    ADD CONSTRAINT fkb13acc7aaafb8987 FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: fkb75b32483d21a507; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sales_dep_threshold
    ADD CONSTRAINT fkb75b32483d21a507 FOREIGN KEY (position_id) REFERENCES "position"(id);


--
-- Name: fkb75b32485c35617e; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sales_dep_threshold
    ADD CONSTRAINT fkb75b32485c35617e FOREIGN KEY (dep_loc_id) REFERENCES department_location(id);


--
-- Name: fkb75b3248aafb8987; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sales_dep_threshold
    ADD CONSTRAINT fkb75b3248aafb8987 FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: fkb75b3248b47baf4a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sales_dep_threshold
    ADD CONSTRAINT fkb75b3248b47baf4a FOREIGN KEY (parent_id) REFERENCES sales_dep_threshold(id);


--
-- Name: fkb75b3248ddc3c35a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sales_dep_threshold
    ADD CONSTRAINT fkb75b3248ddc3c35a FOREIGN KEY (sales_type_loc_id) REFERENCES sales_type_location(id);


--
-- Name: fkbc082a02196271a4; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY department_location
    ADD CONSTRAINT fkbc082a02196271a4 FOREIGN KEY (parent_id) REFERENCES department_location(id);


--
-- Name: fkbc082a02554fc127; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY department_location
    ADD CONSTRAINT fkbc082a02554fc127 FOREIGN KEY (department_id) REFERENCES department(id);


--
-- Name: fkbc082a02aafb8987; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY department_location
    ADD CONSTRAINT fkbc082a02aafb8987 FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: fkbe9825d64b6a41ad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY logtag
    ADD CONSTRAINT fkbe9825d64b6a41ad FOREIGN KEY (corporation_id) REFERENCES corporation(id);


--
-- Name: fkc3612e5566399b58; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY questionnarie
    ADD CONSTRAINT fkc3612e5566399b58 FOREIGN KEY (parent_id) REFERENCES questionnarie(id);


--
-- Name: fkc41836b655fcddbe; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY preference_type_location
    ADD CONSTRAINT fkc41836b655fcddbe FOREIGN KEY (preference_type_id) REFERENCES preference_type(id);


--
-- Name: fkc41836b6aafb8987; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY preference_type_location
    ADD CONSTRAINT fkc41836b6aafb8987 FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: fkc41836b6c9515787; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY preference_type_location
    ADD CONSTRAINT fkc41836b6c9515787 FOREIGN KEY (parent_id) REFERENCES preference_type_location(id);


--
-- Name: fkc4fcea713d21a507; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY pglink
    ADD CONSTRAINT fkc4fcea713d21a507 FOREIGN KEY (position_id) REFERENCES "position"(id);


--
-- Name: fkc4fcea71a3b9520d; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY pglink
    ADD CONSTRAINT fkc4fcea71a3b9520d FOREIGN KEY (positiongroup_id) REFERENCES positiongroup(id);


--
-- Name: fkc4fcea71bf87666e; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY pglink
    ADD CONSTRAINT fkc4fcea71bf87666e FOREIGN KEY (parent_id) REFERENCES pglink(id);


--
-- Name: fkc5f819272f61b826; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY sales_type_location
    ADD CONSTRAINT fkc5f819272f61b826 FOREIGN KEY (sales_type_id) REFERENCES sales_type(id);


--
-- Name: fkc5f8192777983fbe; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY sales_type_location
    ADD CONSTRAINT fkc5f8192777983fbe FOREIGN KEY (parent_id) REFERENCES sales_type_location(id);


--
-- Name: fkc5f81927aafb8987; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY sales_type_location
    ADD CONSTRAINT fkc5f81927aafb8987 FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: fkc7ec7c8d55fcddbe; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee_preference_type
    ADD CONSTRAINT fkc7ec7c8d55fcddbe FOREIGN KEY (preference_type_id) REFERENCES preference_type(id);


--
-- Name: fkc7ec7c8d965efae7; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee_preference_type
    ADD CONSTRAINT fkc7ec7c8d965efae7 FOREIGN KEY (employee_id) REFERENCES employee(id);


--
-- Name: fkc7ec7c8d9c04300; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee_preference_type
    ADD CONSTRAINT fkc7ec7c8d9c04300 FOREIGN KEY (parent_id) REFERENCES employee_preference_type(id);


--
-- Name: fkcb66069738750c46; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY managerlog_comment
    ADD CONSTRAINT fkcb66069738750c46 FOREIGN KEY (creator_id) REFERENCES app_user(id);


--
-- Name: fkcb66069764e9818b; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY managerlog_comment
    ADD CONSTRAINT fkcb66069764e9818b FOREIGN KEY (parent_id) REFERENCES managerlog_comment(id);


--
-- Name: fkcb66069770dbfae7; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY managerlog_comment
    ADD CONSTRAINT fkcb66069770dbfae7 FOREIGN KEY (managerlog_id) REFERENCES manager_log(id);


--
-- Name: fkcbb41deb33759767; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY telink
    ADD CONSTRAINT fkcbb41deb33759767 FOREIGN KEY (template_id) REFERENCES template(id);


--
-- Name: fkcbb41deb3d21a507; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY telink
    ADD CONSTRAINT fkcbb41deb3d21a507 FOREIGN KEY (position_id) REFERENCES "position"(id);


--
-- Name: fkcbb41deb965efae7; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY telink
    ADD CONSTRAINT fkcbb41deb965efae7 FOREIGN KEY (employee_id) REFERENCES employee(id);


--
-- Name: fkcbb41debc63e99e8; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY telink
    ADD CONSTRAINT fkcbb41debc63e99e8 FOREIGN KEY (parent_id) REFERENCES telink(id);


--
-- Name: fkcc4f207633759767; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY tplink
    ADD CONSTRAINT fkcc4f207633759767 FOREIGN KEY (template_id) REFERENCES template(id);


--
-- Name: fkcc4f20763d21a507; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY tplink
    ADD CONSTRAINT fkcc4f20763d21a507 FOREIGN KEY (position_id) REFERENCES "position"(id);


--
-- Name: fkcc4f2076c6d99c73; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY tplink
    ADD CONSTRAINT fkcc4f2076c6d99c73 FOREIGN KEY (parent_id) REFERENCES tplink(id);


--
-- Name: fkd3aa5b84e074dc0; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY applicant_document
    ADD CONSTRAINT fkd3aa5b84e074dc0 FOREIGN KEY (parent_id) REFERENCES applicant_document(id);


--
-- Name: fkd3aa5b869d73bad; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY applicant_document
    ADD CONSTRAINT fkd3aa5b869d73bad FOREIGN KEY (certification_id) REFERENCES certification(id);


--
-- Name: fkd3aa5b86a5047c7; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY applicant_document
    ADD CONSTRAINT fkd3aa5b86a5047c7 FOREIGN KEY (document_id) REFERENCES document(id);


--
-- Name: fkd3aa5b8ba3fc82d; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY applicant_document
    ADD CONSTRAINT fkd3aa5b8ba3fc82d FOREIGN KEY (applicant_id) REFERENCES applicant(id);


--
-- Name: fkd3d8269e70dbfae7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY managerlog_logtag
    ADD CONSTRAINT fkd3d8269e70dbfae7 FOREIGN KEY (managerlog_id) REFERENCES manager_log(id);


--
-- Name: fkd3d8269eeb296907; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY managerlog_logtag
    ADD CONSTRAINT fkd3d8269eeb296907 FOREIGN KEY (logtag_id) REFERENCES logtag(id);


--
-- Name: fkd53641e42190ab9b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY applicant_historical_step
    ADD CONSTRAINT fkd53641e42190ab9b FOREIGN KEY (parent_id) REFERENCES applicant_historical_step(id);


--
-- Name: fkd53641e4ba3fc82d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY applicant_historical_step
    ADD CONSTRAINT fkd53641e4ba3fc82d FOREIGN KEY (applicant_id) REFERENCES applicant(id);


--
-- Name: fkd53641e4c6c33895; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY applicant_historical_step
    ADD CONSTRAINT fkd53641e4c6c33895 FOREIGN KEY (position_tracking_step_id) REFERENCES position_tracking_step(id);


--
-- Name: fkd66692976a8d7354; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY schedule
    ADD CONSTRAINT fkd66692976a8d7354 FOREIGN KEY (parent_id) REFERENCES schedule(id);


--
-- Name: fkd6669297aafb8987; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY schedule
    ADD CONSTRAINT fkd6669297aafb8987 FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: fkd6a2879a3d21a507; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee_position
    ADD CONSTRAINT fkd6a2879a3d21a507 FOREIGN KEY (position_id) REFERENCES "position"(id);


--
-- Name: fkd6a2879a965efae7; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee_position
    ADD CONSTRAINT fkd6a2879a965efae7 FOREIGN KEY (employee_id) REFERENCES employee(id);


--
-- Name: fkd6a2879aad40eb22; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY employee_position
    ADD CONSTRAINT fkd6a2879aad40eb22 FOREIGN KEY (parent_id) REFERENCES employee_position(id);


--
-- Name: fkd99554ba4b6a41ad; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY certification
    ADD CONSTRAINT fkd99554ba4b6a41ad FOREIGN KEY (corporation_id) REFERENCES corporation(id);


--
-- Name: fkd99554ba7c6dc1bd; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY certification
    ADD CONSTRAINT fkd99554ba7c6dc1bd FOREIGN KEY (parent_id) REFERENCES certification(id);


--
-- Name: fke17803d5311438bd; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY event_certification
    ADD CONSTRAINT fke17803d5311438bd FOREIGN KEY (parent_id) REFERENCES event_certification(id);


--
-- Name: fke17803d569d73bad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY event_certification
    ADD CONSTRAINT fke17803d569d73bad FOREIGN KEY (certification_id) REFERENCES certification(id);


--
-- Name: fke17803d5f138d2ad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY event_certification
    ADD CONSTRAINT fke17803d5f138d2ad FOREIGN KEY (event_id) REFERENCES event(id);


--
-- Name: fke5c9fa9d1ae625f3; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY break_time_snap_shot
    ADD CONSTRAINT fke5c9fa9d1ae625f3 FOREIGN KEY (parent_id) REFERENCES break_time_snap_shot(id);


--
-- Name: fke5c9fa9d2d680781; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY break_time_snap_shot
    ADD CONSTRAINT fke5c9fa9d2d680781 FOREIGN KEY (timeblock_snap_shot_id) REFERENCES timeblock_snap_shot(id);


--
-- Name: fke5c9fa9daafb8987; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY break_time_snap_shot
    ADD CONSTRAINT fke5c9fa9daafb8987 FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: fkeb1aab727f418c2f; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY reseller
    ADD CONSTRAINT fkeb1aab727f418c2f FOREIGN KEY (parent_id) REFERENCES reseller(id);


--
-- Name: fkeb1aab72dd790847; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY reseller
    ADD CONSTRAINT fkeb1aab72dd790847 FOREIGN KEY (user_id) REFERENCES app_user(id);


--
-- Name: fkejdfajsh2233; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY message_log
    ADD CONSTRAINT fkejdfajsh2233 FOREIGN KEY (timeblock_id) REFERENCES timeblock(id);


--
-- Name: fkejdfajsh23; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY message_log
    ADD CONSTRAINT fkejdfajsh23 FOREIGN KEY (employee_id) REFERENCES employee(id);


--
-- Name: fkf2686217554fc127; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY event_department
    ADD CONSTRAINT fkf2686217554fc127 FOREIGN KEY (department_id) REFERENCES department(id);


--
-- Name: fkf26862178cb90751; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY event_department
    ADD CONSTRAINT fkf26862178cb90751 FOREIGN KEY (event_id) REFERENCES event(id);


--
-- Name: fkf2686217a62dc5cf; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY event_department
    ADD CONSTRAINT fkf2686217a62dc5cf FOREIGN KEY (parent_id) REFERENCES event_department(id);


--
-- Name: fkf69a042442aed7ba; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY position_certification
    ADD CONSTRAINT fkf69a042442aed7ba FOREIGN KEY (position_code_id) REFERENCES position_code(id);


--
-- Name: fkf69a042469d73bad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY position_certification
    ADD CONSTRAINT fkf69a042469d73bad FOREIGN KEY (certification_id) REFERENCES certification(id);


--
-- Name: fkf69a042480e66014; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY position_certification
    ADD CONSTRAINT fkf69a042480e66014 FOREIGN KEY (parent_id) REFERENCES position_certification(id);


--
-- Name: fkfb0bc2e22f61b826; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY sales_paf
    ADD CONSTRAINT fkfb0bc2e22f61b826 FOREIGN KEY (sales_type_id) REFERENCES sales_type(id);


--
-- Name: fkfb0bc2e2554fc127; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY sales_paf
    ADD CONSTRAINT fkfb0bc2e2554fc127 FOREIGN KEY (department_id) REFERENCES department(id);


--
-- Name: fkfb0bc2e2aafb8987; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY sales_paf
    ADD CONSTRAINT fkfb0bc2e2aafb8987 FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: fkfb0bc2e2b73c3f74; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY sales_paf
    ADD CONSTRAINT fkfb0bc2e2b73c3f74 FOREIGN KEY (who_id) REFERENCES app_user(id);


--
-- Name: hierarchy_corporation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY hierarchy
    ADD CONSTRAINT hierarchy_corporation_id_fkey FOREIGN KEY (corporation_id) REFERENCES corporation(id);


--
-- Name: hierarchy_parent_hierarchy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY hierarchy
    ADD CONSTRAINT hierarchy_parent_hierarchy_id_fkey FOREIGN KEY (parent_hierarchy_id) REFERENCES hierarchy(id);


--
-- Name: hierarchy_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY hierarchy
    ADD CONSTRAINT hierarchy_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES hierarchy(id);


--
-- Name: hierarchy_responsible_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY hierarchy
    ADD CONSTRAINT hierarchy_responsible_user_id_fkey FOREIGN KEY (responsible_user_id) REFERENCES app_user(id);


--
-- Name: location_hierarchy_hierarchy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY location_hierarchy
    ADD CONSTRAINT location_hierarchy_hierarchy_id_fkey FOREIGN KEY (hierarchy_id) REFERENCES hierarchy(id);


--
-- Name: location_hierarchy_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY location_hierarchy
    ADD CONSTRAINT location_hierarchy_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: location_hierarchy_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY location_hierarchy
    ADD CONSTRAINT location_hierarchy_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES location_hierarchy(id);


--
-- Name: manager_log_category_corporation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY manager_log_category
    ADD CONSTRAINT manager_log_category_corporation_id_fkey FOREIGN KEY (corporation_id) REFERENCES corporation(id);


--
-- Name: manager_log_category_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY manager_log_category
    ADD CONSTRAINT manager_log_category_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES manager_log_category(id);


--
-- Name: manager_log_category_parent_manager_log_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY manager_log_category
    ADD CONSTRAINT manager_log_category_parent_manager_log_category_id_fkey FOREIGN KEY (parent_manager_log_category_id) REFERENCES manager_log_category(id);


--
-- Name: manager_log_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY manager_log
    ADD CONSTRAINT manager_log_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES app_user(id);


--
-- Name: manager_log_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY manager_log
    ADD CONSTRAINT manager_log_document_id_fkey FOREIGN KEY (document_id) REFERENCES document(id);


--
-- Name: manager_log_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY manager_log
    ADD CONSTRAINT manager_log_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES employee(id);


--
-- Name: manager_log_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY manager_log
    ADD CONSTRAINT manager_log_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: manager_log_manager_log_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY manager_log
    ADD CONSTRAINT manager_log_manager_log_category_id_fkey FOREIGN KEY (manager_log_category_id) REFERENCES manager_log_category(id);


--
-- Name: manager_log_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY manager_log
    ADD CONSTRAINT manager_log_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES manager_log(id);


--
-- Name: message_log_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY message_log
    ADD CONSTRAINT message_log_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: minor_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY minor
    ADD CONSTRAINT minor_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: minor_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY minor
    ADD CONSTRAINT minor_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES minor(id);


--
-- Name: minor_preference_minor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY minor_preference
    ADD CONSTRAINT minor_preference_minor_id_fkey FOREIGN KEY (minor_id) REFERENCES minor(id);


--
-- Name: minor_preference_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY minor_preference
    ADD CONSTRAINT minor_preference_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES minor_preference(id);


--
-- Name: minor_preference_preference_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY minor_preference
    ADD CONSTRAINT minor_preference_preference_id_fkey FOREIGN KEY (preference_id) REFERENCES preference(id);


--
-- Name: multi_level_pay_rate_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY multi_level_pay_rate
    ADD CONSTRAINT multi_level_pay_rate_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: multi_level_pay_rate_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY multi_level_pay_rate
    ADD CONSTRAINT multi_level_pay_rate_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES multi_level_pay_rate(id);


--
-- Name: multi_level_pay_rate_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY multi_level_pay_rate
    ADD CONSTRAINT multi_level_pay_rate_position_id_fkey FOREIGN KEY (position_id) REFERENCES "position"(id);


--
-- Name: payment_log_corporation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY payment_log
    ADD CONSTRAINT payment_log_corporation_id_fkey FOREIGN KEY (corporation_id) REFERENCES corporation(id);


--
-- Name: payment_log_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY payment_log
    ADD CONSTRAINT payment_log_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES payment_log(id);


--
-- Name: position_certification_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY position_certification
    ADD CONSTRAINT position_certification_document_id_fkey FOREIGN KEY (document_id) REFERENCES document(id);


--
-- Name: position_code_corporation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY position_code
    ADD CONSTRAINT position_code_corporation_id_fkey FOREIGN KEY (corporation_id) REFERENCES corporation(id);


--
-- Name: position_code_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY position_code
    ADD CONSTRAINT position_code_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES position_code(id);


--
-- Name: position_code_sales_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY position_code
    ADD CONSTRAINT position_code_sales_type_id_fkey FOREIGN KEY (sales_type_id) REFERENCES sales_type(id);


--
-- Name: position_position_code_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY "position"
    ADD CONSTRAINT position_position_code_id_fkey FOREIGN KEY (position_code_id) REFERENCES position_code(id);


--
-- Name: position_questionnarie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY "position"
    ADD CONSTRAINT position_questionnarie_id_fkey FOREIGN KEY (questionnarie_id) REFERENCES questionnarie(id);


--
-- Name: preference_conflict_etl_conflict_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY preference_conflict_etl
    ADD CONSTRAINT preference_conflict_etl_conflict_id_fkey FOREIGN KEY (conflict_id) REFERENCES preference(id);


--
-- Name: preference_conflict_etl_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY preference_conflict_etl
    ADD CONSTRAINT preference_conflict_etl_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES preference_conflict_etl(id);


--
-- Name: preference_conflict_etl_preference_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY preference_conflict_etl
    ADD CONSTRAINT preference_conflict_etl_preference_id_fkey FOREIGN KEY (preference_id) REFERENCES preference(id);


--
-- Name: preference_date_etl_date_etl_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY preference_date_etl
    ADD CONSTRAINT preference_date_etl_date_etl_id_fkey FOREIGN KEY (date_etl_id) REFERENCES date_etl(id);


--
-- Name: preference_date_etl_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY preference_date_etl
    ADD CONSTRAINT preference_date_etl_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES preference_date_etl(id);


--
-- Name: preference_date_etl_preference_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY preference_date_etl
    ADD CONSTRAINT preference_date_etl_preference_id_fkey FOREIGN KEY (preference_id) REFERENCES preference(id);


--
-- Name: preference_preference_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY preference
    ADD CONSTRAINT preference_preference_type_id_fkey FOREIGN KEY (preference_type_id) REFERENCES preference_type(id);


--
-- Name: preference_type_corporation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY preference_type
    ADD CONSTRAINT preference_type_corporation_id_fkey FOREIGN KEY (corporation_id) REFERENCES corporation(id);


--
-- Name: preference_type_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY preference_type
    ADD CONSTRAINT preference_type_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES preference_type(id);


--
-- Name: price_object_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY price_object
    ADD CONSTRAINT price_object_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES price_object(id);


--
-- Name: qrtz_blob_triggers_trigger_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY qrtz_blob_triggers
    ADD CONSTRAINT qrtz_blob_triggers_trigger_name_fkey FOREIGN KEY (trigger_name, trigger_group) REFERENCES qrtz_triggers(trigger_name, trigger_group);


--
-- Name: qrtz_cron_triggers_trigger_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY qrtz_cron_triggers
    ADD CONSTRAINT qrtz_cron_triggers_trigger_name_fkey FOREIGN KEY (trigger_name, trigger_group) REFERENCES qrtz_triggers(trigger_name, trigger_group);


--
-- Name: qrtz_job_listeners_job_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY qrtz_job_listeners
    ADD CONSTRAINT qrtz_job_listeners_job_name_fkey FOREIGN KEY (job_name, job_group) REFERENCES qrtz_job_details(job_name, job_group);


--
-- Name: qrtz_simple_triggers_trigger_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY qrtz_simple_triggers
    ADD CONSTRAINT qrtz_simple_triggers_trigger_name_fkey FOREIGN KEY (trigger_name, trigger_group) REFERENCES qrtz_triggers(trigger_name, trigger_group);


--
-- Name: qrtz_trigger_listeners_trigger_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY qrtz_trigger_listeners
    ADD CONSTRAINT qrtz_trigger_listeners_trigger_name_fkey FOREIGN KEY (trigger_name, trigger_group) REFERENCES qrtz_triggers(trigger_name, trigger_group);


--
-- Name: qrtz_triggers_job_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY qrtz_triggers
    ADD CONSTRAINT qrtz_triggers_job_name_fkey FOREIGN KEY (job_name, job_group) REFERENCES qrtz_job_details(job_name, job_group);


--
-- Name: referral_log_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY referral_log
    ADD CONSTRAINT referral_log_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES referral_log(id);


--
-- Name: referral_log_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY referral_log
    ADD CONSTRAINT referral_log_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES app_user(id);


--
-- Name: replacement_employee_assigned_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY replacement
    ADD CONSTRAINT replacement_employee_assigned_fkey FOREIGN KEY (employee_assigned) REFERENCES employee(id);


--
-- Name: replacement_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY replacement
    ADD CONSTRAINT replacement_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES template_group(id);


--
-- Name: replacement_replacement_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY replacement
    ADD CONSTRAINT replacement_replacement_fkey FOREIGN KEY (replacement) REFERENCES employee(id);


--
-- Name: replacement_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY replacement
    ADD CONSTRAINT replacement_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES schedule(id);


--
-- Name: reseller_master_reseller_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY reseller
    ADD CONSTRAINT reseller_master_reseller_id_fkey FOREIGN KEY (master_reseller_id) REFERENCES reseller(id);


--
-- Name: schedule_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY schedule
    ADD CONSTRAINT schedule_department_id_fkey FOREIGN KEY (department_id) REFERENCES department(id);


--
-- Name: schedule_message_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY schedule_message
    ADD CONSTRAINT schedule_message_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES app_user(id);


--
-- Name: schedule_message_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY schedule_message
    ADD CONSTRAINT schedule_message_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: schedule_message_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY schedule_message
    ADD CONSTRAINT schedule_message_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES schedule_message(id);


--
-- Name: schedule_message_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY schedule_message
    ADD CONSTRAINT schedule_message_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES schedule(id);


--
-- Name: schedule_sales_type2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY schedule
    ADD CONSTRAINT schedule_sales_type2_id_fkey FOREIGN KEY (sales_type2_id) REFERENCES sales_type(id);


--
-- Name: schedule_sales_type3_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY schedule
    ADD CONSTRAINT schedule_sales_type3_id_fkey FOREIGN KEY (sales_type3_id) REFERENCES sales_type(id);


--
-- Name: schedule_sales_type4_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY schedule
    ADD CONSTRAINT schedule_sales_type4_id_fkey FOREIGN KEY (sales_type4_id) REFERENCES sales_type(id);


--
-- Name: schedule_sales_type5_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY schedule
    ADD CONSTRAINT schedule_sales_type5_id_fkey FOREIGN KEY (sales_type5_id) REFERENCES sales_type(id);


--
-- Name: schedule_sales_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY schedule
    ADD CONSTRAINT schedule_sales_type_id_fkey FOREIGN KEY (sales_type_id) REFERENCES sales_type(id);


--
-- Name: sensor_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY sensor
    ADD CONSTRAINT sensor_node_id_fkey FOREIGN KEY (node_id) REFERENCES temperature_node(id);


--
-- Name: sensor_profile_corporation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY sensor_profile
    ADD CONSTRAINT sensor_profile_corporation_id_fkey FOREIGN KEY (corporation_id) REFERENCES corporation(id);


--
-- Name: sensor_sensor_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY sensor
    ADD CONSTRAINT sensor_sensor_profile_id_fkey FOREIGN KEY (sensor_profile_id) REFERENCES sensor_profile(id);


--
-- Name: sensorprofilerange_sensor_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY sensorprofilerange
    ADD CONSTRAINT sensorprofilerange_sensor_profile_id_fkey FOREIGN KEY (sensor_profile_id) REFERENCES sensor_profile(id);


--
-- Name: shift_include_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY shift_include
    ADD CONSTRAINT shift_include_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES employee(id);


--
-- Name: shift_include_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY shift_include
    ADD CONSTRAINT shift_include_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES shift_include(id);


--
-- Name: shift_include_timeblock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY shift_include
    ADD CONSTRAINT shift_include_timeblock_id_fkey FOREIGN KEY (timeblock_id) REFERENCES timeblock(id);


--
-- Name: shift_request_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY shift_request
    ADD CONSTRAINT shift_request_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES shift_request(id);


--
-- Name: shift_request_requesting_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY shift_request
    ADD CONSTRAINT shift_request_requesting_employee_id_fkey FOREIGN KEY (requesting_employee_id) REFERENCES employee(id);


--
-- Name: shift_request_timeblock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY shift_request
    ADD CONSTRAINT shift_request_timeblock_id_fkey FOREIGN KEY (timeblock_id) REFERENCES timeblock(id);


--
-- Name: shift_swap_attempt_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY shift_swap_attempt
    ADD CONSTRAINT shift_swap_attempt_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES app_user(id);


--
-- Name: shift_swap_attempt_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY shift_swap_attempt
    ADD CONSTRAINT shift_swap_attempt_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES shift_swap_attempt(id);


--
-- Name: shift_swap_attempt_pickup_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY shift_swap_attempt
    ADD CONSTRAINT shift_swap_attempt_pickup_employee_id_fkey FOREIGN KEY (pickup_employee_id) REFERENCES employee(id);


--
-- Name: shift_swap_attempt_shift_swap_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY shift_swap_attempt
    ADD CONSTRAINT shift_swap_attempt_shift_swap_id_fkey FOREIGN KEY (shift_swap_id) REFERENCES shift_swap(id);


--
-- Name: shift_swap_given_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY shift_swap
    ADD CONSTRAINT shift_swap_given_employee_id_fkey FOREIGN KEY (given_employee_id) REFERENCES employee(id);


--
-- Name: shift_swap_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY shift_swap
    ADD CONSTRAINT shift_swap_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: shift_swap_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY shift_swap
    ADD CONSTRAINT shift_swap_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES shift_swap(id);


--
-- Name: shift_swap_timeblock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY shift_swap
    ADD CONSTRAINT shift_swap_timeblock_id_fkey FOREIGN KEY (timeblock_id) REFERENCES timeblock(id);


--
-- Name: shift_time_group_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY shift_time_group
    ADD CONSTRAINT shift_time_group_department_id_fkey FOREIGN KEY (department_id) REFERENCES department(id);


--
-- Name: shift_time_group_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY shift_time_group
    ADD CONSTRAINT shift_time_group_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: shift_time_group_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY shift_time_group
    ADD CONSTRAINT shift_time_group_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES shift_time_group(id);


--
-- Name: station_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY station
    ADD CONSTRAINT station_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: station_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY station
    ADD CONSTRAINT station_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES station(id);


--
-- Name: station_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY station
    ADD CONSTRAINT station_position_id_fkey FOREIGN KEY (position_id) REFERENCES "position"(id);


--
-- Name: telink_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY telink
    ADD CONSTRAINT telink_station_id_fkey FOREIGN KEY (station_id) REFERENCES station(id);


--
-- Name: temperature_data_sensor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY temperature_data
    ADD CONSTRAINT temperature_data_sensor_id_fkey FOREIGN KEY (sensor_id) REFERENCES sensor(id);


--
-- Name: temperature_event_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY temperature_event
    ADD CONSTRAINT temperature_event_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES employee(id);


--
-- Name: temperature_event_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY temperature_event
    ADD CONSTRAINT temperature_event_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES temperature_event(id);


--
-- Name: temperature_event_sensor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY temperature_event
    ADD CONSTRAINT temperature_event_sensor_id_fkey FOREIGN KEY (sensor_id) REFERENCES sensor(id);


--
-- Name: temperature_node_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY temperature_node
    ADD CONSTRAINT temperature_node_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: template_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY template
    ADD CONSTRAINT template_department_id_fkey FOREIGN KEY (department_id) REFERENCES department(id);


--
-- Name: template_group_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY template_group
    ADD CONSTRAINT template_group_department_id_fkey FOREIGN KEY (department_id) REFERENCES department(id);


--
-- Name: template_group_friday_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY template_group
    ADD CONSTRAINT template_group_friday_template_id_fkey FOREIGN KEY (friday_template_id) REFERENCES template(id);


--
-- Name: template_group_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY template_group
    ADD CONSTRAINT template_group_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: template_group_monday_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY template_group
    ADD CONSTRAINT template_group_monday_template_id_fkey FOREIGN KEY (monday_template_id) REFERENCES template(id);


--
-- Name: template_group_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY template_group
    ADD CONSTRAINT template_group_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES template_group(id);


--
-- Name: template_group_saturday_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY template_group
    ADD CONSTRAINT template_group_saturday_template_id_fkey FOREIGN KEY (saturday_template_id) REFERENCES template(id);


--
-- Name: template_group_sunday_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY template_group
    ADD CONSTRAINT template_group_sunday_template_id_fkey FOREIGN KEY (sunday_template_id) REFERENCES template(id);


--
-- Name: template_group_thursday_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY template_group
    ADD CONSTRAINT template_group_thursday_template_id_fkey FOREIGN KEY (thursday_template_id) REFERENCES template(id);


--
-- Name: template_group_tuesday_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY template_group
    ADD CONSTRAINT template_group_tuesday_template_id_fkey FOREIGN KEY (tuesday_template_id) REFERENCES template(id);


--
-- Name: template_group_wednesday_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY template_group
    ADD CONSTRAINT template_group_wednesday_template_id_fkey FOREIGN KEY (wednesday_template_id) REFERENCES template(id);


--
-- Name: textmessage_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY textmessage
    ADD CONSTRAINT textmessage_document_id_fkey FOREIGN KEY (document_id) REFERENCES document(id);


--
-- Name: textmessage_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY textmessage
    ADD CONSTRAINT textmessage_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(id);


--
-- Name: textmessage_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY textmessage
    ADD CONSTRAINT textmessage_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES textmessage(id);


--
-- Name: textmessage_who_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY textmessage
    ADD CONSTRAINT textmessage_who_id_fkey FOREIGN KEY (who_id) REFERENCES app_user(id);


--
-- Name: tfmessage_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY tfmessage
    ADD CONSTRAINT tfmessage_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES tfmessage(id);


--
-- Name: tfmessage_to_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY tfmessage
    ADD CONSTRAINT tfmessage_to_user_id_fkey FOREIGN KEY (to_user_id) REFERENCES app_user(id);


--
-- Name: tfmessage_user_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY tfmessage_user
    ADD CONSTRAINT tfmessage_user_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES tfmessage_user(id);


--
-- Name: tfmessage_user_tf_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY tfmessage_user
    ADD CONSTRAINT tfmessage_user_tf_message_id_fkey FOREIGN KEY (tf_message_id) REFERENCES tfmessage(id);


--
-- Name: tfmessage_user_who_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY tfmessage_user
    ADD CONSTRAINT tfmessage_user_who_id_fkey FOREIGN KEY (who_id) REFERENCES app_user(id);


--
-- Name: timeblock_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY timeblock
    ADD CONSTRAINT timeblock_station_id_fkey FOREIGN KEY (station_id) REFERENCES station(id);


--
-- Name: tplink_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY tplink
    ADD CONSTRAINT tplink_station_id_fkey FOREIGN KEY (station_id) REFERENCES station(id);


--
-- Name: user_location_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY user_location
    ADD CONSTRAINT user_location_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES user_location(id);


--
-- Name: user_textmessage_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY user_textmessage
    ADD CONSTRAINT user_textmessage_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES user_textmessage(id);


--
-- Name: user_textmessage_textmessage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY user_textmessage
    ADD CONSTRAINT user_textmessage_textmessage_id_fkey FOREIGN KEY (textmessage_id) REFERENCES textmessage(id);


--
-- Name: user_textmessage_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY user_textmessage
    ADD CONSTRAINT user_textmessage_user_id_fkey FOREIGN KEY (user_id) REFERENCES app_user(id);


--
-- Name: weather_data_weather_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ressystems
--

ALTER TABLE ONLY weather_data
    ADD CONSTRAINT weather_data_weather_id_fkey FOREIGN KEY (weather_id) REFERENCES weather(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;
GRANT USAGE ON SCHEMA public TO dfernandez;


--
-- Name: app_user; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE app_user FROM PUBLIC;
REVOKE ALL ON TABLE app_user FROM ressystems;
GRANT ALL ON TABLE app_user TO ressystems;
GRANT SELECT ON TABLE app_user TO dfernandez;


--
-- Name: applicant; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE applicant FROM PUBLIC;
REVOKE ALL ON TABLE applicant FROM postgres;
GRANT ALL ON TABLE applicant TO postgres;
GRANT SELECT ON TABLE applicant TO dfernandez;


--
-- Name: applicant_historical_step; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE applicant_historical_step FROM PUBLIC;
REVOKE ALL ON TABLE applicant_historical_step FROM postgres;
GRANT ALL ON TABLE applicant_historical_step TO postgres;
GRANT SELECT ON TABLE applicant_historical_step TO dfernandez;


--
-- Name: attendance_block; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE attendance_block FROM PUBLIC;
REVOKE ALL ON TABLE attendance_block FROM postgres;
GRANT ALL ON TABLE attendance_block TO postgres;
GRANT SELECT ON TABLE attendance_block TO dfernandez;


--
-- Name: attendance_break; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE attendance_break FROM PUBLIC;
REVOKE ALL ON TABLE attendance_break FROM postgres;
GRANT ALL ON TABLE attendance_break TO postgres;
GRANT SELECT ON TABLE attendance_break TO dfernandez;


--
-- Name: blackout_preference; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE blackout_preference FROM PUBLIC;
REVOKE ALL ON TABLE blackout_preference FROM ressystems;
GRANT ALL ON TABLE blackout_preference TO ressystems;
GRANT SELECT ON TABLE blackout_preference TO dfernandez;


--
-- Name: blocked_daily_ip; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE blocked_daily_ip FROM PUBLIC;
REVOKE ALL ON TABLE blocked_daily_ip FROM postgres;
GRANT ALL ON TABLE blocked_daily_ip TO postgres;
GRANT SELECT ON TABLE blocked_daily_ip TO dfernandez;


--
-- Name: break_rule; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE break_rule FROM PUBLIC;
REVOKE ALL ON TABLE break_rule FROM ressystems;
GRANT ALL ON TABLE break_rule TO ressystems;
GRANT SELECT ON TABLE break_rule TO dfernandez;


--
-- Name: break_time; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE break_time FROM PUBLIC;
REVOKE ALL ON TABLE break_time FROM ressystems;
GRANT ALL ON TABLE break_time TO ressystems;
GRANT SELECT ON TABLE break_time TO dfernandez;


--
-- Name: break_time_snap_shot; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE break_time_snap_shot FROM PUBLIC;
REVOKE ALL ON TABLE break_time_snap_shot FROM ressystems;
GRANT ALL ON TABLE break_time_snap_shot TO ressystems;
GRANT SELECT ON TABLE break_time_snap_shot TO dfernandez;


--
-- Name: certification; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE certification FROM PUBLIC;
REVOKE ALL ON TABLE certification FROM ressystems;
GRANT ALL ON TABLE certification TO ressystems;
GRANT SELECT ON TABLE certification TO dfernandez;


--
-- Name: commision; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE commision FROM PUBLIC;
REVOKE ALL ON TABLE commision FROM ressystems;
GRANT ALL ON TABLE commision TO ressystems;
GRANT SELECT ON TABLE commision TO dfernandez;


--
-- Name: corporation; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE corporation FROM PUBLIC;
REVOKE ALL ON TABLE corporation FROM ressystems;
GRANT ALL ON TABLE corporation TO ressystems;
GRANT SELECT ON TABLE corporation TO dfernandez;


--
-- Name: country; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE country FROM PUBLIC;
REVOKE ALL ON TABLE country FROM ressystems;
GRANT ALL ON TABLE country TO ressystems;
GRANT SELECT ON TABLE country TO dfernandez;


--
-- Name: date_etl; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE date_etl FROM PUBLIC;
REVOKE ALL ON TABLE date_etl FROM ressystems;
GRANT ALL ON TABLE date_etl TO ressystems;
GRANT SELECT ON TABLE date_etl TO dfernandez;


--
-- Name: department; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE department FROM PUBLIC;
REVOKE ALL ON TABLE department FROM ressystems;
GRANT ALL ON TABLE department TO ressystems;
GRANT SELECT ON TABLE department TO dfernandez;


--
-- Name: department_employee; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE department_employee FROM PUBLIC;
REVOKE ALL ON TABLE department_employee FROM ressystems;
GRANT ALL ON TABLE department_employee TO ressystems;
GRANT SELECT ON TABLE department_employee TO dfernandez;


--
-- Name: department_location; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE department_location FROM PUBLIC;
REVOKE ALL ON TABLE department_location FROM ressystems;
GRANT ALL ON TABLE department_location TO ressystems;
GRANT SELECT ON TABLE department_location TO dfernandez;


--
-- Name: department_position; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE department_position FROM PUBLIC;
REVOKE ALL ON TABLE department_position FROM ressystems;
GRANT ALL ON TABLE department_position TO ressystems;
GRANT SELECT ON TABLE department_position TO dfernandez;


--
-- Name: department_roll_up; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE department_roll_up FROM PUBLIC;
REVOKE ALL ON TABLE department_roll_up FROM postgres;
GRANT ALL ON TABLE department_roll_up TO postgres;
GRANT SELECT ON TABLE department_roll_up TO dfernandez;


--
-- Name: document; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE document FROM PUBLIC;
REVOKE ALL ON TABLE document FROM postgres;
GRANT ALL ON TABLE document TO postgres;
GRANT SELECT ON TABLE document TO dfernandez;


--
-- Name: employee; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE employee FROM PUBLIC;
REVOKE ALL ON TABLE employee FROM ressystems;
GRANT ALL ON TABLE employee TO ressystems;
GRANT SELECT ON TABLE employee TO dfernandez;


--
-- Name: employee_accrual; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE employee_accrual FROM PUBLIC;
REVOKE ALL ON TABLE employee_accrual FROM ressystems;
GRANT ALL ON TABLE employee_accrual TO ressystems;
GRANT SELECT ON TABLE employee_accrual TO dfernandez;


--
-- Name: employee_certification; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE employee_certification FROM PUBLIC;
REVOKE ALL ON TABLE employee_certification FROM ressystems;
GRANT ALL ON TABLE employee_certification TO ressystems;
GRANT SELECT ON TABLE employee_certification TO dfernandez;


--
-- Name: employee_position; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE employee_position FROM PUBLIC;
REVOKE ALL ON TABLE employee_position FROM ressystems;
GRANT ALL ON TABLE employee_position TO ressystems;
GRANT SELECT ON TABLE employee_position TO dfernandez;


--
-- Name: employee_preference_type; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE employee_preference_type FROM PUBLIC;
REVOKE ALL ON TABLE employee_preference_type FROM ressystems;
GRANT ALL ON TABLE employee_preference_type TO ressystems;
GRANT SELECT ON TABLE employee_preference_type TO dfernandez;


--
-- Name: employee_sensoralert; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE employee_sensoralert FROM PUBLIC;
REVOKE ALL ON TABLE employee_sensoralert FROM ressystems;
GRANT ALL ON TABLE employee_sensoralert TO ressystems;
GRANT SELECT ON TABLE employee_sensoralert TO dfernandez;


--
-- Name: employee_setting; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE employee_setting FROM PUBLIC;
REVOKE ALL ON TABLE employee_setting FROM ressystems;
GRANT ALL ON TABLE employee_setting TO ressystems;
GRANT SELECT ON TABLE employee_setting TO dfernandez;


--
-- Name: event; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE event FROM PUBLIC;
REVOKE ALL ON TABLE event FROM postgres;
GRANT ALL ON TABLE event TO postgres;
GRANT SELECT ON TABLE event TO dfernandez;


--
-- Name: event_certification; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE event_certification FROM PUBLIC;
REVOKE ALL ON TABLE event_certification FROM postgres;
GRANT ALL ON TABLE event_certification TO postgres;
GRANT SELECT ON TABLE event_certification TO dfernandez;


--
-- Name: event_department; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE event_department FROM PUBLIC;
REVOKE ALL ON TABLE event_department FROM postgres;
GRANT ALL ON TABLE event_department TO postgres;
GRANT SELECT ON TABLE event_department TO dfernandez;


--
-- Name: fingerprint; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE fingerprint FROM PUBLIC;
REVOKE ALL ON TABLE fingerprint FROM ressystems;
GRANT ALL ON TABLE fingerprint TO ressystems;
GRANT SELECT ON TABLE fingerprint TO dfernandez;


--
-- Name: flag; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE flag FROM PUBLIC;
REVOKE ALL ON TABLE flag FROM ressystems;
GRANT ALL ON TABLE flag TO ressystems;
GRANT SELECT ON TABLE flag TO dfernandez;


--
-- Name: forecast_timeblock; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE forecast_timeblock FROM PUBLIC;
REVOKE ALL ON TABLE forecast_timeblock FROM ressystems;
GRANT ALL ON TABLE forecast_timeblock TO ressystems;
GRANT SELECT ON TABLE forecast_timeblock TO dfernandez;


--
-- Name: hierarchy; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE hierarchy FROM PUBLIC;
REVOKE ALL ON TABLE hierarchy FROM ressystems;
GRANT ALL ON TABLE hierarchy TO ressystems;
GRANT SELECT ON TABLE hierarchy TO dfernandez;


--
-- Name: invoice; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE invoice FROM PUBLIC;
REVOKE ALL ON TABLE invoice FROM ressystems;
GRANT ALL ON TABLE invoice TO ressystems;
GRANT SELECT ON TABLE invoice TO dfernandez;


--
-- Name: location; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE location FROM PUBLIC;
REVOKE ALL ON TABLE location FROM ressystems;
GRANT ALL ON TABLE location TO ressystems;
GRANT SELECT ON TABLE location TO dfernandez;


--
-- Name: location_flag; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE location_flag FROM PUBLIC;
REVOKE ALL ON TABLE location_flag FROM ressystems;
GRANT ALL ON TABLE location_flag TO ressystems;
GRANT SELECT ON TABLE location_flag TO dfernandez;


--
-- Name: location_hierarchy; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE location_hierarchy FROM PUBLIC;
REVOKE ALL ON TABLE location_hierarchy FROM ressystems;
GRANT ALL ON TABLE location_hierarchy TO ressystems;
GRANT SELECT ON TABLE location_hierarchy TO dfernandez;


--
-- Name: logtag; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE logtag FROM PUBLIC;
REVOKE ALL ON TABLE logtag FROM postgres;
GRANT ALL ON TABLE logtag TO postgres;
GRANT SELECT ON TABLE logtag TO dfernandez;


--
-- Name: manager_log; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE manager_log FROM PUBLIC;
REVOKE ALL ON TABLE manager_log FROM ressystems;
GRANT ALL ON TABLE manager_log TO ressystems;
GRANT SELECT ON TABLE manager_log TO dfernandez;


--
-- Name: manager_log_category; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE manager_log_category FROM PUBLIC;
REVOKE ALL ON TABLE manager_log_category FROM ressystems;
GRANT ALL ON TABLE manager_log_category TO ressystems;
GRANT SELECT ON TABLE manager_log_category TO dfernandez;


--
-- Name: managerlog_logtag; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE managerlog_logtag FROM PUBLIC;
REVOKE ALL ON TABLE managerlog_logtag FROM postgres;
GRANT ALL ON TABLE managerlog_logtag TO postgres;
GRANT SELECT ON TABLE managerlog_logtag TO dfernandez;


--
-- Name: message_log; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE message_log FROM PUBLIC;
REVOKE ALL ON TABLE message_log FROM ressystems;
GRANT ALL ON TABLE message_log TO ressystems;
GRANT SELECT ON TABLE message_log TO dfernandez;


--
-- Name: minor; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE minor FROM PUBLIC;
REVOKE ALL ON TABLE minor FROM ressystems;
GRANT ALL ON TABLE minor TO ressystems;
GRANT SELECT ON TABLE minor TO dfernandez;


--
-- Name: minor_preference; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE minor_preference FROM PUBLIC;
REVOKE ALL ON TABLE minor_preference FROM ressystems;
GRANT ALL ON TABLE minor_preference TO ressystems;
GRANT SELECT ON TABLE minor_preference TO dfernandez;


--
-- Name: multi_level_pay_rate; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE multi_level_pay_rate FROM PUBLIC;
REVOKE ALL ON TABLE multi_level_pay_rate FROM ressystems;
GRANT ALL ON TABLE multi_level_pay_rate TO ressystems;
GRANT SELECT ON TABLE multi_level_pay_rate TO dfernandez;


--
-- Name: payment_log; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE payment_log FROM PUBLIC;
REVOKE ALL ON TABLE payment_log FROM ressystems;
GRANT ALL ON TABLE payment_log TO ressystems;
GRANT SELECT ON TABLE payment_log TO dfernandez;


--
-- Name: person; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE person FROM PUBLIC;
REVOKE ALL ON TABLE person FROM ressystems;
GRANT ALL ON TABLE person TO ressystems;
GRANT SELECT ON TABLE person TO dfernandez;


--
-- Name: pglink; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE pglink FROM PUBLIC;
REVOKE ALL ON TABLE pglink FROM ressystems;
GRANT ALL ON TABLE pglink TO ressystems;
GRANT SELECT ON TABLE pglink TO dfernandez;


--
-- Name: position; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE "position" FROM PUBLIC;
REVOKE ALL ON TABLE "position" FROM ressystems;
GRANT ALL ON TABLE "position" TO ressystems;
GRANT SELECT ON TABLE "position" TO dfernandez;


--
-- Name: position_certification; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE position_certification FROM PUBLIC;
REVOKE ALL ON TABLE position_certification FROM postgres;
GRANT ALL ON TABLE position_certification TO postgres;
GRANT SELECT ON TABLE position_certification TO dfernandez;


--
-- Name: position_code; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE position_code FROM PUBLIC;
REVOKE ALL ON TABLE position_code FROM ressystems;
GRANT ALL ON TABLE position_code TO ressystems;
GRANT SELECT ON TABLE position_code TO dfernandez;


--
-- Name: position_tracking_step; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE position_tracking_step FROM PUBLIC;
REVOKE ALL ON TABLE position_tracking_step FROM postgres;
GRANT ALL ON TABLE position_tracking_step TO postgres;
GRANT SELECT ON TABLE position_tracking_step TO dfernandez;


--
-- Name: positiongroup; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE positiongroup FROM PUBLIC;
REVOKE ALL ON TABLE positiongroup FROM ressystems;
GRANT ALL ON TABLE positiongroup TO ressystems;
GRANT SELECT ON TABLE positiongroup TO dfernandez;


--
-- Name: preference; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE preference FROM PUBLIC;
REVOKE ALL ON TABLE preference FROM ressystems;
GRANT ALL ON TABLE preference TO ressystems;
GRANT SELECT ON TABLE preference TO dfernandez;


--
-- Name: preference_conflict_etl; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE preference_conflict_etl FROM PUBLIC;
REVOKE ALL ON TABLE preference_conflict_etl FROM ressystems;
GRANT ALL ON TABLE preference_conflict_etl TO ressystems;
GRANT SELECT ON TABLE preference_conflict_etl TO dfernandez;


--
-- Name: preference_date_etl; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE preference_date_etl FROM PUBLIC;
REVOKE ALL ON TABLE preference_date_etl FROM ressystems;
GRANT ALL ON TABLE preference_date_etl TO ressystems;
GRANT SELECT ON TABLE preference_date_etl TO dfernandez;


--
-- Name: preference_type; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE preference_type FROM PUBLIC;
REVOKE ALL ON TABLE preference_type FROM ressystems;
GRANT ALL ON TABLE preference_type TO ressystems;
GRANT SELECT ON TABLE preference_type TO dfernandez;


--
-- Name: preference_type_location; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE preference_type_location FROM PUBLIC;
REVOKE ALL ON TABLE preference_type_location FROM postgres;
GRANT ALL ON TABLE preference_type_location TO postgres;
GRANT SELECT ON TABLE preference_type_location TO dfernandez;


--
-- Name: price_object; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE price_object FROM PUBLIC;
REVOKE ALL ON TABLE price_object FROM ressystems;
GRANT ALL ON TABLE price_object TO ressystems;
GRANT SELECT ON TABLE price_object TO dfernandez;


--
-- Name: pto_accrual; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE pto_accrual FROM PUBLIC;
REVOKE ALL ON TABLE pto_accrual FROM ressystems;
GRANT ALL ON TABLE pto_accrual TO ressystems;
GRANT SELECT ON TABLE pto_accrual TO dfernandez;


--
-- Name: qrtz_blob_triggers; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE qrtz_blob_triggers FROM PUBLIC;
REVOKE ALL ON TABLE qrtz_blob_triggers FROM ressystems;
GRANT ALL ON TABLE qrtz_blob_triggers TO ressystems;
GRANT SELECT ON TABLE qrtz_blob_triggers TO dfernandez;


--
-- Name: qrtz_calendars; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE qrtz_calendars FROM PUBLIC;
REVOKE ALL ON TABLE qrtz_calendars FROM ressystems;
GRANT ALL ON TABLE qrtz_calendars TO ressystems;
GRANT SELECT ON TABLE qrtz_calendars TO dfernandez;


--
-- Name: qrtz_cron_triggers; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE qrtz_cron_triggers FROM PUBLIC;
REVOKE ALL ON TABLE qrtz_cron_triggers FROM ressystems;
GRANT ALL ON TABLE qrtz_cron_triggers TO ressystems;
GRANT SELECT ON TABLE qrtz_cron_triggers TO dfernandez;


--
-- Name: qrtz_fired_triggers; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE qrtz_fired_triggers FROM PUBLIC;
REVOKE ALL ON TABLE qrtz_fired_triggers FROM ressystems;
GRANT ALL ON TABLE qrtz_fired_triggers TO ressystems;
GRANT SELECT ON TABLE qrtz_fired_triggers TO dfernandez;


--
-- Name: qrtz_job_details; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE qrtz_job_details FROM PUBLIC;
REVOKE ALL ON TABLE qrtz_job_details FROM ressystems;
GRANT ALL ON TABLE qrtz_job_details TO ressystems;
GRANT SELECT ON TABLE qrtz_job_details TO dfernandez;


--
-- Name: qrtz_job_listeners; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE qrtz_job_listeners FROM PUBLIC;
REVOKE ALL ON TABLE qrtz_job_listeners FROM ressystems;
GRANT ALL ON TABLE qrtz_job_listeners TO ressystems;
GRANT SELECT ON TABLE qrtz_job_listeners TO dfernandez;


--
-- Name: qrtz_locks; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE qrtz_locks FROM PUBLIC;
REVOKE ALL ON TABLE qrtz_locks FROM ressystems;
GRANT ALL ON TABLE qrtz_locks TO ressystems;
GRANT SELECT ON TABLE qrtz_locks TO dfernandez;


--
-- Name: qrtz_paused_trigger_grps; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE qrtz_paused_trigger_grps FROM PUBLIC;
REVOKE ALL ON TABLE qrtz_paused_trigger_grps FROM ressystems;
GRANT ALL ON TABLE qrtz_paused_trigger_grps TO ressystems;
GRANT SELECT ON TABLE qrtz_paused_trigger_grps TO dfernandez;


--
-- Name: qrtz_scheduler_state; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE qrtz_scheduler_state FROM PUBLIC;
REVOKE ALL ON TABLE qrtz_scheduler_state FROM ressystems;
GRANT ALL ON TABLE qrtz_scheduler_state TO ressystems;
GRANT SELECT ON TABLE qrtz_scheduler_state TO dfernandez;


--
-- Name: qrtz_simple_triggers; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE qrtz_simple_triggers FROM PUBLIC;
REVOKE ALL ON TABLE qrtz_simple_triggers FROM ressystems;
GRANT ALL ON TABLE qrtz_simple_triggers TO ressystems;
GRANT SELECT ON TABLE qrtz_simple_triggers TO dfernandez;


--
-- Name: qrtz_trigger_listeners; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE qrtz_trigger_listeners FROM PUBLIC;
REVOKE ALL ON TABLE qrtz_trigger_listeners FROM ressystems;
GRANT ALL ON TABLE qrtz_trigger_listeners TO ressystems;
GRANT SELECT ON TABLE qrtz_trigger_listeners TO dfernandez;


--
-- Name: qrtz_triggers; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE qrtz_triggers FROM PUBLIC;
REVOKE ALL ON TABLE qrtz_triggers FROM ressystems;
GRANT ALL ON TABLE qrtz_triggers TO ressystems;
GRANT SELECT ON TABLE qrtz_triggers TO dfernandez;


--
-- Name: referral_log; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE referral_log FROM PUBLIC;
REVOKE ALL ON TABLE referral_log FROM ressystems;
GRANT ALL ON TABLE referral_log TO ressystems;
GRANT SELECT ON TABLE referral_log TO dfernandez;


--
-- Name: replacement; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE replacement FROM PUBLIC;
REVOKE ALL ON TABLE replacement FROM ressystems;
GRANT ALL ON TABLE replacement TO ressystems;
GRANT SELECT ON TABLE replacement TO dfernandez;


--
-- Name: reseller; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE reseller FROM PUBLIC;
REVOKE ALL ON TABLE reseller FROM ressystems;
GRANT ALL ON TABLE reseller TO ressystems;
GRANT SELECT ON TABLE reseller TO dfernandez;


--
-- Name: role; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE role FROM PUBLIC;
REVOKE ALL ON TABLE role FROM ressystems;
GRANT ALL ON TABLE role TO ressystems;
GRANT SELECT ON TABLE role TO dfernandez;


--
-- Name: sales_paf; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE sales_paf FROM PUBLIC;
REVOKE ALL ON TABLE sales_paf FROM ressystems;
GRANT ALL ON TABLE sales_paf TO ressystems;
GRANT SELECT ON TABLE sales_paf TO dfernandez;


--
-- Name: sales_type; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE sales_type FROM PUBLIC;
REVOKE ALL ON TABLE sales_type FROM ressystems;
GRANT ALL ON TABLE sales_type TO ressystems;
GRANT SELECT ON TABLE sales_type TO dfernandez;


--
-- Name: sales_type_location; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE sales_type_location FROM PUBLIC;
REVOKE ALL ON TABLE sales_type_location FROM ressystems;
GRANT ALL ON TABLE sales_type_location TO ressystems;
GRANT SELECT ON TABLE sales_type_location TO dfernandez;


--
-- Name: schedule; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE schedule FROM PUBLIC;
REVOKE ALL ON TABLE schedule FROM ressystems;
GRANT ALL ON TABLE schedule TO ressystems;
GRANT SELECT ON TABLE schedule TO dfernandez;


--
-- Name: schedule_message; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE schedule_message FROM PUBLIC;
REVOKE ALL ON TABLE schedule_message FROM ressystems;
GRANT ALL ON TABLE schedule_message TO ressystems;
GRANT SELECT ON TABLE schedule_message TO dfernandez;


--
-- Name: schedule_snap_shot; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE schedule_snap_shot FROM PUBLIC;
REVOKE ALL ON TABLE schedule_snap_shot FROM ressystems;
GRANT ALL ON TABLE schedule_snap_shot TO ressystems;
GRANT SELECT ON TABLE schedule_snap_shot TO dfernandez;


--
-- Name: security_template; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE security_template FROM PUBLIC;
REVOKE ALL ON TABLE security_template FROM ressystems;
GRANT ALL ON TABLE security_template TO ressystems;
GRANT SELECT ON TABLE security_template TO dfernandez;


--
-- Name: security_template_rules; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE security_template_rules FROM PUBLIC;
REVOKE ALL ON TABLE security_template_rules FROM ressystems;
GRANT ALL ON TABLE security_template_rules TO ressystems;
GRANT SELECT ON TABLE security_template_rules TO dfernandez;


--
-- Name: sensor; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE sensor FROM PUBLIC;
REVOKE ALL ON TABLE sensor FROM ressystems;
GRANT ALL ON TABLE sensor TO ressystems;
GRANT SELECT ON TABLE sensor TO dfernandez;


--
-- Name: sensor_profile; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE sensor_profile FROM PUBLIC;
REVOKE ALL ON TABLE sensor_profile FROM ressystems;
GRANT ALL ON TABLE sensor_profile TO ressystems;
GRANT SELECT ON TABLE sensor_profile TO dfernandez;


--
-- Name: sensorprofilerange; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE sensorprofilerange FROM PUBLIC;
REVOKE ALL ON TABLE sensorprofilerange FROM ressystems;
GRANT ALL ON TABLE sensorprofilerange TO ressystems;
GRANT SELECT ON TABLE sensorprofilerange TO dfernandez;


--
-- Name: setting; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE setting FROM PUBLIC;
REVOKE ALL ON TABLE setting FROM ressystems;
GRANT ALL ON TABLE setting TO ressystems;
GRANT SELECT ON TABLE setting TO dfernandez;


--
-- Name: shift_include; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE shift_include FROM PUBLIC;
REVOKE ALL ON TABLE shift_include FROM ressystems;
GRANT ALL ON TABLE shift_include TO ressystems;
GRANT SELECT ON TABLE shift_include TO dfernandez;


--
-- Name: shift_request; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE shift_request FROM PUBLIC;
REVOKE ALL ON TABLE shift_request FROM ressystems;
GRANT ALL ON TABLE shift_request TO ressystems;
GRANT SELECT ON TABLE shift_request TO dfernandez;


--
-- Name: shift_swap; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE shift_swap FROM PUBLIC;
REVOKE ALL ON TABLE shift_swap FROM ressystems;
GRANT ALL ON TABLE shift_swap TO ressystems;
GRANT SELECT ON TABLE shift_swap TO dfernandez;


--
-- Name: shift_swap_attempt; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE shift_swap_attempt FROM PUBLIC;
REVOKE ALL ON TABLE shift_swap_attempt FROM ressystems;
GRANT ALL ON TABLE shift_swap_attempt TO ressystems;
GRANT SELECT ON TABLE shift_swap_attempt TO dfernandez;


--
-- Name: shift_time_group; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE shift_time_group FROM PUBLIC;
REVOKE ALL ON TABLE shift_time_group FROM ressystems;
GRANT ALL ON TABLE shift_time_group TO ressystems;
GRANT SELECT ON TABLE shift_time_group TO dfernandez;


--
-- Name: station; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE station FROM PUBLIC;
REVOKE ALL ON TABLE station FROM ressystems;
GRANT ALL ON TABLE station TO ressystems;
GRANT SELECT ON TABLE station TO dfernandez;


--
-- Name: telink; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE telink FROM PUBLIC;
REVOKE ALL ON TABLE telink FROM ressystems;
GRANT ALL ON TABLE telink TO ressystems;
GRANT SELECT ON TABLE telink TO dfernandez;


--
-- Name: temperature_data; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE temperature_data FROM PUBLIC;
REVOKE ALL ON TABLE temperature_data FROM ressystems;
GRANT ALL ON TABLE temperature_data TO ressystems;
GRANT SELECT ON TABLE temperature_data TO dfernandez;


--
-- Name: temperature_event; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE temperature_event FROM PUBLIC;
REVOKE ALL ON TABLE temperature_event FROM ressystems;
GRANT ALL ON TABLE temperature_event TO ressystems;
GRANT SELECT ON TABLE temperature_event TO dfernandez;


--
-- Name: temperature_node; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE temperature_node FROM PUBLIC;
REVOKE ALL ON TABLE temperature_node FROM ressystems;
GRANT ALL ON TABLE temperature_node TO ressystems;
GRANT SELECT ON TABLE temperature_node TO dfernandez;


--
-- Name: template; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE template FROM PUBLIC;
REVOKE ALL ON TABLE template FROM ressystems;
GRANT ALL ON TABLE template TO ressystems;
GRANT SELECT ON TABLE template TO dfernandez;


--
-- Name: template_group; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE template_group FROM PUBLIC;
REVOKE ALL ON TABLE template_group FROM ressystems;
GRANT ALL ON TABLE template_group TO ressystems;
GRANT SELECT ON TABLE template_group TO dfernandez;


--
-- Name: test125; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE test125 FROM PUBLIC;
REVOKE ALL ON TABLE test125 FROM postgres;
GRANT ALL ON TABLE test125 TO postgres;
GRANT ALL ON TABLE test125 TO ressystems;


--
-- Name: testing; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE testing FROM PUBLIC;
REVOKE ALL ON TABLE testing FROM ressystems;
GRANT ALL ON TABLE testing TO ressystems;
GRANT SELECT ON TABLE testing TO dfernandez;


--
-- Name: textmessage; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE textmessage FROM PUBLIC;
REVOKE ALL ON TABLE textmessage FROM ressystems;
GRANT ALL ON TABLE textmessage TO ressystems;
GRANT SELECT ON TABLE textmessage TO dfernandez;


--
-- Name: tfmessage; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE tfmessage FROM PUBLIC;
REVOKE ALL ON TABLE tfmessage FROM ressystems;
GRANT ALL ON TABLE tfmessage TO ressystems;
GRANT SELECT ON TABLE tfmessage TO dfernandez;


--
-- Name: tfmessage_user; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE tfmessage_user FROM PUBLIC;
REVOKE ALL ON TABLE tfmessage_user FROM ressystems;
GRANT ALL ON TABLE tfmessage_user TO ressystems;
GRANT SELECT ON TABLE tfmessage_user TO dfernandez;


--
-- Name: timeblock; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE timeblock FROM PUBLIC;
REVOKE ALL ON TABLE timeblock FROM ressystems;
GRANT ALL ON TABLE timeblock TO ressystems;
GRANT SELECT ON TABLE timeblock TO dfernandez;


--
-- Name: timeblock_event; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE timeblock_event FROM PUBLIC;
REVOKE ALL ON TABLE timeblock_event FROM postgres;
GRANT ALL ON TABLE timeblock_event TO postgres;
GRANT SELECT ON TABLE timeblock_event TO dfernandez;


--
-- Name: timeblock_snap_shot; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE timeblock_snap_shot FROM PUBLIC;
REVOKE ALL ON TABLE timeblock_snap_shot FROM ressystems;
GRANT ALL ON TABLE timeblock_snap_shot TO ressystems;
GRANT SELECT ON TABLE timeblock_snap_shot TO dfernandez;


--
-- Name: timezone; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE timezone FROM PUBLIC;
REVOKE ALL ON TABLE timezone FROM ressystems;
GRANT ALL ON TABLE timezone TO ressystems;
GRANT SELECT ON TABLE timezone TO dfernandez;


--
-- Name: tplink; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE tplink FROM PUBLIC;
REVOKE ALL ON TABLE tplink FROM ressystems;
GRANT ALL ON TABLE tplink TO ressystems;
GRANT SELECT ON TABLE tplink TO dfernandez;


--
-- Name: user_location; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE user_location FROM PUBLIC;
REVOKE ALL ON TABLE user_location FROM ressystems;
GRANT ALL ON TABLE user_location TO ressystems;
GRANT SELECT ON TABLE user_location TO dfernandez;


--
-- Name: user_role; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE user_role FROM PUBLIC;
REVOKE ALL ON TABLE user_role FROM ressystems;
GRANT ALL ON TABLE user_role TO ressystems;
GRANT SELECT ON TABLE user_role TO dfernandez;


--
-- Name: user_security_template; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE user_security_template FROM PUBLIC;
REVOKE ALL ON TABLE user_security_template FROM ressystems;
GRANT ALL ON TABLE user_security_template TO ressystems;
GRANT SELECT ON TABLE user_security_template TO dfernandez;


--
-- Name: user_textmessage; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE user_textmessage FROM PUBLIC;
REVOKE ALL ON TABLE user_textmessage FROM ressystems;
GRANT ALL ON TABLE user_textmessage TO ressystems;
GRANT SELECT ON TABLE user_textmessage TO dfernandez;


--
-- Name: weather; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE weather FROM PUBLIC;
REVOKE ALL ON TABLE weather FROM ressystems;
GRANT ALL ON TABLE weather TO ressystems;
GRANT SELECT ON TABLE weather TO dfernandez;


--
-- Name: weather_data; Type: ACL; Schema: public; Owner: ressystems
--

REVOKE ALL ON TABLE weather_data FROM PUBLIC;
REVOKE ALL ON TABLE weather_data FROM ressystems;
GRANT ALL ON TABLE weather_data TO ressystems;
GRANT SELECT ON TABLE weather_data TO dfernandez;


--
-- PostgreSQL database dump complete
--

