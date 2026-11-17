# Loyalty Customer Analytics

An end-to-end ELT pipeline built with **Snowflake, dbt Core and SQL**, transforming raw loyalty programme data into structured, analytics-ready customer and transaction datasets.

This project demonstrates practical Analytics Engineering skills, including data ingestion, modular SQL transformations, dimensional modelling, data quality testing and Git-based version control.

---

## 1. Project Overview

The objective of this project is to build a cloud-based loyalty analytics data pipeline using Snowflake and dbt.

Synthetic customer, transaction and loyalty points data are loaded into Snowflake and transformed through three modelling layers:

- **Staging:** Standardise and clean raw source data.
- **Intermediate:** Combine customer, transaction and points activity at customer level.
- **Marts:** Produce business-ready dimension and fact tables.

### Key Objectives

- Build an end-to-end ELT pipeline using Snowflake and dbt.
- Develop modular and reusable SQL transformations.
- Apply data modelling principles and define appropriate data grain.
- Implement data quality tests and referential integrity checks.
- Manage project development using Git and GitHub.

## 2. Technology Stack

| Technology | Purpose |
|---|---|
| Snowflake | Cloud data warehouse and data storage |
| dbt Core | SQL-based data transformation and modelling |
| dbt-snowflake | Snowflake adapter for dbt |
| SQL | Data cleaning, transformation, aggregation and joins |
| Python | Synthetic data generation |
| Git | Version control |
| GitHub | Source code repository |

### Development Environment

- Python 3.13.14
- dbt Core 1.12.7
- dbt-snowflake 1.12.5
- Snowflake Python Connector 5.2.0

## 3. Data Overview

The project uses synthetic loyalty programme data generated using Python.

| Source Table | Records | Description |
|---|---:|---|
| CUSTOMERS | 5,000 | Customer profiles, signup dates, loyalty tiers and statuses |
| TRANSACTIONS | 50,000 | Customer transactions, spending and points earned |
| POINTS_LEDGER | 100,000 | Loyalty points earned and redeemed |
| **Total** | **155,000** | |

### Source Data Model

**CUSTOMERS**
- CUSTOMER_ID
- SIGNUP_DATE
- LOYALTY_TIER
- CUSTOMER_STATUS

**TRANSACTIONS**
- TRANSACTION_ID
- CUSTOMER_ID
- TRANSACTION_DATE
- SPEND
- POINTS_EARNED

**POINTS_LEDGER**
- LEDGER_ID
- CUSTOMER_ID
- TRANSACTION_ID
- ACTIVITY_DATE
- ACTIVITY_TYPE
- POINTS_CHANGE

The synthetic dataset contains two loyalty activity types:

- EARN: Positive points movement.
- REDEEM: Negative points movement.

## 4. Data Architecture

The pipeline follows a layered dbt architecture.

```text
       Python-generated CSV files
                  |
                  v
          SNOWFLAKE RAW
          /      |      \
         /       |       \
 CUSTOMERS  TRANSACTIONS  POINTS_LEDGER
         \       |       /
          \      |      /
                  |
                  v
          STAGING LAYER
             3 Views
       /       |        \
      /        |         \
stg_customers  stg_transactions  stg_points_ledger
                  |
                  v
        INTERMEDIATE LAYER
               1 View
                  |
                  v
     int_customer_loyalty_summary
                  |
                  v
            MARTS LAYER
              2 Tables
             /        \
            /          \
     dim_customers   fct_transactions
```

### Snowflake Schemas

| Schema | Purpose |
|---|---|
| RAW | Stores ingested source data |
| ANALYTICS | Stores dbt-generated models |

## 5. Data Models

The dbt project contains six models across three modelling layers.

### 5.1 Staging Layer

All staging models are materialised as Snowflake views.

| Model | Source | Transformation |
|---|---|---|
| stg_customers | RAW.CUSTOMERS | Standardises customer IDs, signup dates, loyalty tiers and customer statuses |
| stg_transactions | RAW.TRANSACTIONS | Standardises transaction IDs, customer IDs, dates and numeric fields |
| stg_points_ledger | RAW.POINTS_LEDGER | Standardises ledger IDs, activity dates, activity types and points changes |

