- there is a problem when the the command fails i should rerun all the jobs even some of them are passed succeful
- Where is the `.duckdb` file located in the ingestion step 
- Better change the name of the uploaded file 





### Ingestion 
✅ Full data of `ingestr` is available in the `https://ingestr-pypi-downloads.s3.us-east-1.amazonaws.com/raw_ingestr_pypi_downloads/` bucket. -> So you can use it to test the transformation step without running the ingestion step. as well as the dashboard step.

#### Questions in mind 
- running `make ingest` multiple times with same config what happends ? 