#!/bin/bash
PG_VERSION=12

sudo yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo dnf -qy module disable postgresql
sudo yum install -y postgresql${PG_VERSION} postgresql${PG_VERSION}-devel postgresql${PG_VERSION}-server postgresql${PG_VERSION}-contrib python3-psycopg2

POSTGRES_RUNNING=$(service postgresql-${PG_VERSION} status | egrep  "postgresql-${PG_VERSION}.*running" | wc -l)
if [ "$POSTGRES_RUNNING" -ne 1 ]; then
  echo 'Starting Postgres'
  sudo /usr/bin/postgresql-${PG_VERSION}-setup initdb
  sudo /sbin/service postgresql-${PG_VERSION} start
  sudo /sbin/chkconfig postgresql-${PG_VERSION} on
else
  echo "Postgres is running"
fi

echo "Creating postgres user:"
ALTER_POSTGRES_USER_SQL="ALTER USER postgres WITH ENCRYPTED PASSWORD 'postgres'"
sudo -u postgres psql --command="$ALTER_POSTGRES_USER_SQL"

echo "Updating postgresql connection info"
sudo cp /var/lib/pgsql/${PG_VERSION}/data/pg_hba.conf .
sudo chmod 666 pg_hba.conf
sed 's/ident/md5/' < pg_hba.conf > pg_hba2.conf
echo 'host    all             all             0.0.0.0/0               md5' >> pg_hba2.conf
sudo cp pg_hba2.conf /var/lib/pgsql/${PG_VERSION}/data/pg_hba.conf
sudo chmod 600 /var/lib/pgsql/${PG_VERSION}/data/pg_hba.conf

sudo cp /var/lib/pgsql/${PG_VERSION}/data/postgresql.conf .
sudo chmod 666 postgresql.conf
sed "s/^#listen_addresses.*$/listen_addresses = '*'/" < postgresql.conf > postgresql2.conf
sudo cp postgresql2.conf /var/lib/pgsql/${PG_VERSION}/data/postgresql.conf
sudo chmod 600 /var/lib/pgsql/${PG_VERSION}/data/postgresql.conf

echo "Patching complete, restarting"
sudo /sbin/service postgresql-${PG_VERSION} restart

echo "Opening ports"
sudo firewall-cmd --permanent --zone=public --add-port=5432/tcp
sudo firewall-cmd --permanent --zone=public --add-port=5432/udp

echo "Cleaning up"
sudo rm *.conf

