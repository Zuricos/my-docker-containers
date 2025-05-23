#!/bin/bash
set -e

# Start PostgreSQL in the background
docker-entrypoint.sh postgres &

# Wait for PostgreSQL to start
until pg_isready -h localhost -p 5432; do
  echo "Waiting for PostgreSQL to start..."
  sleep 2
done

# Check if SCHEMAS_USERS is set
if [ -z "${SCHEMAS_USERS}" ]; then
  echo "ERROR: SCHEMAS_USERS environment variable is not set. This variable should contain a comma-separated list of schema/user names."
  exit 1
fi

echo "Processing schemas/users: $SCHEMAS_USERS"

IFS=',' read -ra SCHEMA_ARRAY <<< "$SCHEMAS_USERS"

for schema_name in "${SCHEMA_ARRAY[@]}"; do
  trimmed_schema_name=$(echo "$schema_name" | xargs) # Trim whitespace
  if [ -z "$trimmed_schema_name" ]; then
    continue # Skip if schema name is empty after trim
  fi

  echo "Processing schema/user: $trimmed_schema_name"
  
  password_var_name="db_${trimmed_schema_name}_pw"
  current_password="${!password_var_name}" 
  
  if [ -z "$current_password" ]; then
    echo "Warning: Password for schema/user $trimmed_schema_name (from variable $password_var_name) is not set. Using default 'changeme123'."
    current_password="changeme123"
  fi

  echo "Initializing schema/user: $trimmed_schema_name"
  psql -U admin \
       -d postgres \
       -v current_schema_name="$trimmed_schema_name" \
       -v current_schema_password="$current_password" \
       -f /entrypoint/init-schemas.sql
done

# Bring PostgreSQL to the foreground
wait