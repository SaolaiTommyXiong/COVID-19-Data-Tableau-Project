-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in the United States
Select Location,date,total_cases,total_deaths,population,(total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..['Covid Deaths$']
Where Location like '%states%'
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country
Select Location,date,total_cases,total_deaths,population,(total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..['Covid Deaths$']
--where Location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select Location,date,total_cases,population,(total_cases/population)*100 as CasePercentage
From Portfolio..['Covid Deaths$']
Where Location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
Select Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..['Covid Deaths$']
--where Location like '%states%'
Group by Location,population
order by PercentPopulationInfected DESC

-- Showing countries with Highest Death Count per Population
Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..['Covid Deaths$']
Where continent is not null
Group by Location
order by TotalDeathCount DESC

-- Total deaths by Continent
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..['Covid Deaths$']
Where continent is not null
Group by continent
order by TotalDeathCount DESC

-- Location for some reason includes invalid location values
Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..['Covid Deaths$']
Where continent is null AND
Location != 'low income' AND
Location != 'Lower middle income' AND
Location != 'High income' AND
Location != 'Upper middle income'
Group by Location
order by TotalDeathCount DESC

--Global numbers
Select date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
--,total_deaths,population,(total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..['Covid Deaths$']
--where Location like '%states%'
Where continent is not null
Group by date
order by 1,2

--SUM of Global numbers
Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio..['Covid Deaths$']
Where continent is not null
order by 1,2

-- Looking at New Vaccinations by date
Select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
From Portfolio..['Covid Deaths$'] dea 
Join Portfolio..['Covid Vaccinations$'] vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
AND new_vaccinations is not null
order by 3

-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location
, dea.Date) as Vaccination_Rolling_Count
--, (Vaccination_Rolling_Count/population)*100
From Portfolio..['Covid Deaths$'] dea 
Join Portfolio..['Covid Vaccinations$'] vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
AND new_vaccinations is not null
order by 2,3

-- USE CTE
With PopvsVac (continent, Location, Date, Population,New_Vaccinations, Vaccination_Rolling_Count)
as
(
Select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location
, dea.Date) as Vaccination_Rolling_Count
--, (Vaccination_Rolling_Count/population)*100
From Portfolio..['Covid Deaths$'] dea 
Join Portfolio..['Covid Vaccinations$'] vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
AND new_vaccinations is not null
)
Select *, (Vaccination_Rolling_Count/Population)*100
From PopvsVac

-- TEMP Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Vaccination_Rolling_Count numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location
, dea.Date) as Vaccination_Rolling_Count
--, (Vaccination_Rolling_Count/population)*100
From Portfolio..['Covid Deaths$'] dea 
Join Portfolio..['Covid Vaccinations$'] vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
AND new_vaccinations is not null

Select *, (Vaccination_Rolling_Count/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualization
Create View PercentPopulationVaccinated2 as
Select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location
, dea.Date) as Vaccination_Rolling_Count
--, (Vaccination_Rolling_Count/population)*100
From Portfolio..['Covid Deaths$'] dea 
Join Portfolio..['Covid Vaccinations$'] vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
AND new_vaccinations is not null

-- Creating View example
Create View PortfolioExample1 as
Select Location,date,total_cases,total_deaths,population,(total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..['Covid Deaths$']
Where Location like '%states%'
