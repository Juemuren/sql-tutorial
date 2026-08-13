SELECT *
FROM file
WHERE
    (chip_type = '小' AND count < 5)
    OR
    (chip_type = '大' AND count < 8)
ORDER BY count DESC;
