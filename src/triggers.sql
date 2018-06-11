CREATE OR REPLACE FUNCTION addPersonToOwners()
  RETURNS TRIGGER AS $BODY$
DECLARE
  _person_inn NUMERIC(14) DEFAULT NULL;
BEGIN
  INSERT INTO Owners
    (type, person_inn, company_inn)
  VALUES
    (0, NEW.person_inn, null);

  RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER ValidatePersonOwners
AFTER INSERT ON Persons
FOR EACH ROW EXECUTE PROCEDURE addPersonToOwners();

---
CREATE OR REPLACE FUNCTION addCompanyToOwners()
  RETURNS TRIGGER AS $BODY$
DECLARE
  _company_inn NUMERIC(14) DEFAULT NULL;
BEGIN
  INSERT INTO Owners
  (type, person_inn, company_inn)
  VALUES
    (1, null, NEW.company_inn);

  RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER ValidateCompanyOwners
AFTER INSERT ON Company
FOR EACH ROW EXECUTE PROCEDURE addCompanyToOwners();

-- Expiration trigger

CREATE OR REPLACE FUNCTION deleteOutdatedCapital()
  RETURNS TRIGGER AS $BODY$
BEGIN
  DELETE FROM Capital_Assets WHERE (Capital_Assets.expiration_date IS NOT NULL and Capital_Assets.expiration_date < NOW());
  RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER OutdatedCapitalCheck
BEFORE INSERT OR UPDATE ON Capital_assets
FOR EACH STATEMENT EXECUTE PROCEDURE deleteOutdatedCapital();

-- empty asset trigger

CREATE OR REPLACE FUNCTION deleteEmptyAssets()
  RETURNS TRIGGER AS $BODY$
BEGIN
  DELETE FROM Working_Assets WHERE (Working_Assets.count = 0 and Working_Assets.working_type != 'MONEY');
  RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER EmptyAssetsCheck
BEFORE INSERT OR UPDATE ON Working_Assets
FOR EACH STATEMENT EXECUTE PROCEDURE deleteEmptyAssets();