#Exploratory Data Analysis 

SELECT *
FROM layoffs_cleaning2;

# Identifying which industry had the highest lay offs

SELECT industry, SUM(total_laid_off)
FROM layoffs_cleaning2
GROUP BY industry 
ORDER BY industry DESC
;

# Identifying the same but on the basis of country

SELECT country, industry, SUM(total_laid_off) sum_layoffs
FROM layoffs_cleaning2
GROUP BY country, industry 
ORDER BY sum_layoffs DESC
;

# Identiftying and analysing the change of layoffs over time

SELECT country, industry, `date`, SUM(total_laid_off) sum_layoffs
FROM layoffs_cleaning2
GROUP BY country, industry, `date`
ORDER BY sum_layoffs DESC
;

# Further analysis by expanding on date by month

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_cleaning2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
;

# Using the rolling sum method to find gradual change in layoffs over time using a CTE

WITH rolling_sum AS
(SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) total_layoffs
FROM layoffs_cleaning2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY `MONTH` ASC
)
SELECT `MONTH`, total_layoffs, SUM(total_layoffs) OVER(ORDER BY `MONTH`) rolling_sum
FROM rolling_sum
;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_cleaning2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
;

WITH company_year(company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_cleaning2
GROUP BY company, YEAR(`date`)
), company_ranking_by_year AS
( 
SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS `Rank`
FROM company_year
WHERE years IS NOT NULL
)
SELECT *
FROM company_ranking_by_year
WHERE `rank` <= 5
;

SELECT funds_raised_millions
FROM layoffs_cleaning2
WHERE funds_raised_millions IS NULL;

SELECT *
FROM layoffs_cleaning2;

# Exporting the table into a csv file in order to create viz in tableau for further EDA
