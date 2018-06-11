-- Company list
SELECT company_name
FROM Company;

-- Owners list
SELECT *
FROM Owners;

-- Capital assets
SELECT *
FROM Capital_assets;

--Owners name
SELECT company_name AS owners_name
FROM
  ((SELECT company_inn
    FROM Owners
    WHERE owners.type = 1) AS own
    NATURAL JOIN Company)
UNION ALL
SELECT full_name AS owners_name
FROM
  ((SELECT person_INN
    FROM Owners
    WHERE owners.type = 0) AS own
    NATURAL JOIN Persons);

-- Company daughters
SELECT company_name
FROM ((SELECT company_inn
       FROM ((SELECT owner_id
              FROM Owners
              WHERE company_inn = 7708004767)) AS t NATURAL JOIN Company_owners) AS c NATURAL JOIN Company);

-- clear time
DELETE FROM Capital_Assets
WHERE (Capital_Assets.expiration_date IS NOT NULL AND Capital_Assets.expiration_date < NOW())

SELECT
  company_inn,
  companyOwnerPercentage(1, company_inn) AS percentage,
  companyCapitalization(company_inn)     AS capitalization
FROM Company_owners
WHERE company_owners.owner_id = 1;

SELECT companycapitalization(8324324344);

SELECT *
FROM CompanyCost;

SELECT *
FROM CompanyStockCost;

SELECT paydebts(1);

SELECT *
FROM Deffered_payments;

SELECT takecredit(1000000 :: BIGINT, 10, 7708004767);

SELECT * FROM ((SELECT owner_id, company_inn as trg_company_inn, buy_date
FROM company_owners
WHERE 3015080621 = company_owners.company_inn) as b NATURAL JOIN Owners);