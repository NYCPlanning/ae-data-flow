TRUNCATE
  neighborhood_tabulation_area
  CASCADE;

  \copy neighborhood_tabulation_area FROM '/var/lib/postgresql/data/neighborhood_tabulation_area.csv';