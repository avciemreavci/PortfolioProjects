select*
from PortfolioProject..CovidDeaths
order by 3,4
--select*
--from PortfolioProject..CovidDeaths
--order by 3,4
--Select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by location, date
--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like 'Germany'
order by location, date
--Looling at Total Cases vs Population
--Shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Where location like 'Germany'
order by location, date

--Loking at Countries with Highest Infection Rate compered to Population
select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths

--Where location like 'Germany'
Group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest  
select location, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like 'Germany'
where continent is not null
Group by location
order by TotalDeathCount desc

--Global Number
 select date, sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,
 sum(cast(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by  1,2

 select  sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,
 sum(cast(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
order by  1,2

 --Looking at Total Population vs Vaccinations

 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location,dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea
 join PortfolioProject ..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 2,3

 --use CTE
 with PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea
 join PortfolioProject ..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from Popvsvac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea
 join PortfolioProject ..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 --where dea.continent is not null
-- order by 2,3
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating View to store data for later Visualizations
Create view PercentPopulationVaccinated as

 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea
 join PortfolioProject ..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 2,3