---
title: PyPI Downloads Dashboard
---


```sql test_connection
select 1 from motherduck.total_downloads limit 1
```


{#if dev && !test_connection.ready}

## Connect to MotherDuck 🐣

1. [Get your service token](https://motherduck.com/docs/key-tasks/authenticating-to-motherduck/#authentication-using-a-service-token)
1. [Connect Evidence to MotherDuck](/settings)

{:else}

## Total Downloads

```sql total_downloads
SELECT * 
FROM motherduck.total_downloads
```

<Value
    data={total_downloads}
    column=total_downloads
    title="Total Downloads"
    fmt="num"
/>

## Total Downloads Last 30 Days

```sql total_downloads_last_month
SELECT * 
FROM motherduck.total_downloads_last_month
```

<Value
    data={total_downloads_last_month}
    column=total_downloads_last_month
    title="Total Downloads Last Month"
    fmt="num"
/>

## Downloads per Day

```sql downloads_per_day
SELECT * 
FROM motherduck.downloads_per_day
```

<LineChart
    data={downloads_per_day}
    x=download_date
    y=daily_downloads
    title="Downloads per Day (Last 30 Days)"
/>

## Downloads per Week

```sql downloads_per_week
SELECT * 
FROM motherduck.downloads_per_week
```

<LineChart
    data={downloads_per_week}
    x=week_start
    y=weekly_download_sum
    title="Downloads per Week (Last 12 Weeks)"
/>

## Top 10 Countries

```sql downloads_by_country
SELECT *
FROM motherduck.downloads_by_country
ORDER BY total DESC
LIMIT 10
```

<BarChart
    data={downloads_by_country}
    x=country_code
    y=total
    title="Top 10 PyPI Downloads by Country"
    swapXY=true
/>

## What's Next?
- Edit the markdown files in the `pages` folder
- Add new queries to `sources/motherduck` 
- Deploy your project with [Evidence Cloud](https://evidence.dev/cloud)


## Resources 
- Message us on [Slack](https://slack.evidence.dev/)
- Read the [Docs](https://docs.evidence.dev/)
- Open an issue on [Github](https://github.com/evidence-dev/evidence)

{/if}