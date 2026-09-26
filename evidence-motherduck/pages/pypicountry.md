# PyPI Stats for ORA Package

## Downloads by country

```sql downloads_by_country
SELECT *
FROM motherduck.downloads_by_country
ORDER BY total DESC
```

<BarChart
    data={downloads_by_country}
    x=country_code
    y=total
    title="PyPI downloads by country"
    swapXY=true
/>

## Detailed data

<DataTable
    data={downloads_by_country}
/>
