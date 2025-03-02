# MySQL Data Cleaning Project: Company Layoffs Dataset

## Project Overview
This project demonstrates a systematic approach to cleaning and preparing a dataset of company layoffs for analysis. The raw data contained various issues including duplicates, inconsistent formatting, and NULL values that needed to be addressed before meaningful analysis could be performed.

![SQL Data Cleaning](https://img.shields.io/badge/SQL-Data%20Cleaning-blue)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange)
![Data Quality](https://img.shields.io/badge/Data-Quality%20Improvement-green)

## Business Problem
Companies and analysts need reliable data on industry layoffs to:
- Identify employment trends across industries
- Analyze which sectors are most affected by economic changes
- Track the scale of workforce reductions in different companies
- Compare layoff percentages between organizations

Poor data quality can lead to incorrect conclusions and business decisions. This project transforms raw, messy layoff data into a clean, analysis-ready dataset that can support accurate business intelligence and strategic workforce planning.

## Technologies Used
- MySQL 8.0
- SQL techniques including:
  - Common Table Expressions (CTEs)
  - Window functions (ROW_NUMBER)
  - Data type conversion and validation
  - String manipulation functions
  - Self-joins for data enrichment
  - Staged approach with multiple tables
  - Transaction-safe operations

## Data Cleaning Process

### 1. Initial Assessment
The process begins with examining the source data to identify issues:
- Duplicated records
- Inconsistent string formats
- NULL values (both actual NULLs and 'NULL' strings)
- Improper data types

### 2. Duplicate Removal
Used window functions and CTEs to identify duplicates based on multiple fields:
```sql
WITH duplicate_cte AS (
    SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY company, location, 
    industry, total_laid_off, percentage_laid_off, `date`, stage,
    country, funds_raised_millions) AS row_num
    FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;
```

### 3. Data Standardization
Applied multiple standardization techniques:
- Trimmed whitespace from string fields
```sql
UPDATE layoffs_staging2
SET company = TRIM(company);
```
- Standardized industry categories
```sql
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
```
- Cleaned country names
```sql
UPDATE layoffs_staging2
SET country = trim(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';
```

### 4. Date Format Standardization
Converted string date formats to proper DATE data type:
```sql
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` IS NOT NULL;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
```

### 5. NULL Value Handling
Addressed both actual NULL values and 'NULL' strings in the data:
```sql
UPDATE layoffs_staging2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = 'NULL';

-- Removed rows with no meaningful data
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
```

### 6. Missing Data Population
Used self-joins to populate missing industry data from other records of the same company:
```sql
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;
```

## Results and Value Added

The cleaned dataset now offers several advantages:
- **Data integrity**: Duplicates removed, ensuring accurate counts and aggregations
- **Consistency**: Standardized formats for industries, countries, and other text fields
- **Usability**: Proper data types for date fields enabling time-based analysis
- **Completeness**: Missing values addressed through intelligent data population
- **Analysis-ready**: Clean data structure ready for business intelligence applications

## Potential Applications

This cleaned dataset enables various business analyses:
- Layoff trends over time by industry
- Geographic distribution of tech workforce reductions
- Correlation between company funding and layoff percentages
- Industry-specific impact assessments
- Company-level workforce change tracking

## Skills Demonstrated

This project showcases the following technical and analytical abilities:
- Advanced SQL query writing
- Database schema understanding and manipulation
- Data quality assessment and remediation
- Problem-solving approach to data issues
- Documentation of technical processes
- Understanding of business data requirements

---

*This project is part of my portfolio demonstrating SQL data preparation skills for business intelligence and analytics applications.*
