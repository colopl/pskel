dnl config.m4 for extension bongo

dnl Comments in this file start with the string 'dnl'.
dnl Remove where necessary.

dnl If your extension references something external, use 'with':

dnl PHP_ARG_WITH([bongo],
dnl   [for bongo support],
dnl   [AS_HELP_STRING([--with-bongo],
dnl     [Include bongo support])])

dnl Otherwise use 'enable':

PHP_ARG_ENABLE([bongo],
  [whether to enable bongo support],
  [AS_HELP_STRING([--enable-bongo],
    [Enable bongo support])],
  [no])

if test "$PHP_BONGO" != "no"; then
  dnl Write more examples of tests here...

  dnl Remove this code block if the library does not support pkg-config.
  dnl PKG_CHECK_MODULES([LIBFOO], [foo])
  dnl PHP_EVAL_INCLINE($LIBFOO_CFLAGS)
  dnl PHP_EVAL_LIBLINE($LIBFOO_LIBS, BONGO_SHARED_LIBADD)

  dnl If you need to check for a particular library version using PKG_CHECK_MODULES,
  dnl you can use comparison operators. For example:
  dnl PKG_CHECK_MODULES([LIBFOO], [foo >= 1.2.3])
  dnl PKG_CHECK_MODULES([LIBFOO], [foo < 3.4])
  dnl PKG_CHECK_MODULES([LIBFOO], [foo = 1.2.3])

  dnl Remove this code block if the library supports pkg-config.
  dnl --with-bongo -> check with-path
  dnl SEARCH_PATH="/usr/local /usr"     # you might want to change this
  dnl SEARCH_FOR="/include/bongo.h"  # you most likely want to change this
  dnl if test -r $PHP_BONGO/$SEARCH_FOR; then # path given as parameter
  dnl   BONGO_DIR=$PHP_BONGO
  dnl else # search default path list
  dnl   AC_MSG_CHECKING([for bongo files in default path])
  dnl   for i in $SEARCH_PATH ; do
  dnl     if test -r $i/$SEARCH_FOR; then
  dnl       BONGO_DIR=$i
  dnl       AC_MSG_RESULT(found in $i)
  dnl     fi
  dnl   done
  dnl fi
  dnl
  dnl if test -z "$BONGO_DIR"; then
  dnl   AC_MSG_RESULT([not found])
  dnl   AC_MSG_ERROR([Please reinstall the bongo distribution])
  dnl fi

  dnl Remove this code block if the library supports pkg-config.
  dnl --with-bongo -> add include path
  dnl PHP_ADD_INCLUDE($BONGO_DIR/include)

  dnl Remove this code block if the library supports pkg-config.
  dnl --with-bongo -> check for lib and symbol presence
  dnl LIBNAME=BONGO # you may want to change this
  dnl LIBSYMBOL=BONGO # you most likely want to change this

  dnl If you need to check for a particular library function (e.g. a conditional
  dnl or version-dependent feature) and you are using pkg-config:
  dnl PHP_CHECK_LIBRARY($LIBNAME, $LIBSYMBOL,
  dnl [
  dnl   AC_DEFINE(HAVE_BONGO_FEATURE, 1, [ ])
  dnl ],[
  dnl   AC_MSG_ERROR([FEATURE not supported by your bongo library.])
  dnl ], [
  dnl   $LIBFOO_LIBS
  dnl ])

  dnl If you need to check for a particular library function (e.g. a conditional
  dnl or version-dependent feature) and you are not using pkg-config:
  dnl PHP_CHECK_LIBRARY($LIBNAME, $LIBSYMBOL,
  dnl [
  dnl   PHP_ADD_LIBRARY_WITH_PATH($LIBNAME, $BONGO_DIR/$PHP_LIBDIR, BONGO_SHARED_LIBADD)
  dnl   AC_DEFINE(HAVE_BONGO_FEATURE, 1, [ ])
  dnl ],[
  dnl   AC_MSG_ERROR([FEATURE not supported by your bongo library.])
  dnl ],[
  dnl   -L$BONGO_DIR/$PHP_LIBDIR -lm
  dnl ])
  dnl
  dnl PHP_SUBST(BONGO_SHARED_LIBADD)

  dnl In case of no dependencies
  AC_DEFINE(HAVE_BONGO, 1, [ Have bongo support ])

  PHP_NEW_EXTENSION(bongo, bongo.c, $ext_shared)
fi
