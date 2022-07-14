#!/usr/bin/env bash

# Rancher DNS
if [ ! -z "${DNSSERVER}" ]; then
echo "nameserver ${DNSSERVER}" > /etc/resolv.conf
fi

# cron timezone
if [ ! -z "${TZ}" ]; then
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
echo ${TZ} > /etc/timezone
fi

# minio
if [ ! -z "${MINIO_ENDPOINT_URL}" ]; then
mkdir -p /root/.config/rclone
echo "[minio]" > /root/.config/rclone/rclone.conf
echo "type = s3" >> /root/.config/rclone/rclone.conf
echo "provider = Minio" >> /root/.config/rclone/rclone.conf
echo "env_auth = false" >> /root/.config/rclone/rclone.conf
echo "access_key_id = ${AWS_ACCESS_KEY_ID}" >> /root/.config/rclone/rclone.conf
echo "secret_access_key = ${AWS_SECRET_ACCESS_KEY}" >> /root/.config/rclone/rclone.conf
echo "region = us-east-1" >> /root/.config/rclone/rclone.conf
echo "endpoint = ${MINIO_ENDPOINT_URL}" >> /root/.config/rclone/rclone.conf
echo "location_constraint =" >> /root/.config/rclone/rclone.conf
echo "server_side_encryption =" >> /root/.config/rclone/rclone.conf
chmod 600 /root/.config/rclone/rclone.conf
# rclone sync /cronwork minio:${MINIO_BACKET}/${HOSTNAME} --progress
# rclone lsd minio:
# rclone ls minio:${MINIO_BACKET}
fi

set -e

# переносим значения переменных из текущего окружения
env | while read -r LINE; do  # читаем результат команды 'env' построчно
    # делим строку на две части, используя в качестве разделителя "=" (см. IFS)
    IFS="=" read VAR VAL <<< ${LINE}
    # удаляем все предыдущие упоминания о переменной, игнорируя код возврата
    sed --in-place "/^${VAR}/d" /etc/security/pam_env.conf || true
    # добавляем определение новой переменной в конец файла
    echo "${VAR} DEFAULT=\"${VAL}\"" >> /etc/security/pam_env.conf
done

exec "$@"
