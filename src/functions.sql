CREATE OR REPLACE FUNCTION addCompanyOwner(owner_id INT, company_inn NUMERIC(14))
  RETURNS BOOLEAN AS $BODY$
BEGIN
  INSERT INTO Company_owners
  (company_inn, owner_id, count, buy_date)
  VALUES
    (company_inn, owner_id, 0, NOW());
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION transitStocks(old_owner_id INT, new_owner_id INT, tr_company_inn NUMERIC(14),
                                         amount       INT) -- akcii
  RETURNS BOOLEAN AS $BODY$
BEGIN
  IF ((SELECT COUNT(*)
       FROM Company_owners
       WHERE Company_owners.owner_id = old_owner_id AND Company_owners.company_inn = tr_company_inn AND
             amount < company_owners.count) != 1 OR
      (SELECT COUNT(*)
       FROM Company_owners
       WHERE Company_owners.owner_id = new_owner_id AND Company_owners.company_inn = tr_company_inn) != 1)
  THEN
    RETURN FALSE;
  ELSE
    UPDATE Company_owners
    SET Company_owners.count = Company_owners.count - amount
    WHERE Company_owners.owner_id = old_owner_id AND Company_owners.company_inn = tr_company_inn;
    UPDATE Company_owners
    SET Company_owners.count = Company_owners.count + amount
    WHERE Company_owners.owner_id = new_owner_id AND Company_owners.company_inn = tr_company_inn;
    RETURN TRUE;
  END IF;

END;
$BODY$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION findMoneyAsset(billed_company_inn INT)
  RETURNS INT AS $BODY$
DECLARE
  _id INT;
BEGIN
  SELECT working_id
  FROM Working_assets
  WHERE
    billed_company_inn = working_assets.company_inn
  INTO _id;
  RETURN _id;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION transitWorkingAsset(asset_id INT, new_company_inn INT, amount INT)
  RETURNS BOOLEAN AS $BODY$
DECLARE
  _exist        BOOLEAN;
  _working_name VARCHAR(120);
  _working_type VARCHAR(30);
  _cost_per_one INT;
BEGIN
  IF ((SELECT COUNT(*)
       FROM Working_assets
       WHERE Working_assets.working_id = asset_id AND
             amount < Working_assets.count) != 1)
  THEN
    RETURN FALSE;
  ELSE
    SELECT working_name
    FROM Working_assets
    WHERE
      asset_id = working_assets.working_id
    INTO _working_name;
    SELECT working_type
    FROM Working_assets
    WHERE
      asset_id = working_assets.working_id
    INTO _working_type;
    SELECT cost_per_one
    FROM Working_assets
    WHERE
      asset_id = working_assets.working_id
    INTO _cost_per_one;

    IF ((SELECT COUNT(*)
         FROM Working_assets
         WHERE Working_assets.company_inn = new_company_inn AND
               Working_assets.working_name = _working_name AND
               Working_assets.working_type = _working_type) = 0)
    THEN
      INSERT INTO Working_assets
      (company_inn, working_name, count, cost_per_one, working_type)
      VALUES
        (new_company_inn, _working_name, amount, _cost_per_one, _working_type);
    ELSE
      UPDATE Working_assets
      SET working_assets.count = working_assets.count + amount
      WHERE Working_assets.company_inn = new_company_inn AND
            Working_assets.working_name = _working_name AND
            Working_assets.working_type = _working_type;
    END IF;
    UPDATE Company_owners
    SET Working_assets.count = Working_assets.count - amount
    WHERE Working_assets.working_id = asset_id;
  END IF;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION companyOwnersPercentage(tr_company_inn NUMERIC(14))
  RETURNS TABLE(owner_id INT, percentage FLOAT) AS $BODY$
DECLARE
  _all_stocks BIGINT;
BEGIN
  SELECT SUM(count)
  FROM Company_owners
  WHERE Company_owners.company_inn = tr_company_inn
  INTO _all_stocks;

  RETURN QUERY SELECT
                 Company_owners.owner_id,
                 count / _all_stocks :: FLOAT AS percentage
               FROM Company_owners
               WHERE Company_owners.company_inn = tr_company_inn;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION companyOwnerPercentage(cmp_owner_id INT, tr_company_inn NUMERIC(14))
  RETURNS FLOAT AS $BODY$
DECLARE
  _result FLOAT;
BEGIN
  SELECT percentage
  FROM companyOwnersPercentage(tr_company_inn) AS cop
  WHERE cop.owner_id =
        cmp_owner_id
  INTO _result;

  RETURN _result;
END;
$BODY$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION companyCapitalization(tr_company_inn NUMERIC(14))
  RETURNS BIGINT AS $BODY$
DECLARE
  _working_assets    BIGINT DEFAULT 0;
  _capital_assets    BIGINT DEFAULT 0;
  _deffered_payments BIGINT DEFAULT 0;
  _another_companies BIGINT DEFAULT 0;
  _owner_id          INT;
