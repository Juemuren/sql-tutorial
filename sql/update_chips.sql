UPDATE chips
SET "数量" = "数量" + getvariable('increment')
WHERE
    "职业" = getvariable('prof')
    AND "芯片类型" = getvariable('chip_type')
RETURNING *;
