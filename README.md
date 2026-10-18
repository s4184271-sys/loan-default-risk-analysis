# Loan Default Risk Analysis | PostgreSQL & Power BI

An end-to-end analysis of **1.35 million loans** that uses PostgreSQL for data preparation and analysis and Power BI for an interactive 5-page dashboard. The project shows which borrower, loan and geographic characteristics are associated with higher default rates.

**Headline result:** 19.98% of loans defaulted overall, but the rate ranges from **6.0% (Grade A) to 49.7% (Grade G)**. Grade, loan term and DTI separate risk far more than geography or employment length.

---

## Table of Contents

1. [Dashboard Preview](#dashboard-preview)
2. [Business Problem](#business-problem)
3. [Tools and Technologies](#tools-and-technologies)
4. [Dataset and Preparation](#dataset-and-preparation)
5. [Key Performance Indicators](#key-performance-indicators)
6. [Dashboard Pages](#dashboard-pages)
7. [Key Findings](#key-findings)
8. [Recommendations](#recommendations)
9. [SQL Analysis](#sql-analysis)
10. [Repository Structure](#repository-structure)
11. [How to Explore the Project](#how-to-explore-the-project)
12. [Data Quality Notes](#data-quality-notes)
13. [Limitations](#limitations)
14. [Future Improvements](#future-improvements)
15. [Skills Demonstrated](#skills-demonstrated)
16. [Disclaimer](#disclaimer)
17. [Author](#author)

---

## Dashboard Preview

| Page | Preview |
|---|---|
| 1. Executive Overview | ![Overview](screenshots/01_overview.png) |
| 2. Risk Analysis | ![Risk Analysis](screenshots/02_risk_analysis.png) |
| 3. Customer & Loan Segments | ![Segments](screenshots/03_customer_loan_segments.png) |
| 4. Geographic Analysis | ![Geographic](screenshots/04_geographic_analysis.png) |
| 5. Detailed Analysis | ![Detailed](screenshots/05_detailed_analysis.png) |

**[View or download the Power BI Dashboard (.pbix)](https://drive.google.com/file/d/1f_oy951PJMYAy_es_ThrGrjTgym2meLO/view?usp=sharing)**

The Power BI file is hosted on Google Drive because of its size. Ensure the link permissions allow viewers to access the file.

---

## Business Problem

Loan defaults create financial losses for lenders. Knowing which loan and borrower characteristics are associated with higher default rates helps lenders assess portfolio risk and prioritise monitoring.

The project answers:

- Which loan grades and sub-grades have the highest default rates?
- How do debt-to-income (DTI) ratio and revolving credit utilization relate to default risk?
- Which loan purposes show the highest default rates?
- How do income, home ownership and employment length relate to repayment outcomes?
- Do loan term and loan amount show different default patterns?
- How do default rates and default volumes vary by state?
- Which combinations of grade, DTI, utilization, term and purpose show elevated risk?
- How did the monthly default rate move over time?

---

## Tools and Technologies

| Tool | Use |
|---|---|
| **PostgreSQL** | Data cleaning, feature engineering, the `loans_enriched` view, and SQL analysis using CTEs, window functions and aggregation |
| **Power Query (M)** | Light transformations in Power BI, including handling blank purposes, label fixes and sort-order helper columns |
| **Microsoft Power BI** | Five-page interactive dashboard, slicers, heatmap matrices and conditional formatting |
| **DAX** | Measures for total loans, total defaults, default rate, averages and shares |
| **GitHub** | Version control and documentation |

---

## Dataset and Preparation

The analysis uses a loan dataset prepared in PostgreSQL through an enriched view named `loans_enriched`.

- **Source:** [Add dataset name and link]
- **Issue period:** [Add start and end dates]
- **Scope:** Resolved loans only, meaning loans with a final outcome (fully paid, charged off or default, including the credit-policy status variants). Loans still current or late have no final outcome, so including them would distort default rates.

### Default definition

`is_default` is `1` for loans with a charged-off or default status and `0` for fully paid loans, including the corresponding credit-policy status categories.

### Key fields

| Field | Description |
|---|---|
| `is_default` | 1 if the loan defaulted or was charged off, otherwise 0 |
| `grade`, `sub_grade` | Loan risk grade (A to G) and finer classification (A1 to G5) |
| `annual_inc`, `income_bracket` | Borrower income and category (<$30K, $30K–$60K, $60K–$100K, $100K+) |
| `dti`, `dti_band` | Debt-to-income ratio and band (Low 0–15%, Medium 15–25%, High 25–35%, Very High 35%+) |
| `revol_util`, `revol_util_band` | Revolving utilization and band (Low <20%, Moderate 20–40%, High 40–60%, Very High 60–80%, Extremely High 80%+, Unknown) |
| `loan_amnt`, loan amount band | Loan amount and band (<$5K, $5K–$10K, $10K–$20K, $20K–$30K, $30K+) |
| `purpose` | Stated purpose of the loan |
| `home_ownership` | Reported housing status |
| `emp_length` | Employment length |
| `term` | 36 or 60 months |
| `addr_state` | Borrower's state |
| `issue_d` | Loan issue date |

### Preparation steps

1. Loaded the raw data into a staging table, then built a typed, cleaned table.
2. Removed or flagged invalid values and kept resolved loans only.
3. Built derived bands (income, DTI, utilization, loan amount) in the `loans_enriched` view.
4. In Power Query, grouped blank purposes as **Unknown**, standardised labels (for example, "Educational") and added helper columns so bands sort in logical order rather than alphabetically.

---

## Key Performance Indicators

| KPI | Value |
|---|---:|
| Total Loans | 1,348,099 |
| Total Defaults | 269,360 |
| Overall Default Rate | 19.98% (observed) |
| Total Loan Amount | About $19 billion |
| Average Loan Amount | $14,409 |
| Average Annual Income | $76.24K |
| Average DTI | 18.3% |

Default rate is calculated as:

```text
Default Rate = Total Defaults / Total Loans × 100
```

In Power BI, the measure uses `DIVIDE()` and is formatted as a percentage. Revalidate these figures if the dataset, relationships or filtering logic changes.

---

## Dashboard Pages

All pages share slicers for **Year, Month, Grade, Purpose and State**. The Detailed Analysis page adds **Sub Grade, Income Bracket, DTI Band, Revolving Utilization Band, Term and Home Ownership**.

### 1. Executive Overview

Includes KPI cards, default rate by grade, loan purpose distribution, monthly default-rate trend, default rate by home ownership, top 10
