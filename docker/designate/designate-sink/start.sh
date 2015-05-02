#!/bin/bash
set -e

. /opt/kolla/kolla-common.sh
. /opt/kolla/config-designate.sh

fail_unless_os_service_running keystone

CONF=/etc/designate/designate.conf
V="--verbose"
FWDDOMAINID=f26e0b32-736f-4f0a-831b-000aaaaaaa01
REVDOMAINID=f26e0b32-736f-4f0a-831b-000aaaaaaa02

crudini $V --set $CONF DEFAULT debug True
crudini $V --set $CONF service:sink enabled_notification_handlers nova_fixed,neutron_floatingip
crudini $V --set $CONF service:sink workers 1

# Nova
echo Configure Nova
crudini $V --set $CONF handler:nova_fixed domain_id $FWDDOMAINID
crudini $V --set $CONF handler:nova_fixed notification_topics notifications
crudini $V --set $CONF handler:nova_fixed control_exchange nova
crudini $V --set $CONF handler:nova_fixed format '%(display_name)s.%(domain)s'

# Neutron
echo Configure Neutron
crudini $V --set $CONF handler:neutron_floatingip domain_id $REVDOMAINID
crudini $V --set $CONF handler:neutron_floatingip notification_topics notifications
crudini $V --set $CONF handler:neutron_floatingip control_exchange neutron
crudini $V --set $CONF handler:neutron_floatingip format '%(display_name)s.%(domain)s'

#crudini --set $CONF handler:neutron_floatingip format '%(octet0)s-%(octet1)s-%(octet2)s-%(octet3)s.%(domain)s'

exec /usr/bin/designate-sink
