-- eda (exploratory data analysis)

SELECT * -- just selecting all
FROM layoffs_staging_2
;

SELECT MAX(total_laid_off), MAX(percentage_laid_off) -- checking maximum value in total laid off and percentage laid off column
FROM layoffs_staging_2
;

SELECT * -- percentage laid off = 1 (100%) is bad and we are ordering total laid off column from highest to lowest
FROM layoffs_staging_2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC
;

SELECT * -- percentage laid off = 1 (100%) is bad and we are ordering fund raised in millions column from highest to lowest
FROM layoffs_staging_2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC
;

SELECT company, SUM(total_laid_off) -- finding company and their total sum of people who got laid from highest to lowest
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC
;

SELECT MIN(`date`), MAX(`date`) -- just when covid started and 3 years later we're working on
FROM layoffs_staging_2
;

SELECT industry, SUM(total_laid_off) -- finding industry and their total sum of people who got laid from highest to lowest
FROM layoffs_staging_2
GROUP BY industry
ORDER BY 2 DESC
;

SELECT country, SUM(total_laid_off) -- finding country and their total sum of people who got laid from highest to lowest
FROM layoffs_staging_2
GROUP BY country
ORDER BY 2 DESC
;

SELECT `date`, SUM(total_laid_off) -- finding dates and their total sum of people who got laid from each and every date
FROM layoffs_staging_2
GROUP BY `date`
ORDER BY 1 DESC
;

SELECT YEAR(`date`), SUM(total_laid_off) -- finding years and their total sum of people who got laid from each and every year
FROM layoffs_staging_2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC
;

SELECT stage, SUM(total_laid_off) -- finding stages and their total sum of people who got laid in descending order
FROM layoffs_staging_2
GROUP BY stage
ORDER BY 2 DESC
;

SELECT company, SUM(percentage_laid_off) -- not relevant as percentage refers to the percentage of company and we dont have a hard number for it
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC
;

SELECT company, AVG(percentage_laid_off) -- not relevant as percentage refers to the percentage of company and we dont have a hard number for it
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC
;

SELECT SUBSTRING(`date`,6,2) AS `MONTH`, SUM(total_laid_off) -- gives total layoffs based on months but it includes every year's months
FROM layoffs_staging_2
GROUP BY `MONTH`
ORDER BY 1 
;

SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off) -- gives total layoffs based on months 
FROM layoffs_staging_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 
;

WITH Rolling_Total AS -- using cte getting rolling total month by month
(
SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 
)
SELECT `month`, total_off, SUM(total_off) OVER (ORDER BY `month`) AS rolling_total
FROM Rolling_Total
;

SELECT company, SUM(total_laid_off) -- 
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC
;

SELECT company, `date`, SUM(total_laid_off) -- on specific date what company and total laid off how many
FROM layoffs_staging_2
GROUP BY company, `date`
ORDER BY 2 DESC
;

SELECT company, YEAR(`date`), SUM(total_laid_off) -- on specific year what company and total laid off how many and company ascending order
FROM layoffs_staging_2
GROUP BY company, YEAR(`date`)
ORDER BY 1  
;

SELECT company, YEAR(`date`), SUM(total_laid_off) -- on specific year what company and total laid off how many and total laid off ascending order
FROM layoffs_staging_2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC 
;

WITH Company_Year (company, years, total_laid_off) AS --  with cte ranking every year which company has highest total laid off people
(
SELECT company, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging_2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
WHERE years IS NOT NULL
ORDER BY ranking
)
SELECT * 
FROM Company_Year_Rank
WHERE ranking <= 5
;

-- exploratory data analysis over







