# Purpose of this Postgres Docker
This uses the official postgres docker image [Source](https://github.com/docker-library/postgres/tree/d9c4773ca5dc96692188c458f281d217d78b14d9).

It can be used to have only host one postgres instance instead of multiple ones for i.e. a homelab with multiple docker stacks in a convenient way.

# Note
This repo and docker I use for personal self hosting.
But feel free to use the docker container or fork and build it for your own purpose i.e. with a different postgres version.

## Usage

You can set the schemas in the `SCHEMAS_USERS` in a comma seperated list.

The script generates for each `SCHEMAS_USERS` a schema and a user, both with the same name, with the appropriate rights and the provided password.

If you remove a schema/user the schema wont be deleted! You have to do this manually. This is for safety reasons to not loose data by accident.

The [`docker compose`](src/compose.yml) is for testing and as a reference how to use it.

# ENV VARIABLES
**Important**
Do not change the POSTGRES_USER or POSTGRES_DB as this are set inside the container itself.

Values are:
- POSTGRES_USER = admin
- POSTGRES_DB = postgres

## POSTGRES ENV
```env
POSTGRES_PASSWORD=<admin password>
POSTGRES_PORT=5432
```
## SCHEMAS ENV
```env
# Comma-separated list of schema/user names
SCHEMAS_USERS=schema1,schema2,schema3

# Password for schema1 (variable name is db_<schema_name>_pw)
db_schema1_pw=<password_for_schema1>
# Password for schema2
db_schema2_pw=<password_for_schema2>
# Password for schema3
db_schema3_pw=<password_for_schema3>
```