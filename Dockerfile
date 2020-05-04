FROM nginx:1.18.0

ENV CONSUL_TEMPLATE_VERSION=0.25.0

# Install consul template with hash-sum validation

RUN apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y -q unzip runit

ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip .
ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS .

RUN sha256sum --check consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS --ignore-missing --status && \
    rm consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS

RUN unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    rm consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    apt-get remove -y -q unzip

# Configure services to run

RUN rm -v /etc/nginx/conf.d/*
COPY ./source/nginx/nginx.service /etc/service/nginx/run

COPY ./source/consul-template/consul-template.service /etc/service/consul-template/run
COPY ./source/consul-template/consul-template.hcl /etc/consul-template/consul-template.hcl
COPY ./source/consul-template/app.ctmpl /etc/consul-template/app.ctmpl
COPY ./source/consul-template/maintenance/index.ctmpl /etc/consul-template/maintenance/index.ctmpl
COPY ./source/consul-template/maintenance/favicon.ico /www/favicon.ico

RUN chmod +x /etc/service/nginx/run && \
    chmod +x /etc/service/consul-template/run

ENTRYPOINT ["/usr/bin/runsvdir", "/etc/service"]
