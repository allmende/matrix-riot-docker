FROM alpine:3.8

# Maintainer
MAINTAINER Silvio Fricke <silvio.fricke@gmail.com>, Jon Richter <jon@allmende.io>, Andreas Peters <support@aventer.biz>

# install homeserver template
COPY adds/start.sh /start.sh

# startup configuration
ENTRYPOINT ["/start.sh"]

# Git branch to download  
ARG BV_VEC=v1.0.3
ENV BV_VEC=${BV_VEC:-master}

# To rebuild the image, add `--build-arg REBUILD=$(date)` to your docker build
# command.
ARG REBUILD=0

# update and upgrade
# installing riot.im with nodejs/npm
RUN chmod a+x /start.sh \
    && apk update \
    && apk add \
        curl \
        libevent \
        libffi \
        libjpeg-turbo \
        libssl1.0 \
        nodejs \
        nodejs-npm \
        sqlite-libs \
	git \
        unzip \
        || exit 1 ; \
    npm install -g webpack http-server \
    && curl -L https://github.com/vector-im/riot-web/archive/$BV_VEC.zip -o v.zip \
    && unzip v.zip \
    && rm v.zip \
    && mv riot-web-* riot-web \
    && cd riot-web \
    && npm install

COPY config.allmende.json /riot-web/config.json

WORKDIR /riot-web
RUN npm run build \
    || exit 1 \
    ;

WORKDIR /

RUN mv /riot-web/webapp / ; \
    echo "riot:  $BV_VEC " > /webapp/version ; \
    rm -rf /riot-web ; \
    rm -rf /root/.npm ; \
    rm -rf /tmp/* ; \
    rm -rf /urs/lib/node_modules ; \
    apk del \
        unzip \
        libevent \
        libffi \
        libjpeg-turbo \
        libssl1.0 \
        sqlite-libs \
	git \
	curl \
        ; \
    rm -rf /var/lib/apk/* /var/cache/apk/*

