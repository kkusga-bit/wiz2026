#!/bin/bash
set -eux

apt-get update -y
apt-get install -y gnupg curl awscli cron

curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.4.list

apt-get update -y
apt-get install -y mongodb-org mongodb-database-tools #의도된 보안 리스크 mongodb 4.4 구버전 설치

cat > /etc/mongod.conf <<EOF
storage:
  dbPath: /var/lib/mongodb
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log
net:
  port: 27017
  bindIp: 0.0.0.0   #의도된 보안 리스크 SG가 최종 접근 제한
processManagement:
  timeZoneInfo: /usr/share/zoneinfo
EOF

systemctl enable mongod
systemctl start mongod
sleep 20

mongo <<EOF
use admin
db.createUser({
  user: "${mongo_admin_user}",
  pwd: "${mongo_admin_password}",
  roles: [{ role: "root", db: "admin" }]
})
use go-mongodb
db.createUser({
  user: "${mongo_app_user}",
  pwd: "${mongo_app_password}",
  roles: [{ role: "readWrite", db: "go-mongodb" }]
})
db.todos.insertOne({task: "seed data", createdAt: new Date()})
EOF

cat >> /etc/mongod.conf <<EOF

security:
  authorization: enabled
EOF

systemctl restart mongod

cat > /home/ubuntu/mongo_backup.sh <<EOF
#!/bin/bash
DATE=\$(date +%F-%H-%M-%S)
BACKUP_DIR="/tmp/mongo-backup-\$DATE"
ARCHIVE="/tmp/mongo-backup-\$DATE.tar.gz"

mongodump --uri="mongodb://${mongo_app_user}:${mongo_app_password}@localhost:27017/go-mongodb?authSource=go-mongodb" --out="\$BACKUP_DIR"
tar -czf "\$ARCHIVE" -C /tmp "mongo-backup-\$DATE"
aws s3 cp "\$ARCHIVE" "s3://${bucket_name}/"
rm -rf "\$BACKUP_DIR" "\$ARCHIVE"
EOF

chmod +x /home/ubuntu/mongo_backup.sh
chown ubuntu:ubuntu /home/ubuntu/mongo_backup.sh

cat > /etc/cron.d/mongo-backup <<EOF
0 2 * * * ubuntu /home/ubuntu/mongo_backup.sh >> /home/ubuntu/backup.log 2>&1
EOF

chmod 644 /etc/cron.d/mongo-backup
systemctl restart cron