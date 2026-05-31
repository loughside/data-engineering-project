
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'competitions' AND schema_id = SCHEMA_ID('bronze'))
  EXEC('
    CREATE TABLE bronze.competitions (
      id INT,
      name NVARCHAR(100),
      code NVARCHAR(20),
      type NVARCHAR(50),
      emblem NVARCHAR(255),
      area_id INT,
      area_name NVARCHAR(100),
      _ingested_at DATETIME2)
    ')