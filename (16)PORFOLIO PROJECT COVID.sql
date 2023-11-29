SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order by 3,4 

SELECT *
FROM PortfolioProject..CovidVaccinations
Order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order by 1,2

--looking at total cases vs total deaths
--Shows percentage of deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%Malaysia%'
Order by 1,2 

--Looking at total cases vs population
--Shows percentage of population got Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%Malaysia%'
Order by 1,2

--Looking at country with highest infection rates compare to population
SELECT Location, population, MAX(total_cases) as HighestInfectionRates, MAX((total_cases/population))*100 as InfectionRates
FROM PortfolioProject..CovidDeaths
Group by location, population
Order by InfectionRates desc

--Showing countries with the highest death count per population

SELECT Location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by location
Order by TotalDeathCount desc

--breaking down by location

SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
Group by location
Order by TotalDeathCount desc

--breaking things down by continent

--showing continent with the highest death count per population

SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%Malaysia%'
WHERE continent is not null 
--Group by date
Order by 1,2 


--CovidVaccinations table

SELECT* 
FROM PortfolioProject..CovidVaccinations

--JOIN both tables
SELECT *
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location 
	and dea.date = vac.date

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY 
	dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY 
	dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP TABLE

DROP TABLE if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY 
	dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/population)*100
From #PercentagePopulationVaccinated


--CREATE View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY 
	dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated