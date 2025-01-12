select * from [Portfolio Project].[dbo].[CovidDeaths$]
select * from [Portfolio Project].[dbo].[CovidVaccinations$]
order by 3,4

--select * from [Portfolio Project].[dbo].[CovidVaccinations$]
--order by 3,4

--select data that we will use

select Location, date, total_cases,new_cases,total_deaths, population
from [Portfolio Project].dbo.[Coviddeaths$]
order by 1,2 

-- Looking at Total deaths to Total cases
-- Shows the likelihood of dying if you contract covid in your country
select Location, date, total_cases,total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from [Portfolio Project].dbo.[Coviddeaths$]
where Location like '%Kenya%'
order by 1,2


--Looking at the Total deaths vs population
-- shows what percentage died from covid
select Location, date, population,total_deaths,  (total_deaths/population) *100 as DeathPercentage
from [Portfolio Project].dbo.[Coviddeaths$]
where Location like '%Kenya%'
order by 1,2

--Looking at Toatal cases vs Population
--shows what percentage got covid

select Location, date, population,total_cases,  (total_cases/population) *100 as DeathPercentage
from [Portfolio Project].dbo.[Coviddeaths$]
where Location like '%Kenya%'
order by 1,2

--Looking at the country with the highest infection rate compared to Population

select Location, date, max(total_cases) as Highestinfectioncount, max((total_cases/population)) *100 as Percentageofinfection
from [Portfolio Project].dbo.[Coviddeaths$]
group by Location,date, population 
order by Percentageofinfection desc

-- Showing countries with the highest deaths count per population
select Location, max(total_deaths) as Totaldeathscount
from [Portfolio Project].dbo.[Coviddeaths$]
--where Location like '%Kenya%'
group by Location
order by Totaldeathscount desc


-- Grouping total deaths by continent
select Location, max(cast(total_deaths as int)) as Totaldeathscount
from [Portfolio Project].dbo.[Coviddeaths$]
--where Location like '%Kenya%'
where Location is not null
group by Location
order by Totaldeathscount desc

--GLOBAL NUMBERS
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int))as TotalDeaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage--total_deaths,total_cases, (total_deaths/total_cases) *100 as DeathPercentage
from [Portfolio Project].dbo.[Coviddeaths$]
where continent is not null
--group by date
order by 1,2


--Looking at Total population vs Vaccinations
select dea.continent,dea.Location,dea.date,dea.population,vac.new_vaccinations,
sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.Location order by dea.location)
from [Portfolio Project].dbo.CovidDeaths$ dea join
[Portfolio Project].dbo.CovidVaccinations$ vac 
on dea.Location=vac.Location
and dea.date=dea.date
where dea.continent is not null
order by 2,3

--Looking at Total population vs Vaccinations
select dea.continent,dea.Location,dea.date,dea.population,vac.new_vaccinations,
sum(convert (bigint, vac.new_vaccinations)) over 
(partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.CovidDeaths$ dea 
join
[Portfolio Project].dbo.CovidVaccinations$ vac 
on dea.Location=vac.Location
and dea.date=dea.date
where dea.continent is not null
order by 2,3



--TEMP TABLE
--Drop table if exists PercentPopulationVaccinated

create table PercentPopulationVaccinated
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into PercentPopulationVaccinated
select dea.continent,dea.Location,dea.date,dea.population,vac.new_vaccinations,
sum(convert (bigint, vac.new_vaccinations)) over 
(partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.CovidDeaths$ dea 
join
[Portfolio Project].dbo.CovidVaccinations$ vac 
on dea.Location=vac.Location
and dea.date=dea.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from PercentPopulationVaccinated


--creating view to store data for later visualisations

create view PercentPopVaccinated as
select dea.continent,dea.Location,dea.date,dea.population,vac.new_vaccinations,
sum(convert (bigint, vac.new_vaccinations)) over 
(partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.CovidDeaths$ dea 
join
[Portfolio Project].dbo.CovidVaccinations$ vac 
on dea.Location=vac.Location
and dea.date=dea.date
where dea.continent is not null
--order by 2,3
select * from PercentPopVaccinated
