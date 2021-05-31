--------------------------------------------------------------------------------------------
-- Database: PortfolioProject
USE PortfolioProject;

--------------------------------------------------------------------------------------------
-- Total Cases vs Total Deaths for India
-- DeathPercent gives your chances of die with Covid
SELECT [iso_code],
	[location],
	[date],
	[total_deaths],
	[new_cases],
	(total_deaths / total_cases) * 100 AS DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY DATE;

--------------------------------------------------------------------------------------------
-- Total Covid Cases vs Population in India (Datewise)
SELECT location as Location,
	population as Population,
	DATE as Date,
	(total_cases / population) * 100 AS InfectedPopulation
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'India'
ORDER BY DATE;

--------------------------------------------------------------------------------------------
-- List of Countries with their highest case count
SELECT location as Location,
	population as Population,
	MAX(total_cases) AS HighestCaseCount
	--,MAX((total_cases / population) * 100) AS InfectedPopulation
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY population,
	location
ORDER BY HighestCaseCount DESC;

--------------------------------------------------------------------------------------------
--Death count for Continents 
SELECT --[location] AS Location,
	[continent] as Continent,
	MAX(cast(total_deaths AS INT)) AS HighestDeathCount,
	MAX((total_deaths / population) * 100) AS DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent IS not NULL
GROUP BY  continent
ORDER BY HighestDeathCount DESC;

--------------------------------------------------------------------------------------------
-- Global Numbers for CovidCaseCount (Datewise)
SELECT DATE,
	sum(new_cases) AS TotalCases,
	sum(cast(new_deaths AS INT)) AS TotalDeaths,
	sum(cast(new_deaths AS INT)) / sum(new_cases) * 100 AS DeathTOCase
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
group by date
ORDER BY DATE;

--------------------------------------------------------------------------------------------
--Worldwide Death-TO-Case
SELECT 
	sum(new_cases) AS TotalCases,
	sum(cast(new_deaths AS INT)) AS TotalDeaths,
	sum(cast(new_deaths AS INT)) / sum(new_cases) * 100 AS DeathTOCase
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;

--------------------------------------------------------------------------------------------
--Use CTE for Population VS Vaccination (count)
WITH POPvsVAC (
continent, location, date, population, New_vaccinations, RollingPeopleVaccinatedCount)
as
(
SELECT cd.continent AS continent,
	cd.location AS location,
	cd.DATE AS DATE,
	cd.population AS population,
	cv.new_vaccinations,
	SUM(convert(int,cv.new_vaccinations)) OVER (
		PARTITION BY cd.location ORDER BY cd.date
		) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
INNER JOIN PortfolioProject..CovidVaccination cv
	ON cd.location = cv.location
		AND cd.DATE = cv.DATE
WHERE cd.continent IS NOT NULL
)
select * from POPvsVAC;

--------------------------------------------------------------------------------------------
--TEMP TABLE 
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated (
	Continent NVARCHAR(255),
	Location NVARCHAR(255),
	DATE DATETIME,
	Population NUMERIC,
	New_vaccinations NUMERIC,
	RollingPeopleVaccinated NUMERIC
	);

INSERT INTO #PercentPopulationVaccinated
SELECT 
	cd.continent AS continent,
	cd.location AS location,
	cd.DATE AS DATE,
	cd.population AS population,
	cv.new_vaccinations,
	SUM(convert(INT, cv.new_vaccinations)) OVER 
		(
			PARTITION BY cd.location ORDER BY cd.DATE
		) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
INNER JOIN PortfolioProject..CovidVaccination cv
	ON cd.location = cv.location
		AND cd.DATE = cv.DATE
WHERE cd.continent IS NOT NULL

SELECT *,
	(RollingPeopleVaccinated / Population) * 100 AS PopulationVaccinatedPercent
FROM #PercentPopulationVaccinated
WHERE New_vaccinations IS NOT NULL

--------------------------------------------------------------------------------------------
--Creating View for visualisation in BI tools.
CREATE VIEW PercentPopulationVaccinated
AS
SELECT 
	cd.continent AS continent,
	cd.location AS location,
	cd.DATE AS DATE,
	cd.population AS population,
	cv.new_vaccinations,
	SUM(convert(INT, cv.new_vaccinations)) OVER (
		PARTITION BY cd.location ORDER BY cd.DATE
		) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
INNER JOIN PortfolioProject..CovidVaccination cv
	ON cd.location = cv.location
		AND cd.DATE = cv.DATE
WHERE cd.continent IS NOT NULL
