#!/usr/bin/env python3
"""
Extract-Load: AdventureWorks (PostgreSQL local) → Databricks Unity Catalog raw.

Destination pattern:
  catalog  = adventureworks
  schema   = raw
  tables   = {source_schema}_{table_name}
             e.g. person_address, sales_salesorderheader

Uses Databricks SDK Statement Execution API with batched INSERTs.
(Avoids Files API / volume PUT — FEA workspace PAT often lacks `files` scope.)

Usage (from FEA project root):
  source .venv/bin/activate
  python scripts/load_raw_to_databricks.py
"""

from __future__ import annotations

import math
import os
import re
import sys
import time
import warnings
from datetime import date, datetime
from decimal import Decimal
from pathlib import Path

import pandas as pd
import psycopg2
from databricks.sdk import WorkspaceClient
from databricks.sdk.service.sql import State, StatementState
from dotenv import load_dotenv

SOURCE_SCHEMAS = (
    "person",
    "production",
    "humanresources",
    "purchasing",
    "sales",
)

# Keep SQL statement size under warehouse limits
INSERT_BATCH_SIZE = 250

# Optional: comma-separated schema.table filters, e.g.
#   ONLY_TABLES=person.password,production.product python scripts/load_raw_to_databricks.py
ONLY_TABLES = {
    item.strip().lower()
    for item in os.getenv("ONLY_TABLES", "").split(",")
    if item.strip()
}

PROJECT_ROOT = Path(__file__).resolve().parents[1]
# Parent .env first (shared), then FEA/.env overrides (this project's workspace).
load_dotenv(PROJECT_ROOT.parent / ".env")
load_dotenv(PROJECT_ROOT / ".env", override=True)

def _env(*names: str, default: str | None = None) -> str | None:
    for name in names:
        value = os.getenv(name)
        if value:
            return value
    return default


PG_HOST = _env("POSTGRES_HOST", default="localhost")
PG_PORT = int(_env("POSTGRES_PORT", default="5432"))
PG_DB = _env("POSTGRES_DB", default="adventureworks")
PG_USER = _env("POSTGRES_USER", default="adventureworks")
PG_PASSWORD = _env("POSTGRES_PASSWORD", default="adventureworks")

DATABRICKS_HOST = (
    _env("DBT_DATABRICKS_HOST", "DATABRICKS_HOST") or ""
).replace("https://", "").rstrip("/")
DATABRICKS_HTTP_PATH = _env("DBT_DATABRICKS_HTTP_PATH", "DATABRICKS_HTTP_PATH") or ""
DATABRICKS_TOKEN = _env("DBT_DATABRICKS_TOKEN", "DATABRICKS_TOKEN") or ""
CATALOG = _env("DBT_DATABRICKS_CATALOG", "DATABRICKS_CATALOG", default="adventureworks")
RAW_SCHEMA = _env(
    "DATABRICKS_RAW_SCHEMA", "DBT_DATABRICKS_SCHEMA", "DATABRICKS_SCHEMA", default="raw"
)


def require_env() -> None:
    missing = [
        name
        for name, value in {
            "DATABRICKS_HOST": DATABRICKS_HOST,
            "DATABRICKS_HTTP_PATH": DATABRICKS_HTTP_PATH,
            "DATABRICKS_TOKEN": DATABRICKS_TOKEN,
        }.items()
        if not value
    ]
    if missing:
        raise SystemExit(f"Missing required env vars: {', '.join(missing)}")


def warehouse_id() -> str:
    match = re.search(r"/warehouses/([a-f0-9]+)", DATABRICKS_HTTP_PATH)
    if not match:
        raise SystemExit("Could not parse warehouse id from DATABRICKS_HTTP_PATH")
    return match.group(1)


def workspace_client() -> WorkspaceClient:
    return WorkspaceClient(host=f"https://{DATABRICKS_HOST}", token=DATABRICKS_TOKEN)


