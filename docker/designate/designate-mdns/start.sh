#!/bin/bash
set -e

. /opt/kolla/kolla-common.sh
. /opt/kolla/config-designate.sh

MASTERNS=${PUBLIC_IP}
CONF=/etc/designate/designate.conf

crudini --set $CONF service:mdns workers 1
crudini --set $CONF service:mdns host ${MASTERNS}
crudini --set $CONF service:mdns port 5354
crudini --set $CONF service:mdns tcp_backlog 100
crudini --set $CONF service:mdns all_tcp False

exec /usr/bin/designate-mdns
