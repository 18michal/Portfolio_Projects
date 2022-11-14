
-- Covid 19 Data Exploration 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Poland'
ORDER BY 1,2


-----------------------------------------------------------------
-- Total Cases vs Total Deaths in Poland
-- Shows likelihood of dying if you contract Covid in Poland
SELECT location, date, total_cases, total_deaths, (total_deaths / CONVERT(float, total_cases))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%Poland%'
ORDER BY 1,2


-----------------------------------------------------------------
-- Total Cases vs Population
SELECT location, date, total_cases, population, (CAST(total_cases AS float) / population)*100 AS InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%Poland%'
ORDER BY 1,2


-----------------------------------------------------------------
--Countires with Highest Infection Rate compared to Population
SELECT continent, location, MAX(CAST(total_cases AS float)) AS HighestInfectionCount, MAX((CAST(total_cases AS float) / population)*100) AS PopulationInfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, continent
ORDER BY PopulationInfectedPercentage DESC


-----------------------------------------------------------------
-- Continents with Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths AS float)) AS TotalDeathCount, MAX(CAST(total_deaths AS float) / population *100) AS PopulationDeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY PopulationDeathPercentage DESC



-----------------------------------------------------------------
-- Worldwide numbers showing DeathPercentage year by year
SELECT YEAR(date) as Year, SUM(CAST(new_deaths AS float)) AS NewDeaths, SUM(CAST(new_cases AS float)) AS NewCases, SUM(CAST(new_deaths AS float)) / SUM(CAST(new_cases AS float)) *100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY YEAR(date)
ORDER BY 1


-----------------------------------------------------------------
--Total Population vs Vaccinations in Poland and Germany
--CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
	AS (
		SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		FROM PortfolioProject.dbo.CovidDeaths dea
		JOIN PortfolioProject.dbo.CovidVaccinations vac
		ON dea.location = vac.location AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL
		)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PeopleVaccinatedPercentage
FROM PopvsVac
WHERE location = 'Poland' OR location = 'Germany'
ORDER BY 2,3


-----------------------------------------------------------------
--Max Total Population vs Vaccinations

DROP TABLE IF EXISTS PercentPopulationVaccinated

CREATE TABLE  PercentPopulationVaccinated
	(Continent NVARCHAR(255),
	Location NVARCHAR(255),
	Date DATETIME,
	Population NUMERIC,
	New_vaccinations NUMERIC,
	RollingPeopleVaccinated NUMERIC)

INSERT INTO PercentPopulationVaccinated
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject.dbo.CovidDeaths dea
	JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/population)*100 AS PeopleVaccinatedPercentage
FROM PercentPopulationVaccinated
ORDER BY 2,3


-----------------------------------------------------------------
--Creating View
CREATE VIEW PopulationVaccinated AS
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject.dbo.CovidDeaths dea
	JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL

SELECT * 
FROM PopulationVaccinated