SELECT *
FROM file
WHERE chip_type = getvariable('chip_type')
ORDER BY count DESC;
