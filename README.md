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

## 导入和导出

## 更新数据
