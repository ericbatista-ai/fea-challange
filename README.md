# FEA Challenge — AdventureWorks (dbt + Databricks)

Pipeline medallion para o desafio de formação:

1. **Raw** — Extract-Load do PostgreSQL local → Unity Catalog `adventureworks.raw`
2. **Staging / Intermediate / Marts** — transformações dbt (próximas etapas)
3. **Análises** — queries exploratórias no Databricks / pasta `analyses/`

## Arquitetura

```
PostgreSQL (localhost)
  schemas: person, production, humanresources, purchasing, sales
        │
        ▼  scripts/load_raw_to_databricks.py
Databricks Unity Catalog
  adventureworks.raw.{schema}_{table}
  ex.: person_address, sales_salesorderheader
        │
        ▼  dbt source('adventureworks_raw', ...)
  staging → intermediate → marts
```



## Pré-requisitos

- Docker AdventureWorks rodando (`adventureworks-db` na porta 5432)
- Credenciais Databricks em `../.env` (ou `FEA/.env`)
- Python 3.10+ e dbt com adapter Databricks

```bash
# Postgres (a partir de Indicium/adventureworks/AdventureWorks)
docker compose up -d

# Python EL
cd FEA
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
```



## Variáveis de ambiente

Use `FEA/.env`. dbt Fusion / a extensão VS Code carregam automaticamente variáveis com prefixo `DBT_`.

```bash
# Obrigatórias para dbt (profiles.yml)
DBT_DATABRICKS_HOST=...
DBT_DATABRICKS_HTTP_PATH=...
DBT_DATABRICKS_TOKEN=...
DBT_DATABRICKS_CATALOG=adventureworks
DBT_DATABRICKS_SCHEMA=raw
```

No Catalog Explorer: selecione o catálogo `adventureworks` → schema `raw`.


| Variável           | Uso                                             |
| ------------------ | ----------------------------------------------- |
| `DBT_DATABRICKS_*` | Profile dbt (Fusion / LSP)                      |
| `DATABRICKS_*`     | Script EL (`scripts/load_raw_to_databricks.py`) |
| `POSTGRES_*`       | Fonte OLTP local                                |




## 1) Land raw layer

```bash
source .venv/bin/activate
python scripts/load_raw_to_databricks.py
```

O script lê `FEA/.env`. Cria catalog/schema e materializa as **68 tabelas** com prefixo do schema de origem.

## 2) dbt

```bash
dbt debug --profiles-dir .
dbt ls --profiles-dir . --select source:adventureworks_raw
```

Sources declarados em `models/raw/_adventureworks_raw__sources.yml`.
Staging e marts entram nas próximas etapas do desafio.