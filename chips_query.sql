-- 查询小芯片
SELECT *
FROM chips
WHERE 芯片类型 = '小'
ORDER BY 数量 DESC;

-- 查询大芯片
SELECT *
FROM chips
WHERE 芯片类型 = '大'
ORDER BY 数量 DESC;

-- 查询双芯片
SELECT *
FROM chips
WHERE 芯片类型 = '双'
ORDER BY 数量 DESC;

-- 查询合并的小芯片
SELECT
    CASE
        WHEN 职业 IN ('先锋', '辅助') THEN '先锋 + 辅助'
        WHEN 职业 IN ('狙击', '术师') THEN '狙击 + 术师'
        WHEN 职业 IN ('近卫', '特种') THEN '近卫 + 特种'
        WHEN 职业 IN ('重装', '医疗') THEN '重装 + 医疗'
    END AS 组合,
    芯片类型,
    SUM(数量) AS 总数
FROM chips
WHERE 芯片类型 = '小'
GROUP BY 组合
ORDER BY 总数 DESC;

-- 查询合并的大芯片
SELECT
    CASE
        WHEN 职业 IN ('先锋', '辅助') THEN '先锋 + 辅助'
        WHEN 职业 IN ('狙击', '术师') THEN '狙击 + 术师'
        WHEN 职业 IN ('近卫', '特种') THEN '近卫 + 特种'
        WHEN 职业 IN ('重装', '医疗') THEN '重装 + 医疗'
    END AS 组合,
    芯片类型,
    SUM(数量) AS 总数
FROM chips
WHERE 芯片类型 = '大'
GROUP BY 组合
ORDER BY 总数 DESC;

-- 查询紧缺的小芯片
SELECT *
FROM chips
WHERE
    芯片类型 = '小' AND 数量 < 5
ORDER BY 数量 DESC;

-- 查询紧缺的大芯片
SELECT *
FROM chips
WHERE
    芯片类型 = '大' AND 数量 < 8
ORDER BY 数量 DESC;
