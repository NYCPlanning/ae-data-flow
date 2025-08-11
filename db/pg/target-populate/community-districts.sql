TRUNCATE
	community_district,
	cbbr_policy_area,
    cbbr_need_group,
    cbbr_need,
    cbbr_request,
    cbbr_options_cascade
RESTART IDENTITY
CASCADE;

\copy community_district FROM '/var/lib/postgresql/data/community_district.csv';

\copy cbbr_policy_area FROM '/var/lib/postgresql/data/cbbr_policy_area.csv';
\copy cbbr_need_group FROM '/var/lib/postgresql/data/cbbr_need_group.csv';
\copy cbbr_need FROM '/var/lib/postgresql/data/cbbr_need.csv';
\copy cbbr_request FROM '/var/lib/postgresql/data/cbbr_request.csv';
\copy cbbr_options_cascade FROM '/var/lib/postgresql/data/cbbr_options_cascade.csv';
