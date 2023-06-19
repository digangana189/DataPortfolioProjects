--select * from PortfolioProject..CovidDeaths
--order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4

--specifying exact data I'd be using 
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Total cases vs Total Deaths(%age of infected people who died)
--how likly death due to covid would be, in my country
Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathRate
From PortfolioProject..CovidDeaths
Where location='India'
Order by 1,2


-- Total cases and deaths vs population(%age of population who got infected and died)
Select location, date, population, total_cases, total_deaths,
(total_cases/population)*100 as InfectedRate,(total_deaths/population)*100 as DeathRatebyPopulation
From PortfolioProject..CovidDeaths
Where location='India'
Order by 1,2

--Countries with highest Infection rate comapared to population
Select location, population, max(total_cases) as HighestInfectionRate,max((total_cases/population))*100 as InfectedPercent
From PortfolioProject..CovidDeaths
Group by location, population
Order by InfectedPercent desc

--Countries with highest Death count compared to population
Select location, population,  max(total_deaths) as HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
--some continent names found in location instead of continents in this data, there continent is null
--so selecting data where it's not null 
Group by location, population
Order by HighestDeathCount desc
 

 --Continents with highest Death count compared to population
Select location, max(total_deaths) as HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
Order by HighestDeathCount desc

-- Global Estimates 
--Using new_cases instead of total_cases, as the total one is cumulative measure(will add up all duplicates)
Select SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, 
SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 

--using cte
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingCountVaccination)
as
(
--Total population vs total vaccinations
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) 
OVER (Partition by dth.location  order by dth.location, dth.date) as RollingCountVaccination
--partition by location and order by date, as count should renew for every new location
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null 
--order by 2,3
)
select *,(RollingCountVaccination/Population)*100
from PopvsVac

--Same as abv but with temp table
DROP Table if exists #PercentPopulationVaccinated
--drop table in case create table query is run multiple times
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCountVaccination numeric
)
Insert into #PercentPopulationVaccinated
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) 
OVER (Partition by dth.location  order by dth.location, dth.date) as RollingCountVaccination
--partition by location and order by date, as count should renew for every new location
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null 
--order by 2,3
select *,(RollingCountVaccination/Population)*100
from #PercentPopulationVaccinated



-- Creating View to store data for later visualizations
 
Create View PercentPopulationVaccinated as
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dth.Location Order by dth.location, dth.Date) as RollingCountVaccination
--, (RollingCountVaccination/population)*100
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null




