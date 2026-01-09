CREATE OR REPLACE VIEW public.v_alerts_daily AS
SELECT
  CAST(generated_ts_utc AS date) AS alert_date,
  COUNT(*) AS alerts_total,
  SUM(CASE WHEN status='Open' THEN 1 ELSE 0 END) AS alerts_open,
  SUM(CASE WHEN status='Closed' THEN 1 ELSE 0 END) AS alerts_closed,
  ROUND(
    1.0 * SUM(CASE WHEN decision='True Positive' THEN 1 ELSE 0 END)
    / NULLIF(SUM(CASE WHEN status='Closed' THEN 1 ELSE 0 END), 0)
  , 4) AS tp_rate_closed,
  ROUND(
    AVG(EXTRACT(EPOCH FROM (closed_ts_utc - generated_ts_utc))/3600)
    FILTER (WHERE status='Closed')
  , 2) AS avg_close_hours
FROM public.alerts
GROUP BY 1
ORDER BY 1;

CREATE OR REPLACE VIEW public.v_rule_performance AS
SELECT
  rule_name,
  COUNT(*) AS alerts_total,
  SUM(CASE WHEN status='Closed' THEN 1 ELSE 0 END) AS closed,
  ROUND(
    1.0 * SUM(CASE WHEN decision='True Positive' THEN 1 ELSE 0 END)
    / NULLIF(SUM(CASE WHEN status='Closed' THEN 1 ELSE 0 END), 0)
  , 4) AS tp_rate_closed,
  ROUND(
    AVG(EXTRACT(EPOCH FROM (closed_ts_utc - generated_ts_utc))/3600)
    FILTER (WHERE status='Closed')
  , 2) AS avg_close_hours
FROM public.alerts
GROUP BY 1
ORDER BY alerts_total DESC;

CREATE OR REPLACE VIEW public.v_geo_hotspots AS
SELECT
  t.txn_country,
  COUNT(*) AS alerts_total,
  ROUND(AVG(t.risk_score), 1) AS avg_txn_risk_score,
  ROUND(
    1.0 * SUM(CASE WHEN a.decision='True Positive' THEN 1 ELSE 0 END)
    / NULLIF(SUM(CASE WHEN a.status='Closed' THEN 1 ELSE 0 END), 0)
  , 4) AS tp_rate_closed
FROM public.alerts a
JOIN public.transactions t ON t.txn_id = a.txn_id
GROUP BY 1
ORDER BY alerts_total DESC;

CREATE OR REPLACE VIEW public.v_analyst_productivity AS
SELECT
  a.analyst_id,
  an.team,
  COUNT(*) AS alerts_total,
  SUM(CASE WHEN a.status='Closed' THEN 1 ELSE 0 END) AS closed,
  ROUND(
    AVG(EXTRACT(EPOCH FROM (a.closed_ts_utc - a.generated_ts_utc))/3600)
    FILTER (WHERE a.status='Closed')
  , 2) AS avg_close_hours,
  ROUND(
    1.0 * SUM(CASE WHEN a.decision='True Positive' THEN 1 ELSE 0 END)
    / NULLIF(SUM(CASE WHEN a.status='Closed' THEN 1 ELSE 0 END), 0)
  , 4) AS tp_rate_closed
FROM public.alerts a
LEFT JOIN public.analysts an ON an.analyst_id = a.analyst_id
GROUP BY 1,2
ORDER BY closed DESC;

CREATE OR REPLACE VIEW public.v_funnel_daily AS
WITH tx AS (
  SELECT CAST(txn_ts_utc AS date) AS d, COUNT(*) AS txns
  FROM public.transactions
  GROUP BY 1
),
al AS (
  SELECT CAST(generated_ts_utc AS date) AS d, COUNT(*) AS alerts
  FROM public.alerts
  GROUP BY 1
),
cs AS (
  SELECT CAST(opened_ts_utc AS date) AS d,
         COUNT(*) AS cases,
         SUM(CASE WHEN outcome='SAR filed' THEN 1 ELSE 0 END) AS sar
  FROM public.cases
  GROUP BY 1
)
SELECT
  tx.d AS date,
  tx.txns,
  COALESCE(al.alerts, 0) AS alerts,
  COALESCE(cs.cases, 0) AS cases,
  COALESCE(cs.sar, 0) AS sar_filed
FROM tx
LEFT JOIN al ON al.d = tx.d
LEFT JOIN cs ON cs.d = tx.d
ORDER BY date;
