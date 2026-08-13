SELECT
    chip_type,
    CASE
        WHEN prof IN ('先锋', '辅助') THEN '先锋 + 辅助'
        WHEN prof IN ('狙击', '术师') THEN '狙击 + 术师'
        WHEN prof IN ('近卫', '特种') THEN '近卫 + 特种'
        WHEN prof IN ('重装', '医疗') THEN '重装 + 医疗'
    END AS prof_group,
    sum(count) AS group_count
FROM file
WHERE chip_type = getvariable('chip_type')
GROUP BY prof_group, chip_type
ORDER BY group_count DESC;
