# iotp-xtradb

This image deploys an instance of percona-xtradb-cluster, version 5.7.

## Configuration

### Volumes

- Database files are stored in volume `/var/lib/mysql`
- Additional configuration files can be stored in `/etc/my.cnf.d`

### Ports

TCP Ports used by this image:

- **3306**: Mysql.
- **4567**: Percona group communication.
- **4444**: SST (State Snapshot Transfer).
- **4568**: Incremental SST.

### Environment:

- `MYSQL_NODE_ID`: 1, 2, 3... (default *1*).
- `MYSQL_DATADIR`: Path to the data folder (default */var/lib/mysql*).
- `MYSQL_CLUSTER_ADDRESS`: Cluster addresses list for percona xtradb (e.g.: `server1,server2,server3`).
- `MYSQL_CLUSTER_NAME`: Cluster name (default *pxc-cluster*).
- `MYSQL_STRICT_MODE`: Percona strict mode (default *ENFORCING*).
- `MYSQL_PASSWORD`: Initial mysql root password (default *changeme*).
- `MYSQL_SST_PASSWORD`: Initial password for SST (default *changeme*).
- `MYSQL_EXPORTER_PASSWORD`: Initial password for prometheus exporter (default *changeme*).

### Logging

Error logging is performed to stdout. Query log is not enabled.

### Additional mysql config

`mysqld` will read any configuration file with a `.cnf` extension mounted to the `/etc/my.cnf.d` folder.

Optionally, you can name the file with a `.cnf.template` extension. In that case, the entrypoint will replace in the file any reference to an environment variable, with the actual value of the variable, before loading the configuration.

For instance, if you want to create a "slow query log" file named after the mysql node id, you can mount the following file as `/etc/my.cnf.d/slow_query_log.cnf.template`:

```
[mysqld]
slow_query_log = /var/log/slow_queries_node_${MYSQL_NODE_ID}
```

## Initialization

If `MYSQL_NODE_ID` is *1* and `$MYSQL_DATADIR` (default */var/lib/mysql*) is empty (i.e. missing the `mysql`subfolder, on first deployment of the first container in the statefulset), the entrypoint will create an empty database and set the proper `root` and `sstuser` passwords.

In any other case, the entrypoint will not attempt to init the database, in order to avoid possible information loss.
