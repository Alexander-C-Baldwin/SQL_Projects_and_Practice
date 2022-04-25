/* 
	Covid-19 Data Exploration using Microsoft SQL Server Management Studio

	Skills demonstrated: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

/* Explore data with queries
	then want to look at data and queries from viewpoint of visualizing it.
	drilldown layers. easier seen with Tableau */

Select *
FROM PortfolioProject..CovidDeaths
order by 3,4;

DELETE FROM PortfolioProject..CovidDeaths where population IS NULL;

Select *
FROM PortfolioProject..CovidDeaths
order by 3,4;

-- Select data to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2;

-- Looking at Total Cases vs Population
-- Shows what % of population infected with Covid

SELECT location, date, Population, total_cases, (total_cases/population)*100 as PopwithCovid
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2;


SELECT location, date, Population, total_cases, (total_cases/population)*100 as PopwithCovid
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2;

-- Looking at countries with highest infection rate compared to population

SELECT location, Population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc;

-- showing countries with Highest Death Count per Population
-- result is obviously inaccurate. Issue is the datatype for column, must cast to integer or numeric

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location
order by TotalDeathCount desc;

-- After running query found that there is issue with location. It is including status other than countries such as income, continent
-- Found out by looking at * query it has continent column in some that are null and the others status are appearing in location
-- need to add continent is not null to each query

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent IS NOT NULL
group by location
order by TotalDeathCount desc;

-- Now breaking things down by continent
-- Showing continents with highest death count per populaton

SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent IS NOT NULL
group by continent
order by TotalDeathCount desc;

-- Previous query returns results that are not accurate
-- Need to adjust query to find a way to get accurate results.
-- Turns out the correct way to query this dataset include continent is null
-- Need to look at previous query and rerun to make sure numbers are accurate

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent IS NULL
group by location
order by TotalDeathCount desc;

-- Oceania is small total deaths checking to see which countries are in Oceania

select location from PortfolioProject..CovidDeaths where continent = 'Oceania' group by location;

-- Want to look at data and queries from the viewpoint of visualizing for Tableau later on
-- Want to visualize across the entire world

--GLOBAL NUMBERS

-- When grouping by date need to start using agg functions. Need to swap sum new cases with total cases. etc
-- following shows cases and deaths per day

SELECT date, sum(new_cases) as total_cases, sum(CAST(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2;

-- shows total cases, deaths for world

SELECT sum(new_cases) as total_cases, sum(CAST(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2;


-- check out other table

Select *
FROM PortfolioProject..CovidVaccinations
order by 3,4;

-- join tables on location and date
-- check joined columns to make sure joined correctly

select *
from PortfolioProject..CovidDeaths as death
join PortfolioProject..CovidVaccinations as vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date

-- Looking at Total population vs Vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
from PortfolioProject..CovidDeaths as death
join PortfolioProject..CovidVaccinations as vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
order by 2, 3

-- rolling count for vaccinations. important to order by date

select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
sum(cast(vaccine.new_vaccinations as bigint)) over (partition by death.location order by death.location , death.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as death
join PortfolioProject..CovidVaccinations as vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
order by 2, 3

-- To find rolling % of pop thats vaxed (rolling people vaccinated / population) use CTE
-- Using CTE to perform Calculation on Partition By in previous query

WITH PopVsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
sum(cast(vaccine.new_vaccinations as bigint)) over (partition by death.location order by death.location , death.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as death
join PortfolioProject..CovidVaccinations as vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
--order by 2, 3
)

Select *, (RollingPeopleVaccinated/population) * 100
from PopVsVac;

-- Temp Table - queries in temp table
-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
sum(cast(vaccine.new_vaccinations as bigint)) over (partition by death.location order by death.location , death.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as death
join PortfolioProject..CovidVaccinations as vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/population) * 100
from #PercentPopulationVaccinated;


-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
sum(cast(vaccine.new_vaccinations as bigint)) over (partition by death.location order by death.location , death.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as death
join PortfolioProject..CovidVaccinations as vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
--order by 2, 3

Select *
from PercentPopulationVaccinated