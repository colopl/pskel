/* skeleton extension for PHP */

#ifndef PHP_SKELETON_H
# define PHP_SKELETON_H

extern zend_module_entry skeleton_module_entry;
# define phpext_skeleton_ptr &skeleton_module_entry

# define PHP_SKELETON_VERSION "0.1.0"

# if defined(ZTS) && defined(COMPILE_DL_SKELETON)
ZEND_TSRMLS_CACHE_EXTERN()
# endif

#endif	/* PHP_SKELETON_H */
