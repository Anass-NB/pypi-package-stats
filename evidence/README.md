# Evidence dashboard — PyPI package stats

Static dashboard for the `ingestr` PyPI download events, built on the dbt star
schema in `transform/pypi_metrics/dbt_data.duckdb` (opened **read-only**, no
MotherDuck, no cloud warehouse).

Live site: https://anass-nb.github.io/pypi-package-stats/

## How it works

- `sources/local_dbt/connection.yaml` — DuckDB source pointing at
  `../../../transform/pypi_metrics/dbt_data.duckdb` (relative to this source dir).
- `sources/local_dbt/*.sql` — named, pre-aggregated queries executed at
  `npm run sources` time; their results become parquet files that both the
  build step and the published site (via DuckDB-WASM) query. Keep them small.
- `pages/*.md` — the six dashboard pages. The Overview date-range filter runs
  fully client-side against `local_dbt.downloads_daily`.
- `evidence.config.yaml` — `deployment.basePath: /pypi-package-stats` for the
  GitHub Pages project site (also applies to the dev server URL).

## Commands

```bash
npm install          # first time
npm run sources      # (re)build parquet from the local DuckDB file
npm run dev          # dev server → http://localhost:3000/pypi-package-stats/
npm run preview      # serve ./build locally → http://localhost:4173/pypi-package-stats/
npm run build:strict # fail-on-error static build → ./build
npm run deploy       # push ./build to the gh-pages branch
```

Or from the repo root: `make evidence-dev`, `make evidence-build`,
`make evidence-deploy`.

> Re-run `npm run sources` after every `make pypi-transform` — the site embeds
> query results, so it will not see new dbt data until sources are rebuilt.
