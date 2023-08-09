Select *
From PortfolioProject..CovidDeaths$
where continent is not null
Order  by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--Order  by 3,4

Select location,date,total_cases,total_deaths,population
From CovidDeaths$
Order by 1,2


-- Looking at Total cases vs Total deaths
-- Shows Mortality rate in your country

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as 'DeathPercentage'
From CovidDeaths$
Where location= 'India' 
Order by 1,2



-- Looking at Total cases vs Population
-- Shows what percentage of population got COVID

Select location,date,population,total_cases,(total_cases/population)*100 as 'PopulationInfectionPercent'
From CovidDeaths$
Where location = 'India'
Order by 1,2


-- Looking at countries with highest Infection rate compared to population

Select location,population,MAX(total_cases) as HighestInfected,MAX((total_cases/population)*100) as 'PopulationInfectionPercent'
From CovidDeaths$
Group by location,population 
Order by PopulationInfectionPercent DESC



-- Showing Countries with highest Deathcount 

Select location, MAX(cast(total_deaths as int)) as 'TotalDeathCount'
From CovidDeaths$
where continent is not null
Group by location
Order by TotalDeathCount DESC



-- Showing the Continents with the highest Deathcounts

Select continent , MAX(cast(total_deaths as int)) as 'TotalDeathCount'
From CovidDeaths$
where continent is not null 
Group by continent
Order by TotalDeathCount DESC



-- GLOBAL NUMBERS --

Select Sum(new_cases) as 'Total Cases',Sum(CAST(new_deaths as int)) as 'Total Deaths',
(Sum(CAST(new_deaths as int))/Sum(new_cases))*100 as 'Death percentage'
From CovidDeaths$
Where continent is not null


-- Global number day wise

Select date,Sum(new_cases) as 'Total Cases',Sum(CAST(new_deaths as int)) as 'Total Deaths',
(Sum(CAST(new_deaths as int))/Sum(new_cases))*100 as 'Death percentage'
From CovidDeaths$
Where continent is not null
Group by date
order by 1


-- Looking at Total Population vs Vaccinations

Select d.continent,d.location,d.date,population,v.new_vaccinations,
SUM(Convert(int,v.new_vaccinations)) Over (Partition by d.location Order by d.location,d.date) as RollingPeopleVaccinated --Parttion is there to stop the sum count and start again
--, (RollingPeopleVaccinated/population)*100 
--we cant' use alias name here
From CovidDeaths$ d
Join CovidVaccinations$ v
	On d.location =v.location
	and d.date= v.date
Where d.continent is not null
order by 2,3

-- To Counter above issue there are two methods

-- 1. USE CTE (Common Table Expression)

With PopVsVac (Continent, location,date,population,new_vaccinations,RollingPeopleVaccinated)
As
(
Select d.continent,d.location,d.date,population,v.new_vaccinations,
SUM(Convert(int,v.new_vaccinations)) Over (Partition by d.location Order by d.location,d.date) as RollingPeopleVaccinated --Parttion is there to stop the sum count and start again
--, (RollingPeopleVaccinated/population)*100 
--we cant' use alias name here
From CovidDeaths$ d
Join CovidVaccinations$ v
	On d.location =v.location
	and d.date= v.date
Where d.continent is not null
-- order by 2,3 --Cant' use this inside CTE
)
Select *, (RollingPeopleVaccinated/population)*100 as RollingPercent
From PopVsVac
Order by 2,3


-- 2. USE TEMP TABLE 

DROP Table if exists #PercentPopVaccinated
Create Table #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopVaccinated
Select d.continent,d.location,d.date,population,v.new_vaccinations,
SUM(Convert(int,v.new_vaccinations)) Over (Partition by d.location Order by d.location,d.date) as RollingPeopleVaccinated --Parttion is there to stop the sum count and start again
--, (RollingPeopleVaccinated/population)*100 
--we cant' use alias name here
From CovidDeaths$ d
Join CovidVaccinations$ v
	On d.location =v.location
	and d.date= v.date
Where d.continent is not null


Select *, (RollingPeopleVaccinated/population)*100 as RollingPercent
From #PercentPopVaccinated
Order by 2,3



-- Creating View for visualistion for later

Create View PercentPopVaccinated as 
Select d.continent,d.location,d.date,population,v.new_vaccinations,
SUM(Convert(int,v.new_vaccinations)) Over (Partition by d.location Order by d.location,d.date) as RollingPeopleVaccinated --Parttion is there to stop the sum count and start again
--, (RollingPeopleVaccinated/population)*100 
--we cant' use alias name here
From CovidDeaths$ d
Join CovidVaccinations$ v
	On d.location =v.location
	and d.date= v.date
Where d.continent is not null
-- Order by 2,3

Select *
From PercentPopVaccinated
Order by 2,3