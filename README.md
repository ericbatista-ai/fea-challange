# FEA Challenge — AdventureWorks (dbt + Databricks)

Pipeline medallion para o desafio de formação:

1. **Raw** — Extract-Load do PostgreSQL local → Unity Catalog `adventureworks.raw`
2. **Staging / Intermediate / Marts** — transformações dbt
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
  ex.: dim_customer (adventureworks.marts)
```

## Pré-requisitos

- Docker AdventureWorks rodando (`adventureworks-db` na porta 5432)
- Credenciais Databricks em `.env`
- Python 3.10+ e dbt com adapter Databricks (ou dbt Cloud / Fusion)

```bash
# Postgres (a partir de Indicium/adventureworks/AdventureWorks)
docker compose up -d

# Python EL
python -m venv .venv
# Windows: .\.venv\Scripts\Activate.ps1
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
```

## Variáveis de ambiente

Use `.env`. dbt Fusion / a extensão VS Code carregam automaticamente variáveis com prefixo `DBT_`.

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
# activate venv first
python scripts/load_raw_to_databricks.py
```

O script lê `.env`. Cria catalog/schema e materializa as **68 tabelas** com prefixo do schema de origem.

## 2) dbt

```bash
dbt debug --profiles-dir .
dbt deps
dbt ls --profiles-dir . --select source:adventureworks_raw
dbt build --profiles-dir . --select +dim_customer
dbt build --profiles-dir . --select dim_date
```

- Sources: `models/raw/_adventureworks_raw__sources.yml`
- Domains: `models/staging|intermediate|marts/{customer,geography,product,credit_card,sales_reason,date,sales}/` + `marts/bridges/`
- Packages: `packages.yml` (`dbt_utils`) — run `dbt deps` once after clone/pull
- Schemas de saída: `staging`, `intermediate`, `marts` (via `dbt_project.yml` + `generate_schema_name`)
- Audit: `tests/assert_gross_sales_2011.sql` — 2011 net sales = **12,641,672.21** (Postgres source); brief’s 12,646,112.16 does not match this dataset
