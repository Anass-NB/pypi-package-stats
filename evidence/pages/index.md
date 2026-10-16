---
title: Overview
description: PyPI download analytics for ingestr — local DuckDB + dbt + Evidence stack.
sidebar_position: 1
---

# ingestr downloads on PyPI

Everything on this site is built locally: the raw event log is ingested to a local file, transformed with **dbt into a star schema on DuckDB**, and served by Evidence. No cloud warehouse involved.

Data covers **13 Feb 2024 → 1 Oct 2026** (1,086,749 download events, 136 countries).

<DateRange data={all_daily} dates=date_day name=date_range />

```sql all_daily
select * from local_dbt.downloads_daily
```

```sql range_kpi
select
    sum(downloads) as downloads,
    count(*) as days,
    round(sum(downloads) * 1.0 / count(*), 0) as avg_daily
from local_dbt.downloads_daily
where date_day between '${inputs.date_range.start}' and '${inputs.date_range.end}'
```

```sql kpi
select * from local_dbt.kpi_totals
```

<Grid cols=3>
    <Value data={range_kpi} column=downloads fmt=num0 title="Downloads in range" />
    <Value data={range_kpi} column=avg_daily fmt=num0 title="Avg / day in range" />
    <Value data={kpi} column=total_downloads fmt=num0 title="All-time downloads" />
</Grid>

```sql range_trend
select *
from local_dbt.downloads_daily
where date_day between '${inputs.date_range.start}' and '${inputs.date_range.end}'
order by date_day
```

<LineChart data={range_trend} x=date_day y=downloads yFmt=num0 title="Daily downloads" />

## Where the downloads come from

```sql country_top
select country_name, downloads
from local_dbt.countries
where country_name <> 'Unknown'
order by downloads desc
limit 10
```

```sql python_top
select python_major_minor, downloads
from local_dbt.python_split
where python_major_minor <> 'Unknown'
```

<Grid cols=2>
    <BarChart data={country_top} x=country_name y=downloads swapXY=true yFmt=num0 title="Top 10 countries" />
    <BarChart data={python_top} x=python_major_minor y=downloads swapXY=true yFmt=num0 title="Runtime Python (major.minor)" />
</Grid>

## Data quality

`Unknown` means the raw PyPI event did not carry the field (it is not an ingestion error). Runtime Python is the one dimension with a large unresolved share; installer details are missing for about 10% of traffic.

```sql quality
select * from local_dbt.unknown_share
```

<DataTable data={quality} />
