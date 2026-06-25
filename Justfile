DB := "chips.db"
CHIPS := "chips.csv"
DEPOT := "depot.csv"

[default]
default:
    @just --list
depot2chips:
    duckdb -csv -f depot2chips.sql "{{ DEPOT }}" > "{{ CHIPS }}"
import-chips:
    duckdb "{{ CHIPS }}" -cmd "ATTACH '{{ DB }}' AS chips_db" -f import_chips.sql
export-chips:
    duckdb -csv "{{ DB }}" -c "SELECT * FROM chips" > "{{ CHIPS }}"
update-db job type increment:
    duckdb "{{ DB }}" -c "UPDATE chips SET 数量 = 数量 + {{ increment }} WHERE 职业 = '{{ job }}' AND 芯片类型 = '{{ type }}'"
    duckdb "{{ DB }}" -c "SELECT * FROM chips WHERE 职业 = '{{ job }}' AND 芯片类型 = '{{ type }}'"
group-query-db:
    duckdb "{{ DB }}" -cmd "CREATE TEMP VIEW file AS SELECT * FROM chips" -f group_query.sql
group-query-csv:
    duckdb "{{ CHIPS }}" -f group_query.sql
short-query-db:
    duckdb "{{ DB }}" -cmd "CREATE TEMP VIEW file AS SELECT * FROM chips" -f short_query.sql
short-query-csv:
    duckdb "{{ CHIPS }}" -f short_query.sql
raw-query-db type:
    duckdb "{{ DB }}" -c "SELECT * FROM chips WHERE 芯片类型 = '{{ type }}' ORDER BY 数量 DESC"
raw-query-csv type:
    duckdb "{{ CHIPS }}" -c "SELECT * FROM file WHERE 芯片类型 = '{{ type }}' ORDER BY 数量 DESC"
