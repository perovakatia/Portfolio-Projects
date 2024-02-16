Select * from PortfolioProject..CovidDeaths$
where continent is not null
order by 3, 4

--select * from PortfolioProject..CovidVaccinations$
--order by 3, 4

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

ALTER TABLE PortfolioProject..CovidDeaths$ ALTER COLUMN total_deaths float
ALTER TABLE PortfolioProject..CovidDeaths$ ALTER COLUMN population float



-- Looking at total cases VS total deaths
-- Shows likelihood of dying if you contract Covid in some country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where location = 'Russia'
and continent is not null
order by 1,2

 -- Looking at total cases VS population
 -- Shows what percentage of population got Covid

 Select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
from PortfolioProject..CovidDeaths$
Where location = 'Russia'
and continent is not null
order by 1,2

-- Looking at countries with highest infection rate compared to Population

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PecentPopInfected
from PortfolioProject..CovidDeaths$
where continent is not null
group by location, population
order by PecentPopInfected desc

-- Showing countries with Highest Death Count per Population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc


-- Showing the continents with highest death count

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLobal numbers

Select sum(cast(new_cases as float)) as total_cases, sum(cast(new_deaths as float)) as total_deaths, 
sum(cast(new_deaths as float))/NULLIF(sum(cast(new_cases as float)),0) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--Where location = 'Russia'
where continent is not null
--group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP table


Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select * from PercentPopulationVaccinated


