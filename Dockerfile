ARG PLATFORM=${BUILDPLATFORM:-linux/amd64}
ARG IMAGE=php
ARG TAG=8.5-cli-trixie
ARG SKIP_VALGRIND=0
# Full LLVM release version (major.minor.patch), kept up to date by Renovate from the official LLVM GitHub releases.
# Only the major part selects the apt.llvm.org suite and the package names. The full version exists so that the
# CI cache of the LLVM apt packages is invalidated (and apt.llvm.org contacted again) exactly when a new LLVM
# release is published, and never otherwise.
# renovate: datasource=github-releases depName=llvm/llvm-project
ARG LLVM_VERSION=23.1.0
# LLVM apt packages installed into the base image ("@" is replaced with the LLVM major version).
ARG LLVM_PACKAGES="clang-@ libclang-rt-@-dev lld-@ libc++-@-dev libc++abi-@-dev llvm-@ llvm-@-dev llvm-@-runtime"

FROM --platform=${PLATFORM} ${IMAGE}:${TAG} AS base

ARG LLVM_VERSION
ARG LLVM_PACKAGES

ENV USE_ZEND_ALLOC=0
ENV USE_TRACKED_ALLOC=1
ENV ZEND_DONT_UNLOAD_MODULES=1
ENV LC_ALL="C"

RUN --mount=type=bind,source=.,target=/build_context \
    docker-php-source extract \
 && if test -f "/etc/debian_version"; then \
      apt-get update  && \
      DEBIAN_FRONTEND="noninteractive" apt-get install -y "bison" "re2c" "zlib1g-dev" "libsqlite3-dev" "libxml2-dev" \
        "autoconf" "pkg-config" "make" "gcc" "rsync" "git" "ssh" "libc6-dbg" \
        "ca-certificates" "tzdata" "curl" "gnupg" \
        "lcov" "gzip" \
        "unzip" && \
      LLVM_APT_CODENAME="$(. "/etc/os-release" && printf '%s' "${VERSION_CODENAME}")" && \
      test -n "${LLVM_APT_CODENAME}" && \
      LLVM_MAJOR="${LLVM_VERSION%%.*}" && \
      LLVM_APT_KEYRING="/usr/share/keyrings/llvm-snapshot.gpg" && \
      LLVM_APT_SOURCE="deb [signed-by=${LLVM_APT_KEYRING}] https://apt.llvm.org/${LLVM_APT_CODENAME}/ llvm-toolchain-${LLVM_APT_CODENAME}-${LLVM_MAJOR} main" && \
      LLVM_DEBS_DIR="/build_context/llvm-debs/${LLVM_APT_CODENAME}-$(dpkg --print-architecture)" && \
      mkdir -p "/usr/share/keyrings" && \
      if test -f "${LLVM_DEBS_DIR}/llvm-snapshot.gpg"; then \
        cp "${LLVM_DEBS_DIR}/llvm-snapshot.gpg" "${LLVM_APT_KEYRING}"; \
      else \
        curl -fsSL "https://apt.llvm.org/llvm-snapshot.gpg.key" | gpg --dearmor --yes -o "${LLVM_APT_KEYRING}"; \
      fi && \
      if test -f "${LLVM_DEBS_DIR}/Packages"; then \
        echo "[Pskel] Installing LLVM ${LLVM_MAJOR} (release ${LLVM_VERSION}) from pre-fetched apt packages in ${LLVM_DEBS_DIR}." >&2 && \
        echo "deb [trusted=yes] file:${LLVM_DEBS_DIR} ./" > "/etc/apt/sources.list.d/llvm.list"; \
      else \
        echo "[Pskel] Installing LLVM ${LLVM_MAJOR} (release ${LLVM_VERSION}) from apt.llvm.org." >&2 && \
        echo "${LLVM_APT_SOURCE}" > "/etc/apt/sources.list.d/llvm.list"; \
      fi && \
      apt-get update && \
      apt-get install --no-install-recommends -y $(printf '%s' "${LLVM_PACKAGES}" | sed "s/@/${LLVM_MAJOR}/g") && \
      dpkg-query -W -f='[Pskel] Installed ${Package} ${Version}\n' "clang-${LLVM_MAJOR}" >&2 && \
      echo "${LLVM_APT_SOURCE}" > "/etc/apt/sources.list.d/llvm.list" && \
      update-alternatives --install "/usr/bin/clang" clang "/usr/bin/clang-${LLVM_MAJOR}" 100 && \
      update-alternatives --install "/usr/bin/clang++" clang++ "/usr/bin/clang++-${LLVM_MAJOR}" 100 && \
      update-alternatives --install "/usr/bin/ld.lld" ld.lld "/usr/bin/ld.lld-${LLVM_MAJOR}" 100 && \
      update-alternatives --install "/usr/bin/llvm-symbolizer" llvm-symbolizer "/usr/bin/llvm-symbolizer-${LLVM_MAJOR}" 100 && \
      update-alternatives --install "/usr/bin/llvm-config" llvm-config "/usr/bin/llvm-config-${LLVM_MAJOR}" 100; \
    else \
      apk add --no-cache "bison" "zlib-dev" "sqlite-dev" "libxml2-dev" "linux-headers" \
        "autoconf" "pkgconfig" "make" "gcc" "g++" "musl-dbg" \
        "musl-dev" "git" "openssh" \
        "patch" "lcov" "gzip" \
        "unzip" \
        "curl" "vim" "gdb" \
        "bash"; \
    fi

