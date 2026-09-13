from ingestion.bigquery import  PYPI_PUBLIC_TABLE




def test_pypi_public_table():
    assert PYPI_PUBLIC_TABLE == "bigquery-public-data.pypi.file_downloads"