-- ============================================================
--  ETAPA 2: Chaves estrangeiras (FKs separadas das tabelas)
--  Sistema de Controle de Pessoal — MySQL 8.x
-- ============================================================

USE pessoal_db;

-- BLOCO 1 — Dados pessoais
ALTER TABLE telefone
    ADD CONSTRAINT fk_tel_func
        FOREIGN KEY (id_func) REFERENCES funcionario(id_func)
        ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE endereco
    ADD CONSTRAINT fk_end_func
        FOREIGN KEY (id_func) REFERENCES funcionario(id_func)
        ON DELETE CASCADE ON UPDATE CASCADE;

-- BLOCO 2 — Necessidade especial
ALTER TABLE funcionario_necessidade
    ADD CONSTRAINT fk_fn_func
        FOREIGN KEY (id_func) REFERENCES funcionario(id_func)
        ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_fn_necess
        FOREIGN KEY (id_necess) REFERENCES necessidade_especial(id_necess)
        ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE obrigacao_empresa
    ADD CONSTRAINT fk_obrig_necess
        FOREIGN KEY (id_necess) REFERENCES necessidade_especial(id_necess)
        ON DELETE CASCADE ON UPDATE CASCADE;

-- BLOCO 3 — Dependente
ALTER TABLE dependente
    ADD CONSTRAINT fk_dep_func
        FOREIGN KEY (id_func) REFERENCES funcionario(id_func)
        ON DELETE CASCADE ON UPDATE CASCADE;

-- BLOCO 4 — Saúde: doença
ALTER TABLE diagnostico
    ADD CONSTRAINT fk_diag_func
        FOREIGN KEY (id_func) REFERENCES funcionario(id_func)
        ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_diag_doenca
        FOREIGN KEY (id_doenca) REFERENCES doenca(id_doenca)
        ON DELETE RESTRICT ON UPDATE CASCADE;

-- BLOCO 5 — Exame ocupacional
ALTER TABLE realizacao_exame
    ADD CONSTRAINT fk_rex_func
        FOREIGN KEY (id_func) REFERENCES funcionario(id_func)
        ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_rex_exame
        FOREIGN KEY (id_exame) REFERENCES exame(id_exame)
        ON DELETE RESTRICT ON UPDATE CASCADE;

-- BLOCO 6 — Organização
ALTER TABLE historico_lotacao
    ADD CONSTRAINT fk_hl_func
        FOREIGN KEY (id_func) REFERENCES funcionario(id_func)
        ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_hl_setor
        FOREIGN KEY (id_setor) REFERENCES setor(id_setor)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    ADD CONSTRAINT fk_hl_funcao
        FOREIGN KEY (id_funcao) REFERENCES funcao(id_funcao)
        ON DELETE RESTRICT ON UPDATE CASCADE;

-- BLOCO 7 — Férias
ALTER TABLE ferias
    ADD CONSTRAINT fk_fer_func
        FOREIGN KEY (id_func) REFERENCES funcionario(id_func)
        ON DELETE CASCADE ON UPDATE CASCADE;

-- BLOCO 8 — Currículo e competências
ALTER TABLE curriculo
    ADD CONSTRAINT fk_curr_func
        FOREIGN KEY (id_func) REFERENCES funcionario(id_func)
        ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE curriculo_curso
    ADD CONSTRAINT fk_cc_curriculo
        FOREIGN KEY (id_curriculo) REFERENCES curriculo(id_curriculo)
        ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_cc_curso
        FOREIGN KEY (id_curso) REFERENCES curso(id_curso)
        ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE curso_competencia
    ADD CONSTRAINT fk_cco_curso
        FOREIGN KEY (id_curso) REFERENCES curso(id_curso)
        ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_cco_comp
        FOREIGN KEY (id_competencia) REFERENCES competencia(id_competencia)
        ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE funcao_competencia
    ADD CONSTRAINT fk_fc_funcao
        FOREIGN KEY (id_funcao) REFERENCES funcao(id_funcao)
        ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_fc_comp
        FOREIGN KEY (id_competencia) REFERENCES competencia(id_competencia)
        ON DELETE CASCADE ON UPDATE CASCADE;
