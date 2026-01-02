TRUNCATE
    tile_capital_project
    CASCADE;

INSERT INTO tile_capital_project (
    "managingCodeCapitalProjectId",
	"managingAgency",
	"commitmentsTotal",
	"agencyBudgets",
	"fill",
	"label"
)
SELECT
	capital_project.managing_code || capital_project.id,
	capital_project.managing_agency,
	SUM(capital_commitment_fund.value)::DOUBLE PRECISION,
	ARRAY_TO_JSON(
		ARRAY_AGG(
			DISTINCT(capital_commitment.budget_line_code)
		)
	),
	CASE
		WHEN mercator_fill_m_poly IS NOT NULL
			THEN ST_TRANSFORM(mercator_fill_m_poly, 4326)
		WHEN mercator_fill_m_pnt IS NOT NULL
			THEN ST_TRANSFORM(mercator_fill_m_pnt, 4326)
	END,
	ST_TRANSFORM(mercator_label, 4326)
FROM capital_project
LEFT JOIN capital_commitment
	ON capital_commitment.capital_project_id = capital_project.id
	AND capital_commitment.managing_code = capital_project.managing_code
LEFT JOIN capital_commitment_fund
	ON capital_commitment_fund.capital_commitment_id = capital_commitment.id
WHERE
	capital_commitment_fund.capital_fund_category = 'total'
	AND (
		mercator_fill_m_poly IS NOT NULL
		OR mercator_fill_m_pnt IS NOT NULL)
GROUP BY
	capital_project.managing_code,
	capital_project.id,
	capital_project.managing_agency;
