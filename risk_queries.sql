-- Contract risk model summary
-- This query calculates margin, contract risk score, and portfolio exposure.

WITH latest_month AS (
    SELECT MAX(month) AS month
    FROM monthly_performance
), base AS (
    SELECT
        c.contract_id,
        c.client_name,
        c.industry,
        c.monthly_rate,
        c.renewal_date,
        p.month,
        p.payment_status,
        p.days_late,
        p.inspection_score,
        p.complaints,
        p.labor_hours,
        p.supply_cost,
        p.estimated_labor_cost,
        (c.monthly_rate - p.supply_cost - p.estimated_labor_cost) AS estimated_margin_dollars,
        ROUND((c.monthly_rate - p.supply_cost - p.estimated_labor_cost) / c.monthly_rate * 100, 2) AS estimated_margin_pct
    FROM contracts c
    JOIN monthly_performance p
        ON c.contract_id = p.contract_id
    JOIN latest_month lm
        ON p.month = lm.month
), scored AS (
    SELECT
        *,
        CASE WHEN payment_status = 'Late' THEN 25 ELSE 0 END +
        CASE WHEN complaints >= 2 THEN 25 WHEN complaints = 1 THEN 15 ELSE 0 END +
        CASE WHEN inspection_score < 80 THEN 25 WHEN inspection_score < 85 THEN 20 WHEN inspection_score < 90 THEN 10 ELSE 0 END +
        CASE WHEN estimated_margin_pct < 15 THEN 20 WHEN estimated_margin_pct < 25 THEN 10 ELSE 0 END +
        CASE WHEN days_late >= 15 THEN 15 WHEN days_late > 0 THEN 10 ELSE 0 END AS risk_score
    FROM base
)
SELECT
    *,
    CASE
        WHEN risk_score >= 60 THEN 'High Risk'
        WHEN risk_score >= 30 THEN 'Moderate Risk'
        ELSE 'Low Risk'
    END AS risk_category
FROM scored
ORDER BY risk_score DESC, monthly_rate DESC;
