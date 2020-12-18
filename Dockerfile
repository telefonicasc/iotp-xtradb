FROM centos:centos7

# Install Percona-release 5.7
RUN yum install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm && \
    percona-release setup -y pxc-57 && \
    yum install -y Percona-XtraDB-Cluster-server-57 gettext && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    chmod -R a+rX /etc/my.cnf.d && \
    rm    -rf     /etc/my.cnf && \
    rm    -rf     /etc/percona-xtradb-cluster.conf.d

# Install tini init manager
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

VOLUME /var/lib/mysql
EXPOSE 3306 4567 4444 4568

# Overwrite default config and provide entrypoint
COPY files/sysconfig/mysql /etc/sysconfig/mysql
COPY files/my.cnf /etc/my.cnf
COPY files/conf.d /etc/percona-xtradb-cluster.conf.d
COPY entrypoint.sh /entrypoint.sh

RUN  chmod -R a+rX /etc/my.cnf && \
     chmod -R a+rX /etc/percona-xtradb-cluster.conf.d && \
     chmod -R a+rX /etc/sysconfig/mysql && \
     chmod 0755 /entrypoint.sh

ENTRYPOINT ["/tini", "--", "/entrypoint.sh"]

