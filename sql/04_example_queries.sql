-- Rule performance
SELECT rule_name, alerts_total, tp_rate_closed, avg_close_hours
FROM public.v_rule_performance
WHERE alerts_total >= 100
ORDER BY tp_rate_closed DESC;

-- Geo hotspots
SELECT txn_country, alerts_total, avg_txn_risk_score, tp_rate_closed
FROM public.v_geo_hotspots
ORDER BY alerts_total DESC
LIMIT 10;

-- Case outcomes
SELECT outcome, COUNT(*) AS cases
FROM public.cases
GROUP BY outcome
ORDER BY cases DESC;

-- SLA by severity (case-level proxy)
SELECT
  a.severity,
  COUNT(DISTINCT a.case_id) AS cases,
  ROUND(AVG(c.time_to_close_hours), 2) AS avg_case_close_hours
FROM public.alerts a
JOIN public.cases c ON c.case_id = a.case_id
WHERE c.time_to_close_hours IS NOT NULL
GROUP BY a.severity
ORDER BY cases DESC;
