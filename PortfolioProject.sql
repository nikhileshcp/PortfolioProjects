Select *
from PortfolioProject..CovidDeaths$
order by 3,4;

--Select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

Select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths$
order by 1,2;

---Total Cases vs Total Deaths
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location LIKE '%India%'
order by 1,2;

--- Total Cases vs Population
Select location,date,total_cases,population,(total_cases/population)*100 as DeathPercent
from PortfolioProject..CovidDeaths$
where location like '%India%'
order by 1,2;

-- Countries with highest Infection rate 
Select location,MAX(total_cases) as HighInfection,population,MAX((total_cases/population)*100) as DeathPercentage
from PortfolioProject..CovidDeaths$
group by population,location
order by 4 DESC;

-- Countries with highest Death Count
Select location,Max(cast(total_deaths as int)) as DeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by 2 DESC;

-- Lets break things out by continent
-- Death count by continent

Select continent,Max(cast(total_cases as int)) as DeathCount
from PortfolioProject..CovidDeaths$
Where continent is not null
group by continent
order by 2 DESC;

-- Global Numbers

Select date,sum(new_cases),sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1;

-- Covid Vaccination Table
Select *
from PortfolioProject..CovidVaccinations$
where continent is not null
order by 2,3,4;

-- Lets join both the tables

-- Total people vs vaccination
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Population Vs Vaccination
-- CTE
with PopVsVac (continent,date,location,population,new_vaccination,RollingPeopleVaccinated)
as(
Select dea.date,dea.continent,dea.location,dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/population)*100 as VaccinationPercentage
from PopVsVac



-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinates
create table #PercentPopulationVaccinates
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinates
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select *,(RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinates

-- Creating view for data visulisation


Create View PercentPopulationVaccinat as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3;