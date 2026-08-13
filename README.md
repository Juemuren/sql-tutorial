# 结构化数据处理

一个用于学习基于 SQL 进行结构化数据处理的项目。

用到的工具为 Bash 和 DuckDB。如果可以，最好也安装一下 Just。

## 目录

- [简单查询](#简单查询)
- [过滤和排序](#过滤和排序)
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
SELECT * FROM file
```

其中 `*` 表示输出所有字段，`FROM file` 表示从给定的文件中读取。

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

## 导入和导出

## 更新数据
