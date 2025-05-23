#!/bin/bash
set -e

# Start PostgreSQL in the background
docker-entrypoint.sh postgres &

# Wait for PostgreSQL to start
until pg_isready -h localhost -p 5432; do
  echo "Waiting for PostgreSQL to start..."
  sleep 2
done

# Check if DB_USERS is set
if [ -z "${DB_USERS}" ]; then
  echo "ERROR: DB_USERS environment variable is not set. This variable should contain a comma-separated list of database/user names."
  exit 1
fi

echo "Processing databases/users: $DB_USERS"

IFS=',' read -ra DB_USER_ARRAY <<< "$DB_USERS"

for db_user_name in "${DB_USER_ARRAY[@]}"; do
  trimmed_db_user_name=$(echo "$db_user_name" | xargs) # Trim whitespace
  if [ -z "$trimmed_db_user_name" ]; then
    continue # Skip if db_user_name is empty after trim
  fi

  echo "Processing database/user: $trimmed_db_user_name"
  
  password_var_name="db_${trimmed_db_user_name}_pw"
  current_password="${!password_var_name}" 
  
  if [ -z "$current_password" ]; then
    echo "Warning: Password for database/user $trimmed_db_user_name (from variable $password_var_name) is not set. Using default 'changeme123'."
    current_password="changeme123"
  fi

  echo "Initializing database/user: $trimmed_db_user_name"
  
  # psql command arguments
  psql_command_options=(
    -U "admin"
    -d "postgres"
    --variable=ON_ERROR_STOP=1
    # Pass variables for psql substitution (e.g., for the create_myuser function call)
    -v psql_current_db_user_name="$trimmed_db_user_name"
    -v psql_current_db_user_password="$current_password"
    # Execute the SQL file
    -f "/entrypoint/init-user-database.sql"
  )
  
  psql "${psql_command_options[@]}"
done

# Bring PostgreSQL to the foreground
wait