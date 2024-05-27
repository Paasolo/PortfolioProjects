select * from CovidDeaths order by location,date


--select * from CovidVaccinations order by location,date

SELECT location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths order by 1,2



-----------------------Likelyhood of dying if you contract covid in your country-----------------------
SELECT location,date,total_cases,total_deaths,
ROUND((TRY_CONVERT(float,total_deaths) / TRY_CONVERT(float,total_cases)) * 100,2) AS DEATHPERCENTAGE

from CovidDeaths WHERE location = 'United States' order by 1,2


----------------Total cases vrs population-----------------------

SELECT location,date,total_cases,population,
ROUND((TRY_CONVERT(float,total_cases) / TRY_CONVERT(float,population)) * 100,2) AS DEATHPERCENTAGE

from CovidDeaths WHERE location = 'United States' order by 1,2


----------Countries with Highest infection Rate compared to population--------------------------

SELECT location,population,Max(TRY_CONVERT(float,total_cases)) AS HighestInfectionCount,
MAX(ROUND((TRY_CONVERT(float,total_cases) / TRY_CONVERT(float,population)) * 100,2)) AS Percentagepopulationinfected

from CovidDeaths where continent is not null group by location,population order by Percentagepopulationinfected desc--WHERE location = 'United States' order by 1,2

------countries with highest Death count per population--------------------

SELECT location,Max(TRY_CONVERT(int,total_deaths)) AS HighestDeathCount,
MAX(ROUND((TRY_CONVERT(int,total_deaths) / TRY_CONVERT(float,population)) * 100,5)) AS PercentagepopulationDead

from CovidDeaths where continent is not null group by location order by HighestDeathCount desc--WHERE location = 'United States' order by 1,2


---------Continent breakdown---------------


SELECT continent,Max(TRY_CONVERT(int,total_deaths)) AS HighestDeathCount,
MAX(ROUND((TRY_CONVERT(int,total_deaths) / TRY_CONVERT(float,population)) * 100,5)) AS PercentagepopulationDead

from CovidDeaths where continent is not null group by continent order by HighestDeathCount desc--WHERE location = 'United States' order by 1,2


-----Global Numbers

SELECT date,Sum(ISNULL(new_cases,0))--,total_deaths,
--ROUND((TRY_CONVERT(float,total_deaths) / TRY_CONVERT(float,total_cases)) * 100,2) AS DEATHPERCENTAGE

from CovidDeaths
WHERE continent is not null
Group by date 
order by 1,2

------------------------Looking at Total Popuation vs Vaccinations---------
select D.continent,D.location,D.date,D.population,V.new_vaccinations,
SUM(CAST(v.new_vaccinations AS int )) OVER (PARTITION BY D.Location order BY D.Location,D.Date) AS RollingPeopleVaccinated
from CovidDeaths D
join CovidVaccinations V 
	ON D.date = v.date 
	and D.location = v.location
WHERE D.continent is not Null
ORDER BY 2,3

------USE CTE
;WITH popvsVac as
(
select D.continent,D.location,D.date,D.population,V.new_vaccinations,
SUM(CAST(v.new_vaccinations AS int )) OVER (PARTITION BY D.Location order BY D.Location,D.Date) AS RollingPeopleVaccinated
from CovidDeaths D
join CovidVaccinations V 
	ON D.date = v.date 
	and D.location = v.location
WHERE D.continent is not Null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/CAST(population AS INT)) * 100 from popvsVac

-------TEMP table--
DROP TABLE IF EXISTS #percentPopulationVaccinated;

select D.continent,D.location,D.date,D.population,V.new_vaccinations,
SUM(CAST(v.new_vaccinations AS int )) OVER (PARTITION BY D.Location order BY D.Location,D.Date) AS RollingPeopleVaccinated
INTO #percentPopulationVaccinated
from CovidDeaths D
join CovidVaccinations V 
	ON D.date = v.date 
	and D.location = v.location
WHERE D.continent is not Null

SELECT *, (RollingPeopleVaccinated/CAST(population AS INT)) * 100 from #percentPopulationVaccinated
go
----Creating view for later visualizations
Create view percentPopulationVaccinated as
select D.continent,D.location,D.date,D.population,V.new_vaccinations,
SUM(CAST(v.new_vaccinations AS int )) OVER (PARTITION BY D.Location order BY D.Location,D.Date) AS RollingPeopleVaccinated,
(SUM(CAST(v.new_vaccinations AS int )) OVER (PARTITION BY D.Location order BY D.Location,D.Date)/cast(population as int)) * 100 as percVacinated
from CovidDeaths D
join CovidVaccinations V 
	ON D.date = v.date 
	and D.location = v.location
WHERE D.continent is not Null