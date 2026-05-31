
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'competitions' AND schema_id = SCHEMA_ID('silver'))
  EXEC('
  CREATE TABLE silver.competitions (
      id INT PRIMARY KEY,
      name NVARCHAR(100),
      code NVARCHAR(20),
      type NVARCHAR(50),
      emblem NVARCHAR(255),
      area_id INT,
      _updated_at DATETIME2,
      CONSTRAINT fk_areas FOREIGN KEY (area_id) REFERENCES silver.areas(area_id)
      )
      ')


