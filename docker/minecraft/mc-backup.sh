docker-compose down
filedate=$(date '+%s')
tar -cvf /home/vmstan/backups/world-${filedate}.tar /opt/minecraft/config/world
chown vmstan:vmstan /home/vmstan/backups/world-${filedate}.tar
docker-compose pull
docker-compose up -d
