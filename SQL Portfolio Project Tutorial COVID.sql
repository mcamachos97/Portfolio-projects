Select *
From CovidDeaths
Order by 3,4

--Select *
--From CovidVaccinations
--Order by 3,4

-- Seleccionar los datos que vamos a usar

Select location,date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order by 1,2

-- Compararcion Casos totales vs Muertes totales
-- Porcentaje de muerte en Mexico 

Select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercent
From CovidDeaths
Where location = 'Mexico'
--Where continent is not null
Order by 1,2
Create view TasaDeMuerteEnMexico as 
Select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercent
From CovidDeaths
Where location = 'Mexico'
--Where continent is not null
--Order by 1,2


-- Casos Totales vs Poblacion
-- Porcentaje de la poblacion que se ha infectado

Select location,date, population, total_cases, (total_cases/population)*100 As InfectionPercent
From CovidDeaths
Where location = 'Mexico'
Order by 1,2

-- Comparando que paises tienen el mayor porcentaje de infeccion

Select location, population, MAX(total_cases)As PeakOfInfection, Max((total_cases/population)*100) As InfectionPercent
From CovidDeaths
--Where location = 'Mexico'
Where continent is not null
Group by location, population
Order by InfectionPercent desc

-- Ahora Paises con mayor tasa de muerte

Select location, population, MAX(cast(total_deaths as int))As TotalDeathCount, Max((total_deaths/population)*100) As DeathPercetage
From CovidDeaths
--Where location = 'Mexico'
Group by location, population
Order by DeathPercetage desc

Create view PaisesConMayorTasaDeMuerte as
Select location, population, MAX(cast(total_deaths as int))As TotalDeathCount, Max((total_deaths/population)*100) As DeathPercetage
From CovidDeaths
--Where location = 'Mexico'
Group by location, population
--Order by DeathPercetage desc


--Paises con mayor numero de muertes

Select location, MAX(cast(total_deaths as int))As TotalDeathCount
From CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- Ahora haciendo analisis por Continente

Select location, MAX(cast(total_deaths as int))As TotalDeathCount
From CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc

Create view DeathCountByContinent as
Select location, MAX(cast(total_deaths as int))As TotalDeathCount
From CovidDeaths
Where continent is null
Group by location
--Order by TotalDeathCount desc

-- Analisis de los continentes con mayor tasa de muerte de acuerdo a poblacion

Select continent, MAX(cast(total_deaths as int))As TotalDeathCount
From CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Numeros Globales

Select date, Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 As DeathPercent
From CovidDeaths
--Where location = 'Mexico'
Where continent is not null
Group by date
Order by 1,2

Create view AnalysisByDate as 
Select date, Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 As DeathPercent
From CovidDeaths
--Where location = 'Mexico'
Where continent is not null
Group by date
--Order by 1,2

-- Totales

Select Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 As DeathPercent
From CovidDeaths
--Where location = 'Mexico'
Where continent is not null
Order by 1,2

-- Poblacion total vs vacunacion 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as SumaPersonasVacunadas
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	--Where dea.location = 'Mexico'
	Where dea.continent is not null
	Order by 2,3

-- Usando una Temp Table
Drop table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as SumaPersonasVacunadas
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	--Where dea.location = 'Mexico'
	Where dea.continent is not null
	Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creando una visualizacion para usar despues

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as SumaPersonasVacunadas
--, (SumaPersonasVacunadas/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	--Order by 2,3

Select *
From PercentPopulationVaccinated

