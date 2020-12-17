#!/bin/sh

set -eoux pipefail

# Load environment variables
if [ -f /etc/sysconfig/mysql ]; then
    source /etc/sysconfig/mysql
fi

# If the database is not inited, bootstrap the cluster.
# We just set a flag to be able to bootstrap after the
# configuration templates have been processed.
export MYSQL_MUST_INIT=0
if [ "${MYSQL_NODE_ID}" -eq "1" ]; then
    if ! [ -d "${MYSQL_DATADIR}/mysql" ]; then
        MYSQL_MUST_INIT=1
        MYSQL_CLUSTER_ADDRESS=""
    fi
fi

# Create config folder if not there
mkdir -p /tmp/my.cnf.d
for TEMPLATE in /etc/percona-xtradb-cluster.conf.d/*.template; do
    if [ -f "${TEMPLATE}" ]; then
        envsubst < "$TEMPLATE" > /tmp/my.cnf.d/`basename -s .template "${TEMPLATE}"`
    fi
done
for TEMPLATE in /etc/my.cnf.d/*.template; do
    if [ -f "${TEMPLATE}" ]; then
        envsubst < "$TEMPLATE" > /tmp/my.cnf.d/`basename -s .template "${TEMPLATE}"`
    fi
done

# Now we can do the initialization.
if [ "${MYSQL_MUST_INIT}" -eq "1" ]; then
    cat >/tmp/init_file.sql <<EOF
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_PASSWORD}');
CREATE USER 'sstuser'@'localhost' IDENTIFIED BY '${MYSQL_SST_PASSWORD}';
CREATE USER 'sstuser'@'%' IDENTIFIED BY '${MYSQL_SST_PASSWORD}';
GRANT PROCESS, RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'sstuser'@'localhost';
GRANT PROCESS, RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'sstuser'@'%';
FLUSH PRIVILEGES;
EOF
    /usr/sbin/mysqld --basedir=/usr --initialize-insecure --init_file=/tmp/init_file.sql --datadir="${MYSQL_DATADIR}"
    rm -f /tmp/init_file.sql
fi

# Execute mysqld
exec /usr/sbin/mysqld --basedir=/usr "$@"
