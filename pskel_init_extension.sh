#!/bin/sh

if test ${#} -lt 1; then
  echo "Usage: pskel_init_extension <extension_name> --auhor <name> [--onlyunix|--onlywindows] ..."
  exit 1
fi

/usr/local/bin/php "/usr/src/php/ext/ext_skel.php" --ext ${1} --dir "/tmp" ${@} && \
rm -rf "/work/ext" && \
mv "/tmp/${1}" "/work/ext"
