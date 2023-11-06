-- Create external table for MapReduce results
CREATE EXTERNAL TABLE IF NOT EXISTS developer_stats (
  developer_id STRING,
  year INT,
  sum_rates INT,
  count_rates INT,
  count_apps INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '${input_dir3}';

-- Create external table for the second dataset
CREATE EXTERNAL TABLE IF NOT EXISTS developer_info (
  developer_name STRING,
  app_url STRING,
  dev_email STRING,
  app_id BIGINT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\001'
LOCATION '${input_dir4}';

-- Aggregate ratings for developers before ranking
CREATE TEMPORARY TABLE IF NOT EXISTS developer_aggregated AS
SELECT
  developer_id,
  year,
  SUM(sum_rates) AS total_sum_rates,
  SUM(count_rates) AS total_count_rates,
  SUM(count_apps) AS total_count_apps
FROM developer_stats
GROUP BY developer_id, year;

-- Temporary table to store the intermediate results with ranking
CREATE TEMPORARY TABLE IF NOT EXISTS fin_orc_applications AS
SELECT
  developer_name,
  da.year,
  da.avg_rate,
  da.total_count_apps,
  da.total_count_rates
FROM (
  SELECT
    ds.developer_id,
    ds.year,
    di.developer_name,
    ds.total_sum_rates / ds.total_count_rates AS avg_rate,
    ds.total_count_apps,
    ds.total_count_rates,
    DENSE_RANK() OVER (PARTITION BY ds.year ORDER BY ds.total_sum_rates / ds.total_count_rates DESC, ds.total_count_rates DESC) as rank
  FROM developer_aggregated ds
  JOIN developer_info di ON (cast(ds.developer_id as STRING) = cast(di.app_id as STRING))
) da
WHERE da.rank <= 3;


-- Export the final results to JSON format in the specified output directory
-- Including SERDEPROPERTIES to specify JSON attribute names
INSERT OVERWRITE DIRECTORY '${output_dir6}'
ROW FORMAT SERDE  'org.apache.hadoop.hive.serde2.JsonSerDe'
WITH SERDEPROPERTIES (
  "mapping.developer_name" = "developer_name",
  "mapping.year" = "year",
  "mapping.avg_rate" = "avg_rate",
  "mapping.count_apps" = "total_count_apps",
  "mapping.count_rates" = "total_count_rates"
)
SELECT
  developer_name,
  year,
  avg_rate,
  total_count_apps,
  total_count_rates
FROM fin_orc_applications
ORDER BY year ASC, avg_rate DESC, total_count_rates DESC;


