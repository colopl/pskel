ARG PLATFORM=${BUILDPLATFORM:-linux/amd64}
ARG IMAGE=php
ARG TAG=8.4-cli-bookworm

FROM --platform=${PLATFORM} ${IMAGE}:${TAG}

ENV USE_ZEND_ALLOC=0
ENV USE_TRACKED_ALLOC=1
ENV ZEND_DONT_UNLOAD_MODULES=1
ENV LC_ALL="C"

RUN docker-php-source extract \
 && if test -f "/etc/debian_version"; then \
      apt-get update \
 &&   DEBIAN_FRONTEND="noninteractive" apt-get install -y "bison" "re2c" "zlib1g-dev" "libsqlite3-dev" "libxml2-dev" \
        "autoconf" "pkg-config" "make" "gcc" "valgrind" "rsync" "git" "ssh" \
        "clang-19" \
        "lcov" "gzip" \
        "vim" \
 &&   update-alternatives --install "/usr/bin/clang" clang "/usr/bin/clang-19" 100 \
 &&   update-alternatives --install "/usr/bin/clang++" clang++ "/usr/bin/clang++-19" 100; \
    else \
      apk add --no-cache "bison" "zlib-dev" "sqlite-dev" "libxml2-dev" \
        "autoconf" "pkgconfig" "make" "gcc" "g++" "valgrind" "valgrind-dev" \
        "musl-dev" "rsync" "git" "openssh" \
        "patch" "lcov" "gzip" \
        "vim"; \
    fi

COPY ./pskel.sh /usr/local/bin/pskel
COPY ./patches /patches
COPY ./ext /ext
