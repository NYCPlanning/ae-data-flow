import { pgTable, pgEnum, integer, text, varchar, foreignKey, uuid, char, date, numeric, geometry, index, primaryKey } from "drizzle-orm/pg-core"
  import { sql } from "drizzle-orm"

export const capital_fund_category = pgEnum("capital_fund_category", ['city-non-exempt', 'city-exempt', 'city-cost', 'non-city-state', 'non-city-federal', 'non-city-other', 'non-city-cost', 'total'])
export const capital_project_category = pgEnum("capital_project_category", ['Fixed Asset', 'Lump Sum', 'ITT, Vehicles and Equipment'])
export const capital_project_fund_stage = pgEnum("capital_project_fund_stage", ['adopt', 'allocate', 'commit', 'spent'])
export const category = pgEnum("category", ['Residential', 'Commercial', 'Manufacturing'])


export const geography_columns = pgTable("geography_columns", {
	// TODO: failed to parse database type 'name'
	f_table_catalog: unknown("f_table_catalog"),
	// TODO: failed to parse database type 'name'
	f_table_schema: unknown("f_table_schema"),
	// TODO: failed to parse database type 'name'
	f_table_name: unknown("f_table_name"),
	// TODO: failed to parse database type 'name'
	f_geography_column: unknown("f_geography_column"),
	coord_dimension: integer("coord_dimension"),
	srid: integer("srid"),
	type: text("type"),
});

export const geometry_columns = pgTable("geometry_columns", {
	f_table_catalog: varchar("f_table_catalog", { length: 256 }),
	// TODO: failed to parse database type 'name'
	f_table_schema: unknown("f_table_schema"),
	// TODO: failed to parse database type 'name'
	f_table_name: unknown("f_table_name"),
	// TODO: failed to parse database type 'name'
	f_geometry_column: unknown("f_geometry_column"),
	coord_dimension: integer("coord_dimension"),
	srid: integer("srid"),
	type: varchar("type", { length: 30 }),
});

export const spatial_ref_sys = pgTable("spatial_ref_sys", {
	srid: integer("srid").primaryKey().notNull(),
	auth_name: varchar("auth_name", { length: 256 }),
	auth_srid: integer("auth_srid"),
	srtext: varchar("srtext", { length: 2048 }),
	proj4text: varchar("proj4text", { length: 2048 }),
});

export const agency_budget = pgTable("agency_budget", {
	code: text("code").primaryKey().notNull(),
	type: text("type"),
	sponsor: text("sponsor").references(() => agency.initials),
});

export const agency = pgTable("agency", {
	initials: text("initials").primaryKey().notNull(),
	name: text("name").notNull(),
});

export const capital_commitment = pgTable("capital_commitment", {
	id: uuid("id").primaryKey().notNull(),
	type: char("type", { length: 4 }).references(() => capital_commitment_type.code),
	planned_date: date("planned_date"),
	managing_code: char("managing_code", { length: 3 }),
	capital_project_id: text("capital_project_id"),
	budget_line_code: text("budget_line_code"),
	budget_line_id: text("budget_line_id"),
},
(table) => {
	return {
		capital_commitment_budget_line_code_budget_line_id_budget_line_: foreignKey({
			columns: [table.budget_line_code, table.budget_line_id],
			foreignColumns: [budget_line.code, budget_line.id],
			name: "capital_commitment_budget_line_code_budget_line_id_budget_line_"
		}),
		capital_commitment_managing_code_capital_project_id_capital_pro: foreignKey({
			columns: [table.managing_code, table.capital_project_id],
			foreignColumns: [capital_project.managing_code, capital_project.id],
			name: "capital_commitment_managing_code_capital_project_id_capital_pro"
		}),
	}
});

export const capital_commitment_fund = pgTable("capital_commitment_fund", {
	id: uuid("id").primaryKey().notNull(),
	capital_commitment_id: uuid("capital_commitment_id").references(() => capital_commitment.id),
	capital_fund_category: capital_fund_category("capital_fund_category"),
	value: numeric("value"),
});

export const capital_commitment_type = pgTable("capital_commitment_type", {
	code: char("code", { length: 4 }).primaryKey().notNull(),
	description: text("description"),
});

export const managing_code = pgTable("managing_code", {
	id: char("id", { length: 3 }).primaryKey().notNull(),
});

export const borough = pgTable("borough", {
	id: char("id", { length: 1 }).primaryKey().notNull(),
	title: text("title").notNull(),
	abbr: text("abbr").notNull(),
});

export const capital_project_checkbook = pgTable("capital_project_checkbook", {
	id: uuid("id").primaryKey().notNull(),
	managing_code: char("managing_code", { length: 3 }),
	capital_project_id: text("capital_project_id"),
	value: numeric("value"),
},
(table) => {
	return {
		custom_fk: foreignKey({
			columns: [table.managing_code, table.capital_project_id],
			foreignColumns: [capital_project.managing_code, capital_project.id],
			name: "custom_fk"
		}),
	}
});

