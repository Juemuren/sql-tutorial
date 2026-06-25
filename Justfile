DB := "chips.db"
DATA := "chips.csv"
DEPOT_JSON := "depot.json"
DEPOT_CSV := "depot.csv"

[default]
default:
    @just --list

convert-depot-json:
    jq -r -f json2csv.jq "{{DEPOT_JSON}}" > "{{DATA}}"

convert-depot-csv:
    duckdb -csv -f depot2chips.sql "{{DEPOT_CSV}}" > "{{DATA}}"

import-data:
    duckdb "{{DATA}}" -cmd "ATTACH '{{DB}}' AS chips_db" -f chips_import.sql

export-data:
    duckdb -csv "{{DB}}" -c "SELECT * FROM chips" > "{{DATA}}"

update-db job type increment:
    duckdb "{{DB}}" -c "UPDATE chips SET 数量 = 数量 + {{increment}} WHERE 职业 = '{{job}}' AND 芯片类型 = '{{type}}'"
    duckdb "{{DB}}" -c "SELECT * FROM chips WHERE 职业 = '{{job}}' AND 芯片类型 = '{{type}}'"

group-query-db:
    duckdb "{{DB}}" -cmd "CREATE TEMP VIEW file AS SELECT * FROM chips" -f group_query.sql

group-query-data:
    duckdb "{{DATA}}" -f group_query.sql

short-query-db:
    duckdb "{{DB}}" -cmd "CREATE TEMP VIEW file AS SELECT * FROM chips" -f short_query.sql

short-query-data:
    duckdb "{{DATA}}" -f short_query.sql

raw-query-db type:
    duckdb "{{DB}}" -c "SELECT * FROM chips WHERE 芯片类型 = '{{type}}' ORDER BY 数量 DESC"

raw-query-data type:
    duckdb "{{DATA}}" -c "SELECT * FROM file WHERE 芯片类型 = '{{type}}' ORDER BY 数量 DESC"
