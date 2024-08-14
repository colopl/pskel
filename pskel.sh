#!/bin/sh -e

cmd_usage() {
    cat << EOF
Usage: ${0} [task] ...

Available commands:
    init	create new extension
    test	test extension
    build	build PHP runtime
EOF
}

cmd_init() {
  if test "${1}" = "-h" || test "${1}" = "--help" || test "${#}" -lt 1; then
    cat << EOF
Usage: $0 init [extension_name] [ext_skel.php options...]
EOF
    return 0
  fi

  PSKEL_EXT_DIR="/ext"

  if test -d "/workspace/pskel/ext"; then
    echo "[Pskel] Development containers workspace detected, use \"/workspace/pskel/ext\"." >&2
    PSKEL_EXT_DIR="/workspace/pskel/ext"
  fi

  /usr/local/bin/php "/usr/src/php/ext/ext_skel.php" --ext "${1}" --dir "/tmp" ${@}
  rm -rf "${PSKEL_EXT_DIR}"
  mv "/tmp/${1}" "${PSKEL_EXT_DIR}"
}

cmd_test() {
  if test "${1}" = "-h" || test "${1}" = "--help" || test "${#}" -lt 1; then
    cat << EOF
Usage: ${0} test [php_binary_name]
env:
  CFLAGS, CPPFLAGS:	Compile flags
  TEST_PHP_ARGS:	Test flags
EOF
    return 0
  fi

  for BIN in "${1}" "${1}ize" "${1}-config"; do
      if ! type "${1}" > /dev/null 2>&1; then
        echo "Invalid argument: '${1}', executable file not found" >&2
        exit 1
      fi
  done

  PSKEL_EXT_DIR="/ext"

  if test -d "/workspace/pskel/ext"; then
    echo "[Pskel] Development containers workspace detected, use \"/workspace/pskel/ext\"." >&2
    PSKEL_EXT_DIR="/workspace/pskel/ext"
  else
    if test -f "/ext/.gitkeep" && test $(cat "/ext/.gitkeep") = "pskel_uninitialized"; then
       echo "[Pskel] Uninitialized project detected, initialize default skeleton." >&2
       cmd_init "skeleton"
    fi
  fi

  cd "${PSKEL_EXT_DIR}"
    "${1}ize"
    ./configure --with-php-config="$(which "${1}-config")"
    make clean
    make -j"$(nproc)"
    TEST_PHP_ARGS="${TEST_PHP_ARGS} --show-diff -q" make test
  cd -
}

cmd_build() {
  if test "${1}" = "-h" || test "${1}" = "--help" || test "${#}" -lt 1; then
    cat << EOF
Usage: ${0} build [php_binary_prefix]
env:
  CFLAGS, CPPFLAGS:	Compile flags
  CONFIGURE_OPTS:	./configure options
EOF
    return 0
  fi

  cd "/usr/src/php"
    ./buildconf --force
    ./configure --program-prefix="${1}-" --includedir="/usr/local/include/${1}-php" ${CONFIGURE_OPTS}
    make clean
    make -j"$(nproc)"
    make install
    make clean
  cd -
}

if [ $# -eq 0 ]; then
  cmd_usage
  exit 1
fi

case "${1}" in
  help) shift && cmd_usage;;
  init) shift && cmd_init "${@}";;
  test) shift && cmd_test "${@}";;
  build) shift && cmd_build "${@}";;
  *)
    echo "${0} error: invalid command: '${1}'" >&2
    cmd_usage
    exit 1
    ;;
esac
