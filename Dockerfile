ARG PLATFORM=linux/arm64/v8
ARG IMAGE=php
ARG TAG=8.3-cli-bookworm

FROM --platform=${PLATFORM} ${IMAGE}:${TAG}

ARG PSKEL_SKIP_BUILD=""

COPY ./pskel.sh /usr/local/bin/pskel

RUN export CFLAGS="-fPIE -DZEND_TRACK_ARENA_ALLOC" \
 && export CPPFLAGS="${CFLAGS}" \
 && export BASE_OPTS="--enable-option-checking=fatal --enable-debug --disable-phpdbg --disable-cgi --disable-fpm --enable-cli --without-pcre-jit --disable-opcache-jit" \
 && if test "x${PSKEL_SKIP_BUILD}" = "x"; then \
      if test -f "/etc/debian_version"; then \
        apt-get update \
 &&     DEBIAN_FRONTEND="noninteractive" apt-get install -y "bison" "re2c" "zlib1g-dev" "libsqlite3-dev" "libxml2-dev" \
          "autoconf" "pkg-config" "make" "gcc" "valgrind" "llvm" "clang" \
 &&     CC="$(which "clang")" CXX="$(which "clang++")" CONFIGURE_OPTS="${BASE_OPTS} --enable-memory-sanitizer" pskel build "clang-msan" \
 &&     CC="$(which "clang")" CXX="$(which "clang++")" CONFIGURE_OPTS="${BASE_OPTS} --enable-address-sanitizer" pskel build "clang-asan" \
 &&     CC="$(which "clang")" CXX="$(which "clang++")" CONFIGURE_OPTS="${BASE_OPTS} --enable-undefined-sanitizer" pskel build "clang-ubsan"; \
      else \
        apk add --no-cache "bison" "zlib-dev" "sqlite-dev" "libxml2-dev" \
          "autoconf" "pkgconfig" "make" "gcc" "valgrind" "valgrind-dev" \
          "musl-dev"; \
      fi \
 &&   CC="$(which "gcc")" CXX="$(which "g+++")" CONFIGURE_OPTS="${BASE_OPTS}" pskel build "debug" \
 &&   CC="$(which "gcc")" CXX="$(which "g+++")" CONFIGURE_OPTS="${BASE_OPTS} --with-valgrind" pskel build "gcc-valgrind"; \
	fi \
 && if test -f "/etc/debian_version"; then \
      apt-get update && apt-get install -y "git"; \
    else \
      apk add --no-cache "git"; \
    fi

COPY ./ext /ext

ENTRYPOINT [ "/usr/local/bin/pskel" ]
