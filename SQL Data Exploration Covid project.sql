-- Data exploration in SQL using Covid-19 Dataset
-- Select data that we are going to be using
-- covid_deaths table

select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
order by 1,2 

-- Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contact covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid_deaths
where location like '%United Kingdom%'
and continent is not null
order by 1,2 

-- Looking at Total Cases vs Population
-- Shows the percentage of the population that got Covid-19 in the United Kingdom
select location, date, total_cases, population, (total_cases/population)*100 as percentage_population_infected
from covid_deaths
where location like '%United Kingdom%'
order by 1,2

-- Looking at Countries with Highest Infection rate compared to Population
-- United Kingdom is 60th on the list out of 219 countries
select location, MAX(total_cases) as highest_infection_count, population, MAX((total_cases/population))*100 as percentage_population_infected
from covid_deaths
-- where location like '%United Kingdom%'
group by location, population
order by percentage_population_infected desc

-- Showing the Countries with the Highest Death Count per Population
-- Europe has the max death count of 1,016,750
select location, MAX(cast(total_deaths as int)) as total_death_count
from covid_deaths
-- where location like '%United Kingdom%'
where continent is null  
group by location
order by total_death_count desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the Continents with the Highest Death Count per population
select continent, MAX(cast(total_deaths as int)) as total_death_count
from covid_deaths
-- where location like '%United Kingdom%'
where continent is not null  
group by continent
order by total_death_count desc


-- GLOBAL NUMBERS
-- Death percentage of over 2% across the world
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from covid_deaths
-- where location like '%United Kingdom%'
where continent is not null
-- group by date
order by 1,2 

-- 
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from covid_deaths
-- where location like '%United Kingdom%'
where continent is not null
group by date
order by 1,2


-- covid_vaccinations table
-- View table
select *
from covid_vaccinations

-- Join the two tables together

select *
from covid_deaths as deaths
join covid_vaccinations as vaccinations
on deaths.location = vaccinations.location
and deaths.date = vaccinations.date

-- Looking at Total Population vs Vaccinations

select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations, SUM(cast(vaccinations.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_people_vaccinated
-- , (rolling_people_vaccinated/population)*100
from covid_deaths as deaths
join covid_vaccinations as vaccinations
on deaths.location = vaccinations.location
and deaths.date = vaccinations.date
where deaths.continent is not null
order by 2,3


-- USE CTE

with popvsvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations, SUM(cast(vaccinations.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_people_vaccinated
-- , (rolling_people_vaccinated/population)*100
from covid_deaths as deaths
join covid_vaccinations as vaccinations
on deaths.location = vaccinations.location
and deaths.date = vaccinations.date
where deaths.continent is not null
-- order by 2,3
	)
	select *, (rolling_people_vaccinated/population)*100
	from popvsvac
	

-- TEMP TABLE

drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
continent character varying (100),
location character varying (100),
date date,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into PercentPopulationVaccinated
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations, SUM(cast(vaccinations.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_people_vaccinated
-- , (rolling_people_vaccinated/population)*100
from covid_deaths as deaths
join covid_vaccinations as vaccinations
on deaths.location = vaccinations.location
and deaths.date = vaccinations.date
where deaths.continent is not null
-- order by 2,3

select *, (rolling_people_vaccinated/population)*100
	from PercentPopulationVaccinated
	

-- Creating views to store data for later visualisations

create view PercentPopulationVaccinated as
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations, SUM(cast(vaccinations.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_people_vaccinated
-- , (rolling_people_vaccinated/population)*100
from covid_deaths as deaths
join covid_vaccinations as vaccinations
on deaths.location = vaccinations.location
and deaths.date = vaccinations.date
where deaths.continent is not null
-- order by 2,3
	
select *
from PercentPopulationVaccinated


create view deathpercentage as
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from covid_deaths
-- where location like '%United Kingdom%'
where continent is not null
group by date
order by 1,2

select *
from deathpercentage


create view casesvsdeath as
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid_deaths
where location like '%United Kingdom%'
and continent is not null
order by 1,2 

select *
from casesvsdeath