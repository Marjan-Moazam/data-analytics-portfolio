Select *
From CovidDeath
Order by 3,4

Select *
From PortfolioProject..CovidVaccination
--Order by select *

--Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeath
where continent is not null 
Order by 1, 2

--Looking at Total Cases vs Total Deaths
--Show likelihood of dying if you contract covid in your country
Select location, date,total_cases, population, 
(cast(total_deaths as int) / total_cases)  As DeathPercentage ,
total_cases / population As GotCovid
From CovidDeath
where continent is not null and location like '%den%' 
Order by 1, 2

--Showing countries with highest Infection Rate compared to population
Select location, population, Max(total_cases) As HighestInfectionCount, 
(Max(total_cases) / population) As PercentPopulationInfected
From CovidDeath
where continent is not null
group by location, population
Order by PercentPopulationInfected Desc

--Showing countries with highest Death Count per population
Select location, population, Max(cast(total_deaths as int)) As HighestDeathCount, 
(Max(cast(total_deaths as int)) / population) As PercentPopulationDeath
From CovidDeath	
where continent is not null
group by location, population
Order by PercentPopulationDeath Desc

Select continent, population, Max(cast(total_deaths as int)) As HighestDeathCount, 
(Max(cast(total_deaths as int)) / population) As PercentPopulationDeath
From CovidDeath	
where continent is not null
group by continent, population
Order by PercentPopulationDeath Desc

--Showing contintents with the highest death count per population
Select continent, Max(cast(total_deaths as int)) As HighestDeathCount
From CovidDeath	
where continent is not null
group by continent
Order by HighestDeathCount Desc

Select  date, Sum(new_cases) As TotalNewCases, Sum(cast(new_deaths as int)) As TotallNewDeathes, Sum(cast(new_deaths as int)) / Sum(new_cases)
From CovidDeath
where continent is not null
group by date
having Sum(new_cases) > 0
Order by 1, 2 Desc

--Use CTE 
with PopvsVac (continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location and 
	   dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population) 
From PopvsVac

--Temp table
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated   
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location and 
	   dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population) 
From #PercentPopulationVaccinated 

--Creating View to store data for later visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location and 
	   dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated