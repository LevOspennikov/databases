CREATE VIEW CompanyCost AS (SELECT
                              company_inn,
                              company_name,
                              companycapitalization(company_inn) AS capitalization
                            FROM Company
                            ORDER BY capitalization);

CREATE VIEW CompanyStockCost AS (SELECT
                                   company_inn,
                                   company_name,
                                   (companycapitalization(company_inn) / sum :: FLOAT) AS stockPrice
                                 FROM (SELECT *
                                       FROM Company
                                         NATURAL JOIN (SELECT
                                                         company_inn,
                                                         SUM(count)
                                                       FROM Company_owners
                                                       GROUP BY company_inn) AS c) AS comp
                                 ORDER BY stockPrice);


