ARG PLATFORM=${BUILDPLATFORM:-linux/amd64}
ARG IMAGE=php
ARG TAG=8.3-cli-bookworm

FROM --platform=${PLATFORM} ${IMAGE}:${TAG}

ARG PSKEL_SKIP_BUILD=""

COPY ./pskel.sh /usr/local/bin/pskel

RUN docker-php-source extract \
 && if test -f "/etc/debian_version"; then \
      echo "deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm main" > "/etc/apt/sources.list.d/llvm.list" \
 &&   echo "deb-src http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm main" >> "/etc/apt/sources.list.d/llvm.list" \
 &&   curl -fsSL "https://apt.llvm.org/llvm-snapshot.gpg.key" -o "/etc/apt/trusted.gpg.d/apt.llvm.org.asc" \
 &&   apt-get update \
 &&   DEBIAN_FRONTEND="noninteractive" apt-get install -y "bison" "re2c" "zlib1g-dev" "libsqlite3-dev" "libxml2-dev" \
        "autoconf" "pkg-config" "make" "gcc" "valgrind" "git" \
        "clang-20" \
 &&   update-alternatives --install "/usr/bin/clang" clang "/usr/bin/clang-20" 100 \
 &&   update-alternatives --install "/usr/bin/clang++" clang++ "/usr/bin/clang++-20" 100; \
    else \
      apk add --no-cache "bison" "zlib-dev" "sqlite-dev" "libxml2-dev" \
        "autoconf" "pkgconfig" "make" "gcc" "valgrind" "valgrind-dev" \
        "musl-dev" "git"; \
    fi \
 && if test "x${PSKEL_SKIP_BUILD}" = "x"; then \
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
