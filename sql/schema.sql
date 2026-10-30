-- ============================================================
-- Proyecto: Credit Risk Score
-- Fase 2: Definicion del Esquema DDL (PostgreSQL)
-- Archivo: sql/schema.sql
-- ============================================================

DROP TABLE IF EXISTS credit_risk;

CREATE TABLE credit_risk (
    person_id INT PRIMARY KEY,
    person_age INT NOT NULL,
    person_income NUMERIC(12, 2) NOT NULL,
    person_home_ownership VARCHAR(20) NOT NULL,
    person_emp_length INT NOT NULL,
    loan_intent VARCHAR(50) NOT NULL,
    loan_grade VARCHAR(50) NOT NULL,
    loan_amnt NUMERIC(12, 2) NOT NULL,
    loan_int_rate NUMERIC(5, 2) NOT NULL,
    loan_status INT NOT NULL, -- 0: Al dia, 1: En mora / Default
    loan_percent_income NUMERIC(5, 4) NOT NULL,
    cb_person_default_on_file VARCHAR(5) NOT NULL,
    cb_person_cred_hist_length INT NOT NULL,
    age_group VARCHAR(20) NOT NULL
);
