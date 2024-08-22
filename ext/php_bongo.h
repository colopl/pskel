/* bongo extension for PHP */

#ifndef PHP_BONGO_H
# define PHP_BONGO_H

extern zend_module_entry bongo_module_entry;
# define phpext_bongo_ptr &bongo_module_entry

# define PHP_BONGO_VERSION "0.1.0"

# if defined(ZTS) && defined(COMPILE_DL_BONGO)
ZEND_TSRMLS_CACHE_EXTERN()
# endif

#endif	/* PHP_BONGO_H */
