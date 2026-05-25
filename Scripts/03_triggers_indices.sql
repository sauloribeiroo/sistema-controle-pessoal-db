-- ============================================================
--  ETAPA 3: Triggers, regras de negócio e índices
--  Sistema de Controle de Pessoal — MySQL 8.x
-- ============================================================

USE pessoal_db;

-- ------------------------------------------------------------
-- Regra: no máximo 30% da força de trabalho do setor em férias
-- (conta o novo registro na validação)
-- ------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_ferias_limite_30pct_ins;
DROP TRIGGER IF EXISTS trg_ferias_limite_30pct_upd;

DELIMITER $$

CREATE TRIGGER trg_ferias_limite_30pct_ins
BEFORE INSERT ON ferias
FOR EACH ROW
BEGIN
    DECLARE v_id_setor    INT UNSIGNED;
    DECLARE v_total_setor INT;
    DECLARE v_em_ferias   INT;
    DECLARE v_pct         DECIMAL(5,4);

    SELECT id_setor INTO v_id_setor
    FROM historico_lotacao
    WHERE id_func = NEW.id_func AND data_fim IS NULL
    LIMIT 1;

    IF v_id_setor IS NOT NULL THEN
        SELECT COUNT(*) INTO v_total_setor
        FROM historico_lotacao
        WHERE id_setor = v_id_setor AND data_fim IS NULL;

        SELECT COUNT(DISTINCT f.id_func) INTO v_em_ferias
        FROM ferias f
        JOIN historico_lotacao hl ON hl.id_func = f.id_func
        WHERE hl.id_setor = v_id_setor
          AND hl.data_fim IS NULL
          AND f.data_inicio <= NEW.data_fim
          AND f.data_fim    >= NEW.data_inicio;

        SET v_pct = (v_em_ferias + 1) / v_total_setor;

        IF v_total_setor > 0 AND v_pct > 0.30 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Limite de 30% da força do setor em férias seria ultrapassado.';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_ferias_limite_30pct_upd
BEFORE UPDATE ON ferias
FOR EACH ROW
BEGIN
    DECLARE v_id_setor    INT UNSIGNED;
    DECLARE v_total_setor INT;
    DECLARE v_em_ferias   INT;
    DECLARE v_pct         DECIMAL(5,4);

    SELECT id_setor INTO v_id_setor
    FROM historico_lotacao
    WHERE id_func = NEW.id_func AND data_fim IS NULL
    LIMIT 1;

    IF v_id_setor IS NOT NULL THEN
        SELECT COUNT(*) INTO v_total_setor
        FROM historico_lotacao
        WHERE id_setor = v_id_setor AND data_fim IS NULL;

        SELECT COUNT(DISTINCT f.id_func) INTO v_em_ferias
        FROM ferias f
        JOIN historico_lotacao hl ON hl.id_func = f.id_func
        WHERE hl.id_setor = v_id_setor
          AND hl.data_fim IS NULL
          AND f.id_ferias <> OLD.id_ferias
          AND f.data_inicio <= NEW.data_fim
          AND f.data_fim    >= NEW.data_inicio;

        SET v_pct = (v_em_ferias + 1) / v_total_setor;

        IF v_total_setor > 0 AND v_pct > 0.30 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Limite de 30% da força do setor em férias seria ultrapassado.';
        END IF;
    END IF;
END$$

DELIMITER ;

-- ------------------------------------------------------------
-- Índices complementares
-- ------------------------------------------------------------

CREATE INDEX idx_historico_func  ON historico_lotacao (id_func);
CREATE INDEX idx_historico_setor ON historico_lotacao (id_setor);
CREATE INDEX idx_ferias_func     ON ferias (id_func);
CREATE INDEX idx_ferias_periodo    ON ferias (data_inicio, data_fim);
CREATE INDEX idx_diag_func       ON diagnostico (id_func);
CREATE INDEX idx_rex_func        ON realizacao_exame (id_func);
CREATE INDEX idx_rex_func_data   ON realizacao_exame (id_func, dt_realizacao);
CREATE INDEX idx_curriculo_func  ON curriculo (id_func);
