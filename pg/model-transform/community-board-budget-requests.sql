TRUNCATE
	cbbr_policy_area,
	cbbr_need_group,
	cbbr_need,
	cbbr_request,
	cbbr_option_cascade,
	cbbr_agency_category_response,
	community_board_budget_request
RESTART IDENTITY
CASCADE;

INSERT INTO cbbr_policy_area (description)
SELECT DISTINCT
	"Policy Area" AS description
FROM source_cbbr_option
ORDER BY description;

INSERT INTO cbbr_need_group (description)
SELECT DISTINCT
	"Need Group" AS description
FROM source_cbbr_option
ORDER BY description;

INSERT INTO cbbr_need (description)
SELECT DISTINCT
    RTRIM("Need") AS description
FROM source_cbbr_option
    ORDER BY description;

INSERT INTO cbbr_request (description)
SELECT DISTINCT
    "Request" AS description
FROM source_cbbr_option
    ORDER BY description;

ALTER TABLE source_cbbr_option
	ADD COLUMN IF NOT EXISTS
		agency_initials text;

UPDATE source_cbbr_option
	SET agency_initials =
		CASE
	    	WHEN "Agency" = 'Other' THEN 'OTH'
	    	WHEN "Agency" = 'Queens Library (QL)' THEN 'QPL'
	    	WHEN "Agency" = 'School Construction Authority' THEN 'SCA'
	    	WHEN "Agency" = 'Department of Information Technology and Telecommunications (DOITT)' THEN 'OTI'
			WHEN "Agency" = 'NYC Emergency Management (NYCEM)' THEN 'OEM'
	    	ELSE REPLACE(
	    			REPLACE(
	    				SUBSTRING("Agency", '\([A-Z]{1,}\)'),
	    			'(', ''),
	    		')', '')
	    END;

INSERT INTO cbbr_option_cascade (
	policy_area_id,
	need_group_id,
	agency_initials,
	type,
	need_id,
	request_id
)
SELECT
	DISTINCT
	cbbr_policy_area.id as policy_area_id,
	cbbr_need_group.id as need_group_id,
	source_cbbr_option.agency_initials as agency_initials,
	source_cbbr_option."Type" as type,
	cbbr_need.id as need_id,
	cbbr_request.id as request_id
FROM source_cbbr_option
LEFT JOIN cbbr_policy_area ON cbbr_policy_area.description = source_cbbr_option."Policy Area"
LEFT JOIN cbbr_need_group ON cbbr_need_group.description = source_cbbr_option."Need Group"
LEFT JOIN cbbr_need ON cbbr_need.description = source_cbbr_option."Need"
LEFT JOIN cbbr_request ON cbbr_request.description = source_cbbr_option."Request"
WHERE
	cbbr_policy_area.description = source_cbbr_option."Policy Area"
	AND cbbr_need_group.description = source_cbbr_option."Need Group"
	AND cbbr_need.description = source_cbbr_option."Need"
	AND cbbr_request.description = source_cbbr_option."Request";


ALTER TABLE source_cbbr_export
    ADD COLUMN IF NOT EXISTS is_location_specific boolean,
	ADD COLUMN IF NOT EXISTS is_continued_support boolean,
	ADD COLUMN IF NOT EXISTS refined_managing_code text,
	ADD COLUMN IF NOT EXISTS refined_m_agency_acro text,
	ADD COLUMN IF NOT EXISTS refined_request_type text,
	ADD COLUMN IF NOT EXISTS li_ft_m_pnt geometry(MULTIPOINT, 2263),
	ADD COLUMN IF NOT EXISTS li_ft_m_poly geometry(MULTIPOLYGON, 2263),
	ADD COLUMN IF NOT EXISTS mercator_label geometry(POINT, 3857),
	ADD COLUMN IF NOT EXISTS mercator_fill_m_pnt geometry(MULTIPOINT, 3857),
	ADD COLUMN IF NOT EXISTS mercator_fill_m_poly geometry(MULTIPOLYGON, 3857)
	;

UPDATE source_cbbr_export
	SET	
		is_location_specific = CASE
			WHEN location_specific = 'Yes' THEN True
			WHEN location_specific = 'No' THEN False
		END;

UPDATE source_cbbr_export
	SET	
		is_continued_support = CASE
			WHEN RIGHT(tracking_code, 1) = 'S' THEN True
			ELSE False
		END;

UPDATE source_cbbr_export
	SET refined_managing_code = LPAD(agency::TEXT, 3, '0');

UPDATE source_cbbr_export
	SET refined_request_type = CASE
		WHEN type_br = 'C' THEN 'Capital'
		WHEN type_br = 'E' THEN 'Expense'
	END;