def ensure_sql_warehouse_running(client: WorkspaceClient, wid: str) -> None:
    warehouse = client.warehouses.get(id=wid)
    print(f"SQL Warehouse state: {warehouse.state}", flush=True)
    if warehouse.state == State.RUNNING:
        return

    print("Starting SQL Warehouse...", flush=True)
    client.warehouses.start(id=wid)
    for attempt in range(60):
        time.sleep(5)
        warehouse = client.warehouses.get(id=wid)
        print(f"  [{attempt}] {warehouse.state}", flush=True)
        if warehouse.state == State.RUNNING:
            return
        if warehouse.state == State.STOPPED:
            client.warehouses.start(id=wid)

    raise SystemExit(f"SQL Warehouse did not become RUNNING (last state={warehouse.state})")


def run_sql(client: WorkspaceClient, wid: str, statement: str, timeout: str = "50s"):
    result = client.statement_execution.execute_statement(
        warehouse_id=wid,
        statement=statement,
        wait_timeout=timeout,
    )
    # wait_timeout "0s" = async; poll until terminal state (no hard 5min wall).
    while result.status.state in {StatementState.PENDING, StatementState.RUNNING}:
        time.sleep(2)
        result = client.statement_execution.get_statement(result.statement_id)

    if result.status.state != StatementState.SUCCEEDED:
        error = result.status.error
        message = getattr(error, "message", None) or str(error) or result.status.state
        raise RuntimeError(message)
    return result


def list_source_tables(pg_conn) -> list[tuple[str, str]]:
    with pg_conn.cursor() as cur:
        cur.execute(
            """
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_schema = ANY(%s)
              AND table_type = 'BASE TABLE'
            ORDER BY table_schema, table_name
            """,
            (list(SOURCE_SCHEMAS),),
        )
        return [(row[0], row[1]) for row in cur.fetchall()]


def extract_table(pg_conn, schema: str, table: str) -> pd.DataFrame:
    query = f'SELECT * FROM "{schema}"."{table}"'
    with warnings.catch_warnings():
        warnings.filterwarnings("ignore", message="pandas only supports SQLAlchemy")
        df = pd.read_sql_query(query, pg_conn)
    df.columns = [str(c).strip().lower() for c in df.columns]
    return df


def ensure_databricks_objects(client: WorkspaceClient, wid: str) -> None:
    run_sql(client, wid, f"CREATE CATALOG IF NOT EXISTS `{CATALOG}`")
    run_sql(client, wid, f"CREATE SCHEMA IF NOT EXISTS `{CATALOG}`.`{RAW_SCHEMA}`")


def spark_type(dtype, series: pd.Series) -> str:
    if pd.api.types.is_bool_dtype(dtype):
        return "BOOLEAN"
    if pd.api.types.is_integer_dtype(dtype):
        return "BIGINT"
    if pd.api.types.is_float_dtype(dtype):
        return "DOUBLE"
    if pd.api.types.is_datetime64_any_dtype(dtype):
        return "TIMESTAMP"
    # Detect bytes columns stored as object
    sample = series.dropna().head(20)
    if len(sample) and all(isinstance(v, (bytes, memoryview, bytearray)) for v in sample):
        return "BINARY"
    return "STRING"


def sql_literal(value) -> str:
    # Catch pandas/numpy nulls (incl. NaT) before type-specific formatting
    try:
        if value is None or pd.isna(value):
            return "NULL"
    except (TypeError, ValueError):
        pass

    if isinstance(value, pd.Timestamp):
        return f"TIMESTAMP '{value.isoformat(sep=' ', timespec='microseconds')}'"
    if isinstance(value, datetime):
        return f"TIMESTAMP '{value.isoformat(sep=' ', timespec='microseconds')}'"
    if isinstance(value, date):
        return f"DATE '{value.isoformat()}'"
    if isinstance(value, (bytes, bytearray, memoryview)):
        hex_str = bytes(value).hex()
        return f"X'{hex_str}'"
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    if isinstance(value, (int,)):
        return str(value)
    if isinstance(value, float):
        if math.isnan(value) or math.isinf(value):
            return "NULL"
        return repr(value)
    if isinstance(value, Decimal):
        return str(value)
    # strings / everything else
    text = str(value)
    if text in {"NaT", "NaN", "None", "<NA>"}:
        return "NULL"
    text = text.replace("\\", "\\\\").replace("'", "''")
    return f"'{text}'"


