DB := "data/data.db"
CHIPS_CSV := "data/chips.csv"
DEPOT_CSV := "data/depot.csv"

[default]
default:
    @just --list

# 简单查询
preview-depot num="10":
    duckdb "{{ DEPOT_CSV }}" \
        -cmd "SET VARIABLE num = {{ num }}" \
        -f sql/preview_depot.sql

# 过滤和排序
query-chips filter sort="ASC":
    duckdb "{{ DEPOT_CSV }}" \
        -cmd "SET VARIABLE filter = '{{ filter }}'" \
        -cmd "SET default_order = '{{ sort }}'" \
        -f sql/query_chips.sql

# 提取芯片数据
extract-chips:
    duckdb "{{ DEPOT_CSV }}" -csv \
        -f sql/extract_chips.sql > "{{ CHIPS_CSV }}"

# 查询原始的芯片数据
query-raw-chips type:
    duckdb "{{ CHIPS_CSV }}" \
        -cmd "SET VARIABLE chip_type = '{{ type }}'" \
        -f sql/query_raw_chips.sql

# 查询分组的芯片数据
query-group-chips type:
    duckdb "{{ CHIPS_CSV }}" \
        -cmd "SET VARIABLE chip_type = '{{ type }}'" \
        -f sql/query_group_chips.sql

# 查询短缺的芯片数据
query-shortage-chips:
    duckdb "{{ CHIPS_CSV }}" -f sql/query_shortage_chips.sql

# 导入芯片数据
import-chips:
    duckdb "{{ CHIPS_CSV }}" \
        -cmd "ATTACH '{{ DB }}' AS db" \
        -f sql/import_chips.sql

# 导出芯片数据
export-chips:
    duckdb "{{ DB }}" -csv \
        -f sql/export_chips.sql > "{{ CHIPS_CSV }}"

# 更新芯片数据
update-chips prof chip_type increment:
    duckdb "{{ DB }}" \
        -cmd "SET VARIABLE prof = '{{ prof }}'" \
        -cmd "SET VARIABLE chip_type = '{{ chip_type }}'" \
        -cmd "SET VARIABLE increment = {{ increment }}" \
        -f sql/update_chips.sql

# 在 DB 上查询原始芯片数据
query-raw-chips-db chip_type:
    duckdb "{{ DB }}" \
        -cmd "CREATE TEMP VIEW file AS SELECT * FROM chips" \
        -cmd "SET VARIABLE chip_type = '{{ chip_type }}'" \
        -f sql/query_raw_chips.sql

# 在 DB 上查询分组的芯片
query-group-chips-db chip_type:
    duckdb "{{ DB }}" \
        -cmd "CREATE TEMP VIEW file AS SELECT * FROM chips" \
        -cmd "SET VARIABLE chip_type = '{{ chip_type }}'" \
        -f sql/query_group_chips.sql

# 在 DB 上查询短缺的芯片
query-shortage-chips-db:
    duckdb "{{ DB }}" \
        -cmd "CREATE TEMP VIEW file AS SELECT * FROM chips" \
        -f sql/query_shortage_chips.sql
