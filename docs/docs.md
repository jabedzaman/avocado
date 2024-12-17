# Mariadb setup

```bash
docker exec -it mariadb /bin/sh
mysql -u root -p
CREATE USER '<user>'@'%' IDENTIFIED BY '<password>';
GRANT ALL PRIVILEGES ON *.* TO '<user>'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
exit
```

# Nginx setup

```bash
docker exec -it mariadb /bin/sh
mysql -u '<user>' -p
CREATE DATABASE nginx;
exit
```

# Minio setup

```bash
docker exec -it minio /bin/sh
mc alias set minio http://minio:9000 user password
mc admin prometheus generate minio
```

# Pi-hole setup

```bash
sudo systemctl stop systemd-resolved.service
sudo vi /etc/resolv.conf
# replace nameserver
# nameserver 1.1.1.1
```

# Psql setup

```bash
docker exec -it psql /bin/sh
psql -U postgres
CREATE USER <user> WITH PASSWORD '<password>';
ALTER USER <user> WITH SUPERUSER;
/q
```

Proxy the stream

- open nginx proxy manager
- create a new stream proxy
- add host `postgres` and port `5432`
