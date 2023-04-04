/* Exploring the Covid-19 Dataset

Skills utilized: Aggregate Functions(MAX, SUM, AVG...), Creating Views, Temp Tables, Joins, CTE's, DataType Conversions 
*/

--Exploration begins

SELECT *
FROM Portfolio_Projects..Covid_Deaths
WHERE continent is NOT NULL
ORDER BY 3,4

SELECT *
FROM Portfolio_Projects..Covid_vaccines
ORDER BY 3,4


--Exploring deaths, new and total cases and specifics globally

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Projects..Covid_Deaths
ORDER BY 1,2

--Changing datatypes in a different way

ALTER TABLE Portfolio_Projects..Covid_Deaths
ALTER COLUMN total_deaths float

ALTER TABLE Portfolio_Projects..Covid_Deaths
ALTER COLUMN total_cases float


--Exploring the Death percentage over the infected population globally 

SELECT Location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio_Projects..Covid_Deaths
ORDER BY 1,2


--Exploring the Infection percentage over the total population in USA

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS CovidPercentage
FROM Portfolio_Projects..Covid_Deaths
WHERE location like '%states%'
ORDER BY 1,2


--Exploring the Death Percentage over the infected population in USA

SELECT Location, date, population, total_cases, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio_Projects..Covid_Deaths
WHERE location like '%states%'
ORDER BY 1,2

--Exploring Countries with the most INFECTION rates

SELECT Location, population, MAX(total_cases) as HighestInfectionCt, max((total_cases/population))*100 AS InfectedPercentage
FROM Portfolio_Projects..Covid_Deaths
GROUP BY location, population
ORDER BY InfectedPercentage DESC


--Exploring Countries with the most DEATH counts :(
--United States, Brazil and India were hit the hardest

SELECT Location, population, MAX(total_deaths) as TotalDeathsCt, max((total_deaths/population))*100 AS TotaldeathPercentage
FROM Portfolio_Projects..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Totaldeathsct DESC


--Exploring Continents with the most DEATH counts :/

SELECT Location, MAX(total_deaths) as TotalDeathsCt
FROM Portfolio_Projects..Covid_Deaths
WHERE continent IS NULL AND location NOT LIKE '%income'
GROUP BY location
ORDER BY Totaldeathsct DESC


--Global Death Count till 03.29.2023 (Cross-checked with WHO Covid-19 Dashboard)

SELECT SUM(new_cases) AS global_cases, SUM(CAST(new_deaths AS INT)) AS global_deaths
	--,SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM Portfolio_Projects..Covid_Deaths
WHERE continent IS NOT NULL


--Looking at Cumulative Vaccines Count across different countries around the world

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
	,SUM(CONVERT(BIGINT,CV.new_vaccinations)) OVER (Partition by CD.Location ORDER BY CD.location, CD.date) AS RollingVaccines
FROM Portfolio_Projects..Covid_Deaths AS CD
JOIN Portfolio_Projects..Covid_vaccines AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT  NULL
ORDER BY 2,3



--Utilizing CTE for further analysis and exploring cumulative percentage of vaccine

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccines)
AS
(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
 ,SUM(CONVERT(BIGINT,CV.new_vaccinations)) 
 OVER (Partition by CD.Location ORDER BY CD.location, CD.date) AS RollingVaccines
FROM Portfolio_Projects..Covid_Deaths AS CD
JOIN Portfolio_Projects..Covid_vaccines AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent is not null 
)
SELECT *, (RollingVaccines/Population)*100 AS VaccinatioPercentage
FROM PopvsVac


-- Creating a TEMP Table for further calculations

DROP TABLE IF EXISTS pop_vaccinated
CREATE TABLE pop_vaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingVaccines numeric
)

INSERT INTO pop_vaccinated
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
 ,SUM(CONVERT(BIGINT,CV.new_vaccinations)) 
 OVER (Partition by CD.Location ORDER BY CD.location, CD.date) AS RollingVaccines
FROM Portfolio_Projects..Covid_Deaths AS CD
JOIN Portfolio_Projects..Covid_vaccines AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent is not null


--Creating views for data visualization in Tableau

CREATE VIEW rolling_pop_vaccinated AS
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
 ,SUM(CONVERT(BIGINT,CV.new_vaccinations)) 
 OVER (Partition by CD.Location ORDER BY CD.location, CD.date) AS RollingVaccines
FROM Portfolio_Projects..Covid_Deaths AS CD
JOIN Portfolio_Projects..Covid_vaccines AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent is not null


--Looking at the View created from the last query

SELECT *
FROM rolling_pop_vaccinated

