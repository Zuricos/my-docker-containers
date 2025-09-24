# Note
This repo is soley for my private usage and for simplicity do have the docker images build in ci-cd and in a registry.
Feel free to use code from here for you own purpose. But I do not grant any help or futher assistance.

# ENV VARIABLES
## POSTGRES
**Important**
Do not change the POSTGRES_USER or POSTGRES_DB as this are set inside the container itself.

Values are:
- POSTGRES_USER = admin
- POSTGRES_DB = postgres

### POSTGRES ENV
```env
POSTGRES_PASSWORD=<admin password>
POSTGRES_PORT=5432
```
### SCHEMAS ENV
```env
# Comma-separated list of databases/user names
DB_USERS=user1,user2,user3

# Password for schema1 (variable name is db_<user_name>_pw)
db_user1_pw=<password_for_user1>
# Password for schema2
db_user2_pw=<password_for_user2>
# Password for schema3
db_user3_pw=<password_for_user3>
```

## KEYCLOAK
```env
KC_HTTP_ENABLED=true
KC_HTTP_PORT=8080
KC_HOSTNAME=<set to hostname fully qualified>
KC_HOSTNAME_BACKCHANNEL_DYNAMIC=true

# Enable health and metrics support
KC_HEALTH_ENABLED=true
KC_METRICS_ENABLED=true

# Configure Database
KC_DB=postgres

# do not change this after initial setup
KC_DB_USERNAME=keycloak
KC_DB_PASSWORD=<password>

# jdbc:postgresql://<POSTGRES_CONTAINER_NAME>:<POSTGRES_PORT>/<DB_NAME>
KC_DB_URL=jdbc:postgresql://database/postgres

KC_BOOTSTRAP_ADMIN_USERNAME=admin
KC_BOOTSTRAP_ADMIN_PASSWORD=<Admin PW>
```