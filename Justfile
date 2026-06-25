DB := "chips.db"
CSV := "chips.csv"
DEPOT_JSON := "depot.json"
DEPOT_CSV := "depot.csv"

[default]
default:
    @just --list

convert-depot-json:
    jq -r -f json2csv.jq "{{DEPOT_JSON}}" > "{{CSV}}"

convert-depot-csv:
    duckdb -csv -f depot2chips.sql "{{DEPOT_CSV}}" > "{{CSV}}"

import-csv:
    duckdb "{{CSV}}" -cmd "ATTACH '{{DB}}' AS chips_db" -f chips_import.sql

export-csv:
    duckdb -csv "{{DB}}" -c "SELECT * FROM chips" > "{{CSV}}"

# update job type increment:
#     sqlite3 "{{DB}}" "UPDATE chips SET 数量 = 数量 {{increment}} WHERE 职业 = '{{job}}' AND 芯片类型 = '{{type}}'"
#     sqlite3 "{{DB}}" "SELECT * FROM chips WHERE 职业 = '{{job}}' AND 芯片类型 = '{{type}}'"

group-query:
    duckdb "{{CSV}}" -f group_query.sql

short-query:
    duckdb "{{CSV}}" -f short_query.sql

raw-query type:
    duckdb "{{CSV}}" -c "SELECT * FROM file WHERE 芯片类型 = '{{type}}' ORDER BY 数量 DESC"
