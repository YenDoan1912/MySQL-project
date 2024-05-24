1. Basic descriptive statistics 
SELECT 
    Country,
    AVG(Lifeexpectancy) AS avg_lifeexpectancy,
    MIN(Lifeexpectancy) AS min_lifeexpectancy,
    MAX(Lifeexpectancy) AS max_lifeexpectancy,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Lifeexpectancy) AS median_lifeexpectancy
FROM 
    worldlifexpectancy
GROUP BY 
    Country;
2. Trend Analysis 
SELECT 
    Year,
    AVG(Lifeexpectancy) AS avg_lifeexpectancy
FROM 
    worldlifexpectancy
WHERE 
    Country = 'Afghanistan'
GROUP BY 
    Year
ORDER BY 
    Year;
3. Comparative Analysis: 
SELECT 
    Status,
    AVG(Lifeexpectancy) AS avg_lifeexpectancy
FROM 
    worldlifexpectancy
WHERE 
    Year = (SELECT MAX(Year) FROM health_data)
GROUP BY 
    Status;
4. Mortality Analysis: 
WITH stats AS (
    SELECT 
        Country,
        AVG(AdultMortality) AS avg_adult_mortality,
        STDDEV_POP(AdultMortality) AS std_dev_adult_mortality,
        AVG(CAST(Lifeexpectancy AS DECIMAL(10,2))) AS avg_life_expectancy,
        STDDEV_POP(CAST(Lifeexpectancy AS DECIMAL(10,2))) AS std_dev_life_expectancy
    FROM 
        worldlifexpectancy
    GROUP BY 
        Country
)
SELECT 
    s1.Country,
    (SUM((w.AdultMortality - s1.avg_adult_mortality) * (CAST(w.Lifeexpectancy AS DECIMAL(10,2)) - s1.avg_life_expectancy)) / (COUNT(*) * s1.std_dev_adult_mortality * s1.std_dev_life_expectancy)) AS correlation
FROM 
    worldlifexpectancy w
JOIN 
    stats s1 ON w.Country = s1.Country
GROUP BY 
    s1.Country;
5. Impact of GDP: 
SELECT 
    CASE 
        WHEN GDP < 1000 THEN 'Low'
        WHEN GDP BETWEEN 1000 AND 9999 THEN 'Medium'
        ELSE 'High'
    END AS GDP_Range,
    AVG(Lifeexpectancy) AS avg_lifeexpectancy
FROM 
    worldlifexpectancy
GROUP BY 
    GDP_Range;
6. Disease Impact: 
WITH disease_stats AS (
    SELECT 
        Country,
        AVG(Lifeexpectancy) AS avg_lifeexpectancy,
        AVG(Measles) AS avg_measles,
        AVG(Polio) AS avg_polio
    FROM 
        worldlifexpectancy
    GROUP BY 
        Country
),
measles_median AS (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_measles) AS median_measles FROM disease_stats
),
polio_median AS (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_polio) AS median_polio FROM disease_stats
)
SELECT 
    ds.Country,
    ds.avg_lifeexpectancy,
    CASE 
        WHEN ds.avg_measles > mm.median_measles THEN 'High'
        ELSE 'Low'
    END AS measles_incidence,
    CASE 
        WHEN ds.avg_polio > pm.median_polio THEN 'High'
        ELSE 'Low'
    END AS polio_incidence
FROM 
    disease_stats ds, measles_median mm, polio_median pm;
7. Schooling and Health: 
WITH schooling_stats AS (
    SELECT 
        Country,
        AVG(Schooling) AS avg_schooling,
        AVG(Lifeexpectancy) AS avg_lifeexpectancy
    FROM 
        worldlifexpectancy
    GROUP BY 
        Country
)
SELECT 
    Country,
    avg_schooling,
    avg_lifeexpectancy
FROM 
    schooling_stats
ORDER BY 
    avg_schooling DESC
LIMIT 1;

SELECT 
    Country,
    avg_schooling,
    avg_lifeexpectancy
FROM 
    schooling_stats
ORDER BY 
    avg_schooling ASC
LIMIT 1;
8. BMI Trends: 
SELECT 
    Year,
    AVG(BMI) AS avg_BMI
FROM 
    worldlifexpectancy
WHERE 
    Country = 'Country_Name'
GROUP BY 
    Year
ORDER BY 
    Year;
