SELECT
    country_code,
    SUM(daily_download_sum) AS total
FROM pypi_remote.main.pypi_daily_stats
GROUP BY country_code
ORDER BY total DESC;
