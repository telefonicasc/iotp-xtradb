# iotp-xtradb

This image deploys an instance of percona-xtradb-server, version 5.7.

## Configuration

### Volumes

Database files are stored in volume `/var/lib/mysql`

### Ports

TCP Ports used by this image:

- **3306**: Mysql.
- **4567**: Percona group communication.
- **4444**: SST (State Snapshot Transfer).
- **4568**: Incremental SST.

### Environment:

- `MYSQL_NODE_ID`: 1, 2, 3... (default *1*).
- `MYSQL_CLUSTER_ADDRESS`: Cluster addresses list for percona xtradb (e.g.: `server1,server2,server3`).
- `MYSQL_CLUSTER_NAME`: Cluster name (default *pxc-cluster*).
- `MYSQL_STRICT_MODE`: Percona strict mode (default *ENFORCING*).
- `MYSQL_PASSWORD`: Initial mysql root password (default *changeme*).
- `MYSQL_SST_PASSWORD`: Initial password for SST (default *changeme*).

