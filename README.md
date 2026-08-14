# 结构化数据处理

本项目学习如何使用 SQL 进行结构化数据处理。

用到的工具为 DuckDB。如果可以，最好也安装一下 Just。

## 目录

- [数据准备](#数据准备)
- [简单查询](#简单查询)
- [过滤和排序](#过滤和排序)
- [脚本和变量](#脚本和变量)
- [导入和导出](#导入和导出)
- [更新](#更新)
- [复杂查询](#复杂查询)
- [数据转换](#数据转换)

本文使用的操作都在 [Justfile](Justfile) 中提供了对应的快捷命令。

## 数据准备

数据源于《明日方舟》的仓库，使用 MAA 的 `小工具 > 仓库识别` 功能将仓库中的数据导出为 CSV 文件。

示例文件为 [data/depot.sample.csv](data/depot.sample.csv)。不建议直接修改这份示例文件，请拷贝一份用于后续的教程。

```sh
cp data/depot.sample.csv data/depot.csv
```

## 简单查询

查询使用 `SELECT`

```sql
SELECT *
FROM file
```

其中 `SELECT *` 表示选取所有字段，`FROM file` 表示从给定的文件中读取。

DuckDB 可以在命令中指定文件

```sh
duckdb data/depot.csv -c "SELECT * FROM file"
```

改为 `SELECT name` 后表示只输出 `name` 字段

```sh
duckdb data/depot.csv -c "SELECT name FROM file"
```

添加 `LIMIT 10` 限制输出的条目数量

```sh
duckdb data/depot.csv -c "SELECT * FROM file LIMIT 10"
```

## 过滤和排序

### 过滤

`depot.csv` 中的数据条目很多，但我们只关心感兴趣的数据——芯片。因此我们要对数据进行过滤。

过滤使用 `WHERE`

```sql
SELECT *
FROM file
WHERE name LIKE '先锋%'
```

其中 `WHERE name LIKE '先锋%'` 表示只有当 `name` 字段匹配以 `先锋` 开头的字符串时，才输出这个条目

```sh
duckdb data/depot.csv -c "SELECT * FROM file WHERE name LIKE '先锋%'"
```

同理，使用 `LIKE '%芯片组'` 表示匹配以 `芯片组` 结尾的字符串

```sh
duckdb data/depot.csv -c "SELECT * FROM file WHERE name LIKE '%芯片组'"
```

### 排序

排序使用 `ORDER BY`

```sql
SELECT *
FROM file
WHERE name LIKE '%芯片组'
ORDER BY count
```

其中 `ORDER BY count` 表示按 `count` 的大小排序

```sh
duckdb data/depot.csv -c "SELECT * FROM file WHERE name LIKE '%芯片组' ORDER BY count"
```

排序默认为升序，等价为 `ORDER BY count ASC`。使用 `DESC` 改为降序

```sh
duckdb data/depot.csv -c "SELECT * FROM file WHERE name LIKE '%芯片组' ORDER BY count DESC"
```

DuckDB 支持修改默认的排序方式

```sql
SET default_order = 'DESC'
```

不过这涉及到变量。在此之前，我们先讲一下脚本。

## 脚本和变量

### 脚本

现在命令已经开始有点长了。我们可以把 SQL 脚本保存为文件，然后在命令中通过 `-f` 参数指定

```sh
duckdb data/depot.csv -f sql/preview_depot.sql
```

也可以一次执行多个脚本

```sh
duckdb data/depot.csv -f sql/preview_depot.sql -f sql/query_chips.sql
```

### 变量

目前脚本中的内容都是硬编码的，每调整一下命令都要修改脚本，查询起来很不方便。

DuckDB 支持变量功能。

使用 `getvariable()` 获取变量

```sql
SELECT *
FROM file
WHERE name LIKE getvariable('filter')
ORDER BY count
```

使用 `SET VARIABLE` 定义变量

```sql
SET VARIABLE filter = '%芯片'
```

DuckDB 可以在执行脚本前通过 `-cmd` 参数先执行一些命令，我们可以在此处定义变量的值

```sh
duckdb data/depot.csv -cmd "SET VARIABLE filter = '%芯片'" -f sql/query_chips.sql
```

### 环境变量

DuckDB 也支持读取环境变量，在 CLI 里这通常比 `getvariable()` 更易使用。

使用 `getenv()` 获取环境变量

```sql
SELECT *
FROM file
WHERE name LIKE getenv('filter')
ORDER BY count
```

而定义环境变量的方式由使用的 Shell 决定。

在 Bash 里可以通过 `filter='%芯片'` 定义环境变量

```bash
filter='%芯片' duckdb data/depot.csv -f sql/query_chips.sql
```

在 Pwsh 里可以通过 `$env:filter='%芯片'` 定义环境变量

```pwsh
$env:filter='%芯片'; duckdb data/depot.csv -f sql/query_chips.sql
```

> [!caution]
> 目前在 Windows 上使用原生 DuckDB CLI 时，环境变量中如果包含中文等非 ASCII 字符，`getenv()` 读取时可能出现编码错误。此时建议改用 `SET VARIABLE` 和 `getvariable()`。

### 内置变量

DuckDB 有一些内置变量，这些是 DuckDB 的配置。

使用 `SET` 修改配置

```sql
SET default_order = 'DESC'
```

使用 `current_setting()` 读取配置

```sql
SELECT current_setting('default_order');
```

可以通过 `duckdb_settings()` 查询所有配置

```sql
SELECT *
FROM duckdb_settings()
```

如果终端里不方便阅读，也可以导出为 CSV 文件

```sh
duckdb --csv -c "SELECT * FROM duckdb_settings()" > duckdb.csv
```

这就是之后要提到的导入和导出功能。

## 导入和导出

### CSV 导出 CSV

之前我们一直在 `data/depot.csv` 上查询，每次都得进行过滤。其实我们也可以把需要的数据导出到另一个文件中，从而方便后续的查询。

游戏内有八种职业，分别为 `先锋`、`辅助`、`狙击`、`术师`、`近卫`、`特种`、`重装`、`医疗`；每种职业又有三种芯片，分别为 `xx芯片`、`xx芯片组`、`xx双芯片`（后文将其简称为小芯片、大芯片、双芯片）。因此，我们的目标是把芯片数据导出为如下的 CSV 格式

```csv
prof,chip_type,count
"先锋","小",5
"先锋","大",3
"先锋","双",0
"辅助","小",22
"辅助","大",13
"辅助","双",0
...
```

提取和整理芯片数据的脚本保存在 [sql/extract_chips.sql](sql/extract_chips.sql) 中。该脚本较为复杂，后续再深入研究。

使用 `--csv` 让 DuckDB 以 CSV 格式输出查询结果，再使用 Shell 的 `>` 将输出重定向到文件

```sh
duckdb data/depot.csv --csv -f sql/extract_chips.sql > data/chips.csv
```

在该文件上的查询就不再需要使用 `WHERE name LIKE '%芯片组'` 去匹配字符串了，我们可以使用语义更清晰的 `WHERE chip_type = '大'` 进行过滤

```sh
duckdb data/chips.csv -c "SELECT * FROM file WHERE chip_type = '大'"
```

### CSV 导入 DB

CSV 数据也可以导入数据库。完整的操作为，先读取 CSV 文件，然后挂载数据库，最后执行脚本

```sh
duckdb data/chips.csv \
    -cmd "ATTACH 'data/data.db' AS db" \
    -f sql/import_chips.sql
```

其中 `ATTACH 'data/data.db'` 使我们接下来可以操作 `data/data.db` 数据库，而 `AS db` 则给该数据库定义了一个便于使用的别名。

而脚本主要做两件事

1. 使用 `CREATE TABLE` 创建表

    ```sql
    CREATE TABLE db.chips (
        prof TEXT NOT NULL,
        chip_type TEXT NOT NULL,
        count INTEGER NOT NULL,
        UNIQUE (prof, chip_type)
    );
    ```

    其中 `db.chips` 表示 `db` 下的数据库表；`TEXT` 和 `INTEGER` 是定义的字段类型；`NOT NULL` 和 `UNIQUE` 是定义的约束，`NOT NULL` 用于阻止字段为空，`UNIQUE (prof, chip_type)` 用于保证职业和芯片类型的组合不会重复。

2. 使用 `INSERT INTO` 将数据写入表

    ```sql
    INSERT INTO db.chips (prof, chip_type, count)
    SELECT
        prof::TEXT,
        chip_type::TEXT,
        count::INTEGER
    FROM file;
    ```

    其中 `(prof, chip_type, count)` 指定目标字段及其写入顺序，如果省略，那就默认为全部字段，并使用创建表时字段的定义顺序；`::TEXT` 和 `::INTEGER` 用于显式转换字段类型，如果值无法转换为目标类型，语句会报错并终止。

脚本还在创建表前使用 `DROP TABLE IF EXISTS` 删除已经存在的同名表

```sql
DROP TABLE IF EXISTS db.chips;
```

不过这么做有一点风险：如果数据库中的数据已经被更新但还未导出，那么再次导入时这些数据就丢失了。

另外，同一个数据库里可以存在多张表。比如可以把 `data/depot.csv` 也导入数据库，方法是完全一样的——只要表名不重复就行。

### DB 导出 CSV

我们也可以直接在数据库上进行查询，方法和在 CSV 文件上进行查询一样，唯一的不同是 `FROM file` 要改为 `FROM chips`

```sh
duckdb data/data.db -c "SELECT * FROM chips"
```

然后，查询的结果可以重新导出为 CSV 文件

```sh
duckdb data/data.db --csv -c "SELECT * FROM chips" > data/chips.csv
```

另外，如果 SQL 脚本中已经硬编码了 `FROM file`，但希望复用相同的查询逻辑，那么可以通过 `CREATE TEMP VIEW file AS SELECT * FROM chips` 从 `chips` 表中创建一个名为 `file` 的临时视图，并通过 `-cmd` 参数让其在执行查询前先运行

```sh
duckdb data/data.db \
    -cmd "CREATE TEMP VIEW file AS SELECT * FROM chips" \
    -cmd "SET VARIABLE chip_type = '大'" \
    -f sql/query_group_chips.sql
```

## 更新

DuckDB 不方便直接在 CSV 文件上进行更新，因为一边读文件一边写文件会遇到一些问题。主要有两种解决方式

1. 先读 CSV 文件，然后把更新结果写入另一个 CSV 文件，最后再进行覆盖
2. 先将 CSV 文件导入 DuckDB 数据库，然后在数据库里进行更新，最后再把数据库中的数据导出为 CSV 文件

我们采用第二种方式（上一节讲的导入和导出就是为了第二种方式准备的）。

更新使用 `UPDATE`

```sql
UPDATE chips
SET count = count + 2
WHERE
    prof = '先锋'
    AND chip_type = '小'
RETURNING *;
```

其中

- `UPDATE chips` 表示更新 `chips` 表
- `SET count = count + 2` 表示在原有数量上 `+2`
- `WHERE prof = '先锋' AND chip_type = '小'` 表示选取同时满足 `prof = '先锋'` 和 `chip_type = '小'` 的条目
- `RETURNING` 是 DuckDB 提供的扩展功能，可用于返回被更新的数据，便于确认结果

为了让脚本便于应用在不同的职业、芯片类型和数量上，我们可以使用变量代替那些硬编码的值

```sql
UPDATE chips
SET count = count + getvariable('increment')
WHERE
    prof = getvariable('prof')
    AND chip_type = getvariable('chip_type')
RETURNING *;
```

执行脚本前同样要先通过 `-cmd` 定义变量

```sh
duckdb data/data.db \
    -cmd "SET VARIABLE prof = '先锋'" \
    -cmd "SET VARIABLE chip_type = '小'" \
    -cmd "SET VARIABLE increment = -3" \
    -f sql/update_chips.sql
```

`increment` 可以是负数，`+-3` 会被正确处理为 `-3`。不过目前表中没有限制 `count` 必须大于等于 `0`，因此更新后的值可能出现负数。

## 复杂查询

### 组合条件

查询条件可以通过 `AND` 和 `OR` 进行组合

- 使用 `AND` 表示同时满足多个条件

    ```sql
    WHERE prof = '先锋' AND chip_type = '小'
    ```

- 使用 `OR` 表示只需满足其中一个条件

    ```sql
    WHERE count < 5 OR count > 20
    ```

- `AND` 和 `OR` 还可以进行复合，使用括号来明确条件的组合方式

    ```sql
    WHERE
        (chip_type = '小' AND count < 5)
        OR (chip_type = '大' AND count < 8)
    ```

### 条件表达式

游戏内精一一个六星干员需要 `5` 个小芯片，精二一个六星干员需要 `4` 个双芯片，而每个双芯片需要 `2` 个大芯片进行合成。因此，如果我们想知道哪个职业的新六星无法立即精二，可以使用如下的查询

```sql
SELECT
    prof,
    CASE chip_type
        WHEN '双' THEN '大' ELSE chip_type
    END AS converted_chip_type,
    sum(
        count * CASE chip_type
            WHEN '双' THEN 2 ELSE 1
        END
    ) AS converted_count
FROM file
GROUP BY prof, converted_chip_type
HAVING
    (converted_chip_type = '小' AND converted_count < 5)
    OR (converted_chip_type = '大' AND converted_count < 8)
```

其中

- `CASE` 是条件表达式，当值匹配 `WHEN` 时返回 `THEN`，否则返回 `ELSE`。第一个 `CASE` 将类型 `双` 转为 `大`，第二个 `CASE` 将双芯片的数量折算为大芯片的数量
- `sum()` 是聚合函数，将折算后的双芯片数量加到大芯片数量上
- `GROUP BY` 将 `prof` 和 `converted_chip_type` 相同的数据放入同一组
- `HAVING` 用于筛选聚合后的数据

### 分组和聚合

游戏内的每个芯片副本都可能掉落两种职业的芯片，并且这两种芯片之间可以互相转换。因此，如果我们想知道分组后的芯片数量是多少，可以使用如下的查询

```sql
SELECT
    chip_type,
    CASE
        WHEN prof IN ('先锋', '辅助') THEN '先锋 + 辅助'
        WHEN prof IN ('狙击', '术师') THEN '狙击 + 术师'
        WHEN prof IN ('近卫', '特种') THEN '近卫 + 特种'
        WHEN prof IN ('重装', '医疗') THEN '重装 + 医疗'
    END AS prof_group,
    sum(count) AS group_count
FROM file
WHERE chip_type = getvariable('chip_type')
GROUP BY prof_group, chip_type
ORDER BY group_count DESC;
```

其中

- `CASE` 依次检查各个 `WHEN` 条件
- `IN` 用于判断值是否属于给定的集合
- `THEN` 用于返回对应的分组名称
- `sum()` 是聚合函数，用于计算每组的 `count` 总和
- `GROUP BY` 将 `prof_group` 和 `chip_type` 相同的数据放入同一组

## 数据转换

现在回到之前留下的 [sql/extract_chips.sql](sql/extract_chips.sql)。这个脚本把原始仓库数据转换成每个职业的小芯片、大芯片和双芯片数据。总流程可以分为三步。

### 定义公用表表达式

首先定义所有职业以及芯片类型

```sql
WITH
profs (prof, prof_sort) AS (
    VALUES
    ('先锋', 1),
    ('辅助', 2),
    ('狙击', 3),
    ('术师', 4),
    ('近卫', 5),
    ('特种', 6),
    ('重装', 7),
    ('医疗', 8)
),

chip_types (chip_type, name_suffix, type_sort) AS (
    VALUES
    ('小', '芯片', 1),
    ('大', '芯片组', 2),
    ('双', '双芯片', 3)
)
```

`profs` 定义了各职业的职业名及其顺序；`chip_types` 除了定义各芯片类型的类型名和顺序外，还定义了每种芯片在仓库物品名称中对应的后缀。

这里用到的关键字有

- `WITH` 用于定义只在当前语句中使用的公用表表达式，多个表达式之间使用逗号分隔
- `VALUES` 用于从显式给出的数据行中构造查询结果
- `AS` 用于关联公用表表达式的名称、列名和定义它的查询

### 计算笛卡尔积

接下来生成所有职业和芯片类型的组合

```sql
FROM profs
CROSS JOIN chip_types
```

`FROM profs CROSS JOIN chip_types` 会计算笛卡尔积，即把每种职业和每种芯片类型进行组合。`8` 种职业乘以 `3` 种芯片类型，一共得到 `24` 条数据。

### 进行相关标量子查询

最后查询仓库中对应的物品数量，并按之前定义的顺序进行排序

```sql
SELECT
    profs.prof,
    chip_types.chip_type,
    coalesce(
        (
            SELECT file.count
            FROM file
            WHERE file.name = profs.prof || chip_types.name_suffix
        ),
        0
    ) AS count
ORDER BY profs.prof_sort, chip_types.type_sort;
```

其中

- `||` 用于连接字符串
- `coalesce()` 返回参数中第一个不是 `NULL` 的值

括号中的 `SELECT` 是一个相关标量子查询，它引用外层查询当前行的 `profs.prof` 和 `chip_types.name_suffix`，将二者连接成完整的物品名称，再从 `file` 中查询数量。

标量子查询最多只能返回一个值，因此会出现三种情况

1. 仓库中存在一条对应记录，此时返回该记录的 `file.count`
2. 仓库中不存在对应记录，此时返回 `NULL`，再由 `coalesce(..., 0)` 将其替换为 `0`
3. 仓库中存在多条对应记录，此时相关标量子查询会报错，从而暴露出仓库中存在的重复数据

从语义上说，本示例中的仓库数据不应该有重复，所以选择相关标量子查询是合适的。