9. Infant Mortality: 
WITH life_expectancy_stats AS (
    SELECT 
        Country,
        AVG(Lifeexpectancy) AS avg_lifeexpectancy
    FROM 
        worldlifexpectancy
    GROUP BY 
        Country
),
highest_lowest AS (
    SELECT 
        Country,
        avg_lifeexpectancy
    FROM 
        life_expectancy_stats
    ORDER BY 
        avg_lifeexpectancy DESC
    LIMIT 1
    UNION ALL
    SELECT 
        Country,
        avg_lifeexpectancy
    FROM 
        life_expectancy_stats
    ORDER BY 
        avg_lifeexpectancy ASC
    LIMIT 1
)
SELECT 
    hl.Country,
    AVG(hd.infantdeaths) AS avg_infantdeaths,
    AVG(hd.under_five_deaths) AS avg_under_five_deaths
FROM 
    worldlifexpectancy hd
JOIN 
    highest_lowest hl ON hd.Country = hl.Country
GROUP BY 
    hl.Country;
10. Rolling Average of Adult Mortality: 
SELECT 
    Country,
    Year,
    AVG(AdultMortality) OVER (PARTITION BY Country ORDER BY Year ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS rolling_avg_adultmortality
FROM 
    worldlifexpectancy
ORDER BY 
    Country, Year;
11. Impact of Healthcare Expenditure:
WITH Stats AS (
    SELECT 
        AVG(percentageexpenditure) AS avg_percentage_expenditure,
        STDDEV(percentageexpenditure) AS stddev_percentage_expenditure,
        AVG(CAST(Lifeexpectancy AS DECIMAL(10,2))) AS avg_life_expectancy,
        STDDEV(CAST(Lifeexpectancy AS DECIMAL(10,2))) AS stddev_life_expectancy
    FROM 
        worldlifexpectancy
),
CorrelationData AS (
    SELECT 
        (SUM((CAST(percentageexpenditure AS DECIMAL(10,2)) - s.avg_percentage_expenditure) * (CAST(Lifeexpectancy AS DECIMAL(10,2)) - s.avg_life_expectancy)) / (COUNT(*) * s.stddev_percentage_expenditure * s.stddev_life_expectancy)) AS correlation
    FROM 
        worldlifexpectancy wle
    CROSS JOIN 
        Stats s
)
SELECT 
    correlation
FROM 
    CorrelationData;
12. BMI and Health Indicators: 
WITH Stats AS (
    SELECT 
        AVG(BMI) AS avg_bmi,
        STDDEV(BMI) AS stddev_bmi,
        AVG(CAST(Lifeexpectancy AS DECIMAL(10,2))) AS avg_life_expectancy,
        STDDEV(CAST(Lifeexpectancy AS DECIMAL(10,2))) AS stddev_life_expectancy,
        AVG(AdultMortality) AS avg_adult_mortality,
        STDDEV(AdultMortality) AS stddev_adult_mortality
    FROM 
        worldlifexpectancy
),
CorrelationData AS (
    SELECT 
        (SUM((CAST(BMI AS DECIMAL(10,2)) - s.avg_bmi) * (CAST(Lifeexpectancy AS DECIMAL(10,2)) - s.avg_life_expectancy)) / (COUNT(*) * s.stddev_bmi * s.stddev_life_expectancy)) AS correlation_life_expectancy,
        (SUM((CAST(BMI AS DECIMAL(10,2)) - s.avg_bmi) * (AdultMortality - s.avg_adult_mortality)) / (COUNT(*) * s.stddev_bmi * s.stddev_adult_mortality)) AS correlation_adult_mortality
    FROM 
        worldlifexpectancy wle
    CROSS JOIN 
        Stats s
)
SELECT 
    correlation_life_expectancy,
    correlation_adult_mortality
FROM 
    CorrelationData;
13. GDP and Health Outcomes:
WITH gdp_groups AS (
    SELECT 
        Country,
        CASE 
            WHEN GDP < 1000 THEN 'Low'
            WHEN GDP BETWEEN 1000 AND 9999 THEN 'Medium'
            ELSE 'High'
        END AS GDP_Range,
        AVG(Lifeexpectancy) AS avg_lifeexpectancy,
        AVG(AdultMortality) AS avg_adultmortality,
        AVG(infantdeaths) AS avg_infantdeaths
    FROM 
        worldlifexpectancy
    GROUP BY 
        Country, GDP_Range
)
SELECT 
    GDP_Range,
    AVG(avg_lifeexpectancy) AS avg_lifeexpectancy,
    AVG(avg_adultmortality) AS avg_adultmortality,
    AVG(avg_infantdeaths) AS avg_infantdeaths
FROM 
    gdp_groups
GROUP BY 
    GDP_Range;
14. Subgroup Analysis of Life Expectancy: 
SELECT 
    Country,
    AVG(Lifeexpectancy) AS avg_lifeexpectancy
FROM 
    worldlifexpectancy
GROUP BY 
    Country;
