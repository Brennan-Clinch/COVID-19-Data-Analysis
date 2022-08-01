select *
from PortfolioProject..Covid_Deaths
order by 3,4


--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

--select data that we will be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..Covid_Deaths
order by 1,2


--Looking at total cases vs Total Deaths
--This query shows the probability of dying if you get covid
select Location, date, total_cases, Population, total_deaths, (total_cases/population) * 100 as PercentPopInfected
from PortfolioProject..Covid_Deaths
where Population <100000
--where location like '%states%'
order by 1,3

-- Looking at Countries with largest infection rate compared to the population

select Location, Population, max(total_cases) as HighestInfectionCount, max((total_cases/population)) * 100 
as PercentPopInfected
from PortfolioProject..Covid_Deaths
--where location like '%states%'
where continent is not null
group by Location, Population
order by PercentPopInfected desc

-- Showing Countries with Highest Death Count per Population

select Location, max(total_deaths) as TotalDeathCount
from PortfolioProject..Covid_Deaths
--where location like '%states'
where continent is not null
group by location
order by TotalDeathCount desc


--Broken down by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..Covid_Deaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(new_deaths)/sum(new_cases) *100 as DeathPercentage
from PortfolioProject..Covid_Deaths
--where location like '%states%'
where continent is not null
group by date 
order by 1,2

with PopvsVac (Continent, Location, Date, Population, New_vaccinations,RollingPeopleVaccinated)
as
(

--Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
--order by 2,3
)

select * , (RollingPeopleVaccinated/Population) * 100
from PopvsVac


--Temp Table
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   order by 2,3


select * , (RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated

-- Creating View to Store Data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   --order by 2,3

select * from PercentPopulationVaccinated