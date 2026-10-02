SELECT 
    download_date,
    SUM(daily_download_sum) AS daily_downloads
FROM pypi_remote.main.pypi_daily_stats
WHERE download_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY download_date
ORDER BY download_date;