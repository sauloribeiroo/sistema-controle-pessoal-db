# 03 — Consultas

As 4 consultas principais do sistema de controle de pessoal.

---

## Consulta 1 — Relatório Geral de Funcionários

Lista todos os funcionários com setor, função e laudo da última consulta ocupacional (APTO ou INAPTO).

```sql
SELECT
    f.id_func                                      AS "ID",
    f.nome                                         AS "Funcionario",
    s.nome                                         AS "Setor",
    fn.nome                                        AS "Funcao",
    IF(ultimo_exame.apto = 1, 'APTO', 'INAPTO')   AS "Laudo Ocupacional",
    ultimo_exame.dt_realizacao                     AS "Data do Ultimo Exame"
FROM funcionario f
JOIN historico_lotacao hl  ON hl.id_func  = f.id_func  AND hl.data_fim IS NULL
JOIN setor             s   ON s.id_setor  = hl.id_setor
JOIN funcao            fn  ON fn.id_funcao = hl.id_funcao
JOIN (
    SELECT
        re.id_func,
        re.apto,
        re.dt_realizacao
    FROM realizacao_exame re
    INNER JOIN (
        SELECT id_func, MAX(dt_realizacao) AS ultima_data
        FROM realizacao_exame
        GROUP BY id_func
    ) ult ON ult.id_func = re.id_func AND ult.ultima_data = re.dt_realizacao
) AS ultimo_exame ON ultimo_exame.id_func = f.id_func
ORDER BY s.nome, f.nome;
```

---

## Consulta 2 — Funcionários Aptos com Dados Pessoais

Funcionários APTOS no último exame, com estado civil, dependentes, doador de órgãos e último valor de glicose.

```sql
SELECT
    f.nome                                             AS "Funcionario",
    f.estado_civil                                     AS "Estado Civil",
    IF(f.doador_orgaos = 1, 'Sim', 'Nao')             AS "Doador de Orgaos",
    IFNULL(dep.dependentes, 'Sem dependentes')         AS "Dependentes",
    IFNULL(glicose.resultado, 'Sem registro')          AS "Ultimo Valor de Glicose (mg/dL)",
    glicose.dt_realizacao                              AS "Data da Glicose"
FROM funcionario f
JOIN (
    SELECT re.id_func
    FROM realizacao_exame re
    INNER JOIN (
        SELECT id_func, MAX(dt_realizacao) AS ultima_data
        FROM realizacao_exame
        GROUP BY id_func
    ) ult ON ult.id_func = re.id_func AND ult.ultima_data = re.dt_realizacao
    WHERE re.apto = 1
) AS aptos ON aptos.id_func = f.id_func
LEFT JOIN (
    SELECT
        id_func,
        GROUP_CONCAT(
            CONCAT(nome, ' (', tipo_dep, ')')
            ORDER BY nome
            SEPARATOR ' | '
        ) AS dependentes
    FROM dependente
    GROUP BY id_func
) AS dep ON dep.id_func = f.id_func
LEFT JOIN (
    SELECT re.id_func, re.resultado, re.dt_realizacao
    FROM realizacao_exame re
    INNER JOIN (
        SELECT id_func, MAX(dt_realizacao) AS ultima_data
        FROM realizacao_exame
        WHERE id_exame = 1
        GROUP BY id_func
    ) ult ON ult.id_func = re.id_func AND ult.ultima_data = re.dt_realizacao
    WHERE re.id_exame = 1
) AS glicose ON glicose.id_func = f.id_func
ORDER BY f.nome;
```

---

## Consulta 3 — Qualificação dos Funcionários por Função

Lista escolaridade, função e se o funcionário possui todas as competências exigidas para a função que exerce.

