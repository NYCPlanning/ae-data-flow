import { Client, Pool } from "pg";
import "dotenv/config";

const credentials =  {
  host: process.env.FLOW_DATABASE_HOST!,
  port: parseInt(process.env.FLOW_DATABASE_PORT!),
  user: process.env.FLOW_DATABASE_USER,
  password: process.env.FLOW_DATABASE_PASSWORD,
  database: process.env.FLOW_DATABASE_NAME!,
}

export const pgClient = new Client(credentials);

export const pgPool = new Pool(credentials);