Key transformations include:

- Trimming whitespace from identifiers.
- Standardising date and numeric data types.
- Normalising categorical values using uppercase formatting.
- Preserving source records and original points movement signs.

### 5.2 Intermediate Layer

**Model:** `int_customer_loyalty_summary`

**Materialisation:** View

**Grain:** One row per customer.

This model combines customer attributes, transaction summaries and loyalty points activity into a customer-level analytical dataset.

Key metrics include:

| Metric | Description |
|---|---|
| total_transactions | Number of distinct transactions |
| total_spend | Total customer spending |
| average_transaction_value | Average spend per transaction |
| transaction_points_earned | Points earned from transaction records |
| ledger_points_earned | Points earned from ledger records |
| total_points_redeemed | Total redeemed points, displayed as a positive value |
| net_points_movement | Net points movement from the ledger |

**Data modelling considerations:**

- Transaction and points ledger records are aggregated separately before joining to prevent join fan-out.
- LEFT JOINs preserve customers without transaction or points activity.
- COALESCE handles missing aggregated values.
- Transaction points and ledger points are retained as separate metrics rather than assumed to be equivalent.

### 5.3 Marts Layer

Marts models are materialised as Snowflake tables.

| Model | Grain | Description |
|---|---|---|
| dim_customers | One row per customer | Customer attributes, signup date, loyalty tier and status |
| fct_transactions | One row per transaction | Transaction-level spending, dates and points earned |

These models provide structured datasets suitable for downstream analytics and reporting.

## 6. Data Quality Testing

dbt generic data tests are implemented to validate data reliability and consistency.

### Tests Implemented

| Test | Purpose |
|---|---|
| not_null | Checks that required fields contain no NULL values |
| unique | Checks uniqueness of key identifiers |
| accepted_values | Validates permitted loyalty tiers, customer statuses and activity types |
| relationships | Validates referential integrity between related models |

### Full Build Results

The completed `dbt build` successfully executed all six models and their associated data quality tests.

| Metric | Result |
|---|---:|
| Models built | 6 |
| Data tests passed | 40 |
| Errors | 0 |
| Warnings | 0 |

The six models consist of:
- 3 staging views
- 1 intermediate view
- 2 marts tables

## 7. Repository Structure

```text
loyalty-customer-analytics/
│
├── data/
│   └── raw/
│       ├── customers.csv
│       ├── transactions.csv
│       └── points_ledger.csv
│
├── docs/
│
├── sql/
│   └── 01_create_environment.sql
│
├── loyalty_analytics/
│   ├── analyses/
│   ├── macros/
│   ├── models/
│   │   ├── staging/
│   │   │   ├── sources.yml
│   │   │   ├── stg_customers.sql
│   │   │   ├── stg_transactions.sql
│   │   │   └── stg_points_ledger.sql
│   │   │
│   │   ├── intermediate/
│   │   │   └── int_customer_loyalty_summary.sql
│   │   │
│   │   └── marts/
│   │       ├── dim_customers.sql
│   │       └── fct_transactions.sql
│   │
│   ├── seeds/
│   ├── snapshots/
│   ├── tests/
│   └── dbt_project.yml
│
├── generate_data.py
├── .gitignore
├── README.md
└── .gitignore
```

Generated files such as dbt logs, compiled targets, virtual environments and local credentials are excluded from version control.

## 8. How to Run the Project

### Prerequisites

- Python 3.13 or later
- Git
- A Snowflake account
- Access to a Snowflake warehouse

### Step 1: Clone the repository

```bash
git clone https://github.com/youkeefan/loyalty-customer-analytics.git

cd loyalty-customer-analytics
```

### Step 2: Generate synthetic data

```bash
python generate_data.py
```

This generates three CSV files in `data/raw/`.

### Step 3: Set up Snowflake

Execute the SQL script:

```text
sql/01_create_environment.sql
```

This script creates the required Snowflake database objects, including:

