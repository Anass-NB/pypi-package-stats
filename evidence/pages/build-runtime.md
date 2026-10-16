---
title: Build & Runtime
description: Wheel vs sdist, platform-specific wheels and unresolved artifact tags.
sidebar_position: 6
---

# Build vs runtime artifacts

How the downloaded files were packaged, and which platform wheels people pull.

```sql share30
select * from local_dbt.artifact_share_30d
```

<Grid cols=3>
    <Value data={share30} column=wheel_share_30d_pct fmt=num1 title="Wheel share of last 30 days (%)" />
    <Value data={share30} column=wheel_downloads_30d fmt=num0 title="Wheel downloads (last 30 days)" />
    <Value data={share30} column=sdist_downloads_30d fmt=num0 title="Sdist downloads (last 30 days)" />
</Grid>

```sql classes
select * from local_dbt.artifact_class_monthly
```

<AreaChart data={classes} x=month y=downloads series=artifact_class yFmt=num0 title="Monthly downloads by artifact class" />

> About 59% of wheel downloads carry an **unresolved filename tag** — mostly older artifacts whose names predate the current `py3-none-any` / `manylinux` conventions. They are kept as their own class instead of being silently dropped.

```sql by_runtime
select * from local_dbt.wheel_vs_sdist
```

<BarChart data={by_runtime} x=runtime_version y=downloads series=package_type type=stacked yFmt=num0 title="Wheels vs sdists by runtime Python" />

```sql platforms
select * from local_dbt.wheel_platform_top
```

<BarChart data={platforms} x=platform_tag y=downloads swapXY=true yFmt=num0 title="Top platform tags (platform-specific wheels)" />
