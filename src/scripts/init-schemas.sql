-- Create schemas
CREATE SCHEMA IF NOT EXISTS :"current_schema_name";

-- Create Users

CREATE OR REPLACE FUNCTION pg_temp.create_myuser(theUsername text, thePassword text)
RETURNS void AS
$BODY$
DECLARE
  duplicate_object_message text;
  altering_object_message text;
BEGIN
  BEGIN
    EXECUTE format(
      'CREATE USER %I WITH PASSWORD %L',
      theUsername,
      thePassword
    );
  EXCEPTION WHEN duplicate_object THEN
    GET STACKED DIAGNOSTICS duplicate_object_message = MESSAGE_TEXT;
    RAISE NOTICE '%, altering password', duplicate_object_message;
    BEGIN
      EXECUTE format(
        'ALTER USER %I WITH PASSWORD %L',
        theUsername,
        thePassword
      );
    EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS altering_object_message = MESSAGE_TEXT;
      RAISE NOTICE 'Failed to alter password for user %, %', theUsername, altering_object_message;
    END;
  END;
END;
$BODY$
LANGUAGE plpgsql;

SELECT pg_temp.create_myuser(:'current_schema_name', :'current_schema_password');

-- Grant Privileges
-- Use direct psql variable interpolation for identifiers
GRANT ALL PRIVILEGES ON SCHEMA :"current_schema_name" TO :"current_schema_name";

-- Grant database connection privileges
-- Use direct psql variable interpolation for identifiers
GRANT CONNECT ON DATABASE postgres TO :"current_schema_name";

-- connections strings are in form of:
-- jdbc:postgresql://{user}:{password}@{container_name}:{port}/{db_name}?options=-c%20search_path={schema_name}