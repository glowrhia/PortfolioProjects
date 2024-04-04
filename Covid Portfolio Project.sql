SELECT *
FROM CovidDeaths
ORDER BY 3,4

SELECT *
FROM CovidVaccinations
ORDER BY 3,4


/* Total Death vs Total Cases
Shows percentage of the total death from the total cases*/
SELECT location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 As DeathPercentage
FROM CovidDeaths

SELECT location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 As DeathPercentage
FROM CovidDeaths
WHERE location = 'NIGERIA' AND total_deaths IS NOT NULL 
ORDER BY 2

SELECT location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 As Percentage
FROM CovidDeaths
WHERE location = 'UNITED KINGDOM' AND total_deaths IS NOT NULL 
ORDER BY 2

/*Total cases vs Population
Shows percentage of people with covid*/
SELECT location, date, total_cases, new_cases, total_cases, population, (total_cases/population)*100 As PercentagePopulationInfection
FROM CovidDeaths
WHERE location = 'NIGERIA'
ORDER BY 2

SELECT location, date, total_cases, new_cases, total_cases, population, (total_cases/population)*100 As PercentagePopulationInfection
FROM CovidDeaths
WHERE location = 'UNITED KINGDOM'
ORDER BY 2

/*Country with the highest infection rate compared to population*/
SELECT location, population, Max(total_cases) AS HighestInfectionCount,  Max((total_cases/population))*100 As PercentagePopulationInfection
FROM CovidDeaths
GROUP BY continent, location, population
ORDER BY 4 DESC

/*Countries with highest death count per population*/
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

/*Continent with highest death count per population*/
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

/*Global number */
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeath, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeath, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


/* Total Population vs Vaccinations
Shows Percentage of Population that has recieved at least one Covid Vaccine*/

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


/*Using CTE to perform Calculation on Partition By in previous query*/

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 AS PercentageVaccinated
From PopvsVac


/* Using Temp Table to perform Calculation on Partition By in previous query*/

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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

/* Creating View to store data for later visualizations*/

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
from PercentPopulationVaccinated
