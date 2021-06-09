SELECT *
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL

SELECT *
FROM PortfolioProject..covidVaccines
WHERE continent IS NOT NULL

-- GLOBAL NUMBERS
-- Total number of cases per continent
SELECT continent, SUM(CAST(total_cases AS DECIMAL)) as TotalCaseCount
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalCaseCount DESC

--Total number of Covid-19 Deaths per continent
SELECT continent, SUM(CAST(total_deaths AS DECIMAL)) AS TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- New_cases, new_deaths and deathPercantage per continent
SELECT continent, SUM(CAST(new_cases AS DECIMAL)) AS Total_cases, SUM(CAST(new_deaths AS DECIMAL)) AS Total_deaths, SUM(CAST(new_deaths AS DECIMAL))/SUM(CAST(new_cases AS DECIMAL))*100 AS DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathPercentage DESC

--Breaking Things down by countries
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL

--Shows likelihood of dying if you contract covid
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS DECIMAL))/(total_cases)*100 AS DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Percentage of population infected with covid
SELECT location, date, population, total_cases, (CAST(total_cases AS DECIMAL))/(population)*100 AS PercentPopulationInfected
FROM PortfolioProject..covidDeaths
ORDER BY 1,2

--Countries with highest Infection Rate compared to Population
SELECT continent, Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(CAST(total_cases AS DECIMAL))/(population)*100 AS PercentPopulationInfected
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location, population
ORDER BY PercentPopulationInfected DESC

--TOP 10 countries with highest infection rate
SELECT TOP(10) continent, Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(CAST(total_cases AS DECIMAL))/(population)*100 AS PercentPopulationInfected
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location, population
ORDER BY PercentPopulationInfected DESC

--TOP 10 Countries with lowest infection rate
SELECT TOP(50) continent, location, population, max(total_cases) AS HighestInfectedCount, MAX(CAST(total_cases AS DECIMAL))/(population)*100 AS PercentPopulationInfected
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location, population
ORDER BY PercentPopulationInfected ASC

--Countries with highest death count
SELECT continent, location, MAX(CAST(total_deaths AS DECIMAL)) AS TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location
ORDER BY TotalDeathCount DESC

--Top 20 Countries with highest death count
SELECT TOP(20) continent, location, MAX(CAST(total_deaths AS DECIMAL)) AS TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location
ORDER BY TotalDeathCount DESC

--Top 50 countries with lowest death count
SELECT TOP(50) continent, location, MAX(CAST(total_deaths AS DECIMAL)) AS TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location
ORDER BY TotalDeathCount ASC

--Total number of patients in hospital
SELECT location, MAX(CAST(hosp_patients AS DECIMAL)) AS PatientsHospital
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY PatientsHospital DESC


--Total number of patients in icu
SELECT location, MAX(CAST(icu_patients AS DECIMAL)) AS TotalNumberOfICUPatients
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalNumberOfICUPatients DESC


-- Looking at total population vs vaccinations

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CONVERT(DECIMAL, vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS ROLLINGOUTVACCINES
FROM PortfolioProject..covidDeaths AS deaths
JOIN PortfolioProject..covidVaccines AS vac
	ON deaths.location = vac.location
	AND deaths.date = vac.date
WHERE deaths.continent IS NOT  NULL
ORDER BY 2,3

-- CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, ROLLINGOUTVACCINES)
as
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CONVERT(DECIMAL, vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS ROLLINGOUTVACCINES
FROM PortfolioProject..covidDeaths AS deaths
JOIN PortfolioProject..covidVaccines AS vac
	ON deaths.location = vac.location
	AND deaths.date = vac.date
WHERE deaths.continent IS NOT  NULL
)
SELECT *,(ROLLINGOUTVACCINES/population)*100
FROM PopvsVac


--Looking at South Africa's stats
SELECT date, new_cases, total_cases 
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL AND location LIKE '%south africa%'

SELECT date, new_deaths, total_deaths
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL AND location LIKE '%south africa%'
