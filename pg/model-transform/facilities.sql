TRUNCATE
    facility_operator
    CASCADE;

INSERT INTO facility_operator (abbreviation, name)
SELECT DISTINCT
    OPABBREV as abbreviation,
    OPNAME as name
    