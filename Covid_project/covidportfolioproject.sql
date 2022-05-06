-- Death percentage in Canada
with cte as(
select deaths.location, deaths.date, deaths.total_cases,deaths.total_deaths, 
round((total_deaths/total_cases)*100,2) as Deathpercentage
from cpp.dbo.deaths
where deaths.location = 'Canada'
)
select cte.location, cte.date, cte.total_cases,cte.total_deaths,concat(Deathpercentage,'%') as death_percentage
from cte
order by deathpercentage desc


-- Maximum number of infected in comparison to population
Select location, population, Max(total_cases) as Mostcases, Round(MAX((total_cases/population))*100,2) as Populationinfected
from cpp.dbo.deaths
group by location,population
order by 4 desc;

-- Number of deaths compared to number of people vaccinated
select va.location,va.date,total_deaths,people_fully_vaccinated,Round((people_fully_vaccinated/population)*100,4) as populationvaccinated, Round((cast(total_deaths as float)/population)*100,4) as PopulationsDeathspercentage
from cpp.dbo.deaths de JOIN cpp.dbo.vaccinations va
ON de.location=va.location
AND de.date=va.date
where people_fully_vaccinated is not null
and de.location = 'Poland'
order by 2 asc;


-- Percentage of male smokers compared to death rate by population
select va.location, va.male_smokers,
(Round((MAX(cast(total_deaths as float))/population),6)) as PopulationsDeathspercentage
from cpp.dbo.deaths de JOIN cpp.dbo.vaccinations va
ON de.location=va.location
AND de.date=va.date
WHERE va.continent is not null
and va.male_smokers is not null
group by va.location,va.male_smokers,de.population
order by 3 desc;

-- Looking at gdp's of countries compared to death rate by population
select va.location,round(va.gdp_per_capita,0), (Round((sum(cast(total_deaths as float))/population),6)) as PopulationsDeathspercentage
from cpp.dbo.deaths de JOIN cpp.dbo.vaccinations va
ON de.location=va.location
AND de.date=va.date
where  va.continent is not null
and va.male_smokers is not null
group by va.location,va.gdp_per_capita,de.population
order by 3 desc;

