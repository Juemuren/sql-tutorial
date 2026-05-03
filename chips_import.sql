-- 创建表
CREATE TABLE IF NOT EXISTS chips (
    职业 TEXT NOT NULL,
    芯片类型 TEXT NOT NULL,
    数量 INTEGER NOT NULL,
    UNIQUE(职业, 芯片类型)
);

-- 导入 CSV 数据
.mode csv
.import --skip 1 chips.csv chips
