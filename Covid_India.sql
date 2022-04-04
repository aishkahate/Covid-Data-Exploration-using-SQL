
select * from CovidDeaths$

select population from CovidVaccinations$;

--Selecting specific column
select  location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths$;

---Death percentage for India 
select  location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where location like 'India';

--get datatype for the column
select * from INFORMATION_SCHEMA.COLUMNS;

--add column population to CovidDeaths table
--ALTER TABLE CovidDeaths$
--ADD population float;
--ALTER TABLE CovidDeaths$
--DROP COLUMN population;

--Add value
--insert into CovidDeaths$(population)
--select population from CovidVaccinations$



---Covid cases for the total percentage of the population
select  location,date,population,total_cases,(total_cases/population)*100 as DeathPercentage
from CovidDeaths$
where location like 'India';

---Countried with high covid cases
select location,population,max(cast (total_cases as int)) as HighestInfection ,Max(total_cases/population)*100 as PopulationInfected
from CovidDeaths$
group by location,population 
order by PopulationInfected desc;

---Countried with high covid deaths
select location,max(cast(total_deaths as int)) as TotalDeathCount 
from CovidDeaths$
where continent is not NULL
group by location
order by TotalDeathCount desc;

----Death Count by continents
select continent,max(cast(total_deaths as int)) as TotalDeathCount 
from CovidDeaths$
where continent is not NULL
group by continent
order by TotalDeathCount desc;

--global count 
select  sum(cast( new_cases as int)) as TotalCases,sum(cast(new_deaths as int)) as DeathCases,
sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentages
from CovidDeaths$
where continent is not NULL
--group by date;

---vaccinations by locations 
select cd.continent,cd.location,cd.date,cd.population, cv.new_vaccinations,
sum(convert(bigint, cv.new_vaccinations)) over(partition by cd.location order by cd.location, cd.date)as PeopleVaccinated
from CovidDeaths$ cd
join CovidVaccinations$ cv
 on cd.location=cv.location
 and cd.date=cv.date
where cd.continent is not NULL
and cv.new_vaccinations is not null
order by 2,3;


--use CTE
with PopvsVac(Continent, location, date ,population, new_vaccination, PeopleVaccinated)
as (
select cd.continent,cd.location,cd.date,cd.population, cv.new_vaccinations,
sum(convert(bigint, cv.new_vaccinations)) over(partition by cd.location order by cd.location, cd.date)as PeopleVaccinated
from CovidDeaths$ cd
join CovidVaccinations$ cv
 on cd.location=cv.location
 and cd.date=cv.date
where cd.continent is not NULL
and cv.new_vaccinations is not null  

)
select * from PopvsVac


--Temp table 
Drop table if exists #PerPopulationVacc
create Table #PerPopulationVacc
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric)

Insert into #PerPopulationVacc
select cd.continent,cd.location,cd.date,cd.population, cv.new_vaccinations,
sum(convert(bigint, cv.new_vaccinations)) over(partition by cd.location order by cd.location, cd.date)as PeopleVaccinated
from CovidDeaths$ cd
join CovidVaccinations$ cv
 on cd.location=cv.location
 and cd.date=cv.date
where cd.continent is not NULL
and cv.new_vaccinations is not null  


select *  from #PerPopulationVacc



---Create View
create view global as 

select  sum(cast( new_cases as int)) as TotalCases,sum(cast(new_deaths as int)) as DeathCases,
sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentages
from CovidDeaths$
where continent is not NULL

--display view
select * from global