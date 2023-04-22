ARG NODEJS_VER

FROM node:${NODEJS_VER}-alpine

ARG KIBANA_VER

ENV KIBANA_VER=${KIBANA_VER} \
    LANG="C.UTF-8" \
    JAVA_HOME="/usr/lib/jvm/java-1.8-openjdk/jre" \
    \
    PATH="${PATH}:/usr/share/kibana/bin:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin"

COPY bin /usr/local/bin/

USER root

RUN set -ex; \
    { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home; \
	chmod +x /usr/local/bin/docker-java-home; \
    \
    deluser node; \
    addgroup -g 1000 -S kibana; \
    adduser -u 1000 -D -S -s /bin/bash -G kibana kibana; \
    echo "PS1='\w\$ '" >> /home/kibana/.bashrc; \
    \
    apk add --update --no-cache -t .kibana-rundeps \
        bash \
        ca-certificates \
        chromium \
        curl \
        freetype \
        freetype-dev \
        harfbuzz \
        make \
        nss \
        openjdk11-jre \
        sed \
        ttf-freefont; \
    \
    apk add -U --no-cache -t .kibana-edge-run-deps -X http://dl-cdn.alpinelinux.org/alpine/edge/main libc6-compat; \
    ln -s /lib64/ld-linux-x86-64.so.2 /lib/ld-linux-x86-64.so.2; \
    \
    apk add --no-cache -t .kibana-build-deps gnupg openssl tar; \
    \
    gotpl_url="https://github.com/wodby/gotpl/releases/download/0.1.5/gotpl-alpine-linux-amd64-0.1.5.tar.gz"; \
    wget -qO- "${gotpl_url}" | tar xz -C /usr/local/bin; 

COPY opensearch-dashboards-${KIBANA_VER}-linux-x64.tar.gz /tmp/kibana.tar.gz

RUN set -ex; \
    cd /tmp; \
    kibana_url="https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/${KIBANA_VER}/opensearch-dashboards-${KIBANA_VER}-linux-x64.tar.gz"; \
    [ -f kibana.tar.gz ] || curl -o kibana.tar.gz -Lskj "${kibana_url}"; \
    curl -o kibana.tar.gz.sig -Lskj "${kibana_url}.sig"; \
    GPG_KEYS=C5B7498965EFD1C2924BA9D539D319879310D3FC gpg_verify /tmp/kibana.tar.gz.sig /tmp/kibana.tar.gz; \
    \
    mkdir -p /usr/share/kibana/node/bin; \
    tar zxf kibana.tar.gz --strip-components=1 -C /usr/share/kibana; \
    ln -sf /usr/bin/node /usr/share/kibana/node/bin/node; \
    chown -R kibana:kibana /usr/share/kibana; \
    \
    # Modify script to support custom node location.
    # https://discuss.elastic.co/t/kibana-7-0-node-binary-location/180793
    ls -l /usr/share/kibana/bin; \
    sed -i -E 's/(test -x "\$NODE"$)/\1 || NODE=$(which node)/' /usr/share/kibana/bin/opensearch-dashboards; \
    \
    apk del --purge .kibana-build-deps; \
    rm -rf /tmp/*; \
    rm -rf /var/cache/apk/*

USER 1000

WORKDIR /usr/share/kibana

COPY templates /etc/gotpl

EXPOSE 5601

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["kibana-docker"]
