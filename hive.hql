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

-- External table to store the final results in JSON format
CREATE EXTERNAL TABLE IF NOT EXISTS json_res (
    developer_name STRING,
    year INT,
    avg_rate FLOAT,
    count_apps INT,
    count_rates INT
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
STORED AS TEXTFILE
LOCATION '${output_dir6}';

-- Insert data into json_res with the results
INSERT OVERWRITE TABLE json_res
SELECT 
    grouped.developer_name,
    grouped.year,
    grouped.avg_rate, 
    grouped.count_apps,
    grouped.count_rates
FROM (
    SELECT
        di.developer_name,
        ds.year,
        CAST(SUM(ds.sum_rates) AS FLOAT) / SUM(ds.count_rates) AS avg_rate,
        SUM(ds.count_apps) AS count_apps,
        SUM(ds.count_rates) AS count_rates,
        ROW_NUMBER() OVER (
            PARTITION BY ds.year
            ORDER BY CAST(SUM(ds.sum_rates) AS FLOAT) / SUM(ds.count_rates) DESC
        ) AS ord
    FROM developer_stats ds
    JOIN developer_info di ON di.app_id = ds.developer_id
    GROUP BY di.developer_name, ds.year
) grouped
WHERE grouped.ord <= 3
ORDER BY grouped.year ASC, grouped.avg_rate DESC, grouped.count_rates DESC;
