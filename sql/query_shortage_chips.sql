SELECT
    prof,
    CASE chip_type
        WHEN '双' THEN '大' ELSE chip_type
    END AS converted_chip_type,
    sum(
        count * CASE chip_type
            WHEN '双' THEN 2 ELSE 1
        END
    ) AS converted_count
FROM file
GROUP BY prof, converted_chip_type
HAVING
    (converted_chip_type = '小' AND converted_count < 5)
    OR (converted_chip_type = '大' AND converted_count < 8)
