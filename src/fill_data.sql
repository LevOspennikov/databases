INSERT INTO Company_type
  (type)
VALUES
  ('CJSC'), -- ЗАO
  ('PJSC'); -- ПAO

INSERT INTO Company
  (company_INN, company_type_id, company_name, registered_office, country, OGRN)
VALUES
  (7708004767, 2, 'PJSC LUKOIL',  '11, Sretensky Boulevard, Moscow', 'Russia', 1027700035769),
  (3015080621, 1, 'Lukoil-Primoreneftegaz, CJSC', '1, Admiralteyskaya street, Astrahan', 'Russia', 1073015005854),
  (8324324344, 1, 'Lukoil-TRANS, CJSC', '', 'Russia', 1073015005943);


INSERT INTO Persons
  (full_name, person_INN)
VALUES
  ('Vagit Yusufovich Alekperov', 866809987705),
  ('Leonid Arnoldovich Fedun', 780872447132),
  ('Viktor Vladimirovich Blazheev', 609907340606);

-- INSERT INTO Owners
--   (type, person_inn, company_inn)
-- VALUES
--   (1, null, 7708004767),
--   (1, null, 3015080621),
--   (1, null, 8324324344),
--   (0, 866809987705, null),
--   (0, 780872447132, null),
--   (0, 609907340606, null);

INSERT INTO Company_owners
  (company_inn, owner_id, count, buy_date)
VALUES
  (7708004767, 4, 53535, '2006-02-23'),
  (7708004767, 5, 32233, '2007-02-24'),
  (7708004767, 6, 13144, '2007-12-01'),
  (3015080621, 1, 3000, '2009-06-09'),
  (3015080621, 4, 2300, '2009-06-13'),
  (3015080621, 5, 1000, '2009-06-15'),
  (8324324344, 1, 6000, '2010-07-10'),
  (8324324344, 4, 5000, '2010-07-21'),
  (8324324344, 6, 2000, '2010-07-22');

INSERT INTO Capital_assets
  (company_inn, capital_name, cost, expiration_date, capital_type)
VALUES
  (7708004767, '11, Sretensky Boulevard, Moscow', 7380000000, null, 'Real estate'), -- недвижимость
  (7708004767, 'BMW X5', 7000000, null, 'Car'),
  (7708004767, 'Porshe 911', 8000000, null, 'Car'),
  (3015080621, '1, Admiralteyskaya street, Astrahan', 95000000, null, 'Real estate'),
  (3015080621, '20 ga land near Astrahan', 123000000, null, 'Land'),
  (3015080621, '32 ga land near Solyanka', 321000000, DATE 'yesterday' , 'Land');

INSERT INTO Working_assets
  (company_inn, working_name, count, cost_per_one, working_type)
VALUES
  (3015080621, 'RUBLES', 7000000000, 1, 'MONEY'),
  (7708004767, 'RUBLES', 70000000000, 1,  'MONEY'),
  (8324324344, 'RUBLES', 1400000000, 1, 'MONEY'),
  (3015080621, 'PETROLEUM', 7000090, 3000,'FUEL'),
  (8324324344, 'PETROLEUM', 9800090, 3000, 'FUEL');

INSERT INTO Deffered_payments
  (deffered_money, expiration_date, company_inn)
VALUES
  (10000000, DATE '2018-03-18', 3015080621),
  (10000000, DATE '2018-03-19', 7708004767),
  (10000000, DATE '2019-03-19', 8324324344);
