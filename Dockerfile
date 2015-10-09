FROM java:8-jre
MAINTAINER Andres Lamont <andres@orikami.nl>

RUN curl http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
RUN echo 'deb http://packages.elasticsearch.org/elasticsearch/2.0/debian stable main' >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y elasticsearch
RUN apt-get install -y nginx supervisor apache2-utils
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*
RUN /usr/share/elasticsearch/bin/plugin install lmenezes/elasticsearch-kopf/2.0

ENV ELASTICSEARCH_USER **None**
ENV ELASTICSEARCH_PASS **None**

ENV PATH /usr/share/elasticsearch/bin:$PATH

RUN set -ex \
	&& for path in \
		/usr/share/elasticsearch/data \
		/usr/share/elasticsearch/logs \
		/usr/share/elasticsearch/config \
		/usr/share/elasticsearch/config/scripts \
	; do \
		mkdir -p "$path"; \
		chown -R elasticsearch:elasticsearch "$path"; \
	done

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD run.sh /run.sh
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
ADD nginx_default /etc/nginx/sites-enabled/default
RUN chmod +x /*.sh

EXPOSE 9200
CMD ["/run.sh"]
