/* conga extension for PHP */

#ifndef PHP_CONGA_H
# define PHP_CONGA_H

extern zend_module_entry conga_module_entry;
# define phpext_conga_ptr &conga_module_entry

# define PHP_CONGA_VERSION "0.1.0"

# if defined(ZTS) && defined(COMPILE_DL_CONGA)
ZEND_TSRMLS_CACHE_EXTERN()
# endif

#endif	/* PHP_CONGA_H */
