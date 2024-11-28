Select * 
From coviddeaths
where NULLIF(continent, '') is not null 
order by 3,4;

Select Location, date, total_cases, new_cases, total_deaths, population 
FROM coviddeaths
order by Location, str_to_date('date', '%d/%m/%Y');

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if covid is contracted
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
FROM coviddeaths
where location like '%states%'
order by Location, str_to_date('date', '%d/%m/%Y');

-- Looking at Total cases vs Population
Select Location, date, total_cases, population, (total_cases/population)*100 as casepercentage 
FROM coviddeaths
where location like '%Canada%'
order by Location, str_to_date('date', '%d/%m/%Y');

-- Looking at countries with highest infection rates compared to population
Select Location, MAX(total_cases) as HighestInfectionCount, population, MAX(total_cases/population)*100 as PercentageOfPopulationInfected 
FROM coviddeaths
-- where location like '%Canada%'
Group by Location,population
order by PercentageOfPopulationInfected desc;

-- Shows Countries with highest death count

Select Location, MAX(total_deaths) as DeathCount
FROM coviddeaths
where NULLIF(continent, '') is not null
group by location
order by DeathCount desc;

-- Group by continent
Select continent, MAX(total_deaths) as DeathCount
FROM coviddeaths
where NULLIF(continent, '') is not null
group by continent
order by DeathCount desc;

-- Showing Global Numbers
Select date, SUM(new_cases) as SumOfNewCases, SUM(new_deaths) as SumOfNewDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths
where NULLIF(continent, '') is not null
group by date
order by str_to_date('date', '%d/%m/%Y');

-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From coviddeaths dea
join covidvaccinations vac on dea.location = vac.location and dea.date = vac.date
where NULLIF(dea.continent, '') is not null
order by str_to_date('date', '%d/%m/%Y');

-- To get rolling percentage of population vaccinated, I can use CTE using previous table

With PopvsVac(Continent,Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From coviddeaths dea
join covidvaccinations vac on dea.location = vac.location and dea.date = vac.date
where NULLIF(dea.continent, '') is not null
)
Select * ,(RollingPeopleVaccinated/population)*100
From PopvsVac;

-- TEMP TABLE
DROP Table PercentPopulationVaccinated;

Create Table PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date nvarchar(255),
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert Into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From coviddeaths dea
join covidvaccinations vac on dea.location = vac.location and dea.date = vac.date
where NULLIF(dea.continent, '') is not null;

Select * ,(RollingPeopleVaccinated/population)*100
From PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

Create View ViewPercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From coviddeaths dea
join covidvaccinations vac on dea.location = vac.location and dea.date = vac.date
where NULLIF(dea.continent, '') is not null;