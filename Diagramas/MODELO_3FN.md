# Modelo Entidade-Relacionamento — 3ª Forma Normal (3FN)

## Cenário 3 — Sistema de Controle de Pessoal

### Normalização aplicada

| Forma | Aplicação no projeto |
|-------|----------------------|
| **1FN** | Todos os atributos são atômicos (telefones e endereços em tabelas próprias, não em listas no funcionário). |
| **2FN** | Tabelas associativas (`funcionario_necessidade`, `diagnostico`, `curriculo_curso`, etc.) têm chave composta quando necessário; atributos dependem da chave inteira. |
| **3FN** | Não há dependências transitivas: obrigações dependem de `necessidade_especial`, não de `funcionario`; competências de função em `funcao_competencia`; competências de curso em `curso_competencia`. |

### Entidades principais

1. **funcionario** — dados cadastrais (nome, CPF, tipo sanguíneo, estado civil, doador de órgãos).
2. **telefone / endereco** — relacionamento 1:N com funcionário.
3. **necessidade_especial → obrigacao_empresa** — necessidades e obrigações da empresa (1:N).
4. **dependente** — dependentes com regra de universitário até 24 anos (`chk_dep_universitario_idade`).
5. **doenca → diagnostico** — monitoramento de saúde (N:N com data).
6. **exame → realizacao_exame** — exames ocupacionais com valores de referência e laudo APTO/INAPTO.
7. **setor, funcao, historico_lotacao** — histórico de lotação com datas de início e fim.
8. **ferias** — períodos de férias; limite de 30% por setor via trigger.
9. **curriculo, curso, competencia** — currículo, cursos realizados e competências exigidas por função.

### Diagrama visual

- **Mermaid (editável):** `diagrama_MER.mmd` — abra em [mermaid.live](https://mermaid.live) para exportar PNG.
- **Imagem:** `diagrama_MER.png` (versão para entrega impressa/PDF).

### Scripts SQL (ordem de execução)

1. `sql/01_criacao_tabelas.sql` — tabelas sem FKs  
2. `sql/02_foreign_keys.sql` — chaves estrangeiras  
3. `sql/03_triggers_indices.sql` — regras de negócio e índices  
4. `sql/04_carga_dados.sql` — dados de teste  
5. `sql/05_consultas.sql` — quatro relatórios obrigatórios  
