-- ==========================================
-- 1. CRIANDO AS TABELAS DE DIMENSÃO
-- ==========================================

-- A. Dimensão Médico
DROP TABLE IF EXISTS dim_medico CASCADE;
CREATE TABLE dim_medico (
    id_medico SERIAL PRIMARY KEY,
    nome_medico VARCHAR(255)
);
INSERT INTO dim_medico (nome_medico)
SELECT DISTINCT doctor FROM stg_internacoes_brutas WHERE doctor IS NOT NULL;

-- B. Dimensão Convênio (Plano de Saúde)
DROP TABLE IF EXISTS dim_convenio CASCADE;
CREATE TABLE dim_convenio (
    id_convenio SERIAL PRIMARY KEY,
    nome_convenio VARCHAR(255)
);
INSERT INTO dim_convenio (nome_convenio)
SELECT DISTINCT insurance_provider FROM stg_internacoes_brutas WHERE insurance_provider IS NOT NULL;

-- C. Dimensão Hospital
DROP TABLE IF EXISTS dim_hospital CASCADE;
CREATE TABLE dim_hospital (
    id_hospital SERIAL PRIMARY KEY,
    nome_hospital VARCHAR(255)
);
INSERT INTO dim_hospital (nome_hospital)
SELECT DISTINCT hospital FROM stg_internacoes_brutas WHERE hospital IS NOT NULL;


-- ==========================================
-- 2. CRIANDO A TABELA FATO (O Coração)
-- ==========================================

DROP TABLE IF EXISTS fato_internacoes CASCADE;
CREATE TABLE fato_internacoes (
    id_internacao SERIAL PRIMARY KEY,
    id_medico INT REFERENCES dim_medico(id_medico),
    id_convenio INT REFERENCES dim_convenio(id_convenio),
    id_hospital INT REFERENCES dim_hospital(id_hospital),
    paciente_nome VARCHAR(255),
    condicao_medica VARCHAR(255),
    data_admissao DATE,
    data_alta DATE,
    valor_faturamento NUMERIC(10,2)
);

-- Preenchendo a Fato e Convertendo Textos para Datas e Números Reais
INSERT INTO fato_internacoes (
    id_medico, id_convenio, id_hospital, paciente_nome, 
    condicao_medica, data_admissao, data_alta, valor_faturamento
)
SELECT 
    dm.id_medico,
    dc.id_convenio,
    dh.id_hospital,
    stg.name,
    stg.medical_condition,
    CAST(stg.date_of_admission AS DATE),
    CAST(stg.discharge_date AS DATE),
    CAST(stg.billing_amount AS NUMERIC(10,2))
FROM stg_internacoes_brutas AS stg
LEFT JOIN dim_medico AS dm ON stg.doctor = dm.nome_medico
LEFT JOIN dim_convenio AS dc ON stg.insurance_provider = dc.nome_convenio
LEFT JOIN dim_hospital AS dh ON stg.hospital = dh.nome_hospital;