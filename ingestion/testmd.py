import duckdb 
import os 
    
motherduck_token = os.getenv('MOTHERDUCK_TOKEN')

con = duckdb.connect("md:")
con.sql(f"SET motherduck_token='{motherduck_token}';")


df = con.sql("SELECT * FROM pypi_remote.pypi_downloads").df()
print(df)