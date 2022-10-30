select *
from PortfolioProject.dbo.CovidDeaths
Where continent is not null 
order by 3,4;


select *
from PortfolioProject.dbo.CovidVaccinations
order by 3,4

--selection for the data 
create view covid_deaths as 
select location,date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
Where continent is not null 
--order by 1,2;


--total cases vs total death
--create view total_cases as 

select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject.dbo.CovidDeaths
order by 1,2;


----total cases vs population
--seeing what percentage of population got covid all over the world

select location,date, total_cases, population,(total_cases/population)*100 as Percent_Population_Infected
from PortfolioProject.dbo.CovidDeaths
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(cast(total_cases as int)) as Highest_Infection_Count,  Max((total_cases/population))*100 as highest_Percent_Population_Infected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by highest_Percent_Population_Infected desc;


-- Countries with Highest Death Count per Population excuting the countries with no death records

Select Location, MAX(convert(int,(Total_deaths))) as Total_Death_Count
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by Total_Death_Count desc;


-- Showing locations and contintents with the highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by location
order by TotalDeathCount desc;

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;


-- GLOBAL NUMBERS
-- total numbers of cases,death and death percentage
create view globale_numbers as 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
where continent is not null 
--order by 1,2;


--vaccination table
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
create view population_vs_vaccination as 
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location  Order by dea.location, dea.Date) as People_Vaccinated
,(People_Vaccinated/population)*100 as percentage_of_vaccinated
from PortfolioProject..CovidVaccinations as vac
join PortfolioProject..CovidDeaths  as dea
on vac.location= dea.location
and vac.date= dea.date
where dea.continent is not null
--order by 1,2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as People_Vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *,(People_Vaccinated/Population)*100 as percentage_of_vaccinated
From PopvsVac


-- Creating View to store data for later visualizations

Create View visual_popvsvac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as People_Vaccinated
, (people_vaccinated/population)*100 as percentage_of_vaccinated
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;