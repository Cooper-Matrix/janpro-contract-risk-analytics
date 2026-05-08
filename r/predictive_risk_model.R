# Jan-Pro Predictive Risk Scoring Model
# Purpose: Build a simple probability model that estimates which contracts may become high-risk.
# This mirrors early-stage portfolio risk modeling without needing confidential bank data.

library(readr)
library(dplyr)
library(ggplot2)

contracts <- read_csv("data/contracts.csv", show_col_types = FALSE)
performance <- read_csv("data/monthly_performance.csv", show_col_types = FALSE)

model_data <- performance %>%
  left_join(contracts, by = "contract_id") %>%
  mutate(
    estimated_margin_dollars = monthly_rate - supply_cost - estimated_labor_cost,
    estimated_margin_pct = round((estimated_margin_dollars / monthly_rate) * 100, 2),
    late_flag = if_else(payment_status == "Late", 1, 0),
    complaint_flag = if_else(complaints > 0, 1, 0),
    low_inspection_flag = if_else(inspection_score < 88, 1, 0),
    low_margin_flag = if_else(estimated_margin_pct < 25, 1, 0),
    high_risk_next_period = if_else(
      late_flag == 1 | complaints >= 2 | inspection_score < 85 | estimated_margin_pct < 20,
      1,
      0
    )
  )

# Simple logistic regression probability model.
# In plain English: this estimates the probability that a contract becomes high-risk based on operating signals.
risk_model <- glm(
  high_risk_next_period ~ days_late + complaints + inspection_score + estimated_margin_pct + labor_hours,
  data = model_data,
  family = binomial()
)

predictions <- model_data %>%
  mutate(
    predicted_high_risk_probability = round(predict(risk_model, type = "response"), 3),
    predicted_risk_band = case_when(
      predicted_high_risk_probability >= 0.60 ~ "High Probability",
      predicted_high_risk_probability >= 0.35 ~ "Moderate Probability",
      TRUE ~ "Low Probability"
    )
  ) %>%
  arrange(desc(predicted_high_risk_probability)) %>%
  select(
    month, contract_id, client_name, industry, monthly_rate,
    days_late, complaints, inspection_score, estimated_margin_pct, labor_hours,
    predicted_high_risk_probability, predicted_risk_band
  )

write_csv(predictions, "sample_output/predictive_risk_scores.csv")

# Export model coefficients so you can explain which factors drive risk.
model_coefficients <- as.data.frame(summary(risk_model)$coefficients)
model_coefficients$factor <- rownames(model_coefficients)
rownames(model_coefficients) <- NULL
write_csv(model_coefficients, "sample_output/predictive_model_coefficients.csv")

prediction_chart <- ggplot(predictions, aes(x = reorder(client_name, predicted_high_risk_probability), y = predicted_high_risk_probability)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Predicted High-Risk Probability by Contract",
    x = "Client",
    y = "Predicted Probability"
  ) +
  theme_minimal()

ggsave("sample_output/predicted_high_risk_probability.png", prediction_chart, width = 10, height = 6)

cat("Predictive Risk Model Complete\n")
cat("Rows modeled:", nrow(model_data), "\n")
cat("Average predicted risk probability:", round(mean(predictions$predicted_high_risk_probability), 3), "\n")
cat("High probability contracts:", sum(predictions$predicted_risk_band == "High Probability"), "\n")
