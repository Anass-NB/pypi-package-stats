import os
from google.cloud import bigquery
from loguru import logger
import pandas as pd
from dotenv import load_dotenv
from ingestion.models import PypiJobParameters

PYPI_PUBLIC_TABLE = "bigquery-public-data.pypi.file_downloads"


load_dotenv()

def get_bq_client():
    """Initializes the BigQuery client using the service account file."""
    # Ensure GOOGLE_APPLICATION_CREDENTIALS is set in your environment
    return bigquery.Client()



def get_bq_result(params: PypiJobParameters) -> pd.DataFrame:
    """Runs the query and returns results as a DataFrame."""
    client = get_bq_client()
    query = build_pypi_query(params)

    logger.info(f"Executing query for project {params.pypi_project}...")

    # Using the BigQuery Storage API for better performance
    df = client.query(query).to_dataframe()

    logger.info(f"Retrieved {len(df)} rows.")
    return df



def build_pypi_query(
    params: PypiJobParameters, pypi_public_dataset: str = PYPI_PUBLIC_TABLE
) -> str:
    # Query the public PyPI dataset from BigQuery
    # /!\ This is a large dataset, filter accordingly /!\
    return f"""
    SELECT *
    FROM
        {pypi_public_dataset}
    WHERE
        project = '{params.pypi_project}'
        AND {params.timestamp_column} >= TIMESTAMP('{params.start_date}')
        AND {params.timestamp_column} < TIMESTAMP('{params.end_date}')
    """
