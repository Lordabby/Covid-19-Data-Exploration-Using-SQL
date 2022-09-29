--COVID'19 DATA EXPLORATION
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

SELECT *
FROM projects..covid_death_data
ORDER BY location asc;

--TOTAL CASES Vs TOTAL DEATHS: Shows likelihood of dying if you contract covid in your country
SELECT location,date, total_cases,total_deaths, (CAST(total_deaths AS INT)/total_cases)*100 AS death_percentage
FROM projects..covid_death_data
WHERE continent IS NOT NULL
ORDER BY 1,2 ASC;

--TOTAL CASES Vs POPULATION: Shows what percentage of population infected with Covid

SELECT location,date, total_cases, (total_cases/population)*100 AS percent_population_infected
FROM projects..covid_death_data
WHERE continent IS NOT NULL
ORDER BY 1,2 ASC;

-- Countries with Highest Infection Rate compared to Population

SELECT  location,population, MAX(total_cases) AS highest_infection_Count, (MAX(total_cases)/population) * 100  max_infection_rate
FROM projects..covid_death_data
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY 4 DESC;

--COUNTRIES WITH HIGHEST DEATH RATE

SELECT location,population, MAX(CAST (total_deaths AS INT)) AS highest_death_count, (MAX(CAST(total_deaths AS INT))/population)*100 AS max_death_rate
FROM projects..covid_death_data
WHERE continent  IS NOT NULL
GROUP BY location, population
ORDER BY max_death_rate DESC;

--GLOBAL NUMBERS
SELECT SUM(new_cases) as global_cases, SUM(CAST(new_deaths AS INT)) as global_deaths, ROUND((SUM(CAST(new_deaths AS INT))/SUM(new_cases))* 100,5) AS global_death_rate
FROM projects..covid_death_data
WHERE continent IS NOT NULL;

-- POPULUATION  Vs VACCINATION
SELECT d.continent,d.location,d.date,d.population, v.new_vaccinations, 
SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location,d.date ) AS rolling_no_of_ppl_vaccinated
FROM projects..covid_death_data d
INNER JOIN projects..covid_vac_data v
ON d.location = v.location AND
d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.location,d.date ASC; 


-- CREATING CTE  FOR rolling_no_of_ppl_vaccinated
WITH pop_vs_vac(continent,location,date,population, new_vaccinations,rolling_no_of_ppl_vaccinated) AS
(
SELECT d.continent,d.location,d.date,d.population, v.new_vaccinations, 
SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location,d.date ) AS rolling_no_of_ppl_vaccinated
FROM projects..covid_death_data d
INNER JOIN projects..covid_vac_data v
ON d.location = v.location AND
d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY d.location,d.date ASC; 
)

SELECT *, (rolling_no_of_ppl_vaccinated/population) * 100 AS percent_ppl_vaccinated
FROM pop_vs_vac;

