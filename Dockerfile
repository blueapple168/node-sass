FROM node:10.16-jessie

MAINTAINER blueapple1120@qq.com
# Use unicode
RUN locale-gen C.UTF-8 || true
ENV LANG=C.UTF-8

RUN apt-get update && \
    apt-get install -y  -q --no-install-recommends \
    mercurial xvfb \
    locales sudo openssh-client ca-certificates tar gzip parallel \
    net-tools netcat unzip zip bzip2 apt-transport-https build-essential libssl-dev \
    curl g++ gcc git make wget && rm -rf /var/lib/apt/lists/* && apt-get -y autoclean && \

# Set timezone to CST by default
    ln -sf /usr/share/zoneinfo/PRC /etc/localtime && \
# Install jq    
    JQ_URL=$(curl --location --fail --retry 3 https://api.github.com/repos/stedolan/jq/releases/latest  | grep browser_download_url | grep '/jq-linux64"' | grep -o -e 'https.*jq-linux64') && \
    curl --silent --show-error --location --fail --retry 3 --output /usr/bin/jq $JQ_URL && \
    chmod +x /usr/bin/jq && \
    rm -rf /tmp/* \
           /var/tmp/* \
           /var/cache/*
    
# install libsass
RUN git clone https://github.com/sass/sassc && cd sassc && \
    git clone https://github.com/sass/libsass && \
    SASS_LIBSASS_PATH=/sassc/libsass make && \
    mv bin/sassc /usr/bin/sassc && \
    cd ../ && rm -rf /sassc

# created node-sass binary
ENV SASS_BINARY_PATH=/usr/lib/node_modules/node-sass/build/Release/binding.node
RUN git clone --recursive https://github.com/sass/node-sass.git && \
    cd node-sass && \
    git submodule update --init --recursive && \
    npm install && \
    node scripts/build -f && \
    cd ../ && rm -rf node-sass

# add binary path of node-sass to .npmrc
RUN touch $HOME/.npmrc && echo "sass_binary_cache=${SASS_BINARY_PATH}" >> $HOME/.npmrc

ENV SKIP_SASS_BINARY_DOWNLOAD_FOR_CI true
ENV SKIP_NODE_SASS_TESTS true

# Install other app
RUN npm install -g node-gyp && \
    npm i -g @webpack-contrib/tag-versions && \
    npm install -g vuepress && \
    npm install -g postcss-cli && \
    npm install --unsafe-perm -g node-sass && \
    npm install -g express && \
    npm install -g webpack && \
    npm install -g vue && \
    npm install -g vue-cropper && \
    npm install -g vue-cli && \
    npm install -g vue-ls && \
    npm install -g vue-router && \
    npm install -g vue-svg-component-runtime && \
    npm install -g vuex && \
    npm install -g grunt-cli && \
    npm install -g bower && \
    npm install -g gulp && \
    npm install -g ant-design-vue@1.3.9 && \
    npm install -g less@3.8.1 && \
    npm install -g less-loader@4.1.0 && \
    npm install -g axios@0.18.0 && \
    npm install -g js-base64@2.5.1 && \
    npm install -g enquire.js@2.1.6 && \
    npm install -g moment@2.24.0 && \
    npm install -g nprogress@0.2.0 && \
    npm install -g lodash.clonedeep@4.5.0 && \
    npm install -g lodash.get@4.4.2 && \
    npm install -g lodash.pick@4.4.0 && \
    npm install -g node-emoji && \
    npm install -g cnpm --registry=https://registry.npm.taobao.org && \
    npm install
