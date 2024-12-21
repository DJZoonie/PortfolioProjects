select * 
from layoffs_staging2

-- Shows max people laid off and max percentage of people laid off
select MAX(total_laid_off), MAX(percentage_laid_off)
from layoffs_staging2


-- Shows companies that were shutdown and their total layoffs
select *
from layoffs_staging2 
where percentage_laid_off = 1
order by total_laid_off desc 


-- Shows sum of layoffs for each company
select company, Sum(total_laid_off)
from layoffs_staging2
group by company 
order by 2 desc


-- Shows the date range of the layoffs
select Min(date), Max(date)
from layoffs_staging2 


-- Shows industries with the most layoffs
select industry, sum(total_laid_off)
from layoffs_staging2 ls 
group by industry 
order by 2 desc


-- Shows the countries with the most layoffs
select country, sum(total_laid_off)
from layoffs_staging2 ls 
group by country 
order by 2 desc


-- Shows the layoffs that occured each year
select year(date), sum(total_laid_off)
from layoffs_staging2 ls 
group by year(date)
order by 1 desc 


-- Shows the layoffs for each stage of a company
select stage, sum(total_laid_off)
from layoffs_staging2 ls 
group by stage
order by 2 desc 



-- Rolling sum of layoffs per month

select substring(date,1,7) as month, sum(total_laid_off)
from layoffs_staging2 ls 
where substring(date,1,7) is not null 
group by month
order by 1 asc

with Rolling_Total as (
select substring(date,1,7) as month, sum(total_laid_off) as total_off
from layoffs_staging2 ls 
where substring(date,1,7) is not null 
group by month
order by 1 asc
)
select month, total_off, Sum(total_off) Over(order by month) as rolling_total
from Rolling_Total



-- Shows the sum of people laid off each year per company
select company, year(date), sum(total_laid_off)
from layoffs_staging2 ls 
group by company, year(date)
order by 3 desc

-- Ranks the top 5 companies with the largest amounts of layoffs for each year
with Company_Year (company, years, total_laid_off) as(
select company, year(date), sum(total_laid_off)
from layoffs_staging2 ls 
group by company, year(date)
order by 3 desc
), Company_Year_Ranking as(
select *, 
dense_rank()over(partition by years order by total_laid_off desc) as ranking
from Company_Year
where years is not null
)
select * 
from Company_Year_Ranking
where ranking <= 5






