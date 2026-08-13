SELECT *
FROM file
WHERE
    ("芯片类型" = '小' AND "数量" < 5)
    OR
    ("芯片类型" = '大' AND "数量" < 8)
ORDER BY "数量" DESC;
