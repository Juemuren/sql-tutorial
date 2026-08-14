BEGIN TRANSACTION;

DROP TABLE IF EXISTS db.chips;

CREATE TABLE db.chips (
    prof TEXT NOT NULL,
    chip_type TEXT NOT NULL,
    count INTEGER NOT NULL,
    UNIQUE (prof, chip_type)
);

INSERT INTO db.chips (prof, chip_type, count)
SELECT
    prof::TEXT,
    chip_type::TEXT,
    count::INTEGER
FROM file;

COMMIT;