def create_empty_table(client: WorkspaceClient, wid: str, target_table: str, df: pd.DataFrame) -> None:
    full_name = f"`{CATALOG}`.`{RAW_SCHEMA}`.`{target_table}`"
    cols = []
    for col in df.columns:
        cols.append(f"`{col}` {spark_type(df[col].dtype, df[col])}")
    cols.append("`_loaded_at` TIMESTAMP")
    col_sql = ",\n  ".join(cols)
    run_sql(client, wid, f"CREATE OR REPLACE TABLE {full_name} (\n  {col_sql}\n)")


def insert_batch(
    client: WorkspaceClient,
    wid: str,
    target_table: str,
    columns: list[str],
    rows: list[tuple],
) -> None:
    full_name = f"`{CATALOG}`.`{RAW_SCHEMA}`.`{target_table}`"
    col_list = ", ".join(f"`{c}`" for c in columns) + ", `_loaded_at`"
    values_sql = []
    for row in rows:
        literals = ", ".join(sql_literal(v) for v in row)
        values_sql.append(f"({literals}, current_timestamp())")
    statement = (
        f"INSERT INTO {full_name} ({col_list})\nVALUES\n"
        + ",\n".join(values_sql)
    )
    run_sql(client, wid, statement, timeout="0s")


def load_one(
    pg_conn,
    client: WorkspaceClient,
    wid: str,
    schema: str,
    table: str,
) -> int:
    target_table = f"{schema}_{table}"
    print(
        f"  → {schema}.{table}  =>  {CATALOG}.{RAW_SCHEMA}.{target_table}",
        flush=True,
    )

    df = extract_table(pg_conn, schema, table)
    # Replace NaN with None for clean NULL literals
    df = df.where(pd.notnull(df), None)
    row_count = len(df)

    create_empty_table(client, wid, target_table, df)

    if row_count == 0:
        print("     (empty table created, 0 rows)", flush=True)
        return 0

    columns = list(df.columns)
    records = [tuple(row) for row in df.itertuples(index=False, name=None)]

    for start in range(0, row_count, INSERT_BATCH_SIZE):
        batch = records[start : start + INSERT_BATCH_SIZE]
        insert_batch(client, wid, target_table, columns, batch)
        done = min(start + INSERT_BATCH_SIZE, row_count)
        if done == row_count or done % (INSERT_BATCH_SIZE * 20) == 0:
            print(f"     … {done:,}/{row_count:,}", flush=True)

    print(f"     loaded {row_count:,} rows", flush=True)
    return row_count


def main() -> int:
    require_env()
    wid = warehouse_id()
    client = workspace_client()

    print(f"Source Postgres: {PG_USER}@{PG_HOST}:{PG_PORT}/{PG_DB}", flush=True)
    print(f"Target Databricks: {CATALOG}.{RAW_SCHEMA}.* via {DATABRICKS_HOST}", flush=True)

    ensure_sql_warehouse_running(client, wid)
    ensure_databricks_objects(client, wid)

    pg_conn = psycopg2.connect(
        host=PG_HOST,
        port=PG_PORT,
        dbname=PG_DB,
        user=PG_USER,
        password=PG_PASSWORD,
    )
    pg_conn.autocommit = True

    tables = list_source_tables(pg_conn)
    if ONLY_TABLES:
        tables = [(s, t) for s, t in tables if f"{s}.{t}" in ONLY_TABLES]
        missing = ONLY_TABLES - {f"{s}.{t}" for s, t in tables}
        if missing:
            print(f"WARNING: ONLY_TABLES not found: {sorted(missing)}", flush=True)
    print(f"Found {len(tables)} tables in schemas {SOURCE_SCHEMAS}", flush=True)

    total_rows = 0
    failures: list[str] = []

    for schema, table in tables:
        try:
            total_rows += load_one(pg_conn, client, wid, schema, table)
        except Exception as exc:  # noqa: BLE001
            msg = f"{schema}.{table}: {exc}"
            failures.append(msg)
            print(f"     ERROR: {exc}", flush=True)

    pg_conn.close()

    print("\n=== Summary ===", flush=True)
    print(f"Tables attempted : {len(tables)}", flush=True)
    print(f"Tables failed    : {len(failures)}", flush=True)
    print(f"Total rows loaded: {total_rows:,}", flush=True)

    if failures:
        print("\nFailures:", flush=True)
        for failure in failures:
            print(f"  - {failure}", flush=True)
        return 1

    print("\nRaw landing completed successfully.", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
