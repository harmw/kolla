#!/bin/bash
set -e

. /opt/kolla/kolla-common.sh
. /opt/kolla/config-designate.sh

exec /usr/bin/designate-central
