-- Identify the problem with nulls
SELECT continent, LENGTH(continent)
FROM PortfolioProject.coviddeaths
WHERE continent = '' OR continent IS NULL OR continent LIKE ' %';

-- Desactivate the safe mode to make changes with UPDATE and DELETE
SET SQL_SAFE_UPDATES = 0;

-- Change the missing values into null
UPDATE PortfolioProject.coviddeaths
SET continent = NULL
WHERE continent = '' OR continent LIKE ' %';

-- Reactivate the safe mode
SET SQL_SAFE_UPDATES = 1;

SELECT *
FROM PortfolioProject.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- Looking at Total cases vs Total deaths
-- Likelihood oy dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject.coviddeaths
WHERE location LIKE '%xico%'
AND continent IS NOT NULL OR continent = ''
ORDER BY 1,2 DESC ;

-- Looking at the total cases vs population
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS covid_percentage
FROM PortfolioProject.coviddeaths
WHERE location LIKE '%xico%'
AND continent IS NOT NULL OR continent = ''
ORDER BY 1,2 ;

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highestinfection, MAX(total_cases/population)*100 AS percentpopulationinfected
FROM PortfolioProject.coviddeaths
-- WHERE location LIKE '%xico%'
WHERE continent IS NOT NULL OR continent = ''
GROUP BY location, population
ORDER BY percentpopulationinfected DESC ;

-- Showing countries with highest death count per population
SELECT location, MAX(total_deaths) AS totaldeathcount
FROM PortfolioProject.coviddeaths
-- WHERE location LIKE '%xico%'
WHERE continent IS NOT NULL OR continent = ' '
GROUP BY location
ORDER BY totaldeathcount DESC ;



-- Showing the continents with the highest count per population
-- By continent
SELECT continent, MAX(total_deaths) AS totaldeathcount
FROM PortfolioProject.coviddeaths
-- WHERE location LIKE '%xico%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcount DESC ;

-- Global numbers
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject.coviddeaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2 DESC ;



-- VACCIONATIONS
-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
-- , (rollingpeoplevaccinated/population)*100
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- Use CTE 
WITH popvsvac (continent, location, date, population, new_vaccionations, rollingpeoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rollingpeoplevaccinated/population)*100
FROM popvsvac;

-- Creating view to store data for later visualization
CREATE VIEW percentpopulationvaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;



