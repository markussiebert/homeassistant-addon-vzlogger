ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base/amd64:1d0629c

# hadolint ignore=DL3006
FROM ${BUILD_FROM} as builder

ENV LANG C.UTF-8

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git-core \
    cmake \
    pkg-config \
    libcurl4-openssl-dev \
    libgnutls28-dev \
    libsasl2-dev \
    uuid-dev \
    libtool \
    libssl-dev \
    libgcrypt20-dev \
    libmicrohttpd-dev \
    libltdl-dev \
    libjson-c-dev \
    libleptonica-dev \
    libmosquitto-dev \
    libunistring-dev \
    dh-autoreconf \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /vzlogger
RUN git clone https://github.com/volkszaehler/libsml.git --depth 1 && \
    git clone https://github.com/rscada/libmbus.git --depth 1 && \
    git clone https://github.com/volkszaehler/vzlogger.git --depth 1

WORKDIR /vzlogger/libsml
RUN make install -C sml

WORKDIR /vzlogger/libmbus
RUN ./build.sh && make install

WORKDIR /vzlogger/vzlogger
RUN cmake -DBUILD_TEST=off && \
    make && make install

# hadolint ignore=DL3006
FROM $BUILD_FROM 

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Markus Siebert <mail@markussiebert.com>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Markus Siebert <mail@markussiebert.com>" \
    org.opencontainers.image.authors="Markus Siebert <mail@markussiebert.com>" \
    org.opencontainers.image.licenses="GNU General Public License v3.0" \
    org.opencontainers.image.url="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

# libsml is linked statically => no need to copy
COPY --from=builder /usr/local/bin/vzlogger /usr/local/bin/vzlogger
COPY --from=builder /usr/local/lib/libmbus.so* /usr/local/lib/
COPY run.sh /

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4 \
    libgnutls30 \
    libsasl2-2  \
    libuuid1 \
    libssl1.1 \
    libgcrypt20  \
    libmicrohttpd12 \
    libltdl7 \
    libatomic1 \
    libjson-c3 \
    liblept5 \
    libmosquitto1 \
    libunistring2 \
    && rm -rf /var/lib/apt/lists/*

# without running a user context, no exec is possible and without the dialout group no access to usb ir reader possible
RUN useradd -M -G dialout vz
USER vz

# Setup volume
VOLUME ["/cfg"]