- LOYALTY_DB database
- RAW and ANALYTICS schemas
- LOYALTY_WH warehouse
- Raw source tables
- Internal stage and CSV file format
- Data loading statements

Upload the generated CSV files to the Snowflake internal stage using Snowsight, then execute the loading statements in the SQL script.

### Step 4: Set up the Python environment

Create and activate a virtual environment.

**Windows PowerShell:**

```powershell
python -m venv .venv

.\.venv\Scripts\Activate.ps1
```

Install dbt and the Snowflake adapter:

```bash
python -m pip install dbt-core==1.12.7 dbt-snowflake==1.12.5
```

### Step 5: Configure the Snowflake connection

Configure the local dbt profile at:

```text
~/.dbt/profiles.yml
```

Example configuration:

```yaml
loyalty_analytics:
  outputs:
    dev:
      type: snowflake
      account: <organization>-<account>
      user: <your_snowflake_user>
      authenticator: OAUTH_AUTHORIZATION_CODE
      role: <your_role>
      warehouse: LOYALTY_WH
      database: LOYALTY_DB
      schema: ANALYTICS
      threads: 4
  target: dev
```

Authentication settings may need to be adjusted for the Snowflake account being used.

Do not commit passwords, access tokens or private credentials to GitHub.

### Step 6: Validate the connection

From the repository root:

```bash
dbt debug --project-dir ./loyalty_analytics
```

### Step 7: Build the models and run tests

```bash
dbt build --project-dir ./loyalty_analytics
```

dbt will execute models in dependency order and run the associated data quality tests.

## 9. Key Learning Outcomes

This project demonstrates practical experience with:

**Snowflake**
- Database, schema and warehouse configuration.
- Internal stages and CSV data loading.
- Working with Snowflake authentication.

**dbt**
- Source definitions and model references.
- Modular SQL transformations.
- View and table materialisations.
- Model dependencies and build execution.
- Generic data quality tests.

**Data Engineering and Analytics Engineering**
- ELT pipeline design.
- SQL transformations and aggregations.
- Data modelling and grain definition.
- Multi-table joins and fan-out prevention.
- Referential integrity and data validation.

**Development Workflow**
- Python virtual environments.
- Git commits and remote repository management.
- GitHub-based project version control.

## 10. Project Scope and Disclaimer

This is an independent portfolio project built using synthetic loyalty programme data.

It demonstrates data engineering and analytics engineering concepts in a self-managed Snowflake environment. It is not a production commercial pipeline and does not use real customer or business data.

---

**Repository:** [GitHub – Loyalty Customer Analytics](https://github.com/youkeefan/loyalty-customer-analytics)


## 11. Customer Segmentation

### Overview

Developed a customer segmentation model using total customer spend and transaction frequency.

The model uses SQL window functions to rank customers into quartiles and classify them into four mutually exclusive customer segments.

### Methodology

- Used `NTILE(4)` to divide customers into quartiles based on total spend.
- Used `NTILE(4)` to divide customers into quartiles based on transaction frequency.
- Applied `CASE WHEN` logic to assign customer segments.
- Built the model using dbt `ref()` to maintain model dependencies.

### Customer Segments

| Customer Segment | Customers | Percentage |
|---|---:|---:|
| HIGH_VALUE | 919 | 18.38% |
| BIG_SPENDER | 331 | 6.62% |
| FREQUENT_CUSTOMER | 331 | 6.62% |
| DEVELOPING_CUSTOMER | 3,419 | 68.38% |
| **Total** | **5,000** | **100%** |

### Data Quality Validation

- 5,000 total customer records.
- 5,000 unique customer IDs.
- Zero null customer segments.
- Four additional dbt tests passed:
  - Customer ID not null.
  - Customer ID unique.
  - Customer segment not null.
  - Customer segment accepted values.

### Documentation and Lineage

Generated dbt documentation using `dbt docs generate` and reviewed the lineage graph to understand dependencies across staging, intermediate and marts models.

### GitHub Development Workflow

- Created a feature branch: `feature/customer-segmentation`.
- Committed and pushed model changes.
- Created and merged Pull Request #1 into `main`.