```sql
SELECT
    f.nome                                                     AS "Funcionario",
    c.nivel_escolaridade                                       AS "Escolaridade",
    fn.nome                                                    AS "Funcao",
    IFNULL(exigidas.competencias, 'Nenhuma exigida')           AS "Competencias Exigidas",
    IFNULL(possui.competencias, 'Nenhuma registrada')          AS "Competencias Possuidas",
    IF(
        exigidas.total IS NULL OR exigidas.total = 0
        OR exigidas.total = possui.total_cobertas,
        'SIM', 'NAO'
    )                                                          AS "Apto pela Qualificacao?"
FROM funcionario f
JOIN historico_lotacao hl ON hl.id_func  = f.id_func AND hl.data_fim IS NULL
JOIN funcao            fn ON fn.id_funcao = hl.id_funcao
JOIN curriculo          c ON c.id_func   = f.id_func
LEFT JOIN (
    SELECT
        fc.id_funcao,
        COUNT(fc.id_competencia)                       AS total,
        GROUP_CONCAT(comp.nome ORDER BY comp.nome SEPARATOR ' | ') AS competencias
    FROM funcao_competencia fc
    JOIN competencia comp ON comp.id_competencia = fc.id_competencia
    GROUP BY fc.id_funcao
) AS exigidas ON exigidas.id_funcao = fn.id_funcao
LEFT JOIN (
    SELECT
        cur.id_func,
        hl2.id_funcao,
        COUNT(DISTINCT cc2.id_competencia)             AS total_cobertas,
        GROUP_CONCAT(
            DISTINCT comp2.nome ORDER BY comp2.nome SEPARATOR ' | '
        )                                              AS competencias
    FROM curriculo cur
    JOIN historico_lotacao  hl2 ON hl2.id_func    = cur.id_func AND hl2.data_fim IS NULL
    JOIN curriculo_curso     cc  ON cc.id_curriculo = cur.id_curriculo
    JOIN curso_competencia   cc2 ON cc2.id_curso    = cc.id_curso
    JOIN competencia        comp2 ON comp2.id_competencia = cc2.id_competencia
    WHERE EXISTS (
        SELECT 1 FROM funcao_competencia fc2
        WHERE fc2.id_funcao      = hl2.id_funcao
          AND fc2.id_competencia = cc2.id_competencia
    )
    GROUP BY cur.id_func, hl2.id_funcao
) AS possui ON possui.id_func = f.id_func AND possui.id_funcao = fn.id_funcao
ORDER BY fn.nome, f.nome;
```

---

## Consulta 4 — Férias Mês a Mês por Setor

Lista mês a mês os funcionários iniciando férias com o percentual do setor em férias no período.

```sql
SELECT
    DATE_FORMAT(fer.data_inicio, '%Y-%m')          AS "Ano/Mes",
    DATE_FORMAT(fer.data_inicio, '%M/%Y')          AS "Periodo",
    f.nome                                         AS "Funcionario",
    s.nome                                         AS "Setor",
    fn.nome                                        AS "Funcao",
    fer.data_inicio                                AS "Inicio Ferias",
    fer.data_fim                                   AS "Fim Ferias",
    fer.qtd_dias                                   AS "Dias",
    total_setor.total                              AS "Total no Setor",
    em_ferias.qtd                                  AS "Em Ferias no Setor",
    CONCAT(
        ROUND((em_ferias.qtd / total_setor.total) * 100, 1),
        '%'
    )                                              AS "% do Setor em Ferias"
FROM ferias fer
JOIN funcionario       f   ON f.id_func   = fer.id_func
JOIN historico_lotacao hl  ON hl.id_func  = f.id_func AND hl.data_fim IS NULL
JOIN setor             s   ON s.id_setor  = hl.id_setor
JOIN funcao            fn  ON fn.id_funcao = hl.id_funcao
JOIN (
    SELECT id_setor, COUNT(*) AS total
    FROM historico_lotacao
    WHERE data_fim IS NULL
    GROUP BY id_setor
) AS total_setor ON total_setor.id_setor = hl.id_setor
JOIN (
    SELECT
        hl2.id_setor,
        fer2.data_inicio,
        COUNT(*) AS qtd
    FROM ferias fer2
    JOIN historico_lotacao hl2 ON hl2.id_func = fer2.id_func AND hl2.data_fim IS NULL
    GROUP BY hl2.id_setor, fer2.data_inicio
) AS em_ferias ON em_ferias.id_setor    = hl.id_setor
              AND em_ferias.data_inicio = fer.data_inicio
ORDER BY DATE_FORMAT(fer.data_inicio, '%Y-%m'), s.nome, f.nome;
```