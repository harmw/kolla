#!/bin/bash

set -e

. /opt/kolla/kolla-common.sh

: ${ADMIN_TENANT_NAME:=admin}
: ${DESIGNATE_DB_NAME:=designate}
: ${DESIGNATE_DB_USER:=designate}
: ${DESIGNATE_KEYSTONE_USER:=designate}
: ${KEYSTONE_AUTH_PROTOCOL:=http}
: ${PUBLIC_IP:=$DESIGNATE_API_PORT_8004_TCP_ADDR}
: ${RABBIT_USER:=guest}
: ${RABBIT_PASSWORD:=guest}

check_required_vars DESIGNATE_DB_PASSWORD DESIGNATE_KEYSTONE_PASSWORD \
                    KEYSTONE_PUBLIC_SERVICE_HOST RABBITMQ_SERVICE_HOST

fail_unless_db
dump_vars

cat > /openrc <<EOF
export OS_AUTH_URL="http://${KEYSTONE_PUBLIC_SERVICE_HOST}:5000/v2.0"
export OS_USERNAME="${DESIGNATE_KEYSTONE_USER}"
export OS_PASSWORD="${DESIGNATE_KEYSTONE_PASSWORD}"
export OS_TENANT_NAME="${ADMIN_TENANT_NAME}"
EOF

conf=/etc/designate/designate.conf

# regular stuff
crudini --set $conf DEFAULT log_file ""
crudini --set $conf DEFAULT use_stderr true
crudini --set $conf DEFAULT debug false
crudini --set $conf DEFAULT rpc_backend designate.openstack.common.rpc.impl_kombu
crudini --set $conf oslo_messaging_rabbit rabbit_host ${RABBITMQ_SERVICE_HOST}
crudini --set $conf oslo_messaging_rabbit rabbit_userid ${RABBIT_USER}
crudini --set $conf oslo_messaging_rabbit rabbit_password ${RABBIT_PASSWORD}
crudini --set $conf storage:sqlalchemy connection mysql://${DESIGNATE_DB_USER}:${DESIGNATE_DB_PASSWORD}@${MARIADB_SERVICE_HOST}/${DESIGNATE_DB_NAME}
crudini --set $conf service:api auth_strategy keystone
crudini --set $conf service:api api_host ${PUBLIC_IP}

# keystone
crudini --set $conf keystone_authtoken identity_uri "${KEYSTONE_AUTH_PROTOCOL}://${KEYSTONE_ADMIN_SERVICE_HOST}:${KEYSTONE_ADMIN_SERVICE_PORT}"
crudini --set $conf keystone_authtoken auth_uri "${KEYSTONE_AUTH_PROTOCOL}://${KEYSTONE_PUBLIC_SERVICE_HOST}:5000/v2.0"
crudini --set $conf keystone_authtoken admin_tenant_name "${ADMIN_TENANT_NAME}"
crudini --set $conf keystone_authtoken admin_user "${DESIGNATE_KEYSTONE_USER}"
crudini --set $conf keystone_authtoken admin_password "${DESIGNATE_KEYSTONE_PASSWORD}"

