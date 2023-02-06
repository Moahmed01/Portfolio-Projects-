/*
Mohammed Ahmed

COVID-19 Data Exploration

Skills Used: JOINS, CTE, TEMP TABLES, WINDOWS FUNCTIONS, AGGREGATE FUNCTIONS, CONVERTING DATA TYPES

Data: The dataset is from https://ourworldindata.org/covid-deaths. It has data from January 2020 to November 2022. 
I manipulated the data in Excel to contain the columns I wanted to work with.

Task: The goal of this project is to explore 2020-2022 COVID-19 Data by asking and answering data exploration questions. 
I choose to look at insights for the Australia since I am a Australian citizen. I also explored data globally and regionally.

*/

/* VIEWING THE DATASETS */

-- Covid Deaths Data

Select *
From [Portfolio Project]..CovidDeaths$
Where continent is not null 
order by date,population


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths$
Where continent is not null 
order by date,population


-- How many COVID-19 cases in the Australia? How many deaths? What is the percentage death rate?
-- This shows likelihood of dying if you contract covid in Australia 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From [Portfolio Project]..CovidDeaths$
Where location like '%australia%'
order by date

-- As of October 20 2022, there are 98,503,462 total cases and the death percentage is about 1.095%.
-- This means that 98,503,462 people have been infected by COVID-19 since Jan 2020 and that there is about a 1.1% chance of dying if you contract COVID-19 while living in the US.

-- How does this compare to a year ago, two years ago?

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From [Portfolio Project]..CovidDeaths$
Where location like '%australia%' AND date = '2021-10-22 00:00:00.000'
order by date

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From [Portfolio Project]..CovidDeaths$
Where location like '%australia%' AND date = '2020-10-22 00:00:00.000'
order by date

-- One year ago, 48,024,223 people were infected with COVID-19 and there was a ~1.6% chance of dying upon contraction.
-- Two years ago, 12,515,951 people were infected with COVID-19 and there was a ~2% chance of dying upon contraction.

-- What percentage of the Australia population contracted COVID-19? */
-- This Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths$
Where location like '%australia%'
order by date 

-- 0.32% of the Australia population contracted COVID-19 as of October 20, 2022

-- Which countries have the highest infections rate?
-- This shows countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths$
where continent is not null 
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
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
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



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
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
