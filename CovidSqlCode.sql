SELECT *
FROM PortfolioProject..[covid-deaths]
order by date

-- CLEANING DATASET covid_deaths
UPDATE PortfolioProject..[covid-deaths] 
SET total_deaths = NULLIF(total_deaths, '')

UPDATE PortfolioProject..[covid-deaths] 
SET total_cases = NULLIF(total_cases, '')

UPDATE PortfolioProject..[covid-deaths] 
SET population = NULLIF(population, '')

UPDATE PortfolioProject..[covid-deaths] 
SET new_cases = NULLIF(new_cases, '')

UPDATE PortfolioProject..[covid-deaths] 
SET new_deaths = NULLIF(new_deaths, '')

ALTER TABLE PortfolioProject..[covid-deaths]  
ALTER COLUMN total_deaths NUMERIC;

ALTER TABLE PortfolioProject..[covid-deaths]  
ALTER COLUMN total_cases NUMERIC;

ALTER TABLE PortfolioProject..[covid-deaths]
ALTER COLUMN population BIGINT;

ALTER TABLE PortfolioProject..[covid-deaths]  
ALTER COLUMN date date;

ALTER TABLE PortfolioProject..[covid-deaths]  
ALTER COLUMN new_cases NUMERIC;

ALTER TABLE PortfolioProject..[covid-deaths]  
ALTER COLUMN new_deaths NUMERIC;

-- Let's look at the Death Percentage
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..[covid-deaths]
where location NOT IN ('World', 'High income', 'Upper middle income', 'Africa', 'Europe', 'North America', 'Asia', 'Lower middle income', 'South America', 'European Union')

-- Percentage shows likelihood of dying if you contract in India
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..[covid-deaths]
where location = 'India'
order by date, location;

-- What percent of population got covid over time
SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectionPercent
FROM PortfolioProject..[covid-deaths]
where location = 'India'
order by date, location;

-- Looking at countries with high infection rate
SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectionPercent
FROM PortfolioProject..[covid-deaths]
where location NOT IN ('World', 'High income', 'Upper middle income', 'Africa', 'Europe', 'North America', 'Asia', 'Lower middle income', 'South America', 'European Union')
order by date, location;

-- Countries with Highest Percentage of Population infected
SELECT location, population AS Popu, MAX(total_cases) AS Cases, MAX((total_cases/population))*100 AS PercentPopuInfectd
FROM PortfolioProject..[covid-deaths]
where location NOT IN ('World', 'High income', 'Upper middle income', 'Africa', 'Europe', 'North America', 'Asia', 'Lower middle income', 'South America', 'European Union')
group by location, population
order by PercentPopuInfectd desc

-- Countries with High Death Count per Population
select location, MAX(total_deaths) as Deaths
from PortfolioProject..[covid-deaths]
where location NOT IN ('World', 'High income', 'Upper middle income', 'Africa', 'Europe', 'North America', 'Asia', 'Lower middle income', 'South America', 'European Union')
group by location
order by Deaths desc

-- Showing continents with highest death count
select location, MAX(cast(total_deaths as int)) as Deaths
from PortfolioProject..[covid-deaths]
where continent = '' and location not in ('World','High income', 'Upper middle income', 'Lower middle income', 'European Union', 'Low income', 'Oceania', 'International')
group by location
order by Deaths desc

-- GLOBAL NUMBERS
-- Death Percentage
select date, sum(cast(new_cases as int)) as NewCases, SUM(cast(new_deaths as int)) as NewDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercent
from PortfolioProject..[covid-deaths]
where location NOT IN ('World', 'High income', 'Upper middle income', 'Africa', 'Europe', 'North America', 'Asia', 'Lower middle income', 'South America', 'European Union')
group by date
order by 1,2

-- Total Death Percentage for the whole world
select sum(cast(new_cases as int)) as NewCases, SUM(cast(new_deaths as int)) as NewDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercent
from PortfolioProject..[covid-deaths]
where location NOT IN ('World', 'High income', 'Upper middle income', 'Africa', 'Europe', 'North America', 'Asia', 'Lower middle income', 'South America', 'European Union')
order by 1,2

-- ------------------------------------------------------------------------------------------------------------------

SELECT *
FROM PortfolioProject..[covid-vaccinations]
order by date

-- CLEANING DATASET
UPDATE PortfolioProject..[covid-vaccinations] 
SET total_tests = NULLIF(total_tests, '')

UPDATE PortfolioProject..[covid-vaccinations] 
SET new_tests = NULLIF(new_tests, '')

UPDATE PortfolioProject..[covid-vaccinations] 
SET total_vaccinations = NULLIF(total_vaccinations, '')

UPDATE PortfolioProject..[covid-vaccinations] 
SET new_vaccinations = NULLIF(new_vaccinations, '')

UPDATE PortfolioProject..[covid-vaccinations] 
SET people_vaccinated = NULLIF(people_vaccinated, '')

ALTER TABLE PortfolioProject..[covid-vaccinations]  
ALTER COLUMN new_vaccinations NUMERIC;

ALTER TABLE PortfolioProject..[covid-vaccinations]  
ALTER COLUMN people_vaccinated NUMERIC;


-- Looking at Total Population Vs Vaccinations
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
from PortfolioProject..[covid-deaths] Dea
JOIN PortfolioProject..[covid-vaccinations] Vac
ON Dea.location = Vac.location
where Dea.location NOT IN ('World', 'High income', 'Upper middle income', 'Africa', 'Europe', 'North America', 'Asia', 'Lower middle income', 'South America', 'European Union')
and Dea.date = Vac.date
order by 2,3


-- Vaccination wrt Population - Percentage
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, Vac.people_vaccinated, (Vac.people_vaccinated/population)*100 as VaccPerPopu
from PortfolioProject..[covid-deaths] Dea
JOIN PortfolioProject..[covid-vaccinations] Vac
ON Dea.location = Vac.location
where Dea.location NOT IN ('World', 'High income', 'Upper middle income', 'Lower middle income', 'European Union', 'Africa', 'Europe', 'North America', 'Asia', 'South America')
and Dea.date = Vac.date
order by 2,3


-- TEMP TABLE

create table  #VaccinatedPopulation
(
continent varchar(50),
location varchar(50),
date date,
population bigint,
new_vaccinations numeric,
people_vaccinated numeric,
VaccPerPopu numeric
)

insert into #VaccinatedPopulation
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, Vac.people_vaccinated, (Vac.people_vaccinated/population)*100 as VaccPerPopu
from PortfolioProject..[covid-deaths] Dea
JOIN PortfolioProject..[covid-vaccinations] Vac
ON Dea.location = Vac.location
where Dea.location NOT IN ('World', 'High income', 'Upper middle income', 'Lower middle income', 'European Union', 'Africa', 'Europe', 'North America', 'Asia', 'South America')
and Dea.date = Vac.date
order by 2,3

select * from #VaccinatedPopulation

-- Create View
create view VaccinatedPopu as 
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, Vac.people_vaccinated, (Vac.people_vaccinated/population)*100 as VaccPerPopu
from PortfolioProject..[covid-deaths] Dea
JOIN PortfolioProject..[covid-vaccinations] Vac
ON Dea.location = Vac.location
where Dea.location NOT IN ('World', 'High income', 'Upper middle income', 'Lower middle income', 'European Union', 'Africa', 'Europe', 'North America', 'Asia', 'South America')
and Dea.date = Vac.date

Select * from VaccinatedPopu
