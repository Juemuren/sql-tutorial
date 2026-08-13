DROP TABLE IF EXISTS db.depot;

-- 创建表
CREATE TABLE db.depot (
    id TEXT NOT NULL,
    name TEXT NOT NULL,
    count INTEGER NOT NULL,
    UNIQUE (id)
);

-- 导入数据
INSERT INTO db.depot (id, name, count)
SELECT
    "ID"::TEXT,
    "Name"::TEXT,
    "Count"::INTEGER
FROM file;
