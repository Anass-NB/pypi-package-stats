# pypi_metrics — dbt transformation layer

Analytics models over PyPI file-download events (`bigquery-public-data.pypi.file_downloads`,
ingested as `raw_pypi_downloads`). One row per download event, modeled as a star schema.

## Layers

```
raw_pypi_downloads (source: external_source)
  -> staging:     stg_pypi__downloads            (view  | 1:1 flatten, rename, light cast — no logic)
  -> intermediate: int_downloads + 4 parsers + int_downloads_enriched (views | event_id, parsing, 'Unknown' conforming)
  -> marts:        7 dims + fct_downloads         (tables | fct is incremental on downloaded_at)
```

- **Staging** (`models/staging/`): one model per source table. Flatten nested structs
  (`file.*`, `details.installer.*`, `details.system.*`), rename (`timestamp -> downloaded_at`),
  cast timestamps. No joins, no `CASE WHEN`, no dedupe.
- **Intermediate** (`models/intermediate/`): business logic. `int_downloads` adds the stable
  `event_id` (hash + duplicate rank, duplicates kept). `int_python_parsed`, `int_file_parsed`,
  `int_installer_classified`, `int_platform_normalized` each isolate one parsing job.
  `int_downloads_enriched` joins them and coalesces dimension-bound columns to `'Unknown'`.
- **Marts** (`models/marts/`): star schema for BI. `dim_project`, `dim_project_version`,
  `dim_file`, `dim_python`, `dim_installer`, `dim_platform`, `dim_country`, `dim_date`
  (each with a `'-1' / 'Unknown'` member) + `fct_downloads` (`1 as download_count` per row,
  FKs never null, incremental `delete+insert` on `downloaded_at`).

## Sources

Declared in `models/staging/pypi/_pypi__sources.yml` (`external_source.raw_pypi_downloads`).
The database/schema come from env vars so the same code runs locally and in cloud:

| Target | Profile | `TRANSFORM_DATABASE` | `TRANSFORM_SCHEMA` |
|--------|---------|----------------------|--------------------|
| `dev`  | local DuckDB file | `dev` | `main` |
| `prod` | MotherDuck `md:pypi_remote` | `pypi_remote` | `main` |

## Usage

```bash
# run + test locally (DuckDB)
TRANSFORM_DATABASE=dev TRANSFORM_SCHEMA=main \
  dbt build --project-dir transform/pypi_metrics --target dev

# run in cloud (MotherDuck) for a date range
make pypi-transform START_DATE=2026-09-02 END_DATE=2026-09-03 DBT_TARGET=prod

# explore one event end-to-end (DuckDB CLI)
duckdb data/dev.duckdb "SELECT * FROM main_marts.fct_downloads LIMIT 5;"

# docs site (catalog + lineage DAG)
dbt docs generate --project-dir transform/pypi_metrics --target dev
dbt docs serve --project-dir transform/pypi_metrics --port 8080
```

## Conventions

- Staging: `stg_<source>__<table>` as views; tests live in the model's `.yml` (`data_tests`).
- Intermediate: `int_*` as views; nulls preserved, conforming happens only in `int_downloads_enriched`.
- Marts: `dim_*` / `fct_*` as tables; surrogate keys via `dbt_utils.generate_surrogate_key`;
  unknown members use key `'-1'`.
- Every model and every join key has a `description:` — that is what renders on the docs site.
