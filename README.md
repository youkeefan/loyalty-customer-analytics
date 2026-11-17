# Loyalty Customer Analytics

An end-to-end ELT pipeline built with **Snowflake, dbt and SQL**, transforming raw loyalty data into analytics-ready customer and transaction datasets.

## 1. Project Overview

This project simulates a loyalty analytics data platform. It demonstrates how raw customer, transaction and loyalty points data can be ingested into Snowflake, transformed using dbt, and organised into analytics-ready data models.

The pipeline follows a layered data architecture consisting of Staging, Intermediate and Marts.

**Key objectives:**
- Build an end-to-end ELT pipeline using Snowflake and dbt.
- Develop modular and reusable SQL transformations.
- Apply data modelling principles and define appropriate data grain.
- Implement data quality tests to improve data reliability.
- Manage project development using Git and GitHub.

## 2. Technology Stack

| Technology | Purpose |
|---|---|
| Snowflake | Cloud data warehouse |
| dbt Core | Data transformation and modelling |
| dbt-snowflake | Snowflake adapter |
| SQL | Data transformation and aggregation |
| Python | Synthetic data generation |
| Git & GitHub | Version control and collaboration |

## 3. Data Overview

The project uses synthetic loyalty programme data generated with Python.

| Source table | Records | Description |
|---|---:|---|
| Customers | 5,000 | Customer profiles, signup dates, loyalty tiers and statuses |
| Transactions | 50,000 | Customer transactions, spending and points earned |
| Points Ledger | 100,000 | Loyalty points earned and redeemed |
| **Total** | **155,000** | |

## 4. Data Architecture

```text
Python-generated CSV files
          |
          v
     Snowflake RAW
          |
          v
   STAGING (3 Views)
   - stg_customers
   - stg_transactions
   - stg_points_ledger
          |
          v
 INTERMEDIATE (1 View)
 - int_customer_loyalty_summary
          |
          v
      MARTS (2 Tables)
      - dim_customers
      - fct_transactions
```

## 5. Data Models

### Staging Layer

Standardises raw source data through:
- Column naming and data type standardisation.
- Trimming whitespace from identifiers.
- Normalising loyalty tiers, customer statuses and activity types.
- Preserving source records for downstream transformations.

### Intermediate Layer

`int_customer_loyalty_summary`

Creates a customer-level dataset by combining customer attributes, transaction summaries and loyalty points activity.

Key metrics include:
- Total transactions
- Total spend
- Average transaction value
- Transaction points earned
- Ledger points earned
- Total points redeemed
- Net points movement

The model aggregates transactions and points ledger records separately before joining them to prevent join fan-out.

### Marts Layer

| Model | Grain | Description |
|---|---|---|
| dim_customers | One row per customer | Customer attributes, loyalty tier and status |
| fct_transactions | One row per transaction | Transaction date, spending and points earned |

## 6. Data Quality Testing

Implemented dbt generic data tests, including:
- `not_null`
- `unique`
- `accepted_values`
- `relationships`

Tests validate key identifiers, accepted loyalty categories and referential integrity between customers, transactions and points ledger records.

**Latest full dbt build:**
- 6 models successfully built
- 40 data tests passed
- 0 errors
- 0 warnings

## 7. Project Structure

```text
loyalty-customer-analytics/
│
├── data/
│   └── raw/
│       ├── customers.csv
│       ├── transactions.csv
│       └── points_ledger.csv
│
├── sql/
│   └── 01_create_environment.sql
│
├── loyalty_analytics/
│   ├── dbt_project.yml
│   └── models/
│       ├── staging/
│       ├── intermediate/
│       └── marts/
│
├── generate_data.py
├── .gitignore
└── README.md
```

## 8. How to Run

1. Generate synthetic data using `generate_data.py`.
2. Execute the Snowflake environment setup SQL in `sql/01_create_environment.sql`.
3. Upload and load the CSV files into the Snowflake RAW schema.
4. Configure a local dbt Snowflake profile with your own account credentials and authentication settings.
5. Install the required dbt dependencies.
6. Navigate to the dbt project and execute:

```bash
dbt debug
dbt build
```

## 9. Key Learning Outcomes

This project demonstrates practical experience with:
- Snowflake data ingestion and warehouse configuration.
- dbt sources, refs, modular models and materialisations.
- SQL transformations, aggregations and multi-table joins.
- Dimensional modelling and data grain.
- Data quality testing and referential integrity.
- Git branching, commits and GitHub repository management.

---

**Note:** This is an independent portfolio project using synthetic data. It is designed to demonstrate practical data engineering and analytics engineering skills rather than production commercial experience.
