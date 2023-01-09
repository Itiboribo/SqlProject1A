--EXPLORING COVID-19 DATA 
-- AUTHOR KEN
SELECT * 
FROM PortfolioProjectAlex.dbo.CovidDeathsA
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProjectAlex.dbo.CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using in this project

SELECT location,date, total_cases, new_cases,population, CAST(total_deaths as int)
FROM PortfolioProjectAlex.dbo.CovidDeathsA
ORDER BY 1,2

-- looking at total cases vs total deaths
-- shoes likelihood of dying if you contact covid in your country
SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercent
FROM PortfolioProjectAlex..CovidDeathsA
ORDER BY 1,2

-- Looking at total case vs population 
-- shows what percentage of population that got Covid  
SELECT location,date, population, total_cases, total_deaths, (total_cases/population)*100 AS CasePercent
FROM PortfolioProjectAlex.dbo.CovidDeathsA
WHERE location like 'Germany%'
ORDER BY 1,2

-- looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS
	PercentPopulationInfected
FROM PortfolioProjectAlex.dbo.CovidDeathsA
GROUP BY location, population
ORDER by PercentPopulationInfected desc

-- showing countries with highest Death count per population 
SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProjectAlex.dbo.CovidDeathsA
WHERE  continent is not null
GROUP BY location
ORDER by TotalDeathCount desc

-- let brek things down by continent
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProjectAlex.dbo.CovidDeathsA
WHERE  continent is not null
GROUP BY continent
ORDER by TotalDeathCount desc

-- showing the continent with highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProjectAlex.dbo.CovidDeathsA
WHERE  continent is not null
GROUP BY continent
ORDER by TotalDeathCount desc

--GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, 
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercent
FROM PortfolioProjectAlex..CovidDeathsA
--WHERE location like '%states%' 
WHERE continent is not null
ORDER BY 1,2

-- looking for total population vs vaccinations

SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
	OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProjectAlex.dbo.CovidDeathsA AS dea
JOIN PortfolioProjectAlex.dbo.CovidVaccinationsA AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent  is not null
ORDER BY 2,3

-- USE CTE 
WITH PopVSVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
	OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProjectAlex.dbo.CovidDeathsA AS dea
JOIN PortfolioProjectAlex.dbo.CovidVaccinationsA AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent  is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 as RollingVacPercent
FROM PopVsVac

--Temp Table
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric	
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
	OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProjectAlex.dbo.CovidDeathsA AS dea
JOIN PortfolioProjectAlex.dbo.CovidVaccinationsA AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent  is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 as RollingVacPercent
FROM #PercentPopulationVaccinated

-- creating view to store data for later visulization 
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
	OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProjectAlex.dbo.CovidDeathsA AS dea
JOIN PortfolioProjectAlex.dbo.CovidVaccinationsA AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent  is not null

SELECT * 
FROM PercentPopulationVaccinated