DROP TABLE IF EXISTS db.depot;

-- 创建表
CREATE TABLE db.depot (
    id TEXT NOT NULL,
    name TEXT NOT NULL,
    count INTEGER NOT NULL,
    UNIQUE (id)
);

-- 导入数据
INSERT INTO db.depot
SELECT
    "ID"::TEXT AS id,
    "Name"::TEXT AS name,
    "Count"::INTEGER AS count
FROM file;
