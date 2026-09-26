import duckdb
con = duckdb.connect('dev.duckdb')
print("Tables:", con.execute("SHOW TABLES").fetchall())
try:
    print("Schema main:", con.execute("SELECT * FROM information_schema.tables WHERE table_schema='main'").fetchall()[:10])
except Exception as e:
    print("Error:", e)
