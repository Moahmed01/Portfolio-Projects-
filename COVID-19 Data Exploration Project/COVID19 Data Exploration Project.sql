/*

Mohamed Ahmed

COVID-19 Data Exploration

Skills Used: JOINS, CTE, TEMP TABLES, WINDOWS FUNCTIONS, AGGREGATE FUNCTIONS, CONVERTING DATA TYPES

Data: The dataset is from https://ourworldindata.org/covid-deaths. It has data from January 2020 to November 2022. 
I manipulated the data in Excel to contain the columns I wanted to work with.

Task: The goal of this project is to explore 2020-2022 COVID-19 Data by asking and answering data exploration questions. 
I choose to look at insights for the Australia since I am a Australian citizen. I also explored data globally and regionally.

*/

/* DATA EXPLORATION */

-- Covid Deaths Data 

Select *
From [Portfolio Project]..covid_deaths$
Where continent is not null 
order by date,population

-- Covid Vaccinations Data

Select *
From [Portfolio Project]..covid_vaccinations$
Where continent is not null 
order by date,population

/*
										DATA EXPLORATION - COVID DEATHS DATA	
*/

/* How many COVID-19 cases in the US? How many deaths? What is the percentage death rate? */
-- This shows the likelihood of dying in the Australia if you contract COVID-19 in November 2022.


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From [Portfolio Project]..covid_deaths$
Where location like '%australia%' 
order by date

-- As of November 23 2022, there are 10571788 total cases and the death percentage is about 0.151%.
-- This means that 10571788 people have been infected by COVID-19 since Jan 2020 and that there is about a 0.2% chance of dying if you contract COVID-19 while living in the Australia.

-- How does this compare to a year ago, two years ago?

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From [Portfolio Project]..covid_deaths$
Where location like '%australia%' AND date = '2021-11-23 00:00:00.000'
order by date

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From [Portfolio Project]..covid_deaths$
Where location like '%australia%' AND date = '2020-11-23 00:00:00.000'
order by date

-- One year ago, 202115 people were infected with COVID-19 and there was a ~0.97% chance of dying upon contraction.
-- Two years ago, 27843 people were infected with COVID-19 and there was a ~3.25% chance of dying upon contraction.

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

/* Which countries have the highest infections rate? */
-- Showing countries with highest infection rate compared to their population


Select Location, continent, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected 
From [Portfolio Project]..covid_deaths$
Where continent is not null 
Group by Location, continent, population
order by percent_population_infected desc

-- Where does Australia fall? 

Select Location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected 
From [Portfolio Project]..covid_deaths$
Where location = 'Australia'
Group by Location, population

-- The highest infection rate is among European countries. The country with the highest infection rate is Cyprus.
-- The Australia has an infection rate of ~40%, we're 10th.

-------------------------------- LET'S BREAK THINGS DOWN BY CONTINENT ------------------------------------

/* Which continent has the highest death count in 2022, 2021 and 2020? */
--  This shows countries with the highest death count per population

-- 2022

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..covid_deaths$
Where continent is not null -- was reading in continets as countries so had to include this
Group by location
order by TotalDeathCount desc

-- 2021

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..covid_deaths$
Where continent is not null AND (DATEPART(yy, date) = 2021)
Group by location
order by TotalDeathCount desc

-- 2020

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..covid_deaths$
Where continent is not null AND (DATEPART(yy, date) = 2020)
Group by location
order by TotalDeathCount desc

-- The United States, Brazil and India have the highest death counts each year. 
-- The death count in Mexico has improved since 2020, going from 4th place to 5th. Th UK went from 4th to 7th. Russia went from 9th to 4th.

/* How many people in the Australia were hospitalized due to COVID-19? How many in the ICU? */

Select Location, date, total_cases, hosp_patients, (hosp_patients/total_cases)*100 AS hosp_per_case
From [Portfolio Project]..covid_deaths$
Where location like '%Australia%' 
order by date

-- we starts to see hospitalizations due to COVID-19 march 2020 (March 01, 2020)

Select Location, date, total_cases, icu_patients, (icu_patients/total_cases)*100 AS icu_per_case
From [Portfolio Project]..covid_deaths$
Where location like '%Australia%' 
order by date

-- we starts to see ICU admissions around the same time (March 01, 2020)


------------------------------------ CONTINENT NUMBERS -----------------------------

--Which continent has the highiest death count? 

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..covid_deaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- As of right now, North America has the highest death count.

------------------------------------ GLOBAL NUMBERS --------------------------------

/* What is the global death percentage per day? */

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..covid_deaths$
where continent is not null 
group by date
order by total_cases

/* How many cases are there worldwide?
   How many deaths?
   What is the overall global death percentage?
*/

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS global_death_pecentage
From [Portfolio Project]..covid_deaths$
where continent is not null 
group by date
order by 1, 2 

-- Presently, there are 637,876,021 cases and 6,588,157 deaths worldwide due to COVID-19. The global death percentage is 1.03282719260582%.


/* 
								       DATA EXPLORATION - COVID VACCINATIONS DATA
*/

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


---- Using Common Table Expression (CTE) to perform calculation on PARTITION BY in previous query

With population_vaccinated (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..covid_deaths$ dea
Join [Portfolio Project]..Covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 AS percent_vaccinated
From population_vaccinated

-- From this we can see how many people are being vaccinated daily in each country. 
-- new_vaccinations tells us how many people have been vaccinated that day while rolling_ppl_vaccinated provided a rolling count. 
-- percent_vaccinated gives us the daily percentage of peoole vaccinated in each country respective to their population


-- To do futher exploration, lets create a temp table

DROP Table if exists percent_population_vaccinated
Create Table percent_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into percent_population_vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..covid_deaths$ dea
Join [Portfolio Project]..Covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100 AS percentvaccinated
From percent_population_vaccinated

/* What percentage of each country's population is vaccinated as of today (11/23/2022)? */

SELECT Location, Date, Population, new_vaccinations, RollingPeopleVaccinated, (RollingPeopleVaccinated/Population)*100 AS Percent_vaccinated
FROM percent_population_vaccinated
WHERE Date = '2022-11-23 00:00:00.000'
ORDER BY Date

/* What percentage of the world is vaccinated? */

SELECT SUM(New_vaccinations) AS total_vaccinations, (SUM(CAST(New_vaccinations AS BIGINT))/SUM(Population))*100 AS global_vacc_percentage
FROM percent_population_vaccinated
WHERE continent IS NOT NULL

-- 10703463448 people worldwide are vaccinated with at least one vaccine, that's 0.13% of the global population.

/* Which countries have the highest vaccination rate? */


SELECT Location, Continent, Population, MAX(New_vaccinations) as highest_vaccination_count, MAX((New_vaccinations/Population))*100 AS percent_vacc
FROM percent_population_vaccinated
GROUP BY Location, Continent, Population
ORDER BY percent_vacc DESC 

-- Mongolia has the highest vaccination rate

/* Which continents have the highest vaccination count? */

SELECT Continent, MAX(New_vaccinations) as highest_vaccination_count
FROM percent_population_vaccinated
WHERE Continent IS NOT NULL 
GROUP BY Continent
ORDER BY highest_vaccination_count DESC 

-- Asia has the highest vaccination count










-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..Covid_deaths$ dea
Join [Portfolio Project]..Covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 