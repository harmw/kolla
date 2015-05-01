#!/bin/bash
set -e

. /opt/kolla/kolla-common.sh
. /opt/kolla/config-designate.sh

check_required_vars KEYSTONE_ADMIN_TOKEN KEYSTONE_ADMIN_SERVICE_HOST \
                    DESIGNATE_KEYSTONE_USER DESIGNATE_KEYSTONE_PASSWORD \
                    KEYSTONE_AUTH_PROTOCOL ADMIN_TENANT_NAME \
                    DESIGNATE_API_SERVICE_HOST PUBLIC_IP

fail_unless_os_service_running keystone

# Nova stuff
#crudini --set /etc/designate/designate.conf handler:nova_fixed notification_topics \
#    notifications
#crudini --set /etc/designate/designate.conf handler:nova_fixed control_exchange \
#    nova
#crudini --set /etc/designate/designate.conf handler:nova_fixed format \
#    "'%(display_name)s.%(domain)s'"

exec /usr/bin/designate-sink
