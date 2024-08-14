ARG PLATFORM=${BUILDPLATFORM:-linux/amd64}
ARG IMAGE=php
ARG TAG=8.3

FROM ${IMAGE}:${TAG} AS php-source

RUN docker-php-source extract

FROM --platform=${PLATFORM} ubuntu:24.04

COPY --from=php-source "/usr/src/php" "/usr/src/php"

ARG PSKEL_NON_NATIVE=""

COPY ./pskel.sh /usr/local/bin/pskel

RUN if test -f "/etc/debian_version"; then \
      apt-get update \
 &&   DEBIAN_FRONTEND="noninteractive" apt-get install -y "bison" "re2c" "zlib1g-dev" "libsqlite3-dev" "libxml2-dev" \
        "autoconf" "pkg-config" "make" "gcc" "valgrind" "llvm" "clang" "git"; \
    else \
      apk add --no-cache "bison" "zlib-dev" "sqlite-dev" "libxml2-dev" \
        "autoconf" "pkgconfig" "make" "gcc" "valgrind" "valgrind-dev" \
        "musl-dev" "git"; \
    fi \
 && pskel build \
 && if test "x${PSKEL_NON_NATIVE}" = "x"; then \
      export CFLAGS="-DZEND_TRACK_ARENA_ALLOC" \
 &&   export CPPFLAGS="${CFLAGS}" \
 &&   export BASE_OPTS="--enable-debug $(php -r "echo PHP_ZTS === 1 ? '--enable-zts' : '';") --enable-option-checking=fatal --disable-phpdbg --disable-cgi --disable-fpm --enable-cli --without-pcre-jit --disable-opcache-jit" \
 &&   CC="$(which "gcc")" CXX="$(which "g++")" CONFIGURE_OPTS="${BASE_OPTS}" pskel build "debug" \
 &&   CC="$(which "gcc")" CXX="$(which "g++")" CONFIGURE_OPTS="${BASE_OPTS} --with-valgrind" pskel build "gcc-valgrind" \
 &&   if test -f "/etc/debian_version"; then \
        CC="$(which "clang")" CXX="$(which "clang++")" CONFIGURE_OPTS="${BASE_OPTS} --enable-memory-sanitizer" pskel build "clang-msan" \
 &&     CC="$(which "clang")" CXX="$(which "clang++")" LDFLAGS="${LDFLAGS} -fsanitize=address" CONFIGURE_OPTS="${BASE_OPTS} --enable-address-sanitizer" pskel build "clang-asan" \
 &&     CC="$(which "clang")" CXX="$(which "clang++")" LDFLAGS="${LDFLAGS} -fsanitize=undefined" CONFIGURE_OPTS="${BASE_OPTS} --enable-undefined-sanitizer" pskel build "clang-ubsan"; \
      fi; \
    fi

COPY ./ext /ext

ENTRYPOINT [ "/usr/local/bin/pskel" ]
