--- Data Cleaning Project ---

select *
from new_layoffs;

--- 1. Remove Duplicates
--- 2. Standartize Data
--- 3. Null or Blank Values
--- 4. Remove Irrelevant Columns

# Creating a staging table to work with
CREATE TABLE layoffs_staging
LIKE new_layoffs;

select *
from layoffs_staging;

# Changing the name as it was wrong
RENAME TABLE new_layoffs TO layoffs;

# Copying all data from original to staging table
INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
from layoffs_staging;

# Show duplicate entries
WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
from layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

# Show specific company named Oda
SELECT *
FROM layoffs_staging
WHERE company = 'Oda';

# Extend CTE query to partition everyting
WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage,
country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

WITH duplicate_cte AS
(
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

# Creating a 2nd staging table to delete duplicates
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


select *
from layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage,
country, funds_raised_millions) AS row_num
FROM layoffs_staging;


CREATE TABLE `layoffs_staging3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


RENAME TABLE layoffs_staging3 TO layoffs_staging2;


select *
from layoffs_staging2;


DELETE
from layoffs_staging2
WHERE row_num > 1;

--- Standartizing data

select company, TRIM(company)
from layoffs_staging2;

update layoffs_staging2
SET company = TRIM(company);

select *
from layoffs_staging2
WHERE industry LIKE 'Crypto%'
;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


select DISTINCT industry
from layoffs_staging2
;

select *
from layoffs_staging2
;


select DISTINCT industry
from layoffs_staging2
order by 1;


select DISTINCT country, trim(TRAILING '.' FROM country)
from layoffs_staging2
order by 1;

UPDATE layoffs_staging2
SET country = trim(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


# Change data type in Date column from String to Date

select `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
from layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
# The above command did not worked, as there were NULL values. Therefore used the 2 commands below to REMOVE NULL Values: 

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` IS NOT NULL;

UPDATE layoffs_staging2
SET `date` = NULL
WHERE `date` = 'NULL' OR `date` = '';

# Updates the actual data type in the table properties:
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

select *
from layoffs_staging2
WHERE total_laid_off IS NULL
OR industry = '';

select *
from layoffs_staging2
where company = 'Airbnb';

select *
from layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

select t1.industry, t2.industry
from layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2
SET industry = null
WHERE industry = '';

select *
from layoffs_staging2
WHERE industry IS NULL
OR industry = 'NULL';

select *
from layoffs_staging2
WHERE company LIKE 'Bally%';


# Found literal string NULL instead of true NULL value and fixed with the transactions below:
select *
from layoffs_staging2
WHERE percentage_laid_off = 'NULL'
;

UPDATE layoffs_staging2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = 'NULL';

select *
from layoffs_staging2;

select *
from layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

# Delete laidoff NULL values
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

# Remove row_num collumn
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;



select *
from layoffs_staging2;

