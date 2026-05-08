-- Jan-Pro Contract Portfolio JOIN Queries
-- Purpose: connect contract-level information with monthly operating performance.
-- These queries are designed to mirror portfolio monitoring, risk review, and management reporting.

-- 1. Full joined portfolio view
SELECT
    p.month,
    c.contract_id,
    c.client_name,
    c.industry,
    c.monthly_rate,
    c.renewal_date,
    p.payment_status,
    p.days_late,
    p.inspection_score,
    p.complaints,
    p.labor_hours,
    p.supply_cost,
    p.estimated_labor_cost,
    ROUND(c.monthly_rate - p.supply_cost - p.estimated_labor_cost, 2) AS estimated_margin_dollars,
    ROUND(((c.monthly_rate - p.supply_cost - p.estimated_labor_cost) / c.monthly_rate) * 100, 2) AS estimated_margin_pct
FROM contracts c
JOIN monthly_performance p
    ON c.contract_id = p.contract_id
ORDER BY p.month, c.monthly_rate DESC;

-- 2. Latest month risk score using SQL logic
WITH latest_month AS (
    SELECT MAX(month) AS month
    FROM monthly_performance
), joined_portfolio AS (
    SELECT
        p.month,
        c.contract_id,
        c.client_name,
        c.industry,
        c.monthly_rate,
        c.renewal_date,
        p.payment_status,
        p.days_late,
        p.inspection_score,
        p.complaints,
        p.supply_cost,
        p.estimated_labor_cost,
        ROUND(((c.monthly_rate - p.supply_cost - p.estimated_labor_cost) / c.monthly_rate) * 100, 2) AS estimated_margin_pct
    FROM contracts c
    JOIN monthly_performance p
        ON c.contract_id = p.contract_id
    JOIN latest_month lm
        ON p.month = lm.month
)
SELECT
    month,
    contract_id,
    client_name,
    industry,
    monthly_rate,
    payment_status,
    days_late,
    inspection_score,
    complaints,
    estimated_margin_pct,
    (
        CASE WHEN payment_status = 'Late' THEN 25 ELSE 0 END +
        CASE
            WHEN complaints >= 2 THEN 25
            WHEN complaints = 1 THEN 15
            ELSE 0
        END +
        CASE
            WHEN inspection_score < 80 THEN 25
            WHEN inspection_score < 85 THEN 20
            WHEN inspection_score < 90 THEN 10
            ELSE 0
        END +
        CASE
            WHEN estimated_margin_pct < 15 THEN 20
            WHEN estimated_margin_pct < 25 THEN 10
            ELSE 0
        END +
        CASE
            WHEN days_late >= 15 THEN 15
            WHEN days_late > 0 THEN 10
            ELSE 0
        END
    ) AS risk_score
FROM joined_portfolio
ORDER BY risk_score DESC, monthly_rate DESC;

-- 3. Revenue exposure by risk category for latest month
WITH latest_month AS (
    SELECT MAX(month) AS month
    FROM monthly_performance
), scored AS (
    SELECT
        c.contract_id,
        c.client_name,
        c.industry,
        c.monthly_rate,
        (
            CASE WHEN p.payment_status = 'Late' THEN 25 ELSE 0 END +
            CASE WHEN p.complaints >= 2 THEN 25 WHEN p.complaints = 1 THEN 15 ELSE 0 END +
            CASE WHEN p.inspection_score < 80 THEN 25 WHEN p.inspection_score < 85 THEN 20 WHEN p.inspection_score < 90 THEN 10 ELSE 0 END +
            CASE WHEN ROUND(((c.monthly_rate - p.supply_cost - p.estimated_labor_cost) / c.monthly_rate) * 100, 2) < 15 THEN 20
                 WHEN ROUND(((c.monthly_rate - p.supply_cost - p.estimated_labor_cost) / c.monthly_rate) * 100, 2) < 25 THEN 10 ELSE 0 END +
            CASE WHEN p.days_late >= 15 THEN 15 WHEN p.days_late > 0 THEN 10 ELSE 0 END
        ) AS risk_score
    FROM contracts c
    JOIN monthly_performance p
        ON c.contract_id = p.contract_id
    JOIN latest_month lm
        ON p.month = lm.month
)
SELECT
    CASE
        WHEN risk_score >= 60 THEN 'High Risk'
        WHEN risk_score >= 30 THEN 'Moderate Risk'
        ELSE 'Low Risk'
    END AS risk_category,
    COUNT(*) AS contract_count,
    SUM(monthly_rate) AS monthly_revenue_exposure,
    ROUND(AVG(risk_score), 2) AS average_risk_score
FROM scored
GROUP BY risk_category
ORDER BY monthly_revenue_exposure DESC;

-- 4. Contracts with renewal pressure and current operating risk
SELECT
    c.contract_id,
    c.client_name,
    c.industry,
    c.monthly_rate,
    c.renewal_date,
    p.month,
    p.payment_status,
    p.inspection_score,
    p.complaints,
    ROUND(((c.monthly_rate - p.supply_cost - p.estimated_labor_cost) / c.monthly_rate) * 100, 2) AS estimated_margin_pct
FROM contracts c
JOIN monthly_performance p
    ON c.contract_id = p.contract_id
WHERE p.month = (SELECT MAX(month) FROM monthly_performance)
ORDER BY c.renewal_date ASC, estimated_margin_pct ASC;

-- 5. Industry-level risk and margin review
SELECT
    c.industry,
    COUNT(DISTINCT c.contract_id) AS contract_count,
    SUM(c.monthly_rate) AS monthly_revenue,
    ROUND(AVG(p.inspection_score), 2) AS average_inspection_score,
    SUM(p.complaints) AS total_complaints,
    ROUND(AVG(((c.monthly_rate - p.supply_cost - p.estimated_labor_cost) / c.monthly_rate) * 100), 2) AS average_margin_pct
FROM contracts c
JOIN monthly_performance p
    ON c.contract_id = p.contract_id
GROUP BY c.industry
ORDER BY average_margin_pct ASC, total_complaints DESC;
