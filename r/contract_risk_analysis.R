# Jan-Pro Contract Risk & Revenue Exposure Analysis
# Purpose: Treat commercial service contracts like a small operating portfolio.
# Tools: R, dplyr, ggplot2, readr

library(readr)
library(dplyr)
library(ggplot2)

contracts <- read_csv("data/contracts.csv", show_col_types = FALSE)
performance <- read_csv("data/monthly_performance.csv", show_col_types = FALSE)

latest_month <- max(performance$month)

risk_summary <- performance %>%
  filter(month == latest_month) %>%
  left_join(contracts, by = "contract_id") %>%
  mutate(
    estimated_margin_dollars = monthly_rate - supply_cost - estimated_labor_cost,
    estimated_margin_pct = round((estimated_margin_dollars / monthly_rate) * 100, 2),
    risk_score =
      if_else(payment_status == "Late", 25, 0) +
      case_when(
        complaints >= 2 ~ 25,
        complaints == 1 ~ 15,
        TRUE ~ 0
      ) +
      case_when(
        inspection_score < 80 ~ 25,
        inspection_score < 85 ~ 20,
        inspection_score < 90 ~ 10,
        TRUE ~ 0
      ) +
      case_when(
        estimated_margin_pct < 15 ~ 20,
        estimated_margin_pct < 25 ~ 10,
        TRUE ~ 0
      ) +
      case_when(
        days_late >= 15 ~ 15,
        days_late > 0 ~ 10,
        TRUE ~ 0
      ),
    risk_category = case_when(
      risk_score >= 60 ~ "High Risk",
      risk_score >= 30 ~ "Moderate Risk",
      TRUE ~ "Low Risk"
    )
  ) %>%
  select(
    month, contract_id, client_name, industry, monthly_rate, payment_status,
    days_late, inspection_score, complaints, labor_hours, supply_cost,
    estimated_labor_cost, estimated_margin_dollars, estimated_margin_pct,
    risk_score, risk_category, renewal_date
  ) %>%
  arrange(desc(risk_score), desc(monthly_rate))

portfolio_summary <- risk_summary %>%
  group_by(risk_category) %>%
  summarise(
    contract_count = n(),
    monthly_revenue_exposure = sum(monthly_rate),
    average_margin_pct = round(mean(estimated_margin_pct), 2),
    average_inspection_score = round(mean(inspection_score), 2),
    total_complaints = sum(complaints),
    .groups = "drop"
  )

industry_summary <- risk_summary %>%
  group_by(industry) %>%
  summarise(
    contracts = n(),
    monthly_revenue = sum(monthly_rate),
    average_risk_score = round(mean(risk_score), 2),
    average_margin_pct = round(mean(estimated_margin_pct), 2),
    .groups = "drop"
  ) %>%
  arrange(desc(average_risk_score))

write_csv(risk_summary, "sample_output/contract_risk_summary.csv")
write_csv(portfolio_summary, "sample_output/portfolio_summary.csv")
write_csv(industry_summary, "sample_output/industry_summary.csv")

# Chart 1: Risk score by contract
risk_chart <- ggplot(risk_summary, aes(x = reorder(client_name, risk_score), y = risk_score)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Contract Risk Score by Client",
    x = "Client",
    y = "Risk Score"
  ) +
  theme_minimal()

ggsave("sample_output/risk_score_by_contract.png", risk_chart, width = 10, height = 6)

# Chart 2: Monthly revenue exposure by risk category
exposure_chart <- ggplot(portfolio_summary, aes(x = risk_category, y = monthly_revenue_exposure)) +
  geom_col() +
  labs(
    title = "Monthly Revenue Exposure by Risk Category",
    x = "Risk Category",
    y = "Monthly Revenue Exposure"
  ) +
  theme_minimal()

ggsave("sample_output/revenue_exposure_by_risk.png", exposure_chart, width = 8, height = 5)

cat("Jan-Pro Contract Risk Analysis Complete\n")
cat("Latest month analyzed:", latest_month, "\n")
cat("Total monthly revenue:", sum(risk_summary$monthly_rate), "\n")
cat("High-risk contracts:", sum(risk_summary$risk_category == "High Risk"), "\n")
cat("Moderate-risk contracts:", sum(risk_summary$risk_category == "Moderate Risk"), "\n")
