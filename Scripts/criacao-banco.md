# 01 — Criação do Banco de Dados

Script completo de criação do banco `pessoal_db` com todas as tabelas, constraints, índices e trigger.

```sql



DROP SCHEMA IF EXISTS pessoal_db;

CREATE SCHEMA pessoal_db;

USE pessoal_db;



-- DADOS PESSOAIS DO FUNCIONÁRIO

CREATE TABLE pessoal_db.funcionario (
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

CREATE TABLE pessoal_db.telefone (
    id_tel   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_func  INT UNSIGNED NOT NULL,
    numero   VARCHAR(20)  NOT NULL,
    tipo     ENUM('celular','residencial','comercial') NOT NULL DEFAULT 'celular'
) COMMENT '1 funcionário possui N telefones';

CREATE TABLE pessoal_db.endereco (
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

-- NECESSIDADE ESPECIAL E OBRIGAÇÃO DA EMPRESA

CREATE TABLE pessoal_db.necessidade_especial (
    id_necess INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(200) NOT NULL
) COMMENT 'Tipos de necessidades especiais cadastradas';

CREATE TABLE pessoal_db.funcionario_necessidade (
    id_func   INT UNSIGNED NOT NULL,
    id_necess INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_func, id_necess)
) COMMENT 'N:N — Funcionário possui N necessidades especiais';

CREATE TABLE pessoal_db.obrigacao_empresa (
    id_obrig  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_necess INT UNSIGNED NOT NULL,
    descricao VARCHAR(300) NOT NULL
) COMMENT '1 necessidade especial gera N obrigações da empresa';

-- DEPENDENTE

CREATE TABLE pessoal_db.dependente (
    id_dep        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_func       INT UNSIGNED NOT NULL,
    nome          VARCHAR(120) NOT NULL,
    tipo_dep      VARCHAR(50)  NOT NULL COMMENT 'filho(a), cônjuge, pai, mãe, etc.',
    dt_nascimento DATE         NOT NULL,
    universitario TINYINT      NOT NULL DEFAULT 0
        COMMENT '1=sim; dependente universitário é IR até 24 anos'
) COMMENT '1 funcionário tem N dependentes';

-- SAÚDE: DOENÇA

CREATE TABLE pessoal_db.doenca (
    id_doenca INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(120) NOT NULL,
    cid       VARCHAR(10)  NOT NULL UNIQUE COMMENT 'Código CID-10',
    descricao TEXT
) COMMENT 'Catálogo de doenças (CID-10)';

CREATE TABLE pessoal_db.diagnostico (
    id_func        INT UNSIGNED NOT NULL,
    id_doenca      INT UNSIGNED NOT NULL,
    dt_diagnostico DATE         NOT NULL,
    observacao     TEXT,
    PRIMARY KEY (id_func, id_doenca, dt_diagnostico)
) COMMENT 'N:N — funcionário diagnosticado com doenças (com data e observação)';

-- SAÚDE: EXAME OCUPACIONAL

CREATE TABLE pessoal_db.exame (
    id_exame    INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
    nome        VARCHAR(120)  NOT NULL,
    val_ref_min DECIMAL(10,3) COMMENT 'Valor de referência mínimo',
    val_ref_max DECIMAL(10,3) COMMENT 'Valor de referência máximo',
    unidade     VARCHAR(30)   COMMENT 'Unidade de medida (mg/dL, mmHg, etc.)'
) COMMENT 'Catálogo de exames ocupacionais com valores de referência';

CREATE TABLE pessoal_db.realizacao_exame (
    id_realizacao INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
    id_func       INT UNSIGNED  NOT NULL,
    id_exame      INT UNSIGNED  NOT NULL,
    dt_realizacao DATE          NOT NULL,
    resultado     DECIMAL(10,3) NOT NULL,
    observacao    TEXT,
    apto          TINYINT       NOT NULL DEFAULT 1
                  COMMENT '1 = APTO; 0 = INAPTO para o trabalho'
) COMMENT 'N:N — funcionário realiza N exames (com resultado e laudo de aptidão)';

-- ORGANIZAÇÃO: SETOR, FUNÇÃO, HISTÓRICO DE LOTAÇÃO

CREATE TABLE pessoal_db.setor (
    id_setor  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(120) NOT NULL,
    descricao TEXT
) COMMENT 'Setores da empresa';

CREATE TABLE pessoal_db.funcao (
    id_funcao INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(120) NOT NULL,
    descricao TEXT
) COMMENT 'Funções/cargos existentes na empresa';

CREATE TABLE pessoal_db.historico_lotacao (
    id_hist     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_func     INT UNSIGNED NOT NULL,
    id_setor    INT UNSIGNED NOT NULL,
    id_funcao   INT UNSIGNED NOT NULL,
    data_inicio DATE         NOT NULL,
    data_fim    DATE                   COMMENT 'NULL = lotação atual',
    CONSTRAINT chk_datas_hist CHECK (data_fim IS NULL OR data_fim >= data_inicio)
) COMMENT 'Histórico ternário: funcionário × setor × função, com datas';

--  BLOCO 7 — FÉRIAS
--  Regra: no máximo 30% da força de trabalho do setor em férias (Usando o Trigger)

CREATE TABLE pessoal_db.ferias (
    id_ferias   INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    id_func     INT UNSIGNED     NOT NULL,
    data_inicio DATE             NOT NULL,
    data_fim    DATE             NOT NULL,
    qtd_dias    TINYINT UNSIGNED NOT NULL,
    CONSTRAINT chk_ferias_datas CHECK (data_fim >= data_inicio)
) COMMENT '1 funcionário usufrui N períodos de férias';

DELIMITER $$
CREATE TRIGGER pessoal_db.trg_ferias_limite_30pct
BEFORE INSERT ON pessoal_db.ferias
FOR EACH ROW
BEGIN
    DECLARE v_id_setor    INT UNSIGNED;
    DECLARE v_total_setor INT;
    DECLARE v_em_ferias   INT;

    SELECT id_setor INTO v_id_setor
    FROM pessoal_db.historico_lotacao
    WHERE id_func = NEW.id_func AND data_fim IS NULL
    LIMIT 1;

    IF v_id_setor IS NOT NULL THEN
        SELECT COUNT(*) INTO v_total_setor
        FROM pessoal_db.historico_lotacao
        WHERE id_setor = v_id_setor AND data_fim IS NULL;

        SELECT COUNT(*) INTO v_em_ferias
        FROM pessoal_db.ferias f
        JOIN pessoal_db.historico_lotacao hl ON hl.id_func = f.id_func
        WHERE hl.id_setor = v_id_setor
          AND hl.data_fim IS NULL
          AND f.data_inicio <= NEW.data_fim
          AND f.data_fim    >= NEW.data_inicio;

        IF v_total_setor > 0 AND (v_em_ferias / v_total_setor) >= 0.30 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Limite de 30% da força do setor em férias seria ultrapassado.';
        END IF;
    END IF;
END$$
DELIMITER ;

-- CURRÍCULO, CURSO E COMPETÊNCIA

CREATE TABLE pessoal_db.curriculo (
    id_curriculo       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_func            INT UNSIGNED NOT NULL UNIQUE,
    nivel_escolaridade ENUM(
        'fundamental_incompleto','fundamental_completo',
        'medio_incompleto','medio_completo',
        'tecnico','superior_incompleto','superior_completo',
        'pos_graduacao','mestrado','doutorado'
    ) NOT NULL
) COMMENT '1:1 — funcionário possui 1 currículo';

CREATE TABLE pessoal_db.competencia (
    id_competencia INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome           VARCHAR(120) NOT NULL,
    descricao      TEXT
) COMMENT 'Competências que uma função pode exigir';

CREATE TABLE pessoal_db.curso (
    id_curso INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome     VARCHAR(150) NOT NULL
) COMMENT 'Catálogo de cursos disponíveis';

CREATE TABLE pessoal_db.curriculo_curso (
    id_curriculo  INT UNSIGNED      NOT NULL,
    id_curso      INT UNSIGNED      NOT NULL,
    data_inicio   DATE              NOT NULL,
    data_fim      DATE,
    carga_horaria SMALLINT UNSIGNED NOT NULL COMMENT 'Horas cursadas nesta realização',
    PRIMARY KEY (id_curriculo, id_curso, data_inicio),
    CONSTRAINT chk_cc_datas CHECK (data_fim IS NULL OR data_fim >= data_inicio)
) COMMENT 'N:N — currículo inclui N cursos (com datas e carga horária da realização)';

CREATE TABLE pessoal_db.curso_competencia (
    id_curso       INT UNSIGNED NOT NULL,
    id_competencia INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_curso, id_competencia)
) COMMENT 'N:N — curso desenvolve N competências';

CREATE TABLE pessoal_db.funcao_competencia (
    id_funcao      INT UNSIGNED NOT NULL,
    id_competencia INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_funcao, id_competencia)
) COMMENT 'N:N — função requer N competências';

-- ÍNDICES

CREATE INDEX idx_historico_func  ON pessoal_db.historico_lotacao (id_func);
CREATE INDEX idx_historico_setor ON pessoal_db.historico_lotacao (id_setor);
CREATE INDEX idx_ferias_func     ON pessoal_db.ferias             (id_func);
CREATE INDEX idx_diag_func       ON pessoal_db.diagnostico        (id_func);
CREATE INDEX idx_rex_func        ON pessoal_db.realizacao_exame   (id_func);
CREATE INDEX idx_curriculo_func  ON pessoal_db.curriculo          (id_func);

-- CHAVES ESTRANGEIRAS
-- Criadas ao final para garantir que todas as tabelas referenciadas já existam

ALTER TABLE pessoal_db.telefone
    ADD CONSTRAINT fk_tel_func FOREIGN KEY (id_func) REFERENCES pessoal_db.funcionario(id_func)
        ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE pessoal_db.endereco
    ADD CONSTRAINT fk_end_func FOREIGN KEY (id_func) REFERENCES pessoal_db.funcionario(id_func)
        ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE pessoal_db.funcionario_necessidade
    ADD CONSTRAINT fk_fn_func   FOREIGN KEY (id_func)   REFERENCES pessoal_db.funcionario(id_func)
        ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_fn_necess FOREIGN KEY (id_necess) REFERENCES pessoal_db.necessidade_especial(id_necess)
        ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE pessoal_db.obrigacao_empresa
    ADD CONSTRAINT fk_obrig_necess FOREIGN KEY (id_necess) REFERENCES pessoal_db.necessidade_especial(id_necess)
        ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE pessoal_db.dependente
    ADD CONSTRAINT fk_dep_func FOREIGN KEY (id_func) REFERENCES pessoal_db.funcionario(id_func)
        ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE pessoal_db.diagnostico
    ADD CONSTRAINT fk_diag_func   FOREIGN KEY (id_func)   REFERENCES pessoal_db.funcionario(id_func)
        ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_diag_doenca FOREIGN KEY (id_doenca) REFERENCES pessoal_db.doenca(id_doenca)
        ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE pessoal_db.realizacao_exame
    ADD CONSTRAINT fk_rex_func  FOREIGN KEY (id_func)  REFERENCES pessoal_db.funcionario(id_func)
        ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_rex_exame FOREIGN KEY (id_exame) REFERENCES pessoal_db.exame(id_exame)
        ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE pessoal_db.historico_lotacao
    ADD CONSTRAINT fk_hl_func   FOREIGN KEY (id_func)   REFERENCES pessoal_db.funcionario(id_func)
        ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_hl_setor  FOREIGN KEY (id_setor)  REFERENCES pessoal_db.setor(id_setor)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    ADD CONSTRAINT fk_hl_funcao FOREIGN KEY (id_funcao) REFERENCES pessoal_db.funcao(id_funcao)
        ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE pessoal_db.ferias
    ADD CONSTRAINT fk_fer_func FOREIGN KEY (id_func) REFERENCES pessoal_db.funcionario(id_func)
        ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE pessoal_db.curriculo
    ADD CONSTRAINT fk_curr_func FOREIGN KEY (id_func) REFERENCES pessoal_db.funcionario(id_func)
        ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE pessoal_db.curriculo_curso
    ADD CONSTRAINT fk_cc_curriculo FOREIGN KEY (id_curriculo) REFERENCES pessoal_db.curriculo(id_curriculo)
        ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_cc_curso     FOREIGN KEY (id_curso)     REFERENCES pessoal_db.curso(id_curso)
        ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE pessoal_db.curso_competencia
    ADD CONSTRAINT fk_cco_curso FOREIGN KEY (id_curso)       REFERENCES pessoal_db.curso(id_curso)
        ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_cco_comp  FOREIGN KEY (id_competencia) REFERENCES pessoal_db.competencia(id_competencia)
        ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE pessoal_db.funcao_competencia
    ADD CONSTRAINT fk_fc_funcao FOREIGN KEY (id_funcao)      REFERENCES pessoal_db.funcao(id_funcao)
        ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_fc_comp   FOREIGN KEY (id_competencia) REFERENCES pessoal_db.competencia(id_competencia)
        ON DELETE CASCADE ON UPDATE CASCADE;
```
