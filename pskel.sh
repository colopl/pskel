#!/bin/sh -e

get_ext_dir() {
  PSKEL_EXT_DIR="/ext"

  if test -d "${CODESPACE_VSCODE_FOLDER}"; then
    echo "[Pskel] GitHub Codespace workspace detected, use \"${CODESPACE_VSCODE_FOLDER}/ext\"." >&2
    PSKEL_EXT_DIR="${CODESPACE_VSCODE_FOLDER}/ext"
  elif test -d "/workspaces/pskel/ext"; then
    echo "[Pskel] Development Containers workspace detected, use \"/workspaces/pskel/ext\"." >&2
    PSKEL_EXT_DIR="/workspaces/pskel/ext"
  else
    if test -f "/ext/.gitkeep" && test $(cat "/ext/.gitkeep") = "pskel_uninitialized"; then
       echo "[Pskel] Uninitialized project detected, initialize default skeleton." >&2
       cmd_init "skeleton"
    fi
  fi

  if test -f "${PSKEL_EXT_DIR}/.gitkeep" && test $(cat "${PSKEL_EXT_DIR}/.gitkeep") = "pskel_uninitialized"; then
    echo "[Pskel] Project not initialized! Please run \"pskel init\"" >&2
    exit 1
  fi

  echo "${PSKEL_EXT_DIR}"
}

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

  PSKEL_EXT_DIR="$(get_ext_dir)"
  /usr/local/bin/php "/usr/src/php/ext/ext_skel.php" --ext "${1}" --dir "/tmp" ${@}
  rm "${PSKEL_EXT_DIR}/.gitkeep"
  rsync -av "/tmp/${1}/" "${PSKEL_EXT_DIR}/"
  rm -rf "/tmp/${1}"
}

