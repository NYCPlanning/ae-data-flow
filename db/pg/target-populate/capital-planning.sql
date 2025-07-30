TRUNCATE
	capital_project,
	capital_project_fund,
	capital_commitment_type,
	agency_budget,
	budget_line,
	capital_commitment,
	capital_commitment_fund,
	capital_project_checkbook
	CASCADE;

\copy capital_project FROM '/var/lib/postgresql/data/capital_project.csv';
\copy capital_project_fund FROM '/var/lib/postgresql/data/capital_project_fund.csv';
\copy capital_commitment_type FROM '/var/lib/postgresql/data/capital_commitment_type.csv';
\copy capital_project_checkbook FROM '/var/lib/postgresql/data/capital_project_checkbook.csv';
\copy agency_budget FROM '/var/lib/postgresql/data/agency_budget.csv';
\copy budget_line FROM '/var/lib/postgresql/data/budget_line.csv';
\copy capital_commitment FROM '/var/lib/postgresql/data/capital_commitment.csv';
\copy capital_commitment_fund FROM '/var/lib/postgresql/data/capital_commitment_fund.csv';
