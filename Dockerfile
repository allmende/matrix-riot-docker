FROM alpine:3.5

# Maintainer
MAINTAINER Silvio Fricke <silvio.fricke@gmail.com>, Jon Richter <jon@allmende.io>

# install homeserver template
COPY adds/start.sh /start.sh

# startup configuration
ENTRYPOINT ["/start.sh"]

# Git branch to download
ARG BV_VEC
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
        git \
        libevent \
        libffi \
        libjpeg-turbo \
        libssl1.0 \
        nodejs \
        sqlite-libs \
        unzip \
        || exit 1 ; \
    npm install -g webpack http-server \
    && curl -L https://github.com/vector-im/riot-web/archive/$BV_VEC.zip -o v.zip \
    && unzip v.zip \
    && rm v.zip \
    && mv riot-web-* riot-web \
    && cd riot-web \
    && npm install \
    && rm -rf /riot-web/node_modules/phantomjs-prebuilt/phantomjs \
    && GIT_VEC=$(git ls-remote https://github.com/vector-im/riot-web $BV_VEC | cut -f 1) \
    && echo "riot:  $BV_VEC ($GIT_VEC)" > /synapse.version \
    && cp config.sample.json config.json \
    && sed -i 's/\/matrix.org/\/matrix.allmende.io/' config.json \
    && sed -i 's/\/vector.im/\/riot.im/' config.json \
    && sed -i 's/Riot/Allmende/' config.json \
    && sed -i 's/\"matrix.org\"/\"matrix.org\",\ \"matrix.allmende.io\"/' config.json \
    && sed -i 's/piwik.riot.im/piwik.allmende.io/' config.json \
    && sed -i 's/1/13/' config.json \
    && npm run build \
    || exit 1 \
    ; \
    apk del \
        git \
        unzip \
        ; \
    rm -rf /var/lib/apk/* /var/cache/apk/*
