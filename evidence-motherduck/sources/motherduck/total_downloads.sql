SELECT SUM(daily_download_sum) as total_downloads
FROM pypi_remote.main.pypi_daily_stats;
