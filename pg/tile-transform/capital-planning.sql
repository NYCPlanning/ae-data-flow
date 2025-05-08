TRUNCATE
    tile_capital_project
    CASCADE;

INSERT INTO tile_capital_project
SELECT
		source_capital_project.m_a_proj_id AS managing_code_capital_project_id,
		source_capital_project.m_agency_acro AS managing_agency,
		source_capital_project.plannedcommit_total AS commitments_total,
		ARRAY_TO_JSON(ARRAY_AGG(DISTINCT SPLIT_PART(source_capital_commitment.budget_line, '-', 1))) AS agency_budgets,
		CASE
			WHEN source_capital_project_m_pnt.wkt IS NOT NULL THEN source_capital_project_m_pnt.wkt
			WHEN source_capital_project_m_poly.wkt IS NOT NULL THEN source_capital_project_m_poly.wkt
		END as fill,
		CASE
			WHEN source_capital_project_m_pnt.wkt IS NOT NULL THEN ST_PointOnSurface(source_capital_project_m_pnt.wkt)
			WHEN source_capital_project_m_poly.wkt IS NOT NULL THEN (ST_MaximumInscribedCircle(source_capital_project_m_poly.wkt)).center
		END as label
FROM source_capital_project
LEFT JOIN source_capital_project_m_poly
		ON source_capital_project_m_poly.maprojid = source_capital_project.m_a_proj_id
LEFT JOIN source_capital_project_m_pnt
		ON source_capital_project_m_pnt.maprojid = source_capital_project.m_a_proj_id
LEFT JOIN source_capital_commitment
		ON source_capital_commitment.m_a_proj_id = source_capital_project.m_a_proj_id
WHERE
		source_capital_project_m_pnt.wkt IS NOT NULL OR source_capital_project_m_poly.wkt IS NOT NULL
GROUP BY
		source_capital_project.m_a_proj_id,
		source_capital_project.m_agency_acro,
		source_capital_project.plannedcommit_total,
		source_capital_project_m_poly.wkt,
		source_capital_project_m_pnt.wkt;
