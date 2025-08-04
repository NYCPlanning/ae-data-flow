TRUNCATE
    agency,
    managing_code,
    cbbr_policy_area,
    cbbr_need_group,
    cbbr_need,
    cbbr_request,
    cbbr_option_cascade,
	capital_project,
	capital_project_fund,
	capital_commitment_type,
	agency_budget,
	budget_line,
	capital_commitment,
	capital_commitment_fund,
	capital_project_checkbook
RESTART IDENTITY
CASCADE;

\copy agency FROM '/var/lib/postgresql/data/agency.csv';
\copy managing_code FROM '/var/lib/postgresql/data/managing_code.csv';
\copy cbbr_policy_area FROM '/var/lib/postgresql/data/cbbr_policy_area.csv';
\copy cbbr_need_group FROM '/var/lib/postgresql/data/cbbr_need_group.csv';
\copy cbbr_need FROM '/var/lib/postgresql/data/cbbr_need.csv';
\copy cbbr_request FROM '/var/lib/postgresql/data/cbbr_request.csv';
\copy cbbr_option_cascade FROM '/var/lib/postgresql/data/cbbr_option_cascade.csv';
\copy capital_project FROM '/var/lib/postgresql/data/capital_project.csv';
\copy capital_project_fund FROM '/var/lib/postgresql/data/capital_project_fund.csv';
\copy capital_commitment_type FROM '/var/lib/postgresql/data/capital_commitment_type.csv';
\copy capital_project_checkbook FROM '/var/lib/postgresql/data/capital_project_checkbook.csv';
\copy agency_budget FROM '/var/lib/postgresql/data/agency_budget.csv';
\copy budget_line FROM '/var/lib/postgresql/data/budget_line.csv';
\copy capital_commitment FROM '/var/lib/postgresql/data/capital_commitment.csv';
\copy capital_commitment_fund FROM '/var/lib/postgresql/data/capital_commitment_fund.csv';
