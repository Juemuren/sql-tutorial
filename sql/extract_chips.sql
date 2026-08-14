-- noqa: disable=LT02
WITH
profs (prof, prof_sort) AS (
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

chip_types (chip_type, name_suffix, type_sort) AS (
    VALUES
    ('小', '芯片', 1),
    ('大', '芯片组', 2),
    ('双', '双芯片', 3)
)

FROM profs
CROSS JOIN chip_types
SELECT
    profs.prof,
    chip_types.chip_type,
    coalesce(
        (
            SELECT file.count
            FROM file
            WHERE file.name = profs.prof || chip_types.name_suffix
        ),
        0
    ) AS count
ORDER BY profs.prof_sort, chip_types.type_sort;