ARG SKIP_VALGRIND
# renovate: datasource=custom.valgrind depName=valgrind
ARG VALGRIND_VERSION=3.27.1
RUN --mount=type=bind,source=.,target=/build_context \
    if test "${SKIP_VALGRIND}" = "1"; then \
      echo "[Pskel] Skipping Valgrind build (SKIP_VALGRIND=1)." >&2; \
    elif ! test -f "/etc/debian_version"; then \
      echo "[Pskel] Error: Valgrind can only be built on Debian-based images." >&2; \
      echo "[Pskel] Pass SKIP_VALGRIND=1 to build a non-Debian (e.g. Alpine) image without Valgrind." >&2; \
      exit 1; \
    else \
      apt-get update && \
      DEBIAN_FRONTEND="noninteractive" apt-get install -y \
        "build-essential" "bzip2" "libc6-dev" "linux-libc-dev" && \
      VALGRIND_SRC_DIR="$(mktemp -d "${TMPDIR:-/tmp}/valgrind_src.XXXXXX")" && \
      if test -f "/build_context/valgrind-${VALGRIND_VERSION}.tar.bz2"; then \
        echo "[Pskel] Using pre-fetched Valgrind tarball." >&2 && \
        cp "/build_context/valgrind-${VALGRIND_VERSION}.tar.bz2" "${VALGRIND_SRC_DIR}/valgrind-${VALGRIND_VERSION}.tar.bz2"; \
      else \
        echo "[Pskel] Downloading Valgrind tarball from sourceware.org." >&2 && \
        curl -fsSL --retry 5 --retry-delay 10 --retry-all-errors \
          -o "${VALGRIND_SRC_DIR}/valgrind-${VALGRIND_VERSION}.tar.bz2" \
          "https://sourceware.org/pub/valgrind/valgrind-${VALGRIND_VERSION}.tar.bz2"; \
      fi && \
      tar -xjf "${VALGRIND_SRC_DIR}/valgrind-${VALGRIND_VERSION}.tar.bz2" -C "${VALGRIND_SRC_DIR}" && \
      cd "${VALGRIND_SRC_DIR}/valgrind-${VALGRIND_VERSION}" && \
        ./configure && \
        make -j"$(nproc)" && \
        make install && \
      cd - && \
      rm -rf "${VALGRIND_SRC_DIR}" && \
      valgrind --version; \
    fi

COPY ./.pskel "/opt/pskel/.pskel"
COPY ./pskel.sh "/opt/pskel/pskel.sh"
COPY ./patches "/patches"
COPY ./ext "/ext"

