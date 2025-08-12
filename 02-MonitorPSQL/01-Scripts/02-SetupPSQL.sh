KEY_NAME="psql_keypair"
PUBLIC_IP=""
PSQLUSER="dynatrace"
PSQLPASSWORD="postgres"
PSQLDATABASE="dynatrace"

# === Step 1: SSH and run remote commands ===

echo "🔐 Connecting to instance and installing psql DB ..."
ssh -o StrictHostKeyChecking=no -i "${KEY_NAME}.pem" ubuntu@$PUBLIC_IP << 'EOF'
  echo "🏃 Running remote setup..."
  sudo apt install wget ca-certificates -y
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
  sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
  sudo apt update
  sudo apt install postgresql postgresql-contrib -y
  sudo -u postgres psql -c "CREATE USER ${PSQLUSER} WITH PASSWORD '${PSQLPASSWORD}';"
  sudo -u postgres psql -c "CREATE DATABASE ${PSQLDATABASE} OWNER ${PSQLUSER};"
  sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${PSQLDATABASE} TO ${PSQLUSER};"
  sudo -u postgres psql -d ${PSQLDATABASE} -c "CREATE TABLE employees (employee_number int8, 
                                                    lastname varchar, 
                                                    name varchar, 
                                                    gender varchar,
                                                    city varchar, 
                                                    jobtitle varchar, 
                                                    department varchar,
                                                    store_location varchar,
                                                    division varchar,
                                                    age float(8),
                                                    length_service float(8),
                                                    abset_hours float(8),
                                                    business_unit varchar);"
  sudo -u postgres psql -d dynatrace -c "\copy employees FROM '/tmp/absenteeism.csv' DELIMITER ',' CSV;"
  echo "✅ Remote setup complete. PSQL DB should be running and populated."
EOF