-- Rolling 30-day case assignment
-- New case starts when gap between consecutive alerts for the same customer > 30 days

WITH base AS (
  SELECT
    a.alert_id,
    t.customer_id,
    a.generated_ts_utc,
    LAG(a.generated_ts_utc) OVER (
      PARTITION BY t.customer_id
      ORDER BY a.generated_ts_utc, a.alert_id
    ) AS prev_ts
  FROM public.alerts a
  JOIN public.transactions t ON t.txn_id = a.txn_id
),
flags AS (
  SELECT
    alert_id,
    customer_id,
    generated_ts_utc,
    CASE
      WHEN prev_ts IS NULL THEN 1
      WHEN generated_ts_utc - prev_ts > INTERVAL '30 days' THEN 1
      ELSE 0
    END AS new_case_flag
  FROM base
),
seq AS (
  SELECT
    alert_id,
    customer_id,
    SUM(new_case_flag) OVER (
      PARTITION BY customer_id
      ORDER BY generated_ts_utc, alert_id
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS case_seq
  FROM flags
),
map AS (
  SELECT
    alert_id,
    DENSE_RANK() OVER (ORDER BY customer_id, case_seq) AS new_case_id
  FROM seq
)
UPDATE public.alerts a
SET case_id = m.new_case_id
FROM map m
WHERE a.alert_id = m.alert_id;

-- Rebuild cases table from updated alerts
TRUNCATE TABLE public.cases;

INSERT INTO public.cases
  (case_id, customer_id, opened_ts_utc, closed_ts_utc, assigned_analyst_id, outcome, time_to_close_hours)
SELECT
  a.case_id,
  MIN(t.customer_id) AS customer_id,
  MIN(a.generated_ts_utc) AS opened_ts_utc,
  MAX(a.closed_ts_utc) AS closed_ts_utc,
  MIN(a.analyst_id) AS assigned_analyst_id,
  CASE
    WHEN SUM(CASE WHEN a.decision='True Positive' THEN 1 ELSE 0 END) > 0
     AND SUM(CASE WHEN a.severity='High' THEN 1 ELSE 0 END) > 0 THEN 'SAR filed'
    WHEN SUM(CASE WHEN a.decision='True Positive' THEN 1 ELSE 0 END) > 0 THEN 'Escalated'
    ELSE 'No action'
  END AS outcome,
  ROUND(
    AVG(EXTRACT(EPOCH FROM (a.closed_ts_utc - a.generated_ts_utc))/3600)
    FILTER (WHERE a.status='Closed')
  , 1) AS time_to_close_hours
FROM public.alerts a
JOIN public.transactions t ON t.txn_id = a.txn_id
GROUP BY a.case_id;