RUN chmod +x "/opt/pskel/pskel.sh" \
 && ln -sf "/opt/pskel/pskel.sh" "/usr/local/bin/pskel"

RUN printf '%s\n' \
      '#!/bin/sh' \
      'set -e' \
      '' \
      'if test -n "${GITHUB_ACTIONS}" && test -d "${PHP_CACHE_DIR}"; then' \
      '  echo "[Pskel > Cache] GitHub Actions environment detected, checking for cached binaries..." >&2' \
      '  for CACHE_ENTRY in "${PHP_CACHE_DIR}"/*; do' \
      '    if test -f "${CACHE_ENTRY}/.build_complete"; then' \
      '      for BIN in "${CACHE_ENTRY}/usr/local/bin/"*; do' \
      '        if test -f "${BIN}"; then' \
      '          BIN_NAME="$(basename "${BIN}")"' \
      '          ln -sf "${BIN}" "/usr/local/bin/${BIN_NAME}"' \
      '          echo "[Pskel > Cache] Restored: ${BIN_NAME}" >&2' \
      '        fi' \
      '      done' \
      '      if test -d "${CACHE_ENTRY}/usr/local/include"; then' \
      '        cp -an "${CACHE_ENTRY}/usr/local/include/"* "/usr/local/include/" 2>/dev/null || true' \
      '      fi' \
      '    fi' \
      '  done' \
      'fi' \
      '' \
      'exec "$@"' \
      > "/usr/local/bin/docker-entrypoint.sh"

RUN chmod +x "/usr/local/bin/docker-entrypoint.sh"

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]

FROM --platform=${PLATFORM} ${IMAGE}:${TAG} AS builder

ENV LC_ALL="C"

RUN docker-php-source extract \
 && if test -f "/etc/debian_version"; then \
      apt-get update && \
      DEBIAN_FRONTEND="noninteractive" apt-get install -y ${PHPIZE_DEPS} "patch" "zip" && \
      rm -rf "/var/lib/apt/lists/"*; \
    else \
      apk add --no-cache ${PHPIZE_DEPS} "patch" "zip"; \
    fi

COPY ./.pskel "/opt/pskel/.pskel"
COPY ./pskel.sh "/opt/pskel/pskel.sh"
COPY ./patches "/patches"
COPY ./ext "/ext"

RUN chmod +x "/opt/pskel/pskel.sh" \
 && ln -sf "/opt/pskel/pskel.sh" "/usr/local/bin/pskel"

CMD ["sh"]

FROM --platform=${PLATFORM} base AS devcontainer

ARG LLVM_VERSION

RUN if test -f "/etc/debian_version"; then \
      LLVM_MAJOR="${LLVM_VERSION%%.*}" && \
      mkdir -p -m 755 "/etc/apt/keyrings" && \
      curl -fsSL "https://cli.github.com/packages/githubcli-archive-keyring.gpg" -o "/etc/apt/keyrings/githubcli-archive-keyring.gpg" && \
      chmod go+r "/etc/apt/keyrings/githubcli-archive-keyring.gpg" && \
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > "/etc/apt/sources.list.d/github-cli.list" && \
      apt-get update && \
      apt-get install -y --no-install-recommends \
        "gh" "vim" "gdb" \
        "clang-tools-${LLVM_MAJOR}" "clang-format-${LLVM_MAJOR}" "clang-tidy-${LLVM_MAJOR}" "lldb-${LLVM_MAJOR}" && \
      update-alternatives --install "/usr/bin/clang-tidy" clang-tidy "/usr/bin/clang-tidy-${LLVM_MAJOR}" 100 && \
      update-alternatives --install "/usr/bin/lldb" lldb "/usr/bin/lldb-${LLVM_MAJOR}" 100 && \
      update-alternatives --install "/usr/bin/clang-format" clang-format "/usr/bin/clang-format-${LLVM_MAJOR}" 100 && \
      rm -rf "/var/lib/apt/lists/"*; \
    else \
      apk add --no-cache "github-cli"; \
    fi
