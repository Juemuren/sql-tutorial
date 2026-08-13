DROP TABLE IF EXISTS db.chips;

-- 创建表
CREATE TABLE db.chips (
    prof TEXT NOT NULL,
    chip_type TEXT NOT NULL,
    count INTEGER NOT NULL,
    UNIQUE (prof, chip_type)
);

-- 导入数据
INSERT INTO db.chips (prof, chip_type, count)
SELECT
    prof::TEXT,
    chip_type::TEXT,
    count::INTEGER
FROM file;
