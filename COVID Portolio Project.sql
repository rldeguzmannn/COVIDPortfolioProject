SELECT *
FROM CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%philipp%'
ORDER BY 1, 2;

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PopulationCases
FROM CovidDeaths
WHERE location LIKE '%philipp%'
ORDER BY 1, 2;

SELECT location, population, MAX(total_cases) AS HighestCaseCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent is NOT NULL
--WHERE location LIKE '%philipp%''
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

SELECT location, MAX(CAST(total_deaths as int)) AS HighestDeathCount -- per country
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC;

SELECT continent, MAX(CAST(total_deaths as int)) AS HighestDeathCount -- per continent
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1, 2;





SELECT death.continent, death.location, death.date, population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY death.location ORDER BY death.location, death.date)
FROM CovidDeaths death
JOIN CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent is NOT NULL
ORDER BY 2,3;



WITH PopVsVac (Continent, Location, Date, Population, NewVaccinations, RollingVaccinatedCount) AS
(
SELECT death.continent, death.location, death.date, population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingVaccinatedCount
FROM CovidDeaths death
JOIN CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent is NOT NULL
)
SELECT *, (RollingVaccinatedCount/Population)*100 AS RollingVaccinatedPercentage
FROM PopVsVac


CREATE VIEW PhPopulationCases AS
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PopulationCases
FROM CovidDeaths
WHERE location LIKE '%philipp%' AND continent is NOT NULL


CREATE VIEW PercentPopulationVaccinated AS 
SELECT death.continent, death.location, death.date, population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingVaccinatedCount
FROM CovidDeaths death
JOIN CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent is NOT NULL