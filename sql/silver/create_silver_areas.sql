
-- FOR REFERENCE ONLY - MANAGED BY DBT!!

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'areas' AND schema_id = SCHEMA_ID('silver'))
  EXEC('
  CREATE TABLE silver.areas (
      area_id INT PRIMARY KEY,
      area_name NVARCHAR(100))
      ')
