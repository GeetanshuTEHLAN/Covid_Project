/*

Queries used for Tableau visualisation 

*/



-- 1. 

SELECT
    SUM(new_cases) as total_cases,
    SUM(CAST(new_deaths AS INT)) as total_deaths,
    CASE
        WHEN SUM(new_cases) > 0 THEN
            (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100
        ELSE
            0
    END as DeathPercentage
FROM covid_deathsCSV
WHERE continent IS NOT NULL
ORDER BY 1, 2;


-- 2. 


Select continent, SUM(cast(new_deaths as int)) as TotalDeathCount
From covid_deathsCSV
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount
,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deathsCSV
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount
,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deathsCSV
Group by Location, Population, date
order by PercentPopulationInfected desc
