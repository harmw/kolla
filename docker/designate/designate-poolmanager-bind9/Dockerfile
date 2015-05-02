FROM %%KOLLA_NAMESPACE%%/%%KOLLA_PREFIX%%designate-base
MAINTAINER Kolla Project (https://launchpad.net/kolla)

RUN yum install -y bind && \
	yum clean all && \
	easy_install supervisor && \
	pip install supervisor-stdout && \
	cp -pr /var/named /opt/kolla/var-named

ADD start-named.sh /opt/kolla/
ADD start-designate-pool-manager.sh /opt/kolla/

RUN mkdir -p /var/log/supervisor/
ADD supervisord.conf /etc/

CMD ["/usr/bin/supervisord"]
