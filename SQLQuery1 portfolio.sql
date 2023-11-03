--SELECT *
--FROM CovidDeaths$
--ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations$
--ORDER BY 3,4 

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths$
ORDER BY 1,2

SELECT location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeaths$
ORDER BY 1,2

SELECT location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeaths$
WHERE location LIKE '%states%'
ORDER BY 1,2

SELECT location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeaths$
WHERE location = '%states%'
ORDER BY 1,2

SELECT location,date,total_cases,population,(total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths$
WHERE location = '%states%'
ORDER BY 1,2

--looking at countries with highest infection rate compared to population

SELECT location,population,MAX(total_cases)AS HighestInfectionCount, MAX((total_caseS/population))*100 AS PercentPopulationInfected
FROM CovidDeaths$
--WHERE location = '%states%'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

--Showing countries with the highest deathcount per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths$
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT 

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths$
--Where location like '%states%'
Where continent is null 
Group by location 
order by TotalDeathCount desc

--Global numbers

SELECT date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeaths$
--WHERE location = '%states%'
Where continent is not null
order by 1,2 

SELECT date,SUM(new_cases)
FROM CovidDeaths$
--WHERE location = '%states%'
Where continent is not null
GROUP BY date
order by 1,2 

SELECT date,SUM(new_cases),SUM(CAST(new_deaths as int))
FROM CovidDeaths$
--WHERE location = '%states%'
Where continent is not null
GROUP BY date
order by 1,2 

SELECT date,SUM(new_cases) AS total_cases,SUM(CAST(new_deaths as int)) AS total_deaths,SUM(CAST(new_deaths AS int))/SUM (new_cases)*100 AS DeathPercentage
FROM CovidDeaths$
--WHERE location = '%states%'
Where continent is not null
GROUP BY date
order by 1,2

SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths as int)) AS total_deaths,SUM(CAST(new_deaths AS int))/SUM (new_cases)*100 AS DeathPercentage
FROM CovidDeaths$
--WHERE location = '%states%'
Where continent is not null
--GROUP BY date
order by 1,2

SELECT *
FROM CovidVaccinations$

--looking at total population vs vaccination

SELECT *
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location= vac.location
AND dea.date= vac.date

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location= vac.location
AND dea.date= vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From .CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
RowlingPeopleVaccinated numeric 
)


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--create view to store data for later visualisation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null












