-- ============================================================
--  MER — Sistema de Controle de Pessoal (Cenário 3)
--  Modelo Entidade-Relacionamento — 3ª Forma Normal (3FN)
--  ETAPA 1: Criação das tabelas (sem chaves estrangeiras)
--  Banco de dados: MySQL 8.x
-- ============================================================

DROP DATABASE IF EXISTS pessoal_db;
CREATE DATABASE pessoal_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE pessoal_db;

-- ============================================================
--  BLOCO 1 — DADOS PESSOAIS DO FUNCIONÁRIO
-- ============================================================

CREATE TABLE funcionario (
    id_func        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome           VARCHAR(120) NOT NULL,
    cpf            CHAR(11)     NOT NULL UNIQUE,
    dt_nascimento  DATE         NOT NULL,
    tipo_sanguineo ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') NOT NULL,
    email          VARCHAR(120) NOT NULL UNIQUE,
    estado_civil   ENUM('solteiro','casado','divorciado','viuvo','uniao_estavel')
                   NOT NULL DEFAULT 'solteiro'
                   COMMENT 'Estado civil do funcionário',
    doador_orgaos  TINYINT NOT NULL DEFAULT 0
                   COMMENT '1 = doador de órgãos; 0 = não doador',
    CONSTRAINT chk_cpf CHECK (cpf REGEXP '^[0-9]{11}$')
) COMMENT 'Dados cadastrais do funcionário';

CREATE TABLE telefone (
    id_tel   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_func  INT UNSIGNED NOT NULL,
    numero   VARCHAR(20)  NOT NULL,
    tipo     ENUM('celular','residencial','comercial') NOT NULL DEFAULT 'celular'
) COMMENT '1 funcionário possui N telefones';

CREATE TABLE endereco (
    id_end     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_func    INT UNSIGNED NOT NULL,
    logradouro VARCHAR(150) NOT NULL,
    numero     VARCHAR(10)  NOT NULL,
    bairro     VARCHAR(80)  NOT NULL,
    cidade     VARCHAR(80)  NOT NULL,
    uf         CHAR(2)      NOT NULL,
    cep        CHAR(8)      NOT NULL,
    CONSTRAINT chk_uf  CHECK (uf  REGEXP '^[A-Z]{2}$'),
    CONSTRAINT chk_cep CHECK (cep REGEXP '^[0-9]{8}$')
) COMMENT '1 funcionário reside em N endereços';

-- ============================================================
--  BLOCO 2 — NECESSIDADE ESPECIAL E OBRIGAÇÃO DA EMPRESA
-- ============================================================

CREATE TABLE necessidade_especial (
    id_necess INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(200) NOT NULL
) COMMENT 'Tipos de necessidades especiais cadastradas';

CREATE TABLE funcionario_necessidade (
    id_func   INT UNSIGNED NOT NULL,
    id_necess INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_func, id_necess)
) COMMENT 'N:N — Funcionário possui N necessidades especiais';

CREATE TABLE obrigacao_empresa (
    id_obrig  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_necess INT UNSIGNED NOT NULL,
    descricao VARCHAR(300) NOT NULL
) COMMENT '1 necessidade especial gera N obrigações da empresa';

-- ============================================================
--  BLOCO 3 — DEPENDENTE
-- ============================================================

CREATE TABLE dependente (
    id_dep        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_func       INT UNSIGNED NOT NULL,
    nome          VARCHAR(120) NOT NULL,
    tipo_dep      VARCHAR(50)  NOT NULL COMMENT 'filho(a), cônjuge, pai, mãe, etc.',
    dt_nascimento DATE         NOT NULL,
    universitario TINYINT      NOT NULL DEFAULT 0
        COMMENT '1=sim; dependente universitário é IR até 24 anos',
    CONSTRAINT chk_universitario CHECK (universitario IN (0, 1)),
    CONSTRAINT chk_dep_universitario_idade CHECK (
        universitario = 0
        OR TIMESTAMPDIFF(YEAR, dt_nascimento, CURDATE()) <= 24
    )
) COMMENT '1 funcionário tem N dependentes';

-- ============================================================
--  BLOCO 4 — SAÚDE: DOENÇA
-- ============================================================

CREATE TABLE doenca (
    id_doenca INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(120) NOT NULL,
    cid       VARCHAR(10)  NOT NULL UNIQUE COMMENT 'Código CID-10',
    descricao TEXT
) COMMENT 'Catálogo de doenças (CID-10)';

CREATE TABLE diagnostico (
    id_func        INT UNSIGNED NOT NULL,
    id_doenca      INT UNSIGNED NOT NULL,
    dt_diagnostico DATE         NOT NULL,
    observacao     TEXT,
    PRIMARY KEY (id_func, id_doenca, dt_diagnostico)
) COMMENT 'N:N — funcionário diagnosticado com doenças (com data e observação)';

