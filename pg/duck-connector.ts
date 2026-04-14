import { DuckDBInstance } from "@duckdb/node-api";

export const instance = DuckDBInstance.create(':memory:');
// export const connection = instance.connect();
// await connection.runAndReadAll(`
//     INSTALL spatial;
//     LOAD spatial;
// `);

// await connection.run(`
//   CREATE SECRET my_secret (
//   TYPE postgres,
//   HOST $host,
//   PORT $port,
//   DATABASE $database,
//   USER $user,
//   PASSWORD $password
//   );`, {
//     'host': process.env.FLOW_DATABASE_HOST  || '',
//     'port': process.env.FLOW_DATABASE_HOST  || '',
//     'database': process.env.FLOW_DATABASE_HOST  || '',
//     'user': process.env.FLOW_DATABASE_HOST  || '',
//     'password': process.env.FLOW_DATABASE_HOST  || ''
//   }
// );

// await connection.run(`
//     ATTACH '' AS postgres (TYPE postgres, SECRET my_secret);
// `);
