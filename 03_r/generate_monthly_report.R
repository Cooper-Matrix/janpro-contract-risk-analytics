# Automated Monthly Report Generator
# Purpose: create a simple HTML management report using the latest contract risk data.

library(readr)
library(dplyr)

if (!dir.exists("sample_output")) {
  dir.create("sample_output")
}

# Run main analysis first so the output files exist.
source("r/contract_risk_analysis.R")

# Run predictive model so probability scores exist.
source("r/predictive_risk_model.R")

risk_summary <- read_csv("sample_output/contract_risk_summary.csv", show_col_types = FALSE)
portfolio_summary <- read_csv("sample_output/portfolio_summary.csv", show_col_types = FALSE)
predictions <- read_csv("sample_output/predictive_risk_scores.csv", show_col_types = FALSE)

latest_month <- max(risk_summary$month)
total_revenue <- sum(risk_summary$monthly_rate)
high_risk_count <- sum(risk_summary$risk_category == "High Risk")
high_risk_revenue <- sum(risk_summary$monthly_rate[risk_summary$risk_category == "High Risk"])
avg_margin <- round(mean(risk_summary$estimated_margin_pct), 2)
avg_inspection <- round(mean(risk_summary$inspection_score), 2)

high_risk_table <- risk_summary %>%
  filter(risk_category == "High Risk") %>%
  select(client_name, industry, monthly_rate, inspection_score, complaints, estimated_margin_pct, risk_score) %>%
  arrange(desc(risk_score))

prediction_table <- predictions %>%
  arrange(desc(predicted_high_risk_probability)) %>%
  select(client_name, industry, monthly_rate, predicted_high_risk_probability, predicted_risk_band) %>%
  head(10)

make_html_table <- function(df) {
  if (nrow(df) == 0) return("<p>No records found.</p>")
  header <- paste0("<tr>", paste0("<th>", names(df), "</th>", collapse = ""), "</tr>")
  rows <- apply(df, 1, function(row) paste0("<tr>", paste0("<td>", row, "</td>", collapse = ""), "</tr>"))
  paste0("<table>", header, paste(rows, collapse = ""), "</table>")
}

report_html <- paste0('
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Jan-Pro Contract Risk Monthly Report</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.5; }
    h1, h2 { color: #222; }
    .kpi { display: inline-block; padding: 15px; margin: 8px; border: 1px solid #ccc; border-radius: 8px; min-width: 180px; }
    .kpi strong { display: block; font-size: 22px; }
    table { border-collapse: collapse; width: 100%; margin-top: 15px; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background: #f2f2f2; }
    img { max-width: 900px; width: 100%; border: 1px solid #ddd; margin-top: 10px; }
  </style>
</head>
<body>
  <h1>Jan-Pro Contract Risk & Revenue Exposure Monthly Report</h1>
  <p><strong>Reporting Month:</strong> ', latest_month, '</p>
  <p>This report treats commercial cleaning contracts as a small operating portfolio. The goal is to identify contracts with revenue exposure, margin pressure, service-quality risk, and future high-risk probability.</p>

  <h2>Executive Summary</h2>
  <div class="kpi"><strong>$', format(total_revenue, big.mark = ','), '</strong>Total Monthly Revenue</div>
  <div class="kpi"><strong>', high_risk_count, '</strong>High-Risk Contracts</div>
  <div class="kpi"><strong>$', format(high_risk_revenue, big.mark = ','), '</strong>High-Risk Revenue Exposure</div>
  <div class="kpi"><strong>', avg_margin, '%</strong>Average Estimated Margin</div>
  <div class="kpi"><strong>', avg_inspection, '</strong>Average Inspection Score</div>

  <h2>High-Risk Contract Review</h2>
  ', make_html_table(high_risk_table), '

  <h2>Predictive Risk View</h2>
  <p>This section ranks contracts by estimated probability of becoming high-risk based on payment behavior, complaints, inspection scores, margin pressure, and labor hours.</p>
  ', make_html_table(prediction_table), '

  <h2>Charts</h2>
  <h3>Risk Score by Contract</h3>
  <img src="risk_score_by_contract.png" alt="Risk score by contract">
  <h3>Revenue Exposure by Risk Category</h3>
  <img src="revenue_exposure_by_risk.png" alt="Revenue exposure by risk">
  <h3>Predicted High-Risk Probability</h3>
  <img src="predicted_high_risk_probability.png" alt="Predicted high risk probability">

  <h2>Management Interpretation</h2>
  <p>The main operational concern is not just whether a contract is profitable today. It is whether service quality, payment behavior, and cost pressure show early signs of future revenue exposure. Contracts with high complaints, low inspection scores, late payments, or shrinking margins should be reviewed before renewal or pricing decisions are made.</p>
</body>
</html>
')

writeLines(report_html, "sample_output/monthly_contract_risk_report.html")

cat("Automated Monthly Report Complete\n")
cat("Open this file in your browser:\n")
cat("sample_output/monthly_contract_risk_report.html\n")