-- ============================================================
--  BLOCO 5 — SAÚDE: EXAME OCUPACIONAL
-- ============================================================

CREATE TABLE exame (
    id_exame    INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
    nome        VARCHAR(120)  NOT NULL,
    val_ref_min DECIMAL(10,3) COMMENT 'Valor de referência mínimo',
    val_ref_max DECIMAL(10,3) COMMENT 'Valor de referência máximo',
    unidade     VARCHAR(30)   COMMENT 'Unidade de medida (mg/dL, mmHg, etc.)'
) COMMENT 'Catálogo de exames ocupacionais com valores de referência';

CREATE TABLE realizacao_exame (
    id_realizacao INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
    id_func       INT UNSIGNED  NOT NULL,
    id_exame      INT UNSIGNED  NOT NULL,
    dt_realizacao DATE          NOT NULL,
    resultado     DECIMAL(10,3) NOT NULL,
    observacao    TEXT,
    apto          TINYINT       NOT NULL DEFAULT 1
                  COMMENT '1 = APTO; 0 = INAPTO para o trabalho',
    CONSTRAINT chk_apto CHECK (apto IN (0, 1))
) COMMENT 'N:N — funcionário realiza N exames (com resultado e laudo de aptidão)';

-- ============================================================
--  BLOCO 6 — ORGANIZAÇÃO: SETOR, FUNÇÃO, HISTÓRICO DE LOTAÇÃO
-- ============================================================

CREATE TABLE setor (
    id_setor  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(120) NOT NULL,
    descricao TEXT
) COMMENT 'Setores da empresa';

CREATE TABLE funcao (
    id_funcao INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(120) NOT NULL,
    descricao TEXT
) COMMENT 'Funções/cargos existentes na empresa';

CREATE TABLE historico_lotacao (
    id_hist     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_func     INT UNSIGNED NOT NULL,
    id_setor    INT UNSIGNED NOT NULL,
    id_funcao   INT UNSIGNED NOT NULL,
    data_inicio DATE         NOT NULL,
    data_fim    DATE         NULL COMMENT 'NULL = lotação atual',
    CONSTRAINT chk_datas_hist CHECK (data_fim IS NULL OR data_fim >= data_inicio)
) COMMENT 'Histórico ternário: funcionário × setor × função, com datas';

-- ============================================================
--  BLOCO 7 — FÉRIAS
-- ============================================================

CREATE TABLE ferias (
    id_ferias   INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    id_func     INT UNSIGNED     NOT NULL,
    data_inicio DATE             NOT NULL,
    data_fim    DATE             NOT NULL,
    qtd_dias    TINYINT UNSIGNED NOT NULL,
    CONSTRAINT chk_ferias_datas CHECK (data_fim >= data_inicio)
) COMMENT '1 funcionário usufrui N períodos de férias';

-- ============================================================
--  BLOCO 8 — CURRÍCULO, CURSO E COMPETÊNCIA
-- ============================================================

CREATE TABLE curriculo (
    id_curriculo       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_func            INT UNSIGNED NOT NULL UNIQUE,
    nivel_escolaridade ENUM(
        'fundamental_incompleto','fundamental_completo',
        'medio_incompleto','medio_completo',
        'tecnico','superior_incompleto','superior_completo',
        'pos_graduacao','mestrado','doutorado'
    ) NOT NULL
) COMMENT '1:1 — funcionário possui 1 currículo';

CREATE TABLE competencia (
    id_competencia INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome           VARCHAR(120) NOT NULL,
    descricao      TEXT
) COMMENT 'Competências que uma função pode exigir';

CREATE TABLE curso (
    id_curso INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome     VARCHAR(150) NOT NULL
) COMMENT 'Catálogo de cursos disponíveis';

CREATE TABLE curriculo_curso (
    id_curriculo  INT UNSIGNED      NOT NULL,
    id_curso      INT UNSIGNED      NOT NULL,
    data_inicio   DATE              NOT NULL,
    data_fim      DATE,
    carga_horaria SMALLINT UNSIGNED NOT NULL COMMENT 'Horas cursadas nesta realização',
    PRIMARY KEY (id_curriculo, id_curso, data_inicio),
    CONSTRAINT chk_cc_datas CHECK (data_fim IS NULL OR data_fim >= data_inicio)
) COMMENT 'N:N — currículo inclui N cursos (com datas e carga horária da realização)';

CREATE TABLE curso_competencia (
    id_curso       INT UNSIGNED NOT NULL,
    id_competencia INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_curso, id_competencia)
) COMMENT 'N:N — curso desenvolve N competências';

CREATE TABLE funcao_competencia (
    id_funcao      INT UNSIGNED NOT NULL,
    id_competencia INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_funcao, id_competencia)
) COMMENT 'N:N — função requer N competências';
