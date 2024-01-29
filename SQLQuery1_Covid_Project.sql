SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
From  PortfolioProject..CovidDeaths

-- Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From  PortfolioProject..CovidDeaths
where location like '%india%'
where continent is not null
Order by 1,2


-- Looking at Total Cases vs Population
--Shows what population got covid
SELECT Location, date, total_cases, Population, (total_cases/population)*100 as PercentageofPopulationInfected
From  PortfolioProject..CovidDeaths
where location like '%india%'
where continent is not null
Order by 1,2

--Looking ar Counntries with Highest Infection Rate Compared to Population


SELECT Location, Population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentageofPopulationInfected
From  PortfolioProject..CovidDeaths
--where location like '%india%'
Group by Location, Population
where continent is not null
Order by PercentageofPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

SELECT  Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From  PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
Group by Location
Order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY LOCATION

SELECT location, Max(cast(Total_deaths as int)) as TotalDeathCount
From  PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is null
Group by location
Order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From  PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

-- SHowing the Continent with Highest Death Count per Population

SELECT continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From  PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
Group by continent
Order by TotalDeathCount desc


--GLOBAL NUMBERS

SELECT date, Sum(cast(new_cases as int)) as tota_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by date
Order by 1,2

-- Looking at total Population vs Vaccinations

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated, 
--RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- USE CTE

with PopvsVac(Continent, location,Date,Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
