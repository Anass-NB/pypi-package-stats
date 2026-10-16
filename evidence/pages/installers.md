---
title: Installers & Traffic
description: Which tools and bots download ingestr — pip, uv, CI runners, mirrors.
sidebar_position: 4
---

# Installers & Traffic

Installer name/version are parsed from the event payload and classified into traffic classes: `interactive`, `ci`, `mirror`, `scripted`, `automated`, `unknown`.

```sql traffic
select * from local_dbt.traffic_split
```

```sql interactive
select share_pct from local_dbt.traffic_split where traffic_type = 'interactive'
```

```sql ci
select share_pct from local_dbt.traffic_split where traffic_type = 'ci'
```

```sql unknown
select share_pct from local_dbt.traffic_split where traffic_type = 'unknown'
```

<Grid cols=3>
    <Value data={interactive} column=share_pct fmt=num1 title="Interactive share (%)" />
    <Value data={ci} column=share_pct fmt=num1 title="CI share (%)" />
    <Value data={unknown} column=share_pct fmt=num1 title="Unknown share (%)" />
</Grid>

<BarChart data={traffic} x=traffic_type y=downloads swapXY=true yFmt=num0 title="Downloads by traffic class (all time)" />

```sql automated
select
    month,
    round(100.0 * automated_downloads / downloads, 1) as automated_pct,
    automated_downloads,
    downloads
from local_dbt.automation_monthly
```

<LineChart data={automated} x=month y=automated_pct yFmt=num1 title="Automated (CI / mirror / scripted) share of monthly downloads (%)" />

```sql monthly
select * from local_dbt.traffic_monthly
```

<AreaChart data={monthly} x=month y=downloads series=traffic_type yFmt=num0 title="Monthly downloads by traffic class" />

## Top installers

```sql top
select * from local_dbt.installers_top
```

<DataTable data={top} />
