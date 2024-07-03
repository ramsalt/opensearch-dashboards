ARG NODEJS_VER

FROM node:${NODEJS_VER}-alpine

ARG DASHBOARDS_VER

ENV DASHBOARDS_VER=${DASHBOARDS_VER} \
    LANG="C.UTF-8" \
    JAVA_HOME="/usr/lib/jvm/java-1.8-openjdk/jre" \
    \
    PATH="${PATH}:/usr/share/dashboards/bin:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin" \
    \
    ADMIN_PASSWORD=admin

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
    addgroup -g 1000 -S dashboards; \
    adduser -u 1000 -D -S -s /bin/bash -G dashboards dashboards; \
    echo "PS1='\w\$ '" >> /home/dashboards/.bashrc; \
    \
    apk add --update --no-cache -t .dashboards-rundeps \
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
    apk add -U --no-cache -t .dashboards-edge-run-deps -X http://dl-cdn.alpinelinux.org/alpine/edge/main libc6-compat; \
    \
    apk add --no-cache -t .dashboards-build-deps gnupg openssl tar; \
    \
    gotpl_url="https://github.com/wodby/gotpl/releases/download/0.1.5/gotpl-alpine-linux-amd64-0.1.5.tar.gz"; \
    wget -qO- "${gotpl_url}" | tar xz -C /usr/local/bin; \
    \
    cd /tmp; \
    dashboards_url="https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/${DASHBOARDS_VER}/opensearch-dashboards-${DASHBOARDS_VER}-linux-x64.tar.gz"; \
    [ -f dashboards.tar.gz ] || curl -o dashboards.tar.gz -Lskj "${dashboards_url}"; \
    curl -o dashboards.tar.gz.sig -Lskj "${dashboards_url}.sig"; \
    GPG_KEYS=C5B7498965EFD1C2924BA9D539D319879310D3FC gpg_verify /tmp/dashboards.tar.gz.sig /tmp/dashboards.tar.gz; \
    \
    mkdir -p /usr/share/dashboards/node/bin; \
    tar zxf dashboards.tar.gz --strip-components=1 -C /usr/share/dashboards; \
    ln -sf /usr/bin/node /usr/share/dashboards/node/bin/node; \
    chown -R dashboards:dashboards /usr/share/dashboards; \
    \
    # Modify script to support custom node location.
    # https://discuss.elastic.co/t/dashboards-7-0-node-binary-location/180793
    ls -l /usr/share/dashboards/bin; \
    sed -i -E 's/(test -x "\$NODE"$)/\1 || NODE=$(which node)/' /usr/share/dashboards/bin/opensearch-dashboards; \
    \
    apk del --purge .dashboards-build-deps; \
    rm -rf /tmp/*; \
    rm -rf /var/cache/apk/*

USER 1000

WORKDIR /usr/share/dashboards

COPY templates /etc/gotpl

EXPOSE 5601

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["dashboards-docker"]
