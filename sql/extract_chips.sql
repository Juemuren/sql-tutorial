WITH
prof_order (prof, prof_sort) AS (
    VALUES
    ('先锋', 1),
    ('辅助', 2),
    ('狙击', 3),
    ('术师', 4),
    ('近卫', 5),
    ('特种', 6),
    ('重装', 7),
    ('医疗', 8)
),

type_order (chip_type, type_sort) AS (
    VALUES
    ('小', 1),
    ('大', 2),
    ('双', 3)
),

parsed_chips AS (
    SELECT
        "Count"::INTEGER AS count,
        CASE
            WHEN "Name" LIKE '%芯片组' THEN regexp_replace("Name", '芯片组$', '')
            WHEN "Name" LIKE '%双芯片' THEN regexp_replace("Name", '双芯片$', '')
            WHEN "Name" LIKE '%芯片' THEN regexp_replace("Name", '芯片$', '')
        END AS prof,
        CASE
            WHEN "Name" LIKE '%芯片组' THEN '大'
            WHEN "Name" LIKE '%双芯片' THEN '双'
            WHEN "Name" LIKE '%芯片' THEN '小'
        END AS chip_type
    FROM file
    WHERE "Name" LIKE '%芯片%'
),

chip_map AS (
    SELECT
        prof,
        chip_type,
        max(count) AS count
    FROM parsed_chips
    WHERE
        prof IS NOT NULL
        AND chip_type IS NOT NULL
    GROUP BY prof, chip_type
)

SELECT
    prof_order.prof,
    type_order.chip_type,
    coalesce(chip_map.count, 0)::INTEGER AS count
FROM prof_order
CROSS JOIN type_order
LEFT JOIN chip_map
    ON
        prof_order.prof = chip_map.prof
        AND type_order.chip_type = chip_map.chip_type
ORDER BY prof_order.prof_sort, type_order.type_sort;
