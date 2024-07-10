import { pgEnum } from "drizzle-orm/pg-core"

export const capital_fund_category = pgEnum("capital_fund_category", ['city-non-exempt', 'city-exempt', 'city-cost', 'non-city-state', 'non-city-federal', 'non-city-other', 'non-city-cost', 'total'])
export const capital_project_category = pgEnum("capital_project_category", ['Fixed Asset', 'Lump Sum', 'ITT, Vehicles and Equipment'])
export const capital_project_fund_stage = pgEnum("capital_project_fund_stage", ['adopt', 'allocate', 'commit', 'spent'])
export const category = pgEnum("category", ['Residential', 'Commercial', 'Manufacturing'])


