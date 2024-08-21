/* bongo extension for PHP */

#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include "php.h"
#include "ext/standard/info.h"
#include "php_bongo.h"
#include "bongo_arginfo.h"

/* For compatibility with older PHP versions */
#ifndef ZEND_PARSE_PARAMETERS_NONE
#define ZEND_PARSE_PARAMETERS_NONE() \
	ZEND_PARSE_PARAMETERS_START(0, 0) \
	ZEND_PARSE_PARAMETERS_END()
#endif

/* {{{ void test1() */
PHP_FUNCTION(test1)
{
	ZEND_PARSE_PARAMETERS_NONE();

	php_printf("The extension %s is loaded and working!\r\n", "bongo");
}
/* }}} */

/* {{{ string test2( [ string $var ] ) */
PHP_FUNCTION(test2)
{
	char *var = "World";
	size_t var_len = sizeof("World") - 1;
	zend_string *retval;

	ZEND_PARSE_PARAMETERS_START(0, 1)
		Z_PARAM_OPTIONAL
		Z_PARAM_STRING(var, var_len)
	ZEND_PARSE_PARAMETERS_END();

	retval = strpprintf(0, "Hello %s", var);

	RETURN_STR(retval);
}
/* }}}*/

PHP_FUNCTION(test3)
{
	const char *var = "World";
	zend_string *retval;

#if defined(ZTS)
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
#else

	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
	retval = strpprintf(0, "Hello %s", var);
#endif

	retval = strpprintf(0, "Hello %s", var);

	RETURN_STR(retval);
}

/* {{{ PHP_RINIT_FUNCTION */
PHP_RINIT_FUNCTION(bongo)
{
#if defined(ZTS) && defined(COMPILE_DL_BONGO)
	ZEND_TSRMLS_CACHE_UPDATE();
#endif
	return SUCCESS;
}
/* }}} */

/* {{{ PHP_MINFO_FUNCTION */
PHP_MINFO_FUNCTION(bongo)
{
	php_info_print_table_start();
	php_info_print_table_row(2, "bongo support", "enabled");
	php_info_print_table_end();
}
/* }}} */

/* {{{ bongo_module_entry */
zend_module_entry bongo_module_entry = {
	STANDARD_MODULE_HEADER,
	"bongo",					/* Extension name */
	ext_functions,					/* zend_function_entry */
	NULL,							/* PHP_MINIT - Module initialization */
	NULL,							/* PHP_MSHUTDOWN - Module shutdown */
	PHP_RINIT(bongo),			/* PHP_RINIT - Request initialization */
	NULL,							/* PHP_RSHUTDOWN - Request shutdown */
	PHP_MINFO(bongo),			/* PHP_MINFO - Module info */
	PHP_BONGO_VERSION,		/* Version */
	STANDARD_MODULE_PROPERTIES
};
/* }}} */

#ifdef COMPILE_DL_BONGO
# ifdef ZTS
ZEND_TSRMLS_CACHE_DEFINE()
# endif
ZEND_GET_MODULE(bongo)
#endif
