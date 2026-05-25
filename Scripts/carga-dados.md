# 02 — Carga de Dados

Script de INSERT para popular todas as tabelas do banco `pessoal_db`.

```sql
--  SCRIPT DE CARGA DE DADOS — Sistema de Controle de Pessoal

USE pessoal_db;
SET FOREIGN_KEY_CHECKS = 0;

-- FUNCIONÁRIO

INSERT INTO funcionario (id_func, nome, cpf, dt_nascimento, tipo_sanguineo, email, estado_civil, doador_orgaos) VALUES
(1,  'Ana Paula Ferreira',   '12345678901', '1985-03-12', 'A+',  'ana.ferreira@empresa.com',     'casado',        1),
(2,  'Carlos Eduardo Lima',  '23456789012', '1990-07-25', 'O+',  'carlos.lima@empresa.com',      'solteiro',      0),
(3,  'Fernanda Costa',       '34567890123', '1978-11-05', 'B-',  'fernanda.costa@empresa.com',   'casado',        1),
(4,  'Roberto Alves Souza',  '45678901234', '1995-01-18', 'AB+', 'roberto.souza@empresa.com',    'solteiro',      0),
(5,  'Juliana Martins',      '56789012345', '1988-06-30', 'O-',  'juliana.martins@empresa.com',  'divorciado',    1),
(6,  'Marcos Antonio Silva', '67890123456', '1982-09-14', 'A-',  'marcos.silva@empresa.com',     'casado',        0),
(7,  'Patricia Oliveira',    '78901234567', '1993-04-22', 'B+',  'patricia.oliveira@empresa.com','solteiro',      1),
(8,  'Ricardo Gomes',        '89012345678', '1975-12-03', 'O+',  'ricardo.gomes@empresa.com',    'casado',        0),
(9,  'Camila Rodrigues',     '90123456789', '1998-08-17', 'A+',  'camila.rodrigues@empresa.com', 'solteiro',      1),
(10, 'Diego Henrique Nunes', '01234567890', '1987-02-28', 'AB-', 'diego.nunes@empresa.com',      'uniao_estavel', 0);

-- TELEFONE

INSERT INTO telefone (id_func, numero, tipo) VALUES
(1,  '85991110001', 'celular'),
(1,  '8533330001',  'residencial'),
(2,  '85992220002', 'celular'),
(3,  '85993330003', 'celular'),
(3,  '8533330003',  'residencial'),
(4,  '85994440004', 'celular'),
(5,  '85995550005', 'celular'),
(6,  '85996660006', 'celular'),
(6,  '8533330006',  'comercial'),
(7,  '85997770007', 'celular'),
(8,  '85998880008', 'celular'),
(9,  '85999990009', 'celular'),
(10, '85900000010', 'celular'),
(10, '8533330010',  'residencial');

-- ENDEREÇO

INSERT INTO endereco (id_func, logradouro, numero, bairro, cidade, uf, cep) VALUES
(1,  'Rua das Flores',         '123', 'Meireles',        'Fortaleza', 'CE', '60160050'),
(2,  'Av. Beira Mar',          '456', 'Meireles',        'Fortaleza', 'CE', '60165121'),
(3,  'Rua Castro e Silva',     '789', 'Centro',          'Fortaleza', 'CE', '60030010'),
(4,  'Rua Tiburcio Cavalcante','321', 'Dionisio Torres', 'Fortaleza', 'CE', '60125100'),
(5,  'Av. Washington Soares',  '654', 'Edson Queiroz',   'Fortaleza', 'CE', '60811905'),
(6,  'Rua Dr. Jose Lourenco',  '987', 'Aldeota',         'Fortaleza', 'CE', '60115281'),
(7,  'Av. Santos Dumont',      '147', 'Aldeota',         'Fortaleza', 'CE', '60150160'),
(8,  'Rua Osvaldo Cruz',       '258', 'Benfica',         'Fortaleza', 'CE', '60020060'),
(9,  'Rua Barbosa de Freitas', '369', 'Aldeota',         'Fortaleza', 'CE', '60170020'),
(10, 'Av. Dom Luis',           '741', 'Meireles',        'Fortaleza', 'CE', '60160230');

-- NECESSIDADE ESPECIAL E OBRIGAÇÃO DA EMPRESA

INSERT INTO necessidade_especial (id_necess, descricao) VALUES
(1, 'Cadeirante - mobilidade reduzida de membros inferiores'),
(2, 'Deficiencia visual parcial'),
(3, 'Deficiencia auditiva'),
(4, 'Deficiencia visual total'),
(5, 'Mobilidade reduzida - uso de muletas');

INSERT INTO obrigacao_empresa (id_necess, descricao) VALUES
(1, 'Instalacao de rampas de acesso em todas as entradas'),
(1, 'Banheiros adaptados para cadeirantes'),
(1, 'Elevadores com espaco para cadeira de rodas'),
(2, 'Softwares com suporte a leitores de tela (NVDA, JAWS)'),
(2, 'Documentos disponiveis em fontes ampliadas'),
(3, 'Interprete de LIBRAS disponivel em reunioes'),
(3, 'Sistema de alertas visuais (alarmes, notificacoes)'),
(4, 'Softwares de leitura de tela completos'),
(4, 'Materiais em Braille ou audio'),
(5, 'Estacionamento com vagas reservadas proximas a entrada');

INSERT INTO funcionario_necessidade (id_func, id_necess) VALUES
(3, 1),
(6, 2),
(8, 3);

-- DEPENDENTE

INSERT INTO dependente (id_func, nome, tipo_dep, dt_nascimento, universitario) VALUES
(1,  'Lucas Ferreira',     'filho(a)', '2010-05-10', 0),
(1,  'Joao Paulo Ferreira','conjuge',  '1983-08-22', 0),
(3,  'Rodrigo Costa',      'conjuge',  '1976-01-30', 0),
(3,  'Beatriz Costa',      'filho(a)', '2004-11-05', 1),
(5,  'Pedro Martins',      'filho(a)', '2002-07-19', 1),
(5,  'Larissa Martins',    'filho(a)', '2008-12-01', 0),
(6,  'Helena Silva',       'conjuge',  '1980-04-15', 0),
(8,  'Andre Gomes',        'filho(a)', '2005-09-25', 1),
(10, 'Isabela Nunes',      'conjuge',  '1989-06-11', 0);

-- DOENÇA E DIAGNÓSTICO

INSERT INTO doenca (id_doenca, nome, cid, descricao) VALUES
(1, 'Diabetes Mellitus Tipo 2', 'E11', 'Disturbio metabolico com hiperglicemia cronica'),
(2, 'Hipertensao Arterial',     'I10', 'Pressao arterial sistematicamente elevada'),
(3, 'Lombalgia Cronica',        'M54', 'Dor lombar de carater cronico'),
(4, 'Ansiedade Generalizada',   'F41', 'Transtorno de ansiedade generalizada'),
(5, 'Hipotireoidismo',          'E03', 'Producao insuficiente de hormonios da tireoide'),
(6, 'Rinite Alergica',          'J30', 'Inflamacao da mucosa nasal por alergia');

INSERT INTO diagnostico (id_func, id_doenca, dt_diagnostico, observacao) VALUES
(1,  1, '2018-04-10', 'Diabetes controlada com metformina'),
(1,  2, '2020-01-15', 'Hipertensao leve, acompanhamento semestral'),
(3,  3, '2019-07-22', 'Lombalgia decorrente da paraplegia'),
(5,  4, '2021-03-05', 'Em tratamento com psicologa'),
(6,  2, '2017-11-30', 'Hipertensao controlada com medicacao'),
(8,  5, '2016-09-18', 'Hipotireoidismo em tratamento com levotiroxina'),
(10, 4, '2022-06-14', 'Episodios de ansiedade relacionados ao trabalho'),
(2,  6, '2023-02-28', 'Rinite alergica sazonal, uso de antialergico');

-- EXAME E REALIZAÇÃO DE EXAME

INSERT INTO exame (id_exame, nome, val_ref_min, val_ref_max, unidade) VALUES
(1, 'Glicemia em Jejum',          70.000,  99.000, 'mg/dL'),
(2, 'Pressao Arterial Sistolica', 90.000, 120.000, 'mmHg'),
(3, 'Colesterol Total',            0.000, 190.000, 'mg/dL'),
(4, 'Triglicerideos',              0.000, 150.000, 'mg/dL'),
(5, 'TSH (Tireoide)',              0.400,   4.000, 'mUI/L'),
(6, 'Hemoglobina',                12.000,  17.500, 'g/dL');

INSERT INTO realizacao_exame (id_func, id_exame, dt_realizacao, resultado, observacao, apto) VALUES
(1, 1, '2023-01-10', 126.000, 'Glicemia elevada, ajuste de medicacao', 0),
(1, 1, '2023-07-10', 108.000, 'Melhora apos ajuste, ainda acima',      0),
(1, 2, '2023-01-10', 135.000, 'PA levemente elevada',                  0),
(1, 2, '2024-01-10', 118.000, 'PA controlada, apto',                   1),
(2, 1, '2023-03-15',  88.000, 'Normal',                                1),
(2, 3, '2023-03-15', 175.000, 'Colesterol dentro do limite',           1),
(3, 1, '2023-05-20',  92.000, 'Normal',                                1),
(3, 2, '2023-05-20', 115.000, 'Normal',                                1),
(4, 1, '2023-06-10',  85.000, 'Normal',                                1),
(4, 6, '2023-06-10',  14.500, 'Normal',                                1),
(5, 1, '2023-04-18',  94.000, 'Normal',                                1),
(5, 4, '2023-04-18', 130.000, 'Triglicerideos dentro do limite',       1),
(6, 2, '2023-02-22', 145.000, 'PA elevada, inapto temporariamente',    0),
(6, 2, '2024-02-22', 118.000, 'PA controlada, apto',                   1),
(6, 1, '2024-02-22',  96.000, 'Glicemia normal',                       1),
(7, 1, '2023-08-05',  80.000, 'Normal',                                1),
(7, 3, '2023-08-05', 165.000, 'Colesterol dentro do limite',           1),
(8, 5, '2023-09-12',   6.800, 'TSH acima do limite, inapto',           0),
(8, 5, '2024-03-12',   3.200, 'TSH normalizado, apto',                 1),
(8, 1, '2024-03-12',  91.000, 'Glicemia normal',                       1),
(9, 1, '2023-10-01',  78.000, 'Normal',                                1),
(9, 6, '2023-10-01',  13.800, 'Normal',                                1),
(10, 1, '2023-11-15',  89.000, 'Normal',                               1),
(10, 4, '2023-11-15', 178.000, 'Triglicerideos elevados, monitorar',   0),
(10, 4, '2024-05-15', 142.000, 'Triglicerideos reduzidos, apto',       1);

-- SETOR

INSERT INTO setor (id_setor, nome, descricao) VALUES
(1, 'Tecnologia da Informacao', 'Desenvolvimento e infraestrutura de sistemas'),
(2, 'Recursos Humanos',         'Gestao de pessoas e beneficios'),
(3, 'Financeiro',               'Contabilidade, faturamento e tesouraria'),
(4, 'Operacoes',                'Logistica e operacoes internas');

-- FUNÇÃO

INSERT INTO funcao (id_funcao, nome, descricao) VALUES
(1, 'Desenvolvedor de Software', 'Desenvolvimento e manutencao de sistemas'),
(2, 'Analista de RH',            'Recrutamento, selecao e gestao de pessoas'),
(3, 'Gestor',                    'Lideranca de equipe e gestao de processos'),
(4, 'Analista Financeiro',       'Analise e controle financeiro'),
(5, 'Tecnico de Suporte',        'Suporte tecnico a usuarios e sistemas'),
(6, 'Auxiliar Administrativo',   'Atividades administrativas gerais');

-- HISTÓRICO DE LOTAÇÃO

INSERT INTO historico_lotacao (id_func, id_setor, id_funcao, data_inicio, data_fim) VALUES
(1,  2, 2, '2015-03-01', '2020-06-30'),
(1,  2, 3, '2020-07-01', NULL),
(2,  1, 1, '2019-08-01', NULL),
(3,  3, 6, '2010-01-10', '2018-12-31'),
(3,  2, 2, '2019-01-02', NULL),
(4,  1, 5, '2021-02-15', NULL),
(5,  3, 4, '2016-05-01', NULL),
(6,  1, 1, '2012-04-01', '2019-12-31'),
(6,  1, 3, '2020-01-01', NULL),
(7,  2, 2, '2022-03-01', NULL),
(8,  4, 3, '2008-06-01', NULL),
(9,  1, 1, '2023-01-10', NULL),
(10, 3, 4, '2014-09-01', '2021-08-31'),
(10, 3, 3, '2021-09-01', NULL);

-- FÉRIAS

INSERT INTO ferias (id_func, data_inicio, data_fim, qtd_dias) VALUES
(1,  '2024-01-15', '2024-02-04', 21),
(2,  '2024-02-01', '2024-02-20', 20),
(6,  '2024-03-10', '2024-03-29', 20),
(5,  '2024-04-01', '2024-04-30', 30),
(8,  '2024-05-05', '2024-05-24', 20),
(3,  '2024-06-10', '2024-06-29', 20),
(10, '2024-07-01', '2024-07-20', 20),
(4,  '2024-08-12', '2024-08-31', 20),
(7,  '2024-09-02', '2024-09-21', 20),
(9,  '2024-10-07', '2024-10-26', 20),
(1,  '2025-01-06', '2025-01-25', 20),
(2,  '2025-03-03', '2025-03-22', 20),
(5,  '2025-05-05', '2025-05-24', 20),
(6,  '2025-07-07', '2025-07-26', 20),
(8,  '2025-09-01', '2025-09-20', 20);

-- COMPETÊNCIA

INSERT INTO competencia (id_competencia, nome, descricao) VALUES
(1, 'Programacao orientada a objetos', 'Conhecimento em POO com linguagens modernas'),
(2, 'Banco de dados relacional',       'Modelagem e consultas SQL'),
(3, 'Gerencia de pessoas',             'Lideranca, feedbacks e gestao de conflitos'),
(4, 'Recrutamento e selecao',          'Tecnicas de entrevista e triagem de candidatos'),
(5, 'Analise financeira',              'Interpretacao de balancetes e DRE'),
(6, 'Suporte tecnico',                 'Resolucao de problemas de hardware e software'),
(7, 'Legislacao trabalhista',          'Conhecimento em CLT e normas regulamentadoras'),
(8, 'Gestao de projetos',              'Metodologias ageis e classicas de gestao');

-- CURSO

INSERT INTO curso (id_curso, nome) VALUES
(1,  'Java Avancado'),
(2,  'MySQL para DBAs'),
(3,  'Lideranca e Gestao de Equipes'),
(4,  'Tecnicas de Entrevista'),
(5,  'Analise de Demonstracoes Financeiras'),
(6,  'Suporte e Manutencao de Computadores'),
(7,  'CLT na Pratica'),
(8,  'Scrum e Kanban'),
(9,  'Python para Data Science'),
(10, 'Excel Avancado para Financas');

-- CURSO × COMPETÊNCIA

INSERT INTO curso_competencia (id_curso, id_competencia) VALUES
(1, 1), (1, 2), (2, 2), (3, 3), (3, 8),
(4, 4), (4, 7), (5, 5), (6, 6), (7, 7),
(8, 8), (8, 3), (9, 1), (10, 5);

-- FUNÇÃO × COMPETÊNCIA

INSERT INTO funcao_competencia (id_funcao, id_competencia) VALUES
(1, 1), (1, 2), (2, 4), (2, 7), (3, 3),
(3, 8), (4, 5), (5, 6), (5, 2), (6, 7);

-- CURRÍCULO

INSERT INTO curriculo (id_curriculo, id_func, nivel_escolaridade) VALUES
(1,  1,  'pos_graduacao'),
(2,  2,  'superior_completo'),
(3,  3,  'superior_completo'),
(4,  4,  'superior_incompleto'),
(5,  5,  'superior_completo'),
(6,  6,  'mestrado'),
(7,  7,  'superior_completo'),
(8,  8,  'pos_graduacao'),
(9,  9,  'superior_incompleto'),
(10, 10, 'superior_completo');

-- CURRÍCULO × CURSO

INSERT INTO curriculo_curso (id_curriculo, id_curso, data_inicio, data_fim, carga_horaria) VALUES
(1, 3,  '2018-02-01', '2018-04-30', 60),
(1, 4,  '2016-06-01', '2016-07-15', 40),
(1, 7,  '2017-03-01', '2017-04-01', 30),
(2, 1,  '2020-01-10', '2020-03-10', 80),
(2, 2,  '2021-05-01', '2021-06-30', 60),
(2, 9,  '2022-08-01', '2022-10-01', 60),
(3, 4,  '2019-02-01', '2019-03-15', 40),
(3, 7,  '2020-01-05', '2020-02-05', 30),
(4, 6,  '2022-03-01', '2022-04-30', 50),
(5, 5,  '2017-07-01', '2017-09-01', 60),
(5, 10, '2018-02-01', '2018-03-01', 30),
(6, 3,  '2015-01-05', '2015-03-05', 60),
(6, 8,  '2016-04-01', '2016-05-15', 40),
(6, 1,  '2013-01-01', '2013-03-01', 80),
(7, 4,  '2021-09-01', '2021-10-15', 40),
(7, 7,  '2022-01-10', '2022-02-10', 30),
(8, 3,  '2010-03-01', '2010-05-01', 60),
(9, 1,  '2022-06-01', '2022-08-31', 80),
(10, 5, '2013-04-01', '2013-06-01', 60),
(10, 3, '2019-01-01', '2019-03-01', 60),
(10, 8, '2020-06-01', '2020-07-15', 40);

SET FOREIGN_KEY_CHECKS = 1;
```