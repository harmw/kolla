#!/bin/bash
set -e

. /opt/kolla/kolla-common.sh
. /opt/kolla/config-designate.sh

MASTERNS=${PUBLIC_IP}
MEMCACHED_HOST=127.0.0.1

CONF=/etc/designate/designate.conf

# Hardcoded id's for the default pool.
POOLID=794ccc2c-d751-44fe-b57f-8894c9f5c842
NSS=12d8dbb9-5744-49f2-b536-f4950387ae9d
TARGETS=f26e0b32-736f-4f0a-831b-039a415c481d

crudini --set $CONF service:pool_manager workers 2
crudini --set $CONF service:pool_manager enable_recovery_timer false
crudini --set $CONF service:pool_manager periodic_recovery_interval 120
crudini --set $CONF service:pool_manager enable_sync_timer true
crudini --set $CONF service:pool_manager periodic_sync_interval 1800
crudini --set $CONF service:pool_manager poll_max_retries 10
crudini --set $CONF service:pool_manager poll_delay 5
crudini --set $CONF service:pool_manager poll_retry_interval 15
crudini --set $CONF service:pool_manager pool_id $POOLID
crudini --set $CONF service:pool_manager cache_driver noop #memcache
#crudini --set $CONF service:pool_manager memcached_servers ${MEMCACHED_HOST}

crudini --set $CONF pool:$POOLID nameservers $NSS
crudini --set $CONF pool:$POOLID targets $TARGETS

crudini --set $CONF pool_target:$TARGETS type bind9
crudini --set $CONF pool_target:$TARGETS options "rndc_host: 127.0.0.1, rndc_key: /etc/rndc.key, rndc_conf_path: /etc/rndc.conf"
crudini --set $CONF pool_target:$TARGETS masters ${MASTERNS}:5354

crudini --set $CONF pool_nameserver:$NSS host ${MASTERNS}
crudini --set $CONF pool_nameserver:$NSS port 53

exec /usr/bin/designate-pool-manager
