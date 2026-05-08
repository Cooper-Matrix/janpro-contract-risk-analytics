# Power BI Dashboard Build Guide

## Project Title
Jan-Pro Contract Risk & Revenue Exposure Dashboard

## Data Files To Load
Load these CSV files from the `sample_output` folder after running the R scripts:

1. `contract_risk_summary.csv`
2. `portfolio_summary.csv`
3. `industry_summary.csv`
4. `predictive_risk_scores.csv`

## Recommended Dashboard Pages

### Page 1: Executive Risk Overview
Cards:
- Total Monthly Revenue
- High-Risk Contract Count
- High-Risk Revenue Exposure
- Average Inspection Score
- Average Estimated Margin %

Charts:
- Revenue Exposure by Risk Category
- Contract Count by Risk Category
- Risk Score by Client

### Page 2: Contract Detail Review
Table columns:
- Client Name
- Industry
- Monthly Rate
- Payment Status
- Days Late
- Inspection Score
- Complaints
- Estimated Margin %
- Risk Score
- Risk Category
- Renewal Date

Slicers:
- Industry
- Risk Category
- Payment Status
- Renewal Date

### Page 3: Predictive Risk View
Charts:
- Predicted High-Risk Probability by Client
- Average Predicted Probability by Industry
- Monthly Revenue by Predicted Risk Band

Table columns:
- Client Name
- Industry
- Monthly Rate
- Predicted High-Risk Probability
- Predicted Risk Band

## Suggested DAX Measures

```DAX
Total Monthly Revenue = SUM(contract_risk_summary[monthly_rate])
```

```DAX
High Risk Contracts =
CALCULATE(
    COUNTROWS(contract_risk_summary),
    contract_risk_summary[risk_category] = "High Risk"
)
```

```DAX
High Risk Revenue Exposure =
CALCULATE(
    SUM(contract_risk_summary[monthly_rate]),
    contract_risk_summary[risk_category] = "High Risk"
)
```

```DAX
Average Margin % = AVERAGE(contract_risk_summary[estimated_margin_pct])
```

```DAX
Average Inspection Score = AVERAGE(contract_risk_summary[inspection_score])
```

```DAX
Average Predicted Risk Probability = AVERAGE(predictive_risk_scores[predicted_high_risk_probability])
```

## Resume Framing
Built a SQL, R, and Power BI contract risk monitoring system that analyzed commercial service contracts by revenue exposure, payment behavior, complaint trends, inspection performance, margin pressure, renewal risk, and predicted high-risk probability.
