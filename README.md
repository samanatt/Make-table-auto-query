# SQL Table Generator and Data Importer

This SQL Server stored procedure automates the process of creating tables, importing data from files, and setting up full-text indexing for efficient text-based searches.

## Features

- Dynamically creates tables based on provided column definitions
- Imports data from text files using BULK INSERT
- Creates clustered columnstore indexes for improved query performance
- Sets up full-text indexing on all columns
- Handles duplicate rows by inserting only unique entries

## Functionality:

1. Table Creation:
        Drops the table if it already exists
        Creates a new table with the specified columns and an identity column 'FT_ID'
        Adds a unique constraint on 'FT_ID'
        Creates a clustered columnstore index for improved query performance
2. Data Import:
        Creates a temporary table to hold the imported data
        Uses BULK INSERT to load data from the specified file into the temp table
        Inserts unique rows from the temp table into the main table
3. Full-Text Indexing:
        Creates a full-text catalog if it doesn't exist
        Creates a full-text index on all columns of the main table

## Usage

1. Create the stored procedure by executing the SQL script.
2. Call the stored procedure with appropriate parameters:
   
## Parameters:
- @table: Name of the table to be created
- @columns: Column definitions for the table
- @file_dir: Directory path of the input file
- @format: File format (e.g., 'txt', 'csv')
- @first_row: First row to start importing data from
- @row: Row terminator character(s)
- @field: Field terminator character(s)
- @fulltextCatalogName: Name of the full-text catalog (default: 'FT_CAT')

```sql
EXEC sp_tableGenerator
@table = 'YourTableName',
@columns = '[Column1] nvarchar(4000), [Column2] int',
@file_dir = 'C:\path\to\your\file.txt',
@format = 'txt',
@first_row = 2,
@row = '\n',
@field = ',',
@fulltextCatalogName = 'YourCatalogName';
