-include .env
export


ingest:
	@echo "START_DATE: $(START_DATE)"
	@echo "PYPI_PROJECT: $(PYPI_PROJECT)"
	uv run python -m ingestion.pipeline \
	    --start_date $(START_DATE) \
	    --end_date $(END_DATE) \
	    --pypi_project $(PYPI_PROJECT) \
	    --destination $(DESTINATION) \
	    --database_name $(DATABASE_NAME) \
	    --table_name $(TABLE_NAME) \
	    --s3_path $(S3_PATH) \
	    --aws_profile $(AWS_PROFILE) \
	    --gcp_project $(GCP_PROJECT) \
	    --timestamp_column $(TIMESTAMP_COLUMN) \
	    --dbt_duckdb_path $(DBT_DUCKDB_PATH) \
	    --skip_bigquery $(SKIP_BIGQUERY) \
	    --local_csv_path $(LOCAL_CSV_PATH) \
	    --dbt_database $(DBT_DATABASE) \
	    --dbt_schema $(DBT_SCHEMA) \



format:
	ruff format .


ingest-test:
	uv run pytest ingestion/tests


test-md:
	uv run python -m ingestion.testmd

pypi-transform: 
	echo "START_DATE: $(START_DATE)"
	echo "END_DATE: $(END_DATE)"
	dbt seed --project-dir transform/pypi_metrics --target $(DBT_TARGET)
	dbt run --project-dir transform/pypi_metrics --vars "{START_DATE: $(START_DATE), END_DATE: $(END_DATE)}" --target $(DBT_TARGET)


evidence-install:
	cd evidence && npm install


evidence-sources:
	cd evidence && npm run sources


evidence-dev:
	cd evidence && npm run dev


evidence-preview:
	cd evidence && npm run preview


evidence-build:
	cd evidence && npm run sources && npm run build:strict


evidence-deploy: evidence-build
	cd evidence && npm run deploy

