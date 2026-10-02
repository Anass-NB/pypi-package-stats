SELECT 
    date_trunc('week', download_date)::date AS week_start,
    SUM(daily_download_sum) AS weekly_download_sum
FROM pypi_remote.main.pypi_daily_stats
WHERE download_date >= CURRENT_DATE - INTERVAL '12 weeks'
GROUP BY date_trunc('week', download_date)
ORDER BY week_start;