
from ingestion.bigquery import get_bq_result
from ingestion.models import PypiJobParameters,File,validate_dataframe
from ingestion.duck import create_table_from_dataframe,connect_to_md, load_aws_credentials,write_to_md_from_duckdb,write_to_s3_from_duckdb,write_to_duckdb_dbt_source,load_csv_to_duckdb_memory
import fire
import duckdb
from loguru import logger

def main(params: PypiJobParameters):
    print("Hello Pipeline .")
    
    if params.skip_bigquery:
        if not params.local_csv_path:
            raise ValueError("local_csv_path is required when skip_bigquery=True")
        conn = duckdb.connect()
        load_csv_to_duckdb_memory(conn, params.local_csv_path, params.table_name)
        logger.info(f"SKIPPED BigQuery; using local CSV: {params.local_csv_path}")
    else:
        df = get_bq_result(params)
        print(df)
        validate_dataframe(df, File)
        conn = duckdb.connect()
        create_table_from_dataframe(conn, params.table_name, df)
    
  
    if "local" in params.destination:
        local_path = f"{params.pypi_project}_project_from_{params.start_date}_to_{params.end_date}.csv"
        logger.info(f"LOADING DATA  TO LOCAL FILE: {local_path}")
        conn.sql(f"COPY {params.table_name} TO '{local_path}';")
        logger.success(f"DATA LOADED TO LOCAL FILE: {local_path}")
        
    if "s3" in params.destination:
        logger.info("LOADING TO S3...")
        load_aws_credentials(conn,'default')
        write_to_s3_from_duckdb(
            conn,params.table_name,"memory", params.s3_path,
        )
        logger.success("DATA LOADED TO S3")
    if "md" in params.destination:
        logger.info("LOADING TO MOTHERDUCK...")
        connect_to_md(conn)
        write_to_md_from_duckdb(conn,params.table_name,"memory","pypi_remote",params.timestamp_column,params.start_date,params.end_date)
        logger.success("DATA LOADED TO MOTHERDUCK")
    if "dbt" in params.destination:
        logger.info("LOADING TO DBT DUCKDB...")
        write_to_duckdb_dbt_source(conn,params.table_name,params.dbt_duckdb_path,params.dbt_database,params.dbt_schema)
        logger.success("DATA LOADED TO DBT DUCKDB")
    
if __name__ == "__main__":
    fire.Fire(lambda **kwargs: main(PypiJobParameters(**kwargs)))
