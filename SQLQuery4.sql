
Link to Dataset: https://ourworldindata.org/covid-deaths

select *
From Project2..CovidDeaths
Where continent is not null
order by 3,4

--select *
--From Project2..CovidVaccinations
--order by 3,4

--select data we are going to be using
select Location, date, total_cases, new_cases, total_deaths, population
From Project2..CovidDeaths
order by 1,2

--total cases vs total deaths
--shows likelihood of dying if you have covid in your country
select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From Project2..CovidDeaths
where location like '%states%'
order by 1,2

--total cases vs population
--shows the percentage of people who got covid
select Location, date, total_cases, Population,(total_cases/population)*100 Percentpopulationinfected
From Project2..CovidDeaths
--where location like '%states%'
order by 1,2

--analyzing countries with highest infection rates
select Location,Population, MAX(total_cases) as HighestInfectionCount  ,MAX((total_cases /population))*100 as Percentpopulationinfected
From Project2..CovidDeaths
--where location like '%states%'
Group by Location,population
order by Percentpopulationinfected desc



--showing the countries with highest death count per population
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Project2..CovidDeaths
--where location like '%states%'
Group by Location,population
order by TotalDeathCount desc

--lets break things down into continents
--this shows continents with the highest deathcount
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Project2..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int )) / SUM
(New_Cases) * 100 as DeathPercentage --total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From Project2..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2
--total population vs vaccination
with PopvsVac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Project2..CovidDeaths dea
join Project2..CovidVaccinations vac

on dea.location = vac.location
and dea.date = vac.date
where dea.continent is  not null
--order by 2,3

)
select *, (RollingPeopleVaccinated/ population) * 100
From PopvsVac

--temp table
DROP Table if exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Project2..CovidDeaths dea
join Project2..CovidVaccinations vac

on dea.location = vac.location
and dea.date = vac.date
where dea.continent is  not null
--order by 2,3

select *,(RollingPeopleVaccinated /population) * 100
From #percentPopulationVaccinated

Create View percentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Project2..CovidDeaths dea
join Project2..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is  not null
--order by 2,3
