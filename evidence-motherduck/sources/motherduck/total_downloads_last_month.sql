SELECT SUM(daily_download_sum) AS total_downloads_last_month
FROM  pypi_remote.main.pypi_daily_stats
WHERE download_date >= CURRENT_DATE - INTERVAL '30 days';