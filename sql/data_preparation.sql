-- COVID-19 Mortality Analysis
-- Data preparation and local authority harmonisation

BEGIN TRANSACTION;

-- Shepway
UPDATE COVID_19_deaths
SET LA_code = 'E07000112',
    LA_name = 'Folkestone and Hythe'
WHERE LA_name = 'Shepway';

-- Somerset West and Taunton
UPDATE COVID_19_deaths
SET LA_code = 'E0000246',
    LA_name = 'Somerset West and Taunton'
WHERE LA_code IN ('E07000190','E07000191');

-- West Suffolk
UPDATE COVID_19_deaths
SET LA_code = 'E07000245',
    LA_name = 'West Suffolk'
WHERE LA_code IN ('E07000201','E07000204');

-- East Suffolk
UPDATE COVID_19_deaths
SET LA_code = 'E07000244',
    LA_name = 'East Suffolk'
WHERE LA_code IN ('E07000205','E07000206');

-- East Staffordshire
UPDATE COVID_19_deaths
SET LA_code = 'E07000193'
WHERE LA_name = 'East Staffordshire';

-- East Riding of Yorkshire
UPDATE COVID_19_deaths
SET LA_code = 'E06000011'
WHERE LA_name = 'East Riding of Yorkshire';

-- East Northamptonshire
UPDATE COVID_19_deaths
SET LA_code = 'E07000152'
WHERE LA_name = 'East Northamptonshire';

-- Dorset
UPDATE COVID_19_deaths
SET LA_code = 'E06000059',
    LA_name = 'Dorset'
WHERE LA_code IN ('E07000049','E07000050','E07000051','E07000052','E07000053');

-- Bournemouth, Christchurch and Poole
UPDATE COVID_19_deaths
SET LA_code = 'E06000058',
    LA_name = 'Bournemouth, Christchurch and Poole'
WHERE LA_code IN ('E06000028','E07000048','E06000029');

-- Buckinghamshire
UPDATE COVID_19_deaths
SET LA_code = 'E06000060',
    LA_name = 'Buckinghamshire'
WHERE LA_code IN ('E07000004','E07000005','E07000006','E07000007');

-- Northampton
UPDATE COVID_19_deaths
SET LA_code = 'E07000154'
WHERE LA_name = 'Northampton';

-- West Northamptonshire
UPDATE COVID_19_deaths
SET LA_code = 'E06000062',
    LA_name = 'West Northamptonshire'
WHERE LA_code IN ('E07000151','E07000154','E07000155');

-- North Northamptonshire
UPDATE COVID_19_deaths
SET LA_code = 'E06000061',
    LA_name = 'North Northamptonshire'
WHERE LA_code IN ('E07000150','E07000152','E07000153','E07000156');

-- Somerset West and Taunton
UPDATE COVID_19_deaths
SET LA_code = 'E07000246',
    LA_name = 'Somerset West and Taunton'
WHERE LA_code = 'E0000246';

-- Somerset
UPDATE COVID_19_deaths
SET LA_code = 'E06000066',
    LA_name = 'Somerset'
WHERE LA_code IN ('E07000187','E07000188','E07000189','E07000246');

-- North Yorkshire
UPDATE COVID_19_deaths
SET LA_code = 'E06000065',
    LA_name = 'North Yorkshire'
WHERE LA_code IN (
    'E07000163','E07000164','E07000165','E07000166',
    'E07000167','E07000168','E07000169'
);

-- Westmorland and Furness
UPDATE COVID_19_deaths
SET LA_code = 'E06000064',
    LA_name = 'Westmorland and Furness'
WHERE LA_code IN ('E07000027','E07000030','E07000031');

-- Cumbria
UPDATE COVID_19_deaths
SET LA_code = 'E06000063',
    LA_name = 'Cumbria'
WHERE LA_code IN ('E07000026','E07000028','E07000029');

COMMIT;

DROP TABLE IF EXISTS Updated_Dataset;

CREATE TABLE Updated_Dataset AS
SELECT
    d.LA_code,
    MAX(d.LA_name) AS LA_name,
    SUM(d.Total) AS Total
FROM COVID_19_deaths d
INNER JOIN Age a
    ON d.LA_code = a.LA_code
GROUP BY d.LA_code;

SELECT COUNT(*) AS n_rows
FROM Updated_Dataset;
