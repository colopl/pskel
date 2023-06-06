--TEST--
test1() Basic test
--EXTENSIONS--
skeleton
--FILE--
<?php
$ret = test1();

var_dump($ret);
?>
--EXPECT--
The extension skeleton is loaded and working!
NULL
