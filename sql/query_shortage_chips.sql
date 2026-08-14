SELECT chips.*
FROM file AS chips
WHERE
    (chips.chip_type = '小' AND chips.count < 5)
    OR (
        chips.chip_type = '大'
        AND chips.count + (
            SELECT dual_chips.count * 2
            FROM file AS dual_chips
            WHERE
                dual_chips.prof = chips.prof
                AND dual_chips.chip_type = '双'
        ) < 8
    )
ORDER BY chips.count DESC;
