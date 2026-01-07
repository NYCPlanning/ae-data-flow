import { $ } from "execa";

(async () => {
  const { stdout: pg_dump_version } = await $`pg_dump --version`;
  console.log(pg_dump_version);
  const { stdout: psql_version } = await $`psql --version`;
  console.log(psql_version);
})();
