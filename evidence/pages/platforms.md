---
title: Platforms & Geo
description: Operating systems, CPUs, distros and countries for ingestr downloads.
sidebar_position: 3
---

# Platforms & Geo

Operating system, CPU architecture, Linux distribution and country, as reported by the PyPI event.

```sql os
select * from local_dbt.platform_split
```

```sql cpu
select * from local_dbt.platform_cpu
```

<Grid cols=2>
    <BarChart data={os} x=os_family y=downloads swapXY=true yFmt=num0 title="OS family" />
    <BarChart data={cpu} x=cpu_arch y=downloads swapXY=true yFmt=num0 title="CPU architecture" />
</Grid>

```sql os_top
select * from local_dbt.platform_os_top
```

```sql distro
select * from local_dbt.platform_distro
```

<Grid cols=2>
    <DataTable data={os_top} title="Top OS name / release" />
    <DataTable data={distro} title="Top Linux distros" />
</Grid>

## Countries

```sql countries_top
select country_code, country_name, downloads
from local_dbt.countries
where country_name <> 'Unknown'
order by downloads desc
limit 12
```

<BarChart data={countries_top} x=country_name y=downloads swapXY=true yFmt=num0 title="Top 12 countries" />

```sql countries_all
select country_code, country_name, downloads, share_pct
from local_dbt.countries
where country_name <> 'Unknown'
```

<DataTable data={countries_all} title="All countries (downloads and share)" />
