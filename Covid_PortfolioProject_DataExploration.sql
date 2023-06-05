--SELECT *
--FROM PortfolioProject..CovidDeaths
--WHERE continent is not null
--Order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2

-- Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS percentage_death
FROM PortfolioProject..CovidDeaths
WHERE location like 'Thailand'
--and continent is not null
order by 1,2

-- Total Cases vs Population

SELECT Location, date, population,total_cases, (total_cases/population)*100 AS percentage_infected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%States%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) as highest_infected_count, MAX((total_cases/population))*100 AS percentage_infected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%States%'
GROUP BY Location, population
order by percentage_infected desc


-- Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) as death_count_total
FROM PortfolioProject..CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
GROUP BY Location
order by  death_count_total  desc


-- Continent with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount  desc


-- Global numbers

-- Total cases and deaths by date
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS percentage_death
FROM PortfolioProject..CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
GROUP BY date
order by 1,2

-- Whole world Total cases and deaths
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS percentage_death
FROM PortfolioProject..CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
--GROUP BY date
order by 1,2


-- Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as cumulative_people_vaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3


-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, cumulative_people_vaccinated) 
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as cumulative_people_vaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- Order by 2,3
)
Select *, (cumulative_people_vaccinated/Population)*100 as pop_vaccinated_percentage
From PopvsVac



-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
cumulative_people_vaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as cumulative_people_vaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
-- Order by 2,3

Select *, (cumulative_people_vaccinated/Population)*100 as pop_vaccinated_percentage
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

DROP View PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, 
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- Order by 2,3

Select *
From PercentPopulationVaccinated

