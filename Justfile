DB := "date.db"
CHIPS_CSV := "chips.csv"
DEPOT_CSV := "depot.csv"

[default]
default:
    @just --list
import-depot:
    duckdb "{{ DEPOT_CSV }}" -cmd "ATTACH '{{ DB }}' AS db" -f import_depot.sql
export-depot:
    duckdb -csv "{{ DB }}" -c "SELECT * FROM depot" > "{{ DEPOT_CSV }}"
depot2chips:
    duckdb -csv -f depot2chips.sql "{{ DEPOT_CSV }}" > "{{ CHIPS_CSV }}"
import-chips:
    duckdb "{{ CHIPS_CSV }}" -cmd "ATTACH '{{ DB }}' AS db" -f import_chips.sql
export-chips:
    duckdb -csv "{{ DB }}" -c "SELECT * FROM chips" > "{{ CHIPS_CSV }}"
update-db job type increment:
    duckdb "{{ DB }}" -c "UPDATE chips SET 数量 = 数量 + {{ increment }} WHERE 职业 = '{{ job }}' AND 芯片类型 = '{{ type }}'"
    duckdb "{{ DB }}" -c "SELECT * FROM chips WHERE 职业 = '{{ job }}' AND 芯片类型 = '{{ type }}'"
group-query-db:
    duckdb "{{ DB }}" -cmd "CREATE TEMP VIEW file AS SELECT * FROM chips" -f group_query.sql
group-query-csv:
    duckdb "{{ CHIPS_CSV }}" -f group_query.sql
short-query-db:
    duckdb "{{ DB }}" -cmd "CREATE TEMP VIEW file AS SELECT * FROM chips" -f short_query.sql
short-query-csv:
    duckdb "{{ CHIPS_CSV }}" -f short_query.sql
raw-query-db type:
    duckdb "{{ DB }}" -c "SELECT * FROM chips WHERE 芯片类型 = '{{ type }}' ORDER BY 数量 DESC"
raw-query-csv type:
    duckdb "{{ CHIPS_CSV }}" -c "SELECT * FROM file WHERE 芯片类型 = '{{ type }}' ORDER BY 数量 DESC"
