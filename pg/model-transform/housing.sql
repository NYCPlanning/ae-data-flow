TRUNCATE
    housing_growth_cd,
    housing_growth_nta
RESTART IDENTITY
CASCADE;

INSERT INTO housing_growth_cd (
    geography_id,
    units_2020_census,
    units_2020,
    completed_units_previous_10_years,
    completed_units_since_census,
    units_current,
    projected_completed_units_next_10_years,
    projected_units_in_10_years
)
SELECT DISTINCT
    source_housing_growth_cd.geography_id as geography_id,
    source_housing_growth_cd.units_2020_census as units_2020_census,
    source_housing_growth_cd.units_2020 as units_2020,
    source_housing_growth_cd.completed_units_2016_2025 as completed_units_previous_10_years,
    source_housing_growth_cd.completed_units_2021_2025 as completed_units_since_census,
    source_housing_growth_cd.units_2025 as units_current,
    source_housing_growth_cd.projected_completed_units_2026_2035 as projected_completed_units_next_10_years,
    source_housing_growth_cd.projected_units_2035 as projected_units_in_10_years
FROM source_housing_growth_cd;

INSERT INTO housing_growth_nta (
    geography_id,
    units_2020_census,
    units_2020,
    completed_units_previous_10_years,
    completed_units_since_census,
    units_current,
    projected_completed_units_next_10_years,
    projected_units_in_10_years
)
SELECT DISTINCT
    source_housing_growth_nta.geography_id as geography_id,
    source_housing_growth_nta.units_2020_census as units_2020_census,
    source_housing_growth_nta.units_2020 as units_2020,
    source_housing_growth_nta.completed_units_2016_2025 as completed_units_previous_10_years,
    source_housing_growth_nta.completed_units_2021_2025 as completed_units_since_census,
    source_housing_growth_nta.units_2025 as units_current,
    source_housing_growth_nta.projected_completed_units_2026_2035 as projected_completed_units_next_10_years,
    source_housing_growth_nta.projected_units_2035 as projected_units_in_10_years
FROM source_housing_growth_nta;

COPY housing_growth_cd TO '/var/lib/postgresql/data/housing_growth_cd.csv';
COPY housing_growth_nta TO '/var/lib/postgresql/data/housing_growth_nta.csv';