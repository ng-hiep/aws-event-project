CREATE EXTERNAL TABLE IF NOT EXISTS books (
  id STRING,  
  publisher STRING,
  publishing_year INT,
  genre STRING,
  title STRING,
  author STRING
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = '1'
)
LOCATION 's3://project01-libros-raw-2024/';

-- SELECT * FROM libros;
