

select *
from CovidVaccinations


select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 2, 3

--Total Deaths vs Total Cases
--Likelihood of deying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%India%'
order by 1, 2


--Total Case VS Population
-- Show percentage of polulation infected with covid

select location, date, population ,total_cases, (total_cases/population)*100 as PopulationInfectedPercentage
from CovidDeaths
where location like '%India%'
order by 1, 2


--Countries With Highest Infection Rate

select location, population, MAX(total_cases) as HigestInfection, MAX((total_cases/population))*100 as PopulationInfectedPercentage
from CovidDeaths
--where location like '%India%'
group by location, population
order by PopulationInfectedPercentage desc


--Countries with Highest Deaths count

select location, population, MAX(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths
--where location like '%India%'
where continent is not null
group by location, population
order by TotalDeaths desc


--Continent With Highest Death

select location, MAX(cast(total_deaths as int)) as TotalDeath
from CovidDeaths
--where location like '%India%'
where continent is null
group by location
order by TotalDeath desc


--

select continent, MAX(cast(total_deaths as int)) as TotalDeath
from CovidDeaths
--where location like '%India%'
where continent is not null
group by continent
order by TotalDeath desc



--Global Number

select date, Sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
       sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from CovidDeaths
--where location like '%India%'
where continent is not null
group by date
order by 1 ,2


--Total Population vs Vacination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location  Order by dea.location, dea.date) as TotalVaccination
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where  dea.continent is not null
order by 2,3


--Temp Table

Create Table #PopulationVaccinatedPercent
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
TotalVaccination numeric
)

insert into #PopulationVaccinatedPercent
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location  Order by dea.location, dea.date) as TotalVaccination
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where  dea.continent is not null
order by 2,3

select *, (TotalVaccination/Population)*100 as VaccinationPercentage
from #PopulationVaccinatedPercent



--Creating view to store data for later


create view PopulationVaccinatedPercentage as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location  Order by dea.location, dea.date) as TotalVaccination
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where  dea.continent is not null
--order by 2,3


--- Checking the view

select *
from PopulationVaccinatedPercentage
