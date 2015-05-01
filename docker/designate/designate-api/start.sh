#!/bin/bash
set -e

: ${INITDB:=true}

. /opt/kolla/kolla-common.sh
. /opt/kolla/config-designate.sh

check_required_vars KEYSTONE_ADMIN_TOKEN KEYSTONE_ADMIN_SERVICE_HOST \
                    DESIGNATE_KEYSTONE_USER DESIGNATE_KEYSTONE_PASSWORD \
                    KEYSTONE_AUTH_PROTOCOL ADMIN_TENANT_NAME \
                    DESIGNATE_API_SERVICE_HOST PUBLIC_IP

fail_unless_os_service_running keystone

export SERVICE_TOKEN="${KEYSTONE_ADMIN_TOKEN}"
export SERVICE_ENDPOINT="${KEYSTONE_AUTH_PROTOCOL}://${KEYSTONE_ADMIN_SERVICE_HOST}:35357/v2.0"

if [ "${INITDB}" == "true" ]
then
	echo "Configuring database"
	mysql -h ${MARIADB_SERVICE_HOST} -u root -p"${DB_ROOT_PASSWORD}" mysql <<EOF
CREATE DATABASE IF NOT EXISTS ${DESIGNATE_DB_NAME};
GRANT ALL PRIVILEGES ON ${DESIGNATE_DB_NAME}.* TO '${DESIGNATE_DB_USER}'@'%' IDENTIFIED BY '${DESIGNATE_DB_PASSWORD}'
EOF

	designate-manage database sync
fi

crux user-create \
    -n ${DESIGNATE_KEYSTONE_USER} \
    -p ${DESIGNATE_KEYSTONE_PASSWORD} \
    -t ${ADMIN_TENANT_NAME} \
    -r admin

crux endpoint-create \
    --remove-all \
    -n ${DESIGNATE_KEYSTONE_USER} \
    -t dns \
    -I "${KEYSTONE_AUTH_PROTOCOL}://${DESIGNATE_API_SERVICE_HOST}:9001/v1" \
    -P "${KEYSTONE_AUTH_PROTOCOL}://${PUBLIC_IP}:9001/v1" \
    -A "${KEYSTONE_AUTH_PROTOCOL}://${DESIGNATE_API_SERVICE_HOST}:9001/v1"

exec /usr/bin/designate-api
