UPDATE chips
SET count = count + getvariable('increment')
WHERE
    prof = getvariable('prof')
    AND chip_type = getvariable('chip_type')
RETURNING *;
