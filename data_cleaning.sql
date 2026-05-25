-- data cleaning steps:
-- i) remove duplicates
-- ii) standardize data
-- iii) fix null values and blank values
-- iv) remove any unnecessary columns and rows that we wont be using

-- removing duplicates

SELECT * -- selecting all just to see
FROM layoffs
;

CREATE TABLE layoffs_staging -- creating a new table called layoffs_staging and we will be doing data cleaning there and not in the raw table
LIKE layoffs -- creates new table with the help of layoffs table (same column names)
;

SELECT * -- selecting all data and putting in staging table
FROM layoffs_staging
;

INSERT layoffs_staging -- inserting the selected data
SELECT *
FROM layoffs
;

SELECT * -- checking whether it got inserted properly
FROM layoffs_staging
;

SELECT *, -- to select duplicates based on company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions and if there is duplicate itll be 2 or else 1
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging 
;

WITH duplicate_cte AS -- same thing created in a cte (common table expression) and used the same to filter out
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging 
)
SELECT *
FROM duplicate_cte 
WHERE row_num > 1
;

SELECT * -- double checking manually if its actually a duplicate
FROM layoffs_staging
WHERE company = "Casper"
;

WITH duplicate_cte AS -- wont work as we cant update (delete) a cte
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging 
)
DELETE 
FROM duplicate_cte 
WHERE row_num > 1
;

CREATE TABLE `layoffs_staging_2` ( -- copied the layoffs_staging table info so i created layoffs_staging_2 using same and added row_num column 
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  row_num INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * -- layoffs_staging_2 is created with same column names as layoffs_staging_2
FROM layoffs_staging_2
;

INSERT INTO layoffs_staging_2 -- inserting data into the same table to create a copy and filtering it and storing it in the row_num
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging 
;

SELECT * -- selecting all that have 2 (duplicate not unique)
FROM layoffs_staging_2
WHERE row_num > 1
;

SET SQL_SAFE_UPDATES = 0; -- now we can delete shit easily


DELETE -- deleting the same
FROM layoffs_staging_2
WHERE row_num > 1
;

SELECT * -- duplicates are removed now
FROM layoffs_staging_2
;

-- standardizing data

SELECT company, TRIM(company) -- selecting company column and trimming the blank spaces
FROM layoffs_staging_2
;

UPDATE layoffs_staging_2 -- updating the company column to the trimmed company column so now everything is trimmed and updated
SET company = TRIM(company)
;

SELECT DISTINCT industry -- to give ascending order of industry names and we find crypto is written as 3 (includes spelling mistakes)
FROM layoffs_staging_2
ORDER BY 1
;

SELECT * -- to find what and all start with crypto so that we can change them to the mostly used one (crypto here)
FROM layoffs_staging_2
WHERE industry LIKE "crypto%"
;

SET SQL_SAFE_UPDATES = 0; -- now we can delete shit easily

UPDATE layoffs_staging_2 -- whatever starts like crypto we forced it be as crypto so all crypto (which was 3 before now is just 1 "Crypto")
SET industry = "Crypto"
WHERE industry LIKE "crypto%"
;

SELECT DISTINCT industry -- to check if anyother standardization is needed
FROM layoffs_staging_2
ORDER BY 1
;

SELECT * -- checking if anyother standardization is needed
FROM layoffs_staging_2
;

SELECT DISTINCT location -- ordering location in alphabetical order to check if duplicates are there
From layoffs_staging_2
ORDER BY 1
;

SELECT DISTINCT country -- ordering location in alphabetical order to check if duplicates are there (there are 2 united states one with full stop)
From layoffs_staging_2
ORDER BY 1
;

SELECT * -- to double check
From layoffs_staging_2
WHERE country LIKE "United St%"
;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) -- trims any '.' present in the last
FROM layoffs_staging_2
ORDER BY 1
;

UPDATE layoffs_staging_2 -- matching and updating it to the trimmed result
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE "UNITED STA%"
;

-- time series stuff - date is in text format which is not good for eda

SELECT `date`, -- str_to_date converts string to date and we changed the data type
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging_2
;

UPDATE layoffs_staging_2 -- updated it to the database (but datatype still says text)
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
;

ALTER TABLE layoffs_staging_2 -- changes datatype of the whole column `date`
MODIFY COLUMN `date` DATE
;

SELECT * -- just checking again
FROM layoffs_staging_2
;

-- fixing null and blank values

SELECT * -- if both are null then they are useless data right?
FROM layoffs_staging_2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL
;

SELECT * -- checking blank and null in industry column and we found airbnb company has blank industry
from layoffs_staging_2
WHERE industry IS NULL OR industry = ''
;

SELECT * -- checking other airbnb's for checking what industry it can be and we found its travel
FROM layoffs_staging_2
WHERE company = 'Airbnb'
;

UPDATE layoffs_staging_2 -- changing all blank as null so that it will be easier to change one thing
SET industry = NULL
WHERE industry = ''
;

SELECT * -- join so that we can see both null along with data typed columns and we can update them
FROM layoffs_staging_2 AS t1
JOIN layoffs_staging_2 AS t2
	ON t1.company = t2.company
	AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '') AND t2.industry is NOT NULL
;

UPDATE layoffs_staging_2 AS t1 -- now updating the same the filled data value we take and update in the present table
JOIN layoffs_staging_2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry 
WHERE (t1.industry IS NULL OR t1.industry = '') AND t2.industry is NOT NULL
;

SELECT * -- checking blank and null in industry column again and we find bally still has it
from layoffs_staging_2
WHERE industry IS NULL OR industry = ''
;

SELECT * -- checking other bally's for checking what industry it can be and we found it has only 1
FROM layoffs_staging_2
WHERE company LIKE 'Bally%'
;

SELECT * -- just selecting all
from layoffs_staging_2
;

SELECT * -- as seen before if both are null then they are useless data so they can be deleted
FROM layoffs_staging_2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL
;

DELETE -- deleting them
FROM layoffs_staging_2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL
;

-- there are some more nulls/blank spaces left which cant be fixed by us because we dont know the value and whatever we can fix has been done

 SELECT * -- just selecting all
from layoffs_staging_2
;

ALTER TABLE layoffs_staging_2 -- row_num served its use and now we can remove it becuase we have identified the duplicates and removed them
DROP COLUMN row_num
;

 SELECT * -- just selecting all to view the cleaned data
from layoffs_staging_2
;

-- data cleaning over