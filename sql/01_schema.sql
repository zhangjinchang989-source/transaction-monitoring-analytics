-- Table: public.alerts

-- DROP TABLE IF EXISTS public.alerts;

CREATE TABLE IF NOT EXISTS public.alerts
(
    alert_id integer NOT NULL,
    txn_id integer,
    rule_name text COLLATE pg_catalog."default",
    generated_ts_utc timestamp without time zone,
    severity text COLLATE pg_catalog."default",
    case_id integer,
    analyst_id integer,
    status text COLLATE pg_catalog."default",
    closed_ts_utc timestamp without time zone,
    decision text COLLATE pg_catalog."default",
    CONSTRAINT alerts_pkey PRIMARY KEY (alert_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.alerts
    OWNER to postgres;

-- Table: public.analysts

-- DROP TABLE IF EXISTS public.analysts;

CREATE TABLE IF NOT EXISTS public.analysts
(
    analyst_id integer NOT NULL,
    team text COLLATE pg_catalog."default",
    CONSTRAINT analysts_pkey PRIMARY KEY (analyst_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.analysts
    OWNER to postgres;

-- Table: public.cases

-- DROP TABLE IF EXISTS public.cases;

CREATE TABLE IF NOT EXISTS public.cases
(
    case_id integer NOT NULL,
    customer_id integer,
    opened_ts_utc timestamp without time zone,
    closed_ts_utc timestamp without time zone,
    assigned_analyst_id integer,
    outcome text COLLATE pg_catalog."default",
    time_to_close_hours numeric(10,1),
    CONSTRAINT cases_pkey PRIMARY KEY (case_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.cases
    OWNER to postgres;

-- Table: public.customers

-- DROP TABLE IF EXISTS public.customers;

CREATE TABLE IF NOT EXISTS public.customers
(
    customer_id integer NOT NULL,
    home_country text COLLATE pg_catalog."default",
    risk_rating text COLLATE pg_catalog."default",
    pep_flag integer,
    segment text COLLATE pg_catalog."default",
    CONSTRAINT customers_pkey PRIMARY KEY (customer_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.customers
    OWNER to postgres;

-- Table: public.merchants

-- DROP TABLE IF EXISTS public.merchants;

CREATE TABLE IF NOT EXISTS public.merchants
(
    merchant_id integer NOT NULL,
    merchant_country text COLLATE pg_catalog."default",
    mcc text COLLATE pg_catalog."default",
    merchant_risk text COLLATE pg_catalog."default",
    CONSTRAINT merchants_pkey PRIMARY KEY (merchant_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.merchants
    OWNER to postgres;

-- Table: public.transactions

-- DROP TABLE IF EXISTS public.transactions;

CREATE TABLE IF NOT EXISTS public.transactions
(
    txn_id integer NOT NULL,
    txn_ts_utc timestamp without time zone,
    customer_id integer,
    merchant_id integer,
    channel text COLLATE pg_catalog."default",
    amount numeric(12,2),
    currency text COLLATE pg_catalog."default",
    txn_country text COLLATE pg_catalog."default",
    is_international integer,
    risk_score numeric(5,1),
    CONSTRAINT transactions_pkey PRIMARY KEY (txn_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.transactions
    OWNER to postgres;
