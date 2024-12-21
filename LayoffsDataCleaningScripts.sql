select *
from layoffs 
-- Create new Table to avoid editing raw data
create table layoffs_staging
like layoffs

insert layoffs_staging
select * 
from layoffs


-- Remove Duplicates if needed


with duplicate_cte as
(
select *, 
row_number () over(
	partition by company,location,industry,total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num >1

-- Creating new table to delete duplicates

CREATE TABLE `layoffs_staging2` (
  `company` varchar(50) DEFAULT NULL,
  `location` varchar(50) DEFAULT NULL,
  `industry` varchar(50) DEFAULT NULL,
  `total_laid_off` varchar(50) DEFAULT NULL,
  `percentage_laid_off` varchar(50) DEFAULT NULL,
  `date` varchar(50) DEFAULT NULL,
  `stage` varchar(50) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `funds_raised_millions` varchar(50) DEFAULT null,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci

insert into layoffs_staging2  
select *, 
row_number () over(
	partition by company,location,industry,total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging

delete
from layoffs_staging2
where row_num > 1






-- Standardize Data
-- Adjusting company
select distinct company 
from layoffs_staging2
order by 1

update layoffs_staging2 
set company = Trim(company)

-- Adjusting industry
select distinct industry 
from layoffs_staging2
order by 1

update layoffs_staging2 
set industry = 'Crypto'
where industry like 'Crypto%'

-- Adjusting country
select distinct country 
from layoffs_staging2
order by 1

update layoffs_staging2 
set country = Trim(trailing '.' from country)
where country like 'United States%'

-- Standardizing Date
select date,
str_to_date(date, '%m/%d/%Y')
from layoffs_staging2

update layoffs_staging2 
set date = str_to_date(date,'%m/%d/%Y')
where not date = 'NULL'

-- Adjust date values to be able to alter column to date data type
select date
from layoffs_staging2
where date = 'NULL'

update layoffs_staging2 
set date = null 
where date = 'NULL'

alter table layoffs_staging2 
modify column date DATE





-- Null Values

select *
from layoffs_staging2
where industry = "NULL" or industry is null

-- Populate rows where possible
select * 
from layoffs_staging2
where company = 'Airbnb'

select*
from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company =t2.company 
and t1.location = t2.location
where (t1.industry is null or t1.industry ="NULL")
and (t2.industry is not null and t2.industry != 'NULL')

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company 
set t1.industry = t2.industry 
where (t1.industry is null or t1.industry ="NULL")
and (t2.industry is not null and t2.industry != 'NULL')


select total_laid_off
from layoffs_staging2 
where total_laid_off = 'NULL'

update layoffs_staging2 
set total_laid_off = null 
where total_laid_off = 'NULL'


select percentage_laid_off
from layoffs_staging2 
where percentage_laid_off = 'NULL'

update layoffs_staging2 
set percentage_laid_off = null 
where percentage_laid_off = 'NULL'


alter table layoffs_staging2 
modify column total_laid_off int

alter table layoffs_staging2 
modify column percentage_laid_off float





-- Remove unused rows and columns
-- Note that some entries have null values for total laid off and percentage laid off, therefore we can assume there were no layoffs

select * 
from layoffs_staging2
where total_laid_off = "NULL"
and percentage_laid_off ="NULL"

delete 
from layoffs_staging2 
where total_laid_off = "NULL"
and percentage_laid_off ="NULL"

-- Remove row num column
alter table layoffs_staging2 
drop column row_num


