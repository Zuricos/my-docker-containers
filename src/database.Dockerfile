FROM postgres:17.5-bookworm

# Copy the SQL scripts and the custom entry point script
RUN mkdir -p /entrypoint

COPY ./scripts/init-schemas.sql /entrypoint/
COPY ./scripts/init-and-run.sh /entrypoint/

# Make the custom entry point script executable
RUN chmod +x /entrypoint/init-and-run.sh

ENV POSTGRES_USER=admin
ENV POSTGRES_DB=postgres
# Use the custom entry point script
ENTRYPOINT ["/entrypoint/init-and-run.sh"]