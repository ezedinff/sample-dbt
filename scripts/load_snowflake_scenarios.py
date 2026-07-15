import argparse
import csv
import os
import sys
from pathlib import Path

import snowflake.connector


ROOT = Path(__file__).resolve().parents[1]
SCENARIO_ROOT = ROOT / "seeds" / "scenarios"
BOOTSTRAP_SQL = ROOT / "sql" / "bootstrap" / "create_raw_tables.sql"
VERIFY_SQL = ROOT / "sql" / "bootstrap" / "verify_scenario_load.sql"

SCENARIOS = (
    "baseline",
    "freshness_stale_orders",
    "completeness_missing_100_vins",
    "uniqueness_source_duplicates",
    "uniqueness_join_explosion",
)

ORDER_COLUMNS = (
    "scenario_id",
    "record_source",
    "ingest_batch_id",
    "order_id",
    "customer_id",
    "vin",
    "market",
    "order_status",
    "order_amount",
    "source_updated_at",
    "loaded_at",
)

VEHICLE_COLUMNS = (
    "scenario_id",
    "record_source",
    "ingest_batch_id",
    "vin",
    "vehicle_id",
    "make",
    "model",
    "market",
    "source_updated_at",
    "loaded_at",
)


def env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise RuntimeError(f"Missing required environment variable: {name}")
    return value


def connect():
    connection_args = {
        "account": env("SNOWFLAKE_ACCOUNT"),
        "user": env("SNOWFLAKE_USER"),
        "password": env("SNOWFLAKE_PASSWORD"),
        "role": env("SNOWFLAKE_ROLE"),
        "insecure_mode": os.getenv("SNOWFLAKE_INSECURE_MODE", "true").lower() == "true",
    }
    if os.getenv("SNOWFLAKE_HOST"):
        connection_args["host"] = os.environ["SNOWFLAKE_HOST"]
    if os.getenv("SNOWFLAKE_PORT"):
        connection_args["port"] = int(os.environ["SNOWFLAKE_PORT"])
    if os.getenv("SNOWFLAKE_PROTOCOL"):
        connection_args["protocol"] = os.environ["SNOWFLAKE_PROTOCOL"]
    return snowflake.connector.connect(**connection_args)


def read_csv(path: Path, columns: tuple[str, ...]) -> list[tuple[object, ...]]:
    if not path.exists():
        return []
    with path.open(newline="", encoding="utf-8") as handle:
        rows = list(csv.DictReader(handle))
    return [tuple(row[column] for column in columns) for row in rows]


def execute_string(connection, sql_text: str) -> None:
    connection.execute_string(sql_text)


def execute_many(cursor, sql: str, rows: list[tuple[object, ...]]) -> None:
    if rows:
        cursor.executemany(sql, rows)


def load_scenario(connection, scenario_id: str) -> tuple[int, int]:
    scenario_path = SCENARIO_ROOT / scenario_id
    if not scenario_path.exists():
        raise RuntimeError(f"Unknown scenario fixture folder: {scenario_id}")

    orders = read_csv(scenario_path / "orders.csv", ORDER_COLUMNS)
    vehicles = read_csv(scenario_path / "vehicle.csv", VEHICLE_COLUMNS)
    placeholders = ", ".join(["%s"] * len(ORDER_COLUMNS))
    vehicle_placeholders = ", ".join(["%s"] * len(VEHICLE_COLUMNS))

    cursor = connection.cursor()
    try:
        cursor.execute("DELETE FROM RAW.ORDERS WHERE scenario_id = %s", (scenario_id,))
        cursor.execute("DELETE FROM RAW.VEHICLE WHERE scenario_id = %s", (scenario_id,))
        execute_many(
            cursor,
            f"INSERT INTO RAW.ORDERS ({', '.join(ORDER_COLUMNS)}) VALUES ({placeholders})",
            orders,
        )
        execute_many(
            cursor,
            f"INSERT INTO RAW.VEHICLE ({', '.join(VEHICLE_COLUMNS)}) VALUES ({vehicle_placeholders})",
            vehicles,
        )
        cursor.execute(
            """
            INSERT INTO RAW.SCENARIO_LOAD_AUDIT
            SELECT %s, CURRENT_TIMESTAMP(), CURRENT_USER(), %s, %s
            """,
            (scenario_id, len(orders), len(vehicles)),
        )
    finally:
        cursor.close()
    return len(orders), len(vehicles)


def verify(connection) -> list[dict[str, object]]:
    cursors = connection.execute_string(VERIFY_SQL.read_text(encoding="utf-8"))
    rows: list[dict[str, object]] = []
    for cursor in cursors:
        if not cursor.description:
            continue
        columns = [_normalize_column_name(column[0]) for column in cursor.description]
        for row in cursor.fetchall():
            values = dict(zip(columns, row, strict=True))
            if {"check_name", "observed_value", "expected_value", "status"} <= set(values):
                rows.append(values)
    return rows


def print_verification(rows: list[dict[str, object]]) -> None:
    print("check_name\tobserved_value\texpected_value\tstatus")
    for row in rows:
        print(
            f"{row['check_name']}\t{row['observed_value']}\t"
            f"{row['expected_value']}\t{row['status']}"
        )


def _normalize_column_name(name: object) -> str:
    return str(name).strip().strip('"').lower()


def main() -> int:
    parser = argparse.ArgumentParser(description="Load Lighthouse scenario fixtures into Snowflake.")
    parser.add_argument(
        "--scenario",
        action="append",
        choices=SCENARIOS,
        help="Scenario to load. Repeat to load multiple. Defaults to all scenarios.",
    )
    parser.add_argument("--reset", action="store_true", help="Truncate scenario raw tables first.")
    parser.add_argument("--verify", action="store_true", help="Run verification SQL after loading.")
    args = parser.parse_args()

    selected = tuple(args.scenario or SCENARIOS)
    connection = connect()
    try:
        execute_string(connection, BOOTSTRAP_SQL.read_text(encoding="utf-8"))
        cursor = connection.cursor()
        try:
            cursor.execute("USE WAREHOUSE LIGHTHOUSE_DEV_WH")
            cursor.execute("USE DATABASE LIGHTHOUSE_DEV")
            if args.reset:
                cursor.execute("TRUNCATE TABLE RAW.ORDERS")
                cursor.execute("TRUNCATE TABLE RAW.VEHICLE")
                cursor.execute("TRUNCATE TABLE RAW.SCENARIO_LOAD_AUDIT")
        finally:
            cursor.close()

        for scenario_id in selected:
            order_count, vehicle_count = load_scenario(connection, scenario_id)
            print(f"loaded\t{scenario_id}\torders={order_count}\tvehicle={vehicle_count}")

        if args.verify:
            rows = verify(connection)
            print_verification(rows)
            failed = [row for row in rows if str(row["status"]).lower() != "pass"]
            if failed:
                return 1
    finally:
        connection.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
