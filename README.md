# 🏢 Sistema de Controle de Pessoal

Projeto desenvolvido para a disciplina de **Banco de Dados**, implementando um sistema completo de controle de pessoal utilizando **MySQL 8.x**.

---

## 📋 Descrição do Cenário

As empresas têm como seu principal patrimônio as pessoas que nela trabalham. Este sistema registra funcionários com suas características pessoais, monitora sua saúde, controla dependentes, histórico de lotação, férias, qualificações e competências.

---

## 🗂️ Estrutura do Repositório

```
sistema-controle-pessoal/
├── README.md
├── sql/
│   ├── 01_criacao_banco_completo.sql
│   ├── 02_carga_dados.sql
│   └── 03_consultas.sql
└── diagramas/
    └── diagrama_MER.png
```

---

## 🗄️ Tabelas do Banco de Dados

| Tabela | Descrição |
|---|---|
| `funcionario` | Dados cadastrais do funcionário |
| `telefone` | Telefones do funcionário (1:N) |
| `endereco` | Endereços do funcionário (1:N) |
| `dependente` | Dependentes do funcionário (1:N) |
| `necessidade_especial` | Tipos de necessidades especiais |
| `funcionario_necessidade` | Relação N:N funcionário × necessidade |
| `obrigacao_empresa` | Obrigações da empresa por necessidade |
| `doenca` | Catálogo de doenças (CID-10) |
| `diagnostico` | Diagnósticos dos funcionários (N:N) |
| `exame` | Catálogo de exames com valores de referência |
| `realizacao_exame` | Exames realizados com resultado e laudo |
| `setor` | Setores da empresa |
| `funcao` | Funções/cargos da empresa |
| `historico_lotacao` | Histórico de setor e função por funcionário |
| `ferias` | Períodos de férias dos funcionários |
| `curriculo` | Currículo do funcionário (1:1) |
| `curso` | Catálogo de cursos |
| `competencia` | Competências exigidas por função |
| `curriculo_curso` | Cursos realizados no currículo (N:N) |
| `curso_competencia` | Competências desenvolvidas por curso (N:N) |
| `funcao_competencia` | Competências exigidas por função (N:N) |

---

## ⚙️ Regras de Negócio Implementadas

- **Trigger `trg_ferias_limite_30pct`** — impede que mais de 30% da força de trabalho de um setor entre de férias simultaneamente
- **Histórico de lotação** — registra todos os setores e funções pelos quais o funcionário passou, com datas de início e fim
- **Laudo ocupacional** — campo `apto` em `realizacao_exame` indica se o funcionário está APTO ou INAPTO
- **Dependente universitário** — campo `universitario` controla a dependência para fins de imposto de renda até 24 anos

---

## 📊 Consultas Implementadas

1. **Relatório geral** — funcionários, setor, função e laudo do último exame ocupacional
2. **Funcionários aptos** — estado civil, dependentes, doador de órgãos e último valor de glicose
3. **Qualificação por função** — escolaridade, competências exigidas x possuídas e aptidão
4. **Férias mês a mês** — funcionários iniciando férias e percentual do setor em férias

---

## 🚀 Como Executar

1. Certifique-se de ter o **MySQL 8.x** instalado
2. Execute os scripts na seguinte ordem:

```bash
# 1. Criação do banco e tabelas
mysql -u root -p < sql/01_criacao_banco_completo.sql

# 2. Carga de dados
mysql -u root -p < sql/02_carga_dados.sql

# 3. Consultas
mysql -u root -p pessoal_db < sql/03_consultas.sql
```

Ou abra cada arquivo no **MySQL Workbench** e execute na ordem acima.

---

## 🛠️ Tecnologias

- MySQL 8.x
- MySQL Workbench

---

## 👨‍💻 Autor

Desenvolvido como trabalho prático da disciplina de Banco de Dados.