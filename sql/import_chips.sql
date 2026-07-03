DROP TABLE IF EXISTS db.chips;

-- 创建表
CREATE TABLE db.chips (
    职业 TEXT NOT NULL,
    芯片类型 TEXT NOT NULL,
    数量 INTEGER NOT NULL,
    UNIQUE (职业, 芯片类型)
);

-- 导入数据
INSERT INTO db.chips
SELECT
    "职业"::TEXT AS 职业,
    "芯片类型"::TEXT AS 芯片类型,
    "数量"::INTEGER AS 数量
FROM file;
