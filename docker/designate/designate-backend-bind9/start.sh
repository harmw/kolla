#!/bin/bash
NAMEDCFG=/etc/named.conf

# /var/named is coming from a VOLUME definition but at first boot it needs to
# be populated from the original container since else it would be missing some
# Bind9 core files.

if [ ! -f /var/named/named.ca ]
then
	cp -pr /opt/kolla/var-named/* /var/named/
fi
 
# When rndc adds a new domain, bind adds the call in an nzf file in this
# directory.
chmod 770 /var/named
chown root:named /var/named

# Disable recursion but listen on all interfaces.
sed -i -r "s/(recursion) yes/\1 no/" $NAMEDCFG
sed -i -r "/listen-on port 53 \{ 127.0.0.1; \};/d" $NAMEDCFG
# bummer, no IPv6
#sed -i -r "s/(listen-on-v6 port 53 \{) any(; \};)/\1 :: \2/" $NAMEDCFG
sed -i -r "s,/\* Path to ISC DLV key \*/,allow-new-zones yes;," $NAMEDCFG
sed -i -r "/allow-query .+;/d" $NAMEDCFG
	
cat > /etc/rndc.conf <<EOF
options {
	default-key "rndc-key";
	default-server 127.0.0.1;
	default-port 953;
};
EOF
cat /etc/rndc.key >> /etc/rndc.conf

# Launch.
exec /usr/sbin/named -u named -g 
