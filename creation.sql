drop table if exists development;
drop table if exists stock;
drop table if exists trademarks;
drop table if exists patents;
drop table if exists pharmacies;
drop table if exists drugs_to_diseases;
drop table if exists drugs_to_poisons;
drop table if exists poisons;
drop table if exists drugs;
drop table if exists ethnoscience_to_diseases;
drop table if exists diseases;
drop table if exists pathogens;
drop table if exists ethnoscience;
drop table if exists company_info;
drop table if exists companies;

drop type if exists pathogen_type cascade;
drop type if exists drugs_groups cascade;
drop type if exists poison_origin cascade;
drop type if exists development_stage cascade;
drop type if exists stock_availability cascade;
drop type if exists patent_distribution cascade;



CREATE TYPE pathogen_type AS ENUM ('virus', 'bacterium', 'protozoan', 'prion', 'viroid', 'fungus', 'small animal');
CREATE TYPE drugs_groups AS ENUM ('Group A (prohibited substances)', 'Group B (limited turnover)', 'Group C (free circulation)');
CREATE TYPE poison_origin AS ENUM ('nature', 'chemicals', 'synthetic');
CREATE TYPE development_stage AS ENUM ('Preclinical phase', 'Phase 0', 'Phase I', 'Phase II', 'Phase III', 'Phase IV');
CREATE TYPE patent_distribution AS ENUM ('free-to-use', 'usage with some constraints', 'restricted-to-use');


CREATE TABLE pathogens
(
    id     SERIAL PRIMARY KEY,
    name   VARCHAR(80)   NOT NULL,
    type   pathogen_type NOT NULL,
    action VARCHAR(80)   NOT NULL
);

CREATE TABLE diseases
(
    id          SERIAL PRIMARY KEY,
    pathogen_id INTEGER
        CONSTRAINT fk_pathogens_id REFERENCES pathogens (id) ON DELETE CASCADE,
    name        VARCHAR(80),
    mortality   DECIMAL NOT NULL
        DEFAULT 0 CHECK ( mortality >= 0 and mortality <= 1 )
);

CREATE TABLE poisons
(
    id               SERIAL PRIMARY KEY,
    active_substance VARCHAR(80) UNIQUE NOT NULL,
    type_by_action   VARCHAR(80)        NOT NULL,
    type_by_origin   poison_origin,
    mortality        DECIMAL            NOT NULL
        DEFAULT 0 CHECK ( mortality >= 0 and mortality <= 1 )
);

CREATE TABLE ethnoscience
(
    id     SERIAL PRIMARY KEY,
    name   VARCHAR(80) NOT NULL,
    origin VARCHAR(80) NOT NULL
);

CREATE TABLE companies
(
    id                           SERIAL PRIMARY KEY,
    name                         VARCHAR(80) UNIQUE NOT NULL,
    specialization               VARCHAR(80)        NOT NULL,
    market_cap                   DECIMAL CHECK ( market_cap >= 0 ),
    net_profit_margin_pct_annual DECIMAL CHECK ( net_profit_margin_pct_annual >= 0 ) -- ЧЕ это?))))
);

CREATE TABLE company_info
(
    id                           SERIAL PRIMARY KEY,
    company_id                   INTEGER
        CONSTRAINT fk_companies_id REFERENCES companies (id) ON DELETE CASCADE
        NOT NULL,
    restore_date                 TIMESTAMP,
    market_cap                   DECIMAL CHECK ( market_cap >= 0 ),
    net_profit_margin_pct_annual DECIMAL CHECK ( net_profit_margin_pct_annual >= 0 )
);
CREATE TABLE drugs
(
    id               SERIAL PRIMARY KEY,
    active_substance VARCHAR(80) UNIQUE NOT NULL,
    homeopathy       BOOLEAN            NOT NULL
        DEFAULT false,
    drugs_group      drugs_groups       NOT NULL
);


CREATE TABLE development
(
    id            SERIAL PRIMARY KEY,
    company_id    INTEGER
        CONSTRAINT fk_companies_id
            REFERENCES companies (id) ON DELETE CASCADE NOT NULL,
    pathogen_id   INTEGER
        CONSTRAINT fk_pathogens_id
            REFERENCES pathogens (id) ON DELETE CASCADE NOT NULL,
    testing_stage development_stage                     NOT NULL,
    failed        BOOLEAN                               NOT NULL DEFAULT false
);

CREATE TABLE patents
(
    id           SERIAL PRIMARY KEY,
    distribution patent_distribution NOT NULL,
    start_date   DATE                NOT NULL
);

CREATE TABLE trademarks
(
    id            SERIAL PRIMARY KEY,
    name          VARCHAR(80) UNIQUE NOT NULL,
    doze          DECIMAL            NOT NULL CHECK ( doze > 0 ),
    release_price DECIMAL            NOT NULL check ( release_price > 0 ),
    drug_id       INTEGER
        CONSTRAINT fk_drugs_id
            REFERENCES drugs (id) ON DELETE CASCADE,
    company_id    INTEGER
        CONSTRAINT fk_companies_id
            REFERENCES companies (id) ON DELETE CASCADE
                                     NOT NULL,
    patent_id     INTEGER
        CONSTRAINT fk_patents_patent_id
            REFERENCES patents (id) ON DELETE CASCADE,
    UNIQUE (drug_id, company_id, patent_id)
);

CREATE TABLE pharmacies
(
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(80) NOT NULL,
    price_mul  DECIMAL     NOT NULL CHECK ( price_mul >= 1 ),
    price_plus DECIMAL     NOT NULL CHECK ( price_plus >= 0 )
);

CREATE TABLE stock
(
    id           SERIAL PRIMARY KEY,
    pharmacy_id  INTEGER
        CONSTRAINT fk_pharmacy_id REFERENCES pharmacies (id) ON DELETE CASCADE
        NOT NULL,
    trademark_id INTEGER
        CONSTRAINT fk_trademarks_id REFERENCES trademarks (id) ON DELETE CASCADE
        NOT NULL,
    availability INTEGER DEFAULT 0 CHECK (availability >= 0),
    UNIQUE (pharmacy_id, trademark_id)
);

CREATE TABLE drugs_to_diseases
(
    id          SERIAL PRIMARY KEY,
    drugs_id   INTEGER
        CONSTRAINT fk_drugs_id REFERENCES drugs (id) ON DELETE CASCADE
        NOT NULL,
    disease_id INTEGER
        CONSTRAINT fk_diseases_id REFERENCES diseases (id) ON DELETE CASCADE
        NOT NULL,
    UNIQUE (drugs_id, disease_id)
);
CREATE TABLE drugs_to_poisons
(
    id          SERIAL PRIMARY KEY,
    drugs_id  INTEGER
        CONSTRAINT fk_drugs_id REFERENCES drugs (id) ON DELETE CASCADE
        NOT NULL,
    poison_id INTEGER
        CONSTRAINT fk_poisons_id REFERENCES poisons (id) ON DELETE CASCADE
        NOT NULL,
    UNIQUE (drugs_id, poison_id)
);
CREATE TABLE ethnoscience_to_diseases
(
    id          SERIAL PRIMARY KEY,
    ethnoscience_id INTEGER
        CONSTRAINT fk_ethnoscience_id REFERENCES ethnoscience (id) ON DELETE CASCADE
        NOT NULL,
    disease_id      INTEGER
        CONSTRAINT fk_diseases_id REFERENCES diseases (id) ON DELETE CASCADE
        NOT NULL,
    UNIQUE (ethnoscience_id, disease_id)
);



