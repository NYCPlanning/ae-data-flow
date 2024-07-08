import { relations } from "drizzle-orm/relations";
import { agency, agency_budget, budget_line, capital_commitment, capital_project, capital_commitment_type, capital_commitment_fund, capital_project_checkbook, capital_project_fund, borough, tax_lot, land_use, zoning_district_class, zoning_district_zoning_district_class, zoning_district, community_district, managing_code } from "./schema";

export const agency_budgetRelations = relations(agency_budget, ({one, many}) => ({
	agency: one(agency, {
		fields: [agency_budget.sponsor],
		references: [agency.initials]
	}),
	budget_lines: many(budget_line),
}));

export const agencyRelations = relations(agency, ({many}) => ({
	agency_budgets: many(agency_budget),
	capital_projects: many(capital_project),
}));

export const capital_commitmentRelations = relations(capital_commitment, ({one, many}) => ({
	budget_line: one(budget_line, {
		fields: [capital_commitment.budget_line_code],
		references: [budget_line.code]
	}),
	capital_project: one(capital_project, {
		fields: [capital_commitment.managing_code],
		references: [capital_project.managing_code]
	}),
	capital_commitment_type: one(capital_commitment_type, {
		fields: [capital_commitment.type],
		references: [capital_commitment_type.code]
	}),
	capital_commitment_funds: many(capital_commitment_fund),
}));

export const budget_lineRelations = relations(budget_line, ({one, many}) => ({
	capital_commitments: many(capital_commitment),
	agency_budget: one(agency_budget, {
		fields: [budget_line.code],
		references: [agency_budget.code]
	}),
}));

export const capital_projectRelations = relations(capital_project, ({one, many}) => ({
	capital_commitments: many(capital_commitment),
	capital_project_checkbooks: many(capital_project_checkbook),
	capital_project_funds: many(capital_project_fund),
	agency: one(agency, {
		fields: [capital_project.managing_agency],
		references: [agency.initials]
	}),
	managing_code: one(managing_code, {
		fields: [capital_project.managing_code],
		references: [managing_code.id]
	}),
}));

export const capital_commitment_typeRelations = relations(capital_commitment_type, ({many}) => ({
	capital_commitments: many(capital_commitment),
}));

export const capital_commitment_fundRelations = relations(capital_commitment_fund, ({one}) => ({
	capital_commitment: one(capital_commitment, {
		fields: [capital_commitment_fund.capital_commitment_id],
		references: [capital_commitment.id]
	}),
}));

export const capital_project_checkbookRelations = relations(capital_project_checkbook, ({one}) => ({
	capital_project: one(capital_project, {
		fields: [capital_project_checkbook.managing_code],
		references: [capital_project.managing_code]
	}),
}));

export const capital_project_fundRelations = relations(capital_project_fund, ({one}) => ({
	capital_project: one(capital_project, {
		fields: [capital_project_fund.managing_code],
		references: [capital_project.managing_code]
	}),
}));

export const tax_lotRelations = relations(tax_lot, ({one}) => ({
	borough: one(borough, {
		fields: [tax_lot.borough_id],
		references: [borough.id]
	}),
	land_use: one(land_use, {
		fields: [tax_lot.land_use_id],
		references: [land_use.id]
	}),
}));

export const boroughRelations = relations(borough, ({many}) => ({
	tax_lots: many(tax_lot),
	community_districts: many(community_district),
}));

export const land_useRelations = relations(land_use, ({many}) => ({
	tax_lots: many(tax_lot),
}));

export const zoning_district_zoning_district_classRelations = relations(zoning_district_zoning_district_class, ({one}) => ({
	zoning_district_class: one(zoning_district_class, {
		fields: [zoning_district_zoning_district_class.zoning_district_class_id],
		references: [zoning_district_class.id]
	}),
	zoning_district: one(zoning_district, {
		fields: [zoning_district_zoning_district_class.zoning_district_id],
		references: [zoning_district.id]
	}),
}));

export const zoning_district_classRelations = relations(zoning_district_class, ({many}) => ({
	zoning_district_zoning_district_classes: many(zoning_district_zoning_district_class),
}));

export const zoning_districtRelations = relations(zoning_district, ({many}) => ({
	zoning_district_zoning_district_classes: many(zoning_district_zoning_district_class),
}));

export const community_districtRelations = relations(community_district, ({one}) => ({
	borough: one(borough, {
		fields: [community_district.borough_id],
		references: [borough.id]
	}),
}));

export const managing_codeRelations = relations(managing_code, ({many}) => ({
	capital_projects: many(capital_project),
}));