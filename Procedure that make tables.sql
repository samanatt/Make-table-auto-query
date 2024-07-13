
USE master
GO


--CREATE FULLTEXT CATALOG [FT_CAT] AS DEFAULT
--GO


IF(OBJECT_ID('sp_tableGenerator','P') IS NOT NULL)
DROP PROC sp_tableGenerator;
GO

SET NOCOUNT ON ;
SET XACT_ABORT ON;
GO

CREATE PROCEDURE sp_tableGenerator (
@table NVARCHAR(500),
@columns NVARCHAR(4000),
@file_dir NVARCHAR(255),
@format VARCHAR(255),
@first_row TINYINT,
@row VARCHAR(255),
@field VARCHAR(255),
@fulltextCatalogName VARCHAR(255) ='FT_CAT'
)
AS
BEGIN
DECLARE @sql NVARCHAR(MAX)=N'
IF OBJECT_ID(''[dbo].['+@table+']'', ''U'') IS NOT NULL
DROP TABLE [dbo].['+@table+']

CREATE TABLE ['+@table+'](
[FT_ID] INT IDENTITY(1,1),
'+@columns+',
CONSTRAINT [PK_'+@table+'] UNIQUE (FT_ID)
)

CREATE CLUSTERED COLUMNSTORE INDEX [ICS_'+@table+'] ON [dbo].['+@table+']

';

PRINT(@sql)

EXEC sp_executesql @sql

DECLARE @tableColumns NVARCHAR(MAX)=N'';
SELECT
@tableColumns = @tableColumns++'['+COLUMN_NAME+'], '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @table
AND COLUMN_NAME <> 'FT_ID'


SET @tableColumns = LEFT(@tableColumns,LEN(@tableColumns)- LEN(', '))
SET @file_dir = @file_dir --+ '/' + @table + '.csv'
DECLARE @insertUnique NVARCHAR(MAX)=N'

CREATE TABLE #TEMP(
'+@columns+'
)

BULK INSERT #TEMP
FROM '''+@file_dir+'''
WITH (--CODEPAGE = 65001,
--DATAFILETYPE=''WIDECHAR'',
--FORMAT='''+@format+''',
FIRSTROW = '+STR(@first_row)+',
ERRORFILE='''+@file_dir+'.e'',
TABLOCK,
ROWTERMINATOR='''+@row+''',
FIELDTERMINATOR='''+@field+''',
MAXERRORS=1000000,
KEEPNULLS
);

INSERT INTO [dbo].['+@table+'] ('+@tableColumns+')
SELECT '+@tableColumns+' FROM #TEMP
GROUP BY '+@tableColumns+'

'
;

DECLARE @fulltext NVARCHAR(MAX) = N'

IF NOT EXISTS (SELECT 1 FROM sys.fulltext_catalogs WHERE name='''+@fulltextCatalogName+''')
CREATE FULLTEXT CATALOG ['+@fulltextCatalogName+'];

CREATE FULLTEXT INDEX ON [dbo].['+@table+']
(
'
+' '+ @tableColumns
+
'
)
KEY INDEX [PK_'+@table+']
ON ['+@fulltextCatalogName+'] ;';


SET @sql= @insertUnique + @fulltext;

PRINT(@sql)

EXEC sp_executesql @sql

END
GO

EXEC sys.sp_MS_marksystemobject 'sp_tableGenerator'
GO


USE [Twitter_Spritzer]
GO

EXEC sp_tableGenerator
@table = '2012_11',
@columns = '[User ID] nvarchar(4000),[Screen Name History] nvarchar(4000)',
@file_dir = 'D:\twitter_spritzer\2012\2012\1.txt',
@format = 'txt',
@first_row = 2,
@row = '\n',
@field = ' <<...>> ',
@fulltextCatalogName = 'FT_CAT';

	
Displaying New Text Document.txt.
