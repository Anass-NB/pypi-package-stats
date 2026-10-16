---
title: Version Adoption
description: Which ingestr versions are downloaded, and how fast new releases get adopted.
sidebar_position: 5
---

# ingestr version adoption

```sql latest
select
    latest_version,
    latest_downloads_30d,
    total_downloads_30d,
    round(100.0 * latest_downloads_30d / total_downloads_30d, 1) as latest_share_pct
from local_dbt.latest_version_kpi
```

<Grid cols=3>
    <Value data={latest} column=latest_version title="Newest version" />
    <Value data={latest} column=latest_share_pct fmt=num1 title="Newest version share of last 30 days (%)" />
    <Value data={latest} column=latest_downloads_30d fmt=num0 title="Newest version downloads (last 30 days)" />
</Grid>

```sql monthly
select * from local_dbt.version_monthly_share
```

<AreaChart data={monthly} x=month y=downloads series=version yFmt=num0 title="Monthly downloads by version (top 8 + Other)" />

## All versions

```sql detail
select
    project_version,
    is_prerelease,
    downloads,
    first_seen,
    last_seen
from local_dbt.versions_detail
```

<DataTable data={detail} />
