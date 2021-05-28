SELECT *
FROM PortfolioProjects..CovidDeaths
ORDER BY location, date

--Selecting Fields I will use
--Filtering out Null Continents
SELECT 
  location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population
FROM PortfolioProjects..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1,2

--For Location India
--Total Cases VS Total Deaths
--Calculation of Death Percentage
SELECT 
  location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population,
  (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE 
  location = 'India' AND Continent IS NOT NULL
ORDER BY 1,2

--What Percentage of Population got Covid Infected in India?
SELECT 
  location,
  date,
  population,
  total_cases,
  (total_cases/population) * 100 AS PercentagePopulationInfacted
FROM PortfolioProjects..CovidDeaths
WHERE location = 'India' AND Continent IS NOT NULL
ORDER BY 1,2

--Countries with Highest Infection Rate in proportion to the population
SELECT 
  location,
  population,
  MAX(total_cases) AS HighestInfectionCount,
  MAX(total_cases/population)*100 AS PercentagePopulationInfacted
FROM PortfolioProjects..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY 
  location,
  population
ORDER BY PercentagePopulationInfacted DESC

--Countries with Highest Death Count per Population
SELECT 
  location,
  MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY 
  location
ORDER BY 
  TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT 
  SUM(new_cases) AS Total_New_cases,
  SUM(CAST(new_deaths AS int)) AS Total_New_Deaths,
  (SUM(CAST(new_deaths AS int))/SUM(new_cases)) * 100 AS Death_Percentage
FROM PortfolioProjects..CovidDeaths
WHERE 
  Continent IS NOT NULL
ORDER BY 1,2

--BREAKING THINGS BY CONTINENT
SELECT 
  Continent,
  MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE 
  Continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--TOTAL POPULATION VS VACCINATION
--Rolling Count Calculation

WITH PopulationVSVaccination(
  continent, 
  location, 
  date, 
  population, 
  new_vaccinations, 
  RollingPeopleVaccinated)
AS (
SELECT 
  Death.continent,
  Death.location,
  Death.date,
  Death.population,
  Vaccine.new_vaccinations,
  SUM(CONVERT(int,Vaccine.new_vaccinations)) 
    OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths Death
JOIN PortfolioProjects..CovidVaccinations Vaccine
  ON Death.location = Vaccine.location AND Death.date = Vaccine.date
WHERE Death.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercRollingPeopleVaccinated
FROM PopulationVSVaccination
  

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
  (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date DATETIME,
  Population Numeric,
  New_Vaccinations Numeric,
  RollingPeopleVaccinated Numeric
  )
INSERT INTO #PercentPopulationVaccinated
SELECT 
  Death.continent,
  Death.location,
  Death.date,
  Death.population,
  Vaccine.new_vaccinations,
  SUM(CONVERT(int,Vaccine.new_vaccinations)) 
    OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths Death
JOIN PortfolioProjects..CovidVaccinations Vaccine
  ON Death.location = Vaccine.location AND Death.date = Vaccine.date
WHERE Death.continent IS NOT NULL
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later
CREATE VIEW PercentagePeopleVaccinated AS
SELECT 
  Death.continent,
  Death.location,
  Death.date,
  Death.population,
  Vaccine.new_vaccinations,
  SUM(CONVERT(int,Vaccine.new_vaccinations)) 
    OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths Death
JOIN PortfolioProjects..CovidVaccinations Vaccine
  ON Death.location = Vaccine.location AND Death.date = Vaccine.date
WHERE Death.continent IS NOT NULL

SELECT *
FROM PercentagePeopleVaccinated