# Data

This project analyses COVID-19 mortality across English local authorities using demographic, health, deprivation and housing indicators.

The analytical dataset was prepared from multiple source tables and standardised at local authority level.

## Data Preparation

SQL was used to:

- Harmonise local authority codes affected by boundary and naming changes
- Aggregate COVID-19 deaths by local authority
- Join multiple tables using `LA_code`
- Preserve the local authority structure during integration
- Prepare a consistent analytical base for statistical analysis in R

The SQL workflow is available in:

`sql/data_preparation.sql`

## Final Analytical Dataset

The final dataset contained **296 English local authorities**.

Variables included:

- COVID-19 deaths per 1,000 residents
- Age structure indicators
- Self-reported health indicators
- Shared and unshared dwelling indicators
- Household deprivation indicators

The raw and processed datasets are not included in this repository because the project used multiple source files and the repository is intended to present the analytical workflow rather than redistribute the original data.
