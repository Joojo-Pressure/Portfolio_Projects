-- Select Data that to be used
-- Covid Deaths Dataset
select *
From Portfolio_Project..Covid_Deaths$
Order by 1,2

-- Covid Vaccinations Dataset
select *
From Portfolio_Project..Covid_Vaccinations$
Order by 1,2

-- What percentage of a specified country's population got COVID on a daily basis within the period?
select Location, Date, total_cases, population, (total_cases/population)*100 as Covid_Percentage
From Portfolio_Project..Covid_Deaths$
Where location = 'Ghana' and continent is not null
Order by 1,2

-- Inference: Ghana recorded its first 3 cases on 14th March, 2020. 
-- As at 1st March, 2022, it recorded a total of 159,891 cases, representing 0.5% of the population.


-- What is the death Percentage of a specified country's population Per Day
select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From Portfolio_Project..Covid_Deaths$
Where location = 'Ghana' and continent is not null
Order by 1,2

-- Inference: As at 1st March, 2022, 0.9% of Ghanaians died from after contracting COVID. 


-- Which countries have the highest infection rate?
-- Creating a view
Create View Infection_Rate_Per_Country as
select Location, population,  max(total_cases) as Highest_Infec_Count, max((total_cases/population))*100 as Perc_Population_Infected
From Portfolio_Project..Covid_Deaths$
--Where location = 'Ghana'
Where continent is not null
Group by location, population

Select *
From Infection_Rate_Per_Country
Order by Perc_Population_Infected desc

-- Inference: As at 1st March, 2022, as much as 70.09% of the citizens of Faoroe Islands had been infected with COVID.
-- The high infection rate is most likely due to the fact that they have a very small population (49,053). 
-- However, as Guemsey had not recoreded case of COVID as at 1st March, 2022.


-- Which countries have the highest death rate?
-- Creating a view
Create View Death_Rate_Per_Country as
select Location, population,  max(cast(total_deaths as int)) as Highest_Death_Count, max((total_deaths/population))*100 as Perc_Population_Deaths
From Portfolio_Project..Covid_Deaths$
--Where location = 'Ghana'
Where continent is not null
Group by location, population

Select *
From Death_Rate_Per_Country
Order by Perc_Population_Deaths desc

-- Inference: As at 1st March 2022, Peru had the highest death percentage per population at the peak of its COVID infections.


-- Which countries have the most COVID casualties?
-- Creating a view
Create View Death_Count_Per_Country as
select Location, max(cast(total_deaths as int)) as Highest_Death_Count
From Portfolio_Project..Covid_Deaths$
--Where location = 'Ghana'
Where continent is not null
Group by location

Select *
From Death_Count_Per_Country
Order by Highest_Death_Count desc

-- Inference: As at 1st March, 2022, USA is the country with the most COVID causalties. 
-- China is the 85th and Ghana is ranked 119th.


-- Time to Analyze The Data on a Continental Level

-- Which continents have the most COVID casualties?
-- Creating A View
Create View Death_Count_Per_Continent As
select location, max(cast(total_deaths as int)) as Highest_Death_Count
From Portfolio_Project..Covid_Deaths$
Where continent is null
Group by location

Select *
From Death_Count_Per_Continent
Order by Highest_Death_Count desc

-- Inference: Europe has the highest death count, and Oceania has the least.


-- Which continents have the highest Death Count per Population?
-- Creating A View
Create View Death_Count_Per_Population_Per_Continent As
Select location, population, max(cast(total_deaths as int)) as Highest_Death_Count, max((cast(total_deaths as int))/population )*100 as Perc_Population_Deaths
From Portfolio_Project..Covid_Deaths$
Where continent is null
Group by location, population

Select *
From Death_Count_Per_Population_Per_Continent
Order by Perc_Population_Deaths desc

-- Inference: Although Europe has the highest death count per continent, South America has the highest percentage of population deaths.
-- You are more likely to die of COVID in South America than on any other continent.


-- Let's analyze the data on a daily basis

-- Metrices per date on a global scale Per Day
select Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From Portfolio_Project..Covid_Deaths$
Where continent is not null
Order by 1,2

-- Inference: The world recorded the first COVID case and COVID death on 22nd Jan, 2020.


-- Highest Death Percentage Per day
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_Percentage
From Portfolio_Project..Covid_Deaths$
Where continent is not null
Group by Date
Order by 4 desc

-- Inference: On 24 Feb, 2020, the world recorded the highest death percentage of 28.169%. This was due to the fact that few cases had been recorded at that time.
-- On 9th Jan, 2022, the world recorded the least death percentage of 0.19%


-- What is the total death percentage globally
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_Percentage
From Portfolio_Project..Covid_Deaths$
Where continent is not null
Order by 1,2

-- Inference: As at 1st March, 2022, the world had recorded a total of 437,358,320 COVID cases and 5,938,831 deaths, representing 1.36%.
-- If you get infected with COVID on planet earth, you have a 1.36% chance of dying. 


-- Joining COVID Deaths and COVID Vaccination Tables, using Location
select * 
from Portfolio_Project..Covid_Deaths$ as dea
join Portfolio_Project..Covid_Vaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date

-- What is the daily number of vaccinations per day for each counrty?
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_New_Vaccinations -- Rolling Count
from Portfolio_Project..Covid_Deaths$ as dea
join Portfolio_Project..Covid_Vaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location = 'Ghana'
order by 2,3

-- Inference: Ghana recorded its first vacciantion on 8th April, 2021 and had issued 180,950 vaccinations as at 1st March, 2022.


-- What is the daily total number of newly vaccinated people per population in every country?

-- Using a CTE

With Pop_Vs_Vac (continent, location, date, population, new_vaccinations, Rolling_New_Vaccinations) as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_New_Vaccinations -- Rolling Count
from Portfolio_Project..Covid_Deaths$ as dea
join Portfolio_Project..Covid_Vaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location = 'Ghana'
)
select *, (Rolling_New_Vaccinations/population) as Roll_New_Vac_Per_Population
from Pop_Vs_Vac

--Using a TEMPT TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_New_Vaccinations numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_New_Vaccinations -- Rolling Count
from Portfolio_Project..Covid_Deaths$ as dea
join Portfolio_Project..Covid_Vaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (Rolling_New_Vaccinations/population) as Roll_New_Vac_Per_Population
from #PercentPopulationVaccinated
where location = 'Ghana'

-- Inference: On the first day of the vaccination rollout, Ghana vaccinated 0.0015% of its population. The figure stands at 0.0057% as at 1st March, 2022.


--Views For Later Visualizations In Tableau

-- Country with highest infection rate per Country
Select *
From Infection_Rate_Per_Country
Order by Perc_Population_Infected desc

-- Countries With The Highest Death rate per Population
Select *
From Death_Rate_Per_Country
Order by Perc_Population_Deaths desc

-- Countries With The Highest Death Count
Select *
From Death_Count_Per_Country
Order by Highest_Death_Count desc

-- Continents With The Highest Death Count
Select *
From Death_Count_Per_Continent
Order by Highest_Death_Count desc

-- Continents With The Highest Death Count per Population
Select *
From Death_Count_Per_Population_Per_Continent
Order by Highest_Death_Count desc
