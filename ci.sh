#!/bin/sh -e

case "${1}" in
  "") ;;
  "test") TEST_EXTENSION=1;;
  "gcc"|"valgrind") TEST_EXTENSION_VALGRIND=1;;
  "clang"|"msan") TEST_EXTENSION_MSAN=1;;
  *) printf "Pskel CI\nusage:\n\t%s\t: %s\n\t%s\t: %s\n\t%s\t: %s\n" "test" "Test extension with pre-installed PHP binary. [bin: $(which "php")]" "gcc" "Test extension with GCC binary with Valgrind. [bin: $(which "gcc-debug-php")]" "clang" "Test extension with Clang binary with MemorySanitizer. [bin: $(which "clang-debug-php")]"; exit 0;;
esac

echo "[Pskel CI] BEGIN TEST"

if test "${TEST_EXTENSION}" != ""; then
  cd "/ext"
  phpize
  ./configure --with-php-config="$(which php-config)"
  make clean
  make -j"$(nproc)"
  TEST_PHP_ARGS="--show-diff -q" make test
else
  echo "[Pskel CI] skip: TEST_EXTENSION is not set"
fi

if test "${TEST_EXTENSION_VALGRIND}" != ""; then
  if type "gcc-debug-php" > /dev/null 2>&1; then
    cd "/ext"
    gcc-debug-phpize
    ./configure --with-php-config="$(which gcc-debug-php-config)"
    make clean
    make -j"$(nproc)"
    TEST_PHP_ARGS="--show-diff -q -m" make test
  else
    echo "[Pskel CI] missing gcc-debug-php"
    exit 1
  fi
else
  echo "[Pskel CI] skip: TEST_EXTENSION_VALGRIND is not set"
fi

if test "${TEST_EXTENSION_MSAN}" != ""; then
  if type "clang-debug-php" > /dev/null 2>&1; then
    cd "/ext"
    clang-debug-phpize
    CC=clang CXX=clang++ CFLAGS="-fsanitize=memory -DZEND_TRACK_ARENA_ALLOC" LDFLAGS="-fsanitize=memory" ./configure --with-php-config="$(which clang-debug-php-config)"
    make clean
    CFLAGS="-fsanitize=memory -DZEND_TRACK_ARENA_ALLOC" LDFLAGS="-fsanitize=memory" make -j"$(nproc)"
    TEST_PHP_ARGS="--show-diff -q --msan" make test
  else
    echo "[Pskel CI] missing clang-debug-php"
    exit 1
  fi
else
  echo "[Pskel CI] skip: TEST_EXTENSION_MSAN is not set"
fi

echo "[Pskel CI] END TEST"
exit 0