UPDATE source_cbbr_export
    SET
        refined_m_agency_acro = CASE
            WHEN agency_acronym = 'DoiTT' THEN 'OTI'
            WHEN agency_acronym = 'CHR' THEN 'CCHR'
            WHEN agency_acronym = 'CEOM' THEN 'BEBS'
      		WHEN agency_acronym = 'DCA' THEN 'DCWP'
			WHEN agency_acronym IS NULL AND refined_managing_code = '032' THEN 'DOI'
			WHEN agency_acronym IS NULL and refined_managing_code = '836' THEN 'DOF'
            ELSE agency_acronym
        END;
	
UPDATE source_cbbr_export
	SET
		li_ft_m_pnt = CASE
			WHEN ST_GeometryType(geom) = 'ST_MultiPoint' THEN ST_Transform(geom, 2263)
			END,
		li_ft_m_poly = CASE
			WHEN ST_GeometryType(geom) = 'ST_MultiPolygon' THEN ST_Transform(geom, 2263)
			END,
		mercator_fill_m_pnt = CASE
			WHEN ST_GeometryType(geom) = 'ST_MultiPoint' THEN ST_Transform(geom, 3857)
			END,
		mercator_fill_m_poly = CASE
			WHEN ST_GeometryType(geom) = 'ST_MultiPolygon' THEN ST_Transform(geom, 3857)
			END;

UPDATE source_cbbr_export
	SET
		mercator_label = CASE
			WHEN source_cbbr_export.mercator_fill_m_pnt IS NOT NULL THEN ST_Transform(ST_PointOnSurface(source_cbbr_export.mercator_fill_m_pnt), 3857)
			WHEN source_cbbr_export.mercator_fill_m_poly IS NOT NULL THEN ST_Transform((ST_MaximumInscribedCircle(source_cbbr_export.mercator_fill_m_poly)).center, 3857)
			END;

INSERT INTO cbbr_agency_category_response (description)
SELECT 
	acr.description
FROM (
	SELECT DISTINCT 
	agency_category_response as description 
	FROM source_cbbr_export
) acr;

INSERT INTO community_board_budget_request (
	id,
	internal_id,
	title,
	borough_id,
	community_district_id,
	agency,
	managing_code,
	agency_category_response_id,
	agency_response,
	request_type,
	priority,
	policy_area_id,
	need_group_id,
	need_id,
	request_id,
	explanation,
	is_location_specific,
	is_continued_support,
	li_ft_m_pnt,
	li_ft_m_poly,
	mercator_label,
	mercator_fill_m_pnt,
	mercator_fill_m_poly
)
SELECT DISTINCT
	tracking_code as id,
	unique_id as internal_id,
	source_cbbr_export.title,
	borough.id as borough_id,
	community_district.id as community_district_id,
	refined_m_agency_acro as agency,
	managing_code.id as managing_code,
	cbbr_agency_category_response.id as agency_category_response_id,
	agency_response,
	refined_request_type as request_type,
	priority,
	cbbr_policy_area.id as policy_area_id,
	cbbr_need_group.id as need_group_id,
	cbbr_need.id as need_id,
	cbbr_request.id as request_id,
	explanation,
	is_location_specific,
	is_continued_support,
	li_ft_m_pnt,
	li_ft_m_poly,
	source_cbbr_export.mercator_label,
	mercator_fill_m_pnt,
	mercator_fill_m_poly
FROM source_cbbr_export
LEFT JOIN borough on borough.id = source_cbbr_export.borough_code
LEFT JOIN community_district on community_district.id = source_cbbr_export.cd
LEFT JOIN agency on agency.initials = source_cbbr_export.agency_acronym
LEFT JOIN managing_code on managing_code.id = source_cbbr_export.refined_managing_code
LEFT JOIN cbbr_agency_category_response on cbbr_agency_category_response.description = source_cbbr_export.agency_category_response
LEFT JOIN cbbr_policy_area on cbbr_policy_area.description = source_cbbr_export.policy_area
LEFT JOIN cbbr_need_group on cbbr_need_group.description = source_cbbr_export.need_group
LEFT JOIN cbbr_need on UPPER(cbbr_need.description) = UPPER(source_cbbr_export.need)
LEFT JOIN cbbr_request on cbbr_request.description = source_cbbr_export.request
;


COPY cbbr_policy_area TO '/var/lib/postgresql/data/cbbr_policy_area.csv';
COPY cbbr_need_group TO '/var/lib/postgresql/data/cbbr_need_group.csv';
COPY cbbr_need TO '/var/lib/postgresql/data/cbbr_need.csv';
COPY cbbr_request TO '/var/lib/postgresql/data/cbbr_request.csv';
COPY cbbr_option_cascade TO '/var/lib/postgresql/data/cbbr_option_cascade.csv';
COPY cbbr_agency_category_response TO '/var/lib/postgresql/data/cbbr_agency_category_response.csv';
COPY community_board_budget_request TO '/var/lib/postgresql/data/community_board_budget_request.csv';