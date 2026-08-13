SELECT *
FROM file
WHERE name LIKE getvariable('filter')
ORDER BY count