/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From covid_deathsCSV
Where continent is not null 
order by 3


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From covid_deathsCSV
Where continent is not null 
order by 1


-- Total Cases vs Total Deaths in a country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From covid_deathsCSV
Where location like '%states%'
and continent is not null 
order by 1


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From covid_deathsCSV
order by 1


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deathsCSV
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From covid_deathsCSV
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From covid_deathsCSV
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From covid_deathsCSV
where continent is not null 
Group by date
order by 1, 2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From covid_deathsCSV dea
Join covid_vaccinationsCSV vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS ( 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From covid_deathsCSV dea
Join covid_vaccinationsCSV vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated 
(
    continent TEXT,
    location TEXT,
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.Date) as RollingPeopleVaccinated
FROM covid_deathsCSV dea
JOIN covid_vaccinationsCSV vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM PercentPopulationVaccinated;

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinatedView AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    (
        SELECT SUM(vac2.new_vaccinations)
        FROM covid_vaccinationsCSV vac2
        WHERE dea.location = vac2.location
        AND dea.date >= vac2.date
    ) AS RollingPeopleVaccinated
FROM covid_deathsCSV dea
JOIN covid_vaccinationsCSV vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
