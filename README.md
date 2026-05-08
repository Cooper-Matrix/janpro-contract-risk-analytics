### Jan-Pro Contract Risk Analytics System

![SQL](https://img.shields.io/badge/SQL-SQLite-blue)
![R](https://img.shields.io/badge/R-Analytics-276DC3)
![Risk Analytics](https://img.shields.io/badge/Focus-Risk%20Analytics-green)
![Status](https://img.shields.io/badge/Project-Active-success)

#### Table of Contents

* [Overview](#overview)
* [Business Objective](#business-objective)
* [Technologies Used](#technologies-used)
* [Project Structure](#project-structure)
* [Analytical Workflow](#analytical-workflow)
* [Database Design](#database-design)
* [SQL Portfolio Analytics](#sql-portfolio-analytics)
* [Predictive Risk Modeling](#predictive-risk-modeling)
* [Automated Reporting](#automated-reporting)
* [Example Business Insights](#example-business-insights)
* [Key Skills Demonstrated](#key-skills-demonstrated)
* [Future Improvements](#future-improvements)
* [Author](#author)

#### Overview

This project is a SQL and R-based operational risk analytics system designed to model a commercial contract portfolio similarly to how financial institutions monitor account and revenue exposure.

The system structures Jan-Pro commercial cleaning contracts into a relational database, applies portfolio-style risk analysis, and generates automated analytical reporting using SQL and R.

The goal of the project was to simulate real-world analytical workflows used in:

* Risk analytics
* Operations analytics
* Business intelligence
* Portfolio monitoring
* Revenue exposure analysis
* Predictive operational modeling

---

#### Business Objective

Commercial service contracts carry operational and financial risk similarly to customer accounts within banking or portfolio environments.

This project was designed to:

* Monitor operational contract risk
* Analyze revenue exposure
* Identify high-risk accounts
* Track margin pressure
* Evaluate renewal exposure
* Automate reporting workflows
* Support operational decision-making through data analysis

---

#### Technologies Used

### SQL / SQLite

* Relational database design
* Table creation and normalization
* JOIN-based analytical queries
* Portfolio segmentation queries
* Risk exposure analysis

### R

* Data transformation
* Predictive risk scoring
* Statistical calculations
* Automated reporting
* Data visualization with ggplot2

### Additional Tools

* DB Browser for SQLite
* GitHub
* HTML reporting
* CSV data integration

---

#### Project Structure

```text
janpro-contract-risk-analytics/
│
├── 01_sql/
│   ├── create_tables.sql
│   ├── portfolio_join_queries.sql
│   └── risk_queries.sql
│
├── 02_data/
│   ├── contracts.csv
│   └── monthly_performance.csv
│
├── 03_r/
│   ├── contract_risk_analysis.R
│   ├── predictive_risk_model.R
│   └── generate_monthly_report.R
│
├── 04_sample_output/
│   ├── risk_score_by_contract.png
│   ├── revenue_exposure_by_risk.png
│   └── monthly_contract_risk_report.html
│
├── 05_powerbi/
│
├── janpro_risk.db
└── README.md
```

---

#### Analytical Workflow

```text
CSV Operational Data
        ↓
Relational SQL Database
        ↓
JOIN-Based Portfolio Analysis
        ↓
R Risk Modeling & Analytics
        ↓
Automated Charts & Reporting
        ↓
Operational Decision Support
```

---

#### Database Design

The project uses relational SQL tables to model operational portfolio relationships.

### Contracts Table

Stores:

* Contract identifiers
* Client names
* Industry type
* Monthly revenue
* Renewal dates
* Service frequency
* Contract status

### Monthly Performance Table

Stores:

* Complaint counts
* Inspection scores
* Supply costs
* Labor costs
* Payment status
* Operational performance metrics

The tables are connected using:

```sql
contract_id
```

This enables JOIN-based analytical queries across operational and financial datasets.

---

#### SQL Portfolio Analytics

Example JOIN query:

```sql
SELECT c.client_name,
       c.monthly_rate,
       m.complaints,
       m.inspection_score
FROM contracts c
JOIN monthly_performance m
ON c.contract_id = m.contract_id;
```

Example analytical outputs:

* High-risk contracts
* Revenue exposure by risk category
* Margin analysis
* Complaint trend analysis
* Renewal exposure monitoring
* Portfolio segmentation

---

#### Predictive Risk Modeling

The R analytics layer applies operational risk scoring using variables such as:

* Late payment status
* Complaint frequency
* Inspection performance
* Margin pressure
* Operational cost exposure
* Renewal proximity

Example risk scoring logic:

```text
Late Payment → +25 Risk Points
High Complaints → +25 Risk Points
Low Inspection Score → +20 Risk Points
Low Margin → +15 Risk Points
```

Risk categories:

* Low Risk
* Moderate Risk
* High Risk

---

#### Automated Reporting

The project automatically generates:

* Risk charts
* Revenue exposure visualizations
* Portfolio summaries
* HTML analytical reports

Generated reports are exported into:

```text
04_sample_output/
```

---

#### Example Business Insights

Example outputs include:

* Total monthly portfolio revenue
* Revenue tied to high-risk contracts
* Accounts with declining operational performance
* Clients approaching renewal risk
* Margin erosion across accounts
* Complaint concentration analysis

---

#### Key Skills Demonstrated

### Data & Analytics

* SQL querying
* Relational database management
* JOIN operations
* Risk analytics
* Portfolio analysis
* Data visualization
* Predictive modeling

### Operations & Business Intelligence

* Operational reporting
* Revenue exposure analysis
* Risk monitoring
* Process automation
* KPI tracking
* Structured analytical workflows

### Technical Communication

* Analytical documentation
* Portfolio reporting
* Data interpretation
* Executive-style summaries

---

#### Future Improvements

Planned future upgrades:

* Power BI dashboard integration
* Expanded predictive modeling
* Automated PDF reporting
* Real-time database updates
* Route efficiency analysis
* Forecasting models
* Interactive executive dashboards

---

#### Author

**Cooper Davis**

Operations-focused business analyst with interests in:

* Risk analytics
* Business intelligence
* Operational systems
* Financial analytics
* Data-driven decision making

GitHub: [https://github.com/Cooper-Matrix](https://github.com/Cooper-Matrix)
