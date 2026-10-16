---
title: Python
description: Runtime Python version adoption for ingestr downloads.
sidebar_position: 2
---

# Runtime Python

The interpreter that requested the download, as reported by the installer.

```sql split
select * from local_dbt.python_split
```

<BarChart data={split} x=python_major_minor y=downloads swapXY=true yFmt=num0 title="Downloads by Python line (all time)" />

> **34.9% of downloads report no runtime Python** (the field is absent in the raw event). Those rows are the `Unknown` bar above. They are excluded from the monthly view below to keep the trends readable.

```sql monthly
select * from local_dbt.python_monthly_share
```

<AreaChart data={monthly} x=month y=downloads series=python_version yFmt=num0 title="Monthly downloads by Python line (top 6 + Other)" />

```sql impl
select * from local_dbt.python_impl
```

<BarChart data={impl} x=python_implementation y=downloads swapXY=true yFmt=num0 title="Implementations" />

## Version detail

```sql detail
select * from local_dbt.python_versions_detail
```

<DataTable data={detail} />
