
CREATE TABLE Company_type (
  company_type_id SERIAL,
  type VARCHAR(30) NOT NULL,
  PRIMARY KEY (company_type_id),
  UNIQUE (type)
);

CREATE TABLE Company (
  company_INN NUMERIC(14) NOT NULL,
  company_type_id INT NOT NULL,
  company_name VARCHAR(60) NOT NULL,
  registered_office VARCHAR(80) NOT NULL,
  country VARCHAR(30) DEFAULT 'Russia',
  OGRN VARCHAR(13),
  PRIMARY KEY(company_INN),
  FOREIGN KEY (company_type_id) REFERENCES Company_type ON DELETE CASCADE
);

CREATE TABLE Persons (
  full_name VARCHAR(60) NOT NULL,
  person_INN NUMERIC(14) NOT NULL,
  PRIMARY KEY (person_INN)
);

CREATE TABLE Owners (
  owner_id SERIAL,
  type SMALLINT DEFAULT 1, --1 Entity, 0 -- person
  person_INN NUMERIC(14),
  company_INN NUMERIC(14),
  PRIMARY KEY (owner_id),
  FOREIGN KEY (company_INN) REFERENCES Company ON DELETE CASCADE,
  FOREIGN KEY (person_INN) REFERENCES Persons ON DELETE CASCADE
);

CREATE TABLE Company_owners (
  company_INN NUMERIC(14) NOT NULL,
  owner_id SERIAL,
  count INT NOT NULL,
  buy_date DATE,
  PRIMARY KEY (owner_id, company_INN),
  FOREIGN KEY (company_INN) REFERENCES Company ON DELETE CASCADE,
  FOREIGN KEY (owner_id) REFERENCES Owners ON DELETE CASCADE
);


CREATE TABLE Capital_assets (
  capital_id SERIAL,
  company_INN NUMERIC(14) NOT NULL,
  capital_name VARCHAR(120) NOT NULL,
  cost BIGINT NOT NULL,
  capital_type VARCHAR(30),
  FOREIGN KEY (company_INN) REFERENCES Company ON DELETE CASCADE
);

CREATE TABLE Working_assets (
  working_id SERIAL,
  company_INN NUMERIC(14) NOT NULL,
  working_name VARCHAR(120) NOT NULL,
  count BIGINT NOT NULL DEFAULT 1,
  cost_per_one BIGINT NOT NULL DEFAULT 0,
  working_type VARCHAR(30),
  FOREIGN KEY (company_INN) REFERENCES Company ON DELETE CASCADE
);

CREATE TABLE Deffered_payments (
  deffered_payment_id SERIAL,
  deffered_money INT NOT NULL DEFAULT 0,
  expiration_date DATE,
  company_INN NUMERIC(14) NOT NULL,
  FOREIGN KEY (company_INN) REFERENCES Company ON DELETE CASCADE
);