BEGIN
  SELECT SUM(cost)
  FROM Capital_assets
  WHERE tr_company_inn = Capital_assets.company_inn
  INTO _capital_assets;

  SELECT SUM(deffered_money)
  FROM Deffered_payments
  WHERE tr_company_inn = Deffered_payments.company_inn
  INTO _deffered_payments;

  SELECT SUM(cost_per_one * count)
  FROM Working_assets
  WHERE tr_company_inn = Working_assets.company_inn
  INTO _working_assets;

  SELECT owner_id
  FROM Owners
  WHERE tr_company_inn = Owners.company_inn
  INTO _owner_id;
  SELECT SUM((percentage * capitalization) :: BIGINT)
  FROM
    (SELECT
       company_inn,
       companyOwnerPercentage(_owner_id, company_inn) AS percentage,
       companyCapitalization(company_inn)             AS capitalization
     FROM Company_owners
     WHERE company_owners.owner_id = _owner_id)
      AS a
  INTO _another_companies;

  RETURN COALESCE(_another_companies, 0) + COALESCE(_capital_assets, 0) + COALESCE(_working_assets, 0) -
         COALESCE(_deffered_payments, 0);

END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION payDebts(trg_deffered_payment_id INT)
  RETURNS BOOLEAN AS $BODY$
DECLARE
  _debt_amount BIGINT;
  _company_inn BIGINT;
BEGIN
  SELECT deffered_money
  FROM Deffered_payments
  WHERE trg_deffered_payment_id = deffered_payments.deffered_payment_id
  INTO _debt_amount;

  SELECT company_inn
  FROM Deffered_payments
  WHERE trg_deffered_payment_id = Deffered_payments.deffered_payment_id
  INTO _company_inn;

  IF ((SELECT COUNT(*)
       FROM Working_assets
       WHERE Working_assets.company_inn = _company_inn AND Working_assets.working_type = 'MONEY' AND
             Working_assets.working_name = 'RUBLES' AND
             _debt_amount < Working_assets.count) = 1)
  THEN
    UPDATE Working_assets
    SET count = count - _debt_amount
    WHERE company_inn = _company_inn AND working_type = 'MONEY' AND
          working_name = 'RUBLES';
    DELETE FROM deffered_payments
    WHERE deffered_payments.deffered_payment_id = trg_deffered_payment_id;
    RETURN TRUE;
  END IF;
  RETURN FALSE;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION takeCredit(msum BIGINT, months INT, tr_company_inn NUMERIC(14))
  RETURNS BOOLEAN AS $BODY$
DECLARE
  t     DATE := DATE 'tomorrow';
  _perm BIGINT;
BEGIN
  IF ((SELECT COUNT(*)
       FROM Working_assets
       WHERE Working_assets.company_inn = tr_company_inn AND Working_assets.working_type = 'MONEY' AND
             Working_assets.working_name = 'RUBLES') = 1)
  THEN
    UPDATE Working_assets
    SET count = count + msum
    WHERE company_inn = tr_company_inn AND working_type = 'MONEY' AND
          working_name = 'RUBLES';

    _perm = msum / months;

    FOR i IN 1..months LOOP
      t = t + INTERVAL '1 month';
      INSERT INTO Deffered_payments
      (deffered_money, expiration_date, company_inn)
      VALUES
        (_perm, t, tr_company_inn);
    END LOOP;
    RETURN TRUE;
  END IF;
  RETURN FALSE;
END;
$BODY$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION companyBeneficial(tr_company_inn NUMERIC(14))
  RETURNS TABLE(person_INN VARCHAR(14), benefitial_date DATE) AS $BODY$
DECLARE

  _deffered_payments BIGINT DEFAULT 0;
  _another_companies BIGINT DEFAULT 0;
  _owner_id          INT;
  _table             TABLE(company_inn VARCHAR(14));
BEGIN

  SELECT (person_inn, buy_date)
  FROM ((SELECT owner_id, company_inn as trg_company_inn, buy_date
         FROM company_owners
         WHERE tr_company_inn = company_owners.company_inn) AS t NATURAL JOIN (Owners))
  WHERE type = 0;


  FOR temprow IN
    SELECT (company_inn)
    FROM ((SELECT owner_id, company_inn as trg_company_inn, buy_date
           FROM company_owners
           WHERE tr_company_inn = company_owners.company_inn) AS t NATURAL JOIN (Owners))
    WHERE type = 1
  LOOP
    INSERT INTO user_data.leaderboards (season_num,player_id,season_pts) VALUES (old_seasonnum,temprow.userd_id,temprow.season_ptss);
  END LOOP;



END;
$BODY$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION companiesBeneficial(tr_company_inn NUMERIC(14))
  RETURNS TABLE(person_INN VARCHAR(14), benefitial_date DATE) AS $BODY$
DECLARE

  _deffered_payments BIGINT DEFAULT 0;
  _another_companies BIGINT DEFAULT 0;
  _owner_id          INT;
  _table             TABLE(company_inn VARCHAR(14));
BEGIN

  SELECT (person_inn, buy_date)
  FROM ((SELECT owner_id, company_inn as trg_company_inn, buy_date
         FROM company_owners
         WHERE tr_company_inn = company_owners.company_inn) AS t NATURAL JOIN (Owners))
  WHERE type = 0;


  FOR temprow IN
  SELECT (company_inn)
  FROM ((SELECT owner_id, company_inn as trg_company_inn, buy_date
         FROM company_owners
         WHERE tr_company_inn = company_owners.company_inn) AS t NATURAL JOIN (Owners))
  WHERE type = 1
  LOOP
    INSERT INTO user_data.leaderboards (season_num,player_id,season_pts) VALUES (old_seasonnum,temprow.userd_id,temprow.season_ptss);
  END LOOP;



END;
$BODY$ LANGUAGE plpgsql;