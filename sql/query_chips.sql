SELECT *
FROM chips
WHERE
    "职业" = getvariable('prof')
    AND "芯片类型" = getvariable('chip_type');
