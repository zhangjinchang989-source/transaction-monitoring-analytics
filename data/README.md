## Data
CSV files are not included in this repo.
Tables were populated from a synthetic transaction monitoring dataset (CSV).
To reproduce results, import the dataset into PostgreSQL tables defined in `sql/01_schema.sql`,
then run the scripts in `sql/02_case_assignment_rolling_30d.sql` and `sql/03_views.sql`.