cmd_test() {
  if test "${1}" = "-h" || test "${1}" = "--help"; then
    cat << EOF
Usage: ${0} test [test_type|php_binary_name]
env:
  CFLAGS, CPPFLAGS:	Compile flags
  TEST_PHP_ARGS:	Test flags
EOF
    return 0
  fi

  if test "x${1}" = "x"; then
    CC="$(which "gcc")"; CXX="$(which "g++")"; CMD="php"
  else
    case "${1}" in
      debug)
        if ! type "debug-php" > /dev/null 2>&1; then
          CC="$(which "gcc")" CXX="$(which "g++")" CFLAGS="-DZEND_TRACK_ARENA_ALLOC" CPPFLAGS="${CFLAGS}" CONFIGURE_OPTS="--enable-debug $(php -r "echo PHP_ZTS === 1 ? '--enable-zts' : '';") --enable-option-checking=fatal --disable-phpdbg --disable-cgi --disable-fpm --enable-cli --without-pcre-jit --disable-opcache-jit --disable-zend-max-execution-timers" cmd_build "debug"
        fi && \
        CC="$(which "gcc")"; CXX="$(which "g++")"; CMD="debug-php";;
      gcov)
        if ! type "gcc-gcov-php" > /dev/null 2>&1; then
          CC="$(which "gcc")" CXX="$(which "g++")" CFLAGS="--coverage -DZEND_TRACK_ARENA_ALLOC" CPPFLAGS="${CFLAGS}" CONFIGURE_OPTS="--enable-gcov --enable-debug $(php -r "echo PHP_ZTS === 1 ? '--enable-zts' : '';") --enable-option-checking=fatal --disable-phpdbg --disable-cgi --disable-fpm --enable-cli --without-pcre-jit --disable-opcache-jit --disable-zend-max-execution-timers" cmd_build "gcc-gcov"
        fi && \
        CFLAGS="${CFLAGS} --coverage" CPPFLAGS="${CPPFLAGS} --coverage" CC="$(which "gcc")"; CXX="$(which "g++")"; CMD="gcc-gcov-php";;
      valgrind)
        if ! type "gcc-valgrind-php" > /dev/null 2>&1; then
          CC="$(which "gcc")" CXX="$(which "g++")" CFLAGS="-DZEND_TRACK_ARENA_ALLOC" CPPFLAGS="${CFLAGS}" CONFIGURE_OPTS="--enable-debug $(php -r "echo PHP_ZTS === 1 ? '--enable-zts' : '';") --enable-option-checking=fatal --disable-phpdbg --disable-cgi --disable-fpm --enable-cli --without-pcre-jit --disable-opcache-jit --disable-zend-max-execution-timers --with-valgrind" cmd_build "gcc-valgrind"
        fi && \
        TEST_PHP_ARGS="${TEST_PHP_ARGS} -m" CC="$(which "gcc")"; CXX="$(which "g++")"; CMD="gcc-valgrind-php";;
      msan)
        if ! type "clang-msan-php" > /dev/null 2>&1; then
          CC="$(which "clang")" CXX="$(which "clang++")" CFLAGS="-DZEND_TRACK_ARENA_ALLOC" CPPFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS} -fsanitize=memory" CONFIGURE_OPTS="--enable-debug $(php -r "echo PHP_ZTS === 1 ? '--enable-zts' : '';") --enable-option-checking=fatal --disable-phpdbg --disable-cgi --disable-fpm --enable-cli --without-pcre-jit --disable-opcache-jit --disable-zend-max-execution-timers --enable-memory-sanitizer" cmd_build "clang-msan"
        fi && \
        CFLAGS="${CFLAGS} -fsanitize=memory"; CPPFLAGS="${CPPFLAGS}"; LDFLAGS="-fsanitize=memory"; CC="$(which "clang")"; CXX="$(which "clang++")"; CMD="clang-msan-php";;
      asan)
        if ! type "clang-asan-php" > /dev/null 2>&1; then
          CC="$(which "clang")" CXX="$(which "clang++")" CFLAGS="-DZEND_TRACK_ARENA_ALLOC" CPPFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS} -fsanitize=address" CONFIGURE_OPTS="--enable-debug $(php -r "echo PHP_ZTS === 1 ? '--enable-zts' : '';") --enable-option-checking=fatal --disable-phpdbg --disable-cgi --disable-fpm --enable-cli --without-pcre-jit --disable-opcache-jit --disable-zend-max-execution-timers --enable-address-sanitizer" cmd_build "clang-asan"
        fi && \
        CFLAGS="${CFLAGS} -fsanitize=address"; CPPFLAGS="${CPPFLAGS}"; LDFLAGS="-fsanitize=address"; CC="$(which "clang")"; CXX="$(which "clang++")"; CMD="clang-asan-php";;
      ubsan)
        if ! type "clang-ubsan-php" > /dev/null 2>&1; then
          CC="$(which "clang")" CXX="$(which "clang++")" CFLAGS="-DZEND_TRACK_ARENA_ALLOC" CPPFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS} -fsanitize=undefined" CONFIGURE_OPTS="--enable-debug $(php -r "echo PHP_ZTS === 1 ? '--enable-zts' : '';") --enable-option-checking=fatal --disable-phpdbg --disable-cgi --disable-fpm --enable-cli --without-pcre-jit --disable-opcache-jit --disable-zend-max-execution-timers --enable-undefined-sanitizer" cmd_build "clang-ubsan"
        fi && \
        CFLAGS="${CFLAGS} -fsanitize=undefined"; CPPFLAGS="${CPPFLAGS}"; LDFLAGS="-fsanitize=undefined"; CC="$(which "clang")"; CXX="$(which "clang++")"; CMD="clang-ubsan-php";;
      *) CMD="${1}"
    esac
  fi

  for BIN in "${CMD}" "${CMD}ize" "${CMD}-config"; do
    if ! type "${BIN}" > /dev/null 2>&1; then
      echo "Invalid argument: '${CMD}', executable file not found" >&2
      exit 1
    fi
  done

  PSKEL_EXT_DIR="$(get_ext_dir)"

  cd "${PSKEL_EXT_DIR}"
    "${CMD}ize"
    if test "$("${CMD}" -r "echo PHP_VERSION_ID;")" -lt "80400"; then
      patch "./build/ltmain.sh" "./../patches/ltmain.sh.patch"
      echo "[Pskel] ltmain.sh patched" >&2
    fi
    CC=${CC} CXX=${CXX} CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" ./configure --with-php-config="$(which "${CMD}-config")"
    make clean
    make -j"$(nproc)"
    TEST_PHP_ARGS="${TEST_PHP_ARGS} --show-diff -q" make test
  cd -
}

cmd_build() {
  if test "${1}" = "-h" || test "${1}" = "--help"; then
    cat << EOF
Usage: ${0} build [php_binary_prefix]
env:
  CFLAGS, CPPFLAGS:	Compile flags
  CONFIGURE_OPTS:	./configure options
EOF
    return 0
  fi

  if ! test "x${1}" = "x"; then
    CONFIGURE_OPTS="--program-prefix="${1}-" --includedir="/usr/local/include/${1}-php" ${CONFIGURE_OPTS}"
  fi

  cd "/usr/src/php"
    ./buildconf --force
    ./configure ${CONFIGURE_OPTS}
    make clean
    make -j"$(nproc)"
    make install
    make clean
  cd -
}

cmd_coverage() {
  cmd_test "gcov"

  PSKEL_EXT_DIR="$(get_ext_dir)"

  lcov --capture --directory "${PSKEL_EXT_DIR}" ${LCOV_OPTIONS} --exclude "/usr/local/include/*" --output-file "${PSKEL_EXT_DIR}/lcov.info"
  lcov --list "${PSKEL_EXT_DIR}/lcov.info"
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
  coverage) shift && cmd_coverage "${@}";;
  *)
    echo "${0} error: invalid command: '${1}'" >&2
    cmd_usage
    exit 1
    ;;
esac
