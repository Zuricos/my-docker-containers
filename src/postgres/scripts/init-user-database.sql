-- Set a custom GUC. psql will replace :'psql_current_db_user_name' with a quoted literal.
-- e.g., SELECT set_config('myvars.current_db_user_name', 'schema1', false);
SELECT set_config('myvars.current_db_user_name', :'psql_current_db_user_name', false);

-- Create User
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
    RAISE NOTICE 'User % already exists, altering password.', quote_ident(theUsername);
    BEGIN
      EXECUTE format(
        'ALTER USER %I WITH PASSWORD %L',
        theUsername,
        thePassword
      );
    EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS altering_object_message = MESSAGE_TEXT;
      RAISE NOTICE 'Failed to alter password for user %, %', quote_ident(theUsername), altering_object_message;
    END;
  END;
END;
$BODY$
LANGUAGE plpgsql;

-- Call create_myuser using the GUC for username and psql var for password
SELECT pg_temp.create_myuser(current_setting('myvars.current_db_user_name'), :'psql_current_db_user_password');

-- Create or alter database ownership. This must run outside transaction blocks.
-- Generate the SQL command and execute it with psql meta-command \gexec.
SELECT CASE
  WHEN EXISTS (SELECT 1 FROM pg_database WHERE datname = current_setting('myvars.current_db_user_name')) THEN
    format('ALTER DATABASE %I OWNER TO %I', current_setting('myvars.current_db_user_name'), current_setting('myvars.current_db_user_name'))
  ELSE
    format('CREATE DATABASE %I WITH OWNER = %I', current_setting('myvars.current_db_user_name'), current_setting('myvars.current_db_user_name'))
END AS sqlcmd;
\gexec

-- As owner, the user has all privileges on their database (connect, create tables, etc.).

-- Connection strings are in the form of:
-- jdbc:postgresql://{host}:{port}/{database_name}?user={user}&password={password}
-- Example for user 'myuser' and database 'myuser':
-- jdbc:postgresql://localhost:5432/myuser?user=myuser&password=...
