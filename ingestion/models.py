from pydantic import BaseModel,Field,ConfigDict
from typing import List, Annotated,Union,Optional 
from datetime import datetime
import pandas as pd

class PypiJobParameters(BaseModel):
    start_date: str = "2026-09-01"
    end_date: str = "2026-09-02"
    pypi_project: str = "dbt"
    database_name: str
    table_name: str
    gcp_project: str
    timestamp_column: str = "timestamp"
    destination: Annotated[
        Union[List[str], str], Field(default=["local"])
    ]  # local, s3, md
    s3_path: Optional[str]
    aws_profile: Optional[str]




class File(BaseModel):
    model_config = ConfigDict(extra="ignore")

    filename: str | None = None
    project: str | None = None
    version: str | None = None
    type: str | None = None


class Installer(BaseModel):
    model_config = ConfigDict(extra="ignore")

    name: str | None = None
    version: str | None = None
    subcommand: str | None = None


class Implementation(BaseModel):
    model_config = ConfigDict(extra="ignore")

    name: str | None = None
    version: str | None = None


class Libc(BaseModel):
    model_config = ConfigDict(extra="ignore")

    lib: str | None = None
    version: str | None = None


class Distro(BaseModel):
    model_config = ConfigDict(extra="ignore")

    name: str | None = None
    version: str | None = None
    id: str | None = None
    libc: Libc | None = None


class System(BaseModel):
    model_config = ConfigDict(extra="ignore")

    name: str | None = None
    release: str | None = None


class Details(BaseModel):
    model_config = ConfigDict(extra="ignore")

    installer: Installer | None = None
    python: str | None = None
    implementation: Implementation | None = None
    distro: Distro | None = None
    system: System | None = None
    cpu: str | None = None
    openssl_version: str | None = None
    setuptools_version: str | None = None
    rustc_version: str | None = None
    ci: bool | None = None


class Http(BaseModel):
    model_config = ConfigDict(extra="ignore")

    method: str | None = None
    status_code: int | None = None
    bytes_served: int | None = None
    range_header: str | None = None


class DownloadEvent(BaseModel):
    model_config = ConfigDict(extra="ignore")

    timestamp: datetime
    country_code: str | None = None
    url: str
    project: str
    file: File
    details: Details | None = None
    tls_protocol: str | None = None
    tls_cipher: str | None = None
    http: Http | None = None
    
    
def     validate_dataframe(df: pd.DataFrame, model: Type[BaseModel]):
    """
    Validates each row of a DataFrame against a Pydantic model.
    Raises DataFrameValidationError if any row fails validation.

    :param df: DataFrame to validate.
    :param model: Pydantic model to validate against.
    :raises: DataFrameValidationError
    """
    errors = []

    for i, row in enumerate(df.to_dict(orient="records")):
        try:
            model(**row)
        except ValidationError as e:
            errors.append(f"Row {i} failed validation: {e}")

    if errors:
        error_message = "\n".join(errors)
        raise DataFrameValidationError(
            f"DataFrame validation failed with the following errors:\n{error_message}"
        )
