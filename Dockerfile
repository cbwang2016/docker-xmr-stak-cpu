FROM ubuntu:16.04

RUN apt-get update \
    && apt-get -qq --no-install-recommends install \
        libmicrohttpd10 \
        libssl1.0.0 \
    && rm -r /var/lib/apt/lists/*

ENV XMR_STAK_CPU_VERSION v1.1.0-1.2.0

RUN set -x \
    && buildDeps=' \
        ca-certificates \
        cmake \
        curl \
        g++ \
        libmicrohttpd-dev \
        libssl-dev \
        make \
    ' \
    && apt-get -qq update \
    && apt-get -qq --no-install-recommends install nginx $buildDeps \
    && rm -rf /var/lib/apt/lists/* \
    \
    && mkdir -p /usr/local/src/xmr-stak-cpu/build \
    && cd /usr/local/src/xmr-stak-cpu/ \
    && curl -sL https://github.com/fireice-uk/xmr-stak-cpu/archive/$XMR_STAK_CPU_VERSION.tar.gz | tar -xz --strip-components=1 \
    && sed -i 's/constexpr double fDevDonationLevel.*/constexpr double fDevDonationLevel = 0.0;/' donate-level.h \
    && cd build \
    && cmake .. \
    && make -j$(nproc) \
    && cp bin/xmr-stak-cpu /usr/local/bin/ \
    && sed -r \
        -e 's/^("pool_address" : ).*,/\1"la01.supportxmr.com:3333",/' \
        -e 's/^("wallet_address" : ).*,/\1"46KvXf51aHaFif52Cts7LRTgKu9jP2yeFCYJwXDGCT15MehDz6e9sDWCD5W6a5aBxu18KGbAnfagRc4Hm9AftWGpM8fB5M6",/' \
        -e 's/^("pool_password" : ).*,/\1"docker-test:x",/' \
        ../config.txt > /usr/local/etc/config.txt \
    \
    && rm -r /usr/local/src/xmr-stak-cpu \
    && apt-get -qq --auto-remove purge $buildDeps
RUN service nginx start
RUN xmr-stak-cpu && apt update
RUN xmr-stak-cpu
EXPOSE 80
ENTRYPOINT ["xmr-stak-cpu"]
CMD ["/usr/local/etc/config.txt"]
