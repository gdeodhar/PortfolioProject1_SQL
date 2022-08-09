SELECT *
FROM PortfolioProject_1.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject_1.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows percentage of dying if you contract Covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject_1.dbo.CovidDeaths
WHERE location like '%states%' 
AND continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject_1.dbo.CovidDeaths
--WHERE location like '%states%' 
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject_1.dbo.CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
 FROM PortfolioProject_1.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject_1.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject_1.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- GLOBAL NUMBERS without date grouping

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject_1.dbo.CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2



SELECT *
FROM PortfolioProject_1.dbo.CovidDeaths dea
JOIN PortfolioProject_1.dbo.CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
ORDER BY 4


--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject_1.dbo.CovidDeaths dea
JOIN PortfolioProject_1.dbo.CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Use CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject_1.dbo.CovidDeaths dea
JOIN PortfolioProject_1.dbo.CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS Percent_RollingPeopleVaccinated
FROM PopvsVac


--Temp Table  to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject_1.dbo.CovidDeaths dea
JOIN PortfolioProject_1.dbo.CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS Percent_RollingPeopleVaccinated
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject_1.dbo.CovidDeaths dea
JOIN PortfolioProject_1.dbo.CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

