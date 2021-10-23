ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]


ARG BUILD_FROM
FROM $BUILD_FROM as builder

RUN apt-get update && apt-get install -y \
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

RUN git clone https://github.com/volkszaehler/libsml.git --depth 1 \
 && make install -C libsml/sml

RUN git clone https://github.com/rscada/libmbus.git --depth 1 \
 && cd libmbus \
 && ./build.sh \
 && make install

COPY . /vzlogger

RUN cmake -DBUILD_TEST=off \
 && make \
 && make install

FROM $BUILD_FROM 

LABEL Description="vzlogger"



# libsml is linked statically => no need to copy
COPY --from=builder /usr/local/bin/vzlogger /usr/local/bin/vzlogger
COPY --from=builder /usr/local/lib/libmbus.so* /usr/local/lib/
COPY run.sh /

RUN apt-get update && apt-get install -y \
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
    && rm -rf /var/lib/apt/lists/* \
    && chmod a+x /run.sh

# without running a user context, no exec is possible and without the dialout group no access to usb ir reader possible
RUN useradd -M -G dialout vz
USER vz

# Setup volume
VOLUME ["/cfg"]

CMD [ "/run.sh" ]
