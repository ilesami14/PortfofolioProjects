select *
from PortfolioProject..CovidDeath$
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

-- Select Date that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeath$
where continent is not null
order by 1,2


-- Looking at Total Case vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from PortfolioProject..CovidDeath$
where location like '%state%'
and continent is not null
order by 1,2

 -- Looking at Tocal Cases vs Populations 
 -- Show what percentage of population got covid
 
select location, date, population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PopulationPercentage
from PortfolioProject..CovidDeath$
-- where location like '%state%'
where continent is not null
order by 1,2

-- Looking at countries with Highest incfection Rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount, Max(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PopulationPercentageInfected
from PortfolioProject..CovidDeath$
-- where location like '%state%'
where continent is not null
Group by location, population
order by PopulationPercentageInfected desc

-- Showing Countries with Highest Death count per Population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath$
--where location like '%state%'
where continent is not null
Group by location
order by TotalDeathCount  desc

-- Let's break things down by continent


-- showing the continent with highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath$
--where locatiodescn like '%state%'
where continent is  not null
Group by continent
order by TotalDeathCount Desc


-- showing continent total new death

select continent, sum(new_deaths) as TotalNewDeath
from PortfolioProject..CovidDeath$
where continent !=''
group by continent

-- GLOBAL NUMBERS
--total cases per day

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as DeathPercentage
from PortfolioProject..CovidDeath$
where continent !=''
group by date
order by 1,2

-- total casea across the world

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 [DeathPercentage]
from PortfolioProject..CovidDeath$
where continent !=''
--group by date
order by 1,2


-- Looking at Total Population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date ) [RollingPeopleVaccinated]

from PortfolioProject..CovidDeath$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent !=''
order by 2,3

--Use Cte

with PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date ) [RollingPeopleVaccinated]

from PortfolioProject..CovidDeath$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent !=''
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- Using Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date ) [RollingPeopleVaccinated]

from PortfolioProject..CovidDeath$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent !=''
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date ) [RollingPeopleVaccinated]

from PortfolioProject..CovidDeath$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent !=''
--order by 2,3

select *
from PercentPopulationVaccinated