# DB := "chips.db"
CSV := "chips.csv"
JSON := "depot.json"

[default]
default:
    @just --list

import-json:
    python json2csv.py "{{JSON}}" "{{CSV}}"

# import-csv:
#     rm -f "{{DB}}"
#     sqlite3 "{{DB}}" < chips_import.sql

# export-csv:
#     sqlite3 -header -csv "{{DB}}" "SELECT * FROM chips" > "{{CSV}}"

# query:
#     sqlite3 "{{DB}}" < chips_query.sql

# update job type increment:
#     sqlite3 "{{DB}}" "UPDATE chips SET 数量 = 数量 {{increment}} WHERE 职业 = '{{job}}' AND 芯片类型 = '{{type}}'"
#     sqlite3 "{{DB}}" "SELECT * FROM chips WHERE 职业 = '{{job}}' AND 芯片类型 = '{{type}}'"

group-query:
    duckdb "{{CSV}}" -f group_query.sql

short-query:
    duckdb "{{CSV}}" -f short_query.sql

raw-query type:
    duckdb "{{CSV}}" -c "SELECT * FROM file WHERE 芯片类型 = '{{type}}' ORDER BY 数量 DESC"
