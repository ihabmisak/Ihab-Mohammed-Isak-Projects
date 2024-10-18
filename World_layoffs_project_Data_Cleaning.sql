## Stage 1: Data Cleaning 

SELECT *
FROM layoffs;

/* 
Step 1: Removing any duplicates
Step 2: Standardizing the data
Step 3: Cleaning null and blank values
Step 4: Making sure columns and rows are relevant (remove irrelevant ones)
*/

# Creating new table to work with data keeping raw data seperate

CREATE TABLE layoffs_cleaning
LIKE layoffs;

INSERT layoffs_cleaning
SELECT *
FROM layoffs;

SELECT*
FROM layoffs_cleaning;

# Inserting row numbers for table 'layoffs_cleaning' in order to identify points of duplication

SELECT *,
ROW_NUMBER() OVER(
PARTITION  BY company, industry, total_laid_off, percentage_laid_off, `date`) row_num
FROM layoffs_cleaning
;

WITH duplicate_check_cte AS 
(
	SELECT *,
	ROW_NUMBER() OVER(
	PARTITION  BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) row_num
	FROM layoffs_cleaning
)
SELECT *
FROM duplicate_check_cte
WHERE company = 'Casper'
;

CREATE TABLE `layoffs_cleaning2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_cleaning2
SELECT *,
ROW_NUMBER() OVER(
PARTITION  BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) row_num
FROM layoffs_cleaning;

SELECT *
FROM layoffs_cleaning2
WHERE row_num > 1
;

DELETE
FROM layoffs_cleaning2
WHERE row_num > 1
;

# Step 2: Standardizing the data

UPDATE layoffs_cleaning2
SET company = TRIM(company);

SELECT *
FROM layoffs_cleaning2;

SELECT *
FROM layoffs_cleaning2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_cleaning2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'
;

SELECT DISTINCT country
FROM layoffs_cleaning2
ORDER BY 1;

UPDATE layoffs_cleaning2
SET country = 'United States'
WHERE country LIKE 'United States%'
;

UPDATE layoffs_cleaning2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_cleaning2;

ALTER TABLE layoffs_cleaning2
MODIFY COLUMN `date` DATE;

# Step 3: Cleaning null and blank values

SELECT t1.company,
t2.industry
FROM layoffs_cleaning2 t1
JOIN layoffs_cleaning2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL
;

UPDATE layoffs_cleaning2
SET industry = NULL
WHERE industry = ''
;

SELECT industry
FROM layoffs_cleaning2
WHERE industry = ''
;

UPDATE layoffs_cleaning2 t1
JOIN layoffs_cleaning2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL
;

SELECT *
FROM layoffs_cleaning2
WHERE industry IS NULL
;

SELECT *
FROM layoffs_cleaning2
WHERE company LIKE 'Bally%'
;

# Step 4: Making sure columns and rows are relevant (remove irrelevant ones)

SELECT *
FROM layoffs_cleaning2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

/* Ideally I would be looking to populate the Null cells to get the best possible analysis.
However, as the purpose of this part of the project is only to showcase data cleaning skill;
I will be removing date where total_laid_off AND percentage_laid_off cells that are BOTH null in value in order to make 
the best out of analysis in the future phases of the project.
*/

DELETE
FROM layoffs_cleaning2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

# deleting row_num colum as it is irrelevant to the analysis

ALTER TABLE layoffs_cleaning2
DROP COLUMN row_num
;

SELECT *
FROM layoffs_cleaning2
;