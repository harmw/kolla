FROM %%KOLLA_NAMESPACE%%/%%KOLLA_PREFIX%%base
MAINTAINER Kolla Project (https://launchpad.net/kolla)

RUN curl -k -L -o /tmp/designate.tar.gz https://launchpad.net/designate/kilo/2015.1.0/+download/designate-2015.1.0.tar.gz && \
	yum -y install gcc tar python-pip MySQL-python && \
	yum clean all && \
	tar -xf /tmp/designate.tar.gz -C /tmp/ && \
	cd /tmp/designate-2015.1.0 && \
	pip install -r requirements.txt -r test-requirements.txt --upgrade && \
	python setup.py build && \
	python setup.py install && \
	mkdir -p /etc/designate && \
	cp etc/designate/designate.conf.sample /etc/designate/designate.conf && \
	cp etc/designate/api-paste.ini /etc/designate/api-paste.ini && \
	cp etc/designate/policy.json /etc/designate/policy.json && \
	cp etc/designate/rootwrap.conf.sample /etc/designate/rootwrap.conf

RUN mkdir -p /opt/kolla
COPY config-designate.sh /opt/kolla/config-designate.sh
