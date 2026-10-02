# PyPI Stats for ORA Package

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


## Downloads per Week


```sql downloads_per_week
SELECT * 
FROM motherduck.downloads_per_week
```


<LineChart
    data={downloads_per_week}
    x=week_start
    y=weekly_download_sum
    title="Downloads over week"
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
    title="Downloads per Day"
/>


## Downloads by country

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
    title="Top 10 PyPI downloads by country"
    swapXY=true
/>

## Detailed data

