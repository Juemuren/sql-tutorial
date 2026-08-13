SELECT *
FROM file
WHERE "芯片类型" = getvariable('chip_type')
ORDER BY "数量" DESC;
