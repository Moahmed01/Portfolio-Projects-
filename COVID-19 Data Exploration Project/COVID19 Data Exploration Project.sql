/*
Mohammed Ahmed
COVID-19 Data Exploration
Skills Used: JOINS, CTE, TEMP TABLES, WINDOWS FUNCTIONS, AGGREGATE FUNCTIONS, CONVERTING DATA TYPES
Data: The dataset is from https://ourworldindata.org/covid-deaths.  
I manipulated the data in Excel to contain the columns I wanted to work with.
Task: The goal of this project is to explore 2020-2023 COVID-19 Data by asking and answering data exploration questions. 
I choose to look at insights for the Australia since I am a Australian citizen and I currently work in healthcare industry. I also explored data globally and regionally.
*/

/* VIEWING THE DATASETS */

--DATA EXPLORATION - COVID DATA

Select *
From [Portfolio Project]..covid_deaths$
Where continent is not null 
order by date,population


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..covid_deaths$
Where continent is not null 
order by date,population


-- How many COVID-19 cases in the Australia? How many deaths? What is the percentage death rate?
-- This shows likelihood of dying if you contract covid in Australia 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From [Portfolio Project]..covid_deaths$
Where location like '%australia%' 
order by date

-- As of Feb 08 2023, there are 11312904 total cases and the death percentage is about 0.166%.
-- This means that 11312904 people have been infected by COVID-19 since Jan 2020 and that there is about a 0.2% chance of dying if you contract COVID-19 while living in the US.

-- How does this compare to a year ago, two years ago?

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From [Portfolio Project]..covid_deaths$
Where location like '%australia%' AND date = '2022-02-08 00:00:00.000'
order by date

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From [Portfolio Project]..covid_deaths$
Where location like '%australia%' AND date = '2021-02-08 00:00:00.000'
order by date

-- One year ago, 2811390 people were infected with COVID-19 and there was a ~0.15% chance of dying upon contraction.
-- Two years ago, 28860 people were infected with COVID-19 and there was a ~3.1% chance of dying upon contraction.

-- What percentage of the Australia population contracted COVID-19? 
-- This Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..covid_deaths$
Where location like '%australia%'
order by date 

-- 40% of the Australia population contracted COVID-19 as of Novermber 11, 2022

-- Which countries have the highest infections rate?
-- This shows countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..covid_deaths$
Group by Location, Population
order by PercentPopulationInfected desc

-- The highest infection rate is among European countries. The country with the highest infection rate is Cyprus.

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..covid_deaths$
Where continent is not null -- was reading in continets as countries so had to include this
Group by Location
order by TotalDeathCount desc

-- The United States highest death counts per Population. 


-------------------------------- LET'S BREAK THINGS DOWN BY CONTINENT ------------------------------------

--  Which continent has the highest death count? 
--  This shows contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..covid_deaths$
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- North America has the highest death count as of now

------------------------------------ GLOBAL NUMBERS -----------------------------

--What is the global death percentage per day?

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..covid_deaths$
where continent is not null 
group by date 
order by date, total_cases

/* How many cases are there worldwide?
   How many deaths?
   What is the overall global death percentage?
*/

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..covid_deaths$
where continent is not null 
order by 1,2

-- Presently, there are 671,748,742 cases and 6,845,359 deaths worldwide due to COVID-19. The global death percentage is 1.019%.

--DATA EXPLORATION - COVID VACCINATIONS DATA

-- What percentage of people are vaccinated? 
-- Shows percentage of population that has received at least one COVID-19 vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..covid_deaths$ dea
Join [Portfolio Project]..Covid_vaccinations$ vac
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
From [Portfolio Project]..covid_deaths$ dea
Join [Portfolio Project]..Covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- From this we can see how many people are being vaccinated daily in each country. 
-- new_vaccinations tells us how many people have been vaccinated that day while rolling_ppl_vaccinated provided a rolling count. 
-- percent_vaccinated gives us the daily percentage of peoole vaccinated in each country respective to their population


-- To do futher exploration, lets create a temp table

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
From [Portfolio Project]..covid_deaths$ dea
Join [Portfolio Project]..Covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..Covid_deaths$ dea
Join [Portfolio Project]..Covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 