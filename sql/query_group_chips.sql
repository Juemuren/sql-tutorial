SELECT
    芯片类型,
    CASE
        WHEN 职业 IN ('先锋', '辅助') THEN '先锋 + 辅助'
        WHEN 职业 IN ('狙击', '术师') THEN '狙击 + 术师'
        WHEN 职业 IN ('近卫', '特种') THEN '近卫 + 特种'
        WHEN 职业 IN ('重装', '医疗') THEN '重装 + 医疗'
    END AS 组合,
    SUM(数量) AS 总数
FROM file
GROUP BY 组合, 芯片类型
ORDER BY 总数 DESC;