export const capital_project_fund = pgTable("capital_project_fund", {
	id: uuid("id").primaryKey().notNull(),
	managing_code: char("managing_code", { length: 3 }),
	capital_project_id: text("capital_project_id"),
	capital_fund_category: capital_fund_category("capital_fund_category"),
	stage: capital_project_fund_stage("stage"),
	value: numeric("value"),
},
(table) => {
	return {
		custom_fk: foreignKey({
			columns: [table.managing_code, table.capital_project_id],
			foreignColumns: [capital_project.managing_code, capital_project.id],
			name: "custom_fk"
		}),
	}
});

export const tax_lot = pgTable("tax_lot", {
	bbl: char("bbl", { length: 10 }).primaryKey().notNull(),
	borough_id: char("borough_id", { length: 1 }).notNull().references(() => borough.id),
	block: text("block").notNull(),
	lot: text("lot").notNull(),
	address: text("address"),
	land_use_id: char("land_use_id", { length: 2 }).references(() => land_use.id),
	// TODO: failed to parse database type 'geography'
	wgs84: unknown("wgs84").notNull(),
	li_ft: geometry("li_ft", { type: "multipolygon", srid: 2263 }).notNull(),
});

export const land_use = pgTable("land_use", {
	id: char("id", { length: 2 }).primaryKey().notNull(),
	description: text("description").notNull(),
	color: char("color", { length: 9 }).notNull(),
});

export const city_council_district = pgTable("city_council_district", {
	id: text("id").primaryKey().notNull(),
	li_ft: geometry("li_ft", { type: "multipolygon", srid: 2263 }),
	mercator_fill: geometry("mercator_fill", { type: "multipolygon", srid: 3857 }),
	mercator_label: geometry("mercator_label", { type: "point", srid: 3857 }),
},
(table) => {
	return {
		li_ft_idx: index().using("gist", table.li_ft),
		mercator_fill_idx: index().using("gist", table.mercator_fill),
		mercator_label_idx: index().using("gist", table.mercator_label),
	}
});

export const zoning_district_class = pgTable("zoning_district_class", {
	id: text("id").primaryKey().notNull(),
	category: category("category"),
	description: text("description").notNull(),
	url: text("url"),
	color: char("color", { length: 9 }).notNull(),
});

export const zoning_district_zoning_district_class = pgTable("zoning_district_zoning_district_class", {
	zoning_district_id: uuid("zoning_district_id").notNull().references(() => zoning_district.id),
	zoning_district_class_id: text("zoning_district_class_id").notNull().references(() => zoning_district_class.id),
});

export const zoning_district = pgTable("zoning_district", {
	id: uuid("id").defaultRandom().primaryKey().notNull(),
	label: text("label").notNull(),
	// TODO: failed to parse database type 'geography'
	wgs84: unknown("wgs84").notNull(),
	li_ft: geometry("li_ft", { type: "multipolygon", srid: 2263 }).notNull(),
});

export const budget_line = pgTable("budget_line", {
	code: text("code").notNull().references(() => agency_budget.code),
	id: text("id").notNull(),
},
(table) => {
	return {
		budget_line_code_id_pk: primaryKey({ columns: [table.code, table.id], name: "budget_line_code_id_pk"}),
	}
});

export const community_district = pgTable("community_district", {
	borough_id: char("borough_id", { length: 1 }).notNull().references(() => borough.id),
	id: char("id", { length: 2 }).notNull(),
	mercator_fill: geometry("mercator_fill", { type: "multipolygon", srid: 3857 }),
	mercator_label: geometry("mercator_label", { type: "point", srid: 3857 }),
	li_ft: geometry("li_ft", { type: "multipolygon", srid: 2263 }),
},
(table) => {
	return {
		li_ft_idx: index().using("gist", table.li_ft),
		mercator_fill_idx: index().using("gist", table.mercator_fill),
		mercator_label_idx: index().using("gist", table.mercator_label),
		community_district_borough_id_id_pk: primaryKey({ columns: [table.borough_id, table.id], name: "community_district_borough_id_id_pk"}),
	}
});

export const capital_project = pgTable("capital_project", {
	managing_code: char("managing_code", { length: 3 }).notNull().references(() => managing_code.id),
	id: text("id").notNull(),
	managing_agency: text("managing_agency").notNull().references(() => agency.initials),
	description: text("description").notNull(),
	min_date: date("min_date").notNull(),
	max_date: date("max_date").notNull(),
	category: capital_project_category("category"),
	li_ft_m_pnt: geometry("li_ft_m_pnt", { type: "multipoint", srid: 2263 }),
	li_ft_m_poly: geometry("li_ft_m_poly", { type: "multipolygon", srid: 2263 }),
	mercator_label: geometry("mercator_label", { type: "point", srid: 3857 }),
	mercator_fill_m_pnt: geometry("mercator_fill_m_pnt", { type: "multipoint", srid: 3857 }),
	mercator_fill_m_poly: geometry("mercator_fill_m_poly", { type: "multipolygon", srid: 3857 }),
},
(table) => {
	return {
		li_ft_m_pnt_idx: index().using("gist", table.li_ft_m_pnt),
		li_ft_m_poly_idx: index().using("gist", table.li_ft_m_poly),
		mercator_fill_m_pnt_idx: index().using("gist", table.mercator_fill_m_pnt),
		mercator_fill_m_poly_idx: index().using("gist", table.mercator_fill_m_poly),
		capital_project_managing_code_id_pk: primaryKey({ columns: [table.managing_code, table.id], name: "capital_project_managing_code_id_pk"}),
	}
});