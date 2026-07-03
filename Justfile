DB := "data/data.db"
CHIPS_CSV := "data/chips.csv"
DEPOT_CSV := "data/depot.csv"

[default]
default:
    @just --list
# 预览数据
preview limit="10":
    duckdb "{{ DEPOT_CSV }}" -c "SELECT * FROM file LIMIT {{ limit }}"
# 导入仓库数据
import-depot:
    duckdb "{{ DEPOT_CSV }}" -cmd "ATTACH '{{ DB }}' AS db" -f sql/import_depot.sql
# 导出仓库数据
export-depot:
    duckdb -csv "{{ DB }}" -c "SELECT * FROM depot" > "{{ DEPOT_CSV }}"
# 提取芯片数据
extract-chips:
    duckdb -csv -f sql/extract_chips.sql "{{ DEPOT_CSV }}" > "{{ CHIPS_CSV }}"
# 导入芯片数据
import-chips:
    duckdb "{{ CHIPS_CSV }}" -cmd "ATTACH '{{ DB }}' AS db" -f sql/import_chips.sql
# 导出芯片数据
export-chips:
    duckdb -csv "{{ DB }}" -c "SELECT * FROM chips" > "{{ CHIPS_CSV }}"
# 更新芯片数据
update-chips job type increment:
    duckdb "{{ DB }}" -c "UPDATE chips SET 数量 = 数量 + {{ increment }} WHERE 职业 = '{{ job }}' AND 芯片类型 = '{{ type }}'"
    duckdb "{{ DB }}" -c "SELECT * FROM chips WHERE 职业 = '{{ job }}' AND 芯片类型 = '{{ type }}'"
# 在 DB 上查询分组的芯片
query-group-chips-db:
    duckdb "{{ DB }}" -cmd "CREATE TEMP VIEW file AS SELECT * FROM chips" -f sql/query_group_chips.sql
# 在 CSV 上查询分组的芯片
query-group-chips-csv:
    duckdb "{{ CHIPS_CSV }}" -f sql/query_group_chips.sql
# 在 DB 上查询短缺的芯片
query-short-chips-db:
    duckdb "{{ DB }}" -cmd "CREATE TEMP VIEW file AS SELECT * FROM chips" -f sql/query_short_chips.sql
# 在 CSV 上查询短缺的芯片
query-short-chips-csv:
    duckdb "{{ CHIPS_CSV }}" -f sql/query_short_chips.sql
# 在 DB 上查询原始芯片数据
query-raw-chips-db type:
    duckdb "{{ DB }}" -c "SELECT * FROM chips WHERE 芯片类型 = '{{ type }}' ORDER BY 数量 DESC"
# 在 CSV 上查询原始芯片数据
query-raw-chips-csv type:
    duckdb "{{ CHIPS_CSV }}" -c "SELECT * FROM file WHERE 芯片类型 = '{{ type }}' ORDER BY 数量 DESC"
