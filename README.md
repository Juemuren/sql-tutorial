# 结构化数据处理

一个用于学习基于 SQL 进行结构化数据处理的项目。

用到的工具为 Bash 和 DuckDB。如果可以，最好也安装一下 Just。

## 目录

- [简单查询](#简单查询)
- [过滤和排序](#过滤和排序)
- [脚本和变量](#脚本和变量)
- [导入和导出](#导入和导出)
- [更新数据](#更新数据)

## 数据准备

数据源于《明日方舟》的仓库，使用 MAA 的 `小工具 > 仓库识别` 功能将仓库中的数据导出为 CSV 文件。

示例文件为 [data/depot.sample.csv](data/depot.sample.csv)。不建议直接修改这份示例文件。请拷贝一份用于后续的修改。

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

DuckDB 可以在命令中指定文件。完整的命令为

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

而定义环境变量的方式由使用的 Shell 决定。在 Bash 里通过 `filter="'%芯片'"` 定义环境变量

```sh
filter="'%芯片'" duckdb data/depot.csv -f sql/query_chips.sql
```

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

## 更新数据
