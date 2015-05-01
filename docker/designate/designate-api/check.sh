#!/bin/bash
RES=0
. /openrc

if ! keystone token-get > /dev/null
then
	echo "ERROR: keystone token-get failed" >&2
	RES=1
else
	if ! designate domain-list > /dev/null
	then
		echo "ERROR: designate domain-list failed" >&2
		RES=1
	fi
fi

exit $RES
