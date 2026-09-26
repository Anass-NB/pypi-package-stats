import os
from loguru import logger





def create_table_from_dataframe(duckdb_con, table_name: str, df):
   
    
    duckdb_con.sql(
        f"""
        CREATE TABLE {table_name} AS 
            SELECT *
            FROM df
        """
    )

def connect_to_md(duckdb_con):
    motherduck_token = os.getenv('MOTHERDUCK_TOKEN')
    duckdb_con.sql(f"INSTALL md;")
    duckdb_con.sql(f"LOAD md;")
    duckdb_con.sql(f"SET motherduck_token='{motherduck_token}';")
    duckdb_con.sql(f"ATTACH 'md:'")
    
def write_to_md_from_duckdb(
    duckdb_con,
    table: str,
    local_database: str,
    remote_database: str,
    timestamp_column: str,
    start_date: str,
    end_date: str,
):
    logger.info(f"Writing data to motherduck {remote_database}.main.{table}")
    duckdb_con.sql(f"CREATE DATABASE IF NOT EXISTS {remote_database}")
    duckdb_con.sql(
        f"CREATE OR REPLACE TABLE  {remote_database}.{table} AS SELECT * FROM {local_database}.{table} limit 0"
    )
    # Delete any existing data in the date range
    duckdb_con.sql(
        f"DELETE FROM {remote_database}.main.{table} WHERE {timestamp_column} BETWEEN '{start_date}' AND '{end_date}'"
    )
    # Insert new data
    duckdb_con.sql(
        f"""
        INSERT INTO {remote_database}.main.{table}
        SELECT *
        FROM {local_database}.{table}"""
    )
    logger.success(f"Data saved to motherduck {remote_database}.main.{table}")





def load_aws_credentials(duckdb_con, profile_name: str):
    """
    Load AWS credentials from the specified profile in ~/.aws/credentials
    and set them as environment variables.
    """
    duckdb_con.sql(f"CALL load_aws_credentials('{profile_name}');")
    
    
    
def write_to_s3_from_duckdb(
    duckdb_con,
    table: str,
    local_database: str,
    s3_path: str,
):
    logger.info(f"Writing data to S3 bucket :  {s3_path}/{table}")
    s3_file = s3_path.rstrip("/") + f"/{table}"


    duckdb_con.sql(
        f"""
        COPY( 
            SELECT * , YEAR(timestamp) as year, MONTH(timestamp) as month,
            FROM {table})
            TO '{s3_file}'
            (FORMAT PARQUET, PARTITION_BY (year, month), OVERWRITE_OR_IGNORE 1, COMPRESSION 'ZSTD', ROW_GROUP_SIZE 1000000);
        """
    )
    logger.info(f"Data saved to S3 location :  {s3_file}")