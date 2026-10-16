CREATE DATABASE ENERGYDB2;
USE ENERGYDB2;


-- 1. country table
CREATE TABLE  country (
    CID VARCHAR(10) PRIMARY KEY,
    Country VARCHAR(100) UNIQUE
);

SELECT * FROM COUNTRY;

-- 2. emission_3 table
CREATE TABLE  emission_3 (
    country VARCHAR(100),
    energy_type VARCHAR(50),
    year INT,
    emission INT,
    per_capita_emission DOUBLE,
    FOREIGN KEY (country) REFERENCES country(Country)
    on update cascade on delete cascade
);
desc emission_3;
drop table emission_3;
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE  'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\emission_3.csv'
INTO TABLE  emission_3
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(country, energy_type, year, emission, per_capita_emission);

SELECT * FROM EMISSION_3;


-- 3. population table
CREATE TABLE  population (
    countries VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (countries) REFERENCES country(Country)
);

SELECT * FROM POPULATION;

-- 4. production table
CREATE TABLE  production (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    production INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);


SELECT * FROM PRODUCTION;

-- 5. gdp_3 table
CREATE TABLE gdp_3 (
    Country VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (Country) REFERENCES country(Country)
);

SELECT * FROM GDP_3;

-- 6. consumption table
CREATE TABLE  consumption (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    consumption INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);
describe  PRODUCTION; 

-- 1.What is the total emission per country for the most recent year available?
select*from emission;
SELECT
    country,
    year,
    SUM(emission) AS total_emission
FROM emission
GROUP BY country, year
having SUM(emission) =(select max(year) a from emission
ORDER BY a DESC);
-- 2.What are the top 5 countries by GDP in the most recent year?
SELECT
    Country,
    year,
    Value AS GDP
FROM gdp
WHERE year = (
    SELECT MAX(year)
    FROM gdp
)
ORDER BY Value DESC
LIMIT 5;

-- 3.Compare energy production and consumption by country and year
SELECT
    p.country,
    p.year,
    p.energy,
    p.production,
    c.consumption,
    p.production - c.consumption AS production_consumption_difference
FROM production_3 p
JOIN consum_3 c
    ON p.country = c.country
   AND p.energy = c.energy
   AND p.year = c.year
ORDER BY p.country, p.year, p.energy;

-- 4.Which energy types contribute most to emissions across all countries?
SELECT
    energy_type,
    SUM(emission) AS total_emission
FROM emission_3
GROUP BY energy_type
ORDER BY total_emission DESC;

describe emission_3 ;
-- 5.How have global emissions changed year over year?
SELECT
    year,
    SUM(emission) AS global_emission,
    SUM(emission) -
        LAG(SUM(emission)) OVER (ORDER BY year)
        AS yearly_change
FROM emission_3
GROUP BY year
ORDER BY year;
-- 6.What is the trend in GDP for each country over the given years?
SELECT
    Country,
    year,
    Value AS GDP,
    LAG(Value) OVER (
        PARTITION BY Country
        ORDER BY year
    ) AS previous_year_GDP
FROM gdp_3
ORDER BY Country, year;

-- 7.How has population growth affected total emissions in each country?
DESCRIBE population_3;

-- 8.Has energy consumption increased or decreased over the years for major economies?
DESCRIBE consum_3;

-- 9.What is the average yearly change in emissions per capita for each country?
WITH yearly_change AS (
    SELECT
        country,
        year,
        per_capita_emission,
        per_capita_emission
        - LAG(per_capita_emission) OVER (
            PARTITION BY country
            ORDER BY year
        ) AS yearly_change
    FROM emission_3
)
SELECT
    country,
    AVG(yearly_change) AS average_yearly_change
FROM yearly_change
GROUP BY country
ORDER BY average_yearly_change;

-- 10.What is the emission-to-GDP ratio for each country by year?
SELECT
    e.country,
    e.year,
    SUM(e.emission) AS total_emission,
    g.Value AS GDP,
    SUM(e.emission) / NULLIF(g.Value, 0) AS emission_to_gdp_ratio
FROM emission_3 e
JOIN gdp_3 g
    ON e.country = g.Country
   AND e.year = g.year
GROUP BY
    e.country,
    e.year,
    g.Value
ORDER BY
    e.country,
    e.year;
    
-- 11. What is the energy consumption per capita for each country over the last decade? 
  DESCRIBE consum_3;
  DESCRIBE population_3;
  
  -- 12.How does energy production per capita vary across countries?
  DESCRIBE population_3;
  
  -- 13.Which countries have the highest energy consumption relative to GDP?
  DESCRIBE consum_3;
  
  -- 14.What is the correlation between GDP growth and energy production growth?
  WITH production_yearly AS (
    SELECT
        country,
        year,
        SUM(production) AS total_production
    FROM production_3
    GROUP BY country, year
),
yearly_data AS (
    SELECT
        g.Country,
        g.year,
        g.Value AS GDP,
        p.total_production
    FROM gdp_3 g
    JOIN production_yearly p
        ON g.Country = p.country
       AND g.year = p.year
),
growth_data AS (
    SELECT
        Country,
        year,
        GDP - LAG(GDP) OVER (
            PARTITION BY Country
            ORDER BY year
        ) AS GDP_growth,
        total_production - LAG(total_production) OVER (
            PARTITION BY Country
            ORDER BY year
        ) AS production_growth
    FROM yearly_data
)
SELECT
    CORR(GDP_growth, production_growth) AS correlation
FROM growth_data
WHERE GDP_growth IS NOT NULL
  AND production_growth IS NOT NULL;
  
-- 15.What are the top 10 countries by population and how do their emissions compare?
DESCRIBE population_3;

-- 16.Which countries have improved (reduced) their per-capita emissions the most over the last decade?
SELECT 
    country,
    MIN(year) AS start_year,
    MAX(year) AS end_year,
    MIN(CASE
        WHEN
            year = (SELECT 
                    MIN(year)
                FROM
                    emission_3)
        THEN
            per_capita_emission
    END) AS start_emission,
    MAX(CASE
        WHEN
            year = (SELECT 
                    MAX(year)
                FROM
                    emission_3)
        THEN
            per_capita_emission
    END) AS end_emission
FROM
    emission_3
GROUP BY country
ORDER BY country;

-- 17.What is the global share (%) of emissions by country?
WITH country_emissions AS (
    SELECT
        country,
        SUM(emission) AS total_emission
    FROM emission_3
    GROUP BY country
)
SELECT
    country,
    total_emission,
    ROUND(
        total_emission / SUM(total_emission) OVER () * 100,
        2
    ) AS global_share_percent
FROM country_emissions
ORDER BY global_share_percent DESC;

-- 18.What is the global average GDP, emission, and population by year?
DESCRIBE population_3;

SELECT
    energy_type,
    AVG(emission) AS avg_emission
FROM emission_3
GROUP BY energy_type;

SELECT
    year,
    SUM(emission) AS total_emission
FROM emission_3
GROUP BY year
ORDER BY year;

describe emission_3;
